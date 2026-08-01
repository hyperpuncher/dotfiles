pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

Singleton {
	id: root

	property bool doNotDisturb: false
	property bool popupStartupReady: false
	property var popupNotifications: []
	readonly property var history: server.trackedNotifications.values.slice().reverse()

	function showPopup(notification): void {
		const popups = popupNotifications.filter(item => item !== notification);
		popups.unshift(notification);
		popupNotifications = popups.slice(0, 4);
	}

	function hidePopup(notification): void {
		popupNotifications = popupNotifications.filter(item => item !== notification);
	}

	function dismiss(notification): void {
		hidePopup(notification);
		if (notification && notification.tracked)
			notification.dismiss();
	}

	function activate(notification): void {
		if (!notification)
			return;
		for (const action of notification.actions) {
			if (action.identifier === "default") {
				action.invoke();
				dismiss(notification);
				return;
			}
		}

		const names = [notification.desktopEntry, notification.appName]
			.filter(name => name)
			.map(name => name.toLowerCase().replace(/\.desktop$/, ""));
		for (const toplevel of ToplevelManager.toplevels.values) {
			const values = [toplevel.title, toplevel.appId]
				.filter(value => value)
				.map(value => value.toLowerCase());
			if (names.some(name => values.some(value => value === name))) {
				toplevel.activate();
				dismiss(notification);
				return;
			}
		}

		const entry = notification.desktopEntry
			? DesktopEntries.byId(notification.desktopEntry)
			: DesktopEntries.heuristicLookup(notification.appName);
		if (entry)
			entry.execute();
		dismiss(notification);
	}

	function clear(): void {
		popupNotifications = [];
		for (const notification of history) {
			if (notification.tracked)
				notification.dismiss();
		}
	}

	function timeoutFor(notification): int {
		if (notification.urgency === NotificationUrgency.Critical)
			return 0;
		if (notification.expireTimeout > 0)
			return Math.max(1000, notification.expireTimeout);
		return notification.urgency === NotificationUrgency.Low ? 2000 : 4000;
	}

	Timer {
		interval: 1500
		running: true
		onTriggered: root.popupStartupReady = true
	}

	NotificationServer {
		id: server
		keepOnReload: true
		persistenceSupported: true
		bodySupported: true
		bodyMarkupSupported: false
		bodyHyperlinksSupported: false
		bodyImagesSupported: false
		actionsSupported: true
		actionIconsSupported: false
		imageSupported: true
		inlineReplySupported: false

		onNotification: notification => {
			notification.tracked = true;
			if (root.popupStartupReady && !notification.lastGeneration && !root.doNotDisturb)
				root.showPopup(notification);
		}
	}
}
