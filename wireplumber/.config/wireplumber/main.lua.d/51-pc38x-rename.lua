rule = {
    matches = {
        {
            { "device.name", "equals", "alsa_card.usb-FiiO_FiiO_BTR3K_ABCDEF0123456789-00" },
        },
        {
            { "node.name", "equals", "alsa_output.usb-FiiO_FiiO_BTR3K_ABCDEF0123456789-00.analog-stereo" },
        }

    },
    apply_properties = {
        ["device.description"] = "Sennheiser PC38X",
        ["device.nick"] = "Sennheiser PC38X",
        ["node.description"] = "Sennheiser PC38X",
        ["node.nick"] = "Sennheiser PC38X",
    },
}

table.insert(alsa_monitor.rules, rule)
