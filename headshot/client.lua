function hShot( killer, action, bodypart )
	--outputDebugString("bodypart: "..bodypart)
	if (bodypart == 9 or bodypart == 1033) then
		--outputDebugString("HEADSHOT BEEEYOTCHHHHHHHH!")
		playSound("headshot.mp3", 0)
	end
end
addEventHandler("onClientPlayerWasted", getRootElement(), hShot)

function hDamage( attacker, weapon, bodypart, loss )
	if (bodypart == 9 or bodypart == 1033) then -- If Player Hit in Head...
		triggerServerEvent("killTheGuy", getRootElement(), source, attacker, weapon, bodypart)
	    --killPlayer(source, attacker, weapon, bodypart)
	end
end
addEventHandler ( "onClientPlayerDamage", getRootElement(), hDamage )