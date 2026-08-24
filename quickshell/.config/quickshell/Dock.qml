import QtQuick
import Quickshell
import Quickshell.Wayland

Column {
	id: root

	width: 38
	spacing: 5

	readonly property var pinnedApps: [
		{ entryId: "foot", appIds: ["foot"] },
		{ entryId: "nemo", appIds: ["nemo"] },
		{ entryId: "helium", appIds: ["helium", "helium-browser"] },
		{ entryId: "org.telegram.desktop", appIds: ["org.telegram.desktop", "telegramdesktop"] },
		{ entryId: "spotify-launcher", appIds: ["spotify"] }
	]

	readonly property var dockItems: {
		const toplevels = ToplevelManager.toplevels.values;
		const items = [];

		for (const pinned of pinnedApps) {
			const matches = toplevels.filter(toplevel => root.matches(pinned, toplevel));
			const toplevel = matches.find(candidate => candidate.activated)
				|| matches.find(candidate => !candidate.minimized)
				|| matches[0]
				|| null;
			items.push({
				entry: DesktopEntries.byId(pinned.entryId),
				pinned,
				toplevel
			});
		}

		for (const toplevel of toplevels) {
			if (!toplevel.minimized || pinnedApps.some(pinned => root.matches(pinned, toplevel)))
				continue;
			items.push({
				entry: DesktopEntries.heuristicLookup(toplevel.appId),
				pinned: null,
				toplevel
			});
		}

		return items;
	}

	function matches(pinned, toplevel): bool {
		const appId = (toplevel.appId || "").toLowerCase();
		return pinned.appIds.some(candidate => appId === candidate || appId.includes(candidate));
	}

	function activate(item): void {
		if (item.toplevel) {
			if (item.toplevel.activated && !item.toplevel.minimized) {
				item.toplevel.minimized = true;
				return;
			}
			if (item.toplevel.minimized)
				item.toplevel.minimized = false;
			item.toplevel.activate();
			return;
		}
		if (item.entry)
			item.entry.execute();
	}

	Repeater {
		model: root.dockItems

		Item {
			id: app

			required property var modelData
			readonly property var entry: modelData.entry
			readonly property var toplevel: modelData.toplevel
			readonly property string label: entry
				? entry.name
				: (toplevel ? (toplevel.title || toplevel.appId) : "application")

			width: 38
			height: 32

			Rectangle {
				anchors.centerIn: parent
				width: 30
				height: 30
				radius: 8
				color: mouse.containsMouse ? "#24ffffff" : "transparent"
			}

			Image {
				id: icon
				anchors.centerIn: parent
				width: 23
				height: 23
				source: app.entry ? Quickshell.iconPath(app.entry.icon, "") : ""
				fillMode: Image.PreserveAspectFit
				sourceSize: Qt.size(46, 46)
				asynchronous: true
				smooth: true
				mipmap: false
				opacity: app.toplevel && app.toplevel.minimized ? 0.5 : 1
			}

			Text {
				anchors.centerIn: parent
				visible: icon.status === Image.Error || icon.source.toString() === ""
				text: app.label.slice(0, 1).toUpperCase()
				color: Theme.barText
				font.family: Theme.fontFamily
				font.pixelSize: 15
				font.weight: Font.Medium
				opacity: app.toplevel && app.toplevel.minimized ? 0.5 : 1
			}

			Rectangle {
				anchors.right: parent.right
				anchors.rightMargin: 1
				anchors.verticalCenter: parent.verticalCenter
				width: app.toplevel && app.toplevel.activated ? 3 : 2
				height: app.toplevel && app.toplevel.activated ? 16 : 4
				radius: width / 2
				visible: !!app.toplevel
				color: Theme.barText
				opacity: app.toplevel && app.toplevel.minimized ? 0.4 : 0.9
			}

			MouseArea {
				id: mouse
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.activate(app.modelData)
			}
		}
	}
}
