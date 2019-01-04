-- Array of Various Spawn Points
local spawnPoints = 
{
  -- x, y, z
  { 2575.9719238281+math.random(-8,8), 2274.3481445313+math.random(-8,8), 11 }, -- Rock Hotel
  { -798.31433105469+math.random(-8,8), 1435.1799316406+math.random(-8,8), 13.7890625 }, -- Teepee Place
  { -1401.3676757813+math.random(-10,10), -18.284103393555+math.random(-10,10), 14.1484375 }, -- Easter Bay Airport
  { 65.011413574219+math.random(-5,5), -243.83346557617+math.random(-5,5), 1.578125 }, -- Blueberry Acres
  { 2483.9191894531+math.random(-8,8), -1671.5051269531+math.random(-8,8), 13.335947036743 }, -- Grove Street
  { 213.6316986084+math.random(-5,5), 1906.4345703125+math.random(-5,5), 17.640625 }, -- Area 51
  { -707.45233154297+math.random(-5,5), 960.1357421875+math.random(-5,5), 12.468586921692 }, -- Tierra Robada
  { -760.32281494141+math.random(-2,2), 2056.3833007813+math.random(-2,2), 60.3828125 }, -- Water Damn
  { -790.76580810547+math.random(-5,5), 2424.5673828125+math.random(-5,5), 157.14868164063 }, -- Desert Arc
  { 345.10858154297+math.random(-1,1), -2350.447265625+math.random(-1,1), 1.1953601837158 }, -- Water Base v1
  { 2580.5739746094+math.random(-2,2), -962.24169921875+math.random(-2,2), 81.3515625 }, -- Green Coast Hill
  { -2319.1354980469+math.random(-5,5), -1608.7940673828+math.random(-5,5), 483.81231689453 } -- Mount Chiliad
}

-- Player and Bot Teams
local ggTeam = createTeam("Gangsta", 255, 255, 255) -- White
local playerTeam = createTeam("Stupid", 0, 255, 0) -- Green
local otherTeam = createTeam("Drunk", 255, 255, 0) -- Blue
local someTeam = createTeam("Emo", 0, 0, 0) -- Black

local teamStrings =
{
	{ "Gangsta" },
	{ "Stupid" },
	{ "Drunk" },
	{ "Emo" }
}

-- Function that Spawns Player at Random Spawn Point (as Specified Above)
function spawner(player, hisTeam)

	-- Setting Player's Random Spawn Point Successfully
	local rnd = math.random( 1, #spawnPoints )
	spawnPlayer ( player, spawnPoints[rnd][1], spawnPoints[rnd][2], spawnPoints[rnd][3])
	
	-- Standard Spawn Stuff
	fadeCamera(player, true)
	setCameraTarget(player, player)
	
	-- Setting the Player's Correct Team
	setPlayerTeam(player, hisTeam)
end

-- Stuff to do When Map Starts
function startStuff()	
	-- Setting All the Vehicles Re-Spawn Time
	local vehicles = getElementsByType ( "vehicle" )
	for k, vehicle in ipairs ( vehicles ) do
		toggleVehicleRespawn( vehicle, true ) -- Let Every Vehicle Respawn
		setVehicleIdleRespawnDelay( vehicle, 15000 ) -- Set the all the Vehicle's Idle Time to 15 Seconds
		setVehicleFuelTankExplodable( vehicle, true ) -- Set the all the Vehicle's Fuel Tanks Explodable
	end

	local players = getElementsByType( "player" )
	for i, player in ipairs ( players ) do
		-- Setting Player's Random Spawn Point Successfully
		local rndS = math.random( 1, #spawnPoints )
		spawnPlayer ( player, spawnPoints[rndS][1], spawnPoints[rndS][2], spawnPoints[rndS][3])
		
		local rndT = math.random(1,#teamStrings)
		local hisTeam = getTeamFromName( teamStrings[rndT][1] )
	
		-- Standard Spawn Stuff
		fadeCamera(player, true)
		setCameraTarget(player, player)
	
		-- Setting the Player's Correct Team
		setPlayerTeam(player, hisTeam)
	end
end
addEventHandler ( "onResourceStart", getResourceRootElement(getThisResource()), startStuff )

-- Spawns the Player to a Random Spawn Point When He Joins
addEventHandler( "onPlayerJoin", getRootElement( ),
	function()
		local rnd = math.random(1,#teamStrings)
		setTimer( spawner, 2000, 1, source, getTeamFromName( teamStrings[rnd][1] ) )
	end
)

-- Spawns the Player 2 Seconds After Death at a Random Spawn Point
addEventHandler( "onPlayerWasted", getRootElement( ),
	function()
		local team = getPlayerTeam( source )
		setTimer( spawner, 2000, 1, source, team) -- Spawn the Player 2 Seconds After Death
	end
)

-- Bot Functions, Armies, Etc. /////////////////////////////////////////////

-- Gives a Player a Professional Army
function spawnMine (source, command, target)
if (isObjectInACLGroup ("user."..getAccountName(getPlayerAccount(source)),aclGetGroup("Admin"))) then

	local player = getPlayerFromName(tostring(target))
	local x,y,z = getElementPosition (player)
	local rot = 90
	local skin = 287 -- Army Men
	local interior = getElementInterior(player)
	local dimension = 0
	local team = getPlayerTeam( player )
	local weapon = math.random(22, 34)
	local mode = "following"
	-- How Many Soldiers to Make
	for adx=0, 10, 1 do
		call (getResourceFromName("slothbot"), "spawnBot", x+math.random(-11,11), y+math.random(-11,11), z, rot, skin, interior, dimension, team, weapon, mode, player)
		weapon = math.random(22, 34)
	end
	outputChatBox("You are leading a squad of armymen!", player, 0, 255, 0, true)
else
	outputChatBox("You need to be an admin to use this command!", player, 255, 0, 0, true)
end
end
addCommandHandler("armySwat",spawnMine)

-- Gives a Player a Gangsta Militia
function spawnMineG (source, command, target)
if (isObjectInACLGroup ("user."..getAccountName(getPlayerAccount(source)),aclGetGroup("Admin"))) then

	local player = getPlayerFromName(tostring(target))
	local x,y,z = getElementPosition (player)
	local rot = 90
	local skin = math.random(101,107) -- Gangsters (Mostly Grove)
	local interior = getElementInterior(player)
	local dimension = 0
	local team = getPlayerTeam( player )
	local weapon = math.random(0, 12)
	local mode = "following"
	-- How Many Soldiers to Make
	for adx=0, 10, 1 do
		call (getResourceFromName("slothbot"), "spawnBot", x+math.random(-11,11), y+math.random(-11,11), z, rot, skin, interior, dimension, team, weapon, mode, player)
		weapon = math.random(0, 12)
		skin = math.random(101,107)
	end
	outputChatBox("Some Gangsters have joined you!", player, 0, 255, 0, true)
else
	outputChatBox("You need to be an admin to use this command!", player, 255, 0, 0, true)
end	
end
addCommandHandler("armyGang",spawnMineG)

-- Gives a Player Some Heavy Mercenaries
function spawnMineH (source, command, target)
if (isObjectInACLGroup ("user."..getAccountName(getPlayerAccount(source)),aclGetGroup("Admin"))) then

	local player = getPlayerFromName( tostring(target) )
	local x,y,z = getElementPosition (player)
	local rot = 90
	local skin = 285 -- S.W.A.T.
	local interior = getElementInterior(player)
	local dimension = 0
	local team = getPlayerTeam( player )
	local weapon = math.random(37, 38)
	local mode = "following"
	-- How Many Soldiers to Make
	for adx=0, 10, 1 do
		call (getResourceFromName("slothbot"), "spawnBot", x+math.random(-11,11), y+math.random(-11,11), z, rot, skin, interior, dimension, team, weapon, mode, player)
		weapon = math.random(37, 38)
	end
	outputChatBox("Some Mercenaries are working for you!", player, 0, 255, 0, true)
else
	ouputChatBox("You need to be an admin to use this command!", player, 255, 0, 0, true)
end
end
addCommandHandler("armyHeavy",spawnMineH)


-- Mouse Spawn
function spawnStand(mouseButton, buttonState, clickedElement, worldPosX, worldPosY, worldPosZ)
	--outputChatBox("STATESS:  "..mouseButton.."   "..buttonState.."")
	if mouseButton == "right" then
	if buttonState == "down" then
	
	local x = worldPosX
	local y = worldPosY
	local z = worldPosZ
	local rot = 90
	local skin = getPedSkin( source )
	local interior = getElementInterior(source)
	local dimension = 0
	local team = getPlayerTeam( source )
	local weapon = 0
	local mode
	if ( getPedWeapon(source) == 0 ) then -- If Player Has No Weapon
		weapon = math.random(22, 34) -- Give Random Weapon
	else
		weapon = getPedWeapon(source) -- Else Give Player's Weapon
	end
	local temp = getElementData(source, "mode")
	if temp then
		mode = temp
	else
		setElementData(source, "mode", "guarding")
		mode = "guarding"
	end
	local myBot = call (getResourceFromName("slothbot"), "spawnBot", x, y, z+1, rot, skin, interior, dimension, team, weapon, mode, player)
	setElementData( myBot, "owner", getPlayerName( source ) )
	if ( (clickedElement) and (getElementType( clickedElement ) == "vehicle") ) then
		local px, py, pz = getElementPosition(myBot)
		local vx, vy, vz = getElementPosition(clickedElement)
		local sx = px - vx
		local sy = py - vy
		local sz = pz - vz
			
		local rotpX = 0
		local rotpY = 0
		local rotpZ = getPedRotation(myBot)
			
		local rotvX,rotvY,rotvZ = getElementRotation(clickedElement)
			
		local t = math.rad(rotvX)
		local p = math.rad(rotvY)
		local f = math.rad(rotvZ)
			
		local ct = math.cos(t)
		local st = math.sin(t)
		local cp = math.cos(p)
		local sp = math.sin(p)
		local cf = math.cos(f)
		local sf = math.sin(f)
			
		local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
		local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
		local y = st*sz - sf*ct*sx + cf*ct*sy
			
		local rotX = rotpX - rotvX
		local rotY = rotpY - rotvY
		local rotZ = rotpZ - rotvZ
		attachElements( myBot, clickedElement, x, y, z, rotX, rotY, rotZ )
	end
	--createBlipAttachedTo(myBot, 0)
	outputDebugString(""..mode.."Bot Created at Mouse to Team: "..getTeamName(team).." by "..getPlayerName( source ))
	
	end
	end
	
end
addEventHandler("onPlayerClick",getRootElement(),spawnStand)

function killMyBots( source, command )
	bots = getElementsByType("ped")
	local ii = 0
	for i, ped in ipairs(bots) do
		if ( getElementData( ped, "owner") == getPlayerName( source ) ) then
			destroyElement( ped )
			ii = ii + 1
		end
	end
	outputDebugString(""..getPlayerName( source ).."'s bots have been destroyed! ("..ii..")")
	outputChatBox("Your bots have been destroyed! ("..ii..")", source, 0, 120, 120)
end
addCommandHandler("killMyBots", killMyBots)

function changeMode( source, command, str )
	if ( (str == "guarding") or (str == "following") or (str == "chasing") or (str == "waiting") or (str == "hunting") ) then
		setElementData(source, "mode", str)
		outputDebugString(""..getPlayerName(source).."'s Bot Mode set to: "..str)
		outputChatBox("#00FF00Your bot mode has been set to: "..str, source, 0, 0, 0, true)
	else
		outputDebugString("Invalid Bot Mode.  Valid Modes are: guarding, following, chasing, waiting, or hunting.")
		outputChatBox("#FF0000Invalid Bot Mode.", source, 255, 255, 255, true)
		outputChatBox("#FFFFFFValid Modes: #00FF00guarding waiting hunting", source, 255, 255, 255, true)
	end
end
addCommandHandler("botMode", changeMode)

-- Remove Function ///////////////////////////////////////////

-- Bots Remove
function killAllBots()
	local bots = getElementsByType( "ped" )
	local amount = 0
	for i,v in ipairs(bots) do
		amount = amount + 1
		destroyElement(v)
	end
	outputChatBox("All Bots Erased! ("..amount..")")
end
addCommandHandler ( "wipeout", killAllBots )

-- Vehicles Remove
function killAllVehicles()
	local cars = getElementsByType( "vehicle" )
	local amount = 0
	for i,v in ipairs(cars) do
		amount = amount + 1
		destroyElement(v)
	end
	outputChatBox("All Vehicles Erased! ("..amount..")")
end
addCommandHandler ( "poweroutage", killAllVehicles )

-- Objects Remove
function eraseWorld()
	local objs = getElementsByType( "object" )
	for i,v in ipairs(objs) do
		destroyElement(v)
	end
	outputChatBox("All Junk Erased!")
end
addCommandHandler ( "junk", eraseWorld )