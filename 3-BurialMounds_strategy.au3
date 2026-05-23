
Func BurialMounds()
	SkipCinematic()

	Local $team = GetTeamColour()
	PrintMapStart("Burial Mounds", $team)

	Local $mapStartFame = GetHeroTitleSafe()

	SleepIfMapJustStarted(55000)
	Upkeep()

	While GetMapLoading() == $instancetype_explorable And GetMapID() == $burialmounds
		Local $agent = GetBestTarget()
		Local $distance = GetDistance($agent, -2)
		If CheckIsTeamWiped() Then ExitLoop
		If $mapStartFame == GetHeroTitleSafe() Then
			If GetNearestEnemyToAgent() = 0 Then
				If GetIsLiving() Then
					If GetMapID() == $burialmounds Then
						Out("lf enemies")
						Sleep(1000)
						Move(-4214, 3251)
					EndIf
				EndIf
			EndIf
		EndIf
		If $mapStartFame == GetHeroTitleSafe() Then
			If $distance > 1250 And $distance < 10000 Then
				If GetIsLiving() Then
					If GetMapID() == $burialmounds Then
						Attack($agent)
						Sleep(1500)
					EndIf
				EndIf
			EndIf
		EndIf
		If $mapStartFame == GetHeroTitleSafe() Then
			If $distance < 1250 Then
				If GetIsLiving() Then
					If GetMapID() == $burialmounds Then
						KillEnemy()
					EndIf
				EndIf
			EndIf
		EndIf
		If $mapStartFame < GetHeroTitleSafe() Then
			Out("Won in Burial")
			ExitLoop
		EndIf
	WEnd

	UpdateMapStats($mapStartFame, $burialmounds, $team)
	WaitForNextMap($burialmounds)
EndFunc   ;==>burialmounds
