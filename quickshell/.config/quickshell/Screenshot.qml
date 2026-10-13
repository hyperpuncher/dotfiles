import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "screenshot/AnnotationModel.js" as AnnotationModel
import "screenshot/Geometry.js" as Geometry

Scope {
	id: root

	signal closed()

	property string initialMode: "region"
	property string phase: "selecting"
	property var selection: null
	property var gestureStart: null
	property var activeScreen: null
	property string resizeEdge: ""
	property var annotations: AnnotationModel.create()
	property var draft: null
	property int annotationRevision: 0
	property int selectedIndex: -1
	property var moveStart: null
	property point moveOffset: Qt.point(0, 0)
	property bool textEditing: false
	property string activeTool: "arrow"
	property color activeColor: Theme.error
	property int activeWidth: 4
	property var overlays: []
	property bool outputBusy: false
	property int captureFailures: 0

	readonly property var tools: [
		{ id: "select", icon: "mouse-pointer-2", name: "select", key: "v" },
		{ id: "rect", icon: "square", name: "rectangle", key: "r" },
		{ id: "ellipse", icon: "circle", name: "ellipse", key: "o" },
		{ id: "arrow", icon: "arrow-up-right", name: "arrow", key: "a" },
		{ id: "line", icon: "minus", name: "line", key: "l" },
		{ id: "pen", icon: "pencil", name: "pen", key: "p" },
		{ id: "text", icon: "type", name: "text", key: "t" },
		{ id: "redact", icon: "scan-line", name: "redact", key: "x" }
	]
	readonly property string runtimeDirectory: Quickshell.env("XDG_RUNTIME_DIR")
		|| `${Quickshell.env("HOME")}/.cache`
	readonly property string temporaryPath: `${runtimeDirectory}/quickshell-screenshot.png`
	readonly property string screenshotDirectory: `${Quickshell.env("HOME")}/Pictures/screenshots`

	function bumpRevision(): void {
		annotationRevision++;
	}

	function screenAt(x: real, y: real): var {
		for (const screen of Quickshell.screens) {
			if (x >= screen.x && x < screen.x + screen.width
				&& y >= screen.y && y < screen.y + screen.height)
				return screen;
		}
		return null;
	}

	function clampPoint(x: real, y: real): var {
		if (!activeScreen)
			return { x, y };
		return {
			x: Math.max(activeScreen.x, Math.min(x, activeScreen.x + activeScreen.width)),
			y: Math.max(activeScreen.y, Math.min(y, activeScreen.y + activeScreen.height))
		};
	}

	function clampToSelection(x: real, y: real): var {
		if (!selection)
			return { x, y };
		return {
			x: Math.max(selection.x, Math.min(x, selection.x + selection.w)),
			y: Math.max(selection.y, Math.min(y, selection.y + selection.h))
		};
	}

	function beginSelection(x: real, y: real): void {
		activeScreen = screenAt(x, y);
		if (!activeScreen)
			return;
		const point = clampPoint(x, y);
		gestureStart = point;
		selection = { x: point.x, y: point.y, w: 0, h: 0 };
	}

	function updateSelection(x: real, y: real): void {
		if (!gestureStart)
			return;
		selection = Geometry.rectFromPoints(gestureStart, clampPoint(x, y));
	}

	function finishSelection(): void {
		gestureStart = null;
		if (selection && selection.w > 3 && selection.h > 3) {
			phase = "editing";
			return;
		}
		selection = null;
		activeScreen = null;
	}

	function selectWholeScreen(screen: var): void {
		activeScreen = screen;
		selection = {
			x: screen.x,
			y: screen.y,
			w: screen.width,
			h: screen.height
		};
		phase = "editing";
	}

	function selectWindowTarget(target: var): void {
		if (!target)
			return;
		const screen = screenAt(target.x + target.w / 2, target.y + target.h / 2);
		if (!screen)
			return;
		activeScreen = screen;
		const left = Math.max(target.x, screen.x);
		const top = Math.max(target.y, screen.y);
		const right = Math.min(target.x + target.w, screen.x + screen.width);
		const bottom = Math.min(target.y + target.h, screen.y + screen.height);
		selection = { x: left, y: top, w: right - left, h: bottom - top };
		phase = "editing";
	}

	function beginResize(edge: string): void {
		resizeEdge = edge;
	}

	function updateResize(x: real, y: real): void {
		if (resizeEdge === "" || !selection)
			return;
		const point = clampPoint(x, y);
		let left = selection.x;
		let top = selection.y;
		let right = selection.x + selection.w;
		let bottom = selection.y + selection.h;
		const minimum = 8;
		if (resizeEdge.includes("l")) left = Math.min(point.x, right - minimum);
		if (resizeEdge.includes("r")) right = Math.max(point.x, left + minimum);
		if (resizeEdge.includes("t")) top = Math.min(point.y, bottom - minimum);
		if (resizeEdge.includes("b")) bottom = Math.max(point.y, top + minimum);
		selection = { x: left, y: top, w: right - left, h: bottom - top };
	}

	function finishResize(): void {
		resizeEdge = "";
	}

	function selectTool(tool: string): void {
		if (textEditing)
			commitText();
		activeTool = tool;
		selectedIndex = -1;
		moveOffset = Qt.point(0, 0);
		bumpRevision();
	}

	function beginMove(x: real, y: real): void {
		selectedIndex = Geometry.hitTest(annotations.items, x, y);
		if (selectedIndex >= 0) {
			moveStart = { x, y };
			moveOffset = Qt.point(0, 0);
		}
		bumpRevision();
	}

	function updateMove(x: real, y: real): void {
		if (selectedIndex < 0 || !moveStart)
			return;
		moveOffset = Qt.point(x - moveStart.x, y - moveStart.y);
		bumpRevision();
	}

	function finishMove(): void {
		if (selectedIndex >= 0 && (moveOffset.x !== 0 || moveOffset.y !== 0))
			annotations.move(selectedIndex, moveOffset.x, moveOffset.y);
		moveStart = null;
		moveOffset = Qt.point(0, 0);
		bumpRevision();
	}

	function beginDraw(x: real, y: real): void {
		if (!selection)
			return;
		if (activeTool === "text") {
			const point = clampToSelection(x, y);
			draft = {
				type: "text",
				points: [point],
				text: "",
				color: activeColor.toString(),
				size: activeWidth * 4 + 10
			};
			textEditing = true;
			bumpRevision();
			return;
		}
		const point = clampToSelection(x, y);
		gestureStart = point;
		draft = {
			type: activeTool,
			points: activeTool === "pen" ? [point] : [point, point],
			color: activeColor.toString(),
			width: activeWidth
		};
		bumpRevision();
	}

	function updateDraw(x: real, y: real): void {
		if (!draft || !gestureStart || draft.type === "text")
			return;
		const point = clampToSelection(x, y);
		if (draft.type === "pen") {
			const previous = draft.points[draft.points.length - 1];
			if (Math.hypot(point.x - previous.x, point.y - previous.y) >= 2)
				draft.points.push(point);
		} else {
			draft.points = [gestureStart, point];
		}
		bumpRevision();
	}

	function finishDraw(): void {
		if (!draft || draft.type === "text")
			return;
		const first = draft.points[0];
		const last = draft.points[draft.points.length - 1];
		const distance = Math.hypot(last.x - first.x, last.y - first.y);
		if ((draft.type === "pen" && draft.points.length >= 2)
			|| (draft.type !== "pen" && distance > 4))
			annotations.add(draft);
		draft = null;
		gestureStart = null;
		bumpRevision();
	}

	function commitText(): void {
		if (draft && draft.type === "text" && draft.text.trim() !== "")
			annotations.add(draft);
		draft = null;
		textEditing = false;
		bumpRevision();
	}

	function cancelText(): void {
		draft = null;
		textEditing = false;
		bumpRevision();
	}

	function pointerPressed(x: real, y: real): void {
		if (resizeEdge !== "" || outputBusy)
			return;
		if (phase === "selecting")
			beginSelection(x, y);
		else if (activeTool === "select")
			beginMove(x, y);
		else
			beginDraw(x, y);
	}

	function pointerMoved(x: real, y: real): void {
		if (resizeEdge !== "")
			return;
		if (phase === "selecting")
			updateSelection(x, y);
		else if (activeTool === "select")
			updateMove(x, y);
		else
			updateDraw(x, y);
	}

	function pointerReleased(): void {
		if (phase === "selecting")
			finishSelection();
		else if (activeTool === "select")
			finishMove();
		else
			finishDraw();
	}

	function adjustWidth(direction: int): void {
		activeWidth = Math.max(1, Math.min(16, activeWidth + direction));
		if (draft && draft.width !== undefined) {
			draft.width = activeWidth;
			bumpRevision();
		}
	}

	function undo(): void {
		if (annotations.undo()) {
			selectedIndex = -1;
			bumpRevision();
		}
	}

	function redo(): void {
		if (annotations.redo()) {
			selectedIndex = -1;
			bumpRevision();
		}
	}

	function deleteSelected(): void {
		if (selectedIndex >= 0 && annotations.remove(selectedIndex)) {
			selectedIndex = -1;
			bumpRevision();
		}
	}

	function handleEscape(): void {
		if (outputBusy)
			return;
		if (textEditing) {
			cancelText();
			return;
		}
		if (selectedIndex >= 0) {
			selectedIndex = -1;
			bumpRevision();
			return;
		}
		root.closed();
	}

	function overlayForSelection(): var {
		if (!activeScreen)
			return null;
		for (const overlay of overlays) {
			if (overlay.modelData && overlay.modelData.name === activeScreen.name)
				return overlay;
		}
		return null;
	}

	function timestamp(): string {
		const date = new Date();
		const pad = value => String(value).padStart(2, "0");
		return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}_${pad(date.getHours())}h${pad(date.getMinutes())}m${pad(date.getSeconds())}s.png`;
	}

	function notify(message: string, urgency: string, image): void {
		const command = ["notify-send", "-a", "screenshot", "-u", urgency];
		if (image)
			command.push("-i", image);
		command.push("Screenshot", message);
		Quickshell.execDetached(command);
	}

	function exportFor(action: string): void {
		if (outputBusy || !selection)
			return;
		const overlay = overlayForSelection();
		if (!overlay)
			return;
		outputBusy = true;
		overlay.exportSelection(temporaryPath, ok => {
			if (!ok) {
				outputBusy = false;
				notify("Could not render capture", "critical");
				return;
			}
			if (action === "copy") {
				copyProcess.command = ["sh", "-c", "wl-copy --type image/png < \"$1\"", "_", temporaryPath];
				copyProcess.running = true;
			} else {
				const destination = `${screenshotDirectory}/${timestamp()}`;
				saveProcess.destination = destination;
				saveProcess.command = ["sh", "-c", "mkdir -p -- \"$2\" && cp -- \"$1\" \"$3\"; code=$?; rm -f -- \"$1\"; exit $code", "_", temporaryPath, screenshotDirectory, destination];
				saveProcess.running = true;
			}
		});
	}

	Process {
		command: ["hyprctl", "monitors", "-j"]
		running: root.initialMode === "fullscreen" && Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""
		stdout: StdioCollector { id: monitorsOutput }
		onExited: exitCode => {
			if (exitCode !== 0)
				return;
			try {
				const focused = JSON.parse(monitorsOutput.text).find(monitor => monitor.focused);
				const screen = focused
					? Quickshell.screens.find(candidate => candidate.name === focused.name)
					: null;
				if (screen)
					root.selectWholeScreen(screen);
			} catch (error) {
				console.warn("could not select focused screenshot monitor", error);
			}
		}
	}

	Process {
		command: ["hyprctl", "activewindow", "-j"]
		running: root.initialMode === "window" && Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""
		stdout: StdioCollector { id: windowOutput }
		onExited: exitCode => {
			if (exitCode !== 0)
				return;
			try {
				const window = JSON.parse(windowOutput.text);
				if (window.at && window.size && window.size[0] > 0 && window.size[1] > 0) {
					root.selectWindowTarget({
						x: window.at[0], y: window.at[1],
						w: window.size[0], h: window.size[1]
					});
				}
			} catch (error) {
				console.warn("could not select active screenshot window", error);
			}
		}
	}

	Process {
		id: copyProcess
		onExited: exitCode => {
			if (exitCode === 0) {
				root.notify("Copied to clipboard", "low", root.temporaryPath);
				root.closed();
			} else {
				root.outputBusy = false;
				root.notify("Could not copy capture", "critical");
			}
		}
	}

	Process {
		id: saveProcess
		property string destination: ""
		onExited: exitCode => {
			if (exitCode === 0) {
				root.notify(`Saved to ${destination}`, "low", destination);
				root.closed();
			} else {
				root.outputBusy = false;
				root.notify("Could not save capture", "critical");
			}
		}
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: window
			required property var modelData
			screen: modelData
			color: "transparent"
			exclusionMode: ExclusionMode.Ignore

			anchors {
				top: true
				right: true
				bottom: true
				left: true
			}

			WlrLayershell.namespace: "quickshell-screenshot"
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

			FocusScope {
				anchors.fill: parent
				focus: true

				Keys.onPressed: event => {
					if (event.key === Qt.Key_Escape) {
						root.handleEscape();
						event.accepted = true;
						return;
					}
					if (root.textEditing || root.outputBusy)
						return;
					if (event.modifiers & Qt.ControlModifier) {
						if (event.key === Qt.Key_A && root.phase === "selecting")
							root.selectWholeScreen(window.modelData);
						else if (event.key === Qt.Key_C && root.phase === "editing")
							root.exportFor("copy");
						else if (event.key === Qt.Key_S && root.phase === "editing")
							root.exportFor("save");
						else if (event.key === Qt.Key_Z && event.modifiers & Qt.ShiftModifier)
							root.redo();
						else if (event.key === Qt.Key_Z)
							root.undo();
						else if (event.key === Qt.Key_Y)
							root.redo();
						event.accepted = true;
						return;
					}
					if ((event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace)
						&& root.selectedIndex >= 0) {
						root.deleteSelected();
						event.accepted = true;
						return;
					}
					if (root.phase === "editing") {
						const descriptor = root.tools.find(tool => tool.key === event.text.toLowerCase());
						if (descriptor) {
							root.selectTool(descriptor.id);
							event.accepted = true;
						}
					}
				}

				ScreenshotOverlay {
					id: overlay
					anchors.fill: parent
					screenData: window.modelData
					selection: root.selection
					phase: root.phase
					annotations: root.annotations.items
					draft: root.draft
					annotationRevision: root.annotationRevision
					selectedIndex: root.selectedIndex
					moveOffset: root.moveOffset
					textEditing: root.textEditing
					onPressedAt: (x, y) => root.pointerPressed(x, y)
					onMovedTo: (x, y) => root.pointerMoved(x, y)
					onReleased: root.pointerReleased()
					onWheelChanged: direction => root.adjustWidth(direction)
					onResizeStarted: edge => root.beginResize(edge)
					onResizeMoved: (x, y) => root.updateResize(x, y)
					onResizeFinished: root.finishResize()
					onTextChanged: value => {
						if (root.draft && root.draft.type === "text") {
							root.draft.text = value;
							root.bumpRevision();
						}
					}
					onTextAccepted: root.commitText()
					onCaptureFailed: {
						root.captureFailures++;
						if (root.captureFailures >= Quickshell.screens.length) {
							root.notify("Screen capture failed", "critical");
							root.closed();
						}
					}
				}

				ScreenshotToolbar {
					visible: root.phase === "editing" && root.activeScreen
						&& root.activeScreen.name === window.modelData.name
					activeTool: root.activeTool
					activeColor: root.activeColor
					canUndo: {
						root.annotationRevision;
						return root.annotations.undoStack.length > 0;
					}
					canRedo: {
						root.annotationRevision;
						return root.annotations.redoStack.length > 0;
					}
					tools: root.tools
					x: {
						if (!overlay.localSelection)
							return 8;
						return Math.max(8, Math.min(
							overlay.localSelection.x + overlay.localSelection.w / 2 - width / 2,
							window.width - width - 8
						));
					}
					y: {
						if (!overlay.localSelection)
							return 8;
						const below = overlay.localSelection.y + overlay.localSelection.h + 12;
						if (below + height <= window.height - 8)
							return below;
						return Math.max(8, overlay.localSelection.y - height - 12);
					}
					onToolSelected: tool => root.selectTool(tool)
					onColorSelected: value => root.activeColor = value
					onUndoRequested: root.undo()
					onRedoRequested: root.redo()
					onCopyRequested: root.exportFor("copy")
					onSaveRequested: root.exportFor("save")
				}
			}

			Component.onCompleted: root.overlays = root.overlays.concat([window])
			Component.onDestruction: root.overlays = root.overlays.filter(item => item !== window)

			function exportSelection(path: string, callback: var): void {
				overlay.exportSelection(path, callback);
			}
		}
	}
}
