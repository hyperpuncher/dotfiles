import QtQuick
import QtQuick.Effects
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
	property var linkPreview: null
	property var linkPreviewCache: ({})
	readonly property string imageDirectory: `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/clipboard-images`
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
		const changed = rows.length !== history.length
			|| rows.some((row, index) => row.id !== history[index].id || row.complete !== history[index].complete);
		selectedIndex = 0;
		if (changed)
			history = rows;
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
		const selectionChanged = selectedIndex !== 0;
		selectedIndex = 0;
		if (selectionChanged)
			loadPreview();
		ShellState.resetPointerSelection();
		ShellState.open("clipboard");
		connectHistoryEvents();
		reload();
		resultList.cancelFlick();
		resultList.positionViewAtBeginning();
		Qt.callLater(() => keyHandler.forceActiveFocus());
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
		const row = selectedRow();
		previewText = "";
		previewImage = "";
		linkPreview = null;
		linkPreviewProcess.running = false;
		if (!row)
			return;

		if (row.sensitive) {
			previewText = "sensitive clipboard item\n\npress enter to restore it for 10 minutes";
		} else if (row.kind === "file" && row.fileType === "image") {
			previewImage = encodeURI(`file://${row.filePath}`);
		} else if (row.kind === "image") {
			imageDecode.rowId = row.id;
			imageDecode.outputPath = `${imageDirectory}/${row.id}.${row.extension}`;
			imageDecode.command = [
				"bash", "-c", "mkdir -p -- \"$3\" && rift read \"$1\" --mime \"$2\" > \"$4\"",
				"_", row.id, row.previewMime, imageDirectory, imageDecode.outputPath
			];
			imageDecode.running = false;
			imageDecode.running = true;
		} else if (row.kind === "link") {
			const cached = linkPreviewCache[row.url];
			if (cached) {
				linkPreview = cached;
			} else {
				previewText = row.url;
				linkPreviewProcess.rowId = row.id;
				linkPreviewProcess.command = [`${Quickshell.shellDir}/scripts/link-preview`, row.url];
				linkPreviewProcess.running = true;
			}
		} else {
			textDecode.rowId = row.id;
			textDecode.command = ["rift", "read", row.id, "--mime", row.previewMime];
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
				"mkdir -p -- \"$3\" && rift read \"$1\" --mime \"$2\" > \"$4\" && printf '%q' \"$4\" | wl-copy",
				"_", row.id, row.previewMime, imageDirectory, path
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
				"mkdir -p -- \"$3\" && rift read \"$1\" --mime \"$2\" > \"$4\" && xdg-open \"$4\"",
				"_", row.id, row.previewMime, imageDirectory, path
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
		deleteProcess.command = ["rift", "delete", row.id];
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

	onVisibleChanged: {
		if (visible)
			open();
		else
			historyEvents.connected = false;
	}
	onResultsChanged: {
		if (results.length === 0)
			selectedIndex = 0;
		else if (selectedIndex >= results.length)
			selectedIndex = results.length - 1;
		loadPreview();
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
			listProcess.running = false;
			listProcess.running = true;
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
			onStreamFinished: root.parseHistory(text)
		}
		stderr: StdioCollector {
			onStreamFinished: {
				if (text.trim())
					console.warn("rift list error:", text.trim());
			}
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
		id: linkPreviewProcess
		property string rowId: ""
		stdout: StdioCollector {
			onStreamFinished: {
				const row = root.selectedRow();
				if (!text.trim() || !row || row.id !== linkPreviewProcess.rowId)
					return;
				try {
					const preview = JSON.parse(text);
					root.linkPreviewCache[row.url] = preview;
					root.linkPreview = preview;
				} catch (error) {
					console.warn("failed to parse link preview:", error);
				}
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
						property string thumbnailSource: ""
						readonly property string thumbnailInput: `${root.imageCacheDirectory}/${modelData.id}.${modelData.extension}`

						function loadThumbnail(): void {
							thumbnailSource = "";
							if (link) {
								linkMetadata.rowId = modelData.id;
								linkMetadata.command = [`${Quickshell.shellDir}/scripts/link-preview`, "--favicon", modelData.url];
								linkMetadata.running = false;
								linkMetadata.running = true;
								return;
							}
							if (modelData.kind === "file" && modelData.fileType === "image") {
								thumbnailSource = encodeURI(`file://${modelData.filePath}`);
								return;
							}
							if (modelData.kind !== "image")
								return;
							thumbnailDecode.command = [
								`${Quickshell.shellDir}/scripts/clipboard-image-cache`,
								modelData.id,
								modelData.previewMime,
								thumbnailInput
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
									row.thumbnailSource = `file://${row.thumbnailInput}`;
							}
						}

						Process {
							id: linkMetadata
							property string rowId: ""
							stdout: StdioCollector {
								onStreamFinished: {
									if (!text.trim() || row.modelData.id !== linkMetadata.rowId)
										return;
									row.thumbnailSource = text.trim();
								}
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
