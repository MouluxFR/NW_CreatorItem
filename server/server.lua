ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


-----------------------------------------------> Event création item <-----------------------------------------------

RegisterServerEvent("Rx:itemBuilder")
AddEventHandler("Rx:itemBuilder", function(name, label, quantity)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() ~= "user" then
        MySQL.Async.execute("INSERT INTO items (name, label, ".. ConfigItem.Limit .. ") VALUES (@a, @b, @c)", {
            ["@a"] = name,
            ["@b"] = label,
            ["@c"] = quantity,
            }, function()
        end)
        TriggerClientEvent('esx:showNotification', xPlayer.source, "[~g~Succès~s~] L'item a été créer.")
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, "[~r~Erreur~s~] Vous n'avez pas la permission de créer des items.")
    end
end)


-----------------------------------------------> Callback item <-----------------------------------------------


ESX.RegisterServerCallback("Rx:getItem", function(source, cb)
	allItems = {}

	MySQL.Async.fetchAll("SELECT * FROM items", {}, function(data)
		
		for k, v in pairs(data) do 
			table.insert(allItems, {
				item = v.name,
				nomItem = v.label
			})
		end
		cb(allItems)
	end)
end)


RegisterServerEvent("Rx:removeItem")
AddEventHandler("Rx:removeItem", function(name)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() ~= "user" then
        MySQL.Async.execute("DELETE FROM items WHERE name = @a", {
            ["@a"] = name,
            }, function()
        end)
        TriggerClientEvent('esx:showNotification', xPlayer.source, "[~g~Succès~s~] L'item a été supprimer.")
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, "[~r~Erreur~s~] Vous n'avez pas la permission de supprimer des items.")
    end
end)


-----------------------------------------------> Callback le grade <-----------------------------------------------


ESX.RegisterServerCallback('Rx:getUserGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
	local group = xPlayer.getGroup()
	cb(group)
end)


AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print(("The resource %s was stopped."):format(resourceName))
end)