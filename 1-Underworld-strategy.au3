Func Underworld()
	SkipCinematic()

	Local $team = GetTeamColour()
	PrintMapStart("Underworld", $team)

	Local $mapStartFame = GetHeroTitleSafe()

	Sleep(50000)
	Upkeep()

	If $team == $iamblue Then
		Out("Moving blue to starting spot")
		If Not StrongMoveTo(-365.7,-3251.2) Then
			Out("ERROR: Failed to go to blue starting spot")
		EndIf
		ElseIf $team == $iamred Then
		Out("Moving red to starting spot")
		If Not StrongMoveTo(740,-3234.1) Then
			Out("ERROR: Failed to go to red starting spot")
		EndIf
	EndIf

	While GetMapLoading() == $instancetype_explorable And GetMapID() == $uw
		If CheckIsTeamWiped() Then ExitLoop

		TargetNearestEnemy()
		;Local $agent = GetTarget()
		;Local $distance = GetDistance($agent, -2)
		Local $agent = GetBestTarget()
		Local $distance = GetDistance($agent, -2)
		;Out($distance)

		If $mapStartFame == GetHeroTitleSafe() Then
			If $distance > 1250 And $distance < 8000 Then
				If GetIsLiving() Then
					Attack($agent)
					Sleep(1500)
				EndIf
			ElseIf $distance <= 1250 Then
				KillEnemy()
			ElseIf GetNearestEnemyToAgent() = 0 Then
				If GetIsLiving() Then
					Sleep(1000)
					Move(67, -3341)
				EndIf
			EndIf
		EndIf
		If $mapStartFame < GetHeroTitleSafe() Then
			Out("Won in UW")
			ExitLoop
		EndIf
	WEnd

	UpdateMapStats($mapStartFame, $uw, $team)
	WaitForNextMap($uw)
EndFunc   ;==>uw