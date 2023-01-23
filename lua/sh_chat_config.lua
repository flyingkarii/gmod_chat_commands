--[[
    UseColorForMessageColor: when false, uses white as the message text for comms.
    CapitalizeAllCommNames: when true, will capitalize all non-display names, so instead of [327th] its [327TH]
    MessageFormat: the message format of the communications. Placeholders available: 
        {commName}: The name or display name of the comm channel.
        {sender}: The sender of the communication message.
        {message}: The message the sender of the communication sent. If UseColorForMessageColor is on, uses comm channel color.
    DefaultColor: The default color of the messages and any communication without a color.
]]

Comms = Comms or {}

Comms.UseColorForMessageColor = false
Comms.CapitalizeAllCommNames = false
Comms.MessageFormat = "[{commName}] {sender}: {message}"
Comms.DefaultColor = Color(255, 255, 255)
Comms.DeniedMessage = {
    Enabled = true,
    Text = "You do not have access to these communications.",
    MessageColor = Color(255, 0, 0)
}


--[[
    just to note
    250 is darkrp default talk/me range
    550 is darkrp yell/voice range
    90 is darkrp whisper range

    Comms:
        TextColor: Color of the Comms text.
        MessageFormat: First %s is the player who sent it, the second %s is the message.
]]

Comms.Options = {
    RollHearDistance = 250,
    LocalRPDistance = 250, 

    GlobalCommsColor = Color(255, 235, 0),
    GlobalRPColor = Color(255, 166, 0),
    LocalRPColor = Color(255, 166, 0),
    MedicColor = Color(245, 91, 91),
    RFAColor = Color(255, 0, 0),

    RFACategories = { -- change when access is back
        ["Shock"] = true,
        ["High Command"] = true,
        ["SOBDE"] = true,
        ["Fleet"] = true
    }
}

--[[
    -- A command that sends a message to everyone. 
    chatcmd = {
        aliases = {"alias1", "alias2"}, 
        description = "A short description of the chat command.",
        prefixColor = Color(255, 0, 0),
        prefixMessage = "[TEST] {nick}: ",
        textColor = Color(255, 255, 255),
        text = "{message}",
    },

    -- A command that only sends a message to people within the range of distance multiplied by distance. TextColor is nil, so it will use prefixColor.
    localchatcmd = {
        description = "A short description of the chat command.",
        prefixColor = Color(255, 0, 0),
        prefixMessage = "[TEST] {nick}: ",
        text = "{message}",
        distance = 250,
    },

    -- Only sends the message to certain people alongside only having a certain Category have access. Also uses the player's team color.
    selectivechatcmd = {
        description = "A short description of the chat command.",
        canUse = {["High Command"] = true},
        canSee = {["High Command"] = true, ["Shock"] = true, function(ply) return ply:IsSuperAdmin() end}
        prefixColor = "teamcolor",
        prefixMessage = "[TEST] {nick}: ",
        text = "{message}",
    },
]]
Comms.ChatCommands = {
    comms = {
        enabled = true,
        aliases = {"c"},
        description = "Global communications.",
        prefixColor = Color(255, 235, 0),
        prefixMessage = "[COMMS] {nick}: ",
        textColor = Color(255, 255, 255),
        text = "{message}",
    },
    lrp = {
        enabled = true,
        description = "Locally do an action.",
        prefixColor = Color(255, 166, 0),
        prefixMessage = "[LOCAL ACT] {nick} ",
        text = "{message}",
        distance = 250
    },
    rp = {
        enabled = true,
        description = "Globally do an action.",
        prefixColor = Color(255, 166, 0),
        prefixMessage = "[ACT] {nick} ",
        text = "{message}",
        distance = 250
    },
    medic = {
        enabled = true,
        description = "Call for a medic.",
        prefixColor = Color(245, 91, 91),
        prefixMessage = "[MEDIC] {nick}: ",
        textColor = Color(255, 255, 255),
        text = "{message}",
    },
    rfa = {
        enabled = true,
        description = "State your reason for arresting someone.",
        canUse = {["Shock"] = true, ["High Command"] = true, ["SOBDE"] = true, ["Fleet"] = true},
        prefixColor = Color(255, 0, 0),
        prefixMessage = "[RFA] {nick}: ",
        textColor = Color(255, 255, 255),
        text = "{message}",
    },
    panic = {
        enabled = true,
        description = "Send a highly-encrypted panic message to fellow High Command, Shock, and 5th Fleet.",
        canUse = {["High Command"] = true},
        canSee = {
			["Citizens"] = true,
            ["High Command"] = true, 
            ["Shock"] = true, 
            ["5thlead"] = true, 
            ["5thheavy"] = true, 
            ["5thmedic"] = true, 
            ["5thtrooper"] = true, 
            ["5thcadet"] = true  
        },
        prefixColor = Color(153, 0, 255),
        prefixMessage = "[PANIC] {nick} pressed their panic button!",
    },
    roll = {
        enabled = true,
        description = "Roll a number from 1 to 100.",
        requiresArgs = false,
        prefixColor = Color(255, 0, 0),
        prefixMessage = "[Roll] ",
        textColor = Color(255, 255, 255),
        text = function(ply)
            return ply:Nick() .. " rolled " .. math.random(1, 100) .. "."
        end,
        distance = 250
    },
}

--[[

    index of table is the command name, so 327th, etc
    access is the table of who can access it. the index can be a category name or a job command
    color is the color of the comm group and player's name, but message color is dependent on Config.General.UseColorForMessage 
    optional: displayName is the name of the comm group that's put in chat. without this, it uses uppercase index

]]

Comms.Channels = {
    ["327th"] = {
        access = {
            ["327th Star Corps"] = true,
            ["High Command"] = true
        },
        color = Color(225, 255, 0)
    },
    ["shock"] = {
        displayName = "Shock",
        access = {
            ["Shock"] = true,
            ["High Command"] = true
        },
        color = Color(243, 0, 0)
    },
    ["501st"] = {
        access = {
            ["501st Legion"] = true,
            ["High Command"] = true
        },
        color = Color(0, 29, 255, 255)
    },
    ["212th"] = {
        access = {
            ["212th Attack Battalion"] = true,
            ["High Command"] = true
        },
        color = Color(255, 138, 0, 255)
    },
    ["sobde"] = {
        displayName = "SOBDE",
        access = {
            ["SOBDE"] = true,
            ["High Command"] = true
        },
        color = Color(139, 0, 0, 210)
    },
    ["hicom"] = {
        displayName = "HiCOM",
        access = {["High Command"] = true},
        color = Color(0, 39, 41, 42)
    }
}
