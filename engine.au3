#include-once
#include "..\GwAu3-main\API\_GwAu3.au3"

; ===========================================================================
; engine.au3 - Couche de compatibilite GWA2 -> GwAu3
; Maintient les memes signatures de fonctions et structures que l'ancien engine,
; tout en utilisant GwAu3 comme backend.
; Les fichiers HeroesAscentBot.au3, common.au3, skills.au3, etc. ne sont pas modifies.
; NOTE : GetMyID() est deja defini dans GwAu3_Data_Agent.au3 - ne pas le redeclarer ici.
; ===========================================================================

; ---------------------------------------------------------------------------
; Definitions des structures (identiques a l'ancien engine GWA2)
; ---------------------------------------------------------------------------
Global $gAgentStruct = 'ptr vtable;byte unknown1[24];byte unknown2[4];ptr NextAgent;byte unknown3[8];long Id;float Z;byte unknown4[8];float BoxHoverWidth;float BoxHoverHeight;byte unknown5[8];float Rotation;byte unknown6[8];long NameProperties;long Ground;byte unknown7[20];float X;float Y;byte unknown8[8];float NameTagX;float NameTagY;float NameTagZ;byte unknown9[12];long Type;float MoveX;float MoveY;byte unknown10[28];long Owner;long ItemID;byte unknown30[4];long ExtraType;byte unknown11[24];float AttackSpeed;float AttackSpeedModifier;word PlayerNumber;byte unknown12[6];ptr Equip;byte unknown13[10];byte Primary;byte Secondary;byte Level;byte Team;byte unknown14[6];float EnergyPips;byte unknown[4];float EnergyPercent;long MaxEnergy;byte unknown15[4];float HPPips;byte unknown16[4];float HP;long MaxHP;long Effects;byte unknown17[4];byte Hex;byte unknown18[18];long ModelState;long TypeMap;byte unknown19[16];long InSpiritRange;byte boring1[4];byte unknown19a[4];byte unknown20[4];byte boring2[4];long LoginNumber;float ModelMode;byte unknown21[4];long AnimationCode;byte unknown22[32];byte LastStrike;byte Allegiance;word WeaponType;word Skill;byte relic[2];byte WeaponItemType;byte OffhandItemType;word WeaponItemId;word OffhandItemId'

Global $gSkillbarStruct = 'long AgentId;long AdrenalineA1;long AdrenalineB1;dword Recharge1;dword Id1;dword Event1;long AdrenalineA2;long AdrenalineB2;dword Recharge2;dword Id2;dword Event2;long AdrenalineA3;long AdrenalineB3;dword Recharge3;dword Id3;dword Event3;long AdrenalineA4;long AdrenalineB4;dword Recharge4;dword Id4;dword Event4;long AdrenalineA5;long AdrenalineB5;dword Recharge5;dword Id5;dword Event5;long AdrenalineA6;long AdrenalineB6;dword Recharge6;dword Id6;dword Event6;long AdrenalineA7;long AdrenalineB7;dword Recharge7;dword Id7;dword Event7;long AdrenalineA8;long AdrenalineB8;dword Recharge8;dword Id8;dword Event8;dword disabled;byte unknown[8];dword Casting'

Global $gSkillStruct = 'long ID;byte Unknown1[4];long campaign;long Type;long Special;long ComboReq;long Effect1;long Condition;long Effect2;long WeaponReq;byte Profession;byte Attribute;byte Unknown2[2];long PvPID;byte Combo;byte Target;byte unknown3;byte EquipType;byte Unknown4;byte Energy;byte Unknown5[2];dword Adrenaline;float Activation;float Aftercast;long Duration0;long Duration15;long Recharge;byte Unknown6[12];long Scale0;long Scale15;long BonusScale0;long BonusScale15;float AoERange;float ConstEffect;byte unknown7[44]'

Global $gBagStruct = 'long bagType;long index;long id;ptr containerItem;long ItemsCount;ptr bagArray;ptr itemArray;long fakeSlots;long slots'

Global $gItemStruct = 'long id;long agentId;byte unknown1[4];ptr bag;ptr modstruct;long modstructsize;ptr customized;byte unknown2[4];byte type;byte unknown3;short extraId;short value;byte unknown4[4];short interaction;long modelId;ptr modString;byte unknown5[4];ptr NameString;byte unknown6[15];byte unknown65;short quantity;byte equipped;byte profession;byte typeAgain;byte slot'

Global $gEffectStruct = 'long SkillId;long EffectType;long EffectId;long AgentId;float Duration;long TimeStamp'

; Constantes de portee (utilisees par common.au3)
Global Const $rangeAdjacent  = 166.0
Global Const $rangeNearby    = 238.0
Global Const $rangeArea      = 322.0
Global Const $rangeEarshot   = 1010.0
Global Const $rangeSpellcast = 1246.0
Global Const $rangeSpirit    = 2500.0
Global Const $rangeCompass   = 5000.0

; Variables d'etat interne
Global $mUseStringLog   = False
Global $mUseEventSystem = True

; ===========================================================================
; SECTION 1 : Initialisation
; ===========================================================================

; Initialise le bot sur la fenetre GW dont le nom du personnage correspond a $aGW.
; Retourne le handle de fenetre en cas de succes, False sinon.
Func Initialize($aGW, $bChangeTitle = True, $aUseStringLog = False, $aUseEventSystem = True)
    $mUseStringLog   = $aUseStringLog
    $mUseEventSystem = $aUseEventSystem
    If Not Core_Initialize($aGW) Then Return False
    Return $g_h_GWWindow
EndFunc

; Retourne la liste des noms de personnages de toutes les instances GW en cours, separee par le separateur GUI.
Func GetLoggedCharNames()
    Local $lWinList = WinList("[REGEXPTITLE:^Guild Wars; CLASS:ArenaNet_Dx_Window_Class]")
    Local $lRet = ""
    For $i = 1 To $lWinList[0][0]
        Local $lPid = WinGetProcess($lWinList[$i][1])
        If Not $lPid Then ContinueLoop
        Memory_Open($lPid)
        If $g_h_GWProcess Then
            Local $lName = Player_GetCharname()
            If $lName <> "" Then
                If $lRet <> "" Then $lRet &= Opt("GUIDataSeparatorChar")
                $lRet &= $lName
            EndIf
            Memory_Close()
        EndIf
    Next
    Return $lRet
EndFunc

Func getloggedcharnames()
    Return GetLoggedCharNames()
EndFunc

Func GetWindowHandle()
    Return $g_h_GWWindow
EndFunc

Func getwindowhandle()
    Return $g_h_GWWindow
EndFunc

Func GetProcessName($i_pid)
    If Not ProcessExists($i_pid) Then Return SetError(1, 0, "")
    Local $a_processes = ProcessList()
    For $i = 1 To $a_processes[0][0]
        If $a_processes[$i][1] = $i_pid Then Return $a_processes[$i][0]
    Next
    Return SetError(1, 0, "")
EndFunc

Func GetCharname()
    Return Player_GetCharname()
EndFunc

Func GetLoggedIn()
    Return 1
EndFunc

Func GetPlayerStatus()
    Return Memory_Read($g_p_StatusCode)
EndFunc

Func SetPlayerStatus($aStatus)
    If $aStatus >= 0 And $aStatus <= 3 Then
        Friend_SetPlayerStatus($aStatus)
        Return True
    EndIf
    Return False
EndFunc

; ===========================================================================
; SECTION 2 : Agents - lecture des donnees
; ===========================================================================

; Convertit les IDs speciaux : -2 = moi, -1 = cible courante
Func ConvertID($aID)
    If $aID = -2 Then Return GetMyID()
    If $aID = -1 Then Return GetCurrentTargetID()
    Return $aID
EndFunc

Func GetAgentPtr($aAgentID)
    Return Agent_GetAgentPtr(ConvertID($aAgentID))
EndFunc

Func GetAgentExists($aAgentID = -2)
    Return (GetAgentPtr($aAgentID) > 0 And ConvertID($aAgentID) < Agent_GetMaxAgents())
EndFunc

Func getagentexists($aAgentID = -2)
    Return GetAgentExists($aAgentID)
EndFunc

; Retourne un DllStruct $gAgentStruct rempli depuis la memoire GW, ou 0 si l'agent n'existe pas.
Func GetAgentByID($aAgentID = -2)
    Local $lID  = ConvertID($aAgentID)
    Local $lPtr = Agent_GetAgentPtr($lID)
    If $lPtr = 0 Then Return 0
    Local $lStruct = DllStructCreate($gAgentStruct)
    DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lPtr, 'ptr', DllStructGetPtr($lStruct), 'int', DllStructGetSize($lStruct), 'int', '')
    Return $lStruct
EndFunc

; Retourne un tableau indexe de DllStructs d'agents. $aType=0 = tous (vivants), sinon filtre par Type.
Func GetAgentArray($aType = 0)
    Local $lMax = Agent_GetMaxAgents()
    Local $lReturnArray[1] = [0]
    For $i = 1 To $lMax
        Local $lPtr = Agent_GetAgentPtr($i)
        If $lPtr = 0 Then ContinueLoop
        Local $lStruct = DllStructCreate($gAgentStruct)
        DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lPtr, 'ptr', DllStructGetPtr($lStruct), 'int', DllStructGetSize($lStruct), 'int', '')
        If DllStructGetData($lStruct, 'Id') = 0 Then ContinueLoop
        If $aType <> 0 And DllStructGetData($lStruct, 'Type') <> $aType Then ContinueLoop
        $lReturnArray[0] += 1
        ReDim $lReturnArray[$lReturnArray[0] + 1]
        $lReturnArray[$lReturnArray[0]] = $lStruct
    Next
    Return $lReturnArray
EndFunc

Func GetMaxAgents()
    Return Agent_GetMaxAgents()
EndFunc

; NOTE : GetMyID() est defini dans GwAu3_Data_Agent.au3 - ne pas le redeclarer ici.

Func GetCurrentTargetID()
    Return Agent_GetCurrentTarget()
EndFunc

Func GetCurrentTarget()
    Return GetAgentByID(GetCurrentTargetID())
EndFunc

Func GetTarget($aAgent = -2)
    Return GetCurrentTarget()
EndFunc

Func GetMovStructByID($aAgentID = -2)
    Return GetAgentByID($aAgentID)
EndFunc

Func GetMovementAgentPtr($aAgentID)
    Return Agent_GetAgentPtr(ConvertID($aAgentID))
EndFunc

Func GetAgentByPlayerName($aPlayerName)
    For $i = 1 To Agent_GetMaxAgents()
        Local $lAgent = GetAgentByID($i)
        If Not IsDllStruct($lAgent) Then ContinueLoop
        If DllStructGetData($lAgent, 'LoginNumber') = 0 Then ContinueLoop
        If StringInStr(GetAgentName($lAgent), $aPlayerName) > 0 Then Return $lAgent
    Next
    Return 0
EndFunc

Func GetAgentByName($aName)
    For $i = 1 To Agent_GetMaxAgents()
        Local $lAgent = GetAgentByID($i)
        If Not IsDllStruct($lAgent) Then ContinueLoop
        Local $lName = Agent_GetAgentInfo($i, "Name")
        If StringInStr($lName, $aName) > 0 Then Return $lAgent
    Next
    Return 0
EndFunc

Func GetAgentName($aAgent = -2)
    Local $lID
    If IsDllStruct($aAgent) Then
        $lID = DllStructGetData($aAgent, 'Id')
    Else
        $lID = ConvertID($aAgent)
    EndIf
    Return Agent_GetAgentInfo($lID, "Name")
EndFunc

Func GetPlayerName($aAgent = -2)
    Return GetAgentName($aAgent)
EndFunc

Func GetAgentNameEx($aAgent = -2)
    Return GetAgentName($aAgent)
EndFunc

; ===========================================================================
; SECTION 3 : Etat des agents
; ===========================================================================

Func GetIsDead($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return True
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0010) > 0
EndFunc

Func GetIsLiving($aAgent = -2)
    Return Not GetIsDead($aAgent)
EndFunc

Func GetIsMovable($aAgent)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return DllStructGetData($aAgent, 'Type') = 0x400
EndFunc

Func GetIsCasting($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return DllStructGetData($aAgent, 'Skill') <> 0
EndFunc

Func GetIsEnchanted($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0080) > 0
EndFunc

Func GetHasHex($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0800) > 0
EndFunc

Func GetHasDegenHex($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x1000) > 0
EndFunc

Func GetIsBleeding($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0001) > 0
EndFunc

Func GetHasCondition($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0002) > 0
EndFunc

Func GetHasDeepWound($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0200) > 0
EndFunc

Func GetIsPoisoned($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0004) > 0
EndFunc

Func GetHasWeaponSpell($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x8000) > 0
EndFunc

Func GetIsMoving($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return DllStructGetData($aAgent, 'MoveX') <> 0 Or DllStructGetData($aAgent, 'MoveY') <> 0
EndFunc

Func GetIsKnocked($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0020) > 0
EndFunc

Func GetIsAttacking($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return DllStructGetData($aAgent, 'ModelState') = 0x60
EndFunc

Func GetIsBoss($aAgent)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0400) > 0
EndFunc

Func GetIsStatic($aAgent)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return DllStructGetData($aAgent, 'Type') = 0x200
EndFunc

Func GetEnergy($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return 0
    Return DllStructGetData($aAgent, 'EnergyPercent') * DllStructGetData($aAgent, 'MaxEnergy')
EndFunc

Func GetHealth($aAgent = -2)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return 0
    Return DllStructGetData($aAgent, 'HP')
EndFunc

Func GetCanPickup($aAgent)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return GetAssignedToMe($aAgent) Or DllStructGetData($aAgent, 'Owner') = 0
EndFunc

Func GetCanPickUp($aAgent)
    Return GetCanPickup($aAgent)
EndFunc

Func GetAssignedToMe($aAgent)
    If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Return DllStructGetData($aAgent, 'Owner') = GetMyID()
EndFunc

; ===========================================================================
; SECTION 4 : Distances et recherche d'agents
; ===========================================================================

Func ComputeDistance($aX1, $aY1, $aX2, $aY2)
    Return Sqrt(($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2)
EndFunc

Func GetDistance($aAgent1 = -1, $aAgent2 = -2)
    If IsDllStruct($aAgent1) = 0 Then $aAgent1 = GetAgentByID($aAgent1)
    If IsDllStruct($aAgent2) = 0 Then $aAgent2 = GetAgentByID($aAgent2)
    If Not IsDllStruct($aAgent1) Or Not IsDllStruct($aAgent2) Then Return 999999
    Return Sqrt((DllStructGetData($aAgent1, 'X') - DllStructGetData($aAgent2, 'X')) ^ 2 + _
                (DllStructGetData($aAgent1, 'Y') - DllStructGetData($aAgent2, 'Y')) ^ 2)
EndFunc

Func GetPseudoDistance($aAgent1, $aAgent2 = -2)
    Return GetDistance($aAgent1, $aAgent2)
EndFunc

Func GetNearestEnemyToAgent($aAgent = -2)
    Local $lNearestAgent = 0
    Local $lNearestDist  = 100000000
    Local $lAgentArray   = GetAgentArray(0xDB)
    If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return 0
    For $i = 1 To $lAgentArray[0]
        If DllStructGetData($lAgentArray[$i], 'Allegiance') <> 3 Then ContinueLoop
        If DllStructGetData($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
        If BitAND(DllStructGetData($lAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop
        Local $lDist = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + _
                       (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
        If $lDist < $lNearestDist Then
            $lNearestDist  = $lDist
            $lNearestAgent = $lAgentArray[$i]
        EndIf
    Next
    Return $lNearestAgent
EndFunc

Func GetNearestAgentToAgent($aAgent = -2)
    Local $lNearestAgent = 0
    Local $lNearestDist  = 100000000
    Local $lAgentArray   = GetAgentArray(0xDB)
    If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return 0
    Local $lMyID = DllStructGetData($aAgent, 'Id')
    For $i = 1 To $lAgentArray[0]
        If DllStructGetData($lAgentArray[$i], 'Id') = $lMyID Then ContinueLoop
        Local $lDist = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + _
                       (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
        If $lDist < $lNearestDist Then
            $lNearestDist  = $lDist
            $lNearestAgent = $lAgentArray[$i]
        EndIf
    Next
    Return $lNearestAgent
EndFunc

Func GetNearestAgentToCoords($aX, $aY)
    Local $lNearestAgent = 0
    Local $lNearestDist  = 100000000
    Local $lAgentArray   = GetAgentArray(0xDB)
    For $i = 1 To $lAgentArray[0]
        Local $lDist = ($aX - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + _
                       ($aY - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
        If $lDist < $lNearestDist Then
            $lNearestDist  = $lDist
            $lNearestAgent = $lAgentArray[$i]
        EndIf
    Next
    Return $lNearestAgent
EndFunc

Func GetNearestNPCToAgent($aAgent = -2)
    Local $lNearestAgent = 0
    Local $lNearestDist  = 100000000
    Local $lAgentArray   = GetAgentArray(0xDB)
    If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return 0
    For $i = 1 To $lAgentArray[0]
        If DllStructGetData($lAgentArray[$i], 'Allegiance') <> 6 Then ContinueLoop
        If DllStructGetData($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
        If BitAND(DllStructGetData($lAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop
        Local $lDist = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + _
                       (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
        If $lDist < $lNearestDist Then
            $lNearestDist  = $lDist
            $lNearestAgent = $lAgentArray[$i]
        EndIf
    Next
    Return $lNearestAgent
EndFunc

Func GetNearestNPCToCoords($aX, $aY)
    Local $lNearestAgent = 0
    Local $lNearestDist  = 100000000
    Local $lAgentArray   = GetAgentArray(0xDB)
    For $i = 1 To $lAgentArray[0]
        If DllStructGetData($lAgentArray[$i], 'Allegiance') <> 6 Then ContinueLoop
        If DllStructGetData($lAgentArray[$i], 'HP') <= 0 Then ContinueLoop
        If BitAND(DllStructGetData($lAgentArray[$i], 'Effects'), 0x0010) > 0 Then ContinueLoop
        Local $lDist = ($aX - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + _
                       ($aY - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
        If $lDist < $lNearestDist Then
            $lNearestDist  = $lDist
            $lNearestAgent = $lAgentArray[$i]
        EndIf
    Next
    Return $lNearestAgent
EndFunc

Func GetNearestSignpostToAgent($aAgent = -2)
    Local $lNearestAgent = 0
    Local $lNearestDist  = 100000000
    Local $lAgentArray   = GetAgentArray()
    If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return 0
    For $i = 1 To $lAgentArray[0]
        If DllStructGetData($lAgentArray[$i], 'Type') <> 0x200 Then ContinueLoop
        Local $lDist = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + _
                       (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
        If $lDist < $lNearestDist Then
            $lNearestDist  = $lDist
            $lNearestAgent = $lAgentArray[$i]
        EndIf
    Next
    Return $lNearestAgent
EndFunc

Func GetNearestSignpostToCoords($aX, $aY)
    Local $lNearestAgent = 0
    Local $lNearestDist  = 100000000
    Local $lAgentArray   = GetAgentArray()
    For $i = 1 To $lAgentArray[0]
        If DllStructGetData($lAgentArray[$i], 'Type') <> 0x200 Then ContinueLoop
        Local $lDist = ($aX - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + _
                       ($aY - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
        If $lDist < $lNearestDist Then
            $lNearestDist  = $lDist
            $lNearestAgent = $lAgentArray[$i]
        EndIf
    Next
    Return $lNearestAgent
EndFunc

Func GetNearestItemToAgent($aAgent = -2, $aCanPickUp = True)
    Local $lNearestAgent = 0
    Local $lNearestDist  = 100000000
    Local $lAgentArray   = GetAgentArray()
    If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return 0
    For $i = 1 To $lAgentArray[0]
        If DllStructGetData($lAgentArray[$i], 'Type') <> 0x400 Then ContinueLoop
        If $aCanPickUp And Not GetCanPickup($lAgentArray[$i]) Then ContinueLoop
        Local $lDist = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentArray[$i], 'X')) ^ 2 + _
                       (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentArray[$i], 'Y')) ^ 2
        If $lDist < $lNearestDist Then
            $lNearestDist  = $lDist
            $lNearestAgent = $lAgentArray[$i]
        EndIf
    Next
    Return $lNearestAgent
EndFunc

; ===========================================================================
; SECTION 5 : Groupe et heros
; ===========================================================================

Func GetParty($aAgentArray = 0)
    Local $lReturnArray[1] = [0]
    If $aAgentArray = 0 Then $aAgentArray = GetAgentArray(0xDB)
    For $i = 1 To $aAgentArray[0]
        If DllStructGetData($aAgentArray[$i], 'Allegiance') <> 1 Then ContinueLoop
        If Not BitAND(DllStructGetData($aAgentArray[$i], 'TypeMap'), 0x20000) Then ContinueLoop
        $lReturnArray[0] += 1
        ReDim $lReturnArray[$lReturnArray[0] + 1]
        $lReturnArray[$lReturnArray[0]] = $aAgentArray[$i]
    Next
    Return $lReturnArray
EndFunc

Func GetPartySize()
    Local $lSize = 0
    Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0]
    For $i = 0 To 2
        $lOffset[4] = $i * 0x10 + 0xC
        Local $lReturn = Memory_ReadPtr($g_p_BasePointer, $lOffset)
        $lSize += $lReturn[1]
    Next
    Return $lSize
EndFunc

Func GetPartyState($aFlag)
    Local $lOffset[4] = [0, 0x18, 0x4C, 0x14]
    Local $lBitMask = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Return BitAND($lBitMask[1], $aFlag) > 0
EndFunc

Func GetPartyDefeated()
    Return GetPartyState(0x20)
EndFunc

Func GetPartyWaitingForMission()
    Return GetPartyState(0x8)
EndFunc

Func GetIsHardMode()
    Return GetPartyState(0x10)
EndFunc

Func GetPartyDanger($aAgentArray = 0, $aParty = 0)
    If $aAgentArray = 0 Then $aAgentArray = GetAgentArray(0xDB)
    If $aParty = 0 Then $aParty = GetParty($aAgentArray)
    For $pi = 1 To $aParty[0]
        For $ai = 1 To $aAgentArray[0]
            If DllStructGetData($aAgentArray[$ai], 'Allegiance') <> 3 Then ContinueLoop
            If GetDistance($aParty[$pi], $aAgentArray[$ai]) < $rangeArea Then Return True
        Next
    Next
    Return False
EndFunc

Func GetAgentDanger($aAgent = -2, $aAgentArray = 0)
    If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
    If $aAgentArray = 0 Then $aAgentArray = GetAgentArray(0xDB)
    For $i = 1 To $aAgentArray[0]
        If DllStructGetData($aAgentArray[$i], 'Allegiance') <> 3 Then ContinueLoop
        If GetDistance($aAgent, $aAgentArray[$i]) < $rangeArea Then Return True
    Next
    Return False
EndFunc

Func GetHeroCount()
    Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
    Local $lHeroCount = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Return $lHeroCount[1]
EndFunc

Func GetHeroID($aHeroNumber)
    If $aHeroNumber = 0 Then Return GetMyID()
    Local $lOffset[6] = [0, 0x18, 0x4C, 0x54, 0x24, 0x18 * ($aHeroNumber - 1)]
    Local $lAgentID = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Return $lAgentID[1]
EndFunc

Func GetHeroNumberByAgentID($aAgentID)
    For $i = 1 To GetHeroCount()
        If GetHeroID($i) = $aAgentID Then Return $i
    Next
    Return 0
EndFunc

Func GetHeroNumberByHeroID($aHeroId)
    Return GetHeroNumberByAgentID($aHeroId)
EndFunc

Func GetHeroProfession($aHeroNumber, $aSecondary = False)
    Local $lAgent = GetAgentByID(GetHeroID($aHeroNumber))
    If Not IsDllStruct($lAgent) Then Return 0
    If $aSecondary Then Return DllStructGetData($lAgent, 'Secondary')
    Return DllStructGetData($lAgent, 'Primary')
EndFunc

Func GetMorale($aHeroNumber = 0)
    Local $lAgentID = GetHeroID($aHeroNumber)
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x638]
    Local $lIndex = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Local $lOffset2[6] = [0, 0x18, 0x2C, 0x62C, 8 + 0xC * BitAND($lAgentID, $lIndex[1]), 0x18]
    Local $lReturn = Memory_ReadPtr($g_p_BasePointer, $lOffset2)
    Return $lReturn[1] - 100
EndFunc

; ===========================================================================
; SECTION 6 : Competences et effets
; ===========================================================================

; Retourne un DllStruct $gSkillbarStruct pour le joueur ou le heros $aHeroNumber.
Func GetSkillbar($aHeroNumber = 0)
    Local $lSkillbarStruct = DllStructCreate($gSkillbarStruct)
    Local $lOffset[5] = [0, 0x18, 0x2C, 0x6F0, 0]
    For $i = 0 To GetHeroCount()
        $lOffset[4] = $i * 0xBC
        Local $lAddr = Memory_ReadPtr($g_p_BasePointer, $lOffset)
        ; $lAddr[0] est l'adresse physique de l'entree de skillbar dans le tableau
        DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lAddr[0], 'ptr', DllStructGetPtr($lSkillbarStruct), 'int', DllStructGetSize($lSkillbarStruct), 'int', '')
        If DllStructGetData($lSkillbarStruct, 'AgentId') = GetHeroID($aHeroNumber) Then Return $lSkillbarStruct
    Next
    Return DllStructCreate($gSkillbarStruct)
EndFunc

Func GetSkillbarSkillID($aSkillSlot, $aHeroNumber = 0)
    Return DllStructGetData(GetSkillbar($aHeroNumber), 'Id' & $aSkillSlot)
EndFunc

Func GetSkillBarSkillID($aSkillSlot, $aHeroNumber = 0)
    Return GetSkillbarSkillID($aSkillSlot, $aHeroNumber)
EndFunc

Func GetSkillbarSkillAdrenaline($aSkillSlot, $aHeroNumber = 0)
    Return DllStructGetData(GetSkillbar($aHeroNumber), 'AdrenalineA' & $aSkillSlot)
EndFunc

Func GetSkillbarSkillRecharge($aSkillSlot, $aHeroNumber = 0)
    Return DllStructGetData(GetSkillbar($aHeroNumber), 'Recharge' & $aSkillSlot)
EndFunc

; Retourne un DllStruct $gSkillStruct pour le skill ID donne (lecture memoire directe).
Func GetSkillByID($aSkillID)
    Local $lSkillStruct = DllStructCreate($gSkillStruct)
    Local $lSkillStructAddress = $g_p_SkillBase + 160 * $aSkillID
    DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lSkillStructAddress, 'ptr', DllStructGetPtr($lSkillStruct), 'int', DllStructGetSize($lSkillStruct), 'int', '')
    Return $lSkillStruct
EndFunc

Func GetEnergyCost($aSkill)
    If Not IsDllStruct($aSkill) Then $aSkill = GetSkillByID($aSkill)
    Return DllStructGetData($aSkill, 'Energy')
EndFunc

Func GetSkillTimer()
    Return Skill_GetSkillTimer()
EndFunc

; Retourne un DllStruct $gEffectStruct si l'effet $aSkillID est actif, sinon un tableau [0].
; Callers : If DllStructGetData($lCheck, 'SkillID') <> 0 -> actif
;           If IsArray($aEffect) Then Return 0 -> inactif
Func GetEffect($aSkillID = 0, $aHeroNumber = 0)
    Local $lReturnArray[1] = [0]
    If $aSkillID = 0 Then Return $lReturnArray

    Local $lHeroID = GetHeroID($aHeroNumber)
    Local $lPtr = Agent_GetAgentEffectInfo($lHeroID, $aSkillID)
    If $lPtr = 0 Then Return $lReturnArray

    Local $lReturn = DllStructCreate($gEffectStruct)
    DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lPtr, 'ptr', DllStructGetPtr($lReturn), 'int', DllStructGetSize($lReturn), 'int', '')
    Return $lReturn
EndFunc

; Retourne le temps restant en ms d'un effet. Accepte un skillID ou un DllStruct d'effet.
Func GetEffectTimeRemaining($aEffect)
    If Not IsDllStruct($aEffect) Then
        Local $lHeroID = GetHeroID(0)
        Local $lRemaining = Agent_GetAgentEffectInfo($lHeroID, $aEffect, "TimeRemaining")
        If IsNumber($lRemaining) Then Return $lRemaining
        Return 0
    EndIf
    If IsArray($aEffect) Then Return 0
    Return DllStructGetData($aEffect, 'Duration') * 1000 - (Skill_GetSkillTimer() - DllStructGetData($aEffect, 'TimeStamp'))
EndFunc

Func GetAttributeByID($aAttributeID, $aWithRunes = False, $aHeroNumber = 0)
    Local $lAgentID = GetHeroID($aHeroNumber)
    Local $lOffset[5] = [0, 0x18, 0x2C, 0xAC, 0]
    For $i = 0 To GetHeroCount()
        $lOffset[4] = 0x3D8 * $i
        Local $lBuffer = Memory_ReadPtr($g_p_BasePointer, $lOffset)
        If $lBuffer[1] = $lAgentID Then
            Local $lOffset2[5] = [0, 0x18, 0x2C, 0xAC, 0]
            $lOffset2[4] = ($aWithRunes ? 0xC : 0x8) + 0x3D8 * $i + 0x14 * $aAttributeID
            $lBuffer = Memory_ReadPtr($g_p_BasePointer, $lOffset2)
            Return $lBuffer[1]
        EndIf
    Next
    Return 0
EndFunc

Func GetBuffCount($aHeroNumber = 0)
    Return 0
EndFunc

Func GetIsTargetBuffed($aSkillID, $aAgentID, $aHeroNumber = 0)
    Return False
EndFunc

Func GetBuffByIndex($aBuffNumber, $aHeroNumber = 0)
    Return 0
EndFunc

; ===========================================================================
; SECTION 7 : Carte et navigation
; ===========================================================================

Func GetMapID()
    Return Map_GetMapID()
EndFunc

Func GetMapLoading()
    Return Map_GetInstanceInfo("Type")
EndFunc

Func GetMapIsLoaded()
    Return Map_GetInstanceInfo("Type") <> 2
EndFunc

Func GetInstanceUpTime()
    Return Map_GetInstanceUpTime()
EndFunc

Func GetDistrict()
    Return Map_GetCharacterInfo("District")
EndFunc

Func GetRegion()
    Return Map_GetRegion()
EndFunc

Func GetLanguage()
    Return Map_GetCharacterInfo("Language")
EndFunc

Func GetBuildNumber()
    Return 0
EndFunc

Func WaitMapLoading($aMapID = 0, $aDeadlock = 15000)
    Local $lDeadlock = TimerInit()
    Local $lType
    Do
        Sleep(100)
        $lType = Map_GetInstanceInfo("Type")
        If $lType = 2 Then $lDeadlock = TimerInit()
        If $aDeadlock > 0 And TimerDiff($lDeadlock) > $aDeadlock Then Return False
    Until $lType <> 2 And GetMapIsLoaded() And ($aMapID = 0 Or GetMapID() = $aMapID)
    RndSleep(500)
    Return True
EndFunc

Func InitMapLoad()
    ; No-op : GwAu3 gere l'etat de chargement en interne
EndFunc

; ===========================================================================
; SECTION 8 : Faction et titres
; ===========================================================================

Func GetBalthazarFaction()
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x798]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetMaxBalthazarFaction()
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x7C0]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetKurzickFaction()
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x780]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetMaxKurzickFaction()
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x784]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetLuxonFaction()
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x788]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetMaxLuxonFaction()
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x78C]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetImperialFaction()
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x790]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetMaxImperialFaction()
    Local $lOffset[4] = [0, 0x18, 0x2C, 0x794]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetHeroTitle()
    Local $lOffset[5] = [0, 0x18, 0x2C, 0x81C, 0x4]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)[1]
EndFunc

Func GetGladiatorTitle()
    Return Title_GetTitleInfo(6, "CurrentPoints")
EndFunc

Func GetCommanderTitle()
    Return Title_GetTitleInfo(10, "CurrentPoints")
EndFunc

Func GetZaishenTitle()
    Return Title_GetTitleInfo(23, "CurrentPoints")
EndFunc

Func GetTournamentPoints()
    Return 0
EndFunc

Func GetGoldCharacter()
    Return Item_GetInventoryInfo("GoldCharacter")
EndFunc

Func GetGoldStorage()
    Return Item_GetInventoryInfo("GoldStorage")
EndFunc

Func GetExperience()
    Return 0
EndFunc

Func GetAreaVanquished()
    Return 0
EndFunc

Func GetFoesKilled()
    Return 0
EndFunc

Func GetFoesToKill()
    Return 0
EndFunc

; Titres supplementaires
Func GetKurzickTitle()
    Return Title_GetTitleInfo(16, "CurrentPoints")
EndFunc

Func GetLuxonTitle()
    Return Title_GetTitleInfo(17, "CurrentPoints")
EndFunc

Func GetDrunkardTitle()
    Return Title_GetTitleInfo(4, "CurrentPoints")
EndFunc

Func GetSurvivorTitle()
    Return Title_GetTitleInfo(3, "CurrentPoints")
EndFunc

Func GetMaxTitles()
    Return 0
EndFunc

Func GetLuckyTitle()
    Return Title_GetTitleInfo(9, "CurrentPoints")
EndFunc

Func GetUnluckyTitle()
    Return Title_GetTitleInfo(10, "CurrentPoints")
EndFunc

Func GetSunspearTitle()
    Return Title_GetTitleInfo(12, "CurrentPoints")
EndFunc

Func GetLightbringerTitle()
    Return Title_GetTitleInfo(13, "CurrentPoints")
EndFunc

Func GetGamerTitle()
    Return Title_GetTitleInfo(11, "CurrentPoints")
EndFunc

Func GetLegendaryGuardianTitle()
    Return Title_GetTitleInfo(14, "CurrentPoints")
EndFunc

Func GetSweetTitle()
    Return Title_GetTitleInfo(5, "CurrentPoints")
EndFunc

Func GetAsuraTitle()
    Return Title_GetTitleInfo(19, "CurrentPoints")
EndFunc

Func GetDeldrimorTitle()
    Return Title_GetTitleInfo(20, "CurrentPoints")
EndFunc

Func GetVanguardTitle()
    Return Title_GetTitleInfo(22, "CurrentPoints")
EndFunc

Func GetNornTitle()
    Return Title_GetTitleInfo(21, "CurrentPoints")
EndFunc

Func GetNorthMasteryTitle()
    Return Title_GetTitleInfo(18, "CurrentPoints")
EndFunc

Func GetPartyTitle()
    Return Title_GetTitleInfo(7, "CurrentPoints")
EndFunc

Func GetTreasureTitle()
    Return Title_GetTitleInfo(24, "CurrentPoints")
EndFunc

Func GetWisdomTitle()
    Return Title_GetTitleInfo(25, "CurrentPoints")
EndFunc

Func GetCodexTitle()
    Return Title_GetTitleInfo(8, "CurrentPoints")
EndFunc

Func GetCharacterSlots()
    Return 0
EndFunc

Func GetDisplayLanguage()
    Return Map_GetCharacterInfo("Language")
EndFunc

; ===========================================================================
; SECTION 9 : Inventaire et objets
; ===========================================================================

Func GetBag($aBag)
    Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x4 * $aBag]
    Local $lBagStruct = DllStructCreate($gBagStruct)
    Local $lBagPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    If $lBagPtr[1] = 0 Then Return $lBagStruct
    DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lBagPtr[1], 'ptr', DllStructGetPtr($lBagStruct), 'int', DllStructGetSize($lBagStruct), 'int', '')
    Return $lBagStruct
EndFunc

Func GetItemBySlot($aBag, $aSlot)
    Local $lBag
    If IsDllStruct($aBag) = 0 Then
        $lBag = GetBag($aBag)
    Else
        $lBag = $aBag
    EndIf
    Local $lBuffer     = DllStructCreate('ptr')
    Local $lItemStruct = DllStructCreate($gItemStruct)
    DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, _
        'int', DllStructGetData($lBag, 'itemArray') + 4 * ($aSlot - 1), _
        'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
    If DllStructGetData($lBuffer, 1) = 0 Then Return $lItemStruct
    DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, _
        'int', DllStructGetData($lBuffer, 1), _
        'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
    Return $lItemStruct
EndFunc

Func GetItemByItemID($aItemID)
    Local $lItemStruct = DllStructCreate($gItemStruct)
    Local $lOffset[4] = [0, 0x18, 0x40, 0xC0]
    Local $lItemArraySize = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Local $lOffset2[5] = [0, 0x18, 0x40, 0xB8, 0]
    For $lItemID = 1 To $lItemArraySize[1]
        $lOffset2[4] = 0x4 * $lItemID
        Local $lItemPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset2)
        If $lItemPtr[1] = 0 Then ContinueLoop
        DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
        If DllStructGetData($lItemStruct, 'id') = $aItemID Then Return $lItemStruct
    Next
    Return $lItemStruct
EndFunc

Func GetItemByAgentID($aAgentID)
    Local $lItemStruct = DllStructCreate($gItemStruct)
    Local $lOffset[4] = [0, 0x18, 0x40, 0xC0]
    Local $lItemArraySize = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Local $lOffset2[5] = [0, 0x18, 0x40, 0xB8, 0]
    Local $lAgentID = ConvertID($aAgentID)
    For $lItemID = 1 To $lItemArraySize[1]
        $lOffset2[4] = 0x4 * $lItemID
        Local $lItemPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset2)
        If $lItemPtr[1] = 0 Then ContinueLoop
        DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
        If DllStructGetData($lItemStruct, 'agentId') = $lAgentID Then Return $lItemStruct
    Next
    Return $lItemStruct
EndFunc

Func GetItemByModelID($aModelID)
    Local $lItemStruct = DllStructCreate($gItemStruct)
    Local $lOffset[4] = [0, 0x18, 0x40, 0xC0]
    Local $lItemArraySize = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Local $lOffset2[5] = [0, 0x18, 0x40, 0xB8, 0]
    For $lItemID = 1 To $lItemArraySize[1]
        $lOffset2[4] = 0x4 * $lItemID
        Local $lItemPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset2)
        If $lItemPtr[1] = 0 Then ContinueLoop
        DllCall($g_h_Kernel32, 'int', 'ReadProcessMemory', 'int', $g_h_GWProcess, 'int', $lItemPtr[1], 'ptr', DllStructGetPtr($lItemStruct), 'int', DllStructGetSize($lItemStruct), 'int', '')
        If DllStructGetData($lItemStruct, 'modelId') = $aModelID Then Return $lItemStruct
    Next
    Return $lItemStruct
EndFunc

Func GetRarity($aItem)
    Return 0
EndFunc

Func GetIsRareMaterial($aItem)
    Return False
EndFunc

Func GetIsCommonMaterial($aItem)
    Return False
EndFunc

Func GetIsIDed($aItem)
    Return False
EndFunc

Func GetIsIdentified($aItem)
    Return False
EndFunc

Func GetItemReq($aItem)
    Return 0
EndFunc

Func GetItemAttribute($aItem)
    Return 0
EndFunc

Func GetModByIdentifier($aItem, $aIdentifier)
    Return 0
EndFunc

Func GetModStruct($aItem)
    Return 0
EndFunc

Func GetTraderCostID()
    Return Merchant_GetTraderCostID()
EndFunc

Func GetTraderCostValue()
    Return Merchant_GetTraderCostValue()
EndFunc

Func GetMerchantItemsBase()
    Return Merchant_GetMerchantItemsBase()
EndFunc

Func GetMerchantItemsSize()
    Return Merchant_GetMerchantItemsSize()
EndFunc

Func FindSalvageKit()
    Return 0
EndFunc

Func FindExpertSalvageKit()
    Return 0
EndFunc

Func FindIDKit()
    Return 0
EndFunc

Func FindIdentificationKit()
    Return 0
EndFunc

; ===========================================================================
; SECTION 10 : Quetes
; ===========================================================================

; Retourne une valeur non nulle si la quete est dans le journal, 0 sinon.
Func GetQuestByID($aQuestID = 0)
    If $aQuestID = 0 Then Return 0
    Local $lSize = World_GetWorldInfo("QuestLogSize")
    If $lSize = 0 Then Return 0
    For $i = 0 To $lSize
        Local $lOffset[5] = [0, 0x18, 0x2C, 0x52C, 0x34 * $i]
        Local $lFound = Memory_ReadPtr($g_p_BasePointer, $lOffset, "long")
        If $lFound[1] = $aQuestID Then Return $lFound[0]
    Next
    Return 0
EndFunc

Func AcceptQuest($aQuestID)
    Return Quest_AcceptQuest($aQuestID)
EndFunc

Func QuestReward($aQuestID)
    Return Quest_QuestReward($aQuestID)
EndFunc

Func AbandonQuest($aQuestID)
    Return 0
EndFunc

; ===========================================================================
; SECTION 11 : Actions de mouvement
; ===========================================================================

Func Move($aX, $aY, $aRandom = 50)
    If GetAgentExists(-2) Then
        Map_Move($aX + Random(-$aRandom, $aRandom), $aY + Random(-$aRandom, $aRandom))
        Return True
    EndIf
    Return False
EndFunc

Func MoveTo($aX, $aY, $aRandom = 50)
    Local $lBlocked = 0
    Local $lMapLoading = GetMapLoading(), $lMapLoadingOld
    Local $lDestX = $aX + Random(-$aRandom, $aRandom)
    Local $lDestY = $aY + Random(-$aRandom, $aRandom)

    Map_Move($lDestX, $lDestY)
    Local $lMe = GetAgentByID(-2)

    While IsDllStruct($lMe) And ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) >= 25
        Sleep(100)
        $lMe = GetAgentByID(-2)
        If Not IsDllStruct($lMe) Then Return False
        If DllStructGetData($lMe, 'HP') <= 0 Then Return False

        $lMapLoadingOld = $lMapLoading
        $lMapLoading = GetMapLoading()
        If $lMapLoading <> $lMapLoadingOld Then Return False

        If Not GetIsMoving($lMe) Then
            $lBlocked += 1
            If $lBlocked > 5 Then
                Map_Move($lDestX + Random(-50, 50), $lDestY + Random(-50, 50))
                $lBlocked = 0
            EndIf
        Else
            $lBlocked = 0
        EndIf
    WEnd
    Return True
EndFunc

Func GoPlayer($aAgent)
    Local $lID = IsDllStruct($aAgent) ? DllStructGetData($aAgent, 'Id') : ConvertID($aAgent)
    Agent_GoPlayer($lID)
EndFunc

Func GoNPC($aAgent)
    Local $lID = IsDllStruct($aAgent) ? DllStructGetData($aAgent, 'Id') : ConvertID($aAgent)
    Agent_GoNPC($lID)
EndFunc

Func GoSignpost($aAgent)
    GoNPC($aAgent)
EndFunc

Func GoToSignpost($aAgent)
    GoToNPC($aAgent)
EndFunc

Func GoToNPC($aAgent)
    If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
    If Not IsDllStruct($aAgent) Then Return False
    Local $lMapLoading = GetMapLoading(), $lMapLoadingOld
    Local $lBlocked = 0

    Move(DllStructGetData($aAgent, 'X'), DllStructGetData($aAgent, 'Y'), 100)
    Sleep(100)
    GoNPC($aAgent)
    Sleep(GetPing() + 300)

    Do
        Sleep(100)
        Local $lMe = GetAgentByID(-2)
        If Not IsDllStruct($lMe) Then Return False
        If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop

        $lMapLoadingOld = $lMapLoading
        $lMapLoading = GetMapLoading()
        If $lMapLoading <> $lMapLoadingOld Then ExitLoop

        If Not GetIsMoving($lMe) Then
            $lBlocked += 1
            If $lBlocked > 10 Then Return False
        Else
            $lBlocked = 0
        EndIf
    Until GetDistance($lMe, $aAgent) < $rangeNearby

    Return True
EndFunc

Func MoveBackward($aMove)
    Local $lMe = GetAgentByID(-2)
    If Not IsDllStruct($lMe) Then Return
    Local $myX = DllStructGetData($lMe, 'X')
    Local $myY = DllStructGetData($lMe, 'Y')
    Local $mvX = DllStructGetData($lMe, 'MoveX')
    Local $mvY = DllStructGetData($lMe, 'MoveY')
    If $mvX = 0 And $mvY = 0 Then Return
    Local $len = Sqrt($mvX ^ 2 + $mvY ^ 2)
    Map_Move($myX - $aMove * $mvX / $len, $myY - $aMove * $mvY / $len)
EndFunc

Func MoveForward($aMove)
    Local $lMe = GetAgentByID(-2)
    If Not IsDllStruct($lMe) Then Return
    Local $mvX = DllStructGetData($lMe, 'MoveX')
    Local $mvY = DllStructGetData($lMe, 'MoveY')
    If $mvX = 0 And $mvY = 0 Then Return
    Local $len = Sqrt($mvX ^ 2 + $mvY ^ 2)
    Local $myX = DllStructGetData($lMe, 'X')
    Local $myY = DllStructGetData($lMe, 'Y')
    Map_Move($myX + $aMove * $mvX / $len, $myY + $aMove * $mvY / $len)
EndFunc

Func TurnLeft($aTurn)
EndFunc

Func TurnRight($aTurn)
EndFunc

Func StrafeLeft($aStrafe)
EndFunc

Func StrafeRight($aStrafe)
EndFunc

Func ToggleAutoRun()
EndFunc

Func ReverseDirection()
EndFunc

; ===========================================================================
; SECTION 12 : Actions de combat et competences
; ===========================================================================

Func Attack($aAgent, $aCallTarget = False)
    Local $lID = IsDllStruct($aAgent) ? DllStructGetData($aAgent, 'Id') : ConvertID($aAgent)
    If $aCallTarget Then Agent_CallTarget($lID)
    Agent_Attack($lID)
EndFunc

Func ChangeTarget($aAgent)
    Local $lID = IsDllStruct($aAgent) ? DllStructGetData($aAgent, 'Id') : ConvertID($aAgent)
    Agent_ChangeTarget($lID)
EndFunc

Func CallTarget($aTarget)
    Local $lID = IsDllStruct($aTarget) ? DllStructGetData($aTarget, 'Id') : ConvertID($aTarget)
    Agent_CallTarget($lID)
EndFunc

Func ClearTarget()
    Agent_ChangeTarget(0)
EndFunc

Func TargetNearestEnemy()
    Agent_TargetNearestEnemy()
EndFunc

Func TargetNextEnemy()
    Agent_TargetNearestEnemy()
EndFunc

Func TargetPreviousEnemy()
    Agent_TargetNearestEnemy()
EndFunc

Func TargetNearestAlly()
    Agent_TargetNearestAlly()
EndFunc

Func TargetNearestItem()
    ; Pas de fonction directe dans GwAu3 - utilise le ciblage d'ennemi proche comme fallback
    Agent_TargetNearestEnemy()
EndFunc

Func TargetNextItem()
EndFunc

Func TargetPreviousItem()
EndFunc

Func TargetSelf()
    Agent_ChangeTarget(GetMyID())
EndFunc

Func TargetCalledTarget()
    Agent_TargetNearestEnemy()
EndFunc

Func TargetPartyMember($aNumber)
    Local $lID = GetHeroID($aNumber)
    If $lID Then Agent_ChangeTarget($lID)
EndFunc

Func TargetNextPartyMember()
EndFunc

Func TargetPreviousPartyMember()
EndFunc

Func UseSkill($aSkillSlot, $aTarget = 0, $aCallTarget = False)
    Local $lTargetID
    If IsDllStruct($aTarget) Then
        $lTargetID = DllStructGetData($aTarget, 'Id')
    ElseIf $aTarget = 0 Then
        $lTargetID = GetCurrentTargetID()
    Else
        $lTargetID = ConvertID($aTarget)
    EndIf
    If $aCallTarget And $lTargetID > 0 Then Agent_CallTarget($lTargetID)
    Skill_UseSkill($aSkillSlot, $lTargetID)
EndFunc

Func UseHeroSkill($aHero, $aSkillSlot, $aTarget = 0)
    Local $lTargetID
    If IsDllStruct($aTarget) Then
        $lTargetID = DllStructGetData($aTarget, 'Id')
    ElseIf $aTarget = 0 Then
        $lTargetID = 0
    Else
        $lTargetID = ConvertID($aTarget)
    EndIf
    Skill_UseHeroSkill($aHero, $aSkillSlot, $lTargetID)
EndFunc

Func CancelAction()
    Agent_CancelAction()
EndFunc

Func ActionInteract()
EndFunc

Func ActionFollow()
EndFunc

Func DropBundle()
EndFunc

; ===========================================================================
; SECTION 13 : Groupe et heros (actions)
; ===========================================================================

Func AddHero($aHeroId)
EndFunc

Func KickHero($aHeroId)
EndFunc

Func KickAllHeroes()
    Party_KickAllHeroes()
EndFunc

Func AddNPC($aNpcId)
    Party_AddNPC($aNpcId)
EndFunc

Func AddNpc($aNpcId)
    AddNPC($aNpcId)
EndFunc

Func KickNpc($aNpcId)
EndFunc

Func CancelHero($aHeroNumber)
EndFunc

Func CancelAll()
    Party_CancelAll()
EndFunc

Func ClearPartyCommands()
    Party_CancelAll()
EndFunc

Func CommandHero($aHeroNumber, $aX, $aY)
    Party_CommandHero($aHeroNumber, $aX, $aY)
EndFunc

Func CommandAll($aX, $aY)
    Party_CommandAll($aX, $aY)
EndFunc

Func LockHeroTarget($aHeroNumber, $aAgentID = 0)
EndFunc

Func SetHeroAggression($aHeroNumber, $aAggression)
EndFunc

Func DisableHeroSkillSlot($aHeroNumber, $aSkillSlot)
    Ui_DisableHeroSkill($aHeroNumber, $aSkillSlot)
EndFunc

Func EnableHeroSkillSlot($aHeroNumber, $aSkillSlot)
    Ui_EnableHeroSkill($aHeroNumber, $aSkillSlot)
EndFunc

Func ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
    Ui_ToggleHeroSkillState($aHeroNumber, $aSkillSlot)
EndFunc

Func GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot)
    Return Party_GetIsHeroSkillDisabled($aHeroNumber, $aSkillSlot)
EndFunc

Func LeaveGroup($aKickHeroes = True)
    Party_LeaveGroup($aKickHeroes)
EndFunc

Func Resign()
    Chat_SendChat("resign", "/")
EndFunc

; ===========================================================================
; SECTION 14 : Voyages et instances
; ===========================================================================

Func TravelTo($aMapID, $aDis = 0)
    If GetMapID() = $aMapID And $aDis = 0 And GetMapLoading() = 0 Then Return True
    Map_TravelTo($aMapID, Map_GetCharacterInfo("Language"), Map_GetRegion(), $aDis, False)
    Return WaitMapLoading($aMapID)
EndFunc

Func ZoneMap($aMapID, $aDistrict = 0)
    Map_TravelTo($aMapID, Map_GetCharacterInfo("Language"), Map_GetRegion(), $aDistrict, False)
EndFunc

Func MoveMap($aMapID, $aRegion, $aDistrict, $aLanguage)
    Map_TravelTo($aMapID, $aLanguage, $aRegion, $aDistrict, False)
EndFunc

Func ReturnToOutpost()
    Map_ReturnToOutpost(False)
    WaitMapLoading()
EndFunc

Func EnterChallenge()
    Map_EnterChallenge(False)
EndFunc

Func EnterChallengeForeign()
    Map_EnterChallenge(True)
EndFunc

Func TravelGH()
    Map_TravelGH()
    Return WaitMapLoading()
EndFunc

Func LeaveGH()
    Map_LeaveGH()
    Return WaitMapLoading()
EndFunc

; ===========================================================================
; SECTION 15 : Rendu graphique
; ===========================================================================

Func EnableRendering()
    Ui_EnableRendering()
EndFunc

Func DisableRendering()
    Ui_DisableRendering()
EndFunc

Func DisplayAll($aDisplay)
    If $aDisplay Then
        Ui_EnableRendering()
    Else
        Ui_DisableRendering()
    EndIf
EndFunc

Func DisplayAllies($aDisplay)
EndFunc

Func DisplayEnemies($aDisplay)
EndFunc

; ===========================================================================
; SECTION 16 : Chat et communication
; ===========================================================================

Func WriteChat($aMessage, $aSender = 'GWA2')
    Chat_WriteChat($aMessage, $aSender)
EndFunc

Func SendChat($aMessage, $aChannel = '!')
    Chat_SendChat($aMessage, $aChannel)
EndFunc

Func SendWhisper($aReceiver, $aMessage)
    Chat_SendWhisper($aReceiver, $aMessage)
EndFunc

; ===========================================================================
; SECTION 17 : Actions sur les objets
; ===========================================================================

Func PickUpItem($aItem)
    Local $lAgentID
    If IsDllStruct($aItem) = 0 Then
        $lAgentID = $aItem
    ElseIf DllStructGetSize($aItem) < 400 Then
        $lAgentID = DllStructGetData($aItem, 'agentId')
    Else
        $lAgentID = DllStructGetData($aItem, 'Id')
    EndIf
    Item_PickUpItem($lAgentID)
EndFunc

Func UseItem($aItem)
    Local $lItemID = IsDllStruct($aItem) ? DllStructGetData($aItem, 'id') : $aItem
    Item_UseItem($lItemID)
EndFunc

Func EquipItem($aItem)
    Local $lItemID = IsDllStruct($aItem) ? DllStructGetData($aItem, 'id') : $aItem
    Item_EquipItem($lItemID)
EndFunc

Func DropItem($aItem, $aAmount = 0)
EndFunc

Func MoveItem($aItem, $aBag, $aSlot)
EndFunc

Func AcceptAllItems()
EndFunc

Func DestroyItem($aItem)
EndFunc

Func SellItem($aItem, $aQuantity = 0)
EndFunc

Func BuyItem($aItem, $aQuantity, $aValue)
EndFunc

Func BuyIDKit($aQuantity = 1)
EndFunc

Func BuyIdentificationKit($aQuantity = 1)
EndFunc

Func BuySuperiorIDKit($aQuantity = 1)
EndFunc

Func BuySuperiorIdentificationKit($aQuantity = 1)
EndFunc

Func DropGold($aAmount = 0)
    Item_DropGold($aAmount)
EndFunc

Func DepositGold($aAmount = 0)
EndFunc

Func WithdrawGold($aAmount = 0)
EndFunc

Func ChangeGold($aCharacter, $aStorage)
    Item_ChangeGold($aCharacter, $aStorage)
EndFunc

Func TraderRequest($aModelID, $aExtraID = -1)
    DllStructSetData($g_d_RequestQuote, 2, $aModelID)
    Core_Enqueue($g_p_RequestQuote, 8)
    Merchant_WaitForQuote(5000)
EndFunc

Func TraderBuy()
    If Merchant_IsValidQuote() Then
        Core_Enqueue($g_p_TraderBuy, 4)
        Sleep(100)
    EndIf
EndFunc

Func TraderRequestSell($aItem)
EndFunc

Func TraderSell()
EndFunc

Func StartSalvage($aItem, $aExpert = False)
EndFunc

Func SalvageMaterials()
EndFunc

Func SalvageMod($aModIndex)
EndFunc

Func IdentifyItem($aItem)
EndFunc

Func IdentifyBag($aBag, $aWhites = False, $aGolds = True)
EndFunc

Func TradePlayer($aAgent)
EndFunc

Func AcceptTrade()
EndFunc

Func SubmitOffer($aGold = 0)
EndFunc

Func CancelTrade()
EndFunc

Func ChangeOffer()
EndFunc

Func OfferItem($lItemid, $aQuantity = 1)
EndFunc

Func TradeWinExist()
    Return False
EndFunc

Func TradeOfferItemExist()
    Return False
EndFunc

Func TradeOfferMoneyExist()
    Return False
EndFunc

; ===========================================================================
; SECTION 18 : Dialogues, barres de competences et UI
; ===========================================================================

Func Dialog($aDialogID)
    Game_Dialog($aDialogID)
EndFunc

Func SetDisplayedTitle($aTitle = 0)
EndFunc

Func SetSkillbarSkill($aSlot, $aSkillID, $aHeroNumber = 0)
EndFunc

Func LoadSkillBar($aSkill1 = 0, $aSkill2 = 0, $aSkill3 = 0, $aSkill4 = 0, $aSkill5 = 0, $aSkill6 = 0, $aSkill7 = 0, $aSkill8 = 0, $aHeroNumber = 0)
EndFunc

Func LoadSkillTemplate($aTemplate, $aHeroNumber = 0)
EndFunc

Func SetAttributes($fAttsID, $fAttsLevel, $aHeroNumber = 0)
EndFunc

Func ChangeSecondProfession($aProfession, $aHeroNumber = 0)
EndFunc

Func SkipCinematic()
    Cinematic_SkipCinematic()
EndFunc

Func OpenChest()
EndFunc

Func DropBuff($aSkillID, $aAgentID, $aHeroNumber = 0)
EndFunc

Func MakeScreenshot()
EndFunc

Func InvitePlayer($aPlayerName)
EndFunc

Func SwitchMode($aMode)
    Game_SwitchMode($aMode)
EndFunc

Func ChangeWeaponSet($aSet)
EndFunc

Func SuppressAction($aSuppress)
EndFunc

; Systeme d'evenements non supporte dans cette couche de compatibilite
Func SetEvent($aSkillActivate = '', $aSkillCancel = '', $aSkillComplete = '', $aChatReceive = '', $aLoadFinished = '')
EndFunc

Func DonateFaction($aFaction)
EndFunc

Func CloseAllPanels()
EndFunc

Func ToggleHeroWindow()
EndFunc

Func ToggleInventory()
EndFunc

Func ToggleAllBags()
EndFunc

Func ToggleWorldMap()
EndFunc

Func ToggleOptions()
EndFunc

Func ToggleQuestWindow()
EndFunc

Func ToggleSkillWindow()
EndFunc

Func ToggleMissionMap()
EndFunc

Func ToggleFriendList()
EndFunc

Func ToggleGuildWindow()
EndFunc

Func TogglePartyWindow()
EndFunc

Func ToggleScoreChart()
EndFunc

Func ToggleLayoutWindow()
EndFunc

Func ToggleMinionList()
EndFunc

Func ToggleHeroPanel($aHero)
EndFunc

Func ToggleHeroPetPanel($aHero)
EndFunc

Func TogglePetPanel()
EndFunc

Func ToggleHelpWindow()
EndFunc

; ===========================================================================
; SECTION 19 : Utilitaires
; ===========================================================================

Func RndSleep($aAmount, $aRandom = 0.05)
    Other_RndSleep($aAmount, $aRandom)
EndFunc

Func rndsleep($aAmount, $aRandom = 0.05)
    Other_RndSleep($aAmount, $aRandom)
EndFunc

Func TolSleep($aAmount = 150, $aTolerance = 50)
    Other_TolSleep($aAmount, $aTolerance)
EndFunc

Func GetPing()
    Return Other_GetPing()
EndFunc

Func GetIsPointInPolygon($aAreaCoords, $aPosX = 0, $aPosY = 0)
    Local $n = UBound($aAreaCoords, 1)
    Local $inside = False
    Local $j = $n - 1
    For $i = 0 To $n - 1
        If ($aAreaCoords[$i][1] > $aPosY) <> ($aAreaCoords[$j][1] > $aPosY) And _
           $aPosX < ($aAreaCoords[$j][0] - $aAreaCoords[$i][0]) * ($aPosY - $aAreaCoords[$i][1]) / _
                    ($aAreaCoords[$j][1] - $aAreaCoords[$i][1]) + $aAreaCoords[$i][0] Then
            $inside = Not $inside
        EndIf
        $j = $i
    Next
    Return $inside
EndFunc

Func ClearMemory()
EndFunc

Func SetMaxMemory($aMemory = 157286400)
EndFunc

Func EnsureEnglish($aEnsure)
EndFunc

Func ToggleLanguage()
EndFunc

Func ChangeMaxZoom($aZoom = 750)
EndFunc

Func Bin64ToDec($aBinary)
    Return Number($aBinary)
EndFunc

Func Base64ToBin64($aCharacter)
    Return ""
EndFunc

Func GetProfPrimaryAttribute($aProfession)
    Switch $aProfession
        Case 1 ; Warrior
            Return 4
        Case 2 ; Ranger
            Return 8
        Case 3 ; Monk
            Return 16
        Case 4 ; Necromancer
            Return 14
        Case 5 ; Mesmer
            Return 6
        Case 6 ; Elementalist
            Return 0
        Case 7 ; Assassin
            Return 29
        Case 8 ; Ritualist
            Return 31
        Case 9 ; Paragon
            Return 36
        Case 10 ; Dervish
            Return 35
    EndSwitch
    Return 0
EndFunc
