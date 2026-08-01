import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
	id: window

	property real scrimOpacity: 0
	readonly property bool active: ShellState.activePanel !== ""

	visible: active || closeTimer.running || scrimOpacity > 0
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore
	mask: Region {}

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-scrim"
	WlrLayershell.layer: WlrLayer.Top

	onActiveChanged: {
		if (active) {
			closeTimer.stop();
			scrimOpacity = 1;
		} else {
			scrimOpacity = 0;
			closeTimer.restart();
		}
	}

	Component.onCompleted: if (active) scrimOpacity = 1

	Rectangle {
		anchors.fill: parent
		color: Theme.scrim
		opacity: window.scrimOpacity
	}

	Behavior on scrimOpacity {
		NumberAnimation {
			duration: 150
			easing.type: Easing.BezierSpline
			easing.bezierCurve: [0.23, 1, 0.32, 1, 1, 1]
		}
	}

	Timer {
		id: closeTimer
		interval: 150
	}
}
