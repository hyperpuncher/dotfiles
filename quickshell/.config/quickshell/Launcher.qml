import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
	id: root

	property string query: ""
	property int selectedIndex: 0
	property var usage: ({})
	signal usageBumped(var updatedUsage)
	property var applications: []
	readonly property var shellActions: [
		{
			name: "Bluetooth",
			genericName: "connect and manage devices",
			comment: "keyboard-first Bluetooth controls",
			keywords: ["bluetooth", "headphones", "audio", "devices"],
			icon: "",
			shellIcon: "󰂯",
			shellPanel: "bluetooth"
		},
		{
			name: "Network",
			genericName: "connect and manage networks",
			comment: "keyboard-first wired and wifi controls",
			keywords: ["network", "wifi", "wireless", "ethernet", "internet"],
			icon: "",
			shellIcon: "󰖩",
			shellPanel: "network"
		},
		{
			name: "Audio",
			genericName: "control audio devices",
			comment: "keyboard-first PipeWire controls",
			keywords: ["audio", "sound", "volume", "speaker", "microphone", "pipewire"],
			icon: "",
			shellIcon: "󰕾",
			shellPanel: "audio"
		},
		{
			name: "Notifications",
			genericName: "notification history and controls",
			comment: "keyboard-first notification center",
			keywords: ["notifications", "history", "alerts", "do not disturb", "dnd"],
			icon: "",
			shellIcon: "󰂚",
			shellPanel: "notifications"
		}
	]
	readonly property var results: buildResults(query, applications)
	readonly property int visibleRows: Math.min(6, results.length)

	function searchableText(entry): string {
		return [entry.name, entry.genericName, entry.comment, entry.keywords.join(" ")]
			.join(" ")
			.toLowerCase();
	}

	function compact(value: string): string {
		return value.toLowerCase().replace(/[^a-z0-9]/g, "");
	}

	function fuzzySubsequence(haystack: string, needle: string): int {
		let position = 0;
		let gaps = 0;
		for (const character of needle) {
			const found = haystack.indexOf(character, position);
			if (found < 0)
				return -1;
			gaps += found - position;
			position = found + 1;
		}
		return 180 - gaps;
	}

	function score(entry, needle): int {
		const name = entry.name.toLowerCase();
		const compactName = compact(name);
		const compactNeedle = compact(needle);
		if (name === needle || compactName === compactNeedle)
			return 1000;
		if (name.startsWith(needle) || compactName.startsWith(compactNeedle))
			return 700 - name.length;

		const words = name.split(/[^a-z0-9]+/);
		if (words.some(word => word.startsWith(needle)))
			return 500 - name.length;
		if (name.includes(needle))
			return 300 - name.length;
		if (searchableText(entry).includes(needle))
			return 220 - name.length;
		return fuzzySubsequence(compact(searchableText(entry)), compactNeedle);
	}

	function usageKey(entry): string {
		return entry.shellPanel ? `shell:${entry.shellPanel}` : entry.id;
	}

	function usageCount(entry): int {
		return usage[usageKey(entry)] || 0;
	}

	function buildResults(filter, entries): var {
		const needle = filter.trim().toLowerCase();
		const matches = [];

		for (const entry of shellActions) {
			const rank = needle.length === 0 ? usageCount(entry) : score(entry, needle) + 50;
			if (rank >= 0)
				matches.push({ entry, rank, uses: usageCount(entry) });
		}

		for (const entry of entries) {
			const rank = needle.length === 0 ? usageCount(entry) : score(entry, needle);
			if (rank >= 0)
				matches.push({ entry, rank, uses: usageCount(entry) });
		}

		matches.sort((a, b) => {
			if (b.rank !== a.rank)
				return b.rank - a.rank;
			if (b.uses !== a.uses)
				return b.uses - a.uses;
			return a.entry.name.localeCompare(b.entry.name);
		});

		return matches;
	}

	function open(): void {
		query = "";
		selectedIndex = 0;
		ShellState.resetPointerSelection();
		ShellState.open("launcher");
		Qt.callLater(() => keyHandler.forceActiveFocus());
	}

	function close(): void {
		ShellState.close();
	}

	function moveSelection(delta: int): void {
		if (results.length === 0)
			return;
		selectedIndex = (selectedIndex + delta + results.length) % results.length;
		resultList.positionViewAtIndex(selectedIndex, ListView.Contain);
	}

	function launchSelected(): void {
		if (selectedIndex < 0 || selectedIndex >= results.length)
			return;
		const entry = results[selectedIndex].entry;
		const key = usageKey(entry);
		const updatedUsage = Object.assign({}, usage);
		updatedUsage[key] = (updatedUsage[key] || 0) + 1;
		usageBumped(updatedUsage);
		usageWriter.command = [`${Quickshell.shellDir}/scripts/launcher-usage`, "bump", key];
		usageWriter.running = false;
		usageWriter.running = true;
		if (entry.shellPanel) {
			ShellState.open(entry.shellPanel);
			return;
		}
		close();
		Quickshell.execDetached([
			"runapp",
			"--env", `DESKTOP_ENTRY_ID=${entry.desktopEntryId}`,
			"--env", `DESKTOP_ENTRY_NAME=${entry.name}`,
			"gio", "launch", entry.path
		]);
	}

	Process {
		id: usageWriter
	}

	visible: ShellState.activePanel === "launcher"
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	WlrLayershell.namespace: "quickshell-launcher"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	onVisibleChanged: {
		if (visible)
			open();
	}

	MouseArea {
		anchors.fill: parent
		onClicked: root.close()
	}

	Rectangle {
		id: card

		width: Math.min(600, root.width - 64)
		height: 30 + search.height + 10 + Math.max(54, root.visibleRows * 54) + footer.height
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
				} else if (event.key === Qt.Key_PageUp) {
					root.moveSelection(-6);
				} else if (event.key === Qt.Key_PageDown) {
					root.moveSelection(6);
				} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					root.launchSelected();
				} else if (event.key === Qt.Key_Backspace) {
					root.query = root.query.slice(0, -1);
					root.selectedIndex = 0;
				} else if (event.key === Qt.Key_U && ctrl) {
					root.query = "";
					root.selectedIndex = 0;
				} else if (event.text.length === 1 && event.text.charCodeAt(0) >= 32
						&& (event.modifiers === Qt.NoModifier || event.modifiers === Qt.ShiftModifier)) {
					root.query += event.text;
					root.selectedIndex = 0;
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

			Rectangle {
				id: search
				Layout.fillWidth: true
				Layout.preferredHeight: 48
				color: "transparent"
				radius: 8
				border.width: 1
				border.color: Theme.border

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 14
					anchors.rightMargin: 14
					spacing: 12

					Text {
						text: "apps"
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 17
						font.weight: Font.Medium
					}

					Item {
						Layout.fillWidth: true
						Layout.fillHeight: true

						Row {
							anchors.left: parent.left
							anchors.verticalCenter: parent.verticalCenter
							spacing: 2

							Text {
								text: root.query
								color: Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 17
							}

							Rectangle {
								anchors.verticalCenter: parent.verticalCenter
								width: 1
								height: 19
								color: Theme.text
								SequentialAnimation on opacity {
									running: root.visible
									loops: Animation.Infinite
									NumberAnimation { to: 0; duration: 550 }
									NumberAnimation { to: 1; duration: 550 }
								}
							}
						}
					}
				}
			}

			ListView {
				id: resultList
				Layout.fillWidth: true
				Layout.preferredHeight: Math.max(54, root.visibleRows * 54)
				clip: true
				spacing: 0
				model: root.results
				currentIndex: root.selectedIndex
				boundsBehavior: Flickable.StopAtBounds

				delegate: Rectangle {
					id: row

					required property int index
					required property var modelData
					readonly property var entry: modelData.entry
					readonly property bool selected: index === root.selectedIndex

					width: ListView.view.width
					height: 54
					radius: 8
					color: selected ? Theme.selected : "transparent"

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 12
						anchors.rightMargin: 12
						spacing: 12

						Rectangle {
							Layout.preferredWidth: 34
							Layout.preferredHeight: 34
							radius: 7
							color: row.selected ? Qt.rgba(0.5, 0.5, 0.5, 0.2) : Theme.surfaceRaised

							Image {
								id: appIcon
								anchors.centerIn: parent
								visible: !row.entry.shellIcon
								width: 24
								height: 24
								source: visible ? Quickshell.iconPath(row.entry.icon, "") : ""
								fillMode: Image.PreserveAspectFit
								asynchronous: true
								smooth: true
							}

							Text {
								anchors.centerIn: parent
								visible: !!row.entry.shellIcon || appIcon.status === Image.Error || row.entry.icon === ""
								text: row.entry.shellIcon || row.entry.name.slice(0, 1).toUpperCase()
								color: row.selected ? Theme.selectedText : Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 15
							}
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 1

							Text {
								Layout.fillWidth: true
								text: row.entry.name
								color: row.selected ? Theme.selectedText : Theme.text
								font.family: Theme.fontFamily
								font.pixelSize: 16
								font.weight: Font.Medium
								elide: Text.ElideRight
							}

							Text {
								Layout.fillWidth: true
								text: row.entry.genericName || row.entry.comment || "application"
								color: row.selected ? Theme.selectedText : Theme.muted
								opacity: row.selected ? 0.65 : 1
								font.family: Theme.fontFamily
								font.pixelSize: 11
								elide: Text.ElideRight
							}
						}

						Text {
							visible: row.selected
							text: "↵ launch"
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
							if (ShellState.pointerSelectionMoved(row.mapToItem(card, mouse.x, mouse.y)))
								root.selectedIndex = row.index;
						}
						onClicked: {
							root.selectedIndex = row.index;
							root.launchSelected();
						}
					}
				}

				Text {
					anchors.centerIn: parent
					visible: root.results.length === 0
					text: `no matches for “${root.query}”`
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

				KeyHint { shortcut: "↑↓"; description: "navigate" }
				KeyHint { shortcut: "↵"; description: "launch" }
				KeyHint { shortcut: "esc"; description: "close" }
				Item { Layout.fillWidth: true }
			}
		}
	}
}
