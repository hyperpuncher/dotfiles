pragma Singleton

import QtQuick
import Quickshell

Singleton {
	property string activePanel: ""
	property bool pointerPositionKnown: false
	property point lastPointerPosition: Qt.point(0, 0)

	function resetPointerSelection(): void {
		pointerPositionKnown = false;
	}

	function pointerSelectionMoved(position): bool {
		const changed = pointerPositionKnown
			&& (position.x !== lastPointerPosition.x || position.y !== lastPointerPosition.y);
		lastPointerPosition = position;
		pointerPositionKnown = true;
		return changed;
	}

	function open(panel: string): void {
		activePanel = panel;
	}

	function close(): void {
		activePanel = "";
	}

	function toggle(panel: string): void {
		activePanel = activePanel === panel ? "" : panel;
	}
}
