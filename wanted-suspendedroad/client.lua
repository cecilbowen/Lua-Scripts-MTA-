function checkForFallingPlayers()
	if ((isElementInWater(getLocalPlayer())) and (getElementHealth(getLocalPlayer()) > 0)) then
		triggerServerEvent("onPlayerFallInWater", getRootElement(), getLocalPlayer())
	end
end
addEventHandler("onClientRender", getRootElement(), checkForFallingPlayers)