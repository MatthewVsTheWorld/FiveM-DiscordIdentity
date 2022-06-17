function onResourceStart(resourceName)
	if (GetCurrentResourceName() == resourceName) then
		PlayerList:load()
	end
end

RegisterNetEvent('onResourceStart')
AddEventHandler(
	'onResourceStart',
	onResourceStart
)


local nameFilterTable = {
    ["~r~"] = "",
    ["~g~"] = "",
    ["~o~"] = "",
    ["~b~"] = "",
    ["~m~"] = "",
    ["~p~"] = "",
    ["Owner"] = "Pleb",
    ["owner"] = "pleb",
    ["Admin"] = "Pleb",
    ["admin"] = "pleb",
    ["^"] = "",
}


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



RegisterServerEvent('mvtwDiscordIdentity:getData')
AddEventHandler('mvtwDiscordIdentity:getData', function(playerID)

    local name = exports.DiscordWhitelist.getName(playerID,playerID)
    local roles = exports.DiscordWhitelist.getRoles(playerID,playerID)

    local results = {name,roles}

    if playerID and name then
        PlayerList:addPlayer(playerID, name)
    end
    

    TriggerClientEvent('mvtwDiscordIdentity:getDataCallback', playerID, results)

end)



RegisterServerEvent('mvtwDiscordIdentity:sendMessage')
AddEventHandler('mvtwDiscordIdentity:sendMessage', function(source,playerName,colour,tag, Msg, fallbackName)

    local name 

    if playerName then
        name = playerName
    else
        name = fallbackName
    end

    for k,v in pairs(nameFilterTable) do
        name = string.gsub(name, k, v)
    end

    TriggerClientEvent('chatMessage', -1, tag .. name, colour, Msg)

end)





AddEventHandler('chatMessage', function(Source, Name, Msg)


    args = stringsplit(Msg, " ")
    CancelEvent()
    if string.find(args[1], "/") then
        local cmd = args[1]
        table.remove(args, 1)
    else    

        TriggerClientEvent('mvtwDiscordIdentity:getChatData', Source,Msg, Name)

    end
        
end)




function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end


function PlayerList:addPlayer(serverId, discordName)

    local name

    if discordName.nickname then
        name = discordName.nickname
    else
        name = discordName.username
    end
    self.config[tostring(serverId)] = name
    PlayerList:save()

end

function PlayerList:removePlayer(serverId, discordName)
	if discordName then
		self.config[serverId] = nil
		PlayerList:save()
	end
	if serverId then
		self.players[serverId] = nil
	end
end

function PlayerList:load()
	local whitelistFile = loadData("discord_players")
	if whitelistFile ~= nil then
		self.config = whitelistFile
	else
		saveData({}, "discord_players")
	end
end

function PlayerList:save()
	saveData(self.config, "discord_players")
end


function saveData(data, keyword)
	if type(keyword) ~= "string" then
		return
	end
	SaveResourceFile(GetCurrentResourceName(), keyword .. ".json", json.encode(data), -1)
end

function loadData(keyword)
	local fileContents = LoadResourceFile(GetCurrentResourceName(), keyword .. ".json")
	return fileContents and json.decode(fileContents) or nil
end