import Quickshell
import Quickshell.Wayland

Scope {
	IdleMonitor {
		timeout: 900
		respectInhibitors: true
		onIsIdleChanged: Quickshell.execDetached([
			`${Quickshell.shellDir}/scripts/set-dpms`,
			isIdle ? "off" : "on"
		])
	}
}
