import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
	id: root

	property int selectedIndex: 0
	readonly property var rows: NotificationService.history
	readonly property int visibleRows: Math.min(6, rows.length)

	function open(): void {
		selectedIndex = 0;
		ShellState.resetPointerSelection();
		ShellState.open("notifications");
		NotificationService.popupNotifications = [];
		Qt.callLater(() => keyHandler.forceActiveFocus());
	}

	function close(): void {
		ShellState.close();
	}

	function moveSelection(delta: int): void {
		if (rows.length === 0)
			return;
		selectedIndex = (selectedIndex + delta + rows.length) % rows.length;
		resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
	}

	function selectedNotification(): var {
		return selectedIndex >= 0 && selectedIndex < rows.length ? rows[selectedIndex] : null;
	}

	function dismissSelected(): void {
		const notification = selectedNotification();
		if (notification)
			NotificationService.dismiss(notification);
	}

	function activateSelected(): void {
		const notification = selectedNotification();
		if (!notification)
			return;
		if (notification.actions.length > 0)
			notification.actions[0].invoke();
		NotificationService.dismiss(notification);
	}

	visible: ShellState.activePanel === "notifications"
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-notification-center"
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
		width: Math.min(700, root.width - 64)
		height: 112 + Math.max(76, root.visibleRows * 76)
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
					root.activateSelected();
				} else if (event.key === Qt.Key_Delete && ctrl) {
					NotificationService.clear();
				} else if (event.key === Qt.Key_Delete) {
					root.dismissSelected();
				} else if (event.key === Qt.Key_D) {
					NotificationService.doNotDisturb = !NotificationService.doNotDisturb;
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

				Text {
					text: "notifications"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 14
					font.weight: Font.Medium
				}

				Item { Layout.fillWidth: true }

				Rectangle {
					Layout.preferredWidth: dndText.implicitWidth + 18
					Layout.preferredHeight: 28
					radius: 7
					color: NotificationService.doNotDisturb ? Theme.selected : "transparent"

					Text {
						id: dndText
						anchors.centerIn: parent
						text: NotificationService.doNotDisturb ? "do not disturb" : "notifications on"
						color: NotificationService.doNotDisturb ? Theme.selectedText : Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 11
						font.weight: Font.Medium
					}

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: NotificationService.doNotDisturb = !NotificationService.doNotDisturb
					}
				}
			}

			ListView {
				id: resultList
				Layout.fillWidth: true
				Layout.preferredHeight: Math.max(76, root.visibleRows * 76)
				clip: true
				model: root.rows
				currentIndex: root.selectedIndex
				boundsBehavior: Flickable.StopAtBounds

				delegate: Rectangle {
					id: row
					required property int index
					required property var modelData
					readonly property bool selected: index === root.selectedIndex
					width: ListView.view.width
					height: 76
					radius: 8
					color: selected ? Theme.selected : "transparent"

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 12
						anchors.rightMargin: 12
						spacing: 12

						Rectangle {
							Layout.preferredWidth: 40
							Layout.preferredHeight: 40
							radius: 8
							color: row.selected ? Qt.rgba(0.5, 0.5, 0.5, 0.2) : Theme.surfaceRaised
							clip: true

							IconImage {
								anchors.centerIn: parent
								width: 24
								height: 24
								source: row.modelData.appIcon
									? Quickshell.iconPath(row.modelData.appIcon, Quickshell.iconPath("dialog-information-symbolic", ""))
									: Quickshell.iconPath("dialog-information-symbolic", "")
								mipmap: false
							}

							Image {
								anchors.fill: parent
								visible: source !== "" && status !== Image.Error
								source: row.modelData.image
								fillMode: Image.PreserveAspectCrop
								sourceSize: Qt.size(80, 80)
								asynchronous: true
								smooth: true
								mipmap: false
							}
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 2

							Text {
								Layout.fillWidth: true
								text: row.modelData.summary || row.modelData.appName || "notification"
								color: row.selected ? Theme.selectedText : Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 15
								font.weight: Font.Medium
								elide: Text.ElideRight
							}

							Text {
								Layout.fillWidth: true
								text: row.modelData.body || row.modelData.appName
								textFormat: Text.PlainText
								color: row.selected ? Theme.selectedText : Theme.muted
								opacity: row.selected ? 0.65 : 1
								font.family: Theme.fontFamily
								font.pixelSize: 11
								maximumLineCount: 2
								wrapMode: Text.Wrap
								elide: Text.ElideRight
							}
						}

						Text {
							Layout.minimumWidth: 76
							Layout.maximumWidth: 76
							text: row.modelData.actions.length > 0 ? `↵ ${row.modelData.actions[0].text}` : "del dismiss"
							color: Theme.selectedText
							opacity: row.selected ? 0.55 : 0
							font.family: Theme.fontFamily
							font.pixelSize: 10
							elide: Text.ElideRight
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
					}
				}

				Text {
					anchors.centerIn: parent
					visible: root.rows.length === 0
					text: NotificationService.doNotDisturb ? "do not disturb is enabled" : "no notifications"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 14
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Layout.preferredHeight: 20
				Layout.leftMargin: 10
				spacing: 18

				KeyHint { shortcut: "↑↓"; description: "navigate" }
				KeyHint { shortcut: "↵"; description: "action" }
				KeyHint { shortcut: "del"; description: "dismiss" }
				KeyHint { shortcut: "ctrl+del"; description: "clear" }
				KeyHint { shortcut: "d"; description: "do not disturb" }
				Item { Layout.fillWidth: true }
			}
		}
	}
}
