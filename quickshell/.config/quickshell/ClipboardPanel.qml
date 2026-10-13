import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
	id: root

	property alias query: queryInput.text
	property int selectedIndex: 0
	property var history: []
	property var linkPreviewCache: ({})
	readonly property var results: filterRows(history, query)
	readonly property string previewText: previewLoader.item ? previewLoader.item.text : ""
	readonly property string previewImage: previewLoader.item ? previewLoader.item.image.toString() : ""
	readonly property var linkPreview: previewLoader.item ? previewLoader.item.link : null
	readonly property string imageDirectory: `${Quickshell.env("XDG_RUNTIME_DIR") || Quickshell.cacheDir}/clipboard-images`
	readonly property string imageCacheDirectory: `${imageDirectory}/sources`
	readonly property string riftSocketPath: `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/rift.sock`

	function formatSize(bytes: double): string {
		if (bytes < 1024)
			return `${bytes} B`;
		if (bytes < 1024 * 1024)
			return `${(bytes / 1024).toFixed(1)} KiB`;
		if (bytes < 1024 * 1024 * 1024)
			return `${(bytes / (1024 * 1024)).toFixed(1)} MiB`;
		return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} GiB`;
	}

	function imageExtension(mime: string): string {
		const subtype = mime.split("/")[1] || "image";
		return subtype.replace("jpeg", "jpg").replace("svg+xml", "svg");
	}

	function fileIcon(type: string): string {
		const icons = {
			folder: "",
			audio: "",
			video: "",
			image: "",
			archive: "",
			document: "",
			text: "",
			code: "",
			font: "",
			file: ""
		};
		return icons[type] || icons.file;
	}

	function linkUrl(value: string): string {
		const candidate = value.trim();
		return /^https?:\/\/\S+$/.test(candidate) ? candidate : "";
	}

	function linkHost(url: string): string {
		return url.replace(/^https?:\/\//, "").split(/[\/#?]/)[0];
	}

	function rowDetail(row): string {
		const incomplete = row.complete ? "" : " · incomplete";
		if (row.kind === "link")
			return `${linkHost(row.url)} · link${incomplete}`;
		if (row.kind === "image")
			return `${row.extension.toUpperCase()} · image · ${row.imageSize || row.storedSize}${incomplete}`;
		if (row.kind === "file") {
			if (row.fileType === "folder")
				return `folder${incomplete}`;
			const format = row.extension ? `${row.extension.toUpperCase()} · ` : "";
			return `${format}${row.fileType} · ${row.fileSize}${incomplete}`;
		}
		return `text · ${row.storedSize}${incomplete}`;
	}

	function parseHistory(output: string): void {
		let items = [];
		try {
			items = JSON.parse(output);
		} catch (error) {
			console.warn("failed to parse Rift history:", error);
			return;
		}
		const textPriority = ["text/plain;charset=utf-8", "text/plain", "UTF8_STRING", "STRING", "TEXT"];
		const rows = items.map(item => {
			const formats = item.formats || [];
			const imageFormat = formats.find(format => format.mime.startsWith("image/"));
			const imageMetadata = item.image || null;
			let text = null;
			for (const mime of textPriority) {
				text = formats.find(format => format.mime === mime);
				if (text)
					break;
			}
			if (!text)
				text = formats.find(format => format.mime === "text/uri-list" || format.mime.startsWith("text/"));
			const preview = item.text_preview || "";
			const file = item.file || null;
			const isFile = file !== null;
			const primary = isFile ? text || formats[0] || { mime: "unknown", size: 0 }
				: imageFormat || text || formats[0] || { mime: "unknown", size: 0 };
			const fileName = isFile ? file.name : "";
			const detectedFileType = isFile ? file.category : "";
			const url = !isFile && !imageFormat ? linkUrl(preview) : "";
			const kind = isFile ? "file" : imageFormat ? "image" : url ? "link" : "text";
			return {
				id: item.id,
				value: item.sensitive ? "sensitive clipboard item" : isFile ? fileName : preview.trim() ? preview : primary.mime,
				kind,
				extension: isFile ? file.extension : imageFormat ? imageExtension(imageFormat.mime) : "",
				previewMime: primary.mime,
				storedSize: formatSize(item.stored_bytes || 0),
				imageSize: imageMetadata ? formatSize(imageMetadata.size || 0) : "",
				imageTitle: imageMetadata ? `${imageMetadata.width} × ${imageMetadata.height}` : "copied image",
				fileSize: isFile ? formatSize(file.size || 0) : "",
				fileType: detectedFileType,
				fileIcon: isFile ? fileIcon(detectedFileType) : "",
				filePath: isFile ? file.path : "",
				url,
				sensitive: item.sensitive,
				complete: item.complete,
				fileName
			};
		});
		if (JSON.stringify(rows) === JSON.stringify(history))
			return;
		const selectedId = selectedIndex > 0 && selectedRow() ? selectedRow().id : "";
		history = rows;
		selectedIndex = Math.max(0, results.findIndex(row => row.id === selectedId));
		loadPreview();
	}

	function compact(value: string): string {
		return value.toLowerCase().replace(/[^\p{L}\p{N}]/gu, "");
	}

	function filterRows(rows, filter): var {
		const needle = filter.trim().toLowerCase();
		if (!needle)
			return rows.slice(0, 100);
		const compactNeedle = compact(needle);
		return rows.filter(row => row.value.toLowerCase().includes(needle)
			|| (compactNeedle !== "" && compact(row.value).includes(compactNeedle))).slice(0, 100);
	}

	function open(): void {
		query = "";
		selectedIndex = 0;
		loadPreview();
		ShellState.resetPointerSelection();
		connectHistoryEvents();
		reload();
		resultList.cancelFlick();
		resultList.positionViewAtBeginning();
		Qt.callLater(() => {
			resultList.forceLayout();
			resultList.positionViewAtBeginning();
			queryInput.forceActiveFocus();
		});
	}

	function close(): void {
		ShellState.close();
	}

	function reload(): void {
		listReload.restart();
	}

	function connectHistoryEvents(): void {
		historyEvents.connected = false;
		historyEvents.connected = true;
	}

	function selectedRow(): var {
		return selectedIndex >= 0 && selectedIndex < results.length ? results[selectedIndex] : null;
	}

	function loadPreview(): void {
		if (!visible)
			return;
		const row = selectedRow();
		if (JSON.stringify(row) === JSON.stringify(previewLoader.row))
			return;
		previewLoader.active = false;
		previewLoader.row = row;
		previewLoader.active = row !== null;
	}

	function moveSelection(delta: int): void {
		if (results.length === 0)
			return;
		selectedIndex = ((selectedIndex + delta) % results.length + results.length) % results.length;
		resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
		loadPreview();
	}

	function copySelected(): void {
		const row = selectedRow();
		if (!row)
			return;
		Quickshell.execDetached(["rift", "use", row.id]);
		close();
	}

	function copyPathSelected(): void {
		const row = selectedRow();
		if (!row) return;
		if (row.kind === "file") {
			Quickshell.execDetached([
				"bash", "-c", "printf '%q' \"$1\" | wl-copy", "_", row.filePath
			]);
		} else if (row.kind === "image") {
			const path = `${imageDirectory}/${row.id}.${row.extension}`;
			Quickshell.execDetached([
				"bash", "-c",
				"\"$1\" \"$2\" \"$3\" \"$4\" && printf '%q' \"$4\" | wl-copy",
				"_", `${Quickshell.shellDir}/scripts/clipboard-image-cache`, row.id, row.previewMime, path
			]);
		} else {
			copySelected();
			return;
		}
		close();
	}

	function openSelected(): void {
		const row = selectedRow();
		if (!row) return;
		if (row.kind === "file") {
			Quickshell.execDetached(["xdg-open", row.filePath]);
		} else if (row.kind === "link") {
			Quickshell.execDetached(["xdg-open", row.url]);
		} else if (row.kind === "image") {
			const path = `${imageDirectory}/${row.id}.${row.extension}`;
			Quickshell.execDetached([
				"bash", "-c",
				"\"$1\" \"$2\" \"$3\" \"$4\" && xdg-open \"$4\"",
				"_", `${Quickshell.shellDir}/scripts/clipboard-image-cache`, row.id, row.previewMime, path
			]);
		} else {
			copySelected();
			return;
		}
		close();
	}

	function deleteSelected(): void {
		const row = selectedRow();
		if (!row)
			return;
		deleteProcess.exec(["rift", "delete", row.id]);
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

	onVisibleChanged: {
		if (visible)
			open();
		else {
			historyEvents.connected = false;
			listReload.stop();
			listProcess.running = false;
		}
	}
	onResultsChanged: {
		if (results.length === 0)
			selectedIndex = 0;
		else if (selectedIndex >= results.length)
			selectedIndex = results.length - 1;
		Qt.callLater(() => {
			resultList.forceLayout();
			if (root.selectedIndex === 0)
				resultList.positionViewAtBeginning();
			root.loadPreview();
		});
	}

	Socket {
		id: historyEvents
		path: root.riftSocketPath
		connected: false
		onError: {
			connected = false;
			subscriptionRetry.restart();
		}
		onConnectionStateChanged: {
			if (connected) {
				write('{"command":"subscribe"}\n');
				flush();
			} else {
				subscriptionRetry.restart();
			}
		}
		parser: SplitParser {
			splitMarker: "\n"
			onRead: data => {
				try {
					const message = JSON.parse(data);
					if (root.visible && (message.ok || message.event === "history_changed"))
						root.reload();
				} catch (error) {
					console.warn("failed to parse Rift event:", error);
				}
			}
		}
	}

	Timer {
		id: subscriptionRetry
		interval: 30000
		onTriggered: {
			if (root.visible)
				root.connectHistoryEvents();
		}
	}

	Timer {
		id: listReload
		interval: 50
		onTriggered: {
			if (root.visible)
				listProcess.exec(["rift", "list", "--json"]);
		}
	}

	Process {
		id: listProcess
		command: ["rift", "list", "--json"]
		onExited: (exitCode, exitStatus) => {
			if (exitCode !== 0)
				console.warn("rift list failed with exit code", exitCode);
		}
		stdout: StdioCollector {
			onStreamFinished: if (root.visible && text.trim()) root.parseHistory(text)
		}
		stderr: StdioCollector {
			onStreamFinished: {
				if (text.trim())
					console.warn("rift list error:", text.trim());
			}
		}
	}

	Loader {
		id: previewLoader
		property var row: null
		active: false
		sourceComponent: ClipboardPreview {
			row: previewLoader.row
			imageDirectory: root.imageCacheDirectory
			linkCache: root.linkPreviewCache
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

	PopupShadow { target: card }

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
				const shift = event.modifiers & Qt.ShiftModifier;
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
					if (ctrl)
						root.copyPathSelected();
					else if (shift)
						root.openSelected();
					else
						root.copySelected();
				} else if (event.key === Qt.Key_Delete && (ctrl || root.query === "")) {
					root.deleteSelected();
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

					SearchInput {
						id: queryInput
						Layout.fillWidth: true
						Layout.fillHeight: true
						Keys.forwardTo: [keyHandler]
						onTextChanged: {
							root.selectedIndex = 0;
							resultList.positionViewAtBeginning();
							root.loadPreview();
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
					highlightMoveDuration: 0
					boundsBehavior: Flickable.StopAtBounds

					delegate: Rectangle {
						id: row
						required property int index
						required property var modelData
						readonly property bool selected: index === root.selectedIndex
						readonly property bool link: modelData.kind === "link"
						readonly property string fallbackIcon: modelData.kind === "image" ? ""
							: modelData.kind === "file" ? modelData.fileIcon
							: link ? "" : ""
						readonly property url thumbnailSource: thumbnailLoader.item ? thumbnailLoader.item.image : ""

						Loader {
							id: thumbnailLoader
							readonly property var entry: row.modelData
							onEntryChanged: {
								active = false;
								active = true;
							}
							sourceComponent: ClipboardPreview {
								row: thumbnailLoader.entry
								imageDirectory: root.imageCacheDirectory
								linkCache: root.linkPreviewCache
								thumbnailOnly: true
							}
						}

						width: ListView.view.width
						height: 58
						clip: true
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
								color: row.link
									? "transparent"
									: row.selected ? Qt.rgba(0.5, 0.5, 0.5, 0.2) : Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.12)

								Image {
									id: thumbnailImage
									anchors.fill: parent
									anchors.margins: row.link ? 0 : 1
									visible: row.link && status === Image.Ready
									source: row.thumbnailSource
									sourceSize: Qt.size(96, 96)
									fillMode: row.link ? Image.PreserveAspectFit : Image.PreserveAspectCrop
									asynchronous: !row.link
									smooth: true
								}

								MultiEffect {
									anchors.fill: thumbnailImage
									visible: !row.link && thumbnailImage.status === Image.Ready
									source: thumbnailImage
									maskEnabled: true
									maskSource: thumbnailMask
								}

								Item {
									id: thumbnailMask
									anchors.fill: thumbnailImage
									visible: false
									layer.enabled: true

									Rectangle {
										anchors.fill: parent
										radius: 7
										color: "white"
									}
								}

								Text {
									anchors.centerIn: parent
									visible: thumbnailImage.status !== Image.Ready
									text: row.fallbackIcon
									color: row.selected ? Theme.selectedText : Theme.text
									font.family: "Iosevka Nerd Font"
									font.pixelSize: 19
								}

								Rectangle {
									anchors.fill: parent
									z: 2
									color: "transparent"
									radius: 8
									border.width: row.link && thumbnailImage.status === Image.Ready ? 0 : 1
									border.pixelAligned: true
									border.color: Theme.border
								}
							}

							ColumnLayout {
								Layout.fillWidth: true
								spacing: 2

								Text {
									Layout.fillWidth: true
									text: row.modelData.sensitive
										? "sensitive clipboard item"
										: row.modelData.kind === "image"
											? row.modelData.imageTitle
											: row.modelData.value.replace(/\s+/g, " ")
									color: row.selected ? Theme.selectedText : Theme.text
									font.family: Theme.fontFamily
									font.pixelSize: 15
									font.weight: Font.Medium
									elide: Text.ElideRight
								}

								Text {
									text: root.rowDetail(row.modelData)
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
								const pointerMoved = ShellState.pointerSelectionMoved(row.mapToItem(card, mouse.x, mouse.y));
								if (pointerMoved && root.selectedIndex !== row.index) {
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
						visible: root.previewImage === "" && root.linkPreview === null
						text: root.previewText
						textFormat: Text.PlainText
						color: Theme.text
						font.family: Theme.fontFamily
						font.pixelSize: 15
						wrapMode: Text.WrapAnywhere
						verticalAlignment: Text.AlignTop
					}

					ColumnLayout {
						anchors.fill: parent
						anchors.margins: 10
						visible: root.linkPreview !== null
						spacing: 14

						Item {
							Layout.fillWidth: true
							Layout.preferredHeight: root.linkPreview && root.linkPreview.image ? 250 : 0
							visible: root.linkPreview && root.linkPreview.image

							Image {
								id: linkPreviewImage
								anchors.fill: parent
								visible: false
								source: root.linkPreview ? root.linkPreview.image : ""
								fillMode: Image.PreserveAspectCrop
								asynchronous: false
								smooth: true
								sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
							}

							MultiEffect {
								anchors.fill: parent
								source: linkPreviewImage
								maskEnabled: true
								maskSource: linkPreviewMask
							}

							Item {
								id: linkPreviewMask
								anchors.fill: parent
								visible: false
								layer.enabled: true

								Rectangle {
									anchors.fill: parent
									radius: 10
									color: "white"
								}
							}
						}

						RowLayout {
							Layout.fillWidth: true
							spacing: 10

							Image {
								Layout.preferredWidth: 32
								Layout.preferredHeight: 32
								source: root.linkPreview ? root.linkPreview.favicon : ""
								sourceSize: Qt.size(96, 96)
								fillMode: Image.PreserveAspectFit
								asynchronous: false
								smooth: true
							}

							Text {
								Layout.fillWidth: true
								text: root.linkPreview ? root.linkPreview.title : ""
								textFormat: Text.PlainText
								color: Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 19
								font.weight: Font.DemiBold
								wrapMode: Text.Wrap
							}
						}

						Text {
							Layout.fillWidth: true
							visible: text !== ""
							text: root.linkPreview ? root.linkPreview.description : ""
							textFormat: Text.PlainText
							color: Theme.muted
							font.family: Theme.fontFamily
							font.pixelSize: 14
							wrapMode: Text.Wrap
						}

						Text {
							Layout.fillWidth: true
							text: root.linkPreview ? root.linkPreview.url : ""
							color: Theme.muted
							font.family: Theme.fontFamily
							font.pixelSize: 12
							wrapMode: Text.WrapAnywhere
						}

						Item { Layout.fillHeight: true }
					}

					Image {
						anchors.fill: parent
						anchors.margins: 10
						visible: root.previewImage !== ""
						source: root.previewImage
						fillMode: Image.PreserveAspectFit
						asynchronous: false
						smooth: true
						sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
					}
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Layout.leftMargin: 10
				Layout.preferredHeight: 20
				spacing: 18

				KeyHint { shortcut: "type"; description: "filter" }
				KeyHint { shortcut: "↵"; description: "copy" }
				KeyHint {
					visible: root.selectedRow() && ["file", "image"].includes(root.selectedRow().kind)
					shortcut: "ctrl ↵"
					description: "path"
				}
				KeyHint {
					visible: root.selectedRow() && ["file", "image", "link"].includes(root.selectedRow().kind)
					shortcut: "shift ↵"
					description: "open"
				}
				KeyHint { shortcut: "del"; description: "remove" }
				KeyHint { shortcut: "esc"; description: "close" }
				Item { Layout.fillWidth: true }
			}
		}
	}
}
