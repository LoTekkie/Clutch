--[[
Copyright © 2019, Sjshovan (Apogee)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Clutch nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL  Sjshovan (Apogee) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local LSC = LibStub("LibSlashCommander")

if Clutch == nil then Clutch = {} end

Clutch.name = "Clutch"
Clutch.version = "0.9.0"
Clutch.author = "Sjshovan (Apogee)"
Clutch.contact = "Sjshovan@Gmail.com"
Clutch.description = "Clutch aims to prevent weapons from falling to the ground and grants the ability to pick them back up if they do."
Clutch.commands = {"/clutch", "/clch"}

Clutch.collectibles = {
    none = 0,
    hats = {
        hide_your_helm = 5002
    }
}

Clutch.colors = {
    info = "eeeeee",
    primary = "9ab3e5",
    secondary = "6c757d",
    success = "28a745",
    warning = "ffc107",
    danger = "dc3545",
}

local function cStr(color, str)
    return string.format("|c%s%s|r", color, str)
end

local function buildHelpEntryCommand(command, description)
    local addon_name = cStr(Clutch.colors.primary, "/"..string.lower(Clutch.name)) 
    local command = cStr(Clutch.colors.info, command)
    local description = cStr(Clutch.colors.info, description)
    local sep = cStr(Clutch.colors.primary, "=>")
    return string.format("%s %s %s %s", addon_name, command, sep, description)
end

local function buildHelpEntry(key, value)
    local key = cStr(Clutch.colors.info, key)
    local value = cStr(Clutch.colors.info, value)
    local sep = cStr(Clutch.colors.primary, "=>")
    return string.format("%s %s %s", key, sep, value)
end

local function buildHelpTitle(context)
    local context = cStr(Clutch.colors.info, context)
    local title = cStr(Clutch.colors.primary, string.format("%s Help:", Clutch.name))
    return string.format("%s %s", title, context)
end

local function buildHelpSeperator(character, count)
    local sep = ''
    for i = 1, count do
        sep = sep .. character
    end
    return cStr(Clutch.colors.secondary, sep)
end 

function Clutch.displayHelp(table_help)
     for index, command in pairs(table_help) do
        d(command)
    end
end 

function Clutch.clutchWeapons() 
    local collectible_hat_active = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
    
    if collectible_hat_active == Clutch.collectibles.none or collectible_hat_active == Clutch.collectibles.hats.hide_your_helm then
        UseCollectible(Clutch.collectibles.hats.hide_your_helm)
        UseCollectible(Clutch.collectibles.hats.hide_your_helm)
    else
        UseCollectible(Clutch.collectibles.hats.hide_your_helm)
        UseCollectible(collectible_hat_active)
    end
end

function Clutch.onBoundKeyPress()
    d(string.format("%s: %s", 
        cStr(Clutch.colors.primary, Clutch.name), 
        cStr(Clutch.colors.info, "Activated!")
    ))
    
    Clutch.clutchWeapons()
end

function Clutch.onPlayerActivated()
    if not Clutch.startup_info_displayed then
        d(string.format("%s %s %s", 
            cStr(Clutch.colors.primary, Clutch.name),
            cStr(Clutch.colors.info, string.format("v%s ~", Clutch.version)),           
            cStr(Clutch.colors.primary, Clutch.author)
        ))
        Clutch.startup_info_displayed = true
    end 
    
    Clutch.clutchWeapons()
end

function Clutch.onCommandEntered(args)
    if args == 'activate' or args == 'a' then
        Clutch.onBoundKeyPress()
        
    elseif args == 'info' or args == 'i' then
        Clutch.displayHelp(Clutch.help.info)
    
    elseif args == 'help' or args == 'h' then
        Clutch.displayHelp(Clutch.help.commands)
    
    else 
        Clutch.displayHelp(Clutch.help.commands)
    end
end

function Clutch.onAddonLoaded(eventCode, addonName)
    if addonName ~= Clutch.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(Clutch.name, EVENT_ADD_ON_LOADED)

    ZO_CreateStringId("SI_BINDING_NAME_CLUTCH_WEAPONS", "Clutch Weapons")
    
    LSC:Register(Clutch.commands, function(...) Clutch.onCommandEntered(...)  end, "Invoke the Clutch addon")
    
    Clutch.help = {
        commands = {
            buildHelpSeperator("=", 20),
            buildHelpTitle("Commands"),
            buildHelpSeperator('=', 20),
            buildHelpEntryCommand("[activate, a]",  "Activate Clutch and pick up your weapons."),
            buildHelpEntryCommand("[help, h]",  "Display Clutch commands."),
            buildHelpEntryCommand("[info, i]",  "Display information about Clutch."),
            buildHelpSeperator("=", 20),
        },
        info = {
            buildHelpSeperator("=", 14),
            buildHelpTitle("Info"),
            buildHelpSeperator('=', 14),
            buildHelpEntry("Name", Clutch.name),
            buildHelpEntry("Description", Clutch.description),
            buildHelpEntry("Author", Clutch.author),
            buildHelpEntry("Contact", Clutch.contact),
            buildHelpEntry("Version", Clutch.version),
            buildHelpSeperator('=', 14),
        }
    }
    
    EVENT_MANAGER:RegisterForEvent(Clutch.name, EVENT_PLAYER_ACTIVATED, Clutch.onPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(Clutch.name, EVENT_ADD_ON_LOADED, Clutch.onAddonLoaded)