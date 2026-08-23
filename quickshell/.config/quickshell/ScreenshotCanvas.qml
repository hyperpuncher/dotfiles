import QtQuick
import QtQuick.Shapes
import "screenshot/Geometry.js" as Geometry

Item {
	id: canvas

	required property real screenX
	required property real screenY
	property var annotations: []
	property var draft: null
	property int revision: 0
	property int selectedIndex: -1
	property point moveOffset: Qt.point(0, 0)

	function shifted(annotation, dx, dy): var {
		const copy = {};
		for (const key in annotation)
			copy[key] = annotation[key];
		copy.points = annotation.points.map(point => ({ x: point.x + dx, y: point.y + dy }));
		return copy;
	}

	function displayedItems(): var {
		canvas.revision;
		const result = [];
		for (let index = 0; index < canvas.annotations.length; index++) {
			if (index === canvas.selectedIndex && (canvas.moveOffset.x !== 0 || canvas.moveOffset.y !== 0))
				result.push(canvas.shifted(canvas.annotations[index], canvas.moveOffset.x, canvas.moveOffset.y));
			else
				result.push(canvas.annotations[index]);
		}
		if (canvas.draft)
			result.push(canvas.draft);
		return result;
	}

	function localPoint(annotation, index): point {
		return Qt.point(annotation.points[index].x - canvas.screenX,
			annotation.points[index].y - canvas.screenY);
	}

	function pathPoints(annotation): var {
		return annotation.points.map(point => Qt.point(
			point.x - canvas.screenX,
			point.y - canvas.screenY
		));
	}

	function arrowHead(annotation): var {
		const start = localPoint(annotation, 0);
		const end = localPoint(annotation, 1);
		const angle = Math.atan2(end.y - start.y, end.x - start.x);
		const length = Math.max(annotation.width * 4.5, 18);
		const spread = 0.48;
		return {
			tip: end,
			left: Qt.point(end.x - length * Math.cos(angle - spread),
				end.y - length * Math.sin(angle - spread)),
			right: Qt.point(end.x - length * Math.cos(angle + spread),
				end.y - length * Math.sin(angle + spread))
		};
	}

	Repeater {
		model: canvas.displayedItems()

		Item {
			id: annotationItem
			required property var modelData
			readonly property var annotation: modelData
			readonly property bool hasLine: annotation.points && annotation.points.length >= 2
			readonly property var box: hasLine ? Geometry.bounds(annotation) : null
			anchors.fill: parent

			Rectangle {
				visible: annotationItem.hasLine
					&& (annotationItem.annotation.type === "rect" || annotationItem.annotation.type === "redact")
				x: annotationItem.box ? annotationItem.box.x - canvas.screenX : 0
				y: annotationItem.box ? annotationItem.box.y - canvas.screenY : 0
				width: annotationItem.box ? annotationItem.box.w : 0
				height: annotationItem.box ? annotationItem.box.h : 0
				color: annotationItem.annotation.type === "redact" ? "#111111" : "transparent"
				border.color: annotationItem.annotation.type === "redact"
					? "#111111" : annotationItem.annotation.color
				border.width: annotationItem.annotation.type === "redact"
					? 0 : annotationItem.annotation.width || 0
				antialiasing: true
			}

			Shape {
				anchors.fill: parent
				visible: annotationItem.hasLine && annotationItem.annotation.type === "ellipse"
				preferredRendererType: Shape.CurveRenderer

				ShapePath {
					strokeColor: annotationItem.annotation.color || "transparent"
					strokeWidth: annotationItem.annotation.width || 0
					fillColor: "transparent"
					capStyle: ShapePath.RoundCap
					joinStyle: ShapePath.RoundJoin
					startX: annotationItem.box ? annotationItem.box.x - canvas.screenX : 0
					startY: annotationItem.box ? annotationItem.box.y + annotationItem.box.h / 2 - canvas.screenY : 0
					PathArc {
						x: annotationItem.box ? annotationItem.box.x + annotationItem.box.w - canvas.screenX : 0
						y: annotationItem.box ? annotationItem.box.y + annotationItem.box.h / 2 - canvas.screenY : 0
						radiusX: annotationItem.box ? annotationItem.box.w / 2 : 0
						radiusY: annotationItem.box ? annotationItem.box.h / 2 : 0
					}
					PathArc {
						x: annotationItem.box ? annotationItem.box.x - canvas.screenX : 0
						y: annotationItem.box ? annotationItem.box.y + annotationItem.box.h / 2 - canvas.screenY : 0
						radiusX: annotationItem.box ? annotationItem.box.w / 2 : 0
						radiusY: annotationItem.box ? annotationItem.box.h / 2 : 0
					}
				}
			}

			Shape {
				anchors.fill: parent
				visible: annotationItem.hasLine && ["line", "arrow", "pen"].includes(annotationItem.annotation.type)
				preferredRendererType: Shape.CurveRenderer

				ShapePath {
					strokeColor: annotationItem.annotation.color || "transparent"
					strokeWidth: annotationItem.annotation.width || 0
					fillColor: "transparent"
					capStyle: ShapePath.RoundCap
					joinStyle: ShapePath.RoundJoin
					startX: annotationItem.hasLine ? canvas.localPoint(annotationItem.annotation, 0).x : 0
					startY: annotationItem.hasLine ? canvas.localPoint(annotationItem.annotation, 0).y : 0
					PathPolyline {
						path: annotationItem.hasLine ? canvas.pathPoints(annotationItem.annotation) : []
					}
				}
			}

			Shape {
				id: arrowHead
				anchors.fill: parent
				visible: annotationItem.hasLine && annotationItem.annotation.type === "arrow"
				preferredRendererType: Shape.CurveRenderer
				readonly property var points: visible ? canvas.arrowHead(annotationItem.annotation) : null

				ShapePath {
					strokeColor: annotationItem.annotation.color || "transparent"
					strokeWidth: annotationItem.annotation.width || 0
					fillColor: annotationItem.annotation.color || "transparent"
					capStyle: ShapePath.RoundCap
					joinStyle: ShapePath.RoundJoin
					startX: arrowHead.points ? arrowHead.points.tip.x : 0
					startY: arrowHead.points ? arrowHead.points.tip.y : 0
					PathLine {
						x: arrowHead.points ? arrowHead.points.left.x : 0
						y: arrowHead.points ? arrowHead.points.left.y : 0
					}
					PathLine {
						x: arrowHead.points ? arrowHead.points.right.x : 0
						y: arrowHead.points ? arrowHead.points.right.y : 0
					}
					PathLine {
						x: arrowHead.points ? arrowHead.points.tip.x : 0
						y: arrowHead.points ? arrowHead.points.tip.y : 0
					}
				}
			}

			Text {
				visible: annotationItem.annotation.type === "text"
				x: visible ? annotationItem.annotation.points[0].x - canvas.screenX : 0
				y: visible ? annotationItem.annotation.points[0].y - canvas.screenY : 0
				text: visible ? annotationItem.annotation.text : ""
				color: visible ? annotationItem.annotation.color : "transparent"
				font.family: Theme.fontFamily
				font.pixelSize: visible ? annotationItem.annotation.size : 18
				textFormat: Text.PlainText
			}
		}
	}
}
