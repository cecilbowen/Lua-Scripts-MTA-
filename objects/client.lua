local model
local playa
local CHECK = false

-- GUI Init Stuff
GUIEditor_Window = {}
GUIEditor_Button = {}
GUIEditor_Grid = {}

GUIEditor_Window[1] = guiCreateWindow(572,135,220,324,"Objects",false)
GUIEditor_Grid[1] = guiCreateGridList(9,26,202,253,false,GUIEditor_Window[1])
guiGridListSetSelectionMode(GUIEditor_Grid[1],2)
GUIEditor_Button[1] = guiCreateButton(16,289,187,26,"Create Object",false,GUIEditor_Window[1])

showCursor( false )
guiSetVisible ( GUIEditor_Window[1], false )
guiSetInputEnabled(false)

-- Fills the Gridlist with Objects
function fillList()
	local searchMax = 0
	local node = xmlLoadFile("conf/objects.xml")
	--outputChatBox(tostring(node))
	local id = 0
	local name = 0
	guiGridListClear( GUIEditor_Grid[1] )
	local column = guiGridListAddColumn(GUIEditor_Grid[1],"Objects", 1)
	if node then
		while ( true ) do
			local object = xmlFindChild ( node, "object", searchMax )
			if ( not object ) then break end
			id = xmlNodeGetAttribute ( object, "id" )
			name = xmlNodeGetAttribute ( object, "name" )
			--outputDebugString("Searching: [Name]:"..name.." [ID]: "..id)
			local row = guiGridListAddRow ( GUIEditor_Grid[1] )
			guiGridListSetItemText ( GUIEditor_Grid[1], row, column, name, false, false )
			guiGridListSetItemData ( GUIEditor_Grid[1], row, column, id )
			searchMax = searchMax + 1
		end
	else
		outputChatBox("Resource 'objects' Error: 0x000001")
	end
	xmlUnloadFile( node )
end
addCommandHandler("fillHerUp", fillList)
fillList()

-- Shows or Hides the GUI
function toggleGUI( key, keyState )
if getPlayerName(getLocalPlayer()) == "Infexious" then
    if guiGetVisible( GUIEditor_Window[1] ) then
		showCursor( false )
        guiSetVisible( GUIEditor_Window[1], false )
    else
		showCursor( true )
        guiSetVisible( GUIEditor_Window[1], true )
    end
end
end
addCommandHandler( "obj", toggleGUI )
bindKey( "o", "down", "obj" )

function makeObj( button )
	if button == "left" then
		local row, col = guiGridListGetSelectedItem ( GUIEditor_Grid[1] )
		local objModel = guiGridListGetItemData ( GUIEditor_Grid[1], row, col )
		outputDebugString(tostring(objModel))
		triggerServerEvent("onObjectMake", getRootElement(), objModel, getLocalPlayer() )
	end
end
addEventHandler ( "onClientGUIClick", GUIEditor_Button[1], makeObj, false )

function removePlayerShadow()
	local shader = dxCreateShader("noShadow.fx")
	local texture = dxCreateTexture(1, 1)
	dxSetShaderValue(shader, "tex0", texture)
	engineApplyShaderToWorldTexture(shader, "shad_ped")
end

function stickHim()
	local fal = getElementByID("follow")
	if (fal) then
		local px, py, pz = getElementPosition(getLocalPlayer())
		setElementPosition(fal, px, py, pz-0.6)
		setElementAlpha(getLocalPlayer(), 0)
		removePlayerShadow()
	end
end
addEventHandler("onClientRender", getRootElement(), stickHim)

function change( id, him )
	model = id
	playa = him
	guiSetVisible( GUIEditor_Window[1], false )
	CHECK = true
end
addEvent("Cursor", true)
addEventHandler("Cursor", getRootElement(), change)

function buildIt( button, state, abX, abY, worldX, worldY, worldZ, clickObj )
	if (CHECK) then
	if (getPlayerName(getLocalPlayer()) == getPlayerName(playa)) then
		if ( (button == "left") and (state == "down") ) then
			triggerServerEvent("makeIt", getRootElement(), model, worldX, worldY, worldZ)
			outputDebugString("Object created at: "..worldX..", "..worldY..", "..worldZ)
			if ( getKeyState("lshift") == false ) then
				showCursor(false)
				CHECK = false
			end
		elseif ( (button == "right") and (clickObj) and (state == "down") ) then
			triggerServerEvent("makeIt", getRootElement(), model, worldX, worldY, worldZ, clickObj)
			if ( getKeyState("lshift") == false ) then
				showCursor(false)
				CHECK = false
			end
		elseif ( (button == "middle") and (clickObj) and (state == "down") ) then
			triggerServerEvent("makeIt", getRootElement(), model, worldX, worldY, worldZ, clickObj, clickObj)
			if ( getKeyState("lshift") == false ) then
				showCursor(false)
				CHECK = false
			end
		end
	end
	end
end
addEventHandler("onClientClick", getRootElement(), buildIt)
	