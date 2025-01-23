local activeAfk = {}
local closeAfk = {}
local afkTimeout = 300000 -- 5 minutes in miliseconds
local lastPosition = nil
local afkTimer = nil
local wasInVehicle = false
local markerOscillationSpeed = 2.0
local markerSize = 3.0
local textSize = 0.75
local afkText = "~r~ PLAYER HAS BEEN AWAY FOR: ~w~"
local isAfk = false
local afkStartTime = nil

Citizen.CreateThread(function()
    TriggerServerEvent('vojtik_afk:pleaseDontBlameMe')
end)

RegisterNetEvent('vojtik_afk:butSomeoneIsActuallySellingThis')
AddEventHandler('vojtik_afk:butSomeoneIsActuallySellingThis', function(data)
    activeAfk = data
    startMainThread()
end)

RegisterNetEvent('vojtik_afk:cringe')
AddEventHandler('vojtik_afk:cringe', function(action, data)
    if action == 'remove' then
        activeAfk[data.sId] = nil
        if closeAfk[data.sId] then
            closeAfk[data.sId] = nil
        end
    elseif action == 'add' then
        activeAfk[data.sId] = data.text
    end
end)

RegisterNetEvent('vojtik_afk:whyTwoEvents')
AddEventHandler('vojtik_afk:whyTwoEvents', function(bool)
    local playerPed = PlayerPedId()
    SetEntityAlpha(playerPed, bool and 190 or 255, false)
    NetworkSetPlayerIsPassive(bool)
    isAfk = bool
    if bool then
        afkStartTime = GetGameTimer()
    else
        afkStartTime = nil
    end
end)

function startMainThread()
    Citizen.CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local myCoords = GetEntityCoords(playerPed)
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if lastPosition then
                if #(myCoords - lastPosition) > 0.5 or IsAnyInputPressed() then
                    if afkTimer then
                        afkTimer = nil
                        TriggerServerEvent('vojtik_afk:playerMoved')
                    end
                else
                    if not afkTimer then
                        afkTimer = GetGameTimer() + afkTimeout
                    elseif GetGameTimer() > afkTimer then
                        if not isAfk then
                            TriggerServerEvent('vojtik_afk:playerAfk')
                        end
                        afkTimer = nil
                    end
                end
            end
            
            lastPosition = myCoords

            for sId, v in pairs(activeAfk) do
                local cId = GetPlayerFromServerId(sId)
                if cId ~= -1 then
                    local cPed = GetPlayerPed(cId)
                    local cCoords = GetEntityCoords(cPed)
                    local dist = #(myCoords - cCoords)
                    if dist < 15.0 and closeAfk[sId] == nil then
                        closeAfk[sId] = {ped = cPed, text = v}
                    elseif dist > 15.0 and closeAfk[sId] then
                        closeAfk[sId] = nil
                    end
                end
            end
            Citizen.Wait(1000)
        end
    end)

    Citizen.CreateThread(function()
        local sleep = 1000
        while true do 
            if next(closeAfk) ~= nil then
                sleep = 0
                for k, v in pairs(closeAfk) do
                    drawText(GetEntityCoords(v.ped), v.text)
                end
            else
                sleep = 1000
            end
            Citizen.Wait(sleep)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            if isAfk then
                local playerPed = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    drawMarkerOnVehicle(vehicle)
                end
            end
            Citizen.Wait(0)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            if IsAnyInputPressed() then
                if isAfk then
                    TriggerServerEvent('vojtik_afk:playerMoved')
                else
                    afkTimer = GetGameTimer() + afkTimeout
                end
            end
            Citizen.Wait(0)
        end
    end)
end

function IsAnyInputPressed()
    for i = 0, 31 do
        if IsControlJustPressed(0, i) then
            return true
        end
    end
    return false
end

function drawMarkerOnVehicle(vehicle)
    local coords = GetEntityCoords(vehicle)
    local time = GetGameTimer() / 1000 * markerOscillationSpeed
    local alpha = math.floor(75 * math.sin(time) + 100)
    local vehicleSize = GetModelDimensions(GetEntityModel(vehicle))
    local markerSizeScaled = markerSize * (vehicleSize.y - vehicleSize.x)
    DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerSizeScaled, markerSizeScaled, markerSizeScaled, 0, 153, 255, alpha, false, true, 2, nil, nil, false)
end

function drawText(coords, text)
    local camCoords = GetGameplayCamCoords()
    local distance = #(coords - camCoords)

    local font = 0
    local size = 1
    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0 * scale, textSize * scale)
    SetTextFont(font)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)

    SetDrawOrigin(vector3(coords.x, coords.y, coords.z + 1.0), 0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(afkText .. "\n" .. getAfkTime())
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

function getAfkTime()
    if afkStartTime then
        local elapsed = GetGameTimer() - afkStartTime + afkTimeout
        local minutes = math.floor(elapsed / 60000)
        local seconds = math.floor((elapsed % 60000) / 1000)
        return string.format("%02d:%02d", minutes, seconds)
    end
    return "00:00"
end
