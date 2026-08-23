import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
	id: root

	anchors {
		top: true
		right: true
	}
	margins {
		top: 12
		right: 12
	}

	implicitWidth: Math.max(220, Math.min(280, toastColumn.implicitWidth))
	implicitHeight: Math.max(1, toastColumn.implicitHeight)
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	WlrLayershell.namespace: "quickshell-notifications"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

	Column {
		id: toastColumn
		width: parent.width
		spacing: 4

		Repeater {
			model: NotificationService.popupNotifications

			Rectangle {
				id: toast
				required property var modelData
				readonly property int timeout: NotificationService.timeoutFor(modelData)
				implicitWidth: 58 + Math.max(summaryText.implicitWidth, bodyText.visible ? bodyText.implicitWidth : 0)
				width: toastColumn.width
				height: 62
				color: Theme.notificationSurface
				radius: 9
				border.width: 3
				border.color: Theme.notificationBorder
				clip: true

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 12
					anchors.rightMargin: 12
					spacing: 10

					Rectangle {
						Layout.preferredWidth: 34
						Layout.preferredHeight: 34
						radius: 7
						color: Theme.surfaceRaised
						clip: true

						IconImage {
							anchors.centerIn: parent
							width: 22
							height: 22
							source: toast.modelData.appIcon
								? Quickshell.iconPath(toast.modelData.appIcon, Quickshell.iconPath("dialog-information-symbolic", ""))
								: Quickshell.iconPath("dialog-information-symbolic", "")
							mipmap: false
						}

						Image {
							anchors.fill: parent
							visible: source !== "" && status !== Image.Error
							source: toast.modelData.image
							fillMode: Image.PreserveAspectCrop
							sourceSize: Qt.size(68, 68)
							asynchronous: true
							smooth: true
							mipmap: false
						}
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: 2

						Text {
							id: summaryText
							Layout.fillWidth: true
							text: toast.modelData.summary || "notification"
							color: Theme.text
							font.family: Theme.fontFamily
							font.pixelSize: 14
							font.styleName: "Medium"
							elide: Text.ElideRight
						}

						Text {
							id: bodyText
							Layout.fillWidth: true
							visible: text !== ""
							text: toast.modelData.body
							textFormat: Text.PlainText
							color: Theme.muted
							font.family: Theme.fontFamily
							font.pixelSize: 12
							maximumLineCount: 1
							elide: Text.ElideRight
						}
					}
				}

				MouseArea {
					id: pointer
					property bool dragged: false
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					drag.target: toast
					drag.axis: Drag.XAxis
					drag.minimumX: -toast.width
					drag.maximumX: toast.width
					onPressed: dragged = false
					onPositionChanged: if (drag.active) dragged = true
					onClicked: {
						if (!dragged)
							NotificationService.activate(toast.modelData);
					}
					onReleased: {
						if (dragged && Math.abs(toast.x) >= 80)
							NotificationService.dismiss(toast.modelData);
						else
							toast.x = 0;
					}
					onCanceled: toast.x = 0
				}

				Timer {
					interval: toast.timeout
					running: toast.timeout > 0
					onTriggered: NotificationService.hidePopup(toast.modelData)
				}

				Connections {
					target: toast.modelData
					function onClosed(): void {
						NotificationService.hidePopup(toast.modelData);
					}
				}
			}
		}
	}
}
