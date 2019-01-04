local make = false

local cars =
{
	{"bullet"},
	{"cheetah"},
	{"comet"},
	{"infernus"},
	{"turismo"},
	{"banshee"},
	{"alpha"},
	{"phoenix"},
	{"blade"},
	{"elegy"},
	{"hotknife"},
	{"police car (ls)"},
	{"police car (lf)"},
	{"police car (lv)"}
}

local heavy =
{
	{"dumper"},
	{"roadtrain"},
	{"rhino"},
	{"dft-30"}
}

local boats =
{
	{"predator"},
	{"speeder"},
	{"dinghy"}
}

local planes =
{
	{"hydra"},
	{"rustler"},
	{"shamal"}
}

local helicopters =
{
	{"hunter"},
	{"seasparrow"},
	{"raindance"}
}

function initBot( button, state, element, x, y, z )
	outputDebugString("eData: "..tostring(getElementData(source, "spawnCarBot")))
	if ( (button == "middle") and (state == "down") and (element == nil) ) then
		local rnd = math.random(1, #cars)
		local vehicleID = 0
		repeat
			outputDebugString("ride: "..tostring(getVehicleModelFromName( cars[rnd][1] )))
			rnd = math.random(1, #cars)
			vehicleID = getVehicleModelFromName( cars[rnd][1] )
		until (vehicleID ~= false)
		local ride = createVehicle(vehicleID, x, y, z+2)
		local bot = createPed(math.random(0, 288), x, y, z+2, 3)
		local controller = source
		local blip = createBlipAttachedTo(bot)
		setVehicleDamageProof( ride, false )
		warpPedIntoVehicle(bot, ride)
		setElementRotation(getPedOccupiedVehicle(bot), getElementRotation(source))
		outputDebugString("Test Vehicle Point Bot Created. Target: "..getPlayerName(controller))
		triggerClientEvent("onVehiclePimped", getRootElement(), controller, bot)
	end
end
addEventHandler("onPlayerClick", getRootElement(), initBot)

function slowItDown(ped)
	setVehicleHandling(getPedOccupiedVehicle(ped), "maxVelocity", 10);
end
addEvent("slowItDown", true)
addEventHandler("slowItDown", getRootElement(), slowItDown)

function speedItUp(ped)
	setVehicleHandling(getPedOccupiedVehicle(ped), "maxVelocity", 40);
end
addEvent("speedItUp", true)
addEventHandler("speedItUp", getRootElement(), speedItUp)

function clearDeadBot()
	--if (getElementType(source) ~= "player") then
	outputDebugString("Car Bot Wasted!")
		for i, blip in ipairs(getElementsByType("blip")) do
			local deadPlayer = getElementAttachedTo(blip)
			--outputDebugString("attacher: "..tostring(getElementAttachedTo(blip)))
			if (getElementData(blip, "type") == "destroy" and getElementAttachedTo(blip) == source) then
				destroyElement(blip)
			end
		end
	--end
end
addEventHandler("onPedWasted", getRootElement(), clearDeadBot)

function clearWastedCars()
	outputDebugString("A vehicle has exploded!")
    local occupants = getVehicleOccupants(source) -- Get all vehicle occupants
    local seats = getVehicleMaxPassengers(source) -- Get the amount of passenger seats
 
    for seat = 0, seats do -- Repeat with seat = 0, incrementing until it reaches the amount of passenger seats the vehicle has
        local occupant = occupants[seat] -- Get the occupant
        if occupant and getElementType(occupant)=="ped" then -- If the seat is occupied by a player...
			killPed(occupant)
        end
    end
end
addEventHandler("onVehicleExplode", getRootElement(), clearWastedCars)