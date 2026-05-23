
Func BuyMaterial($aMaterialID, $aQuantity)
	Dim $waypoints[36][3] = [ _
		[$burningisle, -3793, 1069], _
		[$burningisle, -2798, -74], _
		[$druidsisle, -989, 4493], _
		[$frozenisle, 71, 834], _
		[$frozenisle, 99, 2660], _
		[$frozenisle, -385, 3254], _
		[$frozenisle, -983, 3195], _
		[$huntersisle, 3267, 6557], _
		[$isleofthedead, -3415, -1658], _
		[$nomadsisle, 1930, 4129], _
		[$nomadsisle, 462, 4094], _
		[$warriorsisle, 4108, 8404], _
		[$warriorsisle, 3403, 6583], _
		[$warriorsisle, 3415, 5617], _
		[$wizardsisle, 3610, 9619], _
		[$imperialisle, 759, 11465], _
		[$isleofjade, 8919, 3459], _
		[$isleofjade, 6789, 2781], _
		[$isleofjade, 6566, 2248], _
		[$isleofmeditation, -2197, 8076], _
		[$isleofmeditation, -1745, 8681], _
		[$isleofmeditation, -331, 8084], _
		[$isleofmeditation, 422, 8769], _
		[$isleofmeditation, 549, 9531], _
		[$isleofweepingstone, -3988, 7588], _
		[$isleofweepingstone, -3095, 8535], _
		[$isleofweepingstone, -2431, 7946], _
		[$isleofweepingstone, -1618, 8797], _
		[$corruptedisle, -4424, 5645], _
		[$corruptedisle, -4443, 4679], _
		[$isleofsolitude, 3172, 3728], _
		[$isleofsolitude, 3221, 4789], _
		[$isleofsolitude, 3745, 4542], _
		[$isleofwurms, 8353, 2995], _
		[$isleofwurms, 6708, 3093], _
		[$unchartedisle, 2530, -2403] _
	]
	For $i = 0 To (UBound($waypoints) - 1)
		If ($waypoints[$i][0] == GetMapID()) Then
			Do
				MoveTo($waypoints[$i][1], $waypoints[$i][2], 50)
			Until CheckArea($waypoints[$i][1], $waypoints[$i][2])
		EndIf
	Next

	Local $lRare = GetAgentByName("Rare Material Trader")
	If IsDllStruct($lRare) Then
		Out("Going to trader")
		GoToNPC($lRare)
	Else
		Out("ERROR: Failed to find trader")
	EndIf

	For $q = 1 To $aQuantity
		TraderRequest($aMaterialID)
		Sleep(2 * GetPing())
		TraderBuy()
	Next
EndFunc
