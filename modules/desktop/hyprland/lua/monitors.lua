hl.monitor({
    output = mainMonitor,
    mode = mainMode,
    position = mainPosition,
    scale = monitorScale,
})

hl.monitor({
    output = subMonitor,
    mode = subMode,
    position = subPosition,
    scale = monitorScale,
})

for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = mainMonitor,
        default = i == 1,
        persistent = true,
    })
end

for i = 6, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = subMonitor,
        default = i == 6,
        persistent = true,
    })
end
