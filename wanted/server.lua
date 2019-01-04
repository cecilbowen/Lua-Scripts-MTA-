-- Gamemode Variables
local WANTED -- The Wanted Player
local WANTED_MONEY_BASE = 50 -- The Starting Amount of Cash Gain Wanted Player Receives
local WANTED_MONEY = 50 -- The Amount of Money Wanted Player Receives Every Second
local WANTED_REWARD = 10000 -- The Amount of Money Player who Kills Wanted Player Receives
local INJUSTICE = 0 -- Police Fine Init
local FORMER -- The Former Wanted Player
local reward = false -- The Money Timer
local interior = 0
local wantedDead = false
local newTextItem
local timer

function policeMsg( player )
	textItemSetText(newTextItem, ""..getPlayerName(WANTED).." is the Wanted Player!")
	textDisplayAddObserver ( policeDisplay, player ) -- Add An Observer
end

function showPoliceMsg()
	for i, player in ipairs(getElementsByType("player")) do
		textDisplayRemoveObserver( policeDisplay, player ) -- Remove Text
	end
end

-- Wanted Message
function wantedMsg( player )
	local display = textCreateDisplay()
	textDisplayAddObserver ( display, player ) -- Add An Observer
	local newtextitem = textCreateTextItem ( "You're the Wanted Player!", 0.5, 0.5, "low", 255, 0, 0, 255, 3, "center", "center" ) -- Create Text
	textDisplayAddText( display, newtextitem ) -- Add Text to Display
	setTimer( textDestroyDisplay, 5000, 1, display ) -- Remove Text 5 Seconds Later
end

function weaponDeciding(res)
	local map = getResourceName(res)
	W_WEAPONS = {}
	P_WEAPONS = {}
	
	-- Starting Weapons for Wanted Player
	local weaponsString = get(map..".wanted")
	for i,weaponSub in ipairs(split(weaponsString,44)) do
		local weapon = tonumber(gettok ( weaponSub, 1, 58 ))
		local ammo = tonumber(gettok ( weaponSub, 2, 58 ))
		if weapon and ammo then
			W_WEAPONS[weapon] = ammo
		end
	end

	-- Starting Weapons for Police
	local weaponsString2 = get(map..".police")
	for i,weaponSub in ipairs(split(weaponsString2,44)) do
		local weapon = tonumber(gettok ( weaponSub, 1, 58 ))
		local ammo = tonumber(gettok ( weaponSub, 2, 58 ))
		if weapon and ammo then
			P_WEAPONS[weapon] = ammo
		end
	end
	
	-- Interior Setting
	interior = tonumber(get(map..".interior"))
	--setElementInterior( getRootElement(), interior )
	
	-- Police Message
	policeDisplay = textCreateDisplay() -- Create Display
	newtextitem = textCreateTextItem ( "", 0.5, 0.5, "low", 255, 0, 0, 255, 3, "center", "center" ) -- Create Text
	textDisplayAddText( policeDisplay, newtextitem ) -- Add Text to Display
	
	-----------------------------------------
	
	-- Global Spawn Vars
	playSpawn = getElementByIndex("spawn_police",0)
	wantSpawn = getElementByIndex("spawn_wanted",0)
	px, py, pz = getElementPosition(playSpawn)
	wx, wy, wz = getElementPosition(wantSpawn)
	globIntP = getElementData(playSpawn, "interior2")
	globIntW = getElementData(wantSpawn, "interior2")
	setElementInterior(playSpawn, globIntP)
	setElementInterior(wantSpawn, globIntW)
	outputDebugString("Wanted Interior Spawn: "..tostring(globIntW).." / Player Interior Spawn: "..tostring(globIntP))
	
	
	-- Getting Portals
	local portals = getElementsByType("portal")
	for i, portal in ipairs(portals) do
		setElementInterior(portal, getElementData(portal, "interior2"))
		local x, y, z = getElementPosition(portal)
		local marker = createMarker(x, y, z, "cylinder", 1.5, 0, 0, 255)
		setElementInterior(marker, getElementInterior(portal))
		setElementData(marker, "Name", getElementData(portal, "Name"))
		setElementData(marker, "link", getElementData(portal, "link"))
		setElementData(marker, "interior2", getElementData(portal, "interior2"))
		
		addEventHandler("onMarkerHit", marker, throughPortal)
		addEventHandler("onMarkerLeave", marker, leavePortal)
	end

	-- Mode Init Stuff
	for i, player in ipairs(getElementsByType("player")) do
		setPlayerMoney(player, 0) -- Remove All Player's Cash
		setPlayerWantedLevel(player, 0) -- Remove All Player's Wanted Level
		setElementModel(player, 0) -- Set Everyone's Skin to CJ
	end
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Rank")
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Type")
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "$$$")

	-- Random Picking of Wanted Player
	WANTED = getRandomPlayer()

	setTimer(updateBoard, 3000, 1)
	
	newTextItem = textCreateTextItem ( ""..getPlayerName(WANTED).." is the Wanted Player!", 0.5, 0.5, "low", 255, 0, 0, 255, 3, "center", "center" ) -- Create Text
	textDisplayAddText( policeDisplay, newTextItem ) -- Add Text to Display

	-- Spawn Wanted Player
	spawnWanted(WANTED)
	
	-- Spawn All Others
	for i,player in ipairs(getElementsByType("player")) do
		if (player ~= WANTED) then
			spawnPolice(player)
		end
	end
	
	-- Init the Money Timer
	reward = true
	setTimer(moneyMe, 1000, 1)
	
	-- Create the Wanted Marker
	local wantMarker = createMarker(0, 0, 0, "arrow", 2, 0, 155, 100, 200) -- Marker that Follows Wanted Player
	--setElementCollisionsEnabled(wantMarker, false) -- Make it Non-Collidable with Anything
	setElementID(wantMarker, "wntdMarker") -- Variable to Retrieve Client-Side
	
	-- Vehicle Respawn Limit
	for i, vehicle in ipairs(getElementsByType("vehicle")) do
		toggleVehicleRespawn(vehicle, true)
		setVehicleIdleRespawnDelay(vehicle, 30000)
	end
	
	-- Create Police Blips
	--for i, player in ipairs(getElementsByType("player")) do
		--local blip = createBlipAttachedTo(player)
		--setElementVisibleTo(blip, WANTED, false)
	--end
end
addEventHandler("onGamemodeMapStart", getRootElement(), weaponDeciding)

function throughPortal(element, sameDimension)
	local data = getElementData(element, "inportal")
	if (sameDimension and data == 0) then
		setElementData(element, "inportal", 1)
		--local letsWarp = getElementData(source, "toInterior")
		local which = getElementData(source, "link")
		outputDebugString("Source portal link: "..tostring(which).." / interior: "..tostring(getElementInterior(source)))
		local link = "X"
		if (which == "A") then
			link = "B"
		elseif (which == "B") then
			link = "A"
		end
		
		local name = getElementData(source, "Name")
		local toWhere = nil
		if (which ~= false) then
			for i, colshape in ipairs(getElementsByType("marker")) do
				if (getElementData(colshape, "Name") == name) then
					local toLink = getElementData(colshape, "link")
					
					if (toLink == link) then
						toWhere = colshape
						outputDebugString("Other side link: "..tostring(toLink).." / interior: "..tostring(getElementInterior(colshape)))
					end
				end
			end
			
			if (toWhere ~= nil) then
				local x, y, z = getElementPosition(toWhere)
				if (getElementType(element) == "vehicle") then
					if (getPedOccupiedVehicle(element)) then
						local playaOnVehicle = getPedOccupiedVehicle(element)
							setElementInterior(playaOnVehicle, getElementInterior(toWhere))
							setElementPosition(playaOnVehicle, x, y, z+1)
							setElementInterior(element, getElementInterior(toWhere))
							setElementPosition(element, x, y, z+1)
							return
					end
				end
				setElementInterior(element, getElementInterior(toWhere))
				setElementPosition(element, x, y, z+1)
			else
				outputDebugString("ERROR: Portal link not found!")
			end
		end
	end
end

function leavePortal(element, sameDimension)
	local data = getElementData(element, "inportal")
	if (sameDimension and data == 1) then
		setTimer(function() setElementData(element, "inportal", 0) end, 1500, 1)
	end
end

function spawnPolice( player )
	--fadeCamera(player, false, 2)
	spawnPlayer(player, px+math.random(-1,1), py+math.random(-1,1), pz+2)
	setElementData(player, "inportal", 0)
	fadeCamera(player, true)
	setCameraTarget(player, player)
	--setElementInterior( player, interior )
	setElementInterior(player, getElementInterior(playSpawn))
	setElementModel(player, 0)
	wantedClothes(player, false)
	local blip = createBlipAttachedTo(player, 0, 2, 0, 0, 255)
	setElementData(blip, "owner", 1) --cecil-new
	setElementVisibleTo(blip, getRootElement(), false)
	local myMarker = getElementByID("wntdMarker")
	setElementVisibleTo(myMarker, player, true)
	for i, guy in ipairs(getElementsByType("player")) do
		if (guy ~= WANTED) then 
			setElementVisibleTo(blip, guy, true)
		end
	end
	
	for wep, ammo in pairs(P_WEAPONS) do	
		giveWeapon(player, wep, ammo)
	end
end

function spawnWanted( player )
	--fadeCamera(player, false, 2)
	spawnPlayer(player, wx, wy, wz+2)
	setElementData(player, "inportal", 0)
	fadeCamera(player, true)
	setCameraTarget(player, player)
	setElementInterior(player, getElementInterior(wantSpawn))
	--setElementInterior( player, interior )
	setElementModel(player, 0)
	wantedClothes(player, true)
	local myMarker = getElementByID("wntdMarker")
	setElementVisibleTo(myMarker, player, false)
	
	for wep, ammo in pairs(W_WEAPONS) do
		giveWeapon(player, wep, ammo)
	end
end

-- When a Player Dies...
function checkDeath( ammo, murderer, weapon, part )
--if (murderer and getElementType(murderer) == "vehicle") then outputDebugString("XXXXXXXX: "..tostring(murderer)) end
--outputDebugString("source: "..tostring(getElementType(source)).." / murderer: "..tostring(getElementType(murderer)))
if (wantedDead == false) then
local theGuy = murderer
local str = "null"
if (getElementType(theGuy) == "player") then
	str = getPlayerName(theGuy)
else
	str = tostring(theGuy)
end
outputDebugString(""..getPlayerName(source).." just died by "..tostring(str))
	if (source == WANTED) then -- If Wanted Player Dies...
		wantedDead = true
		if ( (murderer) and (murderer ~= WANTED) and (getElementType(murderer) ~= "vehicle") ) then -- If the Player Didn't Have an Accident (or Kill Himself)...
			-- Money Giving
			reward = false -- Stop the Money Timer
			local give -- Amount of Money to Give
			if ( part == 9 ) then
				give = WANTED_REWARD + (WANTED_REWARD/2)
				outputChatBox("+$"..give.." - Headshot!", murderer, 0, 255, 0, true )
			else
				give = WANTED_REWARD
				outputChatBox("+$"..give.."", murderer, 0, 255, 0, true )
			end
			givePlayerMoney( murderer, give )
			
			-- Old Wanted Player
			WANTED = murderer -- Change the Wanted Player
			
			-- Creating Weapon/Armor Pickups from Former Wanted Player
			local x, y, z = getElementPosition(source)
			for i=0, 12, 1 do
				local wep = getPedWeapon(source, i)
				local amm = getPedTotalAmmo(source, i)
				if (wep ~= 0) and (amm ~= 0) then
					local oldWeapon = createPickup(x+math.random(-1,1), y+math.random(-1,1), z, 2, wep, 3600000, amm)
					setElementInterior( oldWeapon, getElementInterior( source ) )
				end
			end
			local armor = getPedArmor(source)
			if (armor > 0) then
				local oldArmor = createPickup(x+math.random(-1,1), y+math.random(-1,1), z, 1, armor, 3600000)
				setElementInterior( oldArmor, getElementInterior( source ) )
			end
			
			-- New Wanted Player
			wantedClothes(WANTED, true)
			
			-- Start the Money Timer
			reward = true
			setTimer(moneyMe, 1000, 1)
		else
			reward = false
			outputChatBox("The Wanted Player has had a fatal accident!", getRootElement(), 0, 0, 255, true )
			FORMER = WANTED
			repeat WANTED = getRandomPlayer() until (WANTED ~= FORMER) -- This Lags It A Bit - New Method Coming Soon
			wantedClothes(WANTED, true)
			reward = true
			setTimer(moneyMe, 1000, 1)
		end
	elseif (murderer) and (murderer ~= WANTED) and (getElementType(murderer) ~= "vehicle") then -- Wanted Player Didn't Die So...  If No Accident Happened and Police Killed Fellow Police...
		local fine = getPlayerMoney(murderer)/2
		if (INJUSTICE > fine) then
			fine = INJUSTICE
		end
		outputChatBox("-$"..tostring(fine).." - In-Justice Fine", murderer, 255, 0, 0, true )
		givePlayerMoney( murderer, fine )
	elseif (murderer) and (murderer == WANTED) then -- If Wanted Player Kills Player...
		local level = getPlayerWantedLevel(murderer)
		if (level < 6) then
			setPlayerWantedLevel(murderer,level+1)
			WANTED_MONEY = WANTED_MONEY+10
			outputChatBox("You gained another star!  You're cash gain increased! ("..WANTED_MONEY..")", murderer, 0, 255, 0)
			if (getPlayerWantedLevel(murderer) == 6) then
				for i=69, 80, 1 do
					setPedStat(murderer, i, 1000)
				end
				outputChatBox("You have gained the max Wanted Level!  Your weapon skills are now maxed!", murderer, 0, 255, 0)
				triggerClientEvent(WANTED, "onGainMaxLevel", getRootElement())
			end
		end
	elseif (getElementType(murderer) == "vehicle") then
		outputDebugString("Policeman killed by vehicle...")
	end
	
	--Eliminate the Dead Blips
	for i, blip in ipairs(getElementsByType("blip")) do
		if (getElementData(blip, "owner") == 1) then
			outputDebugString("Destroyed dead policeman blip!")
			destroyElement(blip)
		end
	end
	
	-- Spawn the Player that Died (if Not Wanted Player)
	setTimer(spawnPolice, 3000, 1, source)
elseif (wantedDead) then
	outputDebugString("Close death encountered for "..getPlayerName(source).."; suspending respawn.")
	setTimer(redoDeath, 3000, 1, source, ammo, murderer, weapon, part)
end
end
addEventHandler("onPlayerWasted", getRootElement(), checkDeath)

function heBailed()
	if (source == WANTED) then
		reward = false
		outputChatBox("The Wanted Player has quit!", getRootElement(), 225, 0, 30, true )
		outputDebugString("The Wanted Player has left the game. Panicking... Picking random player...")
		WANTED = getRandomPlayer()
		wantedClothes(WANTED, true)
		reward = true
		setTimer(moneyMe, 1000, 1)
		outputDebugString(""..getPlayerName(WANTED).." successfully chosen randomly as the Wanted Player!")
	end
end
addEventHandler("onPlayerQuit", getRootElement(), heBailed)	

function redoDeath( player, ammo, murderer, weapon, part )
	outputDebugString("Re-Triggering respawn event for "..getPlayerName(player))
	triggerEvent("onPlayerWasted", player, ammo, murderer, weapon, part)
end

function moneyMe()
	if (reward) then
		givePlayerMoney(WANTED, WANTED_MONEY)
		setTimer(moneyMe, 1000, 1)
	end
end

-------------------------------
function sortingFunction (a,b)
	return (getElementData(a,"$$$") or 0) > (getElementData(b,"$$$") or 0)
end

function updateBoard()
	-- Score (Money)
	for i, player in ipairs(getElementsByType("player")) do
		setElementData(player, "$$$", getPlayerMoney(player) ) -- Adds Player's Money as Their Score
		if (player == WANTED) then
			setElementData(player, "Type", "wanted" )
		else
			setElementData(player, "Type", "police" )
		end
	end
	
	--Calculate the ranks
	local ranks = {}
	local players = getElementsByType( "player" )
	table.sort ( players, sortingFunction )
	
	--Take Into Account People With Same Score
	for i,player in ipairs(players) do
		local previousPlayer = players[i-1]
		if players[i-1] then
			local previousScore = getElementData ( previousPlayer, "$$$" )
			local playerScore = getElementData ( player, "$$$" ) 
			if previousScore == playerScore then
				setElementData ( player, "Rank", getElementData( previousPlayer, "Rank" ) )
			else
				setElementData ( player, "Rank", i )
			end
		else
			setElementData ( player, "Rank", 1 )
		end
	end
	setTimer(updateBoard, 1500, 1)
end
-----------------------------------------

function joinMe()
	spawnPolice(source)
end
addEventHandler("onPlayerJoin", getRootElement(), joinMe)

-- Accesorize the Player with Specified Clothes
function wantedClothes(player, add)
	if add then
		-- Add Wanted Clothes
		WANTED_MONEY = WANTED_MONEY_BASE
		setElementID(WANTED, "wntd")
		setPlayerWantedLevel(player, 1)
		removePedClothes(player, 17)
		addPedClothes(player, "cowboy", "cowboy", 16)
		addPedClothes(player, "leather", "leather", 0)
		addPedClothes(player, "leathertr", "leathertr", 2)
		addPedClothes(player, "cowboyboot", "biker", 3)
		addPedClothes(player, "neckdollar", "neck", 13)
		addPedClothes(player, "7CROSS", "7cross", 7)
		wantedDead = false
		-- "Police" Message
		for i, p in ipairs(getElementsByType("player")) do
			if (p ~= WANTED) then
				policeMsg(p)
			end
		end
		setTimer(showPoliceMsg, 5000, 1)
		wantedMsg(WANTED)
	else -- Add Police Clothes
		setElementID(player, "former"..tostring(math.random(1,100)))
		setPlayerWantedLevel(player, 0)
		removePedClothes(player, 7)
		removePedClothes(player, 13)
		removePedClothes(player, 3)
		removePedClothes(player, 2)
		removePedClothes(player, 0)
		removePedClothes(player, 16)
		-- Downgrades Weapon Stats to 0
		for i=69, 80, 1 do
			setPedStat(player, i, 0)
		end
		addPedClothes(player, "policetr", "policetr", 17)
	end
end

function dieMe(source)
	killPed(source)
end
addCommandHandler( "kill", dieMe )
bindKey( "enter", "down", "kill" )

-- Tries to Prevent Damage to Players When There is No Wanted Player
function noDamage()
	if (reward == false) then
		outputDebugString("PLAYER "..getPlayerName(source).." is not taking damage!")
		cancelEvent()
	end
end
addEventHandler("onPlayerDamage", getRootElement(), noDamage)

-----------------------------------------------------------------
-- Shop Functions -----------------------------------------------
-----------------------------------------------------------------
function giveArmor( player, cost )
	setPedArmor(player, 100)
	givePlayerMoney( player, -cost )
end
addEvent("buyArmor", true)
addEventHandler("buyArmor", getRootElement(), giveArmor)

function giveWep( player, weapon, ammo, cost )
	giveWeapon( player, weapon, ammo, true )
	givePlayerMoney( player, -cost )
end
addEvent("buyWeapon", true)
addEventHandler("buyWeapon", getRootElement(), giveWep)

function giveVec( player, vehicle, cost )
	local x, y, z = getElementPosition( player )
	local myCar = createVehicle( vehicle, x, y, z )
	setElementInterior( myCar, getElementInterior( player ) )
	warpPedIntoVehicle( player, myCar )
	givePlayerMoney( player, -cost )
end
addEvent("buyVehicle", true)
addEventHandler("buyVehicle", getRootElement(), giveVec)