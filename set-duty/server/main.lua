ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


AddEventHandler("playerDropped", function()
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade

    if job == 'police' or job == 'ambulance' or job == 'mechanic' then
        xPlayer.setJob('off' ..job, grade)
        TriggerEvent("TokoVoip:removePlayerFromAllRadio", _source)
        TriggerEvent("eblips:remove", _source)
        print("Set job to off for a player")
    end
end)

RegisterServerEvent('duty:onoff')
AddEventHandler('duty:onoff', function(job)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.job.name
    local grade = xPlayer.job.grade
    
    if job == 'police' or job == 'ambulance' or job == 'mechanic' then
        xPlayer.setJob('off' ..job, grade)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You are now off-duty', length = 9000})
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Tracker status = off', length = 9000})
        TriggerEvent("TokoVoip:removePlayerFromAllRadio", _source)
        TriggerEvent("eblips:remove", _source)
    elseif job == 'offpolice' then
        xPlayer.setJob('police', grade)
        if xPlayer.getInventoryItem('radio').count >= 1 then
            TriggerEvent("TokoVoip:addPlayerToRadio", 1, _source)
        end
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You are now on-duty', length = 9000})
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Tracker status = on', length = 9000})
        TriggerEvent("eblips:add", {name = "Police", src = _source, color = 42})
    elseif job == 'offambulance' then
        xPlayer.setJob('ambulance', grade)
        if xPlayer.getInventoryItem('radio').count >= 1 then
            TriggerEvent("TokoVoip:addPlayerToRadio", 2, _source)
        end
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You are now on-duty', length = 9000})
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Tracker status = on', length = 9000})
        TriggerEvent("eblips:add", {name = "EMS", src = _source, color = 1})
    elseif job == 'offmechanic' then
        xPlayer.setJob('mechanic', grade) 
        if xPlayer.getInventoryItem('radio').count >= 1 then
            TriggerEvent("TokoVoip:addPlayerToRadio", 11, _source)
        end
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'You are now on-duty', length = 9000})
        --TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Tracker status = on', length = 9000})
        --TriggerEvent("eblips:add", {name = "Mechanic", src = _source, color = 5})
    end
end)