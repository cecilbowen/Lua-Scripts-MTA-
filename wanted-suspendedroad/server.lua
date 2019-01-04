function inTheWater(player)
	killPed(player)
end
addEvent("onPlayerFallInWater", true)
addEventHandler("onPlayerFallInWater", getRootElement(), inTheWater)