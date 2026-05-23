
Func Antechamber()
	SkipCinematic()
	
	Local $team = GetTeamColour()
	PrintMapStart("Antechamber", $team)
	
	Local $mapStartFame = GetHeroTitleSafe()

	SleepIfMapJustStarted(30000)
	Upkeep()

	Out("Take ghostly")
	GoNpcLog(FindMyGhostly())

	While GetMapLoading() == $instancetype_explorable And GetMapID() == $antechamber
		If CheckIsTeamWiped() Then ExitLoop
		If $team == $iamblue Then
			If $mapStartFame == GetHeroTitleSafe() Then
				If GetIsLiving() Then
					If GetMapID() == $antechamber Then
						CommandAll(-494, 4389)
						Do
							If GetMapID() <> $antechamber Then ExitLoop
							If GetIsDead(GetMyID()) Then ExitLoop
							If $mapStartFame < GetHeroTitleSafe() Then ExitLoop
							Move(-485, 2039)
							Sleep(2000)
						Until CheckArea(-485, 2039)
					EndIf
				EndIf
			EndIf
			If CheckArea(-485, 2039) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							Sleep(15000)
							CommandAll(-495, -18)
							MoveTo(28, 1144)
							Sleep(1000)
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(28, 1144) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							MoveTo(-495, -18)
							Sleep(5000)
							CancelAll()
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(-495, -18) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							MoveTo(237, -9)
							Sleep(1000)
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(237, -9) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							MoveTo(-494, -2239)
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(-494, -2239) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							Sleep(15000)
							CommandAll(-467, -4608)
							Sleep(15000)
							CancelAll()
						EndIf
					EndIf
				EndIf
			EndIf
			If $mapStartFame < GetHeroTitleSafe() Then
				Out("Won in Antechamber")
				ExitLoop
			EndIf
		EndIf
		If $team == $iamred Then
			If $mapStartFame == GetHeroTitleSafe() Then
				If GetIsLiving() Then
					If GetMapID() == $antechamber Then
						CommandAll(-467, -4608)
						Do
							If GetMapID() <> $antechamber Then ExitLoop
							If GetIsDead(GetMyID()) Then ExitLoop
							If $mapStartFame < GetHeroTitleSafe() Then ExitLoop
							Move(-475, -2253)
							Sleep(2000)
						Until CheckArea(-494, -2239)
					EndIf
				EndIf
			EndIf
			If CheckArea(-494, -2239) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							Sleep(15000)
							MoveTo(-494, -2239)
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(-494, -2239) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							Sleep(15000)
							CommandAll(-495, -18)
							MoveTo(-1030, -1250)
							Sleep(1000)
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(-1030, -1250) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							MoveTo(-495, -18)
							Sleep(5000)
							CancelAll()
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(-495, -18) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							MoveTo(237, -9)
							Sleep(1000)
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(237, -9) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							MoveTo(-485, 2039)
							Sleep(15000)
						EndIf
					EndIf
				EndIf
			EndIf
			If CheckArea(-485, 2039) Then
				If $mapStartFame == GetHeroTitleSafe() Then
					If GetIsLiving() Then
						If GetMapID() == $antechamber Then
							CommandAll(-494, 4389)
							Sleep(15000)
						EndIf
					EndIf
				EndIf
			EndIf
			If $mapStartFame < GetHeroTitleSafe() Then
				Out("Won in Antechamber")
				ExitLoop
			EndIf
		EndIf
	WEnd

	UpdateMapStats($mapStartFame, $antechamber, $team)
	If GUICtrlRead($cbxLeaveBeforeHalls) == $GUI_CHECKED Then
		TravelTo($ha)
	Else
		WaitForNextMap($antechamber)
	EndIf
EndFunc   ;==>antechamber
