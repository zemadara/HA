Func Courtyard()
	SkipCinematic()
	
	Local $team = GetTeamColour()
	PrintMapStart("Courtyard", $team)
	
	Local $mapStartFame = GetHeroTitleSafe()

	SleepIfMapJustStarted(30000)
	Upkeep()

	Out("Take ghostly")
	GoNpcLog(FindMyGhostly())

	While GetMapLoading() == $instancetype_explorable And GetMapID() == $courtyard

		If CheckIsTeamWiped() Then ExitLoop
		; Move to middle
		If $mapStartFame == GetHeroTitleSafe() Then
			;ComputeDistance
			If Not CheckArea(-75, 325) Then
				;If GetIsDead(GetMyID()) Then ExitLoop
				If GetIsLiving() Then
					If GetMapID() == $courtyard Then
						Out("lf enemies")
						Sleep(1000)
						MoveTo(-75, 325)
					EndIf
				EndIf
			EndIf
		EndIf

		; Kill nearby
		If $mapStartFame == GetHeroTitleSafe() Then
			Local $distance = GetDistance(GetBestTarget()) ;added
			If $distance < 1300 Then
				;If GetIsDead(GetMyID()) Then ExitLoop
				If GetIsLiving() Then
					If GetMapID() == $courtyard Then
						KillEnemy()
					EndIf
				EndIf
			EndIf
		EndIf

		; If my ghost is not nearby, go to my spawn and pick it up
		; TODO

		; Won
		If $mapStartFame < GetHeroTitleSafe() Then
			Out("Won in Courtyard")
			ExitLoop
		EndIf
	WEnd

	UpdateMapStats($mapStartFame, $courtyard, $team)
	WaitForNextMap($courtyard)
EndFunc   ;==>courtyard
