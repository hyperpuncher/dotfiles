pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

Singleton {
	id: root

	property bool doNotDisturb: false
	property bool popupStartupReady: false
	property var popupNotifications: []
	readonly property var history: server.trackedNotifications.values.filter(notification => !notification.transient).reverse()
	signal popupShown(var notification)

	onDoNotDisturbChanged: if (doNotDisturb) hideAllPopups()

	function showPopup(notification): void {
		const popups = popupNotifications.filter(item => item !== notification);
		popups.unshift(notification);
		popupNotifications = popups.slice(0, 4);
		for (const dropped of popups.slice(4))
			expirePopup(dropped);
		popupShown(notification);
	}

	function hidePopup(notification): void {
		popupNotifications = popupNotifications.filter(item => item !== notification);
	}

	function expirePopup(notification): void {
		hidePopup(notification);
		if (notification && notification.transient && notification.tracked)
			notification.expire();
	}

	function hideAllPopups(): void {
		for (const notification of popupNotifications.slice())
			expirePopup(notification);
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
				hidePopup(notification);
				action.invoke();
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
		hideAllPopups();
		for (const notification of history) {
			if (notification.tracked)
				notification.dismiss();
		}
	}

	function timeoutFor(notification): int {
		if (notification.expireTimeout === 0 || notification.urgency === NotificationUrgency.Critical)
			return 0;
		if (notification.expireTimeout > 0)
			return notification.expireTimeout;
		return notification.urgency === NotificationUrgency.Low ? 2000 : 4000;
	}

	Instantiator {
		model: server.trackedNotifications
		delegate: Scope {
			id: lifetime
			required property Notification modelData

			Timer {
				id: expiry
				interval: root.timeoutFor(lifetime.modelData)
				running: interval > 0 && root.popupNotifications.includes(lifetime.modelData)
				onTriggered: root.expirePopup(lifetime.modelData)
			}

			Connections {
				target: lifetime.modelData
				function onClosed(): void { root.hidePopup(lifetime.modelData); }
			}

			Connections {
				target: root
				function onPopupShown(notification): void {
					if (notification === lifetime.modelData && expiry.interval > 0)
						expiry.restart();
				}
			}
		}
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
			const show = root.popupStartupReady && !notification.lastGeneration && !root.doNotDisturb;
			notification.tracked = !notification.transient || show;
			if (show)
				root.showPopup(notification);
		}
	}
}
