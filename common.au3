;Range
Global const $rangeAdjacent = 166.0
Global const $rangeNearby = 238.0
Global const $rangeArea = 322.0
Global const $rangeEarshot = 1010.0
Global const $rangeSpellcast = 1246.0
Global const $rangeSpirit = 2500.0
Global const $rangeCompass = 5000.0

Func MsToTime($aTimeInMs)
	Local $g_iHour, $g_iMins, $g_iSecs
	_TicksToTime($aTimeInMs, $g_iHour, $g_iMins, $g_iSecs)
	return StringFormat("%02i:%02i:%02i", $g_iHour, $g_iMins, $g_iSecs)
EndFunc

; Check if agent is within 500 of x,y (no regard for circular co-ord)
; TODO GetDistance / GetPseudoDistance
Func CheckArea($ax, $ay, $aDistance = 500)
	Local $px = DllStructGetData(GetAgentByID(-2), "X")
	Local $py = DllStructGetData(GetAgentByID(-2), "Y")
	If ($px < $ax + $aDistance) And _
	   ($px > $ax - $aDistance) And _
	   ($py < $ay + $aDistance) And _
	   ($py > $ay - $aDistance) Then
		Return True
	EndIf
	Return False
EndFunc   ;==>checkarea

Func CountItemInBagsByModelID($itemmodelid)
	Local $count = 0
	;6 is MaterialStorage
	Local Enum $bag_backpack = 1, $bag_beltpouch, $bag_bag1, $bag_bag2, $bag_equipmentpack, $bag_unclaimeditems = 7, _
		$bag_storage1, $bag_storage2, $bag_storage3, $bag_storage4, $bag_storage5, $bag_storage6, $bag_storage7, $bag_storage8, $bag_storageanniversary
	For $i = $bag_backpack To $bag_bag2
		For $j = 1 To DllStructGetData(GetBag($i), "Slots")
			Local $liteminfo = GetItemBySlot($i, $j)
			If DllStructGetData($liteminfo, "ModelID") = $itemmodelid Then $count += DllStructGetData($liteminfo, "quantity")
		Next
	Next
	Return $count
EndFunc   ;==>countiteminbagsbymodelid

Func CountBagsFreeSlots()
	Local Const $mid_free_slot = 0
	Local $count = 0
	Local Enum $bag_backpack = 1, $bag_beltpouch, $bag_bag1, $bag_bag2, $bag_equipmentpack, $bag_unclaimeditems = 7, _
		$bag_storage1, $bag_storage2, $bag_storage3, $bag_storage4, $bag_storage5, $bag_storage6, $bag_storage7, $bag_storage8, $bag_storageanniversary
	For $i = $bag_backpack To $bag_bag2
		For $j = 1 To DllStructGetData(GetBag($i), "Slots")
			Local $liteminfo = GetItemBySlot($i, $j)
			If DllStructGetData($liteminfo, "ModelID") = $mid_free_slot Then $count += 1
		Next
	Next
	Return $count
EndFunc

Func GetTeam($aTeam)
	Local $lTeamNumber = $aTeam
	Local $lTeam[1][3]
	Local $lTeamSmall[1] = [0]
	Local $lAgent
	$lTeam[0][0] = 0
	$lTeam[0][1] = $lTeamNumber
	$lTeam[0][2] = 0
	If $lTeamNumber == 0 Then Return $lTeamSmall
	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentByID($i)
		If DllStructGetData($lAgent, 'ID') == 0 Then ContinueLoop
		If Not GetIsDead($lAgent) _
			And GetIsLiving($lAgent) _
			And DllStructGetData($lAgent, 'Team') == $lTeamNumber _
			And (DllStructGetData($lAgent, 'LoginNumber') <> 0 Or StringRight(GetAgentName($lAgent), 9) == "Henchman]") Then

			$lTeam[0][0] += 1
			ReDim $lTeam[$lTeam[0][0]+1][3]
			$lTeam[$lTeam[0][0]][0] = DllStructGetData($lAgent, 'id')
			$lTeam[$lTeam[0][0]][1] = DllStructGetData($lAgent, 'PlayerNumber')
			$lTeam[$lTeam[0][0]][2] = FormatName($lAgent)
		EndIf
	Next
	_ArraySort($lTeam, 0, 1, 0, 1)
	Return $lTeam
EndFunc   ;==>GetTeam

Func FormatName($aAgent)
	If IsDllStruct($aAgent) == 0 Then $aAgent = GetAgentByID($aAgent)
	Local $sString = ""
	Switch DllStructGetData($aAgent, 'Primary')
		Case 0
			$sString &= " "
		Case 1
			$sString &= "W"
		Case 2
			$sString &= "R"
		Case 3
			$sString &= "Mo"
		Case 4
			$sString &= "N"
		Case 5
			$sString &= "Me"
		Case 6
			$sString &= "E"
		Case 7
			$sString &= "A"
		Case 8
			$sString &= "Rt"
		Case 9
			$sString &= "P"
		Case 10
			$sString &= "D"
	EndSwitch

	Switch DllStructGetData($aAgent, 'Secondary')
		Case 0
			$sString &= " "
		Case 1
			$sString &= "/W"
		Case 2
			$sString &= "/R"
		Case 3
			$sString &= "/Mo"
		Case 4
			$sString &= "/N"
		Case 5
			$sString &= "/Me"
		Case 6
			$sString &= "/E"
		Case 7
			$sString &= "/A"
		Case 8
			$sString &= "/Rt"
		Case 9
			$sString &= "/P"
		Case 10
			$sString &= "/D"
		EndSwitch
		$sString &= " - "
		If DllStructGetData($aAgent, 'LoginNumber') > 0 Then
			$sString &= GetPlayerName($aAgent)
		Else
			$sString &= StringReplace(GetAgentName($aAgent), "Corpse of ", "")
		EndIf
	Return $sString
EndFunc   ;==>FormatName

; True iff no weapon equipped (e.g, carrying repair kit, flag)
; <> 0 variant:
;   Returns True nearly all the time
;   Sometimes returns false just after ressing
;   DOES NOT work with relic
Func HasBundle($aAgentID = -2)
	Local $agent = GetAgentByID($aAgentID)
	Return DllStructGetData($agent, 'WeaponItemID') <> 0
EndFunc

Func HasRelic($aAgentID = -2)
	Local $agent = GetAgentByID($aAgentID)
	Return DllStructGetData($agent, 'Relic') == '0x0606'
EndFunc

Func GetTeamColour()
	Return DllStructGetData(GetAgentByID(), "team")
EndFunc

Func GetTeamColourName($aTeam)
	Local $ret = "Unknown"
	Switch $aTeam
		Case 0
			$ret = "Unknown/town"
		Case 1
			$ret = "Blue"
		Case 2
			$ret = "Red"
		Case 3
			$ret = "Yellow"
	EndSwitch

	return $ret
EndFunc

;~ Description: Returns the amount of foes in range
Func CountEnemies($range = $rangeCompass)
	Local $lAgentArray = GetAgentArray(0xDB)

	Local Const $myTeam = GetTeamColour()
	Local $count = 0
	For $aID = 1 To $lAgentArray[0]
		Local $lAgent = $lAgentArray[$aID]
		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
		If $myTeam <> 0 And DllStructGetData($lAgent, "Team") == $myTeam Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		If GetDistance($lAgent, -2) > $range Then ContinueLoop

		$count += 1
	Next

	Return $count
EndFunc   ;==>GetNearestEnemyToAgent

;~ Description: Returns the amount of allies in range
Func CountAllies($range = $rangeCompass)
	Local $lAgentArray = GetAgentArray(0xDB)

	Local Const $myTeam = GetTeamColour()
	Local $count = 0
	For $aID = 1 To $lAgentArray[0]
		Local $lAgent = $lAgentArray[$aID]
		If DllStructGetData($lAgent, 'Allegiance') <> 1 Then ContinueLoop
		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
		If $myTeam <> 0 And DllStructGetData($lAgent, "Team") <> $myTeam Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		If GetDistance($lAgent, -2) > $range Then ContinueLoop

		$count += 1
	Next

	Return $count
EndFunc   ;==>GetNearestEnemyToAgent