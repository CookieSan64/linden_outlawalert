-- ESX Framework Stuff ---------------------------------------------------------------
ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('linden_outlawalert:getCharData', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local identifier = xPlayer.getIdentifier()
	MySQL.Async.fetchAll('SELECT firstname, lastname, phone_number FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(results)
		cb(results[1])
	end)
end)

ESX.RegisterServerCallback('linden_outlawalert:isVehicleOwned', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT plate FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		if result[1] then
			cb(true)
		else
			cb(false)
		end
	end)
end)

-- ESX Framework Stuff ---------------------------------------------------------------
local name = ('%s %s'):format(firstname, lastname)
			local title = ('%s %s'):format(rank, lastname)
caller = name
info = title

function getCaller(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	return xPlayer.getName()
end

function getTitle(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	local title = ('%s %s'):format(xPlayer.job.grade_label, xPlayer.get('lastName'))
	return title
end

local dispatchCodes = {
	melee = { displayCode = '10-10', description = _U('melee'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 652, blipColour = 84, blipScale = 1.5 },
	officerdown = {displayCode = '10-99', description = _U('officerdown'), isImportant = 1, recipientList = {'police', 'ambulance', 'fbi'},
	blipSprite = 653, blipColour = 84, blipScale = 1.5, infoM = 'fa-portrait'},
	persondown = {displayCode = '10-52', description = _U('persondown'), isImportant = 0, recipientList = {'police', 'ambulance', 'fbi'},
	blipSprite = 153, blipColour = 84, blipScale = 1.5, infoM = 'fa-portrait'},
	autotheft = {displayCode = '10-16', description = _U('autotheft'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 651, blipColour = 84, blipScale = 1.5, infoM = 'fa-car', infoM2 = 'fa-palette' },
	atmrobbery = {displayCode = '10-64', description = _U('atmrobbery'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 651, blipColour = 84, blipScale = 1.5, infoM = 'fa-solid fa-piggy-bank', infoM2 = 'fa-palette' },
	speeding = {displayCode = '10-66', description = _U('speeding'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 650, blipColour = 84, blipScale = 1.5, infoM = 'fa-car', infoM2 = 'fa-palette' },
	shooting = { displayCode = '10-13', description = _U('shooting'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 648, blipColour = 84, blipScale = 1.5 },
	driveby = { displayCode = '10-13', description = _U('driveby'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 649, blipColour = 84, blipScale = 1.5, infoM = 'fa-car', infoM2 = 'fa-palette' },

	holdup = {displayCode = '10-64', description = _U('holdup'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 651, blipColour = 84, blipScale = 1.5, infoM = 'fa-solid fa-piggy-bank', infoM2 = 'fa-palette' },
	holdupbank = {displayCode = '10-64', description = _U('holdupbank'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 651, blipColour = 84, blipScale = 1.5, infoM = 'fa-solid fa-piggy-bank', infoM2 = 'fa-palette' },
	holdupfleeca = {displayCode = '10-64', description = _U('holdupfleeca'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 651, blipColour = 84, blipScale = 1.5, infoM = 'fa-solid fa-piggy-bank', infoM2 = 'fa-palette' },
	selldrug = {displayCode = '10-64', description = _U('selldrug'), isImportant = 0, recipientList = {'police', 'fbi'},
	blipSprite = 651, blipColour = 84, blipScale = 1.5, infoM = 'fa-solid fa-piggy-bank', infoM2 = 'fa-palette' },
}

--[[ Example custom alert
RegisterCommand('testvangelico', function(playerId, args, rawCommand)
	local data = {displayCode = '211', description = 'Robbery', isImportant = 0, recipientList = {'police'}, length = '10000', infoM = 'fa-info-circle', info = 'Vangelico Jewelry Store'}
	local dispatchData = {dispatchData = data, caller = 'Alarm', coords = vector3(-633.9, -241.7, 38.1)}
	TriggerEvent('wf-alerts:svNotify', dispatchData)
end, false)
--]]

local blacklistedIdentifiers = {
}

function Blacklisted()
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return false end
	local identifier = xPlayer.steamId
	for i = 1, #blacklistedIdentifiers do
		if identifier == blacklistedIdentifiers[i] then
			return true
		end
	end
	return false
end

RegisterServerEvent('wf-alerts:svNotify')
AddEventHandler('wf-alerts:svNotify', function(pData)
	if not Blacklisted(source) then
		local dispatchData
		if pData.dispatchCode == 'officerdown' then
			pData.info = getTitle(source)
		end
		if pData.dispatchCode == 'persondown' then
			pData.caller = getCaller(source)
		end
		if not pData.dispatchCode then dispatchData = pData.dispatchData elseif dispatchCodes[pData.dispatchCode] ~= nil then dispatchData = dispatchCodes[pData.dispatchCode] end
		if not pData.info then pData.info = dispatchData.info end
		if not pData.info2 then pData.info2 = dispatchData.info2 end
		if not pData.length then pData.length = dispatchData.length end
		pData.displayCode = dispatchData.displayCode
		pData.dispatchMessage = dispatchData.description
		pData.isImportant = dispatchData.isImportant
		pData.recipientList = dispatchData.recipientList
		pData.infoM = dispatchData.infoM
		pData.infoM2 = dispatchData.infoM2
		pData.sprite = dispatchData.blipSprite
		pData.colour = dispatchData.blipColour
		pData.scale = dispatchData.blipScale
		TriggerClientEvent('wf-alerts:clNotify', -1, pData)
		local n = [[
	]]
		local details = pData.dispatchMessage
		if pData.info then details = details .. n .. pData.info end
		if pData.info2 then details = details .. n .. pData.info2 end
		if pData.recipientList[1] == 'police' then TriggerEvent('mdt:newCall', details, pData.caller, vector3(pData.coords.x, pData.coords.y, pData.coords.z), false) end
	end
end)

RegisterServerEvent('wf-alerts:svNotify911')
AddEventHandler('wf-alerts:svNotify911', function(message, caller, coords)
	if message ~= nil then
		local pData = {}
		pData.displayCode = '911'
		if caller == _U('caller_unknown') then pData.dispatchMessage = _U('unknown_caller') else
		pData.dispatchMessage = _U('call_from') .. caller end
		pData.recipientList = {'police', 'ambulance', 'fbi'}
		pData.length = 13000
		pData.infoM = 'fa-phone'
		pData.info = message
		pData.coords = vector3(coords.x, coords.y, coords.z)
		pData.sprite, pData.colour, pData.scale =  480, 84, 2.0 -- radar_vip, blue
	local xPlayers = ESX.GetPlayers()
		for i= 1, #xPlayers do
			local source = xPlayers[i]
			local xPlayer = ESX.GetPlayerFromId(source)
			if xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'fbi' then
				TriggerClientEvent('wf-alerts:clNotify', source, pData)
			end
		end
		TriggerClientEvent('wf-alerts:clNotify', -1, pData) -- Send to all clients then check auth clientside?
		TriggerEvent('mdt:newCall', message, caller, vector3(coords.x, coords.y, coords.z), false)
	end
end)

-- VERSION CHECK
CreateThread(function()
	local resourceName = GetCurrentResourceName()
	local currentVersion, latestVersion = GetResourceMetadata(resourceName, 'version')
	local outdated = '^6[%s]^3 Version ^2%s^3 is available! You are using version ^1%s^7'
	Citizen.Wait(2000)
	while Config.CheckVersion do
		Citizen.Wait(0)
		PerformHttpRequest(GetResourceMetadata(resourceName, 'versioncheck'), function (errorCode, resultData, resultHeaders)
			if errorCode ~= 200 then print("Returned error code:" .. tostring(errorCode)) else
				local data, version = tostring(resultData)
				for line in data:gmatch("([^\n]*)\n?") do
					if line:find('^version') then version = line:sub(10, (line:len(line) - 1)) break end
				end		 
				latestVersion = version
			end
		end)
		if latestVersion then 
			if currentVersion ~= latestVersion then
				print(outdated:format(resourceName, latestVersion, currentVersion))
			end
			Citizen.Wait(60000*Config.CheckVersionDelay)
		end
	end
end)