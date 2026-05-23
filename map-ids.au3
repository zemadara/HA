Global Const $gtob = 248

;HA maps
Global Const $ha = 330 ; Zaishen + HA outpost
Global Const $uw = 84
Global Const $fetid = 593
Global Const $burialmounds = 80
Global Const $unholytemples = 79
Global Const $forgottenshrines = 596
Global Const $goldengates = 126
Global Const $courtyard = 78
Global Const $antechamber = 598
Global Const $vault = 83
Global Const $hoh = 75

; Guild halls
Global Const $burningisle = 52
Global Const $corruptedisle = 537
Global Const $druidsisle = 178
Global Const $frozenisle = 176
Global Const $huntersisle = 5
Global Const $imperialisle = 359
Global Const $isleofjade = 276
Global Const $isleofmeditation = 360
Global Const $isleofsolitude = 538
Global Const $isleofthedead = 179
Global Const $isleofweepingstone = 275
Global Const $isleofwurms = 530
Global Const $nomadsisle = 177
Global Const $unchartedisle = 529
Global Const $warriorsisle = 4
Global Const $wizardsisle = 6

Func MapHasResShrine($mapID)
	If $mapID == $fetid Then Return True
	If $mapID == $burialmounds Then Return True
	If $mapID == $unholytemples Then Return True
	If $mapID == $forgottenshrines Then Return True
	If $mapID == $goldengates Then Return True
	If $mapID == $antechamber Then Return True
	Return False
EndFunc

Func GetMapName($aMapID)
	Switch $aMapID
		Case $ha
			Return "Zaishen / Heroes Ascent"
		Case $gtob
			Return "Great Temple"
		Case $uw
			Return "Underworld"
		Case $fetid
			Return "Fetid River"
		Case $burialmounds
			Return "Burial Mounds"
		Case $unholytemples
			Return "Unholy Temples"
		Case $forgottenshrines
			Return "Forgotten Shrines"
		Case $goldengates
			Return "Golden Gates"
		Case $courtyard
			Return "Courtyard"
		Case $antechamber
			Return "Antechamber"
		Case $vault
			Return "Vault"
		Case $hoh
			Return "Hall of Heroes"
		Case $burningisle
			ContinueCase
		Case $corruptedisle
			ContinueCase
		Case $druidsisle
			ContinueCase
		Case $frozenisle
			ContinueCase
		Case $huntersisle
			ContinueCase
		Case $imperialisle
			ContinueCase
		Case $isleofjade
			ContinueCase
		Case $isleofmeditation
			ContinueCase
		Case $isleofsolitude
			ContinueCase
		Case $isleofthedead
			ContinueCase
		Case $isleofweepingstone
			ContinueCase
		Case $isleofwurms
			ContinueCase
		Case $nomadsisle
			ContinueCase
		Case $unchartedisle
			ContinueCase
		Case $warriorsisle
			ContinueCase
		Case $wizardsisle
			Return "Guild Hall"
	EndSwitch
	Return "Unknown: " & $aMapID
EndFunc
