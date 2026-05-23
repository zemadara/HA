Func Vault()
	SkipCinematic()
	
	GUICtrlSetData($mapDisplay, "Vault")
	
	Out("Vault")
	GUICtrlSetData($lblVaultWin, GUICtrlRead($lblVaultWin) + 1)

	If GUICtrlRead($cbxLeaveBeforeHalls) == $GUI_CHECKED Then
		TravelTo($ha)
	Else
		WaitForNextMap($vault)
	EndIf
EndFunc   ;==>vault
