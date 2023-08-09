rule = {
    matches = {
        {
            { "node.name", "equals", "alsa_input.pci-0000_09_00.4.analog-stereo" },
        }

    },
    apply_properties = {
        ["node.description"] = "Mic",
        ["node.nick"] = "Mic",
    },
}

table.insert(alsa_monitor.rules, rule)
