pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property bool dark: true

	readonly property color barBackground: "#000000"
	readonly property color barText: "#ffffff"
	readonly property color surface: dark ? "#f2181818" : "#f2f6f6f4"
	readonly property color surfaceRaised: dark ? "#f2242424" : "#f2e8e8e5"
	readonly property color notificationSurface: dark ? "#f20a0a0b" : surface
	readonly property color notificationBorder: "#80dedede"
	readonly property color text: dark ? "#f2f2f0" : "#141414"
	readonly property color muted: dark ? "#999999" : "#6c6c68"
	readonly property color border: dark ? "#3b3b3b" : "#cacac6"
	readonly property color borderStrong: dark ? "#737373" : "#777773"
	readonly property color input: dark ? "#d91f1f1f" : "#e8eeeeeb"
	readonly property color error: dark ? "#d16d6d" : "#a33d3d"
	readonly property color selected: dark ? "#f2f2f0" : "#111111"
	readonly property color selection: selected
	readonly property color selectedText: dark ? "#141414" : "#ffffff"
	readonly property color scrim: dark ? "#59000000" : "#24000000"

	readonly property string fontFamily: "Iosevka Nerd Font"
	readonly property int radius: 9

	function setMode(mode: string): void {
		if (mode === "dark" || mode === "light")
			root.dark = mode === "dark";
	}

	function refresh(): void {
		darkmanGet.running = true;
	}

	function toggle(): void {
		darkmanToggle.running = true;
	}

	Process {
		id: darkmanToggle
		command: ["darkman", "toggle"]
		onExited: root.refresh()
	}

	Process {
		id: darkmanGet
		command: ["darkman", "get"]
		stdout: StdioCollector {
			onStreamFinished: root.setMode(text.trim())
		}
	}

	Component.onCompleted: refresh()
}
