import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import Quickshell.Widgets

Scope {
	id: root

	property string failureMessage: ""

	function clearResponse(): void {
		response.text = "";
	}

	function focusResponse(): void {
		if (window.visible && agent.flow && agent.flow.isResponseRequired)
			Qt.callLater(() => response.forceActiveFocus());
	}

	function submit(): void {
		if (!agent.flow || !agent.flow.isResponseRequired || response.text.length === 0)
			return;
		const value = response.text;
		response.text = "";
		failureMessage = "";
		agent.flow.submit(value);
	}

	function cancel(): void {
		clearResponse();
		failureMessage = "";
		if (agent.flow)
			agent.flow.cancelAuthenticationRequest();
	}

	PolkitAgent {
		id: agent
		onAuthenticationRequestStarted: {
			root.clearResponse();
			root.failureMessage = "";
			root.focusResponse();
		}
		onFlowChanged: {
			root.clearResponse();
			root.failureMessage = "";
			root.focusResponse();
		}
	}

	Connections {
		target: agent.flow
		ignoreUnknownSignals: true

		function onIsResponseRequiredChanged(): void {
			if (agent.flow && agent.flow.isResponseRequired)
				root.focusResponse();
		}

		function onAuthenticationFailed(): void {
			root.clearResponse();
			root.failureMessage = "incorrect password or authentication was denied"
			root.focusResponse();
		}

		function onAuthenticationSucceeded(): void {
			root.clearResponse();
		}

		function onAuthenticationRequestCancelled(): void {
			root.clearResponse();
		}
	}

	PanelWindow {
		id: window
		visible: agent.isActive && agent.flow !== null
		color: "transparent"
		exclusionMode: ExclusionMode.Ignore

		anchors {
			top: true
			right: true
			bottom: true
			left: true
		}

		WlrLayershell.namespace: "quickshell-polkit"
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

		onVisibleChanged: {
			if (visible)
				root.focusResponse();
			else
				root.clearResponse();
		}

		Rectangle {
			anchors.fill: parent
			color: Theme.scrim
			opacity: window.visible ? 1 : 0
			Behavior on opacity { NumberAnimation { duration: 50; easing.type: Easing.OutQuad } }
		}

		PopupShadow { target: card }

		Rectangle {
			id: card
			width: Math.min(480, window.width - 64)
			height: content.implicitHeight + 36
			anchors.centerIn: parent
			color: Theme.surface
			radius: Theme.radius
			border.width: 1
			border.color: Theme.border

			ColumnLayout {
				id: content
				anchors {
					left: parent.left
					right: parent.right
					top: parent.top
					margins: 18
				}
				spacing: 12

				RowLayout {
					Layout.fillWidth: true
					spacing: 12

					IconImage {
						Layout.preferredWidth: 32
						Layout.preferredHeight: 32
						source: agent.flow && agent.flow.iconName
							? Quickshell.iconPath(agent.flow.iconName, "")
							: Quickshell.iconPath("dialog-password-symbolic", "")
						mipmap: false
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: 2

						Text {
							Layout.fillWidth: true
							text: "authentication required"
							color: Theme.text
							font.family: Theme.fontFamily
							font.pixelSize: 15
							font.styleName: "Medium"
						}

						Text {
							Layout.fillWidth: true
							text: agent.flow && agent.flow.selectedIdentity
								? agent.flow.selectedIdentity.displayName
								: ""
							visible: text !== ""
							color: Theme.muted
							font.family: Theme.fontFamily
							font.pixelSize: 11
						}
					}
				}

				Text {
					Layout.fillWidth: true
					text: agent.flow ? agent.flow.message : ""
					color: Theme.text
					font.family: Theme.fontFamily
					font.pixelSize: 12
					wrapMode: Text.Wrap
					textFormat: Text.PlainText
				}

				Text {
					Layout.fillWidth: true
					text: root.failureMessage || (agent.flow ? agent.flow.supplementaryMessage : "")
					visible: text !== ""
					color: root.failureMessage !== "" || (agent.flow && agent.flow.supplementaryIsError) ? Theme.error : Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: 11
					wrapMode: Text.Wrap
					textFormat: Text.PlainText
				}

				Rectangle {
					Layout.fillWidth: true
					Layout.preferredHeight: 42
					color: Theme.input
					radius: 7
					border.width: response.activeFocus ? 1 : 0
					border.color: Theme.borderStrong

					TextInput {
						id: response
						anchors {
							fill: parent
							leftMargin: 12
							rightMargin: 12
						}
						verticalAlignment: TextInput.AlignVCenter
						enabled: agent.flow && agent.flow.isResponseRequired
						echoMode: agent.flow && agent.flow.responseVisible ? TextInput.Normal : TextInput.Password
						passwordCharacter: "•"
						color: Theme.text
						selectionColor: Theme.selection
						selectedTextColor: Theme.selectedText
						font.family: Theme.fontFamily
						font.pixelSize: 13
						selectByMouse: true
						onAccepted: root.submit()

						Keys.onEscapePressed: event => {
							root.cancel();
							event.accepted = true;
						}
					}

					Text {
						anchors {
							left: parent.left
							right: parent.right
							verticalCenter: parent.verticalCenter
							leftMargin: 12
							rightMargin: 12
						}
						visible: response.text.length === 0
						text: agent.flow && agent.flow.isResponseRequired
							? (agent.flow.inputPrompt || "password")
							: "waiting for authentication service"
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: 12
					}
				}

				RowLayout {
					Layout.fillWidth: true
					Layout.preferredHeight: 20
					Layout.leftMargin: 2
					spacing: 18

					KeyHint { shortcut: "↵"; description: "authenticate" }
					KeyHint { shortcut: "esc"; description: "cancel" }
					Item { Layout.fillWidth: true }
				}
			}
		}
	}
}
