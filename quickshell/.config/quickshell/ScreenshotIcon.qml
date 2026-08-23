import QtQuick
import QtQuick.Effects

Item {
	id: icon

	required property string name
	property color tint: Theme.text
	property real size: 18

	implicitWidth: size
	implicitHeight: size

	Image {
		id: sourceIcon
		anchors.centerIn: parent
		width: icon.size
		height: icon.size
		source: Qt.resolvedUrl(`icons/lucide/${icon.name}.svg`)
		sourceSize.width: icon.size * Screen.devicePixelRatio
		sourceSize.height: icon.size * Screen.devicePixelRatio
		mipmap: false
		smooth: true
	}

	ShaderEffectSource {
		id: texture
		anchors.fill: sourceIcon
		sourceItem: sourceIcon
		hideSource: true
		live: false
	}

	MultiEffect {
		anchors.fill: sourceIcon
		source: texture
		colorization: 1
		colorizationColor: icon.tint
	}
}
