function rectFromPoints(first, second) {
	return {
		x: Math.min(first.x, second.x),
		y: Math.min(first.y, second.y),
		w: Math.abs(second.x - first.x),
		h: Math.abs(second.y - first.y)
	};
}

function bounds(annotation) {
	var xs = annotation.points.map(function(point) { return point.x; });
	var ys = annotation.points.map(function(point) { return point.y; });
	var left = Math.min.apply(null, xs);
	var top = Math.min.apply(null, ys);
	var right = Math.max.apply(null, xs);
	var bottom = Math.max.apply(null, ys);
	if (annotation.type === "text") {
		var size = annotation.size || 18;
		return {
			x: left,
			y: top,
			w: Math.max(size, (annotation.text || "").length * size * 0.62),
			h: size * 1.4
		};
	}
	return { x: left, y: top, w: right - left, h: bottom - top };
}

function distanceToSegment(px, py, first, second) {
	var dx = second.x - first.x;
	var dy = second.y - first.y;
	var lengthSquared = dx * dx + dy * dy;
	if (lengthSquared === 0)
		return Math.hypot(px - first.x, py - first.y);
	var position = ((px - first.x) * dx + (py - first.y) * dy) / lengthSquared;
	position = Math.max(0, Math.min(1, position));
	return Math.hypot(px - first.x - position * dx, py - first.y - position * dy);
}

function contains(annotation, x, y) {
	var tolerance = Math.max(annotation.width || 4, 8);
	if (annotation.type === "line" || annotation.type === "arrow")
		return distanceToSegment(x, y, annotation.points[0], annotation.points[1]) <= tolerance;
	if (annotation.type === "pen") {
		for (var i = 1; i < annotation.points.length; i++) {
			if (distanceToSegment(x, y, annotation.points[i - 1], annotation.points[i]) <= tolerance)
				return true;
		}
		return false;
	}
	var box = bounds(annotation);
	if (annotation.type === "ellipse") {
		var rx = box.w / 2 + tolerance;
		var ry = box.h / 2 + tolerance;
		if (rx <= 0 || ry <= 0)
			return false;
		var nx = (x - box.x - box.w / 2) / rx;
		var ny = (y - box.y - box.h / 2) / ry;
		return nx * nx + ny * ny <= 1;
	}
	var padding = annotation.type === "text" ? 2 : tolerance;
	return x >= box.x - padding && x <= box.x + box.w + padding
		&& y >= box.y - padding && y <= box.y + box.h + padding;
}

function hitTest(annotations, x, y) {
	for (var i = annotations.length - 1; i >= 0; i--) {
		if (contains(annotations[i], x, y))
			return i;
	}
	return -1;
}

if (typeof module !== "undefined" && module.exports) {
	module.exports = {
		rectFromPoints: rectFromPoints,
		bounds: bounds,
		distanceToSegment: distanceToSegment,
		contains: contains,
		hitTest: hitTest
	};
}
