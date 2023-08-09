rule = {
    matches = {
        {
            { "device.name", "equals", "alsa_card.pci-0000_09_00.4" },
        }

    },
    apply_properties = {
        ["device.description"] = "System Card",
        ["device.nick"] = "System Card",
    },
}

table.insert(alsa_monitor.rules, rule)
