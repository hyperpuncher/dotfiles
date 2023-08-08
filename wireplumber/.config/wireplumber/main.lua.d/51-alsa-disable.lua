rule = {
    matches = {
        {
            { "node.name", "equals", "alsa_output.pci-0000_07_00.1.hdmi-stereo-extra1" },
        },
    },
    apply_properties = {
        ["node.disabled"] = true,
    },
}

table.insert(alsa_monitor.rules, rule)
