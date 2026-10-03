local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('criminalempire:getPlayerEmpire', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.fetchScalar('SELECT empire_id FROM criminal_empire_members WHERE player_id = @player_id', {
        ['@player_id'] = identifier
    }, function(empireId)
        if empireId then
            MySQL.Async.fetchAll('SELECT * FROM criminal_empires WHERE id = @empire_id', {
                ['@empire_id'] = empireId
            }, function(empires)
                if empires[1] then
                    cb(empires[1])
                else
                    cb(nil)
                end
            end)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('criminalempire:createEmpire')
AddEventHandler('criminalempire:createEmpire', function(empireName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if xPlayer.getAccount('bank').money >= Config.EmpireCreationCost then
        xPlayer.removeAccountMoney('bank', Config.EmpireCreationCost)

        MySQL.Async.execute('INSERT INTO criminal_empires (name, leader) VALUES (@name, @leader)', {
            ['@name'] = empireName,
            ['@leader'] = identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                MySQL.Async.fetchScalar('SELECT LAST_INSERT_ID()', {}, function(empireId)
                    MySQL.Async.execute('INSERT INTO criminal_empire_members (empire_id, player_id) VALUES (@empire_id, @player_id)', {
                        ['@empire_id'] = empireId,
                        ['@player_id'] = identifier
                    }, function()
                        xPlayer.showNotification('Empire created successfully')
                    end)
                end)
            else
                xPlayer.showNotification('Failed to create empire')
            end
        end)
    else
        xPlayer.showNotification('Not enough money to create an empire')
    end
end)

RegisterServerEvent('criminalempire:joinEmpire')
AddEventHandler('criminalempire:joinEmpire', function(empireId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if xPlayer.getAccount('bank').money >= Config.EmpireJoinCost then
        xPlayer.removeAccountMoney('bank', Config.EmpireJoinCost)

        MySQL.Async.execute('INSERT INTO criminal_empire_members (empire_id, player_id) VALUES (@empire_id, @player_id)', {
            ['@empire_id'] = empireId,
            ['@player_id'] = identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                xPlayer.showNotification('Joined empire successfully')
            else
                xPlayer.showNotification('Failed to join empire')
            end
        end)
    else
        xPlayer.showNotification('Not enough money to join an empire')
    end
end)

RegisterServerEvent('criminalempire:leaveEmpire')
AddEventHandler('criminalempire:leaveEmpire', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    MySQL.Async.execute('DELETE FROM criminal_empire_members WHERE player_id = @player_id', {
        ['@player_id'] = identifier
    }, function(rowsChanged)
        if rowsChanged > 0 then
            xPlayer.showNotification('Left empire successfully')
        else
            xPlayer.showNotification('Failed to leave empire')
        end
    end)
end)

RegisterServerEvent('criminalempire:getAvailableEmpires')
AddEventHandler('criminalempire:getAvailableEmpires', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM criminal_empires', {}, function(empires)
        TriggerClientEvent('criminalempire:openJoinMenu', source, empires)
    end)
end)