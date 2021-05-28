local display = false
local autoDelete = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterCommand("wccc", function(source) 
    SetDisplay(not display)
end)

RegisterNUICallback("car", function(data)
    WCCC(data.car, colors[data.color], data.fuel + .0, data.health + .0, data.bodyhealth + .0, data.wheelHealth + .0, data.plate, data.locked, data.isIncible, data.upgrade, data.autodel)
    SetDisplay(false)
end)

RegisterNUICallback("exit", function()
    SetDisplay(false)
end)

Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 322, display) -- ESC
    end
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        status = bool,
    })
end


function WCCC(model, colorPrimary, fuel, engineHealth, bodyHealth, wheelHealth, plate, locked, isIncible, fullUpgrated, autodel)
    if model ~= nil then
        local modelHash = GetHashKey(model)
        RequestModel(modelHash)
        local isLoaded = HasModelLoaded(modelHash)
        local wheelIndex = 0
        while isLoaded == false do
            Citizen.Wait(100)
        end
        local vehicle = CreateVehicle(modelHash, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), 1, 0)
        SetVehicleColours(vehicle, colorPrimary, colorPrimary)
        SetVehicleFuelLevel(vehicle, fuel)
        DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
        SetVehicleEngineHealth(vehicle, engineHealth)
        SetVehicleBodyHealth(vehicle, bodyHealth)
        SetVehicleNumberPlateText(vehicle, plate)
        SetVehicleDoorsLockedForAllPlayers(vehicle, locked)

        SetEntityInvincible(vehicle, isIncible)

        SetVehicleCanBeVisiblyDamaged(vehicle, isIncible)
        SetVehicleCanEngineOperateOnFire(vehicle, not isIncible)

        while (wheelIndex < 5) do
            SetVehicleWheelHealth(vehicle, wheelIndex ,wheelHealth)
            wheelIndex = wheelIndex + 1
        end

        if fullUpgrated then
            local ourSelection = {
                ["Armour"] = "Armor Upgrade 100%",
                ["Engine"] = "EMS Upgrade, Level 4",
                ["Transmission"] = "Race Transmission",
                ["Suspension"] = "Competition Suspension",
                ["Horns"] = "Sadtrombone Horn",
                ["Brakes"] = "Race Brakes",
                ["Lights"] = "Xenon Lights",
                ["Turbo"] = "Turbo Tuning"
            }
            SetVehicleModKit(vehicle, 0)
            for k, v in pairs(ourSelection) do
                local modType = upgrades[k].type
                local mod = upgrades[k].types[v].index
                SetVehicleMod(vehicle, modType, mod)
            end
            ToggleVehicleMod(vehicle, upgrades["Lights"].type, true)
        end

        autoDelete = autodel

        Citizen.CreateThread(function()
            while autoDelete do
                Citizen.Wait(0)
                local oyuncuCoord = GetEntityCoords(PlayerPedId(), false)
                local vehicleUsing = ESX.Game.GetClosestVehicle(oyuncuCoord)
                if not IsPedInVehicle(PlayerPedId(), vehicleUsing, true) then    
                    DeleteEntity(vehicleUsing)
                    autoDelete = false
                end 
            end
        end)

        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)

    end
end

colors = {
    ["Black"] = 0,
    ["Carbon Black"] = 147,
    ["Graphite"] = 1,
    ["Anhracite Black"] = 11,
    ["Black Steel"] = 2,
    ["Dark Steel"] = 3,
    ["Silver"] = 4,
    ["Bluish Silver"] = 5,
    ["Rolled Steel"] = 6,
    ["Shadow Silver"] = 7,
    ["Stone Silver"] = 8,
    ["Midnight Silver"] = 9,
    ["Cast Iron Silver"] = 10,
    ["Red"] = 27,
    ["Torino Red"] = 28,
    ["Formula Red"] = 29,
    ["Lava Red"] = 150,
    ["Blaze Red"] = 30,
    ["Grace Red"] = 31,
    ["Garnet Red"] = 32,
    ["Sunset Red"] = 33,
    ["Cabernet Red"] = 34,
    ["Wine Red"] = 143,
    ["Candy Red"] = 35,
    ["Hot Pink"] = 135,
    ["Pfsiter Pink"] = 137,
    ["Salmon Pink"] = 136,
    ["Sunrise Orange"] = 36,
    ["Orange"] = 38,
    ["Bright Orange"] = 138,
    ["Gold"] = 99,
    ["Bronze"] = 90,
    ["Yellow"] = 88,
    ["Race Yellow"] = 89,
    ["Dew Yellow"] = 91,
    ["Dark Green"] = 49,
    ["Racing Green"] = 50,
    ["Sea Green"] = 51,
    ["Olive Green"] = 52,
    ["Bright Green"] = 53,
    ["Gasoline Green"] = 54,
    ["Lime Green"] = 92,
    ["Midnight Blue"] = 141,
    ["Galaxy Blue"] = 61,
    ["Dark Blue"] = 62,
    ["Saxon Blue"] = 63,
    ["Blue"] = 64,
    ["Mariner Blue"] = 65,
    ["Harbor Blue"] = 66,
    ["Diamond Blue"] = 67,
    ["Surf Blue"] = 68,
    ["Nautical Blue"] = 69,
    ["Racing Blue"] = 73,
    ["Ultra Blue"] = 70,
    ["Light Blue"] = 74,
    ["Chocolate Brown"] = 96,
    ["Bison Brown"] = 101,
    ["Creeen Brown"] = 95,
    ["Feltzer Brown"] = 94,
    ["Maple Brown"] = 97,
    ["Beechwood Brown"] = 103,
    ["Sienna Brown"] = 104,
    ["Saddle Brown"] = 98,
    ["Moss Brown"] = 100,
    ["Woodbeech Brown"] = 102,
    ["Straw Brown"] = 99,
    ["Sandy Brown"] = 105,
    ["Bleached Brown"] = 106,
    ["Schafter Purple"] = 71,
    ["Spinnaker Purple"] = 72,
    ["Midnight Purple"] = 142,
    ["Bright Purple"] = 145,
    ["Cream"] = 107,
    ["Ice White"] = 111,
    ["Frost White"] = 112
}


upgrades = {
    ["Suspension"] = {
        type = 13,
        types = {
            ["Stock Suspension"] = {index = -1},
            ["Lowered Suspension"] = {index = false},
            ["Street Suspension"] = {index = 1},
            ["Sport Suspension"] = {index = 2},
            ["Competition Suspension"] = {index = 3}
        }
    },
    ["Armour"] = {
        type = 16,
        types = {
            ["None"] = {index = -1},
            ["Armor Upgrade 20%"] = {index = false},
            ["Armor Upgrade 40%"] = {index = 1},
            ["Armor Upgrade 60%"] = {index = 2},
            ["Armor Upgrade 80%"] = {index = 3},
            ["Armor Upgrade 100%"] = {index = 4}
        }
    },
    ["Transmission"] = {
        type = 13,
        types = {
            ["Stock Transmission"] = {index = -1},
            ["Street Transmission"] = {index = false},
            ["Sports Transmission"] = {index = 1},
            ["Race Transmission"] = {index = 2}
        }
    },
    ["Turbo"] = {
        type = 18,
        types = {
            ["None"] = {index = false},
            ["Turbo Tuning"] = {index = true}
        }
    },
    ["Lights"] = {
        type = 22,
        types = {
            ["Stock Lights"] = {index = false},
            ["Xenon Lights"] = {index = true}
        },
        xenonHeadlightColors = {
            ["Default"] = {index = -1},
            ["White"] = {index = 0},
            ["Blue"] = {index = 1},
            ["Electric_Blue"] = {index = 2},
            ["Mint_Green"] = {index = 3},
            ["Lime_Green"] = {index = 4},
            ["Yellow"] = {index = 5},
            ["Golden_Shower"] = {index = 6},
            ["Orange"] = {index = 7},
            ["Red"] = {index = 8},
            ["Pony_Pink"] = {index = 9},
            ["Hot_Pink"] = {index = 10},
            ["Purple"] = {index = 11},
            ["Blacklight"] = {index = 12}
        }
    },
    ["Engine"] = {
        type = 11,
        types = {
            ["EMS Upgrade, Level 1"] = {index = -1},
            ["EMS Upgrade, Level 2"] = {index = false},
            ["EMS Upgrade, Level 3"] = {index = 1},
            ["EMS Upgrade, Level 4"] = {index = 2}
        }
    },
    ["Brakes"] = {
        type = 12,
        types = {
            ["Stock Brakes"] = {index = -1},
            ["Street Brakes"] = {index = false},
            ["Sport Brakes"] = {index = 1},
            ["Race Brakes"] = {index = 2}
        }
    },
    ["Horns"] = {
        type = 14,
        types = {
            ["Stock Horn"] = {index = -1},
            ["Truck Horn"] = {index = false},
            ["Police Horn"] = {index = 1},
            ["Clown Horn"] = {index = 2},
            ["Musical Horn 1"] = {index = 3},
            ["Musical Horn 2"] = {index = 4},
            ["Musical Horn 3"] = {index = 5},
            ["Musical Horn 4"] = {index = 6},
            ["Musical Horn 5"] = {index = 7},
            ["Sadtrombone Horn"] = {index = 8},
            ["Calssical Horn 1"] = {index = 9},
            ["Calssical Horn 2"] = {index = 10},
            ["Calssical Horn 3"] = {index = 11},
            ["Calssical Horn 4"] = {index = 12},
            ["Calssical Horn 5"] = {index = 13},
            ["Calssical Horn 6"] = {index = 14},
            ["Calssical Horn 7"] = {index = 15},
            ["Scaledo Horn"] = {index = 16},
            ["Scalere Horn"] = {index = 17},
            ["Scalemi Horn"] = {index = 18},
            ["Scalefa Horn"] = {index = 19},
            ["Scalesol Horn"] = {index = 20},
            ["Scalela Horn"] = {index = 21},
            ["Scaleti Horn"] = {index = 22},
            ["Scaledo Horn High"] = {index = 23},
            ["Jazz Horn 1"] = {index = 25},
            ["Jazz Horn 2"] = {index = 26},
            ["Jazz Horn 3"] = {index = 27},
            ["Jazzloop Horn"] = {index = 28},
            ["Starspangban Horn 1"] = {index = 29},
            ["Starspangban Horn 2"] = {index = 30},
            ["Starspangban Horn 3"] = {index = 31},
            ["Starspangban Horn 4"] = {index = 32},
            ["Classicalloop Horn 1"] = {index = 33},
            ["Classical Horn 8"] = {index = 34},
            ["Classicalloop Horn 2"] = {index = 35}
        }
    },
    ["Wheels"] = {
        type = 23,
        ["suv"] = {
            type = 3,
            types = {
                ["Stock"] = {index = -1},
                ["Vip"] = {index = false},
                ["Benefactor"] = {index = 1},
                ["Cosmo"] = {index = 2},
                ["Bippu"] = {index = 3},
                ["Royalsix"] = {index = 4},
                ["Fagorme"] = {index = 5},
                ["Deluxe"] = {index = 6},
                ["Icedout"] = {index = 7},
                ["Cognscenti"] = {index = 8},
                ["Lozspeedten"] = {index = 9},
                ["Supernova"] = {index = 10},
                ["Obeyrs"] = {index = 11},
                ["Lozspeedballer"] = {index = 12},
                ["Extra vaganzo"] = {index = 13},
                ["Splitsix"] = {index = 14},
                ["Empowered"] = {index = 15},
                ["Sunrise"] = {index = 16},
                ["Dashvip"] = {index = 17},
                ["Cutter"] = {index = 18}
            }
        },
        ["sport"] = {
            type = false,
            types = {
                ["Stock"] = {index = -1},
                ["Inferno"] = {index = false},
                ["Deepfive"] = {index = 1},
                ["Lozspeed"] = {index = 2},
                ["Diamondcut"] = {index = 3},
                ["Chrono"] = {index = 4},
                ["Feroccirr"] = {index = 5},
                ["Fiftynine"] = {index = 6},
                ["Mercie"] = {index = 7},
                ["Syntheticz"] = {index = 8},
                ["Organictyped"] = {index = 9},
                ["Endov1"] = {index = 10},
                ["Duper7"] = {index = 11},
                ["Uzer"] = {index = 12},
                ["Groundride"] = {index = 13},
                ["Spacer"] = {index = 14},
                ["Venum"] = {index = 15},
                ["Cosmo"] = {index = 16},
                ["Dashvip"] = {index = 17},
                ["Icekid"] = {index = 18},
                ["Ruffeld"] = {index = 19},
                ["Wangenmaster"] = {index = 20},
                ["Superfive"] = {index = 21},
                ["Endov2"] = {index = 22},
                ["Slitsix"] = {index = 23}
            }
        },
        ["offroad"] = {
            type = 4,
            types = {
                ["Stock"] = {index = -1},
                ["Raider"] = {index = false},
                ["Mudslinger"] = {index = 1},
                ["Nevis"] = {index = 2},
                ["Cairngorm"] = {index = 3},
                ["Amazon"] = {index = 4},
                ["Challenger"] = {index = 5},
                ["Dunebasher"] = {index = 6},
                ["Fivestar"] = {index = 7},
                ["Rockcrawler"] = {index = 8},
                ["Milspecsteelie"] = {index = 9}
            }
        },
        ["tuner"] = {
            type = 5,
            types = {
                ["Stock"] = {index = -1},
                ["Cosmo"] = {index = false},
                ["Supermesh"] = {index = 1},
                ["Outsider"] = {index = 2},
                ["Rollas"] = {index = 3},
                ["Driffmeister"] = {index = 4},
                ["Slicer"] = {index = 5},
                ["Elquatro"] = {index = 6},
                ["Dubbed"] = {index = 7},
                ["Fivestar"] = {index = 8},
                ["Slideways"] = {index = 9},
                ["Apex"] = {index = 10},
                ["Stancedeg"] = {index = 11},
                ["Countersteer"] = {index = 12},
                ["Endov1"] = {index = 13},
                ["Endov2dish"] = {index = 14},
                ["Guppez"] = {index = 15},
                ["Chokadori"] = {index = 16},
                ["Chicane"] = {index = 17},
                ["Saisoku"] = {index = 18},
                ["Dishedeight"] = {index = 19},
                ["Fujiwara"] = {index = 20},
                ["Zokusha"] = {index = 21},
                ["Battlevill"] = {index = 22},
                ["Rallymaster"] = {index = 23}
            }
        },
        ["highend"] = {
            type = 7,
            types = {
                ["Stock"] = {index = -1},
                ["Shadow"] = {index = false},
                ["Hyper"] = {index = 1},
                ["Blade"] = {index = 2},
                ["Diamond"] = {index = 3},
                ["Supagee"] = {index = 4},
                ["Chromaticz"] = {index = 5},
                ["Merciechlip"] = {index = 6},
                ["Obeyrs"] = {index = 7},
                ["Gtchrome"] = {index = 8},
                ["Cheetahr"] = {index = 9},
                ["Solar"] = {index = 10},
                ["Splitten"] = {index = 11},
                ["Dashvip"] = {index = 12},
                ["Lozspeedten"] = {index = 13},
                ["Carboninferno"] = {index = 14},
                ["Carbonshadow"] = {index = 15},
                ["Carbonz"] = {index = 16},
                ["Carbonsolar"] = {index = 17},
                ["Carboncheetahr"] = {index = 18},
                ["Carbonsracer"] = {index = 19}
            }
        },
        ["lowrider"] = {
            type = 2,
            types = {
                ["Stock"] = {index = -1},
                ["Flare"] = {index = false},
                ["Wired"] = {index = 1},
                ["Triplegolds"] = {index = 2},
                ["Bigworm"] = {index = 3},
                ["Sevenfives"] = {index = 4},
                ["Splitsix"] = {index = 5},
                ["Freshmesh"] = {index = 6},
                ["Leadsled"] = {index = 7},
                ["Turbine"] = {index = 8},
                ["Superfin"] = {index = 9},
                ["Classicrod"] = {index = 10},
                ["Dollar"] = {index = 11},
                ["Dukes"] = {index = 12},
                ["Lowfive"] = {index = 13},
                ["Gooch"] = {index = 14}
            }
        },
        ["muscle"] = {
            type = 1,
            types = {
                ["Stock"] = {index = -1},
                ["Classicfive"] = {index = false},
                ["Dukes"] = {index = 1},
                ["Musclefreak"] = {index = 2},
                ["Kracka"] = {index = 3},
                ["Azrea"] = {index = 4},
                ["Mecha"] = {index = 5},
                ["Blacktop"] = {index = 6},
                ["Dragspl"] = {index = 7},
                ["Revolver"] = {index = 8},
                ["Classicrod"] = {index = 9},
                ["Spooner"] = {index = 10},
                ["Fivestar"] = {index = 11},
                ["Oldschool"] = {index = 12},
                ["Eljefe"] = {index = 13},
                ["Dodman"] = {index = 14},
                ["Sixgun"] = {index = 15},
                ["Mercenary"] = {index = 16}
            }
        }
    }
}
