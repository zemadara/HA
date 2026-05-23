
Func HallOfHeroes()
	SkipCinematic()
	
	Local $team = GetTeamColour()
	PrintMapStart("Hall of Heroes", $team)

	If GUICtrlRead($cbxLeaveBeforeHalls) == $GUI_CHECKED Then
		Out("Error: Somehow got to Halls!")
		TravelTo($ha)
	EndIf

	Local $lWonHoH = GetHeroTitleSafe()

	SleepIfMapJustStarted(15000)
	Upkeep()

	Sleep(3000)
	Out("Take ghostly")
	GoNpcLog(FindMyGhostly())
	Sleep(5000)

	TargetNearestItem()
	Sleep(GetPing()+100)
	If GetCanPickup(GetTarget()) Then
		Out("I think this is relic run")
		PickupLoot()
	Else
		Out("No relic found")
	EndIf

	While GetMapLoading() == $instancetype_explorable And GetMapID() == $hoh
		Local $agent = GetBestTarget()
		Local $distance = GetDistance($agent, -2)
		If CheckIsTeamWiped() Then ExitLoop

		; Escourt Ghost
		If $lWonHoH == GetHeroTitleSafe() Then
			Local $myGhost = FindMyGhostly()
			Local $distanceToGhost = GetDistance(-2, $myGhost)
			Out ("Distance to Ghost " & $distanceToGhost)
			If GetIsLiving() And IsDllStruct($myGhost) And $distanceToGhost > $rangeCompass Then
				GoNpcLog($myGhost)
			EndIf
			ContinueLoop
		EndIf

		; Kill straglers
		If CountEnemies($rangeCompass) > 0 Then
			Out("Killing stragglers")
			KillEnemy($rangeCompass)
			ContinueLoop
		EndIf

		If $lWonHoH == GetHeroTitleSafe() Then
			If Not CheckArea(26.6,6238) Then
				If GetIsLiving() Then
					If GetMapID() == $hoh Then
						Out("Halls: Moving to centre")
						;TODO make this "move aggroing"; catch people at our base
						MoveTo(26.6,6238)
						Sleep(1000)
					EndIf
				EndIf
			EndIf
		EndIf
		If $lWonHoH == GetHeroTitleSafe() Then
			Out("Halls: kill")
			Local $distance = GetDistance(GetBestTarget())
			If $distance < 1300 Then
				KillEnemy()
			EndIf
			Sleep(1000)
		EndIf
		If $lWonHoH < GetHeroTitleSafe() Then
			If GetMapID() == $hoh Then
				Out("Halls: WON HALLS")
				;RecordVictory($hoh)
				$lWonHoH = GetHeroTitleSafe() ; Will make UpdateMapStats record a victory

				GetHallsChest()

				; Not easy to tell new map.
				; Get position, wait for it to change.
				If Not CheckArea(2.4, 4861.8) Then
					Out("ERROR: Wait, not inside the chest area?")
					MoveTo(2.4, 4861.8)
				EndIf
				While(CheckArea(2.4, 4861.8))
					WaitMapLoading(0, 60000)
					Out("Waiting for next halls instance")
				WEnd
				Out("Next instance of halls")
				ExitLoop
			EndIf
		EndIf
	Wend

	UpdateMapStats($lWonHoH, $hoh, $team)
EndFunc   ;==>hoh


Func GetHallsChest()
	;0,4747.5
	Local $inventoryBefore = CountBagsFreeSlots()
	While GetMapLoading() == $instancetype_explorable And GetMapID() == $hoh
		If Not GetIsLiving() Then
			Out("ERROR: Halls: Died trying to get chest...?")
			;Return
		EndIf

		If Not CheckArea(2.4, 4861.8) Then
			Out("Halls: Moving to chest")
			MoveTo(2.4, 4861.8)
			Sleep(1000)
		Else
			TargetNearestItem()
			Sleep(100)
			Out("Halls: Open chest")
			ActionInteract()
			Sleep(5000)
			Out("Halls: Loot")
			PickupLoot()
			;TODO log inventory status
		EndIf

		Local $inventoryAfter = CountBagsFreeSlots()
		If $inventoryAfter < $inventoryBefore Then
			Out("Picked up something! (" & $inventoryAfter & " > " & $inventoryBefore & ")")
			ExitLoop
		EndIf
	WEnd
	Out("Halls: Done with chest")
EndFunc
