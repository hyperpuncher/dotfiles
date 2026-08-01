import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
	id: root

	property string query: ""
	property int selectedIndex: 0
	property var history: []
	readonly property var results: filterRows(history, query)
	property string previewText: ""
	property string previewImage: ""

	function parseHistory(output: string): void {
		const rows = [];
		for (const line of output.split("\n")) {
			if (!line)
				continue;
			const separator = line.indexOf("\t");
			if (separator < 0)
				continue;
			const id = line.slice(0, separator);
			const value = line.slice(separator + 1);
			const imageMatch = value.match(/binary data.*\s(png|jpe?g|webp|bmp)\s/i);
			rows.push({
				id,
				raw: line,
				value,
				kind: imageMatch ? "image" : "text",
				extension: imageMatch ? imageMatch[1].toLowerCase().replace("jpeg", "jpg") : ""
			});
		}
		history = rows;
		selectedIndex = 0;
		loadPreview();
	}

	function compact(value: string): string {
		return value.toLowerCase().replace(/[^a-z0-9]/g, "");
	}

	function filterRows(rows, filter): var {
		const needle = filter.trim().toLowerCase();
		if (!needle)
			return rows.slice(0, 100);
		const compactNeedle = compact(needle);
		return rows.filter(row => row.value.toLowerCase().includes(needle)
			|| compact(row.value).includes(compactNeedle)).slice(0, 100);
	}

	function open(): void {
		query = "";
		selectedIndex = 0;
		ShellState.resetPointerSelection();
		ShellState.open("clipboard");
		reload();
		Qt.callLater(() => keyHandler.forceActiveFocus());
	}

	function close(): void {
		ShellState.close();
	}

	function reload(): void {
		listProcess.running = false;
		listProcess.running = true;
	}

	function selectedRow(): var {
		return selectedIndex >= 0 && selectedIndex < results.length ? results[selectedIndex] : null;
	}

	function loadPreview(): void {
		const row = selectedRow();
		previewText = "";
		previewImage = "";
		if (!row)
			return;

		if (row.kind === "image") {
			imageDecode.rowId = row.id;
			imageDecode.outputPath = `/tmp/quickshell-clipboard-${row.id}.${row.extension}`;
			imageDecode.command = ["bash", "-c", "printf '%s\\n' \"$1\" | cliphist decode > \"$2\"", "_", row.raw, imageDecode.outputPath];
			imageDecode.running = false;
			imageDecode.running = true;
		} else {
			textDecode.rowId = row.id;
			textDecode.command = ["bash", "-c", "printf '%s\\n' \"$1\" | cliphist decode", "_", row.raw];
			textDecode.running = false;
			textDecode.running = true;
		}
	}

	function moveSelection(delta: int): void {
		if (results.length === 0)
			return;
		selectedIndex = (selectedIndex + delta + results.length) % results.length;
		resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
		loadPreview();
	}

	function copySelected(): void {
		const row = selectedRow();
		if (!row)
			return;
		Quickshell.execDetached(["bash", "-c", "printf '%s\\n' \"$1\" | cliphist decode | wl-copy", "_", row.raw]);
		close();
	}

	function deleteSelected(): void {
		const row = selectedRow();
		if (!row)
			return;
		deleteProcess.command = ["bash", "-c", "printf '%s\\n' \"$1\" | cliphist delete", "_", row.raw];
		deleteProcess.running = true;
	}

	visible: ShellState.activePanel === "clipboard"
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-clipboard"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	onVisibleChanged: if (visible) open()
	onResultsChanged: {
		if (results.length === 0)
			selectedIndex = 0;
		else if (selectedIndex >= results.length)
			selectedIndex = results.length - 1;
		loadPreview();
	}

	Process {
		id: listProcess
		command: ["cliphist", "list"]
		stdout: StdioCollector {
			onStreamFinished: root.parseHistory(text)
		}
	}

	Process {
		id: textDecode
		property string rowId: ""
		stdout: StdioCollector {
			onStreamFinished: {
				const row = root.selectedRow();
				if (row && row.id === textDecode.rowId)
					root.previewText = text;
			}
		}
	}

	Process {
		id: imageDecode
		property string rowId: ""
		property string outputPath: ""
		onExited: imagePreviewDelay.restart()
	}

	Timer {
		id: imagePreviewDelay
		interval: 40
		onTriggered: {
			const row = root.selectedRow();
			if (row && row.id === imageDecode.rowId)
				root.previewImage = `file://${imageDecode.outputPath}?v=${Date.now()}`;
		}
	}

	Process {
		id: deleteProcess
		onExited: root.reload()
	}

	MouseArea {
		anchors.fill: parent
		onClicked: root.close()
	}

	Rectangle {
		id: card
		width: Math.min(1140, root.width - 80)
		height: Math.min(620, root.height - 80)
		anchors.centerIn: parent
		color: Theme.surface
		radius: Theme.radius
		border.width: 1
		border.color: Theme.border

		MouseArea {
			anchors.fill: parent
			onClicked: mouse => mouse.accepted = true
		}

		Item {
			id: keyHandler
			anchors.fill: parent
			focus: root.visible

			Keys.priority: Keys.BeforeItem
			Keys.onPressed: event => {
				const ctrl = event.modifiers & Qt.ControlModifier;
				if (event.key === Qt.Key_Escape) {
					root.close();
				} else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K)) {
					root.moveSelection(-1);
				} else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J)) {
					root.moveSelection(1);
				} else if (event.key === Qt.Key_PageUp) {
					root.moveSelection(-6);
				} else if (event.key === Qt.Key_PageDown) {
					root.moveSelection(6);
				} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					root.copySelected();
				} else if (event.key === Qt.Key_Delete) {
					root.deleteSelected();
				} else if (event.key === Qt.Key_Backspace) {
					root.query = root.query.slice(0, -1);
					root.selectedIndex = 0;
				} else if (event.key === Qt.Key_U && ctrl) {
					root.query = "";
					root.selectedIndex = 0;
				} else if (event.text.length === 1 && event.text.charCodeAt(0) >= 32
						&& (event.modifiers === Qt.NoModifier || event.modifiers === Qt.ShiftModifier)) {
					root.query += event.text;
					root.selectedIndex = 0;
				} else {
					return;
				}
				event.accepted = true;
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 18
			spacing: 12

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 50
				color: "transparent"
				radius: 8
				border.width: 1
				border.color: Theme.border

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 15
					anchors.rightMargin: 15
					spacing: 12

					Text {
						text: "clipboard"
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 17
						font.weight: Font.Medium
					}

					Item {
						Layout.fillWidth: true
						Layout.fillHeight: true

						Row {
							anchors.left: parent.left
							anchors.verticalCenter: parent.verticalCenter
							spacing: 2

							Text {
								text: root.query
								color: Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 17
							}

							Rectangle {
								anchors.verticalCenter: parent.verticalCenter
								width: 1
								height: 19
								color: Theme.text
								SequentialAnimation on opacity {
									running: root.visible
									loops: Animation.Infinite
									NumberAnimation { to: 0; duration: 550 }
									NumberAnimation { to: 1; duration: 550 }
								}
							}
						}
					}
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				spacing: 20

				ListView {
					id: resultList
					Layout.preferredWidth: 470
					Layout.fillHeight: true
					clip: true
					spacing: 3
					model: root.results
					currentIndex: root.selectedIndex
					boundsBehavior: Flickable.StopAtBounds

					delegate: Rectangle {
						id: row
						required property int index
						required property var modelData
						readonly property bool selected: index === root.selectedIndex
						property string thumbnailSource: ""
						readonly property string thumbnailPath: `/tmp/quickshell-clipboard-thumb-${modelData.id}.png`
						readonly property string thumbnailInput: `/tmp/quickshell-clipboard-thumb-${modelData.id}.${modelData.extension}`

						function loadThumbnail(): void {
							thumbnailSource = "";
							if (modelData.kind !== "image")
								return;
							thumbnailDecode.command = [
								`${Quickshell.shellDir}/scripts/clipboard-thumbnail`,
								modelData.raw,
								thumbnailInput,
								thumbnailPath
							];
							thumbnailDecode.running = false;
							thumbnailDecode.running = true;
						}

						Component.onCompleted: loadThumbnail()
						onModelDataChanged: loadThumbnail()

						Process {
							id: thumbnailDecode
							onExited: (exitCode, exitStatus) => {
								if (exitCode === 0)
									row.thumbnailSource = `file://${row.thumbnailPath}?v=${Date.now()}`;
							}
						}

						width: ListView.view.width
						height: 58
						radius: 8
						color: selected ? Theme.selected : "transparent"

						RowLayout {
							anchors.fill: parent
							anchors.leftMargin: 12
							anchors.rightMargin: 12
							spacing: 12

							Rectangle {
								Layout.preferredWidth: 38
								Layout.preferredHeight: 38
								radius: 8
								color: row.selected ? Qt.rgba(0.5, 0.5, 0.5, 0.2) : Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.12)

								Image {
									anchors.fill: parent
									anchors.margins: 1
									visible: row.thumbnailSource !== ""
									source: row.thumbnailSource
									sourceSize: Qt.size(68, 68)
									fillMode: Image.PreserveAspectCrop
									clip: true
									asynchronous: true
									smooth: true
								}

								Text {
									anchors.centerIn: parent
									visible: row.thumbnailSource === ""
									text: row.modelData.kind === "image" ? "" : ""
									color: row.selected ? Theme.selectedText : Theme.text
									font.family: "IosevkaTerm Nerd Font Mono"
									font.pixelSize: 19
								}

								Rectangle {
									anchors.fill: parent
									z: 2
									color: "transparent"
									radius: 8
									border.width: 1
									border.pixelAligned: true
									border.color: Theme.border
								}
							}

							ColumnLayout {
								Layout.fillWidth: true
								spacing: 2

								Text {
									Layout.fillWidth: true
									text: row.modelData.kind === "image" ? row.modelData.value.replace(/^\[\[\s*|\s*\]\]$/g, "") : row.modelData.value.replace(/\s+/g, " ")
									color: row.selected ? Theme.selectedText : Theme.text
									font.family: Theme.fontFamily
									font.pixelSize: 15
									font.weight: Font.Medium
									elide: Text.ElideRight
								}

								Text {
									text: row.modelData.kind
									color: row.selected ? Theme.selectedText : Theme.muted
									opacity: row.selected ? 0.65 : 1
									font.family: Theme.fontFamily
									font.pixelSize: 11
								}
							}
						}

						MouseArea {
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onPositionChanged: mouse => {
								if (ShellState.pointerSelectionMoved(row.mapToItem(card, mouse.x, mouse.y))) {
									root.selectedIndex = row.index;
									root.loadPreview();
								}
							}
							onClicked: {
								root.selectedIndex = row.index;
								root.loadPreview();
								root.copySelected();
							}
						}
					}

					Text {
						anchors.centerIn: parent
						visible: root.results.length === 0
						text: root.query ? `no matches for “${root.query}”` : "clipboard is empty"
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 14
					}
				}

				Rectangle {
					Layout.preferredWidth: 1
					Layout.fillHeight: true
					color: Theme.border
				}

				Item {
					Layout.fillWidth: true
					Layout.fillHeight: true
					clip: true

					Text {
						anchors.fill: parent
						anchors.margins: 10
						visible: root.previewImage === ""
						text: root.previewText
						color: Theme.text
						font.family: Theme.fontFamily
						font.pixelSize: 15
						wrapMode: Text.WrapAnywhere
						verticalAlignment: Text.AlignTop
					}

					Image {
						anchors.fill: parent
						anchors.margins: 10
						visible: root.previewImage !== ""
						source: root.previewImage
						fillMode: Image.PreserveAspectFit
						asynchronous: true
						smooth: true
					}
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Layout.leftMargin: 10
				Layout.preferredHeight: 18
				spacing: 18

				KeyHint { shortcut: "type"; description: "filter" }
				KeyHint { shortcut: "↵"; description: "copy" }
				KeyHint { shortcut: "del"; description: "remove" }
				KeyHint { shortcut: "esc"; description: "close" }
				Item { Layout.fillWidth: true }
			}
		}
	}
}
