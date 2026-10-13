import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Column {
	id: level
	property var handle: null
	property var dismiss
	readonly property real naturalWidth: children.reduce((maximum, child) => Math.max(maximum, child.naturalWidth || 0), 0)
	spacing: 2

	QsMenuOpener {
		id: opener
		menu: level.handle
	}

	Repeater {
		model: opener.children

		Column {
			id: entry
			required property var modelData
			property bool expanded: false
			readonly property real naturalWidth: Math.max(labelMetrics.lineWidth + 16
				+ (modelData.buttonType !== QsMenuButtonType.None ? 24 : 0)
				+ (modelData.icon !== "" ? 24 : 0)
				+ (modelData.hasChildren ? 24 : 0),
				submenu.item ? submenu.item.naturalWidth + submenu.x : 0)
			width: level.width
			spacing: 2

			function activate(): void {
				if (!modelData.enabled || modelData.isSeparator)
					return;
				if (modelData.hasChildren) {
					expanded = !expanded;
				} else {
					modelData.triggered();
					level.dismiss();
				}
			}

			FontMetrics {
				id: labelMetrics
				font: label.font
				readonly property real lineWidth: entry.modelData.isSeparator ? 0
					: label.text.split("\n").reduce((maximum, line) => Math.max(maximum, advanceWidth(line)), 0)
			}

			Rectangle {
				id: row
				readonly property bool highlighted: !entry.modelData.isSeparator && entry.modelData.enabled
					&& (mouse.containsMouse || activeFocus)
				width: parent.width
				height: entry.modelData.isSeparator ? 9 : Math.max(32, label.implicitHeight + 12)
				radius: 5
				color: highlighted ? Theme.selected : "transparent"
				activeFocusOnTab: entry.modelData.enabled && !entry.modelData.isSeparator
				Keys.onReturnPressed: entry.activate()
				Keys.onEnterPressed: entry.activate()
				Keys.onSpacePressed: entry.activate()

				Rectangle {
					visible: entry.modelData.isSeparator
					anchors.verticalCenter: parent.verticalCenter
					x: 6
					width: parent.width - 12
					height: 1
					color: Theme.border
				}

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 8
					anchors.rightMargin: 8
					spacing: 8
					visible: !entry.modelData.isSeparator
					opacity: entry.modelData.enabled ? 1 : 0.5

					Text {
						visible: entry.modelData.buttonType !== QsMenuButtonType.None
						Layout.preferredWidth: 16
						text: entry.modelData.buttonType === QsMenuButtonType.RadioButton
							? (entry.modelData.checkState === Qt.Checked ? "●" : "○")
							: (entry.modelData.checkState === Qt.Checked ? "☑" : entry.modelData.checkState === Qt.PartiallyChecked ? "⊟" : "☐")
						color: row.highlighted ? Theme.selectedText : Theme.text
						font: Qt.application.font
					}

					IconImage {
						visible: entry.modelData.icon !== ""
						Layout.preferredWidth: 16
						Layout.preferredHeight: 16
						source: entry.modelData.icon
					}

					Text {
						id: label
						Layout.fillWidth: true
						text: entry.modelData.text.replace(/&&|&/g, match => match === "&&" ? "&" : "")
						textFormat: Text.PlainText
						wrapMode: Text.Wrap
						color: row.highlighted ? Theme.selectedText : Theme.text
						font: Qt.application.font
					}

					Text {
						visible: entry.modelData.hasChildren
						text: entry.expanded ? "⌄" : "›"
						Layout.preferredWidth: 16
						color: row.highlighted ? Theme.selectedText : Theme.muted
						font: Qt.application.font
					}
				}

				MouseArea {
					id: mouse
					anchors.fill: parent
					enabled: entry.modelData.enabled && !entry.modelData.isSeparator
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: entry.activate()
				}
			}

			Loader {
				id: submenu
				x: 12
				width: parent.width - x
				active: entry.expanded && entry.modelData.hasChildren
				visible: active
				source: Qt.resolvedUrl("TrayMenuLevel.qml")
				onLoaded: {
					item.handle = Qt.binding(() => entry.modelData);
					item.dismiss = level.dismiss;
				}
			}
		}
	}
}
