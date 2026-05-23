
Func GoldenGates()
	SkipCinematic()
	
	Local $team = GetTeamColour()
	PrintMapStart("Golden Gates", $team)
	
	Local $mapStartFame = GetHeroTitleSafe()

	SleepIfMapJustStarted(45000)
	Upkeep()

	If $team == $iamblue Then
		If StrongMoveTo(-1762.8,-1006.9) Then
			Out("Successfully opened gate as blue")
			Sleep(1000)
			MoveTo(-559.2,-1208.3) ; spot2
		Else
			Out("ERROR: Failed to open gate as blue")
		EndIf
	ElseIf $team == $iamred Then
		If StrongMoveTo(1656.4,1249.3) Then
			Out("Successfully opened gate as red")
			Sleep(1000)
			MoveTo(492.9,1624.4) ; spot2
		Else
			Out("ERROR: Failed to open gate as red")
		EndIf
	EndIf

	While GetMapLoading() == $instancetype_explorable And GetMapID() == $goldengates
		If CheckIsTeamWiped() Then ExitLoop

		Local $agent = GetNearestEnemyToAgent()
		Local $distance = GetDistance($agent, -2)
		Local $besttarget = GetBestTarget()
		If $mapStartFame == GetHeroTitleSafe() Then
			; No foes in range -> Hunt
			If GetNearestEnemyToAgent() = 0 Then
				If GetIsLiving() Then
					Out("lf enemies")
					MoveTo(-308, -950)
					Sleep(1000)
				EndIf
			EndIf
		EndIf

		If $mapStartFame == GetHeroTitleSafe() Then
			; Priest / distant enemy out of range -> Attack
			If $distance > 1300 And $distance < 5000 Then
				If GetIsLiving() Then
					If GetMapID() == $goldengates Then
						GoNPC($agent)
						Sleep(500)
						Attack($agent)
						Sleep(1500)
					EndIf
				EndIf
			EndIf
		EndIf

		If $mapStartFame == GetHeroTitleSafe() Then
			; Foe in range -> Kill
			If $distance < 1300 Then
				If GetIsLiving() Then
					If GetMapID() == $goldengates Then
						KillEnemy()
					EndIf
				EndIf
			EndIf
		EndIf

		If $mapStartFame < GetHeroTitleSafe() Then
			Out("Won in Golden Gates")
			ExitLoop
		EndIf
	WEnd

	UpdateMapStats($mapStartFame, $goldengates, $team)
	WaitForNextMap($goldengates)
EndFunc   ;==>goldengates
