Define Class CloseTemps As Custom

	Dimension aStart[1]
	nfiles = 0

	Procedure Init
		Local aTemp[1]
		This.nfiles = Aused (aTemp)
		If This.nfiles > 0
			Acopy (aTemp, This.aStart)
		Else
			This.aStart = ''
		Endif
	Endproc

	Procedure Destroy
		Local lnI
		Local aNow[1]
		For lnI = 1 To Aused (aNow)
			If Ascan (This.aStart, aNow[lnI, 1], -1, -1, 1, 2 + 4) = 0
				Use In aNow[lnI, 1]
			Endif
		Endfor
	Endproc

Enddefine
