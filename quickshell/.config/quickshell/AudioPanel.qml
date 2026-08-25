import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland

PanelWindow {
	id: root

	property int selectedIndex: 0
	property int activeTab: 0
	readonly property var tabs: [
		{ key: "playback", label: "playback" },
		{ key: "recording", label: "recording" },
		{ key: "output", label: "outputs" },
		{ key: "input", label: "inputs" }
	]
	readonly property var nodes: Pipewire.nodes.values.filter(node => node.audio
		&& (node.type & PwNodeType.Audio))
	readonly property var rows: buildRows(nodes, tabs[activeTab].key)
	readonly property int visibleRows: Math.min(7, rows.length)
	readonly property int listHeight: Math.max(62, visibleRows * 62)

	function buildRows(nodes, kind): var {
		const wantsStream = kind === "playback" || kind === "recording";
		const wantsSink = kind === "playback" || kind === "output";
		const result = nodes.filter(node => Boolean(node.type & PwNodeType.Stream) === wantsStream
			&& Boolean(node.type & (wantsSink ? PwNodeType.Sink : PwNodeType.Source)))
			.map(node => ({ node, kind }));
		result.sort((a, b) => Number(isDefault(b)) - Number(isDefault(a))
			|| nodeName(a.node).localeCompare(nodeName(b.node)));
		return result;
	}

	function isDefault(row): bool {
		if (row.kind === "output")
			return row.node === Pipewire.defaultAudioSink;
		if (row.kind === "input")
			return row.node === Pipewire.defaultAudioSource;
		return false;
	}

	function nodeName(node): string {
		return node.description || node.nickname || node.name || "audio device";
	}

	function open(): void {
		selectedIndex = 0;
		activeTab = 0;
		ShellState.resetPointerSelection();
		ShellState.open("audio");
		Qt.callLater(() => keyHandler.forceActiveFocus());
	}

	function close(): void {
		ShellState.close();
	}

	function selectedRow(): var {
		return selectedIndex >= 0 && selectedIndex < rows.length ? rows[selectedIndex] : null;
	}

	function moveSelection(delta: int): void {
		if (rows.length === 0)
			return;
		selectedIndex = (selectedIndex + delta + rows.length) % rows.length;
		resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
	}

	function moveTab(delta: int): void {
		activeTab = (activeTab + delta + tabs.length) % tabs.length;
		selectedIndex = 0;
		ShellState.resetPointerSelection();
	}

	function changeVolume(delta: real): void {
		const row = selectedRow();
		if (!row || !row.node.audio)
			return;
		row.node.audio.volume = Math.max(0, Math.min(1.5, row.node.audio.volume + delta));
	}

	function toggleMute(): void {
		const row = selectedRow();
		if (row && row.node.audio)
			row.node.audio.muted = !row.node.audio.muted;
	}

	function makeDefault(): void {
		const row = selectedRow();
		if (!row)
			return;
		if (row.kind === "output")
			Pipewire.preferredDefaultAudioSink = row.node;
		else if (row.kind === "input")
			Pipewire.preferredDefaultAudioSource = row.node;
	}

	PwObjectTracker {
		objects: root.nodes
	}

	visible: ShellState.activePanel === "audio"
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-audio"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	onVisibleChanged: if (visible) open()
	onRowsChanged: {
		if (rows.length === 0)
			selectedIndex = 0;
		else if (selectedIndex >= rows.length)
			selectedIndex = rows.length - 1;
	}

	MouseArea {
		anchors.fill: parent
		onClicked: root.close()
	}

	PopupShadow { target: card }

	Rectangle {
		id: card
		width: Math.min(620, root.width - 64)
		height: 110 + root.listHeight
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
				if (event.key === Qt.Key_Tab) {
					root.moveTab(event.modifiers & Qt.ShiftModifier ? -1 : 1);
				} else if (event.key === Qt.Key_Escape) {
					root.close();
				} else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K)) {
					root.moveSelection(-1);
				} else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J)) {
					root.moveSelection(1);
				} else if (event.key === Qt.Key_Left || event.key === Qt.Key_Minus) {
					root.changeVolume(-0.05);
				} else if (event.key === Qt.Key_Right || event.key === Qt.Key_Plus || event.key === Qt.Key_Equal) {
					root.changeVolume(0.05);
				} else if (event.key === Qt.Key_M) {
					root.toggleMute();
				} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					root.makeDefault();
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

			RowLayout {
				Layout.fillWidth: true
				Layout.preferredHeight: 34
				Layout.leftMargin: 10
				Layout.rightMargin: 10
				spacing: 6

				Text {
					Layout.rightMargin: 8
					text: "audio"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 14
					font.weight: Font.Medium
				}

				Repeater {
					model: root.tabs

					Rectangle {
						required property int index
						required property var modelData
						Layout.preferredWidth: tabLabel.implicitWidth + 18
						Layout.preferredHeight: 28
						radius: 7
						color: index === root.activeTab ? Theme.selected : "transparent"

						Text {
							id: tabLabel
							anchors.centerIn: parent
							text: parent.modelData.label
							color: parent.index === root.activeTab ? Theme.selectedText : Theme.muted
							font.family: Theme.fontFamily
							font.pixelSize: 11
							font.weight: Font.Medium
						}

						MouseArea {
							anchors.fill: parent
							cursorShape: Qt.PointingHandCursor
							onClicked: {
								root.activeTab = parent.index;
								root.selectedIndex = 0;
								ShellState.resetPointerSelection();
							}
						}
					}
				}

				Item { Layout.fillWidth: true }
			}

			ListView {
				id: resultList
				Layout.fillWidth: true
				Layout.preferredHeight: root.listHeight
				clip: true
				model: root.rows
				currentIndex: root.selectedIndex
				boundsBehavior: Flickable.StopAtBounds

				delegate: Rectangle {
					id: row
					required property int index
					required property var modelData
					readonly property bool selected: index === root.selectedIndex
					readonly property bool defaultNode: root.isDefault(modelData)
					readonly property var audio: modelData.node.audio
					width: ListView.view.width
					height: 62
					radius: 8
					color: selected ? Theme.selected : "transparent"

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 14
						anchors.rightMargin: 14
						spacing: 14

						Text {
							Layout.minimumWidth: 28
							Layout.maximumWidth: 28
							text: row.modelData.kind === "output" || row.modelData.kind === "playback" ? row.audio && row.audio.muted ? "󰖁" : "󰕾" : row.audio && row.audio.muted ? "󰍭" : "󰍬"
							color: row.selected ? Theme.selectedText : Theme.text
							font.family: "Iosevka Nerd Font"
							font.pixelSize: 20
							horizontalAlignment: Text.AlignHCenter
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 1

							Text {
								Layout.fillWidth: true
								text: root.nodeName(row.modelData.node)
								color: row.selected ? Theme.selectedText : Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 16
								font.weight: Font.Medium
								elide: Text.ElideRight
							}

							Text {
								Layout.fillWidth: true
								text: `${row.modelData.kind}${row.defaultNode ? "  default" : ""}${row.audio && row.audio.muted ? "  muted" : ""}`
								color: row.selected ? Theme.selectedText : Theme.muted
								opacity: row.selected ? 0.65 : 1
								font.family: Theme.fontFamily
								font.pixelSize: 11
							}
						}

						Text {
							Layout.minimumWidth: 52
							Layout.maximumWidth: 52
							text: row.audio ? `${Math.round(row.audio.volume * 100)}%` : ""
							color: row.selected ? Theme.selectedText : Theme.text
							font.family: Theme.fontFamily
							font.pixelSize: 14
							font.weight: Font.Medium
							horizontalAlignment: Text.AlignRight
						}

						Text {
							Layout.minimumWidth: 62
							Layout.maximumWidth: 62
							text: row.modelData.kind === "output" || row.modelData.kind === "input" ? "↵ default" : ""
							color: Theme.selectedText
							opacity: row.selected ? 0.55 : 0
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
						onClicked: root.selectedIndex = row.index
						onWheel: wheel => {
							root.selectedIndex = row.index;
							root.changeVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05);
						}
					}
				}

				Text {
					anchors.centerIn: parent
					visible: root.rows.length === 0
					text: Pipewire.ready ? "no audio devices" : "connecting to PipeWire"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 14
				}
			}

			RowLayout {
				id: footer
				Layout.fillWidth: true
				Layout.preferredHeight: 20
				Layout.leftMargin: 10
				spacing: 18

				KeyHint { shortcut: "tab"; description: "section" }
				KeyHint { shortcut: "↑↓"; description: "item" }
				KeyHint { shortcut: "←→"; description: "volume" }
				KeyHint { shortcut: "m"; description: "mute" }
				KeyHint { visible: root.tabs[root.activeTab].key === "output" || root.tabs[root.activeTab].key === "input"; shortcut: "↵"; description: "default" }
				Item { Layout.fillWidth: true }
			}
		}
	}
}
