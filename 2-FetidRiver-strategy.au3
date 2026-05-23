
Func FetidRiver()
	SkipCinematic()

	Local $team = GetTeamColour()
	PrintMapStart("Fetid River", $team)

	Local $mapStartFame = GetHeroTitleSafe()

	SleepIfMapJustStarted(50000)
	Upkeep()

	While GetMapLoading() == $instancetype_explorable And GetMapID() == $fetid
		Local $agent = GetBestTarget()
		If CheckIsTeamWiped() Then ExitLoop

;~ 		Local $enemies = CountEnemies($rangeCompass)
;~ 		If $enemies == 0 Then
;~ 			;Out("Debug: No enemies, we should be about to win")
;~ 		ElseIf $enemies < 5 Then
;~ 			;KillEnemy(GetNearestNPCToCoords)
;~ 			; No need to do anything fancy here; we seem to always win at this point
;~ 			;Out("Debug: Less than 5 foes left")
;~ 		EndIf

		If $mapStartFame == GetHeroTitleSafe() Then
			Local $distance = GetDistance($agent, -2)
			If $distance > 1250 And $distance < 8000 Then
				Attack($agent)
				Sleep(1500)
			ElseIf $distance < 1250 Then
				KillEnemy()
			EndIf
		EndIf
		If $mapStartFame < GetHeroTitleSafe() Then
			Out("Won in Fetid")
			ExitLoop
		EndIf
	WEnd

	UpdateMapStats($mapStartFame, $fetid, $team)
	WaitForNextMap($fetid)
EndFunc   ;==>fetid
