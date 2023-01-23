util.AddNetworkString("comms_sendmessage")
util.AddNetworkString("comms_sendglobalmessage")

local function ProcessPlaceholder(ply, raw, message)
    local placeholders = {
        ["name"] = ply:Name(),
        ["nick"] = ply:Nick(),
        ["message"] = message
    }
    
    local result = raw

    for key, value in pairs(placeholders) do
        result = result:gsub("{" .. key .. "}", value)
    end

    return result
end

local function HasAccess(ply, needs)
    if needs[RPExtraTeams[ply:Team()].category] then
        return true
    elseif needs[RPExtraTeams[ply:Team()].command] ~= nil then
        return true
    else
        return false
    end
end

local function GetAuthorized(needs)
    local result = {}

    for i, ply in ipairs(player.GetHumans()) do
        if HasAccess(ply, needs) then
            table.insert(result, ply)
        end
    end

    return result
end

local function SendError(ply, msg)
    net.Start("comms_sendglobalmessage")

        net.WriteColor(Color(255, 0, 0))
        net.WriteString("[ERROR] ")

        net.WriteColor(Color(255, 255, 255))
        net.WriteString(msg)

    net.Send(ply)
    return ""
end

local function Check(ply, value)
    if value then
        if type(value) == "function" then
            return value(ply)
        elseif type(value) == "table" then
            return HasAccess(ply, value)
        else
            return true
        end
    else
        return true
    end
end

local function ProcessText(ply, value)
    if type(value) == "function" then
        return value(ply)
    elseif type(value) == "string" then
        return value
    else
        return
    end
end

local function SendMessage(recipients, prefixColor, prefixText, textColor, text)
    net.Start("comms_sendglobalmessage")

    net.WriteColor(prefixColor)
    net.WriteString(prefixText)
    net.WriteColor(textColor)
    net.WriteString(text)

    net.Send(recipients)
end

local function GetChatCmdRecipients(ply, distance, canSee)
    local recipients = {}

    for _, receiver in ipairs(player.GetHumans()) do
        if distance and distance > 0 then
            if receiver:GetPos():DistToSqr(ply:GetPos()) > (distance * distance) then
                continue 
            end
        end

        if Check(ply, canSee) then
            table.insert(recipients, receiver)
        end
    end

    return recipients
end

for cmd, data in pairs(Comms.ChatCommands) do
    for _, alias in ipairs(data.aliases or {}) do
        Comms.ChatCommands[alias] = data
    end
end

hook.Add( "PlayerSay", "comms_channels", function(sender, text, teamChat) 
    local split = string.Split(text, " ")
    local name = split[1]:sub(2, #split[1]):lower()
    local teamGroup = Comms.Channels[name]
    local message = ""

    for index, word in ipairs(split) do
        if index >= 2 then
            message = message .. " " .. word
        end
    end

    if teamGroup == nil then
        return
    end
    
    if message == "" then
        return SendError(sender, "You must input a message.")
    end

    if HasAccess(sender, teamGroup.access) then
        local recipients = GetAuthorized(teamGroup.access)  
        net.Start("comms_sendmessage")
        net.WriteBool(true)
        net.WriteColor(teamGroup.color or Comms.General['DefaultColor'])
        net.WriteString(teamGroup.displayName or name)
        net.WriteString(sender:GetName())
        net.WriteString(message:sub(2, #message))
        net.Send(recipients)

        return ""
    else
        net.Start("comms_sendmessage")
        net.WriteBool(false)
        net.Send(sender)

        return ""
    end
end)

hook.Add("PlayerSay", "comms_rpcmds", function(sender, text, teamChat)
    local split = string.Split(text, " ")
    local name = split[1]:sub(2, #split[1]):lower()
    local message = ""

    for index, word in ipairs(split) do
        if index == 2 then
            message = word
        elseif index > 2 then
            message = message .. " " .. word
        end
    end

    if split[1]:sub(1, 1) ~= "/" then
        return
    end

    if not Comms.ChatCommands[name] then
        return
    end

    local cmdData = Comms.ChatCommands[name]
    local description = cmdData.description or "No description available."
    local requiresArgs = cmdData.requiresArgs
    local canUse = Check(sender, cmdData.canUse)
    local prefixColor = cmdData.prefixColor or Color(255, 255, 255)
    local prefixText = cmdData.prefixMessage or ""
    local textColor = cmdData.textColor or prefixColor or Color(255, 255, 255)
    local text = ProcessText(sender, cmdData.text) or ""
    local distance = cmdData.distance or nil

    if not cmdData.enabled then
        SendError(sender, name:upper() .. " is not enabled.")
        return ""
    end

    if prefixColor == "teamcolor" then
        prefixColor = team.GetColor(sender:Team())
    end

    if textColor == "teamcolor" then
        textColor = team.GetColor(sender:Team())
    end

    if requiresArgs == true and message == "" then
        SendError(sender, "You must input a message.")
        return ""
    end

    if not canUse then
        SendError(sender, "You do not have access to these communications.")
        return ""
    end

    local recipients = GetChatCmdRecipients(sender, distance, cmdData.canSee)
    prefixText = ProcessPlaceholder(sender, prefixText, message)
    text = ProcessPlaceholder(sender, text, message)

    SendMessage(recipients, prefixColor, prefixText, textColor, text)
    return ""
end)