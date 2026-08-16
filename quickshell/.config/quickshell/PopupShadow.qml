import QtQuick
import QtQuick.Effects

RectangularShadow {
	required property Item target

	x: target.x
	y: target.y
	width: target.width
	height: target.height
	radius: target.radius
	blur: 10
	spread: 0
	offset: Qt.vector2d(0, 4)
	color: "#30000000"
	cached: false
}
