ESX              = nil
local isProposedTo = false
local ProposedBy = nil

local isMarried = false
local myMarriage = nil

local defaultScale = 0.5 -- Text scale
local color = { r = 230, g = 230, b = 230, a = 255 } -- Text color
local font = 0 -- Text font
local distToDraw = 250 -- Min. distance to draw 

-- --------------------------------------------
-- Variable
-- --------------------------------------------

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
	if ESX.IsPlayerLoaded() then
		TriggerServerEvent("esx_marriage:checktest")
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler("esx:playerLoaded", function()
	TriggerServerEvent("esx_marriage:checktest")
end)

RegisterNetEvent("esx_marriage:CheckClosestPlayer")
AddEventHandler("esx_marriage:CheckClosestPlayer", function()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer ~= -1 and closestDistance <= 3.0 then
		TriggerServerEvent("esx_marriage:foundPlayer", GetPlayerServerId(closestPlayer))
	else
		TriggerEvent('chat:addMessage', {
			color = { 255, 0, 0},
			multiline = true,
			args = {"婚姻: ", "身邊沒有人.."}
		})
	end

end)

RegisterNetEvent("esx_marriage:setMarriageStatus")
AddEventHandler('esx_marriage:setMarriageStatus', function()
	isMarried = true
end)

RegisterNetEvent("esx:onPlayerLogout")
AddEventHandler("esx:onPlayerLogout", function()
	isMarried = false
	myMarriage = nil
end)

RegisterNetEvent("esx_marriage:sendProposal")
AddEventHandler("esx_marriage:sendProposal", function(name,proposedBy) -- proposedBy is the server id of the player who sent the proposal.
	local text = name .. " 向你求婚. 按E接受/ Y拒絕"
	ESX.ShowHelpNotification(text, false, true, 10000)
	isProposedTo = true
	ProposedBy = proposedBy
end)

RegisterNetEvent("esx_marriage:updateservermarry")
AddEventHandler("esx_marriage:updateservermarry", function(servermarry)
	myMarriage = servermarry
end)

RegisterNetEvent("esx_marriage:removeservermarry")
AddEventHandler("esx_marriage:removeservermarry", function()
	isMarried = false
	myMarriage = nil
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if isProposedTo and ProposedBy ~= nil then
			if IsControlJustReleased(1, 51) then -- Accepted the proposal
				if not isMarried then
					TriggerServerEvent("esx_marriage:acceptedProposal", ProposedBy)
					isProposedTo = false
					ProposedBy = nil
				else
					TriggerEvent('chat:addMessage', {
						color = { 255, 0, 0},
						multiline = true,
						args = {"婚姻: ", "你已經結婚了!"}
					})
				end
			elseif IsControlJustReleased(1, 246) then -- Declined the proposal
				TriggerServerEvent("esx_marriage:declineProposal", ProposedBy)
				isProposedTo = false
				ProposedBy = nil
			end
		end
	end
end)

local function DrawText3D(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    
    local scale = 200 / (GetGameplayCamFov() * dist)

        SetTextColour(color.r, color.g, color.b, color.a)
        SetTextScale(0.0, defaultScale * scale)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextDropShadow()
        SetTextCentre(true)


        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        SetDrawOrigin(coords, 0)
        EndTextCommandDisplayText(0.0, 0.0)
        ClearDrawOrigin()

    --end
end

Citizen.CreateThread(function()
	local Sleep = 500
	while true do
		Sleep = 500
		if myMarriage then
			local playerID = GetPlayerFromServerId(myMarriage)
			if playerID then
				local playerPed = GetPlayerPed(playerID)
				if playerPed then
					local pedCoords, myCoords = GetEntityCoords(playerPed), GetEntityCoords(PlayerPedId())
					if pedCoords and Vdist(pedCoords, myCoords) <= 45 then
						Sleep = 0
						DrawText3D(pedCoords + vec3(0,0,0.9), "❤")
						DrawText3D(myCoords + vec3(0,0,0.9), "❤")
					end
				end
			end
		end
		Wait(Sleep)
	end
end)