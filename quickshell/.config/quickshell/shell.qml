//@ pragma DropExpensiveFonts
//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
	id: root

	readonly property string wallpaperInput: `${Quickshell.env("HOME")}/Pictures/wallpapers/keith-up.png`
	readonly property string wallpaperCache: Quickshell.cachePath("wallpaper.webp")
	property url wallpaperSource: `file://${wallpaperCache}`
	readonly property var wallpaperScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
	property var pendingWallpaperCommand: []
	property bool wallpaperPreparePending: false
	property var launcherApplications: []
	property var launcherUsage: ({})

	function prepareWallpaper(): void {
		const monitor = wallpaperScreen && Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""
			? Hyprland.monitorFor(wallpaperScreen)
			: null;
		const scale = monitor ? monitor.scale : (wallpaperScreen ? wallpaperScreen.devicePixelRatio : 1);
		const width = wallpaperScreen ? Math.round(wallpaperScreen.width * scale) : 3840;
		const height = wallpaperScreen ? Math.round(wallpaperScreen.height * scale) : 2160;
		pendingWallpaperCommand = [
			`${Quickshell.shellDir}/scripts/prepare-wallpaper`,
			wallpaperInput,
			wallpaperCache,
			String(width),
			String(height)
		];
		wallpaperPrepareDebounce.restart();
	}

	Timer {
		id: wallpaperPrepareDebounce
		interval: 250
		onTriggered: {
			if (wallpaperPrepare.running) {
				root.wallpaperPreparePending = true;
				return;
			}
			wallpaperPrepare.command = root.pendingWallpaperCommand;
			wallpaperPrepare.running = true;
		}
	}

	Process {
		id: launcherApplicationsReader
		command: [`${Quickshell.shellDir}/scripts/launcher-apps`]
		running: true
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

	Process {
		id: wallpaperPrepare
		onExited: (exitCode, exitStatus) => {
			if (exitCode === 0)
				root.wallpaperSource = `file://${root.wallpaperCache}?v=${Date.now()}`;
			else if (exitCode !== 10)
				console.warn("could not prepare wallpaper with vips", exitCode, exitStatus);
			if (root.wallpaperPreparePending) {
				root.wallpaperPreparePending = false;
				wallpaperPrepareDebounce.restart();
			}
		}
	}

	Timer {
		interval: 500
		running: true
		onTriggered: root.prepareWallpaper()
	}

	Wallpaper {
		source: root.wallpaperSource
		barWidth: 38
		cornerRadius: 9
	}

	Bar {}
	OverlayScrim {}

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
		onLoaded: item.open()
	}

	Loader {
		active: ShellState.activePanel === "bluetooth"
		sourceComponent: BluetoothPanel {}
		onLoaded: item.open()
	}

	Loader {
		active: ShellState.activePanel === "clipboard"
		sourceComponent: ClipboardPanel {}
		onLoaded: item.open()
	}

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
					onPressed: root.togglePanel("launcher")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "clipboard"
					description: "open clipboard history"
					onPressed: root.togglePanel("clipboard")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "power"
					description: "open power menu"
					onPressed: root.togglePanel("power")
				}

				GlobalShortcut {
					appid: "quickshell"
					name: "emoji"
					description: "open emoji picker"
					onPressed: root.togglePanel("emoji")
				}
			}
		}
	}

	function togglePanel(name: string): void {
		if (ShellState.activePanel === name)
			ShellState.close();
		else
			ShellState.open(name);
	}

	IpcHandler {
		target: "shell"

		function toggleLauncher(): void {
			root.togglePanel("launcher");
		}

		function toggleClipboard(): void {
			root.togglePanel("clipboard");
		}

		function togglePower(): void {
			root.togglePanel("power");
		}

		function toggleEmoji(): void {
			root.togglePanel("emoji");
		}

		function toggleNetwork(): void {
			root.togglePanel("network");
		}

		function toggleAudio(): void {
			root.togglePanel("audio");
		}

		function toggleNotifications(): void {
			root.togglePanel("notifications");
		}

		function close(): void {
			ShellState.close();
		}

		function setTheme(mode: string): void {
			Theme.setMode(mode);
		}

		function refreshTheme(): void {
			Theme.refresh();
		}
	}
}
