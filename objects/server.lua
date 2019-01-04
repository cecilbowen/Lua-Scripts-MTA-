function buildObject( id, creator )
	local x, y, z = getElementPosition( creator )
	--local thing = createObject( id, x + 3, y, z )
	triggerClientEvent("Cursor", getRootElement(), id, creator)
end
addEvent("onObjectMake", true)
addEventHandler("onObjectMake", getRootElement(), buildObject)

function buildObject2( id, x, y, z, del, seethrough )
	if (del) then
		local a, b, c = getElementPosition(del)
		outputDebugString("Destroyed object at: "..a..", "..b..", "..c)
		destroyElement(del)
	else
		local thing = createObject( id, x, y, z+0.5 )
		if (seethrough) then
			setElementCollisionsEnabled(thing, false)
			setElementID(thing, "follow")
		end
	end
end
addEvent("makeIt", true)
addEventHandler("makeIt", getRootElement(), buildObject2)

