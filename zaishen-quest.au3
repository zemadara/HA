;Quests
Global $qHeroesAscent[] =[ 1102, 1110, 1094, 1118 ]

Func MoveToZaishenCombat()
	Local $gtob=248
	If GetMapID() <> $gtob Then
		Out("Warnining: MoveToZaishenCombat() expected to be on gtob but was on " & GetMapName(GetMapID()))
		TravelTo($gtob)
	EndIf
	If Not MoveTo(-5122.8798828125,-5405.55029296875) Then
		Out("ERROR: Failed to move to zaishen combat")
	EndIf
	rndsleep(500)
	TalkToZaishenCombat()
	rndsleep(500)
EndFunc

Func TalkToZaishenCombat()
	Local $gtob=248
	If GetMapID() <> $gtob Then
		Out("Warnining: MoveToZaishenCombat() expected to be on gtob but was on " & GetMapName(GetMapID()))
		TravelTo($gtob)
	EndIf
	Local $npc = GetNearestNPCToCoords(-5122.8798828125,-5405.55029296875)
	rndsleep(500)
	GoNPC($npc)
EndFunc

Func MoveToZaishenChallengeRewardsGuy()
	Out("Talking to zaishen rewards...")
	If Not MoveTo(-5093.0576171875,-5521.0771484375) Then
		Out("ERROR: Failed to move to zaishen rewards")
	EndIf
	rndsleep(500)
EndFunc

Func TalkToZaishenChallengeRewardsGuy()
	Local $npc = GetNearestNPCToCoords(-5093.0576171875,-5521.0771484375)
	rndsleep(500)
	GoNPC($npc)
	rndsleep(500)
EndFunc

Func HaveQuest()
	For $q in $qHeroesAscent
		If GetQuestByID($q) <> 0 Then
			Out("Have quest " & $q)
			rndsleep(500)
			Return True
		EndIf
		rndsleep(500)
	Next
	Return False
EndFunc

;assumes gtob
Func GetQuest()
	MoveToZaishenCombat()
	Out("Trying to get quest...")
	For $q In $qHeroesAscent
		TalkToZaishenCombat()
		AcceptQuest($q)
		If GetQuestByID($q) <> 0 Then
			Return True
			ExitLoop
		EndIf
		rndsleep(500)
	Next
	Return False
EndFunc

Func GetQuestReward()
	MoveToZaishenChallengeRewardsGuy()
	Out("Getting reward...")
	For $q In $qHeroesAscent
		TalkToZaishenChallengeRewardsGuy()
		QuestReward($q)
		rndsleep(500)
	Next
EndFunc