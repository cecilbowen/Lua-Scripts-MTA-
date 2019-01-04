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

-- Angle Facing Player
function follow( x1, y1, x2, y2 )
	return ( (math.atan2(y2-y1, x2-x1))*180/math.pi-90 )
end

-- Angle Circling Player
function circle( x1, y1, x2, y2 )
	return ( (math.atan2(y2-y1, x2-x1))*180/math.pi )
end

-- Angle Circling Player
function away( x1, y1, x2, y2 )
	return ( (math.atan2(y1-y2, x1-x2))*180/math.pi-90 )
end

local driveTime = 2
local brakeTime = 2
function humanDriving(controller, ped)
	setPedControlState(ped, "accelerate", true)
	outputDebugString("Accelerating...")
	setTimer(humanDriving2, driveTime*1000, 1, controller, ped)
end

function humanDriving2(controller, ped)
	setPedControlState(ped, "accelerate", false)
	setPedControlState(ped, "handbrake", true)
	setTimer(humanBraking, (brakeTime/2)*1000, 1, controller, ped)
	outputDebugString("NOT Accelerating...")
	setTimer(humanDriving, brakeTime*1000, 1, controller, ped)
end

function humanBraking(controller, ped)
	setPedControlState(ped, "handbrake", false)
end

function drive( controller, myPed )
	--setPedControlState(myPed, "vehicle_fire", true)
	
	setPedControlState(ped, "accelerate", true)
	--setTimer(humanDriving, 50, 1, controller, myPed)
	setTimer(rotation, 50, 0, controller, myPed)
end
addEvent("onVehiclePimped", true)
addEventHandler("onVehiclePimped", getRootElement(), drive)

function rotation( player, ped )
if (getElementHealth( ped ) > 0 and getElementHealth(getPedOccupiedVehicle( ped )) > 0) then
	local x, y, z = getElementPosition( player )
	local px, py, pz = getElementPosition( ped )
	local rx, ry, rz = getElementRotation( getPedOccupiedVehicle( ped ) )
	local rot	

	local pathPoints = getElementsByType("colshape")
	local foundTarget = false
	for i, theMarker in ipairs(pathPoints) do
		local markerNumber = getElementData(theMarker, "number")
		local pedNumber = getElementData(ped, "Number")
		local markerPath = getElementData(theMarker, "path")
		local pedPath = getElementData(ped, "Path")
		local mx, my, mz = getElementPosition(theMarker)
		
		if (markerPath == pedPath) then
		--outputDebugString("markerPath: "..tostring(markerPath).." / pedPath: "..tostring(pedPath))
			if (markerNumber == pedNumber) then
				--outputDebugString("Target FOUND! x"..tostring(mx).." y"..tostring(my).." z"..tostring(mz))
				--createExplosion(mx, my, mz, 12, true, -1, false)
				rot = follow(px, py, mx, my)
				foundTarget = true
			end
		end
	end
	
		-- Check if in Water
	local inWater = isElementInWater( getPedOccupiedVehicle( ped ) )
	if ( inWater ) and ( getVehicleType( getPedOccupiedVehicle( ped ) ) ~= "Boat" ) then
		triggerServerEvent("changeToBoat", getRootElement(), getPedOccupiedVehicle(ped))
	elseif ( inWater == false ) and ( getVehicleType( getPedOccupiedVehicle( ped ) ) == "Boat" ) then
		triggerServerEvent("changeToCar", getRootElement(), getPedOccupiedVehicle(ped))
	end
	
	if (foundTarget) then
		if (getPedControlState(ped, "accelerate") == false) then
			setPedControlState(ped, "accelerate", true)
			setPedControlState(ped, "handbrake", false)
		end
	else
		if (getPedControlState(ped, "accelerate")) then
			setPedControlState(ped, "accelerate", false)
			setPedControlState(ped, "handbrake", true)
		end
		setElementData(ped, "Number", 1)
	end
	
	if (rot) then
		setElementRotation( getPedOccupiedVehicle(ped), rx, ry, rot ) -- Make Vehicle Face Direction of Movement
	end

	-- ////////////////////////////////////////////////////////////////////////////////////////////
	
	--local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
	--local range = getElementRadius( getPedOccupiedVehicle( ped ) ) * 2 + 1
	--local state = getPedControlState(ped, "accelerate")

	
end
end

function checkCol(hitElement, sameDimension)
	triggerServerEvent("iHitIt", getRootElement(), hitElement, sameDimension)
end
--addEventHandler("onClientColShapeHit", getRootElement(), checkCol)