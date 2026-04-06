local ESX = exports["es_extended"]:getSharedObject()

-- 1. Item bruikbaar maken
ESX.RegisterUsableItem('stash_tablet', function(source)
    TriggerClientEvent('Fs-Stash:openPlacement', source)
end)

-- 2. Aanbod sturen
RegisterNetEvent('Fs-Stash:sendOfferToID', function(targetId, price, stashName, coords)
    local _source = source
    TriggerClientEvent('Fs-Stash:receiveOffer', targetId, _source, price, stashName, coords)
end)

-- 3. Betaling en Opslag
lib.callback.register('Fs-Stash:payAndSave', function(source, sellerId, price, stashName, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xSeller = ESX.GetPlayerFromId(sellerId)
    if not xPlayer or xPlayer.getAccount('bank').money < price then return false, "Geen geld!" end

    local coordsString = json.encode(coords)
    local promise = promise.new()

    exports.oxmysql:insert('INSERT INTO player_stashes (owner, name, coords) VALUES (?, ?, ?)', {
        xPlayer.identifier, stashName, coordsString
    }, function(id)
        local insertId = type(id) == 'table' and (id.insertId or id[1]) or id
        local finalId = tonumber(insertId)
        
        -- Veilige fallback als finalId nil is
        if finalId then
            xPlayer.removeAccountMoney('bank', price)
            if xSeller then xSeller.addAccountMoney('bank', price) end
            
            exports.ox_inventory:RegisterStash("stash_"..finalId, stashName, 50, 100000, xPlayer.identifier)
            TriggerClientEvent('Fs-Stash:addClientStash', -1, finalId, coords, stashName)
            promise:resolve(true)
        else
            promise:resolve(false)
        end
    end)
    return Citizen.Await(promise)
end)

-- 4. Verwijder Functie (Vergelijkingen zijn hier uitgebannen)
RegisterNetEvent('Fs-Stash:removeStash', function(id)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local stashId = tonumber(id)

    if not xPlayer or not stashId then return end

    exports.oxmysql:query('SELECT owner FROM player_stashes WHERE id = ?', {stashId}, function(result)
        local isOwner = false
        
        -- ONMOGELIJK TE CRASHEN: We gebruiken geen # of > 0 meer.
        -- Als result een tabel is, kijken we of we erdoorheen kunnen wandelen.
        if type(result) == 'table' then
            for _, row in ipairs(result) do
                if row.owner == xPlayer.identifier then
                    isOwner = true
                    break
                end
            end
        end

        local isAdmin = (xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin')

        if isOwner or isAdmin then
            exports.oxmysql:execute('DELETE FROM player_stashes WHERE id = ?', {stashId}, function(rows)
                -- Veilige conversie voor rows (sommige oxmysql versies geven een tabel met affectedRows)
                local affected = type(rows) == 'table' and (rows.affectedRows or 0) or tonumber(rows) or 0
                
                if affected > 0 then 
                    TriggerClientEvent('Fs-Stash:removeClientStash', -1, stashId)
                    TriggerClientEvent('esx:showNotification', _source, isAdmin and "Kluis verwijderd als Admin." or "Kluis verwijderd.")
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', _source, "Dit is niet jouw kluis!")
        end
    end)
end)

-- 5. Inladen bij start (Vergelijkingen zijn hier uitgebannen)
local function LoadAllStashes()
    exports.oxmysql:query('SELECT * FROM player_stashes', {}, function(result)
        local geladenAantal = 0
        
        -- ONMOGELIJK TE CRASHEN: We loopen gewoon veilig door de data.
        -- Geen tabellen vergelijken met nummers.
        if type(result) == 'table' then
            for _, v in ipairs(result) do
                local sId = tonumber(v.id)
                if sId then
                    -- pcall zorgt ervoor dat kapotte JSON de server niet laat crashen
                    local success, coords = pcall(json.decode, v.coords)
                    if success and coords then
                        exports.ox_inventory:RegisterStash("stash_" .. sId, v.name, 50, 100000, v.owner)
                        TriggerClientEvent('Fs-Stash:addClientStash', -1, sId, coords, v.name)
                        geladenAantal = geladenAantal + 1
                    end
                end
            end
        end
        
        if geladenAantal > 0 then
            print(("^2[Fs-Stash] ^7Succesvol %s kluizen ingeladen."):format(geladenAantal))
        else
            print("^3[Fs-Stash] ^7Geen kluizen gevonden om in te laden.")
        end
    end)
end

CreateThread(function()
    Wait(5000) 
    LoadAllStashes()
end)