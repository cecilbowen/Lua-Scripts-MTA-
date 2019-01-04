function killTheGuy(player, killer, weapon, bodypart)
	killPed(player, killer, weapon, bodypart)
end
addEvent("killTheGuy", true)
addEventHandler("killTheGuy", getRootElement(), killTheGuy)