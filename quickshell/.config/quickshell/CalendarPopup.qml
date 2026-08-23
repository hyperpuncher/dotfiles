import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
	id: root

	property date currentDate: new Date()
	readonly property var weekdays: ["mo", "tu", "we", "th", "fr", "sa", "su"]
	readonly property var days: buildDays(currentDate)

	function buildDays(date): var {
		const year = date.getFullYear();
		const month = date.getMonth();
		const firstWeekday = (new Date(year, month, 1).getDay() + 6) % 7;
		const monthLength = new Date(year, month + 1, 0).getDate();
		const values = [];
		for (let index = 0; index < 42; index++) {
			const day = index - firstWeekday + 1;
			values.push(day >= 1 && day <= monthLength ? day : 0);
		}
		return values;
	}

	anchors {
		top: true
		left: true
	}
	margins {
		top: 0
		left: 30
	}

	implicitWidth: 256
	implicitHeight: 252
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	WlrLayershell.namespace: "quickshell-calendar"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

	Timer {
		interval: 60000
		running: true
		repeat: true
		onTriggered: root.currentDate = new Date()
	}

	PopupShadow { target: card }

	Rectangle {
		id: card
		x: 10
		y: 2
		width: 236
		height: 236
		color: Theme.surface
		radius: Theme.radius
		border.width: 1
		border.color: Theme.border

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 14
			spacing: 6

			Text {
				Layout.fillWidth: true
				Layout.preferredHeight: 24
				text: Qt.formatDateTime(root.currentDate, "MMMM yyyy").toLowerCase()
				color: Theme.text
				font.family: Theme.fontFamily
				font.pixelSize: 14
				font.weight: Font.Medium
			}

			GridLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				columns: 7
				columnSpacing: 2
				rowSpacing: 2

				Repeater {
					model: root.weekdays

					Text {
						required property string modelData
						Layout.fillWidth: true
						Layout.preferredHeight: 22
						text: modelData
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 10
						font.weight: Font.Medium
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}

				Repeater {
					model: root.days

					Rectangle {
						id: dayCell
						required property int modelData
						readonly property bool today: modelData > 0
							&& modelData === root.currentDate.getDate()
						Layout.fillWidth: true
						Layout.fillHeight: true
						radius: 6
						color: today ? Theme.selected : "transparent"

						Text {
							anchors.centerIn: parent
							text: dayCell.modelData > 0 ? String(dayCell.modelData) : ""
							color: dayCell.today ? Theme.selectedText : Theme.text
							font.family: Theme.fontFamily
							font.pixelSize: 11
							font.weight: dayCell.today ? Font.Medium : Font.Normal
						}
					}
				}
			}
		}
	}
}
