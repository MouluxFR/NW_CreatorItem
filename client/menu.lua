local Rx_Item = {
    nomLabel = "Aucun",
    labelLabel = "Aucun",
    quantiteLabel = "Aucun",
}

local itemTable = {}

local item_menu = false
local menu_item = RageUI.CreateMenu("NW Item Creator", "Options disponibles :")
local menu_itemCreator = RageUI.CreateSubMenu(menu_item, "NW Item Creator", "Création de l'item :")
local menu_itemDelete = RageUI.CreateSubMenu(menu_item, "NW Item Creator", "Supprimer un item :")
local menu_itemBDD = RageUI.CreateSubMenu(menu_item, "NW Item Creators", "Item dans la BDD :")
menu_item.Closed = function()
    item_menu = false
end

function ItemMenu()
    if item_menu then
        item_menu = false
        RageUI.Visible(menu_item, false)
        return
    else
        item_menu = true
        RageUI.Visible(menu_item, true)

        Citizen.CreateThread(function()
            while item_menu do
                Citizen.Wait(1)

                RageUI.IsVisible(menu_item, function()

                    RageUI.Separator("~b~↓↓~w~  Intéraction avec les items  ~b~↓↓~w~")

                    RageUI.Button("Créer un item", nil, { RightLabel = "→→" }, true, {
                    }, menu_itemCreator)

                    RageUI.Button("Supprimer un item", nil, { RightLabel = "→→" }, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback("Rx:getItem", function(data)
                                itemTable = data
                            end)
                        end
                    }, menu_itemDelete)

                    RageUI.Line()

                    RageUI.Button("Voir les items dans la BDD", nil, { RightLabel = "→→" }, true, {
                        onSelected = function()
                            ESX.TriggerServerCallback("Rx:getItem", function(data)
                                itemTable = data
                            end)
                        end
                    }, menu_itemBDD)
                end)

                RageUI.IsVisible(menu_itemCreator, function()

                    RageUI.Button("Nom :", nil, { RightLabel = Rx_Item.nomLabel }, true, {
                        onSelected = function()
                            local nameResult = EntrerText("Nom de l'item (~b~Par ex: burger~s~) ", "", 20)

                            if nameResult == "" then
                                Rx_Item.nomLabel = "Aucun"
                                Notification("[~r~Erreur~s~] Impossible de créer le nom de l'item.")
                            else
                                Rx_Item.nomLabel = nameResult
                            end
                        end
                    })

                    RageUI.Button("Label :", nil, { RightLabel = Rx_Item.labelLabel }, true, {
                        onSelected = function()
                            local labelResult = EntrerText("Label de l'item (~b~Par ex: Burger~s~) ", "", 20)

                            if labelResult == "" then
                                Rx_Item.labelLabel = "Aucun"
                                Notification("[~r~Erreur~s~] Impossible de créer le label de l'item.")
                            else
                                Rx_Item.labelLabel = labelResult
                            end
                        end
                    })

                    RageUI.Button("Quantité maximum :", nil, { RightLabel = Rx_Item.quantiteLabel }, true, {
                        onSelected = function()
                            local quantityResult = EntrerText("Quantité max que le joueur peux posséder ", "", 3)

                            if tonumber(quantityResult) then
                                Rx_Item.quantiteLabel = quantityResult
                            else
                                Rx_Item.quantiteLabel = "Aucun"
                                Notification("[~r~Erreur~s~] Seuls les chiffres sont tolérés.")
                            end
                        end
                    })

                    RageUI.Line()

                    if Rx_Item.nomLabel == "Aucun" or Rx_Item.labelLabel == "Aucun" or Rx_Item.quantiteLabel == "Aucun" then
                        RageUI.Button("Créer l'item", nil, { RightLabel = "→→", Color = { BackgroundColor = RageUI.ItemsColour.Red } }, false, {
                        })
                    else
                        RageUI.Button("Créer l'item", nil, { RightLabel = "→→", Color = { BackgroundColor = RageUI.ItemsColour.Green } }, true, {
                            onSelected = function()
                                TriggerServerEvent("Rx:itemBuilder", Rx_Item.nomLabel, Rx_Item.labelLabel, Rx_Item.quantiteLabel)
                                RageUI.GoBack()
                                Rx_Item.nomLabel = "Aucun"
                                Rx_Item.labelLabel = "Aucun"
                                Rx_Item.quantiteLabel = "Aucun"
                            end
                        })
                    end
                end)

                RageUI.IsVisible(menu_itemDelete, function()
                    if #itemTable >= 1 then
                        RageUI.Separator("~r~↓↓~s~  Supprimer un item dans la BDD  ~r~↓↓~s~")
                        RageUI.Line()

                        for k, v in pairs(itemTable) do
                            RageUI.Button(v.nomItem, "Appuyez sur ~g~[ENTER]~s~ pour retirer l'item de la BDD", { RightLabel = "~r~Supprimer~s~ →→" }, true, {
                                onSelected = function()
                                    local removeItem = EntrerText("Entrer 'Oui' pour supprimer cet item ", "", 3)

                                    if removeItem == "Oui" then
                                        TriggerServerEvent("Rx:removeItem", v.item)
                                        RageUI.GoBack()
                                    else
                                        Notification("[~r~Erreur~s~] Syntaxe incorrecte.")
                                    end
                                end
                            })
                        end
                    else
                        RageUI.Separator("")
                        RageUI.Separator("~r~Aucun item dans la BDD.")
                        RageUI.Separator("")
                    end
                end)

                RageUI.IsVisible(menu_itemBDD, function()
                    if #itemTable >= 1 then
                        RageUI.Separator("~y~↓↓~s~  Items dans la BDD  ~y~↓↓~s~")
                        RageUI.Line()

                        for k, v in pairs(itemTable) do
                            RageUI.Button(v.nomItem, nil, { RightLabel = "~g~Dans la BDD" }, true, {
                            })
                        end
                    else
                        RageUI.Separator("")
                        RageUI.Separator("~r~Aucun item dans la BDD.")
                        RageUI.Separator("")
                    end
                end)
            end
        end)
    end
end

RegisterKeyMapping("-CreationItem", "Menu Item", "keyboard", ConfigItem.Key)
RegisterCommand("-CreationItem", function()
    ESX.TriggerServerCallback('Rx:getUserGroup', function(group)
        if group ~= "user" then
            if item_menu == false then
                ItemMenu()
            end
        else
            Notification("[~r~Erreur~s~] Vous n'avez pas la permissions d'accéder à ce menu.")
        end
    end, GetPlayerServerId(PlayerId()))
end)