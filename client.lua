local ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Draw markers for empire territories
        for _, territory in ipairs(Config.EmpireTerritories) do
            if #(playerCoords - vector3(territory.x, territory.y, territory.z)) < 10.0 then
                DrawMarker(Config.EmpireMarkerType, territory.x, territory.y, territory.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.EmpireMarkerScale.x, Config.EmpireMarkerScale.y, Config.EmpireMarkerScale.z, Config.EmpireMarkerColor.r, Config.EmpireMarkerColor.g, Config.EmpireMarkerColor.b, Config.EmpireMarkerColor.a, false, true, 2, nil, nil, false)
            end
        end
    end
end)

RegisterNetEvent('criminalempire:updateTerritories')
AddEventHandler('criminalempire:updateTerritories', function(territories)
    Config.EmpireTerritories = territories
end)

function OpenEmpireMenu()
    local elements = {
        {label = 'Create Empire', value = 'create_empire'},
        {label = 'Join Empire', value = 'join_empire'},
        {label = 'Leave Empire', value = 'leave_empire'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'empire_menu', {
        title = 'Criminal Empire',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'create_empire' then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'create_empire_dialog', {
                title = 'Enter Empire Name'
            }, function(data2, menu2)
                local empireName = data2.value
                if empireName and #empireName >= Config.EmpireNameLength.min and #empireName <= Config.EmpireNameLength.max then
                    TriggerServerEvent('criminalempire:createEmpire', empireName)
                else
                    ESX.ShowNotification('Invalid empire name length')
                end
                menu2.close()
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == 'join_empire' then
            TriggerServerEvent('criminalempire:getAvailableEmpires')
        elseif data.current.value == 'leave_empire' then
            TriggerServerEvent('criminalempire:leaveEmpire')
        end
    end, function(data, menu)
        menu.close()
    end)
end

RegisterCommand('empire', function()
    OpenEmpireMenu()
end, false)

RegisterNetEvent('criminalempire:openJoinMenu')
AddEventHandler('criminalempire:openJoinMenu', function(empires)
    local elements = {}
    for _, empire in ipairs(empires) do
        table.insert(elements, {label = empire.name, value = empire.id})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'join_empire_menu', {
        title = 'Join Empire',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        TriggerServerEvent('criminalempire:joinEmpire', data.current.value)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end)