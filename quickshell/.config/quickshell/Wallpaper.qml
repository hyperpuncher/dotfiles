import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Scope {
	id: root

	property url source
	property real barWidth: 38
	property int cornerRadius: 13

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: window

			required property var modelData
			screen: modelData

			anchors {
				top: true
				right: true
				bottom: true
				left: true
			}

			color: Theme.barBackground
			exclusionMode: ExclusionMode.Ignore
			mask: Region {}

			WlrLayershell.namespace: "quickshell-wallpaper"
			WlrLayershell.layer: WlrLayer.Background

			ClippingRectangle {
				x: root.barWidth
				width: parent.width - root.barWidth
				height: parent.height
				topLeftRadius: root.cornerRadius
				topRightRadius: root.cornerRadius
				bottomLeftRadius: root.cornerRadius
				bottomRightRadius: root.cornerRadius
				color: Theme.barBackground
				contentUnderBorder: true

				Image {
					x: -root.barWidth
					width: window.width
					height: window.height
					source: root.source
					fillMode: Image.PreserveAspectCrop
					asynchronous: true
					cache: true
					smooth: true
				}
			}
		}
	}
}
