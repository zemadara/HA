
Func ForgottenShrines()
	SkipCinematic()
	
	Local $team = GetTeamColour()
	PrintMapStart("Forgotten Shrines", $team)
	
	Local $mapStartFame = GetHeroTitleSafe()

	SleepIfMapJustStarted(45000)
	Upkeep()

	Out("Take ghostly")
	If $team == $iamblue Then
		Local $ghostlyblue = getnearestnpctocoords(-1910, -3490)
		GoNpcLog($ghostlyblue)
		Sleep(1000)
	ElseIf $team == $iamred Then
		Local $ghostlyred = getnearestnpctocoords(1950, -3435)
		GoNpcLog($ghostlyred)
		Sleep(1000)
	EndIf

	Global $startblue = 0
	Global $startred = 0
	While GetMapLoading() == $instancetype_explorable And GetMapID() == $forgottenshrines
		If CheckIsTeamWiped() Then ExitLoop
		If $team == $iamblue Then
			Local $agent = GetNearestEnemyToAgent()
			Local $distance = GetDistance($agent, -2)
			Local $besttarget = GetBestTarget()
			If $startblue = 0 Then
				If GetIsLiving() Then
					CommandAll(-949, 946)
					Do
						If GetIsDead(GetMyID()) Then ExitLoop
						If $mapStartFame < GetHeroTitleSafe() Then ExitLoop
						Move(-2227, -1405)
						Sleep(2000)
					Until CheckArea(-2227, -1405)
				EndIf
			EndIf
			If $mapStartFame == GetHeroTitleSafe() And CheckArea(-2227, -1405) And GetMapID() == $forgottenshrines Then
				If GetIsLiving() Then
					Sleep(15000)
					MoveTo(-949, 946)
					Poke()
					$startblue = 1
				EndIf
			EndIf
			If $mapStartFame == GetHeroTitleSafe() And CheckArea(-949, 946) And GetMapID() == $forgottenshrines Then
				If GetIsLiving() Then
					Sleep(15000)
					CommandAll(11, 3664)
					MoveTo(11, 3664)
					Poke()
				EndIf
			EndIf
			If $mapStartFame == GetHeroTitleSafe() And CheckArea(11, 3664) And GetMapID() == $forgottenshrines Then
				If GetIsLiving() Then
					Sleep(15000)
					CommandAll(606, 928)
					MoveTo(606, 928)
					Poke()
				EndIf
			EndIf
			If $mapStartFame == GetHeroTitleSafe() And CheckArea(606, 928) And GetMapID() == $forgottenshrines Then
				If GetIsLiving() Then
					Sleep(15000)
					CommandAll(2063, -1375)
					MoveTo(2063, -1375)
					Poke()
				EndIf
			EndIf
			If $startblue = 1 Then
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then Sleep(20000)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then CommandAll(606, 928)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then Sleep(20000)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then CommandAll(11, 3664)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then Sleep(20000)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then CommandAll(-949, 946)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then Sleep(20000)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then CommandAll(2063, -1375)
			EndIf
		EndIf
		If $team == $iamred Then
			Local $agent = GetNearestEnemyToAgent()
			Local $distance = GetDistance($agent, -2)
			Local $besttarget = GetBestTarget()
			If $startred = 0 Then
				If GetIsLiving() Then
					CommandAll(606, 928)
					Do
						If GetMapID() <> $forgottenshrines Then ExitLoop
						If GetIsDead(GetMyID()) Then ExitLoop
						If $mapStartFame < GetHeroTitleSafe() Then ExitLoop
						Move(2063, -1375)
						Poke()
						Sleep(2000)
					Until CheckArea(2063, -1375)
				EndIf
			EndIf
			If $mapStartFame == GetHeroTitleSafe() And CheckArea(2063, -1375) And GetMapID() == $forgottenshrines Then
				If GetIsLiving() Then
					Sleep(15000)
					MoveTo(606, 928)
					Poke()
					$startred = 1
				EndIf
			EndIf
			If $mapStartFame == GetHeroTitleSafe() And CheckArea(606, 928) And GetMapID() == $forgottenshrines Then
				If GetIsLiving() Then
					Sleep(15000)
					CommandAll(11, 3664)
					MoveTo(11, 3664)
					Poke()
				EndIf
			EndIf
			If $mapStartFame == GetHeroTitleSafe() And CheckArea(11, 3664) And GetMapID() == $forgottenshrines Then
				If GetIsLiving() Then
					Sleep(15000)
					CommandAll(-949, 946)
					MoveTo(-949, 946)
					Poke()
					Sleep(15000)
				EndIf
			EndIf
			If $mapStartFame == GetHeroTitleSafe() And CheckArea(-949, 946) And GetMapID() == $forgottenshrines Then
				If GetIsLiving() Then
					Sleep(15000)
					CommandAll(-2227, -1405)
					MoveTo(-2227, -1405)
					Poke()
				EndIf
			EndIf
			If $startred = 1 Then
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then Sleep(20000)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then CommandAll(-949, 946)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then Sleep(20000)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then CommandAll(11, 3664)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then Sleep(20000)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then CommandAll(606, 928)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then Sleep(20000)
				If $mapStartFame == GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then CommandAll(-2227, -1405)
			EndIf
		EndIf

		If $mapStartFame < GetHeroTitleSafe() And GetMapID() == $forgottenshrines Then
			If GetIsLiving() Then
				If GetMapID() == $forgottenshrines Then
					Out("Won in Forgotten Shrines")
					ExitLoop
				EndIf
			EndIf
		EndIf
	WEnd

	UpdateMapStats($mapStartFame, $forgottenshrines, $team)
	WaitForNextMap($forgottenshrines)
EndFunc   ;==>forgottenshrines
