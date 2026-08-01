import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets

Scope {
	id: root

	property bool showDate: false
	property bool trayExpanded: false
	property string language: "EN"
	readonly property bool onHyprland: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""
	readonly property var players: Mpris.players.values
	readonly property var player: selectPlayer(players)
	readonly property var trayItems: SystemTray.items.values.filter(item => {
		const identity = `${item.id} ${item.title}`.toLowerCase();
		return !identity.includes("spotify")
			&& !identity.includes("blueman")
			&& !identity.includes("nm_applet")
			&& !identity.includes("networkmanager");
	})
	readonly property var networkDevices: Networking.devices.values
	readonly property var connectedWifi: {
		for (const device of networkDevices) {
			if (device.type !== DeviceType.Wifi)
				continue;
			for (const network of device.networks.values) {
				if (network.connected)
					return network;
			}
		}
		return null;
	}
	readonly property bool wiredConnected: networkDevices.some(device =>
		device.type === DeviceType.Wired && device.network && device.network.connected)
	readonly property string networkIcon: {
		if (connectedWifi) {
			if (connectedWifi.signalStrength >= 80)
				return "network-wireless-signal-excellent-symbolic";
			if (connectedWifi.signalStrength >= 60)
				return "network-wireless-signal-good-symbolic";
			if (connectedWifi.signalStrength >= 40)
				return "network-wireless-signal-ok-symbolic";
			if (connectedWifi.signalStrength >= 20)
				return "network-wireless-signal-weak-symbolic";
			return "network-wireless-signal-none-symbolic";
		}
		return wiredConnected ? "network-wired-symbolic" : "network-wired-disconnected-symbolic";
	}
	readonly property string mediaText: {
		if (!player)
			return "";
		const metadata = [player.trackArtist, player.trackTitle].filter(value => value).join(" - ");
		if (!metadata)
			return "";
		return `${metadata} ${player.isPlaying ? "" : ""}`;
	}

	function selectPlayer(players): var {
		for (const player of players) {
			if (player.identity.toLowerCase().includes("spotify"))
				return player;
		}
		for (const player of players) {
			if (player.isPlaying)
				return player;
		}
		return players.length > 0 ? players[0] : null;
	}

	function updateLanguage(name: string): void {
		root.language = name.toLowerCase().includes("russian") ? "RU" : "EN";
	}

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}

	Process {
		command: ["hyprctl", "devices", "-j"]
		running: root.onHyprland
		stdout: StdioCollector {
			onStreamFinished: {
				try {
					const devices = JSON.parse(text);
					const keyboard = devices.keyboards.find(item => item.main);
					if (keyboard)
						root.updateLanguage(keyboard.active_keymap);
				} catch (error) {
					console.warn("could not read the active keyboard layout", error);
				}
			}
		}
	}

	Connections {
		target: Hyprland
		function onRawEvent(event): void {
			if (event.name === "activelayout") {
				const separator = event.data.indexOf(",");
				root.updateLanguage(separator >= 0 ? event.data.slice(separator + 1) : event.data);
			}
		}
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: window

			required property var modelData
			screen: modelData

			anchors {
				top: true
				bottom: true
				left: true
			}

			implicitWidth: 38
			color: Theme.barBackground

			WlrLayershell.namespace: "quickshell-bar"
			WlrLayershell.layer: WlrLayer.Top

			Item {
				anchors.fill: parent

				MouseArea {
					id: clockMouse
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					height: clockText.implicitHeight + 14
					cursorShape: Qt.PointingHandCursor
					onClicked: root.showDate = !root.showDate
				}

				Text {
					id: clockText
					anchors.top: parent.top
					anchors.topMargin: 8
					anchors.horizontalCenter: parent.horizontalCenter
					text: root.showDate
						? Qt.formatDateTime(clock.date, "dd\nMM\nyy")
						: Qt.formatDateTime(clock.date, "HH\nmm")
					color: Theme.barText
					font.family: Theme.fontFamily
					font.pixelSize: 18
					font.styleName: "Medium"
					lineHeight: 0.9
					horizontalAlignment: Text.AlignHCenter
				}

				Item {
					id: mediaArea
					visible: root.mediaText !== ""
					anchors.top: clockMouse.bottom
					anchors.bottom: bottomArea.top
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.topMargin: 10
					anchors.bottomMargin: 8
					clip: true

					Text {
						anchors.centerIn: parent
						width: Math.max(0, mediaArea.height - 8)
						rotation: -90
						text: root.mediaText
						color: Theme.barText
						font.family: Theme.fontFamily
						font.pixelSize: 18
						font.styleName: "Medium"
						horizontalAlignment: Text.AlignRight
						elide: Text.ElideLeft
					}

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: if (root.player && root.player.canTogglePlaying) root.player.togglePlaying()
						onWheel: wheel => {
							if (!root.player)
								return;
							if (wheel.angleDelta.y > 0 && root.player.canGoPrevious)
								root.player.previous();
							else if (wheel.angleDelta.y < 0 && root.player.canGoNext)
								root.player.next();
						}
					}
				}

				ColumnLayout {
					id: bottomArea
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 1
					spacing: 2

					Repeater {
						model: root.trayExpanded ? root.trayItems : []

						Item {
							required property var modelData
							Layout.alignment: Qt.AlignHCenter
							Layout.preferredWidth: 32
							Layout.preferredHeight: 30

							IconImage {
								anchors.centerIn: parent
								width: 20
								height: 20
								source: modelData.icon
								mipmap: false
								backer.sourceSize.width: width * Screen.devicePixelRatio
								backer.sourceSize.height: height * Screen.devicePixelRatio
							}

							MouseArea {
								anchors.fill: parent
								acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
								cursorShape: Qt.PointingHandCursor
								onClicked: mouse => {
									if (mouse.button === Qt.RightButton && modelData.hasMenu)
										modelData.display(window, window.width, parent.y);
									else if (mouse.button === Qt.MiddleButton)
										modelData.secondaryActivate();
									else
										modelData.activate();
								}
							}
						}
					}

					IconBarButton {
						visible: root.trayExpanded
						source: Quickshell.iconPath(root.networkIcon, "")
						onClicked: ShellState.open("network")
					}

					BarButton {
						visible: root.onHyprland
						text: root.language
						fontSize: 17
						onClicked: Hyprland.dispatch("switchxkblayout current next")
					}

					BarButton {
						text: Theme.dark ? "" : ""
						iconRotation: 90
						fontSize: 30
						onClicked: Theme.toggle()
					}

					BarButton {
						text: ""
						iconRotation: 90
						onClicked: root.trayExpanded = !root.trayExpanded
					}
				}
			}
		}
	}

	component IconBarButton: Item {
		id: iconButton
		required property url source
		signal clicked()
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: 32
		Layout.preferredHeight: 28

		IconImage {
			id: sourceIcon
			anchors.centerIn: parent
			width: 16
			height: 16
			source: iconButton.source
			mipmap: false
			backer.sourceSize.width: width * Screen.devicePixelRatio
			backer.sourceSize.height: height * Screen.devicePixelRatio
		}

		ShaderEffectSource {
			id: iconTexture
			anchors.fill: sourceIcon
			sourceItem: sourceIcon
			hideSource: true
		}

		MultiEffect {
			anchors.fill: sourceIcon
			source: iconTexture
			brightness: 0.82
			colorization: 1
			colorizationColor: Theme.barText
		}

		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			cursorShape: Qt.PointingHandCursor
			onClicked: iconButton.clicked()
		}
	}

	component BarButton: Item {
		id: button
		required property string text
		property real iconRotation: 0
		property real fontSize: 24
		signal clicked()
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: 32
		Layout.preferredHeight: 28

		Text {
			anchors.centerIn: parent
			text: button.text
			color: Theme.barText
			font.family: "IosevkaTerm Nerd Font Mono"
			font.pixelSize: button.fontSize
			font.weight: Font.Medium
			rotation: button.iconRotation
		}

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: button.clicked()
		}
	}
}
