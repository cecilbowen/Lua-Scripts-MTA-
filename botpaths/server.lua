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

function binder()
	for i, player in ipairs(getElementsByType("player")) do
		bindKey(player, "3", "down", "cursor")
	end
end
addEventHandler("onResourceStart", getRootElement(), binder)

--Pseudo In-Game Process -------------
--newpath [name] : Creates new path
--cursor command : Toggles mouse mode to click-place path points
--pathbot [name] : Creates bot for path with [name]
--------------------------------------

--Pseudo Code Process ----------------
--createPathBot() [SERVER]
--drive() [CLIENT]


function createPathBot(source, command, pathName, maxSpeed)
	if (source) then
		local x, y, z = getElementPosition(source)
		local rnd = math.random(1, #cars)
		local vehicleID = 0
		local defSpeed = 30
		repeat
			outputDebugString("ride: "..tostring(getVehicleModelFromName( cars[rnd][1] )))
			rnd = math.random(1, #cars)
			vehicleID = getVehicleModelFromName( cars[rnd][1] )
		until (vehicleID ~= false)
	
		-- Creates the Vehicle and Bot
		local ride = createVehicle(vehicleID, x, y, z+2)
		local bot = createPed(math.random(0, 288), x, y, z+2, 3)
		
		--setElementSyncer(bot, getRootElement())
		--setElementSyncer(ride, getRootElement())
		
		local controller = source
		local blip = createBlipAttachedTo(bot)
		warpPedIntoVehicle(bot, ride)
		setVehicleDamageProof( ride, false )
		setVehicleSirensOn(ride, true)
		
		if (maxSpeed) then
			defSpeed = maxSpeed
		end
		setVehicleHandling(ride, "maxVelocity", defSpeed);
		setElementRotation(getPedOccupiedVehicle(bot), getElementRotation(source))
		
		-- A Bit of Configuring
		giveWeapon( bot, 28, 5000, true )
		setElementData(bot, "Number", 1) --# of Waypoint to Head Towards
		setElementData(bot, "Path", tostring(pathName))
		
		-- Safeguard Stuff - No Actual Effect
		setElementData(bot, "type", "pathBot")
		setElementData(blip, "type", "destroy")
		
		outputDebugString("Path bot created.")
		triggerClientEvent("onVehiclePimped", getRootElement(), controller, bot)
	end
end
addCommandHandler("pathbot", createPathBot)

-- Init Some Helpful Vars
local editPath = "null"
local editNumber = 1
local recording = false

function initPath(source, command, name)
	if (source) then
		if (command) then
			editPath = tostring(name)
			editNumber = 1
			outputDebugString("editPath: "..tostring(editPath).." / editNumber: "..tostring(editNumber))
		end
	end
end
addCommandHandler("newpath", initPath)

function incPathPoint(hitElement, sameDimension)
	local markerNumber = getElementData(source, "number")
	local pedNumber = getElementData(hitElement, "Number")
	local markerPath = getElementData(source, "path")
	local pedPath = getElementData(hitElement, "Path")
	
	if (pedNumber == false or pedPath == false) then
		return
	end
	
	outputDebugString("-----SERVER-----")
	outputDebugString(tostring(markerNumber).." / "..tostring(pedNumber))
	outputDebugString(tostring(markerPath).." / "..tostring(pedPath))
	
	if (pedNumber == markerNumber) then
		if (pedPath == markerPath) then
			outputDebugString("Correct element hit!  Incrementing pedNumber to: "..tostring(pedNumber))
			setElementData(hitElement, "Number", pedNumber+1)
		end
	end
end

function addPathPoint( button, state, element, x, y, z )
	--outputDebugString("eData: "..tostring(getElementData(source, "spawnPathBot")))
	if ( (button == "left") and (state == "down") and (element == nil) and (getElementData(source, "spawnPathBot") == 1) and (make) ) then
		-- Makes Sure newpath [name] has been set
		if (editPath == "null") then
			outputDebugString("editPath has not been set!  Please set editPath using newpath [name]")
			return
		end
		
		--local marker = createMarker(x, y, z, "cylinder", 3, 0, 255, 255, 255)
		--local marker = createPed(0, x, y, z)
		local marker = createObject(1238, x, y, z+1, 0, 0, 0, true)
		local border = createColSphere(x, y, z, 3)
		--setElementHealth(marker, 500000)
		if (marker) then
			outputDebugString("Pathpoint ("..tostring(editNumber)..") with path name "..tostring(editPath).." added successfully!")
			setElementData(marker, "path", editPath)
			setElementData(marker, "number", editNumber)
			setElementData(border, "path", editPath)
			setElementData(border, "number", editNumber)
			editNumber = editNumber + 1
			
			--createBlip(x, y, z)
			--killPed(marker)
			addEventHandler("onColShapeHit", border, incPathPoint)
		end
	end
end
addEventHandler("onPlayerClick", getRootElement(), addPathPoint)

function shapeWasHit(element, sameDimension)
	incPathPoint(element, sameDimension)
end
addEvent("iHitIt", true)
addEventHandler("iHitIt", getRootElement(), shapeWasHit)

local recordIntervals = 0.7
function startRecording(source, command)
	recording = true
	record(source)
end
addCommandHandler("record", startRecording)

function stopRecording(source, command)
	recording = false
	editNumber = 1
	editPath = "null"
end
addCommandHandler("stoprecording", stopRecording)

function record(player)
	if (recording == false) then
		return
	end
	
	if (editPath == "null") then
		outputDebugString("editPath has not been set!  Please set editPath using newpath [name]")
		return
	end
	
	setTimer(addManualPathPoint, recordIntervals*1000, 1, player)
	setTimer(record, recordIntervals*1000, 1, player)
end

function addManualPathPoint(player)
	if (flag == false or recording == false) then
		return
	end
	
	local x, y, z = getElementPosition(player)
	local marker = createObject(1238, x, y, z+1, 0, 0, 0, true)
	local border = createColSphere(x, y, z, 3)
	if (marker) then
		outputDebugString("Pathpoint ("..tostring(editNumber)..") with path name "..tostring(editPath).." added successfully (record)!")
		setElementData(marker, "path", editPath)
		setElementData(marker, "number", editNumber)
		setElementData(border, "path", editPath)
		setElementData(border, "number", editNumber)
		editNumber = editNumber + 1
		addEventHandler("onColShapeHit", border, incPathPoint)
	end
end

function cursor(source)
	if (isCursorShowing(source)) then
		showCursor(source, false)
		setElementData(source, "spawnPathBot", 0)
		make = false
	else
		setElementData(source, "spawnPathBot", 1)
		showCursor(source, true)
		make = true
	end
end
addCommandHandler("cursor", cursor)

function toBoat( ped )
	local rnd = math.random(1, #boats)
	setElementModel( ped, getVehicleModelFromName( boats[rnd][1] ) )
end
addEvent("changeToBoat", true)
addEventHandler("changeToBoat", getRootElement(), toBoat)

function toCar( ped )
	local rnd = math.random(1, #cars)
	local vehicleID = 0
	repeat
		outputDebugString("ride: "..tostring(getVehicleModelFromName( cars[rnd][1] )))
		rnd = math.random(1, #cars)
		vehicleID = getVehicleModelFromName( cars[rnd][1] )
	until (vehicleID ~= false)
	setElementModel( ped, vehicleID )
end
addEvent("changeToCar", true)
addEventHandler("changeToCar", getRootElement(), toCar)

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

function nextMarker( element )
	if (getElementType( element ) ~= "player") then
		local x, y, z = getElementPosition( source )
		setTimer( replaceMarker, 2000, 1, x, y, z )
		destroyElement( source )
	end
end
addEventHandler("onMarkerHit", getRootElement(), nextMarker)

function replaceMarker( x, y, z )
	local marker = createMarker( x, y, z, "cylinder", 2.5, 0, 0, 255 )
	--setElementAlpha(marker, 0)
end

function testMark( source )
	local x, y, z = getElementPosition( source )
	local marker = createMarker ( x + 2, y + 2, z, "cylinder", 1.5, 255, 255, 0, 170 )
	outputDebugString("Marker created at: ".."["..tostring(x).."] ["..tostring(y).."] ["..tostring(z).."]")
	--setElementAlpha( marker, 200 )
end
addCommandHandler("makeMarker", testMark)