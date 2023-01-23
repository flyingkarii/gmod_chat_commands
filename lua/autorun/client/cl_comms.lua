local function ProcessTextForPlaceholders(text, ...)
    local args = {...}
    local messageStart = 0
    local newText = text
    -- table looks like this: {placeholderId, placeholderValue}, {placeholderId, placeholderValue}

    for _, tbl in ipairs(args) do
        newText = newText:gsub("{" .. tbl[1] .. "}", tbl[2])

        if tbl[1] == "message" then
            messageStart = newText:find(tbl[2])
        end
    end

    return newText, messageStart
end

local function tblToColor(tbl)
    return Color(tbl.r, tbl.g, tbl.b, tbl.a)
end

net.Receive("comms_sendmessage", function(len, ply)
    local allowed = net.ReadBool()
    local colour = net.ReadColor()
    local group = net.ReadString()
    local sender = net.ReadString()
    local message = net.ReadString()

    if not allowed then
        chat.AddText(Comms.DeniedMessage["MessageColor"], Comms.DeniedMessage["Text"])
        return
    end 
    
    if Comms["CapitalizeAllCommNames"] then
        group = group:upper()
    end

    if Comms["UseColorForMessageColor"] then
        local text = ProcessTextForPlaceholders(Comms["MessageFormat"], {"commName", group}, {"sender", sender}, {"message", message})
        chat.AddText(colour, text)
    else
        local messageFormat = Comms["MessageFormat"]
        local newText, messageStart = ProcessTextForPlaceholders(messageFormat, {"commName", group}, {"sender", sender}, {"message", message})

        chat.AddText(colour or Comms["DefaultColor"], newText:sub(1, messageStart - 1), Color(255, 255, 255), newText:sub(messageStart, #newText))
    end
end)

net.Receive("comms_sendglobalmessage", function(len, ply)
    local color1 = net.ReadColor()
    local text1 = net.ReadString()
    local color2 = net.ReadColor()
    local text2 = net.ReadString()

    chat.AddText(color1, text1, color2 or Color(255, 255, 255), text2 or "")
end)