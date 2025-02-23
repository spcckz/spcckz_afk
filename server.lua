local adminHex = {
    'steam:xxxx',
}
local afkPlayers = {}

RegisterNetEvent('vojtik_afk:pleaseDontBlameMe')
AddEventHandler('vojtik_afk:pleaseDontBlameMe', function()
    TriggerClientEvent('vojtik_afk:butSomeoneIsActuallySellingThis', source, afkPlayers)
end)

RegisterServerEvent('vojtik_afk:playerAfk')
AddEventHandler('vojtik_afk:playerAfk', function()
    local src = source
    afkPlayers[src] = "AFK"
    TriggerClientEvent('vojtik_afk:cringe', -1, 'add', {sId = src, text = "AFK"})
    TriggerClientEvent('vojtik_afk:whyTwoEvents', src, true)
end)

RegisterServerEvent('vojtik_afk:playerMoved')
AddEventHandler('vojtik_afk:playerMoved', function()
    local src = source
    if afkPlayers[src] then
        afkPlayers[src] = nil
        TriggerClientEvent('vojtik_afk:cringe', -1, 'remove', {sId = src})
        TriggerClientEvent('vojtik_afk:whyTwoEvents', src, false)
    end
end)

RegisterCommand('afk', function(src, args)
    local argument = table.concat(args, " ", 1, #args) 
    if argument == '' then
        if afkPlayers[src] then
            afkPlayers[src] = nil
            TriggerClientEvent('vojtik_afk:whyTwoEvents', src, false)
            TriggerClientEvent('vojtik_afk:cringe', -1, 'remove', {sId = src})
        end
        return 
    end

    if args[1] ~= '' then
        if argument then
            afkPlayers[src] = argument

            local time = os.date("*t")
            TriggerClientEvent('vojtik_afk:whyTwoEvents', src, true)
            TriggerClientEvent('vojtik_afk:cringe', -1, 'add', {sId = src, text = '~b~- AFK -~w~\n~b~Since:~w~ '..time.hour..':'..time.min..'\n~b~Reason:~w~ '..argument})
        end
    end
end)

RegisterCommand('afkid', function(src, args)
    local plyId = tonumber(args[1])
    local argument = table.concat(args, " ", 2, #args)

    if not isAdmin(src) then return end

    if plyId == nil or GetPlayerPing(plyId) == 0 then
        -- add notify msg, mby?
        return 
    end

    if argument == '' then
        if afkPlayers[plyId] then
            afkPlayers[plyId] = nil
            TriggerClientEvent('vojtik_afk:whyTwoEvents', plyId, false)
            TriggerClientEvent('vojtik_afk:cringe', -1, 'remove', {sId = plyId})
        end
        return 
    end

    if args[1] ~= '' then
        if argument then
            afkPlayers[plyId] = argument

            local time = os.date("*t")
            TriggerClientEvent('vojtik_afk:whyTwoEvents', plyId, true)
            TriggerClientEvent('vojtik_afk:cringe', -1, 'add', {sId = plyId, text = '~b~- AFK -~w~\n~b~Since:~w~ '..time.hour..':'..time.min..'\n~b~Reason:~w~ '..argument})
        end
    end
end, false)

function isAdmin(src)
    local srcSteam = GetPlayerIdentifiers(src)[1]
    local result = false
    for k, v in pairs(adminHex) do
        if v == srcSteam then
            result = true
            break
        end
    end
    return result
end
