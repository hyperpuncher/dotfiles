import QtQuick

Row {
	required property string shortcut
	required property string description
	spacing: 4

	Text {
		text: parent.shortcut
		color: Theme.text
		opacity: 0.72
		font.family: Theme.fontFamily
		font.pixelSize: 10
	}

	Text {
		text: parent.description
		color: Theme.muted
		font.family: Theme.fontFamily
		font.pixelSize: 10
	}
}
