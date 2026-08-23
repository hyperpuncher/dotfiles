import QtQuick
import QtQuick.Layouts

Rectangle {
	id: toolbar

	property string activeTool: "arrow"
	property color activeColor: Theme.error
	property bool canUndo: false
	property bool canRedo: false
	property var tools: []

	signal toolSelected(string tool)
	signal colorSelected(color value)
	signal undoRequested()
	signal redoRequested()
	signal copyRequested()
	signal saveRequested()

	implicitWidth: row.implicitWidth + 12
	implicitHeight: 42
	radius: Theme.radius
	color: Theme.surface
	border.color: Theme.borderStrong
	border.width: 1

	RowLayout {
		id: row
		anchors.centerIn: parent
		spacing: 2

		Repeater {
			model: toolbar.tools
			ToolButton {
				required property var modelData
				icon: modelData.icon
				tip: `${modelData.name} (${modelData.key})`
				active: toolbar.activeTool === modelData.id
				onClicked: toolbar.toolSelected(modelData.id)
			}
		}

		Separator {}

		Repeater {
			model: [Theme.error.toString(), "#f2f2f0", "#e4b95f", "#72b38e", "#6f9fd8"]
			Item {
				required property var modelData
				readonly property bool active: Qt.colorEqual(toolbar.activeColor, modelData)
				Layout.preferredWidth: 26
				Layout.preferredHeight: 32

				Rectangle {
					anchors.centerIn: parent
					width: 14
					height: width
					radius: width / 2
					color: modelData
					border.color: parent.active ? Theme.selected : Theme.border
					border.width: 1
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: toolbar.colorSelected(modelData)
				}
			}
		}

		Separator {}

		ToolButton {
			icon: "undo-2"
			tip: "undo (Ctrl+Z)"
			enabled: toolbar.canUndo
			onClicked: toolbar.undoRequested()
		}
		ToolButton {
			icon: "redo-2"
			tip: "redo (Ctrl+Shift+Z)"
			enabled: toolbar.canRedo
			onClicked: toolbar.redoRequested()
		}

		Separator {}

		ToolButton {
			icon: "copy"
			tip: "copy (Ctrl+C)"
			onClicked: toolbar.copyRequested()
		}
		ToolButton {
			icon: "save"
			tip: "save (Ctrl+S)"
			onClicked: toolbar.saveRequested()
		}
	}

	component Separator: Rectangle {
		Layout.preferredWidth: 1
		Layout.preferredHeight: 20
		Layout.leftMargin: 3
		Layout.rightMargin: 3
		color: Theme.border
	}

	component ToolButton: Item {
		id: button
		property string icon: ""
		property string tip: ""
		property bool active: false
		signal clicked()

		Layout.preferredWidth: 30
		Layout.preferredHeight: 32
		opacity: enabled ? 1 : 0.35

		Rectangle {
			anchors.fill: parent
			radius: 6
			color: button.active ? Theme.selected : hover.hovered ? Theme.surfaceRaised : "transparent"
		}

		ScreenshotIcon {
			anchors.centerIn: parent
			name: button.icon
			size: 16
			tint: button.active ? Theme.selectedText : Theme.text
		}

		HoverHandler {
			id: hover
			cursorShape: Qt.PointingHandCursor
		}
		TapHandler {
			enabled: button.enabled
			onTapped: button.clicked()
		}

		Rectangle {
			visible: hover.hovered && button.tip !== ""
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.top: parent.bottom
			anchors.topMargin: 8
			z: 20
			width: tipText.implicitWidth + 14
			height: tipText.implicitHeight + 8
			radius: 5
			color: Theme.notificationSurface
			border.color: Theme.border

			Text {
				id: tipText
				anchors.centerIn: parent
				text: button.tip
				color: Theme.text
				font.family: Theme.fontFamily
				font.pixelSize: 10
			}
		}
	}
}
