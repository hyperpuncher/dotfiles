import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
	id: root

	property int selectedIndex: 0
	readonly property var actions: [
		{ name: "shutdown", detail: "power off the system", icon: "", command: ["bash", "-c", "rift clear; systemctl poweroff"] },
		{ name: "reboot", detail: "restart the system", icon: "", command: ["systemctl", "reboot"] },
		{ name: "hibernate", detail: "save session to disk", icon: "", command: ["systemctl", "hibernate"] },
		{ name: "logout", detail: "end the current session", icon: "󰗽", command: [`${Quickshell.shellDir}/scripts/logout`] }
	]

	function open(): void {
		selectedIndex = 0;
		ShellState.resetPointerSelection();
		Qt.callLater(() => keyHandler.forceActiveFocus());
	}

	function close(): void {
		ShellState.close();
	}

	function moveSelection(delta: int): void {
		selectedIndex = (selectedIndex + delta + actions.length) % actions.length;
	}

	function executeSelected(): void {
		if (selectedIndex < 0 || selectedIndex >= actions.length)
			return;
		const command = actions[selectedIndex].command;
		close();
		Quickshell.execDetached(command);
	}

	visible: ShellState.activePanel === "power"
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-power"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None


	MouseArea {
		anchors.fill: parent
		onClicked: root.close()
	}

	PopupShadow { target: card }

	Rectangle {
		id: card
		width: Math.min(440, root.width - 64)
		height: 292
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
				} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					root.executeSelected();
				} else {
					return;
				}
				event.accepted = true;
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 15
			spacing: 8

			Text {
				Layout.leftMargin: 10
				Layout.preferredHeight: 24
				text: "power"
				color: Theme.muted
				font.family: Theme.fontFamily
				font.pixelSize: 14
				font.weight: Font.Medium
			}

			Repeater {
				model: root.actions

				Rectangle {
					id: row
					required property int index
					required property var modelData
					readonly property bool selected: index === root.selectedIndex
					Layout.fillWidth: true
					Layout.preferredHeight: 52
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
							text: row.modelData.icon
							color: row.selected ? Theme.selectedText : Theme.text
							font.family: "Iosevka Nerd Font"
							font.pixelSize: 20
							horizontalAlignment: Text.AlignHCenter
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 0

							Text {
								Layout.fillWidth: true
								text: row.modelData.name
								color: row.selected ? Theme.selectedText : Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 16
								font.weight: Font.Medium
							}

							Text {
								Layout.fillWidth: true
								text: row.modelData.detail
								color: row.selected ? Theme.selectedText : Theme.muted
								opacity: row.selected ? 0.65 : 1
								font.family: Theme.fontFamily
								font.pixelSize: 11
							}
						}

						Text {
							Layout.minimumWidth: 72
							Layout.maximumWidth: 72
							text: "↵ execute"
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
						onClicked: {
							root.selectedIndex = row.index;
							root.executeSelected();
						}
					}
				}
			}
		}
	}
}
