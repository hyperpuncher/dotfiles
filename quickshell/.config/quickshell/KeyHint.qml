import QtQuick

Row {
	id: root

	required property string shortcut
	required property string description
	readonly property var keys: shortcut.split(/[ +]+/).filter(key => key.length > 0)

	height: 20
	spacing: 6

	Row {
		height: parent.height
		spacing: 3

		Repeater {
			model: root.keys

			delegate: Rectangle {
				id: key

				required property string modelData

				width: keyLabel.implicitWidth + 10
				height: 20
				radius: 4
				color: Theme.surfaceRaised
				border.width: 1
				border.color: Theme.border

				Text {
					id: keyLabel
					anchors.centerIn: parent
					text: key.modelData
					color: Theme.text
					font.family: Theme.fontFamily
					font.pixelSize: 10
					font.weight: Font.DemiBold
				}
			}
		}
	}

	Text {
		anchors.verticalCenter: parent.verticalCenter
		text: root.description
		color: Theme.muted
		font.family: Theme.fontFamily
		font.pixelSize: 10
	}
}
