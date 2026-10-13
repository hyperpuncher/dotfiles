import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray

PanelWindow {
	id: root

	property SystemTrayItem trayItem: null
	property real anchorX: 38
	property real anchorY: 0

	function close(): void {
		trayItem = null;
	}

	visible: trayItem !== null
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore
	anchors { top: true; bottom: true; left: true; right: true }

	WlrLayershell.namespace: "quickshell-tray-menu"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	Connections {
		target: root.trayItem
		function onHasMenuChanged(): void {
			if (!root.trayItem.hasMenu)
				root.close();
		}
	}

	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.AllButtons
		onClicked: root.close()
	}

	PopupShadow { target: card }

	Rectangle {
		id: card
		x: Math.max(8, Math.min(root.anchorX + 6, root.width - width - 8))
		y: Math.max(8, Math.min(root.anchorY, root.height - height - 8))
		width: Math.min(Math.ceil(menuLoader.item ? menuLoader.item.naturalWidth : 0) + 16, root.width - 16)
		height: Math.min(menuLoader.implicitHeight + 16, root.height - 16)
		color: Theme.surface
		radius: Theme.radius
		border.width: 1
		border.color: Theme.border

		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.AllButtons
		}

		ScrollView {
			anchors.fill: parent
			anchors.margins: 8
			contentWidth: availableWidth
			clip: true
			ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

			Loader {
				id: menuLoader
				width: parent.width
				active: root.visible
				focus: true
				Keys.onEscapePressed: root.close()
				sourceComponent: TrayMenuLevel {
					handle: root.trayItem ? root.trayItem.menu : null
					dismiss: root.close
				}
				onLoaded: forceActiveFocus()
			}
		}
	}
}
