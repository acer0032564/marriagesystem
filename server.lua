ESX = nil
local servermarry = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local discordLogs = function(msg, color)
	if Config.Discord.enable then
        PerformHttpRequest(Config.Discord.webhook, function(err, Content, Head) end, 'POST', json.encode({username = "Marriage System", embeds = {
            {
                ["color"] = color,
                ["title"] = "**Marriage System**",
                ["description"] = msg,
                ["footer"] = {
                    ["text"] = "",
                },
            }
        }, avatar_url = Config.Discord.imgURL}), {['Content-Type'] = 'application/json'})
    end
end

ESX.RegisterUsableItem('ring', function(source)
    local _source = source
    TriggerClientEvent("esx_marriage:CheckClosestPlayer", _source)
end)

ESX.RegisterUsableItem('unring', function(source)
    local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = GetPlayerIdentifier(_source)
    MySQL.Async.fetchAll("SELECT * FROM `marriages` WHERE husband = @husband OR wife = @wife", {['@husband'] = identifier, ['@wife'] = identifier}, function(result)
		if result[1] ~= nil then
			xPlayer.removeInventoryItem('unring', 1)
			if identifier == result[1].husband then --// xPlayer is husband
                local xXxPlayer = ESX.GetPlayerFromIdentifier(result[1].wife)
                if xXxPlayer then
					for i=1, #servermarry do
						if servermarry[i].husband == _source then
							table.remove(servermarry, i)
							break
						end
					end
					TriggerClientEvent("esx_marriage:removeservermarry", xPlayer.source)
					TriggerClientEvent("esx_marriage:removeservermarry", xXxPlayer.source)
                end
				MySQL.Async.fetchAll('SELECT name FROM users WHERE identifier = @identifier', {['@identifier'] = result[1].wife}, function(marryparner)
					text = "遺憾了! "..GetPlayerName(_source).." 和 "..marryparner[1].name.." 已離婚! 現在 "..GetPlayerName(_source)..' 需要安慰!'
					TriggerClientEvent('chat:addMessage', -1, {color = { 255, 0, 0},multiline = true,args = {"婚姻: ", text}})
					discordLogs("遺憾了! ".. GetPlayerName(_source) .. " 和 " .. marryparner[1].name .." 已離婚!", 15335424)
				end)
				MySQL.Sync.execute('DELETE FROM marriages WHERE husband = @husband',{['@husband'] = identifier})
            else --// xPlayer is wife ( probably )
				local xXxPlayer = ESX.GetPlayerFromIdentifier(result[1].husband)
                if xXxPlayer then
					for i=1, #servermarry do
						if servermarry[i].wife == _source then
							table.remove(servermarry, i)
							break
						end
					end
					TriggerClientEvent("esx_marriage:removeservermarry", xPlayer.source)
					TriggerClientEvent("esx_marriage:removeservermarry", xXxPlayer.source)
                end
				MySQL.Async.fetchAll('SELECT name FROM users WHERE identifier = @identifier', {['@identifier'] = result[1].husband}, function(marryparner)
					text = "遺憾了! ".. GetPlayerName(_source) .. " 和 " .. marryparner[1].name .." 已離婚! 現在 ".. GetPlayerName(_source) ..' 需要安慰!'
					TriggerClientEvent('chat:addMessage', -1, {color = { 255, 0, 0},multiline = true,args = {"婚姻: ", text}})
					discordLogs("遺憾了! ".. GetPlayerName(_source) .. " 和 " .. marryparner[1].name .." 已離婚!", 15335424)
				end)
				MySQL.Sync.execute('DELETE FROM marriages WHERE wife = @wife',{['@wife'] = identifier})
            end
		else
			TriggerClientEvent('chat:addMessage', _source, {color = { 255, 0, 0},multiline = true,args = {"婚姻: ", '你沒有結過婚!'} })
		end
	end)
end)

AddEventHandler('esx:playerDropped', function(playerId)
    local _source = playerId
	local xPlayer  = ESX.GetPlayerFromId(playerId)
    local identifier = GetPlayerIdentifier(_source)
    MySQL.Async.fetchAll("SELECT * FROM `marriages` WHERE husband = @husband OR wife = @wife", {['@husband'] = identifier, ['@wife'] = identifier}, function(result)
		if result[1] ~= nil then
			if identifier == result[1].husband then --// xPlayer is husband
                local xXxPlayer = ESX.GetPlayerFromIdentifier(result[1].wife)
                if xXxPlayer then
					for i=1, #servermarry do
						if servermarry[i].husband == _source then
							table.remove(servermarry, i)
							break
						end
					end
					TriggerClientEvent("esx_marriage:updateservermarry", xXxPlayer.source,nil)
					print(xPlayer.name .. 'quithusband')
                end
            else --// xPlayer is wife ( probably )
				local xXxPlayer = ESX.GetPlayerFromIdentifier(result[1].husband)
                if xXxPlayer then
					for i=1, #servermarry do
						if servermarry[i].wife == _source then
							table.remove(servermarry, i)
							break
						end
					end
					TriggerClientEvent("esx_marriage:updateservermarry", xXxPlayer.source,nil)
					print(xPlayer.name .. 'quitwife')
                end
            end
        end
    end)
end)

RegisterNetEvent("esx_marriage:foundPlayer")
AddEventHandler("esx_marriage:foundPlayer", function(proposedTo)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent("esx_marriage:sendProposal", proposedTo, xPlayer.name, xPlayer.source)
    xPlayer.removeInventoryItem('ring', 1)
end)

RegisterNetEvent("esx_marriage:checktest")
AddEventHandler("esx_marriage:checktest", function()
    checktest(source)
end)

function checktest(player)
	local _source = player
	local xPlayer  = ESX.GetPlayerFromId(source)
    local identifier = GetPlayerIdentifier(_source)
    MySQL.Async.fetchAll("SELECT * FROM `marriages` WHERE husband = @husband OR wife = @wife", {['@husband'] = identifier, ['@wife'] = identifier}, function(result)
        print(xPlayer.name .. '1')
		if result[1] ~= nil then
			if identifier == result[1].husband then --// xPlayer is husband
                local xXxPlayer = ESX.GetPlayerFromIdentifier(result[1].wife)
                if xXxPlayer then
					local repeatservermarry = false
					for i=1, #servermarry do
						if servermarry[i].husband == _source then
							repeatservermarry = true
							break
						end
					end
					if not repeatservermarry then
						table.insert(servermarry, {husband = _source, wife = xXxPlayer.source})
						TriggerClientEvent("esx_marriage:updateservermarry", xPlayer.source,xXxPlayer.source)
						TriggerClientEvent("esx_marriage:updateservermarry", xXxPlayer.source,xPlayer.source)
						print(xPlayer.name .. '2')
					end
                end
            else --// xPlayer is wife ( probably )
				local xXxPlayer = ESX.GetPlayerFromIdentifier(result[1].husband)
                if xXxPlayer then
					local repeatservermarry = false
					for i=1, #servermarry do
						if servermarry[i].wife == _source then
							repeatservermarry = true
							break
						end
					end
					if not repeatservermarry then
						table.insert(servermarry, {husband = xXxPlayer.source, wife = _source})
						TriggerClientEvent("esx_marriage:updateservermarry", xPlayer.source,xXxPlayer.source)
						TriggerClientEvent("esx_marriage:updateservermarry", xXxPlayer.source,xPlayer.source)
						print(xPlayer.name .. '3')
					end
                end
            end
			print(xPlayer.name .. '4')
            TriggerClientEvent("esx_marriage:setMarriageStatus", _source)
        end
    end)
end

RegisterNetEvent("esx_marriage:acceptedProposal")
AddEventHandler("esx_marriage:acceptedProposal", function(proposalOf) -- // proposalOf is the ID of the player the proposal was sent from.
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local target = ESX.GetPlayerFromId(proposalOf)
    local text = "恭喜啦! " .. GetPlayerName(_source) .. " 接受了你的求婚!"
    MySQL.Async.execute("INSERT INTO `marriages` SET husband = @husband, wife = @wife", { ['@husband'] = xPlayer.identifier, ['@wife'] = target.identifier }, function(res)
        TriggerClientEvent('chat:addMessage', proposalOf, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"婚姻: ", text}
        })

        text = "恭喜啦! 你已經接受了 ".. GetPlayerName(proposalOf) .." 的求婚!" 
        TriggerClientEvent('chat:addMessage', _source, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"婚姻: ", text}
        })
		
		text = "恭喜啦! ".. GetPlayerName(_source) .. " 和 " .. GetPlayerName(proposalOf) .." 已經成為合法夫婦!"
		discordLogs("恭喜啦! ".. GetPlayerName(_source) .. " 和 " .. GetPlayerName(proposalOf) .." 已經成為合法夫婦!", 47872)
		TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"婚姻: ", text}
        })
        TriggerClientEvent("esx_marriage:setMarriageStatus", xPlayer.source)
        TriggerClientEvent("esx_marriage:setMarriageStatus", target.source)
		table.insert(servermarry, {husband = xPlayer.source, wife = target.source})
		TriggerClientEvent("esx_marriage:updateservermarry", xPlayer.source, target.source)
		TriggerClientEvent("esx_marriage:updateservermarry", target.source, xPlayer.source)
    end)
end)

RegisterNetEvent("esx_marriage:declineProposal")
AddEventHandler("esx_marriage:declineProposal", function(proposalOf) -- // proposalOf is the ID of the player the proposal was sent from.
    local _source = source
    local text = "不好了, " .. GetPlayerName(_source) .. " 拒絕了你的求婚.."
    TriggerClientEvent('chat:addMessage', proposalOf, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"婚姻: ", text}
    })
    text = "你拒絕了 " .. GetPlayerName(proposalOf) .. "的求婚"
    TriggerClientEvent('chat:addMessage', _source, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"婚姻: ", text}
    })
end)

-- RegisterNetEvent('esx_marriage:textDrawReq')
-- AddEventHandler("esx_marriage:textDrawReq", function(player2)
    -- local _source = source
    -- TriggerClientEvent('esx_marriage:drawText', -1, player2, _source)
-- end)