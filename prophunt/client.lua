local armorCost = 75000
local WEAPONS =
{
	-- Format: [ID],[AMMO],[COST]
	{22,100,1000}, -- Pistol
	{24,100,1200}, -- Desert Eagle
	{6,1,1000}, -- Shovel
	{9,1,25000}, -- Chainsaw
	{25,500,50000}, -- Shotgun
	{26,500,60000}, -- Sawn-Off
	{27,500,60000}, -- SPAZ-12
	{28,500,60000}, -- Uzi
	{29,500,75000}, -- MP5
	{32,500,75000}, -- Tec-9
	{31,500,70000}, -- M4
	{34,500,75000}, -- Sniper
	{35,10,120000}, -- Rocket
	{36,10,150000}, -- Rocket HS
	{37,300,150000}, -- Flamethrower
	{38,1000,200000}, -- Minigun
	{16,50,75000}, -- Grenade
	{17,50,50000}, -- Teargas
	{39,50,80000}, -- Satchel
	{45,1,60000} -- Infrared Goggles
}

local VEHICLES =
{
	-- Format: [ID],[COST]
	{568,75000}, -- Bandito
	{444,100000}, -- Monster
	{539,100000}, -- Vortex
	{429,120000}, -- Banshee
	{415,120000}, -- Cheetah
	{451,120000}, -- Turismo
	{411,130000}, -- Infernus
	{603,80000}, -- Phoenix
	{536,80000}, -- Blade
	{535,80000}, -- Slamvan
	{578,90000}, -- DFT-30
	{515,85000}, -- Roadtrain
	{406,200000}, -- Dumper
	{601,100000}, -- S.W.A.T.
	{599,75000}, -- Police Ranger
	{431,75000}, -- Bus
	{420,75000}, -- Taxi
	{452,90000}, -- Speeder
	{430,100000}, -- Predator
	{586,80000}, -- Wayfayer
	{522,90000}, -- NRG-500
	{479,50000}, -- Regina
	{540,50000} -- Vincent
}

function patrick()
	local muff = playSound("patrick.mp3", 0)
	--setSoundVolume(muzz, 0.7)
end
addEvent("onGainMaxLevel", true)
addEventHandler("onGainMaxLevel", getRootElement(), patrick)

-- Shop GUI
function initGUI()
	mainWindow = guiCreateWindow(16,15,768,408,"Shop",false)
	
	gridVehicles = guiCreateGridList(395,34,356,170,false,mainWindow)
	guiGridListSetSelectionMode(gridVehicles,2)
	gridWeapons = guiCreateGridList(17,34,356,170,false,mainWindow)
	guiGridListSetSelectionMode(gridWeapons,2)
	
	buttonWeapon = guiCreateButton(52,215,289,42,"Buy for $",false,mainWindow)
	buttonVehicle = guiCreateButton(431,215,289,42,"Buy for $",false,mainWindow)
	buttonArmor = guiCreateButton(240,283,289,42,"Buy Armor Vest for $75000",false,mainWindow)
	guiSetEnabled(buttonWeapon, false)
	guiSetEnabled(buttonVehicle, false)
	buttonClose = guiCreateButton(736,381,23,18,"x",false,mainWindow)
	addEventHandler ( "onClientGUIClick", buttonClose, toggleGUI, false )
	addEventHandler ( "onClientGUIClick", buttonArmor, giveArmor, false )
	addEventHandler ( "onClientGUIClick", buttonVehicle, giveVec, false )
	addEventHandler ( "onClientGUIClick", buttonWeapon, giveWep, false )
	
	labelMoney = guiCreateLabel(203,333,344,53,"Money: ",false,mainWindow)
	guiLabelSetColor(labelMoney,5,200,50)
	guiLabelSetVerticalAlign(labelMoney,"center")
	guiLabelSetHorizontalAlign(labelMoney,"center",false)
	guiSetFont(labelMoney,"sa-gothic")
	
	-- Fill Gridlists
	guiGridListClear( gridVehicles )
	guiGridListClear( gridWeapons )
	local columnA = guiGridListAddColumn(gridWeapons,"Weapon", 1)
	local columnB = guiGridListAddColumn(gridVehicles,"Vehicle", 1)
	
	if columnA then
		for i, wep in ipairs(WEAPONS) do
			local row = guiGridListAddRow ( gridWeapons )
			local wepID = WEAPONS[i][1]
			local text = getWeaponNameFromID( wepID )
			guiGridListSetItemText ( gridWeapons, row, columnA, text, false, false )
			guiGridListSetItemData ( gridWeapons, row, columnA, wepID )
		end
	end
	if columnB then
		for i, vec in ipairs(VEHICLES) do
			local row = guiGridListAddRow ( gridVehicles )
			local vecID = VEHICLES[i][1]
			local text = getVehicleNameFromModel( vecID )
			guiGridListSetItemText ( gridVehicles, row, columnB, text, false, false )
			guiGridListSetItemData ( gridVehicles, row, columnB, vecID )
		end
	end
	
	guiSetVisible( mainWindow, false )
end
addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource() ), initGUI)

-- Shows/Hides the GUI
function toggleGUI()
    if guiGetVisible( mainWindow ) then
		showCursor( false )
        guiSetVisible( mainWindow, false )
    else
		showCursor( true )
        guiSetVisible( mainWindow, true )
    end
end
addCommandHandler( "shop", toggleGUI )
bindKey( "F1", "down", "shop" )

function giveArmor( button, state )
	if button == "left" then
		local player = getLocalPlayer()
		local money = getPlayerMoney( player )
		if (money > armorCost) then
			outputDebugString(""..getPlayerName(player).." has bought Armor for $"..tostring(armorCost)..".")
			triggerServerEvent("buyArmor", getRootElement(), player, armorCost)
		end
	end
end

function giveWep( button, state )
	if button == "left" then
		local player = getLocalPlayer()
		local money = getPlayerMoney( player )
		local row, column = guiGridListGetSelectedItem( gridWeapons )
		local wep = WEAPONS[row+1][1]
		local cost = WEAPONS[row+1][3]
		local ammo = WEAPONS[row+1][2]
		if (money > cost) then
			outputDebugString(""..getPlayerName(player).." has bought a "..getWeaponNameFromID(wep).." for $"..tostring(cost)..".")
			triggerServerEvent("buyWeapon", getRootElement(), player, wep, ammo, cost)
		end
	end
end

function giveVec( button, state )
	if button == "left" then
		local player = getLocalPlayer()
		local money = getPlayerMoney( player )
		local row, column = guiGridListGetSelectedItem( gridVehicles )
		local vec = VEHICLES[row+1][1]
		local cost = VEHICLES[row+1][2]
		if (money > cost) then
			outputDebugString(""..getPlayerName(player).." has bought a "..getVehicleNameFromModel(vec).." for $"..tostring(cost)..".")
			triggerServerEvent("buyVehicle", getRootElement(), player, vec, cost)
		end
	end
end

function updateButtons()
	local money = getPlayerMoney( getLocalPlayer() )
	guiSetText(labelMoney, "Money: "..tostring(money))
	local rowA, columnA = guiGridListGetSelectedItem( gridWeapons )
	local rowB, columnB = guiGridListGetSelectedItem( gridVehicles )
	if (rowA ~= -1) then
		local costA = WEAPONS[rowA+1][3]
		guiSetText(buttonWeapon, "Buy for $"..costA)
		if (money > costA) then
			guiSetEnabled(buttonWeapon, true)
		else
			guiSetEnabled(buttonWeapon, false)
		end
	end
	
	if (rowB ~= -1) then
		local costB = VEHICLES[rowB+1][2]
		guiSetText(buttonVehicle, "Buy for $"..costB)
		if (money > costB) then
			guiSetEnabled(buttonVehicle, true)
		else
			guiSetEnabled(buttonVehicle, false)
		end
	end
	
	if (money > armorCost) then
		guiSetEnabled(buttonArmor, true)
	else
		guiSetEnabled(buttonArmor, false)
	end
end
addEventHandler("onClientRender", getRootElement(), updateButtons)

-----------------------------------------------------------------------
-- Wanted Marker
function stickToMarker()
	local follow = getElementByID("wntd") -- The Wanted Player
	if (follow == false) then return end
	local wanted = (getPedOccupiedVehicle(follow)) or (follow) -- Take Players in Vehicles to Account Too
	local marker = getElementByID("wntdMarker") -- The Wanted Marker
	--setElementCollisionsEnabled(marker, false)
	if (wanted) and (marker) then
		local mInt = getElementInterior( marker )
		local wInt = getElementInterior( wanted )
		if (mInt ~= wInt) then setElementInterior( marker, wInt ) end
		local x, y, z = getElementPosition(wanted)
		setElementPosition(marker, x, y, z+4)
	end
end
addEventHandler("onClientPreRender", getRootElement(), stickToMarker)