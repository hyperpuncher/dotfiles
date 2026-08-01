import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Wayland

PanelWindow {
	id: root

	property int selectedIndex: 0
	property bool enteringPassword: false
	property string password: ""
	property string statusText: ""
	readonly property var devices: Networking.devices.values
	readonly property var wifiDevices: devices.filter(device => device.type === DeviceType.Wifi)
	readonly property var wiredDevices: devices.filter(device => device.type === DeviceType.Wired)
	readonly property var rows: buildRows(wiredDevices, wifiDevices)
	readonly property int visibleRows: Math.min(7, rows.length)

	function buildRows(wired, wifi): var {
		const result = [];
		for (const device of wired) {
			if (device.network)
				result.push({ kind: "wired", name: device.network.name || device.name, device, network: device.network });
		}

		const seen = {};
		const networks = [];
		for (const device of wifi) {
			for (const network of device.networks.values) {
				if (!network.name)
					continue;
				const previous = seen[network.name];
				if (!previous || network.signalStrength > previous.signalStrength)
					seen[network.name] = network;
			}
		}
		for (const name of Object.keys(seen))
			networks.push(seen[name]);
		networks.sort((a, b) => Number(b.connected) - Number(a.connected)
			|| Number(b.known) - Number(a.known)
			|| b.signalStrength - a.signalStrength
			|| a.name.localeCompare(b.name));
		for (const network of networks)
			result.push({ kind: "wifi", name: network.name, device: network.device, network });
		return result;
	}

	function open(): void {
		selectedIndex = 0;
		enteringPassword = false;
		password = "";
		statusText = "";
		ShellState.resetPointerSelection();
		ShellState.open("network");
		for (const device of wifiDevices)
			device.scannerEnabled = true;
		Qt.callLater(() => keyHandler.forceActiveFocus());
	}

	function close(): void {
		for (const device of wifiDevices)
			device.scannerEnabled = false;
		password = "";
		enteringPassword = false;
		ShellState.close();
	}

	function moveSelection(delta: int): void {
		if (rows.length === 0)
			return;
		selectedIndex = (selectedIndex + delta + rows.length) % rows.length;
		resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
	}

	function selectedRow(): var {
		return selectedIndex >= 0 && selectedIndex < rows.length ? rows[selectedIndex] : null;
	}

	function activateSelected(): void {
		const row = selectedRow();
		if (!row)
			return;
		const network = row.network;
		statusText = "";
		if (network.connected) {
			network.disconnect();
		} else if (row.kind === "wired" || network.known || network.security === WifiSecurityType.Open) {
			network.connect();
		} else {
			password = "";
			enteringPassword = true;
		}
	}

	function submitPassword(): void {
		const row = selectedRow();
		if (!row || row.kind !== "wifi" || password.length === 0)
			return;
		row.network.connectWithPsk(password);
		password = "";
		enteringPassword = false;
	}

	function forgetSelected(): void {
		const row = selectedRow();
		if (row && row.kind === "wifi" && row.network.known && !row.network.connected)
			row.network.forget();
	}

	visible: ShellState.activePanel === "network"
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-network"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	onVisibleChanged: if (visible) open()
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

	Rectangle {
		id: card
		width: Math.min(600, root.width - 64)
		height: 92 + (root.enteringPassword ? 56 : 0) + Math.max(58, root.visibleRows * 58) + footer.height
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
				if (root.enteringPassword) {
					if (event.key === Qt.Key_Escape) {
						root.password = "";
						root.enteringPassword = false;
					} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
						root.submitPassword();
					} else if (event.key === Qt.Key_Backspace) {
						root.password = root.password.slice(0, -1);
					} else if (event.text.length === 1 && event.text.charCodeAt(0) >= 32
							&& !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
						root.password += event.text;
					} else {
						return;
					}
					event.accepted = true;
					return;
				}

				const ctrl = event.modifiers & Qt.ControlModifier;
				if (event.key === Qt.Key_Escape) {
					root.close();
				} else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K)) {
					root.moveSelection(-1);
				} else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J)) {
					root.moveSelection(1);
				} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					root.activateSelected();
				} else if (event.key === Qt.Key_Delete) {
					root.forgetSelected();
				} else if (event.key === Qt.Key_B) {
					Networking.wifiEnabled = !Networking.wifiEnabled;
				} else if (event.key === Qt.Key_R) {
					for (const device of root.wifiDevices) {
						device.scannerEnabled = false;
						device.scannerEnabled = true;
					}
				} else {
					return;
				}
				event.accepted = true;
			}
		}

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 15
			spacing: 10

			RowLayout {
				Layout.fillWidth: true
				Layout.preferredHeight: 34
				Layout.leftMargin: 10
				Layout.rightMargin: 10

				Text {
					text: "network"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 14
					font.weight: Font.Medium
				}

				Item { Layout.fillWidth: true }

				Text {
					text: root.wifiDevices.length === 0 ? "wired" : Networking.wifiEnabled ? "wifi on" : "wifi off"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 12
				}
			}

			Rectangle {
				visible: root.enteringPassword
				Layout.fillWidth: true
				Layout.preferredHeight: visible ? 46 : 0
				color: "transparent"
				radius: 8
				border.width: 1
				border.color: Theme.border

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 14
					anchors.rightMargin: 14

					Text {
						text: "password"
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 14
					}

					Text {
						Layout.fillWidth: true
						text: "•".repeat(root.password.length)
						color: Theme.text
						font.family: Theme.fontFamily
						font.pixelSize: 17
					}
				}
			}

			ListView {
				id: resultList
				Layout.fillWidth: true
				Layout.preferredHeight: Math.max(58, root.visibleRows * 58)
				clip: true
				model: root.rows
				currentIndex: root.selectedIndex
				boundsBehavior: Flickable.StopAtBounds

				delegate: Rectangle {
					id: row
					required property int index
					required property var modelData
					readonly property bool selected: index === root.selectedIndex
					readonly property var network: modelData.network
					width: ListView.view.width
					height: 58
					radius: 8
					color: selected ? Theme.selected : "transparent"

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 14
						anchors.rightMargin: 14
						spacing: 14

						Text {
							Layout.minimumWidth: 28
							Layout.maximumWidth: 28
							text: row.modelData.kind === "wired" ? "󰈀" : row.network.connected ? "󰖩" : "󰖪"
							color: row.selected ? Theme.selectedText : Theme.text
							font.family: "IosevkaTerm Nerd Font Mono"
							font.pixelSize: 20
							horizontalAlignment: Text.AlignHCenter
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 1

							Text {
								Layout.fillWidth: true
								text: row.modelData.name
								color: row.selected ? Theme.selectedText : Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 16
								font.weight: Font.Medium
								elide: Text.ElideRight
							}

							Text {
								Layout.fillWidth: true
								text: row.network.stateChanging ? "connecting" : row.network.connected ? "connected" : row.modelData.kind === "wired" ? "disconnected" : `${Math.round(row.network.signalStrength)}%${row.network.known ? "  saved" : ""}`
								color: row.selected ? Theme.selectedText : Theme.muted
								opacity: row.selected ? 0.65 : 1
								font.family: Theme.fontFamily
								font.pixelSize: 11
							}
						}

						Text {
							Layout.minimumWidth: 78
							Layout.maximumWidth: 78
							text: row.network.connected ? "↵ disconnect" : root.enteringPassword && row.selected ? "enter password" : "↵ connect"
							color: Theme.selectedText
							opacity: row.selected ? 0.55 : 0
							font.family: Theme.fontFamily
							font.pixelSize: 10
						}
					}

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onPositionChanged: mouse => {
							if (!root.enteringPassword && ShellState.pointerSelectionMoved(row.mapToItem(card, mouse.x, mouse.y)))
								root.selectedIndex = row.index;
						}
						onClicked: {
							root.selectedIndex = row.index;
							root.activateSelected();
						}
					}

					Connections {
						target: row.network
						function onConnectionFailed(reason): void {
							root.password = "";
							root.enteringPassword = false;
							root.statusText = ConnectionFailReason.toString(reason);
						}
					}
				}

				Text {
					anchors.centerIn: parent
					visible: root.rows.length === 0
					text: "no managed network devices"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 14
				}
			}

			RowLayout {
				id: footer
				Layout.fillWidth: true
				Layout.preferredHeight: 18
				Layout.leftMargin: 10
				spacing: 18

				Text { visible: root.statusText !== ""; text: root.statusText; color: Theme.error; font.family: Theme.fontFamily; font.pixelSize: 10 }
				KeyHint { visible: root.statusText === ""; shortcut: "↑↓"; description: "navigate" }
				KeyHint { shortcut: "↵"; description: "connect" }
				KeyHint { shortcut: "del"; description: "forget" }
				KeyHint { visible: root.wifiDevices.length > 0; shortcut: "b"; description: "wifi" }
				Item { Layout.fillWidth: true }
			}
		}
	}
}
