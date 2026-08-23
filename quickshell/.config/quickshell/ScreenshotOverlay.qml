import QtQuick
import Quickshell.Wayland
import "screenshot/Geometry.js" as Geometry

Item {
	id: overlay

	required property var screenData
	property var selection: null
	property string phase: "selecting"
	property var annotations: []
	property var draft: null
	property int annotationRevision: 0
	property int selectedIndex: -1
	property point moveOffset: Qt.point(0, 0)
	property bool textEditing: false

	readonly property real screenX: screenData.x
	readonly property real screenY: screenData.y
	readonly property real pixelScaleX: frozen.hasContent && width > 0
		? frozen.sourceSize.width / width : screenData.devicePixelRatio
	readonly property real pixelScaleY: frozen.hasContent && height > 0
		? frozen.sourceSize.height / height : screenData.devicePixelRatio
	readonly property color dimColor: "#4d000000"
	readonly property var localSelection: {
		if (!selection)
			return null;
		const left = Math.max(selection.x, screenX);
		const top = Math.max(selection.y, screenY);
		const right = Math.min(selection.x + selection.w, screenX + width);
		const bottom = Math.min(selection.y + selection.h, screenY + height);
		if (right <= left || bottom <= top)
			return null;
		return { x: left - screenX, y: top - screenY, w: right - left, h: bottom - top };
	}
	readonly property var selectedBounds: {
		annotationRevision;
		if (selectedIndex < 0 || selectedIndex >= annotations.length)
			return null;
		const box = Geometry.bounds(annotations[selectedIndex]);
		return {
			x: box.x - screenX + moveOffset.x - 5,
			y: box.y - screenY + moveOffset.y - 5,
			w: box.w + 10,
			h: box.h + 10
		};
	}

	signal pressedAt(real x, real y)
	signal movedTo(real x, real y)
	signal released()
	signal wheelChanged(int direction)
	signal resizeStarted(string edge)
	signal resizeMoved(real x, real y)
	signal resizeFinished()
	signal textChanged(string value)
	signal textAccepted()
	signal captureFailed()

	Item {
		id: scene
		anchors.fill: parent
		opacity: frozen.hasContent ? 1 : 0

		ScreencopyView {
			id: frozen
			anchors.fill: parent
			captureSource: overlay.screenData
			live: false
			paintCursor: false
		}

		ScreenshotCanvas {
			anchors.fill: parent
			screenX: overlay.screenX
			screenY: overlay.screenY
			annotations: overlay.annotations
			draft: overlay.draft
			revision: overlay.annotationRevision
			selectedIndex: overlay.selectedIndex
			moveOffset: overlay.moveOffset
		}
	}

	Timer {
		interval: 50
		repeat: true
		running: !frozen.hasContent
		property int attempts: 0
		onTriggered: {
			attempts++;
			if (frozen.hasContent)
				stop();
			else if (attempts >= 60) {
				stop();
				overlay.captureFailed();
			} else
				frozen.captureFrame();
		}
	}

	Rectangle {
		anchors.fill: parent
		visible: frozen.hasContent && overlay.localSelection === null
		color: overlay.dimColor
	}

	Item {
		anchors.fill: parent
		visible: frozen.hasContent && overlay.localSelection !== null

		Rectangle {
			x: 0
			y: 0
			width: parent.width
			height: overlay.localSelection ? overlay.localSelection.y : 0
			color: overlay.dimColor
		}
		Rectangle {
			x: 0
			y: overlay.localSelection ? overlay.localSelection.y + overlay.localSelection.h : 0
			width: parent.width
			height: overlay.localSelection
				? parent.height - overlay.localSelection.y - overlay.localSelection.h : 0
			color: overlay.dimColor
		}
		Rectangle {
			x: 0
			y: overlay.localSelection ? overlay.localSelection.y : 0
			width: overlay.localSelection ? overlay.localSelection.x : 0
			height: overlay.localSelection ? overlay.localSelection.h : 0
			color: overlay.dimColor
		}
		Rectangle {
			x: overlay.localSelection ? overlay.localSelection.x + overlay.localSelection.w : 0
			y: overlay.localSelection ? overlay.localSelection.y : 0
			width: overlay.localSelection
				? parent.width - overlay.localSelection.x - overlay.localSelection.w : 0
			height: overlay.localSelection ? overlay.localSelection.h : 0
			color: overlay.dimColor
		}
	}

	Item {
		id: selectionChrome
		visible: frozen.hasContent && overlay.localSelection !== null
		x: overlay.localSelection ? overlay.localSelection.x : 0
		y: overlay.localSelection ? overlay.localSelection.y : 0
		width: overlay.localSelection ? overlay.localSelection.w : 0
		height: overlay.localSelection ? overlay.localSelection.h : 0

		Rectangle {
			anchors.fill: parent
			color: "transparent"
			border.color: Theme.text
			border.width: 2
		}

		Rectangle {
			x: Math.max(6 - selectionChrome.x,
				Math.min(-1, overlay.width - selectionChrome.x - width - 6))
			y: selectionChrome.y >= height + 7 ? -height - 7 : 6
			width: label.implicitWidth + 12
			height: label.implicitHeight + 6
			radius: 4
			color: Theme.notificationSurface
			border.color: Theme.border

			Text {
				id: label
				anchors.centerIn: parent
				text: overlay.localSelection
					? `${Math.round(overlay.localSelection.w * overlay.pixelScaleX)} × ${Math.round(overlay.localSelection.h * overlay.pixelScaleY)}`
					: ""
				color: Theme.text
				font.family: Theme.fontFamily
				font.pixelSize: 11
			}
		}
	}

	Item {
		visible: overlay.selectedBounds !== null
		x: overlay.selectedBounds ? overlay.selectedBounds.x : 0
		y: overlay.selectedBounds ? overlay.selectedBounds.y : 0
		width: overlay.selectedBounds ? overlay.selectedBounds.w : 0
		height: overlay.selectedBounds ? overlay.selectedBounds.h : 0

		Rectangle {
			anchors.fill: parent
			color: "transparent"
			border.color: Theme.text
			border.width: 1
		}
	}

	Item {
		id: exportClip
		visible: false
		clip: true
		width: overlay.localSelection ? overlay.localSelection.w : 0
		height: overlay.localSelection ? overlay.localSelection.h : 0

		ShaderEffectSource {
			id: exportSource
			sourceItem: scene
			width: scene.width
			height: scene.height
			x: overlay.localSelection ? -overlay.localSelection.x : 0
			y: overlay.localSelection ? -overlay.localSelection.y : 0
			live: false
			recursive: false
		}
	}

	function exportSelection(path: string, callback: var): void {
		if (!overlay.localSelection) {
			callback(false);
			return;
		}
		exportSource.scheduleUpdate();
		const started = exportClip.grabToImage(result => {
			let saved = false;
			try {
				saved = result ? result.saveToFile(path) : false;
			} catch (error) {
				console.warn("could not export screenshot", error);
			}
			callback(saved);
		});
		if (!started)
			callback(false);
	}

	MouseArea {
		anchors.fill: parent
		enabled: frozen.hasContent
		acceptedButtons: Qt.LeftButton
		cursorShape: overlay.phase === "selecting" ? Qt.CrossCursor
			: overlay.textEditing ? Qt.IBeamCursor
			: Qt.CrossCursor
		onPressed: mouse => overlay.pressedAt(mouse.x + overlay.screenX, mouse.y + overlay.screenY)
		onPositionChanged: mouse => {
			if (pressed)
				overlay.movedTo(mouse.x + overlay.screenX, mouse.y + overlay.screenY);
		}
		onReleased: overlay.released()
		onWheel: wheel => {
			if (wheel.angleDelta.y !== 0)
				overlay.wheelChanged(wheel.angleDelta.y > 0 ? 1 : -1);
			wheel.accepted = true;
		}
	}

	Item {
		anchors.fill: parent
		visible: frozen.hasContent && overlay.phase === "editing" && overlay.localSelection !== null

		Repeater {
			model: [
				{ edge: "tl", x: 0, y: 0, cursor: Qt.SizeFDiagCursor },
				{ edge: "t", x: 0.5, y: 0, cursor: Qt.SizeVerCursor },
				{ edge: "tr", x: 1, y: 0, cursor: Qt.SizeBDiagCursor },
				{ edge: "r", x: 1, y: 0.5, cursor: Qt.SizeHorCursor },
				{ edge: "br", x: 1, y: 1, cursor: Qt.SizeFDiagCursor },
				{ edge: "b", x: 0.5, y: 1, cursor: Qt.SizeVerCursor },
				{ edge: "bl", x: 0, y: 1, cursor: Qt.SizeBDiagCursor },
				{ edge: "l", x: 0, y: 0.5, cursor: Qt.SizeHorCursor }
			]

			Item {
				id: handle
				required property var modelData
				readonly property real centerX: overlay.localSelection
					? overlay.localSelection.x + modelData.x * overlay.localSelection.w : 0
				readonly property real centerY: overlay.localSelection
					? overlay.localSelection.y + modelData.y * overlay.localSelection.h : 0
				x: centerX - 9
				y: centerY - 9
				width: 18
				height: 18

				Rectangle {
					anchors.centerIn: parent
					width: 8
					height: 8
					radius: 2
					color: Theme.text
					border.color: Theme.surface
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: handle.modelData.cursor
					onPressed: overlay.resizeStarted(handle.modelData.edge)
					onPositionChanged: mouse => {
						if (pressed)
							overlay.resizeMoved(mouse.x + handle.x + overlay.screenX,
								mouse.y + handle.y + overlay.screenY);
					}
					onReleased: overlay.resizeFinished()
				}
			}
		}
	}

	TextInput {
		readonly property bool ownsDraft: overlay.textEditing && overlay.draft
			&& overlay.draft.type === "text"
			&& overlay.draft.points[0].x >= overlay.screenX
			&& overlay.draft.points[0].x < overlay.screenX + overlay.width
			&& overlay.draft.points[0].y >= overlay.screenY
			&& overlay.draft.points[0].y < overlay.screenY + overlay.height
		visible: ownsDraft
		enabled: ownsDraft
		x: ownsDraft ? overlay.draft.points[0].x - overlay.screenX : 0
		y: ownsDraft ? overlay.draft.points[0].y - overlay.screenY : 0
		color: ownsDraft ? overlay.draft.color : "transparent"
		font.family: Theme.fontFamily
		font.pixelSize: ownsDraft ? overlay.draft.size : 18
		cursorVisible: ownsDraft
		onTextEdited: overlay.textChanged(text)
		onOwnsDraftChanged: {
			if (ownsDraft) {
				text = overlay.draft.text || "";
				forceActiveFocus();
			}
		}
		Keys.onPressed: event => {
			if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
				overlay.textAccepted();
				event.accepted = true;
			}
		}
	}
}
