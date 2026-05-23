
Func Zaishen()
	Local $team = GetTeamColour()
	PrintMapStart("Zaishen", $team)
	Upkeep()
	While GetMapLoading() == $instancetype_explorable And GetMapID() == $ha
		If CheckIsTeamWiped() Then
			WaitMapLoading($ha)
			ExitLoop
		EndIf
		Local $agent = GetBestTarget(8000) ;No limit
		If IsDllStruct($agent) Then
			Local $distance = GetDistance($agent, -2)
			If $distance > 2000 Then
				Attack($agent)
				Out("Zaishen: Attack best target")
				CallTarget($agent)
				ChangeTarget($agent)
				Sleep(6000)
			Else
				KillEnemy()
			EndIf
		EndIf

		If GetNearestEnemyToAgent() = 0 Then
			Out("Waiting for UW load...")
			WaitMapLoading(0, 45000)
		EndIf
	WEnd
EndFunc   ;==>zaishen