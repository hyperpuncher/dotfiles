import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland

PanelWindow {
	id: root

	readonly property var adapter: Bluetooth.defaultAdapter
	readonly property var devices: Bluetooth.devices.values
	readonly property var rows: buildRows(devices)
	property int selectedIndex: 0
	property bool scanningHere: false

	function usefulName(device): string {
		const name = device.name || device.deviceName || "unknown device";
		const addressLike = /^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(name);
		return name === device.address || addressLike ? "unknown device" : name;
	}

	function buildRows(devices): var {
		const connected = [];
		const paired = [];
		const available = [];

		for (const device of devices) {
			if (device.connected)
				connected.push({ device, section: "connected" });
			else if (device.paired || device.bonded || device.trusted)
				paired.push({ device, section: "paired" });
			else if (adapter && adapter.discovering && usefulName(device) !== "unknown device")
				available.push({ device, section: "available" });
		}

		const byName = (a, b) => usefulName(a.device).localeCompare(usefulName(b.device));
		connected.sort(byName);
		paired.sort(byName);
		available.sort(byName);
		return connected.concat(paired, available);
	}

	function sectionLabel(index: int): string {
		if (index < 0 || index >= rows.length)
			return "";
		if (index > 0 && rows[index - 1].section === rows[index].section)
			return "";
		return rows[index].section;
	}

	function open(): void {
		selectedIndex = 0;
		ShellState.resetPointerSelection();
		Qt.callLater(() => keyHandler.forceActiveFocus());
	}

	function close(): void {
		ShellState.close();
	}

	function moveSelection(delta: int): void {
		if (rows.length === 0)
			return;
		selectedIndex = (selectedIndex + delta + rows.length) % rows.length;
		deviceList.positionViewAtIndex(selectedIndex, ListView.Contain);
	}

	function activateSelected(): void {
		if (selectedIndex < 0 || selectedIndex >= rows.length)
			return;
		const device = rows[selectedIndex].device;
		if (device.connected) {
			device.disconnect();
		} else if (device.paired || device.bonded || device.trusted) {
			device.trusted = true;
			device.connect();
		} else {
			device.pair();
		}
	}

	function forgetSelected(): void {
		if (selectedIndex < 0 || selectedIndex >= rows.length)
			return;
		rows[selectedIndex].device.forget();
	}

	visible: ShellState.activePanel === "bluetooth"
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-bluetooth"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	Component.onDestruction: {
		if (scanningHere && adapter)
			adapter.discovering = false;
	}
	onRowsChanged: {
		if (rows.length === 0)
			selectedIndex = 0;
		else if (selectedIndex >= rows.length)
			selectedIndex = rows.length - 1;
	}

	MouseArea {
		anchors.fill: parent
		onClicked: root.close()
	}

	PopupShadow { target: card }

	Rectangle {
		id: card

		width: Math.min(520, root.width - 64)
		height: Math.min(560, 170 + Math.max(1, Math.min(root.rows.length, 6)) * 78, root.height - 64)
		anchors.centerIn: parent
		color: Theme.surface
		radius: Theme.radius
		border.width: 1
		border.color: Theme.border

		MouseArea {
			anchors.fill: parent
			onClicked: mouse => mouse.accepted = true
		}

		Item {
			id: keyHandler
			anchors.fill: parent
			focus: root.visible

			Keys.priority: Keys.BeforeItem
			Keys.onPressed: event => {
				const ctrl = event.modifiers & Qt.ControlModifier;
				if (event.key === Qt.Key_Escape) {
					root.close();
				} else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K)) {
					root.moveSelection(-1);
				} else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J)) {
					root.moveSelection(1);
				} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					root.activateSelected();
				} else if (event.key === Qt.Key_Delete || event.key === Qt.Key_X) {
					root.forgetSelected();
				} else if (event.key === Qt.Key_B && root.adapter) {
					root.adapter.enabled = !root.adapter.enabled;
				} else if (event.key === Qt.Key_R && root.adapter && root.adapter.enabled) {
					if (root.scanningHere) {
						root.adapter.discovering = false;
						root.scanningHere = false;
					} else if (!root.adapter.discovering) {
						root.adapter.discovering = true;
						root.scanningHere = true;
					}
				} else {
					return;
				}
				event.accepted = true;
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 18
			spacing: 12

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 70
				color: "transparent"
				radius: 8
				border.width: 1
				border.color: Theme.border

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 16
					anchors.rightMargin: 16
					spacing: 14

					Text {
						text: root.adapter && root.adapter.enabled ? "" : "󰂲"
						color: Theme.text
						font.family: "Iosevka Nerd Font"
						font.pixelSize: 25
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: 2

						Text {
							text: "Bluetooth"
							color: Theme.text
							font.family: Theme.fontFamily
							font.pixelSize: 19
							font.weight: Font.DemiBold
						}

						Text {
							text: !root.adapter ? "no adapter"
								: !root.adapter.enabled ? "off"
								: root.adapter.discovering ? "on · scanning"
								: "on"
							color: Theme.muted
							font.family: Theme.fontFamily
							font.pixelSize: 11
						}
					}

					Text {
						text: "󰐥"
						color: Theme.text
						opacity: root.adapter && root.adapter.enabled ? 1 : 0.45
						font.family: "Iosevka Nerd Font"
						font.pixelSize: 20
					}
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
				}
			}

			ListView {
				id: deviceList
				Layout.fillWidth: true
				Layout.fillHeight: true
				clip: true
				spacing: 3
				model: root.rows
				currentIndex: root.selectedIndex
				boundsBehavior: Flickable.StopAtBounds

				delegate: Item {
					id: wrapper

					required property int index
					required property var modelData
					readonly property var device: modelData.device
					readonly property bool selected: index === root.selectedIndex
					readonly property string section: root.sectionLabel(index)

					width: ListView.view.width
					height: row.height + (section ? sectionText.height + 7 : 0)

					Text {
						id: sectionText
						visible: wrapper.section !== ""
						height: visible ? implicitHeight : 0
						text: wrapper.section.toUpperCase()
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 10
						font.weight: Font.DemiBold
						font.letterSpacing: 1.2
					}

					Rectangle {
						id: row
						anchors.top: sectionText.bottom
						anchors.topMargin: wrapper.section ? 7 : 0
						width: parent.width
						height: 62
						radius: 8
						color: wrapper.selected ? Theme.selected : "transparent"

						RowLayout {
							anchors.fill: parent
							anchors.leftMargin: 14
							anchors.rightMargin: 14
							spacing: 13

							Text {
								text: ""
								color: wrapper.selected ? Theme.selectedText : Theme.text
								font.family: "Iosevka Nerd Font"
								font.pixelSize: 20
								Layout.preferredWidth: 28
								horizontalAlignment: Text.AlignHCenter
							}

							ColumnLayout {
								Layout.fillWidth: true
								spacing: 2

								Text {
									Layout.fillWidth: true
									text: root.usefulName(wrapper.device)
									color: wrapper.selected ? Theme.selectedText : Theme.text
									font.family: Theme.fontFamily
									font.pixelSize: 16
									font.weight: Font.Medium
									elide: Text.ElideRight
								}

								Text {
									Layout.fillWidth: true
									text: wrapper.device.pairing ? "pairing…"
										: wrapper.device.state === BluetoothDeviceState.Connecting ? "connecting…"
										: wrapper.device.state === BluetoothDeviceState.Disconnecting ? "disconnecting…"
										: wrapper.device.connected && wrapper.device.batteryAvailable ? `connected · ${Math.round(wrapper.device.battery * 100)}%`
										: wrapper.device.connected ? "connected"
										: wrapper.modelData.section === "paired" ? "paired"
										: "available"
									color: wrapper.selected ? Theme.selectedText : Theme.muted
									opacity: wrapper.selected ? 0.65 : 1
									font.family: Theme.fontFamily
									font.pixelSize: 11
									elide: Text.ElideRight
								}
							}

							Text {
								visible: wrapper.selected
								text: wrapper.device.connected ? "↵ disconnect" : wrapper.device.paired ? "↵ connect" : "↵ pair"
								color: Theme.selectedText
								opacity: 0.55
								font.family: Theme.fontFamily
								font.pixelSize: 10
							}
						}

						MouseArea {
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onPositionChanged: mouse => {
								if (ShellState.pointerSelectionMoved(wrapper.mapToItem(card, mouse.x, mouse.y)))
									root.selectedIndex = wrapper.index;
							}
							onClicked: {
								root.selectedIndex = wrapper.index;
								root.activateSelected();
							}
						}
					}

					Connections {
						target: wrapper.device
						function onPairedChanged(): void {
							if (wrapper.device.paired) {
								wrapper.device.trusted = true;
								wrapper.device.connect();
							}
						}
					}
				}

				Text {
					anchors.centerIn: parent
					visible: root.rows.length === 0
					text: !root.adapter ? "no Bluetooth adapter"
						: !root.adapter.enabled ? "press b to turn Bluetooth on"
						: root.adapter.discovering ? "scanning for devices…"
						: "no paired devices · press r to scan"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 14
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Layout.leftMargin: 10
				Layout.preferredHeight: 20
				spacing: 16

				KeyHint { shortcut: "↑↓"; description: "move" }
				KeyHint { shortcut: "↵"; description: "connect" }
				KeyHint { shortcut: "del"; description: "forget" }
				KeyHint { shortcut: "b"; description: "power" }
				KeyHint { shortcut: "r"; description: "scan" }
				Item { Layout.fillWidth: true }
			}
		}
	}
}
