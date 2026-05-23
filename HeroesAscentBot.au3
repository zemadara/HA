#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=HeroesAscentBot.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Before=echo # This file is populated by #AutoIt3Wrapper_Run_Before statements in HeroesAscentBot.au3 > version.au3
#AutoIt3Wrapper_Run_Before=echo Global Const $version = _ >> version.au3
#AutoIt3Wrapper_Run_Before=git rev-parse --sq --short HEAD >> version.au3
#Au3Stripper_Parameters=/debug /sf /sv /mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#AutoIt3Wrapper_Run_Au3Stripper=y

AutoItSetOption("MustDeclareVars", 1)
#include <Array.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiScrollBars.au3>
#include <EditConstants.au3>
#include <Date.au3>
#include <Math.au3>

#include <engine.au3>
#include <common.au3>
#include <skills.au3>

#include <map-ids.au3>
#include <zaishen-quest.au3>
#include <materials.au3>
#include <version.au3>

Opt("GUIOnEventMode", 1)

#Region Declarations
Global Const $iamblue = 1
Global Const $iamred = 2

; Logic / trackers
Global $gwpid
Global $fameup
Global $fameAtStart
Global $lastZkeyPurchaseFailureTimer = 0 ; Timer handle
Global $checkedForQuestDayToday = False

;UI
Global $runs = 0
Global $zkEarned = 0
Global $haQuestWins = 0
Global $totalQuestCompletions = 0

Global $HeroTitleRequirements[15] = [25,75,180,360,600,1000,1680,2800,4665,7750,12960,21600,36000,60000,100000]

;Model IDs
Global Const $mid_zkey = 28517
Global Const $mid_hero_boxes = 36666
Global Const $mid_bronze_coins = 31202
Global Const $mid_silver_coins = 31204

; Game consts
Global Const $GWA_CONST_FASTCASTING = 0
Global Const $skill_dishonourable = 2546

Global $UpkeepSkills[] =[ "FIRE ATTUNEMENT", _
	"EARTH ATTUNEMENT", _
	"WATER ATTUNEMENT", _
	"AIR ATTUNEMENT", _
	"AURA OF RESTORATION", _
	"MANTRA OF FLAME", _
	"MANTRA OF CONCENTRATION", _
	"MANTRA OF RESOLVE", _
	"PERSISTENCE OF MEMORY", _
	"CHANNELING", _
	"LYSSA'S AURA", _
	"GLYPH OF ELEMENTAL POWER", _
	"GLYPH OF LESSER ENERGY" _
]

Global $specialSkills[] = [ "DRAIN ENCHANTMENT", _
	"SHATTER ENCHANTMENT", _
	"METEOR SHOWER", _
	"GLYPH OF SACRIFICE", _
	"WASTREL'S WORRY" _
]

Global $interuptSkills[] = [ "CRY OF FRUSTRATION", _
	"TEASE", _
	"COMPLICATE", _
	"PSYCHIC INSTABILITY", _
	"POWER BLOCK", _
	"POWER DRAIN", _
	"POWER FLUX", _
	"POWER LEAK", _
	"POWER LEACH", _
	"POWER SPIKE", _
	"LEECH SIGNET" _
]

Global $boolrun = False
Global $paused = False
Global $logfile
Global $logfileExcel
Global $rendering = True

Global Enum $instancetype_outpost, $instancetype_explorable, $instancetype_loading
#EndRegion Declarations

#Region GUI
Global $uiWidth = 354
Global $uiHeight = 280
Global Const $uiMain = GUICreate("HA Bot", $uiWidth, $uiHeight, 0, 0); $GUI_SS_DEFAULT_GUI + $WS_SIZEBOX)

Global $guiname = GUICtrlCreateCombo("", 8, 8, 195, 25, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, getloggedcharnames())
AutoItSetOption("GUICoordMode", 0)
Global $guistart = GUICtrlCreateButton("START", 10+195, 0, 65, 25)
GUICtrlSetOnEvent($guistart, "UIEventHandler")
Global $uiPause = GUICtrlCreateButton("Pause", 70, 0, 65, 25)
GUICtrlSetOnEvent($uiPause, "UIEventHandler")
GUICtrlSetState($uiPause, $GUI_DISABLE)

AutoItSetOption("GUICoordMode", 1)
Global $uiTab = GUICtrlCreateTab(5, 40, $uiWidth - 10, $uiHeight - 40)
GUISetFont(-1, 9, 400, 0, "Arial")

CreateRunTab()
CreatePerformanceTab()
CreateInventoryTab()
CreateAccountTab()
CreateDebugTab()
GUICtrlCreateTabItem("") ; Close tab group

GUISetState(@SW_SHOW)
GUISetOnEvent($GUI_EVENT_CLOSE, "CloseHandler")

Func CreateRunTab()
	GUICtrlCreateTabItem("Run")

	AutoItSetOption("GUICoordMode", 1)
	Global $console = GUICtrlCreateEdit("", 8, 65, $uiWidth - 18, 140, BitOR($WS_VSCROLL, $ES_AUTOVSCROLL, $ES_READONLY))
	GUICtrlSetFont(-1, 9, 400, 0, "Arial")
	GUICtrlSetColor(-1, 0x00FFFF)
	GUICtrlSetBkColor(-1, 0)
	GUICtrlSetCursor(-1, 5)
	AutoItSetOption("GUICoordMode", 0)
	Global $mapDisplay = GUICtrlCreateLabel("[Map]", 0, 140+5, $uiWidth - 10, 20, $SS_Center)
	GUICtrlSetFont(-1, 10, 700, 0)
	GUICtrlSetColor(-1, 0xFF0000)

	Global $cbxHideGw = GUICtrlCreateCheckbox("Disable graphics", 5, 20)
	GUICtrlSetState($cbxHideGw, $GUI_DISABLE)
	GUICtrlSetOnEvent($cbxHideGw, "UIEventHandler")
	Global $cbHaQuest = GUICtrlCreateCheckbox("HA quest", 0, 20)

	Global $cbxLeaveIfBored = GUICtrlCreateCheckbox("Leave after 5 mins", 165, -20)
	Global $cbxLeaveBeforeHalls = GUICtrlCreateCheckbox("Leave before Halls", 0, 20)

	GUICtrlCreateTabItem("")
EndFunc

Func CreatePerformanceTab()
	Local $groupTopMargin = 20
	Local $groupLeftMargin = 12
	Local $top = 75

	Local $3CharWidth = 50

	; Performance - labels
	Local $performanceLeftMargin = 230
	GUICtrlCreateTabItem("Performance")
	AutoItSetOption("GUICoordMode", 1)
	GUICtrlCreateGroup("Earnings", $performanceLeftMargin, $top, 110, 90)
	AutoItSetOption("GUICoordMode", 0)
	GUICtrlCreateLabel("Runs:", $groupLeftMargin, $groupTopMargin, 55, 18)
	GUICtrlCreateLabel("Fame+:", 0, 16, 55, 18)
	GUICtrlCreateLabel("Zkeys+:", 0, 16, 55, 18)
	GUICtrlCreateLabel("Gold+:", 0, 16, 55, 18)

	; Performance - values
	AutoItSetOption("GUICoordMode", 1)
	Global $lblRuns = GUICtrlCreateLabel("0", $performanceLeftMargin+60, $top+$groupTopMargin, 25)
	GUICtrlSetColor(-1, 0x008500)
	AutoItSetOption("GUICoordMode", 0)
	Global $lblFameEarned = GUICtrlCreateLabel("0", 0, 16, 51, 25)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblZkEarned = GUICtrlCreateLabel("0", 0, 16, 51, 25)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblGoldEarned = GUICtrlCreateLabel("0", 0, 16, 51, 25)
	GUICtrlSetColor(-1, 0x008500)

	; Map history - labels
	Local $mapHistoryTop = $top
	AutoItSetOption("GUICoordMode", 1)
	GUICtrlCreateGroup("Map history", 12, $mapHistoryTop, 205, 180)
	AutoItSetOption("GUICoordMode", 0)
	GUICtrlCreateLabel("Underworld:", $groupLeftMargin, $groupTopMargin)
	GUICtrlCreateLabel("Fetid River:", 0, 15)
	GUICtrlCreateLabel("Burial Mounds:", 0, 15)
	GUICtrlCreateLabel("Unholy Temples:", 0, 15)
	GUICtrlCreateLabel("Forgotten Shrines:", 0, 15)
	GUICtrlCreateLabel("Golden Gates:", 0, 15)
	GUICtrlCreateLabel("Courtyard:", 0, 15)
	GUICtrlCreateLabel("Antechamber:", 0, 15)
	GUICtrlCreateLabel("Vault:", 0, 15)
	GUICtrlCreateLabel("Halls:", 0, 15)
	AutoItSetOption("GUICoordMode", 1)

	;Map history - victory values
	AutoItSetOption("GUICoordMode", 1)
	Global $lblUnderworldWin = GUICtrlCreateLabel("0", $groupLeftMargin+125, $mapHistoryTop+$groupTopMargin, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	AutoItSetOption("GUICoordMode", 0)
	Global $lblFetidRiverWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblBurialMoundsWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblUnholyTemplesWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblForgottenShrinesWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblGoldenGatesWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblCourtyardWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblAntechamberWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblVaultWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)
	Global $lblHallOfHeroesWin = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0x008500)

	;Map history - loss values
	AutoItSetOption("GUICoordMode", 1)
	Global $lblUnderworldLoss = GUICtrlCreateLabel("0", 160, $mapHistoryTop+$groupTopMargin, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	AutoItSetOption("GUICoordMode", 0)
	Global $lblFetidRiverLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	Global $lblBurialMoundsLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	Global $lblUnholyTemplesLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	Global $lblForgottenShrinesLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	Global $lblGoldenGatesLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	Global $lblCourtyardLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	Global $lblAntechamberLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	Global $lblVaultLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)
	Global $lblHallOfHeroesLoss = GUICtrlCreateLabel("0", 0, 15, $3CharWidth)
	GUICtrlSetColor(-1, 0xFF0000)

	Local $offScreen = 600
	; Blue win
	Global $lblUnderworldBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblFetidRiverBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblBurialMoundsBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblUnholyTemplesBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblForgottenShrinesBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblGoldenGatesBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblCourtyardBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblAntechamberBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblVaultBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblHallOfHeroesBlueWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)

	; Red win
	Global $lblUnderworldRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblFetidRiverRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblBurialMoundsRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblUnholyTemplesRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblForgottenShrinesRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblGoldenGatesRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblCourtyardRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblAntechamberRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblVaultRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblHallOfHeroesRedWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)

	; Yellow win
	Global $lblCourtyardYellowWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblHallOfHeroesYellowWin = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)

	; Blue loss
	Global $lblUnderworldBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblFetidRiverBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblBurialMoundsBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblUnholyTemplesBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblForgottenShrinesBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblGoldenGatesBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblCourtyardBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblAntechamberBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblVaultBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblHallOfHeroesBlueLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)

	; Red loss
	Global $lblUnderworldRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblFetidRiverRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblBurialMoundsRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblUnholyTemplesRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblForgottenShrinesRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblGoldenGatesRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblCourtyardRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblAntechamberRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblVaultRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblHallOfHeroesRedLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)

	; Yellow loss
	Global $lblCourtyardYellowLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)
	Global $lblHallOfHeroesYellowLoss = GUICtrlCreateLabel("0", $offScreen, $offScreen, $3CharWidth)

	GUICtrlCreateTabItem("")
	AutoItSetOption("GUICoordMode", 1)
EndFunc

Func GetWinHandle($aMap)
	Switch $aMap
		Case $ha
			Out("ERROR: We shouldn't be trying to log Zaishen wins")
		Case $uw
			Return $lblUnderworldWin
		Case $fetid
			Return $lblFetidRiverWin
		Case $burialmounds
			Return $lblBurialMoundsWin
		Case $unholytemples
			Return $lblUnholyTemplesWin
		Case $forgottenshrines
			Return $lblForgottenShrinesWin
		Case $goldengates
			Return $lblGoldenGatesWin
		Case $courtyard
			Return $lblCourtyardWin
		Case $antechamber
			Return $lblAntechamberWin
		Case $vault
			Return $lblVaultWin
		Case $hoh
			Return $lblHallOfHeroesWin
	EndSwitch

	Out("ERROR: Can't get win handle for map: " & GetMapName($aMap))
EndFunc

Func GetColouredWinHandle($aMap, $aTeam)
	If $aMap == $ha Then
		Out("ERROR: We shouldn't be trying to log Zaishen wins")
		Return
	EndIf

	Switch $aTeam
		Case 1 ; Blue
			Switch $aMap
				Case $uw
					Return $lblUnderworldBlueWin
				Case $fetid
					Return $lblFetidRiverBlueWin
				Case $burialmounds
					Return $lblBurialMoundsBlueWin
				Case $unholytemples
					Return $lblUnholyTemplesBlueWin
				Case $forgottenshrines
					Return $lblForgottenShrinesBlueWin
				Case $goldengates
					Return $lblGoldenGatesBlueWin
				Case $courtyard
					Return $lblCourtyardBlueWin
				Case $antechamber
					Return $lblAntechamberBlueWin
				Case $vault
					Return $lblVaultBlueWin
				Case $hoh
					Return $lblHallOfHeroesBlueWin
			EndSwitch
		Case 2 ; Red
			Switch $aMap
				Case $uw
					Return $lblUnderworldRedWin
				Case $fetid
					Return $lblFetidRiverRedWin
				Case $burialmounds
					Return $lblBurialMoundsRedWin
				Case $unholytemples
					Return $lblUnholyTemplesRedWin
				Case $forgottenshrines
					Return $lblForgottenShrinesRedWin
				Case $goldengates
					Return $lblGoldenGatesRedWin
				Case $courtyard
					Return $lblCourtyardRedWin
				Case $antechamber
					Return $lblAntechamberRedWin
				Case $vault
					Return $lblVaultRedWin
				Case $hoh
					Return $lblHallOfHeroesRedWin
			EndSwitch
		Case 3 ; Yellow
			Switch $aMap
				Case $courtyard
					Return $lblCourtyardYellowWin
				Case $hoh
					Return $lblHallOfHeroesYellowWin
			EndSwitch
	EndSwitch

	Out("ERROR: Can't get coloured-win handle for team " & GetTeamColourName($aTeam) & " on map: " & GetMapName($aMap))
EndFunc

Func GetColouredLossHandle($aMap, $aTeam)
	If $aMap == $ha Then
		Out("ERROR: We shouldn't be trying to log Zaishen Losss")
		Return
	EndIf

	Switch $aTeam
		Case 1 ; Blue
			Switch $aMap
				Case $uw
					Return $lblUnderworldBlueLoss
				Case $fetid
					Return $lblFetidRiverBlueLoss
				Case $burialmounds
					Return $lblBurialMoundsBlueLoss
				Case $unholytemples
					Return $lblUnholyTemplesBlueLoss
				Case $forgottenshrines
					Return $lblForgottenShrinesBlueLoss
				Case $goldengates
					Return $lblGoldenGatesBlueLoss
				Case $courtyard
					Return $lblCourtyardBlueLoss
				Case $antechamber
					Return $lblAntechamberBlueLoss
				Case $vault
					Return $lblVaultBlueLoss
				Case $hoh
					Return $lblHallOfHeroesBlueLoss
			EndSwitch
		Case 2 ; Red
			Switch $aMap
				Case $uw
					Return $lblUnderworldRedLoss
				Case $fetid
					Return $lblFetidRiverRedLoss
				Case $burialmounds
					Return $lblBurialMoundsRedLoss
				Case $unholytemples
					Return $lblUnholyTemplesRedLoss
				Case $forgottenshrines
					Return $lblForgottenShrinesRedLoss
				Case $goldengates
					Return $lblGoldenGatesRedLoss
				Case $courtyard
					Return $lblCourtyardRedLoss
				Case $antechamber
					Return $lblAntechamberRedLoss
				Case $vault
					Return $lblVaultRedLoss
				Case $hoh
					Return $lblHallOfHeroesRedLoss
			EndSwitch
		Case 3 ; Yellow
			Switch $aMap
				Case $courtyard
					Return $lblCourtyardYellowLoss
				Case $hoh
					Return $lblHallOfHeroesYellowLoss
			EndSwitch
	EndSwitch

	Out("ERROR: Can't get coloured-loss handle for team " & GetTeamColourName($aTeam) & " on map: " & GetMapName($aMap))
EndFunc

Func GetLossHandle($aMap)
	Switch $aMap
		Case $ha
			Out("ERROR: Loss on zaishen...?")
		Case $uw
			Return $lblUnderworldLoss
		Case $fetid
			Return $lblFetidRiverLoss
		Case $burialmounds
			Return $lblBurialMoundsLoss
		Case $unholytemples
			Return $lblUnholyTemplesLoss
		Case $forgottenshrines
			Return $lblForgottenShrinesLoss
		Case $goldengates
			Return $lblGoldenGatesLoss
		Case $courtyard
			Return $lblCourtyardLoss
		Case $antechamber
			Return $lblAntechamberLoss
		Case $vault
			Out("ERROR: Loss on vault...?")
			Return $lblVaultLoss
		Case $hoh
			Return $lblHallOfHeroesLoss
		Case Else
			Out("ERROR: Can't get loss handle for unknown map: " & GetMapName($aMap))
	EndSwitch
EndFunc

Func CreateInventoryTab()
	Dim $items[4] = [ "key.ico" , "box.ico", "zbronze.ico", "zsilver.ico" ]
	Dim $labels[4]

	GUICtrlCreateTabItem("Inventory")
	AutoItSetOption("GUICoordMode", 1)

	Local $spacing = 60
	Local $left = ($uiWidth/2)-64-$spacing
	Local $top = 90
	For $i = 0 To 3
		If $i == 2 Then
			$left += (64+$spacing)
		EndIf
		Local $row = $top+(64*mod($i,2))
		$labels[$i] = GUICtrlCreateLabel("?", $left, $row, 51, 64, $SS_Center)
		GUICtrlSetResizing($labels[$i], $GUI_DOCKALL)
		GUICtrlSetFont(-1, 12, 700, 0)
		GUICtrlSetColor(-1, 0xFF0000)
		Local $icon = GUICtrlCreateIcon(@ScriptDir & "\assets\" & $items[$i], -1, $left+48, $row, 64, 64)
		GUICtrlSetResizing($icon, $GUI_DOCKALL)
	Next

	Global $lblZkeysInBag = $labels[0]
	Global $lblBoxesInBag = $labels[1]
	Global $lblBronzeCoinsInBag = $labels[2]
	Global $lblSilverCoinsInBag = $labels[3]

	GUICtrlCreateLabel("Inventory space: ", ($uiWidth/2)-64-$spacing, 220, 170, 64)
	AutoItSetOption("GUICoordMode", 0)
	Global $lblFreeSpace = GUICtrlCreateLabel("?", 105, 0, 51, 64)
	GUICtrlSetColor(-1, 0x008500)
	AutoItSetOption("GUICoordMode", 1)
	GUICtrlCreateLabel("Gold: ", ($uiWidth/2)-64-$spacing, 240, 170, 64)
	AutoItSetOption("GUICoordMode", 0)
	Global $lblGoldOnCharacter  = GUICtrlCreateLabel("?", 105, 0, 51, 64)
	GUICtrlSetColor(-1, 0x008500)

	GUICtrlCreateTabItem("")
	AutoItSetOption("GUICoordMode", 1)
EndFunc

Func CreateAccountTab()

	GUICtrlCreateTabItem("Account")

	Local $leftMargin = 8
	Local $groupTopMargin = 20
	Local $progressWidth = 320
	Local $slashPadding = 10
	;Balth
	AutoItSetOption("GUICoordMode", 1)
	GUICtrlCreateGroup("Balthazar Faction", $leftMargin, 97, 335, 60, BitOR($gui_ss_default_group, $bs_center))
	AutoItSetOption("GUICoordMode", 0)
	Global $uiBalthProgress = GUICtrlCreateProgress($leftMargin, $groupTopMargin, $progressWidth, 15)
	GUICtrlCreateLabel("/", $progressWidth/2, 20, -1, 18)
	Global $lblBalthCurrent = GUICtrlCreateLabel("0000", -$slashPadding - 50, 0, 50, 18, $SS_RIGHT)
	GUICtrlSetColor(-1, 255)

	Global $lblBalthMax = GUICtrlCreateLabel("10000", (2*$slashPadding)+50, 0, 50, 18)
	GUICtrlSetColor(-1, 0xFF0000)

	;Hero
	AutoItSetOption("GUICoordMode", 1)
	Global $lblHeroTitle = GUICtrlCreateGroup("[Hero title]", $leftMargin, 175, 335, 60, BitOR($gui_ss_default_group, $bs_center))
	AutoItSetOption("GUICoordMode", 0)
	Global $lblHeroProgress = GUICtrlCreateProgress($leftMargin, $groupTopMargin, $progressWidth, 15)
	GUICtrlCreateLabel("/", $progressWidth/2, 20, -1, 18)
	Global $lblFame = GUICtrlCreateLabel("[Current]", -$slashPadding - 50, 0, 50, 18, $SS_RIGHT)
	GUICtrlSetColor(-1, 0x008500)

	Global $lblFameNext = GUICtrlCreateLabel("[Next]", (2*$slashPadding)+50, 0, 50, 18)
	GUICtrlSetColor(-1, 0xFF0000)

	GUICtrlCreateTabItem("")
	AutoItSetOption("GUICoordMode", 1)
EndFunc

Func CreateDebugTab()
	GUICtrlCreateTabItem("Debug")

	Local $groupTopMargin = 20
	Local $groupLeftMargin = 12
	Local $top = 75
	;Labels
	AutoItSetOption("GUICoordMode", 1)
	GUICtrlCreateGroup("Position", 8, $top, 90, 85)
	AutoItSetOption("GUICoordMode", 0)
	Global Const $gX = GUICtrlCreateLabel("X: 0", 8, 20, 112, 17)
	Global Const $gY = GUICtrlCreateLabel("Y: 0", 0, 20, 128, 17)
	Global Const $uiUpdatePositionButton = GUICtrlCreateButton("Update", 0, 20, 70, 22, $WS_GROUP)
	GUICtrlSetOnEvent($uiUpdatePositionButton, "UIEventHandler")

	AutoItSetOption("GUICoordMode", 1)
	GUICtrlCreateGroup("Bundle", 8+80+5+8, $top, 90, 85)
	AutoItSetOption("GUICoordMode", 0)
	Global Const $bundleStatus = GUICtrlCreateLabel("False", 8, 20, 128, 17)
	Global Const $uiBundleButton = GUICtrlCreateButton("HasBundle", 0, 40, 70, 22, $WS_GROUP)
	GUICtrlSetOnEvent($uiBundleButton, "UIEventHandler")

	AutoItSetOption("GUICoordMode", 1)
	GUICtrlCreateGroup("Stats", 8+80+5+8+80+5+8, $top, 90, 85)
	AutoItSetOption("GUICoordMode", 0)
	Global Const $uiStatsButton = GUICtrlCreateButton("Dump stats", 8, 60, 70, 22, $WS_GROUP)
	GUICtrlSetOnEvent($uiStatsButton, "UIEventHandler")

	GUICtrlCreateTabItem("")
	AutoItSetOption("GUICoordMode", 1)
EndFunc

Func UpdatePosition()
	Local $x = DllStructGetData(GetAgentByID(-2), "X")
	Local $y = DllStructGetData(GetAgentByID(-2), "Y")
	GUICtrlSetData($gX, StringFormat("X: %d", $x))
	GUICtrlSetData($gY, StringFormat("Y: %d", $y))
	Out("Captured position: (" & $x & "," & $y & ")")
EndFunc

#EndRegion GUI

#Region UI
Func UpdateInventoryDisplay()
	GUICtrlSetData($lblBoxesInBag, CountItemInBagsByModelID($mid_hero_boxes))
	GUICtrlSetData($lblZkeysInBag, CountItemInBagsByModelID($mid_zkey))
	GUICtrlSetData($lblBronzeCoinsInBag, CountItemInBagsByModelID($mid_bronze_coins))
	GUICtrlSetData($lblSilverCoinsInBag, CountItemInBagsByModelID($mid_silver_coins))
	GUICtrlSetData($lblGoldOnCharacter, GetGoldCharacter())
	GUICtrlSetData($lblFreeSpace, CountBagsFreeSlots())
EndFunc

Func UpdateFameDisplay()
	Local $lFame = GetHeroTitleSafe()
	GUICtrlSetData($lblFame, $lFame)

	Local $titleNumber = GetHeroTitleNumber($lFame)
	Local $lFamePrevious = 0
	If $titleNumber > 0 Then
		$lFamePrevious = $HeroTitleRequirements[$titleNumber - 1]
	EndIf
	Local $lFameNext = $HeroTitleRequirements[$titleNumber]
	GUICtrlSetData($lblFameNext, $lFameNext)

	Local $frac = (($lFame - $lFamePrevious) / ($lFameNext - $lFamePrevious)) * 100
	GUICtrlSetData($lblHeroProgress, $frac)

	Local $lTitleName = GetHeroTitleName($titleNumber)
	GUICtrlSetData($lblHeroTitle, $lTitleName)
EndFunc

Func UpdateFactionDisplay()
	Local $lBalth = GetBalthazarFaction()
	Local $lMaxBalth = GetMaxBalthazarFaction()
	If $lMaxBalth == 0 Then
		;Happens sometimes. Unreliable API, no point logging.
		Return
	EndIf

	Local $frac = ($lBalth / $lMaxBalth) * 100
	GUICtrlSetData($uiBalthProgress, $frac)
	GUICtrlSetData($lblBalthCurrent, $lBalth)
	GUICtrlSetData($lblBalthMax, $lMaxBalth)
EndFunc

Func GetHeroTitleName($aRank)
	Switch ($aRank)
		Case 0
			Return "Unranked (0)"
		Case 1
			Return "Hero (1)"
		Case 2
			Return "Fierce Hero (2)"
		Case 3
			Return "Mighty Hero (3)"
		Case 4
			Return "Deadly Hero (4)"
		Case 5
			Return "Terrifying Hero (5)"
		Case 6
			Return "Conquering Hero (6)"
		Case 7
			Return "Subjugating Hero (7)"
		Case 8
			Return "Vanquishing Hero (8)"
		Case 9
			Return "Renowned Hero (9)"
		Case 10
			Return "Illustrious Hero (10)"
		Case 11
			Return "Eminent Hero (11)"
		Case 12
			Return "King's Hero (12)"
		Case 13
			Return "Emperor's Hero (13)"
		Case 14
			Return "Balthazar's Hero (14)"
		Case 15
			Return "Legendary Hero (15)"
		Case Else
			Return "Unknown"
	EndSwitch
EndFunc

Func GetHeroTitleNumber($aFame = GetHeroTitle())
	If $aFame < $HeroTitleRequirements[0] Then Return 0
	If $aFame < $HeroTitleRequirements[1] Then Return 1
	If $aFame < $HeroTitleRequirements[2] Then Return 2
	If $aFame < $HeroTitleRequirements[3] Then Return 3
	If $aFame < $HeroTitleRequirements[4] Then Return 4
	If $aFame < $HeroTitleRequirements[5] Then Return 5
	If $aFame < $HeroTitleRequirements[6] Then Return 6
	If $aFame < $HeroTitleRequirements[7] Then Return 7
	If $aFame < $HeroTitleRequirements[8] Then Return 8
	If $aFame < $HeroTitleRequirements[9] Then Return 9
	If $aFame < $HeroTitleRequirements[10] Then Return 10
	If $aFame < $HeroTitleRequirements[11] Then Return 11
	If $aFame < $HeroTitleRequirements[12] Then Return 12
	If $aFame < $HeroTitleRequirements[13] Then Return 13
	If $aFame < $HeroTitleRequirements[14] Then Return 14
	If $aFame < $HeroTitleRequirements[15] Then Return 15
	Return 15
EndFunc

#EndRegion

SetEvent("", "", "", "", "")

Func UIEventHandler()
	Switch (@GUI_CtrlId)
		Case $guistart
			If $boolrun = False Then
				Local $GWHwnd = Initialize(GUICtrlRead($guiname), True, True, False)
				If $GWHwnd == False Then
					Console("Failed to connect to GW")
					Return
				EndIf

				$boolrun = True
				GUICtrlSetData($guistart, "Running")
				GUICtrlSetState($guistart, $GUI_DISABLE)
				GUICtrlSetState($cbxHideGw, $GUI_ENABLE)
				GUICtrlSetState($uiPause, $GUI_ENABLE)
				GUICtrlSetState($guiname, $GUI_DISABLE)

				Local $lCharName = GetCharname() ; Relevant if user doesn't select anything and jumps straight to run
				GUICtrlSetData($guiname, $lCharName)

				Local $processName = GetProcessName(WinGetProcess($GWHwnd))
				WinSetTitle($uiMain, "", "HA Bot - " & $processName)

				$logfile = FileOpen(StringReplace(GetCharname(), " ", "_") & "_" & @MDAY & "_" & @MON & "_" & @YEAR & "_" & @HOUR & "_" & @MIN & ".txt", $FO_APPEND + $FO_CREATEPATH)
				$logfileExcel = FileOpen(StringReplace(GetCharname(), " ", "_") & "_" & @MDAY & "_" & @MON & "_" & @YEAR & "_" & @HOUR & "_" & @MIN & "_Excel.txt", $FO_APPEND + $FO_CREATEPATH)
				Out("HA Bot version " & $version)

				SetPlayerStatus(0) ; Offline

				UpdateFameDisplay()
				UpdateFactionDisplay()
				UpdateInventoryDisplay()

				$fameAtStart = GetHeroTitle()
				If ($fameAtStart <= 1) Then
					Out("Warning: Suspiciously low starting fame")
					Sleep(2000)
				EndIf
			EndIf
		Case $cbxHideGw
			If GUICtrlRead($cbxHideGw) = 1 Then
				DisableRendering()
				WinSetState(getwindowhandle(), "", @SW_HIDE)
				clearmemory()
			Else
				EnableRendering()
				WinSetState(getwindowhandle(), "", @SW_SHOW)
			EndIf
		Case $uiPause
			If $paused Then
				$paused = False
				GUICtrlSetData($uiPause, "Pause")
			Else
				$paused = True
				Out("PAUSE: Will pause in next outpost")
				GUICtrlSetData($uiPause, "Unpause")
			EndIf
		Case $uiUpdatePositionButton
			UpdatePosition()
		Case $uiBundleButton
			Local $bundleRead = HasRelic()
			Out("DUMP: HasBundle: " & $bundleRead)
			GUICtrlSetData($bundleStatus, $bundleRead)
		Case $uiStatsButton
			Out("DUMP: Saving colour win rates")
			WriteWinRatesToFile()
	EndSwitch
EndFunc   ;==>UIEventHandler

While 1
	Sleep(500)
	If $boolrun Then
		MainLoop()
	EndIf
WEnd

Func MainLoop()
	Local $mapState = GetMapLoading()
	If $mapState == $instancetype_loading Then
		sleep(1000)
	ElseIf $mapState == $instancetype_outpost Then
		handleOutpost()
	ElseIf $mapState == $instancetype_explorable Then
		Local $map = GetMapID()

		Switch $map
			Case $ha
				Zaishen()
			Case $uw
				Underworld()
			Case $fetid
				FetidRiver()
			Case $burialmounds
				BurialMounds()
			Case $unholytemples
				UnholyTemples()
			Case $forgottenshrines
				ForgottenShrines()
			Case $goldengates
				GoldenGates()
			Case $courtyard
				Courtyard()
			Case $antechamber
				Antechamber()
			Case $vault
				Vault()
			Case $hoh
				HallOfHeroes()
			Case Else
				Out("ERROR: No handler for map: " & GetMapName($map))
		EndSwitch
	Else
		; This never happens; even during err7/crash the map state is 0,
		; which maps to $instancetype_outpost
		Out("ERROR: Unexpected map-state " & $mapState & "," & GetMapID())
	EndIf

EndFunc   ;==>mainloop

Func handleOutpost()
	;Out("In outpost")
	GUICtrlSetData($mapDisplay, "In outpost")

	SetPlayerStatus(0) ; Offline
	UpdateFameDisplay()
	UpdateFactionDisplay()
	UpdateInventoryDisplay()

	If GetBalthazarFaction() = GetMaxBalthazarFaction() Then
		Out("Warning: Balthazar faction capped")
	EndIf

	If $paused = True Then
		Out("Bot paused")
		TravelGH()
		GUICtrlSetData($mapDisplay, GetMapName(GetMapID()))
		While $paused
			Sleep(5000)
		WEnd
		LeaveGH()
		Return
	EndIf

	If GetMapLoading() == $instancetype_outpost Then
		Local $outpostId = GetMapID()
		If $outpostId == $ha Then
			haOutpost()
		ElseIf $outpostId == $gtob Then
			greatTempleOutpost()
		ElseIf $outpostId == 0 Then
			Out("ERROR: Disconnected?")
			Disconnected()
		Else
			Out("Travel to HA (outpost was " & GetMapName($outpostID) & ")")
			TravelTo($ha)
		EndIf
	EndIf
EndFunc   ;==>start

Func TimeBetween($cTime, $sTime, $eTime)
    If _DateDiff('s', '2000/01/01 ' & $cTime & ':00', '2000/01/01 ' & $sTime & ':00') < 0 And _
       _DateDiff('s', '2000/01/01 ' & $cTime & ':00', '2000/01/01 ' & $eTime & ':00') > 0 Then
        Return True
   EndIf

	Return False
EndFunc  ; ==>_timeBetwee

Func haOutpost()
	Out("Heroes Ascent")
	GUICtrlSetData($mapDisplay, "Heroes Ascent")

	BuyZkeys()

	If $runs > 0 Then
		;WriteWinRatesToFile()
	EndIf

	DealWithQuest()

	While GetEffectTimeRemaining($skill_dishonourable) > 0
		Local $remaining = GetEffectTimeRemaining($skill_dishonourable) + 2000
		If $remaining > (10 * 60 * 1000) Then
			Out("ERROR: Dishonourable too large: " & $remaining & " (" & MsToTime($remaining) & ")")
			Sleep(5 * 60 * 1000) ; Just sleep for 5 minutes and hope it goes away
		Else
			Out("Waiting for Dishonourable: " & MsToTime($remaining))
			Sleep($remaining)
		EndIf
	Wend

	$runs += 1
	GUICtrlSetData($lblRuns, $runs)
	Out("Starting Run # " & $runs)

	; Clear memory periodically when UI is disabled
	If GUICtrlRead($cbxHideGw) == 1 Then clearmemory()

	;Out("Party size before: " & GetPartySize())
	; 1,2  w
	; 3,4  r
	; 5    me: illusion
	; 7,8  mo
	; 9,10 n: curses profane
	; 11,12,13,14 e: earth, icy, searing, immolating
	; 15   sin
	; 16   rt
	; 17,18 d wounding, d reaping
	; 19,20 p
	Sleep(3000) ; Often a delay required when bot makes first entry to HA
	While(GetPartySize() <> 8)
		Out("Add henchmen")
		Local $henchmen = [18,6,12,13,14,7,8]
		For $i = 0 To 6
			AddNPC($henchmen[$i])
			Sleep(300)
		Next
		If GetPartySize() <> 8 Then
			;This just happens sometimes. Retrying fixes it.
			;Out("ERROR: Party size: " & GetPartySize())
			LeaveGroup()
		EndIf
	Wend

	EnterChallenge()

	WaitMapLoading()
	Local $lAttempts = 0
	While (GetMapLoading() <> $instancetype_explorable) And GetMapID() == $ha And $lAttempts < 5
		Out("Waiting to load Zaishen: " & GetMapLoading() & "," & GetMapName(GetMapID()) & "," & $lAttempts)
		$lAttempts += 1
		Sleep(5000)
	Wend
	If $lAttempts == 5 Then
		Out("ERROR: Deadlock fired whilst waiting for Zaishen")
	EndIf
	Sleep(1000) ; Avoid "get party" errors when just coming out of the loading screen
EndFunc

Func greatTempleOutpost()
	Out("Great Temple")
	GUICtrlSetData($mapDisplay, "Great Temple")

	DealWithQuest()

	TravelTo($ha)
EndFunc

Func DealWithQuest()

	If GUICtrlRead($cbHaQuest) == $GUI_CHECKED Then
		If (HaveQuest() == False) Then
			Out("Need to pick up HA quest")
			If GetMapID() <> $gtob Then TravelTo($gtob)
			GetQuest()
			$haQuestWins = 0
			Out("Going to HA")
			TravelTo($ha)
		ElseIf ($haQuestWins >= 2) Then
			Out("Checking for end of quest day, time is " & @HOUR & ':' & @MIN )
			If TimeBetween(@HOUR & ':' & @MIN, '16:55', '17:50') Then
				Out("End of Quest day; not completing last quest!")
				GUICtrlSetState($cbHaQuest, $GUI_UNCHECKED)
			Else
				Out("HA quest complete, get reward")
				TravelTo($gtob)
				GetQuestReward()
				TrackQuestCompletions()
				Out("Got reward. Going back to HA")
				Return ; Loop back to Gtob handler to pick up new quest
			EndIf
		Else
			Out("Quest not complete")
		EndIf

	; TODO: Algorithmically work out quest day based on zaishen cycle?
	ElseIf TimeBetween(@HOUR & ':' & @MIN, '17:00', '17:30') And Not $checkedForQuestDayToday Then
		Out("Testing to see if it's Quest day")
		If GetMapID() <> $gtob Then TravelTo($gtob)
		If GetQuest() Then
			Out("It is quest day!")
			GUICtrlSetState($cbHaQuest, $GUI_CHECKED)
		Else
			Out("It's not quest day")
		EndIf
		TravelTo($ha)
		$checkedForQuestDayToday = True
	ElseIf @HOUR > '18' Then
		$checkedForQuestDayToday = False
	EndIf
EndFunc

Func TrackQuestCompletions()
	$totalQuestCompletions += 1
	Out("Quest completions: " & $totalQuestCompletions)
	GUICtrlSetData($lblGoldEarned, ($totalQuestCompletions * 1.5) & "k")
	$haQuestWins = 0
EndFunc

Func Poke()
	Local $enemies = CountEnemies($rangeSpirit)
	Local $allies = CountAllies($rangeSpirit)
	If $enemies == 0 Then
		Out("No-one to poke!")
	ElseIf ($enemies - $allies) <= 1 Then
		Out("Poking!")
		Local $target = GetNearestEnemyToAgent()
		CallTarget($target)
		If Not GetIsDead(GetMyID()) Then
			Sleep(300)
			Attack($target)
			MoveBackward(1)
			MoveBackward(0)
		EndIf
	Else
		Out("Not poking; I'm scared! ( foe:" & $enemies & ", friend:" & $allies &")")
	EndIf
EndFunc

Func InInstanceTooLong()
	Local $mapTimeMs = GetInstanceUpTime()

	If ($mapTimeMs/(1000*60)) > 15 Then
		; Sometimes the map changes between API calls, so you get the instance time for HA outpost
		; ...which is usually ~20 hours
		If GetMapLoading() == $instancetype_explorable Then
			Out("ERROR: In instance too long: " & GetMapName(GetMapID()) & " for " & MsToTime($mapTimeMs))
			Return True
		EndIf
	EndIf

	Return False
EndFunc

Func SleepIfMapJustStarted($sleepTime)
	Local $mapTimeMs = GetInstanceUpTime()
	If ($mapTimeMs/(1000*60)) < 1 Then
		Sleep($sleepTime)
	Else
		Out("Not sleeping; mid-map start")
	EndIf
EndFunc

#Region map handlers

#include <0-Zaishen-strategy.au3>
#include <1-Underworld-strategy.au3>
#include <2-FetidRiver-strategy.au3>
#include <3-BurialMounds_strategy.au3>
#include <4-UnholyTemples-strategy.au3>
#include <5-ForgottenShrines-strategy.au3>
#include <6-GoldenGates-strategy.au3>
#include <7-Courtyard-strategy.au3>
#include <8-Antechamber-strategy.au3>
#include <9-Vault-strategy.au3>
#include <10-HallOfHeroes-strategy.au3>

#EndRegion map handlers

Func StrongMoveTo($aX, $aY)
	Local $attempts = 0
	While True
		If MoveTo($aX, $aY) Then
			Return True
		ElseIf $attempts == 10 Then
			ExitLoop
		Else
			$attempts += 1
			Out("StrongMoveTo retry attempt " & $attempts)
			Sleep(3000)
		EndIf
	WEnd

	Return False
EndFunc

#Region Skill use and targetting

Func Upkeep()
	Local $lSkillbar = GetSkillBar()
	For $skillName in $UpkeepSkills
		Local $skillID = GetSkillID($skillName)
		;Is it active?
		Local $lCheck = GetEffect($skillID)
		If DllStructGetData($lCheck, 'SkillID') <> 0 Then
			ContinueLoop
		EndIf

		;Do we have it on our bar?
		For $i = 1 To 8
			If GetSkillBarSkillID($i) == $skillID Then
				;If it's recharged, cast it
				If DllStructGetData($lSkillbar, "Recharge" & $i) == 0 Then
					SkillUseSleep($i)
					ExitLoop
				EndIf
			EndIf
		Next
	Next
EndFunc

Func KillEnemy($range = $rangeSpellcast)
	Out("Hunting...")
	;Upkeep()

	Local $bestTarget = GetBestTarget($range)
	If Not IsDllStruct($bestTarget) Then
		Out("Debug: No-one to kill!")
		Sleep(3000)
		Return
	EndIf

	CallTarget($bestTarget)
	ChangeTarget($bestTarget)
	If Not GetIsDead() Then
		Attack($bestTarget)
	Else
		Return
	EndIf

	; Use 3 skills on target then exit
	Local $skillsUsed = 0

	Out("Hunting... skill loop starts")
	For $i = 1 To 8
		Upkeep()
		Local $skillID = GetSkillBarSkillID($i)

		Local $lSkillbar = GetSkillBar()
		If DllStructGetData($lSkillbar, "Recharge" & $i) <> 0 Then
			ContinueLoop ;Skill is not Recharged
		EndIf

		Local $skillIdStruct = GetSkillByID($skillID)
		If DllStructGetData($skillIdStruct, "Energy" & $i) > GetEnergy() Then
			ContinueLoop ; Not enough energy
			Sleep(50)
		EndIf

		If $skillID == GetSkillID("DRAIN ENCHANTMENT") Or _
		   $skillID == GetSkillID("SHATTER ENCHANTMENT") Then
			If GetIsEnchanted($bestTarget) Then
				SkillUseRange($i, $bestTarget)
				ContinueLoop
			Else
				ContinueLoop
			EndIf
		EndIf

		If $skillID == GetSkillID("WASTREL'S WORRY") Then
			SkillUseRange($i, $bestTarget)
			ExitLoop ; Effectively this means we're likely to pick another target
		EndIf

		If $skillID == GetSkillID("METEOR SHOWER") Then
			; By convention, assume that the skill to the left is GlyphSac
			Local $previousSkillID = GetSkillBarSkillID($i - 1)
			If $previousSkillID <> GetSkillID("GLYPH OF SACRIFICE") Then
				Out("Warning: Meteor Shower equipped, but previous skill isn't Glyph Sac")
			Else
				If DllStructGetData($lSkillbar, "Recharge" & $i - 1) == 0 Then
					; We have at least 25 energy, due to previous check
					; Sleep until we have 30
					While GetEnergy() < 30
						Out("Waiting for 30 energy")
						Sleep(1000)
					WEnd
					Out("Using Glyph Sac")
					SkillUseRange($i -1, $bestTarget) ; Glyph Sac
					Local $lCheck = GetEffect(GetSkillID("GLYPH OF SACRIFICE"))
					If DllStructGetData($lCheck, 'SkillID') == 0 Then
						Out("Warning: GlyphSac interrupted; not casting MS")
					Else
						Out("Using Meteor Shower")
						$bestTarget = GetBestTarget()
						SkillUseRange($i, $bestTarget) ; Meteor Shower
						ExitLoop
					EndIf
				EndIf
			EndIf
		EndIf

		; Ignore upkeep skills
		Local $skip = False
		For $skill = 0 To Ubound($UpkeepSkills)-1
			If $skillID == GetSkillID($UpkeepSkills[$skill]) Then
				$skip = True
				ExitLoop
			EndIf
		Next
		If $skip == True Then ContinueLoop

		; Ignore skills that require specific AI
		$skip = False
		For $skill = 0 To Ubound($specialSkills)-1
			If $skillID == GetSkillID($specialSkills[$skill]) Then
				$skip = True
				ExitLoop
			EndIf
		Next
		If $skip == True Then ContinueLoop

		; Refresh target information
		$bestTarget = GetAgentByID(DllStructGetData($bestTarget, "ID"))

		Local $rupted = False
		For $skill = 0 To Ubound($interuptSkills)-1
			If $skillID == GetSkillID($interuptSkills[$skill]) Then
				Out("Attempting to interupt!")
				If GetIsCasting($bestTarget) Then
					SkillUseRange($i, $bestTarget)
					$rupted = True
					ExitLoop
				EndIf
			EndIf
		Next
		If $rupted == True Then ContinueLoop

		; Pick a fresh target if HP is above 20%
		;If (DllStructGetData($bestTarget, "HP") > 0.20) Then
			;$bestTarget = GetBestTarget()
		;EndIf
		;ChangeTarget($bestTarget)
		;CallTarget($bestTarget)
		If Not GetIsDead() Then
			SkillUseRange($i, $bestTarget)
			$skillsUsed += 1
		EndIf

		If GetIsDead($bestTarget) Or $skillsUsed > 2 Then
			Out("Changing target...")
			ExitLoop
		EndIf
	Next
EndFunc   ;==>killenemy

Func SkillUseSleep($skillNumber)
	Local $skillSlotID = GetSkillBarSkillID($skillNumber)
	Local $skillIdStruct = GetSkillByID($skillSlotID)

	UseSkill($skillNumber)
	Local $activationTime = DllStructGetData($skillIdStruct, "Activation") * .5^(GetAttributeByID($GWA_CONST_FASTCASTING, True) / 15);Spell usage & fast casting time
	Local $aftercastTime = DllStructGetData($skillIdStruct, "Aftercast")
	;Out("Upkeep: Sleeping for " & $activationTime & " + " & $aftercastTime & " after casting Id " & $skillNumber)
	Sleep(($activationTime+$aftercastTime)*1000)
EndFunc   ;==>SkillUseSleep

Func SkillUseRange($skillNumber, $agent)
	Local $distance = GetDistance($agent, -2)
	If $distance < 1250 Then
		Local $skillSlotID = GetSkillBarSkillID($skillNumber)
		Local $skillIdStruct = GetSkillByID($skillSlotID)
		UseSkill($skillNumber, -1)
		Local $activationTime = DllStructGetData($skillIdStruct, "Activation") * .5^(GetAttributeByID($GWA_CONST_FASTCASTING, True) / 15);Spell usage & fast casting time
		Local $aftercastTime = DllStructGetData($skillIdStruct, "Aftercast")
		Sleep(($activationTime+$aftercastTime)*1000)
	EndIf
EndFunc   ;==>SkillUseRange

Func GetBestTarget($aSearchRange = 2000, $aSkillRange = $rangeArea)
	Local $lBestTarget = 0
	Local $lDistance, $bestScore
	Local $lAgentArray = GetAgentArray(0xDB)
	For $i = 1 To $lAgentArray[0]
		Local $lScore = 0
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		If GetDistance($lAgentArray[$i]) > $aSearchRange Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "ID") = GetMyID() Then ContinueLoop

		For $j = 1 To $lAgentArray[0]
			If $j == $i Then ContinueLoop

			If DllStructGetData($lAgentArray[$j], "Allegiance") <> 3 Then ContinueLoop
			If DllStructGetData($lAgentArray[$j], "HP") <= 0 Then ContinueLoop
			If DllStructGetData($lAgentArray[$j], "ID") = GetMyID() Then ContinueLoop
			Local $name = GetAgentName($lAgentArray[$j])
			If $name == "Priest" Or $name == "Ghostly Hero" Then ContinueLoop

			$lDistance = GetDistance($lAgentArray[$i], $lAgentArray[$j])
			;Out("Distance between " & $i & " and " & $j & " is " & $lDistance)
			; Ignore agents that are out of effect range
			; But score agents higher the closer to the target they are
			If $lDistance < $rangeNearby Then
				$lScore += _Max($aSkillRange - $lDistance, 0)
			EndIf
		Next
		;Out(" " & $lAgentArray[$i] & ":" & GetAgentNameEx($lAgentArray[$i]) & " score of " & $lScore)
		If $lScore > $bestScore Then
			;Out("Improved target is " & $i & " with a score of " & $lScore)
			$bestScore = $lScore
			$lBestTarget = $lAgentArray[$i]
		EndIf
	Next

	If Not IsDllStruct($lBestTarget) Then
		$lBestTarget = GetNearestEnemyToAgent()
	EndIf
	;Out("Best target is " & $i & " with a score of " & $bestScore)
	Return $lBestTarget
EndFunc   ;==>getbesttarget

#EndRegion Skill use and targetting

Func Disconnected()
	Out("ERROR: Disconnected! Attempting to reconnect...")
	Local $lcheck = False
	Local $ldeadlock = TimerInit()
	Do
		ControlSend(getwindowhandle(), "", "", "{Enter}")
		Sleep(200)
		$lcheck = GetMapLoading() <> $instancetype_loading And getagentexists(-2)
	Until $lcheck Or TimerDiff($ldeadlock) > 60000

	If $lcheck = False Then
		Out("ERROR: Could not reconnect, exiting")
		EnableRendering()
		WriteAllStatsToFile()
		Exit
	EndIf

	; Go back to offline following reconnect
	SetPlayerStatus(0) ; Offline
EndFunc   ;==>Disconnected

Func BuyZkeys()
	rndsleep(250)
	If (GetBalthazarFaction() < 5000) Then Return

	If ($lastZkeyPurchaseFailureTimer <> 0) Then
		Local $msSinceLastKeyBuyFailure = TimerDiff($lastZkeyPurchaseFailureTimer)

		If ($msSinceLastKeyBuyFailure < (1000 * 60 * 60 * 1)) Then
			Out("Not bothering to try to buy a key; " & Round($msSinceLastKeyBuyFailure/(60*60*1000), 2) & " < 1 hour")
			Return
		Else
			Out("Timer expired, about to buy key: " & MsToTime($msSinceLastKeyBuyFailure))
			$lastZkeyPurchaseFailureTimer = 0
		EndIf
	EndIf

	If GetMapID() == $ha Then
		Out("Trading Balthazar")
		Local $npc = GetAgentByName("Tolkano [Tournament]")
		rndsleep(500)
		If IsDllStruct($npc) And GoToNPC($npc) Then
			While (GetBalthazarFaction() >= 5000)
				Local $ZkeysBefore = CountItemInBagsByModelID($mid_zkey)
				rndsleep(500)
				dialog(135)
				rndsleep(500)
				dialog(136)
				rndsleep(500)
				Local $ZkeysAfter = CountItemInBagsByModelID($mid_zkey)
				If $ZkeysAfter > $ZkeysBefore Then
					;Bought a key successfully
					Out("Bought a key")
					$zkEarned += 1
					GUICtrlSetData($lblZkEarned, $zkEarned)
				Else
					Out("Warning: Failed by buy Zkey; at daily cap?")
					$lastZkeyPurchaseFailureTimer = TimerInit()
					ExitLoop
				EndIf
			WEnd
		Else
			Local $lMe = GetAgentByID(-2)
			Out("ERROR: Failed to find Tolkano: " & DllStructGetData($lMe, 'X') & ", " & DllStructGetData($lMe, 'Y'))
		EndIf
		rndsleep(500)
	EndIf

	UpdateFactionDisplay()
	UpdateInventoryDisplay()
EndFunc   ;==>zkeys

Func CheckIsTeamWiped()
	Local $mapState = GetMapLoading()
	If $mapState <> $instancetype_explorable Then
		; High risk of error7 if this starts to happen
		Out("ERROR: Didn't notice we were dead for too long. We're in a town already...")
		Return True
	EndIf

	Local $lAgentArray = GetParty()
	If $lAgentArray[0] == 0 Then
		Out("ERROR: GetParty() returned no party")
		Local $attempts = 0
		While($attempts < 3 And $lAgentArray[0] == 0)
			$lAgentArray = GetParty()
			$attempts += 1
			sleep(3000)
		Wend
		If $lAgentArray[0] <> 0 Then
			Out("...Recovered")
		Else
			Out("ERROR: Didn't recover from GetParty. Disconnected?")
			Disconnected()
			$lAgentArray = GetParty()
			If $lAgentArray[0] <> 0 Then
				Out("...Recovered after disconnect")
			Else
				Out("ERROR: Didn't recover from disconnected")
				; Probably could just give up and Exit here
				Return True
			EndIf
		EndIf
	EndIf

	If InInstanceTooLong() Then Resign()

	Local $teammembersalive = 0
	For $i = 1 To $lAgentArray[0]
		Local $lagent = $lAgentArray[$i]
		If DllStructGetData($lagent, "Allegiance") = 1 Then
			If Not BitAND(DllStructGetData($lagent, "Typemap"), 131072) Then ContinueLoop
			If GetIsDead($lagent) = False Then
				$teammembersalive += 1
			EndIf
		EndIf
	Next

	If $teammembersalive > 0 Then
		If GetMorale() == -60 Then
			If GetMapID() <> $courtyard Then
				Out("Death penalty 60")
				Resign()
				Return True
			Else
				; On Courtyard you res even at 60 DP
				; No DP in Hall of Heroes
				Out("Death penalty 60... but Courtyard")
				Return False
			EndIf
		Else
			;I Ent Dead
			Return False
		EndIf
	EndIf

	Out("Party is dead")
	CancelAll()

	Local $mapID = GetMapID()
	If $mapID == $courtyard Or $mapID == $hoh Or $mapID == $forgottenshrines Then
		If WaitForResOrLoss() Then
			Return True
		Else
			Sleep(1000) ; Seems to be some oddity immediately following res

			Local $mapTimeMs = GetInstanceUpTime()
			If ($mapTimeMs/(1000*60)) > 2 Then
				Out("Take ghostly following res")
				GoNpcLog(FindMyGhostly())
			EndIf
			If $mapID == $hoh Then
				Out("Checking for relics after res...")
				TargetNearestItem()
				Sleep(GetPing()+100)
				Local $potentialRelic = GetTarget()
				Out("Targetted: " & $potentialRelic)
				If GetCanPickup($potentialRelic) Then
					Out("Halls: Found a relic after res")
					PickupLoot()
				Else
					Out("Halls: Didn't find a relic after res")
				EndIf
			EndIf
			Return False
		EndIf
	ElseIf MapHasResShrine($mapID) Then
		;TODO Priest detection
		Return WaitForResOrLoss()
	Else
		Out("No res shrine; we've lost")
		WaitForResOrLoss()
		Return True
	EndIf
EndFunc   ;==>checkisteamwiped

Func WaitForResOrLoss()
	Out("Awaiting res / outpost...")
	Do
		Sleep(2000)
	Until GetIsLiving() Or InInstanceTooLong()

	Local $mapState = GetMapLoading()
	If $mapState == $instancetype_explorable Then
		Out("Res")
		Return False
	Else
		Out("Returned to outpost")
		Return True
	EndIf
EndFunc

Func FindMyGhostly($myTeam = 0)
	If $myTeam == 0 Then $myTeam = GetTeamColour()

	Local $lAgents = GetAgentArray(0xDB)
	If $lAgents[0] = 0 Then
		Out("ERROR: Can't find any agents at all!")
		Return False
	EndIf

	Local $lGhostly = 0
	For $aID = 1 To $lAgents[0]
		Local $lAgent = $lAgents[$aID]
		Local $name = GetAgentName($lAgent)
		If $name <> "Ghostly Hero" Then
			ContinueLoop
		EndIf

		Local $theirTeam = DllStructGetData($lAgent, "Team")
		Local $theirAllegiance = DllStructGetData($lAgent, 'Allegiance')
		Local $lX = Round(DllStructGetData($lAgent, 'X'), 1)
		Local $lY = Round(DllStructGetData($lAgent, 'Y'), 1)
		If ($theirTeam == $myTeam) Then
			Out("Targetted: " & $aID & ". Name: " & $name & ". " & $theirAllegiance & ", " & $theirTeam)
			$lGhostly = $lAgent
		Else
			Out("Not targetted: " & $aID & "," & $name & ", " & $theirAllegiance & ", " & $theirTeam)
		EndIf
	Next

	If Not IsDllStruct($lGhostly) Then Out("Warning: Couldn't find Ghostly")

	Return $lGhostly
EndFunc

Func PickupLoot($range = $rangeCompass)
	If GetMapLoading() == $instancetype_loading Then
		Out("Warning: Disconnected on PickupLoot (1)")
		Disconnected()
	EndIf
	Local $lme, $lagent, $litem
	Local $lblockedtimer
	Local $lblockedcount = 0
	Local $litemexists = True
	For $i = 1 To GetMaxAgents()
		If GetMapLoading() == $instancetype_loading Then
			Out("Warning: Disconnected on PickupLoot (2), agent is " & $i)
			Disconnected()
		EndIf
		$lme = GetAgentByID(-2)
		If DllStructGetData($lme, "HP") <= 0 Then Return
		$lagent = GetAgentByID($i)
		If Not GetIsMovable($lagent) Then ContinueLoop
		If Not GetCanPickup($lagent) Then ContinueLoop

		$litem = GetItemByAgentID($i)
		Local $distance = GetDistance($litem, -2)
		;If $distance > $range Then
			;Out("Debug: Not picking up item; distance too far")
			;ContinueLoop
		;EndIf

		Local $rx = DllStructGetData($litem, "X")
		Local $ry = DllStructGetData($litem, "Y")
		;If $rx == 0 And $ry == 0 Then
			;Out("Item at 0,0? Ignoring")
			;ContinueLoop
			;
		;EndIf
		Local $ax = DllStructGetData($lme, "X")
		Local $ay = DllStructGetData($lme, "Y")
		Local $itemName = GetAgentName($litem)
		Out("Picking up '" & $itemName & "' : distance is: " & $distance & ", I am at (" & $ax & "," & $ay & "), target is at (" & $rx & "," & $ry & ")")

		Do

			PickupItem($litem)
			If GetMapLoading() == $instancetype_loading Then
				Out("Warning: Disconnected on PickupLoot (4); " & $itemName)
				Disconnected()
			EndIf
			Sleep(GetPing())

			Do
				Sleep(500)
				$lme = GetAgentByID(-2)
			Until DllStructGetData($lme, "MoveX") == 0 And DllStructGetData($lme, "MoveY") == 0

			$lblockedtimer = TimerInit()
			Do
				Sleep(500)
				$litemexists = IsDllStruct(GetAgentByID($i))
			Until Not $litemexists Or TimerDiff($lblockedtimer) > 2000

			If $litemexists Then $lblockedcount += 1
		Until Not $litemexists Or $lblockedcount > 5
		If $lblockedcount > 5 Then
			Out("ERROR: Failed to pick up item")
		Else
			Out("Picked up item")
		EndIf
	Next
EndFunc   ;==>pickuploot

Func PickupMyRelic($aTeam, $range = $rangeCompass)
	If GetMapLoading() == $instancetype_loading Then
		Out("Warning: Disconnected on PickupLoot (1)")
		Disconnected()
	EndIf
	Local $lme, $lagent, $litem
	Local $lblockedtimer
	Local $lblockedcount = 0
	Local $litemexists = True

	Local $lItemsArray = GetAgentArray(0x400)
	For $i = 1 To $lItemsArray[0]
		If GetMapLoading() == $instancetype_loading Then
			Out("Warning: Disconnected on PickupLoot (2)")
			Disconnected()
		EndIf
		$lme = GetAgentByID(-2)
		If DllStructGetData($lme, "HP") <= 0 Then Return
		$litem = $lItemsArray[$i]
		If Not GetIsMovable($lagent) Then ContinueLoop
		If Not GetCanPickup($lagent) Then ContinueLoop

		Local $distance = GetDistance($litem, -2)
		;If $distance > $range Then
			;Out("Debug: Not picking up item; distance too far")
			;ContinueLoop
		;EndIf

		Local $rx = DllStructGetData($litem, "X")
		Local $ry = DllStructGetData($litem, "Y")
		;If $rx == 0 And $ry == 0 Then
			;Out("Item at 0,0? Ignoring")
			;ContinueLoop
			;
		;EndIf
		Local $ax = DllStructGetData($lme, "X")
		Local $ay = DllStructGetData($lme, "Y")
		Local $itemName = GetAgentName($litem)

		Out("Considering picking up:" & $itemName)
		If $aTeam == $iamblue Then
			If $itemName == "Blue Relic" Then
				Out("Not picking up my own relic")
				Return
			EndIf
		ElseIf $aTeam == $iamred Then
			If $itemName == "Red Relic" Then
				Out("Not picking up my own relic")
				Return
			EndIf
		EndIf

		Out("Picking up '" & $itemName & "' : distance is: " & $distance & ", I am at (" & $ax & "," & $ay & "), target is at (" & $rx & "," & $ry & ")")

		Do
			PickupItem($litem)
			If GetMapLoading() == $instancetype_loading Then
				Out("Warning: Disconnected on PickupLoot (4); " & $itemName)
				Disconnected()
			EndIf
			Sleep(GetPing())

			Do
				Sleep(500)
				$lme = GetAgentByID(-2)
			Until DllStructGetData($lme, "MoveX") == 0 And DllStructGetData($lme, "MoveY") == 0

			$lblockedtimer = TimerInit()
			Do
				Sleep(500)
				$litemexists = IsDllStruct(GetAgentByID($i))
			Until Not $litemexists Or TimerDiff($lblockedtimer) > 2000

			If $litemexists Then $lblockedcount += 1
		Until Not $litemexists Or $lblockedcount > 5
		If $lblockedcount > 5 Then
			Out("ERROR: Failed to pick up item")
		Else
			Out("Picked up item")
		EndIf
	Next
EndFunc

Func GetHeroTitleSafe()
	Local $lFame = GetHeroTitle()
	Sleep(100)
	If ($lFame >= $fameAtStart) Then
		return $lFame
	EndIf

	; API is unreliable / is being called whilst map loading
	Local $attempts = 0
	While($attempts < 5 And $lFame < $fameAtStart)
		$lFame = GetHeroTitle()
		$attempts += 1
		sleep(3000)
	Wend

	If ($lFame < $fameAtStart) Then
		Local $fameGuess = GUICtrlRead($lblFame)
		Out("ERROR: After " & $attempts & " attempts fame returned (" & $lFame & ") was lower than starting fame (" & $fameAtStart & "), so I am assuming fame is " & $fameGuess)
		; Safest thing to do is assume it's not gone up from the last update
		$lFame = $fameGuess
		Disconnected()
	EndIf

	return $lFame
EndFunc

Func GetMyLocation()
	Local $lMe = GetAgentByID(-2)
	Dim $location[2]
	$location[0] = DllStructGetData($lMe, 'X')
	$location[1] = DllStructGetData($lMe, 'Y')
	Return $location
EndFunc

Func PrintMapStart($aMap, $aTeam)
	Sleep(300)
	; Intentionally do not use GetMap/GetMapName; want to catch logic mistakes in map handlers
	GUICtrlSetData($mapDisplay, $aMap)
	Out("I am " & GetTeamColourName($aTeam) & " in " & $aMap)
	;Local $lBaseLocation = GetMyLocation()
	;Out("My base is " & $lBaseLocation[0] & "," & $lBaseLocation[1])
EndFunc

Func UpdateMapStats($aMapStartingFame, $map, $team)
	If $aMapStartingFame < GetHeroTitleSafe() Then
		RecordVictory($map, $team)
	Else
		Local $currentMap = GetMapID()
		If $map <> $currentMap And $currentMap <> $ha Then
			Out("Debug: Fame capped? Fame earned is: " & GUICtrlRead($lblFameEarned))
			RecordVictory($map, $team)
		Else
			RecordLoss($map, $team)
		EndIf
	EndIf
EndFunc

Func RecordVictory($aMap, $aTeam)
	Out("Recording victory in " & GetMapName($aMap) & " as " & GetTeamColourName($aTeam))

	$haQuestWins += 1

	If ($aMap <> GetMapID()) Then
		Out("ERROR: About to record a victory in " & GetMapName($aMap) & " but we are on " & GetMapName(GetMapID()))
		; Problem - We don't want to accumulate dishonourable,
		; but may want to leave for quest.
		; "Leave next round" bool?
	Else
		If GUICtrlRead($cbHaQuest) == $GUI_CHECKED Then
			If $haQuestWins >= 2 Then
				Out("Optimising for quest!")
				Sleep(100)
				Resign()
				Sleep(500)
				TravelTo($gtob)
			EndIf
		EndIf
	EndIf

	Local $uiWinHandle = GetWinHandle($aMap)
	GUICtrlSetData($uiWinHandle, GUICtrlRead($uiWinHandle) + 1)

	Local $colouredWinHandle = GetColouredWinHandle($aMap, $aTeam)
	GUICtrlSetData($colouredWinHandle, GUICtrlRead($colouredWinHandle) + 1)

	UpdateFameDisplay()
	UpdateFactionDisplay()
	UpdateInventoryDisplay()

	$fameup = GetHeroTitleSafe() - $fameAtStart
	GUICtrlSetData($lblFameEarned, $fameup)
EndFunc

Func RecordLoss($aMap, $aTeam)
	Out("Recording loss in " & GetMapName($aMap) & " as " & GetTeamColourName($aTeam))

	Local $uiLossHandle = GetLossHandle($aMap)
	GUICtrlSetData($uiLossHandle, GUICtrlRead($uiLossHandle) + 1)

	Local $colouredLossHandle = GetColouredLossHandle($aMap, $aTeam)
	GUICtrlSetData($colouredLossHandle, GUICtrlRead($colouredLossHandle) + 1)

	UpdateFameDisplay()
	UpdateFactionDisplay()
	UpdateInventoryDisplay()
EndFunc

Func WriteWinRatesToFile()
	OutExcel("Win rates by map:" & _
		"  Underworld blue," & GUICtrlRead(GUICtrlRead($lblUnderworldBlueWin)) & "," & GUICtrlRead($lblUnderworldBlueLoss) & @CRLF & _
		"  Underworld red," & GUICtrlRead($lblUnderworldRedWin) & "," & GUICtrlRead($lblUnderworldRedLoss) & @CRLF & _
		"  Fetid River blue," & GUICtrlRead($lblFetidRiverBlueWin) & "," & GUICtrlRead($lblFetidRiverBlueLoss) & @CRLF & _
		"  Fetid River red," & GUICtrlRead($lblFetidRiverRedWin) & "," & GUICtrlRead($lblFetidRiverRedLoss) & @CRLF & _
		"  Burial Mounds blue," & GUICtrlRead($lblBurialMoundsBlueWin) & "," & GUICtrlRead($lblBurialMoundsBlueLoss) & @CRLF & _
		"  Burial Mounds red," & GUICtrlRead($lblBurialMoundsRedWin) & "," & GUICtrlRead($lblBurialMoundsRedLoss) & @CRLF & _
		"  Unholy Temples blue," & GUICtrlRead($lblUnholyTemplesBlueWin) & "," & GUICtrlRead($lblUnholyTemplesBlueLoss) & @CRLF & _
		"  Unholy Temples red," & GUICtrlRead($lblUnholyTemplesRedWin) & "," & GUICtrlRead($lblUnholyTemplesRedLoss) & @CRLF & _
		"  Forgotten Shrines blue," & GUICtrlRead($lblForgottenShrinesBlueWin) & "," & GUICtrlRead($lblForgottenShrinesBlueLoss) & @CRLF & _
		"  Forgotten Shrines red," & GUICtrlRead($lblForgottenShrinesRedWin) & "," & GUICtrlRead($lblForgottenShrinesRedLoss) & @CRLF & _
		"  Golden Gates blue," & GUICtrlRead($lblGoldenGatesBlueWin) & "," & GUICtrlRead($lblGoldenGatesBlueLoss) & @CRLF & _
		"  Golden Gates red," & GUICtrlRead($lblGoldenGatesRedWin) & "," & GUICtrlRead($lblGoldenGatesRedLoss) & @CRLF & _
		"  Courtyard blue," & GUICtrlRead($lblCourtyardBlueWin) & "," & GUICtrlRead($lblCourtyardBlueLoss) & @CRLF & _
		"  Courtyard red," & GUICtrlRead($lblCourtyardRedWin) & "," & GUICtrlRead($lblCourtyardRedLoss) & @CRLF & _
		"  Courtyard yellow," & GUICtrlRead($lblCourtyardYellowWin) & "," & GUICtrlRead($lblCourtyardYellowLoss) & @CRLF & _
		"  Antechamber blue," & GUICtrlRead($lblAntechamberBlueWin) & "," & GUICtrlRead($lblAntechamberBlueLoss) & @CRLF & _
		"  Antechamber red," & GUICtrlRead($lblAntechamberRedWin) & "," & GUICtrlRead($lblAntechamberRedLoss) & @CRLF & _
		"  Vault blue," & GUICtrlRead($lblVaultBlueWin) & "," & GUICtrlRead($lblVaultBlueLoss) & @CRLF & _
		"  Vault red," & GUICtrlRead($lblVaultRedWin) & "," & GUICtrlRead($lblVaultRedLoss) & @CRLF & _ ; ?
		"  Hall Of Heroes blue," & GUICtrlRead($lblHallOfHeroesBlueWin) & "," & GUICtrlRead($lblHallOfHeroesBlueLoss) & @CRLF & _
		"  Hall Of Heroes red," & GUICtrlRead($lblHallOfHeroesRedWin) & "," & GUICtrlRead($lblHallOfHeroesRedLoss) & @CRLF & _
		"  Hall Of Heroes yellow," & GUICtrlRead($lblHallOfHeroesYellowWin) & "," & GUICtrlRead($lblHallOfHeroesYellowLoss))
EndFunc

Func WriteAllStatsToFile()
	WriteWinRatesToFile()

	OutExcel($runs & " runs" & @CRLF & _
		" Fame went from " & $fameAtStart & " to " & $fameup & @CRLF & _
		$zkEarned & " zkeys" & @CRLF & _
		$totalQuestCompletions & " quest completions" & @CRLF & _
		GUICtrlRead($lblBronzeCoinsInBag) & " bronze coins" & @CRLF & _
		GUICtrlRead($lblGoldOnCharacter) & " gold" & @CRLF & _
		GUICtrlRead($lblBoxesInBag) & " strongboxes")
EndFunc

Func WaitForNextMap($currentMap)
	Local $nextMapTimer = TimerInit()

	Local $waited = 0
	Local Const $Boredom = 1000 * 60 * 5  ; 5 minutes (TODO variable?)

	While GetMapID() == $currentMap
		WaitMapLoading(0, 60000)
		$waited = TimerDiff($nextMapTimer)

		If GUICtrlRead($cbxLeaveIfBored) == $GUI_CHECKED Then
			If $currentMap <> $vault And $waited > $Boredom Then
				Out("Can't be bothered to wait this long: " & MsToTime($waited))
				Resign()
				TravelTo($ha)
				Return
			EndIf
		ElseIf $waited > 1000 * 60 * 20 Then ; 20 minutes; REALLY bored
			Out("REALLY bored; resigning")
			Resign()
			TravelTo($ha)
		ElseIf $waited > $Boredom Then
			Out("Getting bored. Waited for: " & MsToTime($waited))
		EndIf
	Wend

	Local $mapState = GetMapLoading()
	If $mapState <> $instancetype_outpost And $mapState <> $instancetype_loading Then
		Out("Next map (" & GetMapName(GetMapID()) & ") loaded after: " & MsToTime(TimerDiff($nextMapTimer)))
	EndIf
EndFunc

Func GoNpcLog($aNPC)
	If Not IsDllStruct($aNPC) Then Return

	Local $success = GoToNPC($aNPC)
	If $success Then
		If @error <> 0 Then
			Local $pX = DllStructGetData($aNPC, 'X')
			Local $pY = DllStructGetData($aNPC, 'Y')
			Out("Warning: Got blocked " & @error & " times when going to NPC at " & $px & "," & $py)
		EndIf
	Else ; fail
		Local $pX = DllStructGetData($aNPC, 'X')
		Local $pY = DllStructGetData($aNPC, 'Y')
		Out("ERROR: Failed to go to NPC at " & $px & "," & $py)
	EndIf
EndFunc

Func Console($aString)
	GUICtrlSetData($console, GUICtrlRead($console) & $aString & @CRLF)
EndFunc

Func Out($aString)
	;FileFlush($logfileExcel) ; Flush the _other_ file -> Autoit bug in file buffers
	Local $lWithTimestamp = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $aString
	FileWriteLine($logfile, $lWithTimestamp)
	Console($lWithTimestamp)
	_GUICtrlEdit_Scroll($console, $SB_SCROLLCARET)
EndFunc   ;==>out

Func OutExcel($aString)
	FileFlush($logfile); Flush the _other_ file -> Autoit bug in file buffers
	Local $lWithTimestamp = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $aString
	FileWriteLine($logfileExcel, $lWithTimestamp)
EndFunc

Func CloseHandler()
	If Not $rendering Then AdlibUnRegister("_ReduceMemory")

	Out("Exit by user request.")

	WriteAllStatsToFile()

	Exit
EndFunc   ;==>CloseHandler

Func _ReduceMemory()
	If $gwpid <> -1 Then
		Local $ai_handle = DllCall("kernel32.dll", "int", "OpenProcess", "int", 2035711, "int", False, "int", $gwpid)
		Local $ai_return = DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", $ai_handle[0])
		DllCall("kernel32.dll", "int", "CloseHandle", "int", $ai_handle[0])
	Else
		Local $ai_return = DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", -1)
	EndIf
	Return $ai_return[0]
EndFunc   ;==>_ReduceMemory
