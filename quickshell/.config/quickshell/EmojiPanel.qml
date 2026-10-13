import QtQuick
import QtQuick as QQ
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
	id: root

	property alias query: queryInput.text
	property int selectedIndex: 0
	property var emojis: []
	readonly property var results: filterRows(emojis, query)
	readonly property int visibleRows: Math.min(7, results.length)
	readonly property int searchHeight: 48
	readonly property int rowHeight: 58
	readonly property int footerHeight: 20

	function parseEmoji(output: string): void {
		const rows = [];
		for (const line of output.split("\n")) {
			if (!line)
				continue;
			const fields = line.split("\t");
			if (fields.length < 4)
				continue;
			rows.push({
				emoji: fields[0],
				category: fields[1],
				group: fields[2],
				name: fields[3],
				keywords: fields.slice(4).join(" ")
			});
		}
		emojis = rows;
	}

	function filterRows(rows, filter): var {
		const needle = filter.trim().toLowerCase();
		if (!needle)
			return rows;
		return rows.filter(row => `${row.name} ${row.keywords} ${row.category} ${row.group}`
			.toLowerCase().includes(needle));
	}

	function open(): void {
		query = "";
		selectedIndex = 0;
		ShellState.resetPointerSelection();
		if (emojis.length === 0)
			emojiReader.running = true;
		Qt.callLater(() => queryInput.forceActiveFocus());
	}

	function close(): void {
		ShellState.close();
	}

	function moveSelection(delta: int): void {
		if (results.length === 0)
			return;
		selectedIndex = ((selectedIndex + delta) % results.length + results.length) % results.length;
		resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
	}

	function copySelected(): void {
		if (selectedIndex < 0 || selectedIndex >= results.length)
			return;
		Quickshell.execDetached(["wl-copy", results[selectedIndex].emoji]);
		close();
	}

	visible: ShellState.activePanel === "emoji"
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-emoji"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	onResultsChanged: {
		if (results.length === 0)
			selectedIndex = 0;
		else if (selectedIndex >= results.length)
			selectedIndex = results.length - 1;
	}

	Process {
		id: emojiReader
		command: [`${Quickshell.shellDir}/scripts/emoji-data`]
		stdout: StdioCollector {
			onStreamFinished: root.parseEmoji(text)
		}
	}

	MouseArea {
		anchors.fill: parent
		onClicked: root.close()
	}

	PopupShadow { target: card }

	Rectangle {
		id: card
		width: Math.min(660, root.width - 64)
		height: 30 + root.searchHeight + Math.max(root.rowHeight, root.visibleRows * root.rowHeight)
			+ root.footerHeight + 20
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
					root.moveSelection(-7);
				} else if (event.key === Qt.Key_PageDown) {
					root.moveSelection(7);
				} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					root.copySelected();
				} else if (event.key === Qt.Key_U && ctrl) {
					root.query = "";
				} else {
					return;
				}
				event.accepted = true;
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 15
			spacing: 10

			Rectangle {
				id: search
				Layout.fillWidth: true
				Layout.preferredHeight: root.searchHeight
				color: "transparent"
				radius: 8
				border.width: 1
				border.color: Theme.border

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 14
					anchors.rightMargin: 14
					spacing: 12

					Text {
						text: "emoji"
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 17
						font.weight: Font.Medium
					}

					SearchInput {
						id: queryInput
						Layout.fillWidth: true
						Keys.forwardTo: [keyHandler]
						onTextChanged: {
							root.selectedIndex = 0;
							resultList.positionViewAtBeginning();
						}
					}
				}
			}

			ListView {
				id: resultList
				Layout.fillWidth: true
				Layout.preferredHeight: Math.max(root.rowHeight, root.visibleRows * root.rowHeight)
				clip: true
				model: root.results
				currentIndex: root.selectedIndex
				boundsBehavior: Flickable.StopAtBounds

				delegate: Rectangle {
					id: row
					required property int index
					required property var modelData
					readonly property bool selected: index === root.selectedIndex
					width: ListView.view.width
					height: root.rowHeight
					radius: 8
					color: selected ? Theme.selected : "transparent"

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 12
						anchors.rightMargin: 12
						spacing: 14

						QQ.Text {
							Layout.preferredWidth: 38
							text: row.modelData.emoji
							font.family: "Noto Color Emoji"
							font.pixelSize: 25
							renderType: QQ.Text.NativeRendering
							horizontalAlignment: QQ.Text.AlignHCenter
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 1

							Text {
								Layout.fillWidth: true
								text: row.modelData.name
								color: row.selected ? Theme.selectedText : Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 16
								font.weight: Font.Medium
								elide: Text.ElideRight
							}

							Text {
								Layout.fillWidth: true
								text: row.modelData.category
								color: row.selected ? Theme.selectedText : Theme.muted
								opacity: row.selected ? 0.65 : 1
								font.family: Theme.fontFamily
								font.pixelSize: 11
								elide: Text.ElideRight
							}
						}

						Text {
							visible: row.selected
							text: "↵ copy"
							color: Theme.selectedText
							opacity: 0.55
							font.family: Theme.fontFamily
							font.pixelSize: 10
						}
					}

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onPositionChanged: mouse => {
							if (ShellState.pointerSelectionMoved(row.mapToItem(card, mouse.x, mouse.y)))
								root.selectedIndex = row.index;
						}
						onClicked: {
							root.selectedIndex = row.index;
							root.copySelected();
						}
					}
				}

				Text {
					anchors.centerIn: parent
					visible: root.results.length === 0
					text: root.emojis.length === 0 ? "loading emoji" : `no matches for “${root.query}”`
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 14
				}
			}

			RowLayout {
				id: footer
				Layout.fillWidth: true
				Layout.preferredHeight: root.footerHeight
				Layout.leftMargin: 10
				spacing: 18

				KeyHint { shortcut: "↑↓"; description: "navigate" }
				KeyHint { shortcut: "↵"; description: "copy" }
				KeyHint { shortcut: "esc"; description: "close" }
				Item { Layout.fillWidth: true }
			}
		}
	}
}
