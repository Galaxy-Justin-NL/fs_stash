local ESX = exports["es_extended"]:getSharedObject()

-- Kluis aanmaken (Interactie-zone)
RegisterNetEvent('Fs-Stash:addClientStash', function(id, coords, label)
    local zoneName = "stash_zone_" .. id
    
    exports.ox_target:addSphereZone({
        name = zoneName,
        coords = vec3(coords.x, coords.y, coords.z + 1.0),
        radius = 1.2,
        options = {
            {
                label = 'Open ' .. label,
                icon = 'lock',
                onSelect = function() exports.ox_inventory:openInventory('stash', "stash_"..id) end
            },
            {
                label = 'Kluis Verwijderen',
                icon = 'trash',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Bevestigen',
                        content = 'Weet je zeker dat je deze kluis wilt verwijderen?',
                        cancel = true
                    })
                    if confirm == 'confirm' then TriggerServerEvent('Fs-Stash:removeStash', id) end
                end
            }
        }
    })
end)

-- GEFIXTE DELETE: Verwijdert de zone direct van je scherm
RegisterNetEvent('Fs-Stash:removeClientStash', function(id)
    local zoneName = "stash_zone_" .. id
    
    -- Verwijder de target zone van ox_target
    exports.ox_target:removeZone(zoneName)
    
    lib.notify({
        title = 'Kluis Weg',
        description = 'De kluis is succesvol verwijderd en niet meer toegankelijk.',
        type = 'info'
    })
end)

-- Tablet Menu (Onveranderd)
RegisterNetEvent('Fs-Stash:openPlacement', function()
    local input = lib.inputDialog('Verkoop Tablet', {
        {type = 'number', label = 'ID Koper', required = true},
        {type = 'input', label = 'Naam Kluis', required = true},
        {type = 'number', label = 'Prijs', required = true},
    })
    if not input then return end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local spawnPos = {x = coords.x + (forward.x * 1.0), y = coords.y + (forward.y * 1.0), z = coords.z - 1.0}
    TriggerServerEvent('Fs-Stash:sendOfferToID', tonumber(input[1]), tonumber(input[3]), input[2], spawnPos)
end)

RegisterNetEvent('Fs-Stash:receiveOffer', function(sellerId, price, stashName, coords)
    local alert = lib.alertDialog({header = 'Kluis Kopen', content = ('Koop %s voor $%s?'):format(stashName, price), cancel = true})
    if alert == 'confirm' then lib.callback.await('Fs-Stash:payAndSave', false, sellerId, price, stashName, coords) end
end)
