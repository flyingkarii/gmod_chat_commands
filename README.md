# Kari's Chat Channels and Commands

## Features

Easy to use chat channel commands. Able to add job categories as well as job commands to chat channel recipients. 
(Note that all of these commands are able to be changed in the config, but right now are made for an SWRP I used to develop for.)
Chat commands that do not accept blank input, all made through a config.
* /act [message] - Do an action globally. 
* /lact [message] - Do an action within the configured range.
* /comms [message] - A global communications channel that all players can see. This is able to be changed, just like any other chat command.
* /roll - Roll a number from 1 to 100.
* /medic [message] - Request a medic
* /rfa [message] - State your reason for arresting a player. 
* /panic [message] - Send a panic message to all enforcement-adjacent officers.

Example chat command:
```lua
panic = {
    enabled = true,
    description = "Send a highly-encrypted panic message to fellow High Command, Shock, and 5th Fleet.",
    canUse = {["High Command"] = true},
    canSee = {
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
```

Chat channels for inter-job and inter-category, as well as per-category and per-job communication. Multiple jobs and multiple categories can use the same command easily.
Currently includes:
* /327th [message] - Send a message to all 327th Star Corps category members if you are also in that category or in the High Command category.
* /212th [message] - Send a message to all 212th Attack Battalion category members if you are also in that category or in the High Command category.
* /510st [message] - Send a message to all 501st Legion category members if you are also in that category or in the High Command category.
* /shock [message] - Send a message to all Shock category members if you are also in that category or in the High Command category.
* /sobde [message] - Send a message to all SOBDE Star Corps category members if you are also in that category or in the High Command category.
* /hicom [message] - Send a message to all High Command if you are also in that category.

Example chat channel:
```lua
["hicom"] = {
    displayName = "HiCOM",
    access = {["High Command"] = true},
    color = Color(0, 39, 41, 42)
}
```
