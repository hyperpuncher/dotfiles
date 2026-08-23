var undoLimit = 100;

function cloneAnnotation(annotation) {
	var copy = {};
	for (var key in annotation)
		copy[key] = annotation[key];
	copy.points = annotation.points.map(function(point) {
		return { x: point.x, y: point.y };
	});
	return copy;
}

function cloneAnnotations(annotations) {
	return annotations.map(cloneAnnotation);
}

function create() {
	return {
		items: [],
		undoStack: [],
		redoStack: [],

		checkpoint: function() {
			this.undoStack.push(cloneAnnotations(this.items));
			if (this.undoStack.length > undoLimit)
				this.undoStack.shift();
			this.redoStack = [];
		},

		add: function(annotation) {
			this.checkpoint();
			this.items.push(annotation);
		},

		move: function(index, dx, dy) {
			if (index < 0 || index >= this.items.length)
				return false;
			this.checkpoint();
			for (var i = 0; i < this.items[index].points.length; i++) {
				this.items[index].points[i].x += dx;
				this.items[index].points[i].y += dy;
			}
			return true;
		},

		remove: function(index) {
			if (index < 0 || index >= this.items.length)
				return false;
			this.checkpoint();
			this.items.splice(index, 1);
			return true;
		},

		undo: function() {
			if (this.undoStack.length === 0)
				return false;
			this.redoStack.push(cloneAnnotations(this.items));
			var previous = this.undoStack.pop();
			this.items.splice.apply(this.items, [0, this.items.length].concat(previous));
			return true;
		},

		redo: function() {
			if (this.redoStack.length === 0)
				return false;
			this.undoStack.push(cloneAnnotations(this.items));
			var next = this.redoStack.pop();
			this.items.splice.apply(this.items, [0, this.items.length].concat(next));
			return true;
		}
	};
}

if (typeof module !== "undefined" && module.exports)
	module.exports = { create: create };
