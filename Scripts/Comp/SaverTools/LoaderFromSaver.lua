savers = comp:GetToolList(true, 'Saver')

function Set(list)
    local set = {}
    for _, element in ipairs(list) do
        set[element] = true
    end
    return set
end

function place_loader(name, tool)
    local flow = comp.CurrentFrame.FlowView
    x, y = flow:GetPos(tool)
    -- local loader = comp:Loader({ Clip = name })
    local loader = comp:AddTool("Loader")
    loader.Clip = name
    flow:SetPos(loader, x+.5, y+1)
    inputs = tool.Output:GetConnectedInputs()
    for i, input in ipairs(inputs) do
        input:ConnectTo(loader.Output)
    end
end


if (#savers) == 0 then
    print('select some savers')
else
    comp:Lock()
    -- comp:StartUndo('loader from saver script')
    for _, tool in ipairs(savers) do
        selected_clipname = tool:GetAttrs()["TOOLST_Clip_Name"][1]
        seq = string.match(selected_clipname, '(%d+)%..+$')
        -- if pattern 0000.ext$ is found set selected name
        -- otherwice replace extention with 0000-extention
        if seq then
            place_loader(selected_clipname, tool)
        else
            name, ext = string.match(selected_clipname,'([^/]-([^.]+))$')
            local file_exts = Set{'mp4', 'mov', 'avi', 'mxf'}
            -- if saver file format is container, use original name
            if file_exts[ext] then
                place_loader(selected_clipname, tool)
            -- append zero padding for sequence filename 
            else
                local new_name = selected_clipname:gsub('.'..ext, '0000.'..ext)
                place_loader(new_name, tool)
            end
        end
    end
    -- comp:EndUndo()
    comp:Unlock()
end

