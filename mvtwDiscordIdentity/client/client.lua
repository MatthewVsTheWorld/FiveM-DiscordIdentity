
local discordNickname 
local discordRoles = {}
local chatColour = {50, 42, 191}
local chatTag = '[Guest] '
local hasDiscordName = false

PlayerList = {
	players = {},
	config = {},
	__index = self,
	init = function(object)
		object = object or {players = {}, config = {}}
		setmetatable(object, self)
		return object
	end
}



Citizen.CreateThread(function ()
    TriggerServerEvent('mvtwDiscordIdentity:getData',   GetPlayerServerId(PlayerId()))
end)

Citizen.CreateThread(function()

    local id = PlayerId()
    
    while true do
    
        Citizen.Wait(1)
    
        DisablePlayerVehicleRewards(id)
    
    end
 end)


RegisterNetEvent('mvtwDiscordIdentity:getDataCallback')
AddEventHandler('mvtwDiscordIdentity:getDataCallback', function(results)

    local name = results[1]
    local roles = results[2]

    if name.nickname then
        discordNickname = name.nickname
    else
        discordNickname = name.username
    end

    discordRoles = roles

   if has_value(discordRoles, '973638245881614336') then --  Member 
        chatColour = {255, 255, 255}
        chatTag = ''
    end 

    if has_value(discordRoles, '974024680639975476') then -- Top Fan  
        chatColour = {219, 206, 26}
        chatTag = ''
    end 

    if has_value(discordRoles, '974024262224592896') then -- Moderator
        chatColour = {219, 206, 26}
        chatTag = ''
    end 

    if has_value(discordRoles, '974022612214763551') then -- Nitro Booster
        chatColour = {219, 3, 252}
        chatTag = ''
    end 

    if has_value(discordRoles, '974024314577895424') then -- Admin
        chatColour = {250, 25, 66}
    end 



    if discordNickname then
        hasDiscordName = true
    end

end)


RegisterNetEvent('mvtwDiscordIdentity:getChatData')
AddEventHandler('mvtwDiscordIdentity:getChatData', function(Msg, Name)

    TriggerServerEvent('mvtwDiscordIdentity:sendMessage',-1, discordNickname, chatColour, chatTag, Msg, Name )

end)




exports("getPlayerName",function(playerId)
    return PlayerList:check(playerId)
end)

exports("discordRoles",function(playerId)
    return discordRoles
end)

exports("discordNickname",function(playerId)
        return discordNickname
end)


exports("discordColour",function()
   return chatColour
end)


function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function PlayerList:check(serverId)
	return self.config[tostring(serverId)]
end

function PlayerList:load()
	local whitelistFile = loadData("discord_players")
	if whitelistFile ~= nil then
		self.config = whitelistFile
	end
end

function loadData(keyword)
	local fileContents = LoadResourceFile(GetCurrentResourceName(), keyword .. ".json")
	return fileContents and json.decode(fileContents) or nil
end

PlayerList:load()