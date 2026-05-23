
Func UnholyTemples()
	SkipCinematic()
	
	Local $team = GetTeamColour()
	PrintMapStart("Unholy Temples", $team)
	
	Local $mapStartFame = GetHeroTitleSafe()

	SleepIfMapJustStarted(30000)
	Upkeep()

	Local $myTeam = GetTeamColour()
	;Debug purposes
	FindMyGhostly()

	While GetMapLoading() == $instancetype_explorable And GetMapID() == $unholytemples

		If UnholyInner($mapStartFame, $myTeam) == False Then ExitLoop

		If $mapStartFame < GetHeroTitleSafe() Then
			Out("Won in Unholy")
			ExitLoop
		EndIf
	WEnd

	UpdateMapStats($mapStartFame, $unholytemples, $team)
	WaitForNextMap($unholytemples)
EndFunc   ;==>unholytemples

Func MoveToMiddle()
	Return MoveTo(-667, -331)
EndFunc

Func MoveToRelic($myTeam)
	If $myTeam == $iamblue Then
		Return MoveTo(-2233, -2047) ; Red relic
	ElseIf $myTeam == $iamred Then
		Return MoveTo(868, 1666) ; Blue relic
	EndIf
EndFunc

Func InRelicArea($myTeam)
	If $myTeam == $iamblue Then
		Return CheckArea(-2233, -2047) ; Red area
	ElseIf $myTeam == $iamred Then
		Return CheckArea(868, 1666) ; Blue area
	EndIf
EndFunc

Func InMiddle()
	Return CheckArea(-667, -331)
EndFunc

Func MoveToGhostlyArea($myTeam)
	If $myTeam == $iamblue Then
		Return MoveTo(1549, 1519)
	ElseIf $myTeam == $iamred Then
		MoveTo(-2855, -1646)
		MoveTo(-3107, -2996) ; what's this???
	EndIf
EndFunc

Func FlagOutsideEnemyBase($myTeam)
	If $myTeam == $iamblue Then
		; Flag to just outside red's base
		CommandAll(1549, 1519)
	ElseIf $myTeam == $iamred Then
		; Flag to just outside blue's base
		CommandAll(-3107, -2996)
	EndIf
EndFunc

Func UnholyInner($mapStartFame, $myTeam)
	If CheckIsTeamWiped() Then Return False

	; What if ghost is dead?
	; What if I am dead?
	; What if you are in relic area but dont have relic?

	If Not GetIsLiving() Then
		Do
			Sleep(1000)
		Until GetIsLiving()
		Out("Looking for potentially dropped relic")
		PickupLoot($rangeAdjacent)
	EndIf

	If $mapStartFame == GetHeroTitleSafe() And Not HasRelic() Then
		Out("Checking for dropped relics")
		;TODO catch "stupidly moving towards my own relic in its home base"
		; (but allow returning dropped own relic)
		PickupLoot($rangeNearby)
		If $mapStartFame > GetHeroTitleSafe() Then Return
		If Not HasRelic() Then
			If InRelicArea(3 - $myTeam) Then
				Out("I think I did the stupid thing. Picking up my relic, again")
				PickupMyRelic($myTeam, $rangeCompass)
			Else
				Out("Moving to relic area (HasRelic = " & HasRelic() & ")")
				If GetIsLiving() Then
					MoveToRelic($myTeam)
					Poke()
					Sleep(1000)
				EndIf
			EndIf
			Sleep(1000)
		EndIf
	EndIf
	If $mapStartFame == GetHeroTitleSafe() And InRelicArea($myTeam) And Not HasRelic() Then
		Out("Picking up enemy relic")
		If GetIsLiving() Then
			PickupMyRelic($myTeam, $rangeCompass)
			If $mapStartFame > GetHeroTitleSafe() Then Return
			Sleep(3000)
			KillEnemy()
			If InRelicArea($myTeam) Then
				Out("Considering killing ghost")
				Local $enemyGhost = FindMyGhostly(3 - GetTeamColour())
				If IsDllStruct($enemyGhost) Then
					Out("Calling ghost target")
					CallTarget($enemyGhost)
				Else
					Out("Failed to find ghost for team " & GetTeamColourName(3 - GetTeamColour()))
				EndIf
			EndIf
			If HasRelic() Then
				MoveToMiddle()
				Poke()
			EndIf
		EndIf
		Sleep(1000)
	EndIf
	If $mapStartFame == GetHeroTitleSafe() And HasRelic() Then
		Out("Taking relic home (HasRelic = " & HasRelic() & ")")

		MoveToGhostlyArea($myTeam)
		If GetIsLiving() Then
			If Not GoNpcLog(FindMyGhostly()) Then
				Out("Maybe I am blocked? Calling target!")
				KillEnemy()
			Else
				If Not HasRelic() Then
					Out("Hopefully scored a point!")
				Else
					Out("Can't score. Is my ghost dead?")
					Local $lme = GetAgentByID(-2)
					Out("I am at (" & DllStructGetData($lme, "X") & "," & DllStructGetData($lme, "Y") & ")")
					Out("My speed is " & DllStructGetData($lme, "MoveX") & "," & DllStructGetData($lme, "MoveY"))
					GoNpcLog(FindMyGhostly())
				EndIf
			EndIf
			Sleep(1000)
		Else
			Out("Died with relic?")
		EndIf

		Sleep(1000)
	EndIf

	Return True
EndFunc   ;==>unholyinner
