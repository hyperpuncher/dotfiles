rule = {
    matches = {
        {
            { "device.name", "equals", "alsa_card.pci-0000_07_00.1" },
        },
        {
            { "node.name", "equals", "alsa_output.pci-0000_09_00.4.iec958-stereo" },
        }
    },
    apply_properties = {
        ["node.disabled"] = true,
        ["device.disabled"] = true,
    },
}

table.insert(alsa_monitor.rules, rule)
