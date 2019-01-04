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

local vehicleIDS = { 602, 545, 496, 517, 401, 410, 518, 600, 527, 436, 589, 580, 419, 439, 533, 549, 526, 491, 474, 445, 467, 604, 426, 507, 547, 585,
405, 587, 409, 466, 550, 492, 566, 546, 540, 551, 421, 516, 529, 592, 553, 577, 488, 511, 497, 548, 563, 512, 476, 593, 447, 425, 519, 520, 460,
417, 469, 487, 513, 581, 510, 509, 522, 481, 461, 462, 448, 521, 468, 463, 586, 472, 473, 493, 595, 484, 430, 453, 452, 446, 454, 485, 552, 431, 
438, 437, 574, 420, 525, 408, 416, 596, 433, 597, 427, 599, 490, 432, 528, 601, 407, 428, 544, 523, 470, 598, 499, 588, 609, 403, 498, 514, 524, 
423, 532, 414, 578, 443, 486, 515, 406, 531, 573, 456, 455, 459, 543, 422, 583, 482, 478, 605, 554, 530, 418, 572, 582, 413, 440, 536, 575, 534, 
567, 535, 576, 412, 402, 542, 603, 475, 449, 537, 538, 441, 464, 501, 465, 564, 568, 557, 424, 471, 504, 495, 457, 539, 483, 508, 571, 500, 
444, 556, 429, 411, 541, 559, 415, 561, 480, 560, 562, 506, 565, 451, 434, 558, 494, 555, 502, 477, 503, 579, 400, 404, 489, 505, 479, 442, 458, 
606, 607, 610, 590, 569, 611, 584, 608, 435, 450, 591, 594 }

function binder()
	for i, car in ipairs(getElementsByType("vehicle")) do
		if (getVehicleModelFromName(getVehicleName(car)) == 596 or getVehicleModelFromName(getVehicleName(car)) == 597 or getVehicleModelFromName(getVehicleName(car)) == 598 or getVehicleModelFromName(getVehicleName(car)) == 599) then  
			local bot = createPed(math.random(0, 288), 0, 0, 0, 3)
			warpPedIntoVehicle(bot, car)
			--setTimer( rotation, 50, 0, controller, myPed )
			setTimer (putEmIn, 2000, 1, source, bot)
		end
	end
end
addEventHandler("onResourceStart", getRootElement(), binder)

function getIn(car)
	if (getVehicleModelFromName(getVehicleName(car)) == 596 or getVehicleModelFromName(getVehicleName(car)) == 597 or getVehicleModelFromName(getVehicleName(car)) == 598 or getVehicleModelFromName(getVehicleName(car)) == 599) then  
		setTimer (makeEmIn, 4500, 1, source, nil)
	end
end
addEventHandler("onVehicleExit", getRootElement(), getIn)

-- Returns Nearest Element
function getNearestElement2D( from, eType )
	--outputDebugString("Getting nearest ["..eType.."] element to "..tostring(from))
	local eTable = getElementsByType( eType )
	local minDist = 10000
	local dist
	local nearest = 0
	local oNearest
	
	for i, element in ipairs( eTable ) do
		local x, y, z = getElementPosition( from )
		local x2, y2, z2 = getElementPosition( element )
		local dist = getDistanceBetweenPoints2D( x, y, x2, y2 )
		if (dist < minDist) then
			minDist = dist
			oNearest = nearest
			nearest = i
		end
	end
	if ( from == eTable[nearest]) then
		return eTable[oNearest]
	else
		return eTable[nearest]
	end
end

function makeEmIn(car, player)
	local bot = createPed(math.random(0, 288), 0, 0, 0, 3)
	warpPedIntoVehicle(bot, car)
	triggerClientEvent("onVehiclePimped", getRootElement(), player, bot)
end

function putEmIn(player, bot)
	triggerClientEvent("onVehiclePimped", getRootElement(), player, bot)
end

function initBot( button, state, element, x, y, z )
	outputDebugString("eData: "..tostring(getElementData(source, "spawnCarBot")))
	if ( (button == "middle") and (state == "down")) then
		local rnd = math.random(1, #cars)
		--local vehicleID = 0
		--repeat
			--outputDebugString("ride: "..tostring(getVehicleModelFromName( cars[rnd][1] )))
			--rnd = math.random(1, #cars)
			--vehicleID = getVehicleModelFromName( cars[rnd][1] )
		--until (vehicleID ~= false)
		--local ride = createVehicle(vehicleID, x, y, z+2)
		local ride = createVehicle(597, x, y, z+2)
		local bot = createPed(math.random(0, 288), x, y, z+2, 3)
		local controller = source
		local blip = createBlipAttachedTo(bot)
		giveWeapon( bot, 28, 5000, true )
		setVehicleDamageProof(ride, true)
		setVehicleSirensOn(ride, false)
		warpPedIntoVehicle(bot, ride)
		setElementRotation(getPedOccupiedVehicle(bot), getElementRotation(source))
		outputDebugString("Test Vehicle Point Bot Created. Target: "..getPlayerName(controller))
		triggerClientEvent("onVehiclePimped", getRootElement(), controller, bot)
	end
end
addEventHandler("onPlayerClick", getRootElement(), initBot)

function slowItDown(ped)
	setVehicleSirensOn(getPedOccupiedVehicle(ped), true)
	setVehicleHandling(getPedOccupiedVehicle(ped), "maxVelocity", 30);
end
addEvent("slowItDown", true)
addEventHandler("slowItDown", getRootElement(), slowItDown)

function speedItUp(ped)
	setVehicleSirensOn(getPedOccupiedVehicle(ped), true)
	setVehicleHandling(getPedOccupiedVehicle(ped), "maxVelocity", 40);
end
addEvent("speedItUp", true)
addEventHandler("speedItUp", getRootElement(), speedItUp)

function sirensOff(ped)
	setVehicleSirensOn(getPedOccupiedVehicle(ped), false)
end
addEvent("sirensOff", true)
addEventHandler("sirensOff", getRootElement(), sirensOff)

function supeUp( ped, player, state )
	local x, y, z = getElementPosition( player )
	--giveWeapon( ped, 28, 5000, true )
	
	if (state) then
		setPedWeaponSlot( ped, 0 )
		setPedDoingGangDriveby( ped, false )
		setPedControlState( ped, "fire", false )
	else
		setPedWeaponSlot( ped, 4 )
		setPedDoingGangDriveby( ped, true )
		setPedControlState( ped, "fire", true )
	end
	
	--setPedWeaponSlot( ped, 4 )
	--setPedDoingGangDriveby( ped, true )
end
addEvent("giveHimStuff", true)
addEventHandler("giveHimStuff", getRootElement(), supeUp)

function clearDeadBot()
	--if (getElementType(source) ~= "player") then
	outputDebugString("Predator bot vehicle wasted!")
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
	outputDebugString("A police vehicle has exploded!")
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