import QtQuick

TextInput {
	clip: true
	selectByMouse: true
	verticalAlignment: TextInput.AlignVCenter
	color: Theme.text
	selectionColor: Theme.selected
	selectedTextColor: Theme.selectedText
	font.family: Theme.fontFamily
	font.pixelSize: 17
	renderType: TextInput.CurveRendering
}
