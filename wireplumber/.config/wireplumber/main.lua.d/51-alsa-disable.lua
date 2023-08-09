rule = {
    matches = {
        -- display home
        {
            { "device.name", "equals", "alsa_card.pci-0000_07_00.1" },
        },
        {
            { "node.name", "equals", "alsa_output.pci-0000_09_00.4.iec958-stereo" },
        },
        -- display work
        {
            { "device.name", "equals", "alsa_card.pci-0000_07_00.1.3" },
        },
        -- system card work
        {
            { "device.name", "equals", "alsa_card.pci-0000_07_00.6" },
        }
    },
    apply_properties = {
        ["node.disabled"] = true,
        ["device.disabled"] = true,
    },
}

table.insert(alsa_monitor.rules, rule)
