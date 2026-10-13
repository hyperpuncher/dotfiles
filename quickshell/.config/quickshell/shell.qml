//@ pragma DropExpensiveFonts
//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
	id: root

	property var launcherApplications: []
	property var launcherUsage: ({})
	property bool launcherReloadPending: false
	property bool screenshotActive: false
	property string screenshotMode: "region"

	Process {
		id: launcherApplicationsReader
		command: [`${Quickshell.shellDir}/scripts/launcher-apps`]
		running: true
		onExited: {
			if (root.launcherReloadPending) {
				root.launcherReloadPending = false;
				launcherReloadDebounce.restart();
			}
		}
		stdout: StdioCollector {
			onStreamFinished: {
				try {
					root.launcherApplications = JSON.parse(text || "[]");
				} catch (error) {
					console.warn("could not read applications", error);
				}
			}
		}
	}

	Process {
		command: [`${Quickshell.shellDir}/scripts/launcher-apps`, "--watch"]
		running: true
		stdout: SplitParser {
			onRead: launcherReloadDebounce.restart()
		}
	}

	Timer {
		id: launcherReloadDebounce
		interval: 150
		onTriggered: {
			if (launcherApplicationsReader.running)
				root.launcherReloadPending = true;
			else
				launcherApplicationsReader.running = true;
		}
	}

	Process {
		id: launcherUsageReader
		command: [`${Quickshell.shellDir}/scripts/launcher-usage`, "read"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: {
				try {
					root.launcherUsage = JSON.parse(text || "{}");
				} catch (error) {
					console.warn("could not read launcher usage", error);
				}
			}
		}
	}

	Wallpaper {
		source: `file://${Quickshell.env("HOME")}/Pictures/wallpapers/keith-up.png`
		barWidth: 38
		cornerRadius: 9
	}

	Bar {}
	OverlayScrim {}

	Loader {
		active: root.screenshotActive
		sourceComponent: Screenshot {
			initialMode: root.screenshotMode
			onClosed: root.screenshotActive = false
		}
	}

	Idle {}
	PolkitPrompt {}

	Loader {
		active: NotificationService.popupNotifications.length > 0
		sourceComponent: NotificationToasts {}
	}

	Loader {
		active: ShellState.activePanel === "launcher"
		sourceComponent: Launcher {
			applications: root.launcherApplications
			usage: root.launcherUsage
			onUsageBumped: updatedUsage => root.launcherUsage = updatedUsage
		}
		onLoaded: {
			launcherReloadDebounce.restart();
			item.open();
		}
	}

	Loader {
		active: ShellState.activePanel === "bluetooth"
		sourceComponent: BluetoothPanel {}
		onLoaded: item.open()
	}

	ClipboardPanel {}

	Loader {
		active: ShellState.activePanel === "power"
		sourceComponent: PowerPanel {}
		onLoaded: item.open()
	}

	Loader {
		active: ShellState.activePanel === "emoji"
		sourceComponent: EmojiPanel {}
		onLoaded: item.open()
	}

	Loader {
		active: ShellState.activePanel === "network"
		sourceComponent: NetworkPanel {}
		onLoaded: item.open()
	}

	Loader {
		active: ShellState.activePanel === "audio"
		sourceComponent: AudioPanel {}
		onLoaded: item.open()
	}

	Loader {
		active: ShellState.activePanel === "notifications"
		sourceComponent: NotificationCenter {}
		onLoaded: item.open()
	}

	Loader {
		active: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""
		sourceComponent: Component {
			Scope {
				GlobalShortcut {
					appid: "quickshell"
					name: "launcher"
					description: "open the application launcher"
					onPressed: ShellState.toggle("launcher")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "clipboard"
					description: "open clipboard history"
					onPressed: ShellState.toggle("clipboard")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "power"
					description: "open power menu"
					onPressed: ShellState.toggle("power")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "emoji"
					description: "open emoji picker"
					onPressed: ShellState.toggle("emoji")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "screenshot"
					description: "capture and annotate a region"
					onPressed: root.openScreenshot("region")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "screenshot-window"
					description: "capture and annotate the active window"
					onPressed: root.openScreenshot("window")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "screenshot-fullscreen"
					description: "capture and annotate the focused monitor"
					onPressed: root.openScreenshot("fullscreen")
				}
			}
		}
	}

	function openScreenshot(mode: string): void {
		if (root.screenshotActive) {
			root.screenshotActive = false;
			return;
		}
		ShellState.close();
		root.screenshotMode = mode;
		root.screenshotActive = true;
	}

	IpcHandler {
		target: "shell"

		function toggleLauncher(): void {
			ShellState.toggle("launcher");
		}

		function toggleClipboard(): void {
			ShellState.toggle("clipboard");
		}

		function togglePower(): void {
			ShellState.toggle("power");
		}

		function toggleEmoji(): void {
			ShellState.toggle("emoji");
		}

		function toggleNetwork(): void {
			ShellState.toggle("network");
		}

		function toggleAudio(): void {
			ShellState.toggle("audio");
		}

		function toggleNotifications(): void {
			ShellState.toggle("notifications");
		}

		function close(): void {
			ShellState.close();
		}

		function screenshot(): void {
			root.openScreenshot("region");
		}

		function editScreenshot(mode: string): void {
			if (["region", "window", "fullscreen"].includes(mode))
				root.openScreenshot(mode);
		}

		function setTheme(mode: string): void {
			Theme.setMode(mode);
		}

		function refreshTheme(): void {
			Theme.refresh();
		}
	}
}
