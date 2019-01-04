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

function slowFollow(currentRot, wantRot, ped)
	local ww1 = wantRot-2
	local ww2 = wantRot+2

	if (math.abs(wantRot-currentRot)>180) then
		if (wantRot<currentRot) then
			local wwt1 = wantRot
			wantRot = wantRot+360
			--ww2 = wwt1
		else
			local wwt2 = currentRot
			currentRot = currentRot+360
			--ww1 = wwt2
		end
	end
	
	ww1 = wantRot-2
	ww2 = wantRot+2
	
	if (currentRot > ww1 and currentRot < ww2) then
	--if rotation is w/in target rotation
		triggerServerEvent("speedItUp", getRootElement(), ped)
		return currentRot
	end

	triggerServerEvent("slowItDown", getRootElement(), ped)
	local add = wantRot-currentRot
	local sub = currentRot-wantRot
	local plus = true -- if true add
	
	local inc = 4
	local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(ped))
	local velocity = (vx^2+vy^2+vz^2)^0.5
	--velocity = velocity*50
	local radius = getElementRadius( getPedOccupiedVehicle( ped ) )
	--inc = (velocity^2)/radius
	--inc = inc+velocity
	outputDebugString("inc: "..velocity)
	
	if (sub > add) then
		plus = false
	end
	
	if (velocity < 0.15) then inc = 2 end
	
	if (plus) then
		return currentRot+inc
	else
		return currentRot-inc
	end
end

function drive( controller, myPed )
	setPedControlState(myPed, "accelerate", true)
	--setPedControlState(myPed, "vehicle_fire", true)
	setTimer( rotation, 50, 0, controller, myPed )
end
addEvent("onVehiclePimped", true)
addEventHandler("onVehiclePimped", getRootElement(), drive)

function shootShoot( ped, player, flag )
	if (flag) then
		local x, y, z = getElementPosition( player )
		local state = getPedControlState( ped, "fire")
		--outputDebugString("Running shootShoot!")

		--setPedControlState ( ped, "aim_weapon", true )
		setPedControlState ( ped, "fire", true )
		setTimer ( function (ped) if ( isElement ( ped ) ) then setPedControlState ( ped, "fire", false) end end, 500, 1, ped )
		
		setTimer( shootShoot, 1000, 1, ped, player )
		--triggerServerEvent("giveHimStuff", getRootElement(), ped, player, state)
	end
end

function rotation( player, ped )
--outputDebugString(tostring(getElementHealth(ped)))
if (getElementHealth( ped ) > 0 and getElementHealth(getPedOccupiedVehicle( ped )) > 0) then
	local x, y, z = getElementPosition( player )
	local px, py, pz = getElementPosition( ped )
	local rx, ry, rz = getElementRotation( getPedOccupiedVehicle( ped ) )
	local rot	

	local mx, my, mz = 0, 0, 0
	local playa = getNearestElement2D( ped, "player" )
	mx, my, mz = getElementPosition( playa )
	local dist = getDistanceBetweenPoints3D(mx, my, mz, px, py, pz)
	
	local vx, vy, vz = getElementVelocity(getPedOccupiedVehicle(ped))
	local velocity = (vx^2+vy^2+vz^2)^0.5
	--outputDebugString("velocity: "..velocity)
	
	local state = getPedControlState(ped, "accelerate")
	if (dist > 40) then
		triggerServerEvent("sirensOff", getRootElement(), ped)
		setPedControlState(ped, "accelerate", false)
		return
	else
		if (state == false) then
			setPedControlState(ped, "accelerate", true)
		else
			setPedWeaponSlot(ped, 4)
			setPedDoingGangDriveby(ped, true)
			setTimer(shootShoot, 50, 1, ped, player, true)
		end
		
	end
	
	rot = follow( px, py, mx, my )
	--outputDebugString(rot.." ///// "..rz)
	
	--rz to rot
	--0=0 / 90=90=-270 / 180=-180 / 270=-90
	local dum = createObject(1238, x, y, z+1, 0, 0, 0, true)
	setElementRotation(dum, rx, ry, rot)
	local dx, dy, dz = getElementRotation(dum)
	destroyElement(dum)
	
	setElementRotation(getPedOccupiedVehicle( ped ), rx, ry, slowFollow(rz, dz, ped) )
	
	--local range = getElementRadius( getPedOccupiedVehicle( ped ) ) * 2 + 1
	
end
end