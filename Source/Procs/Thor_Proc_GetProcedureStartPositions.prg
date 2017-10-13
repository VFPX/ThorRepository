Lparameters tcCode, tlClass

Local loResult As 'Empty'
Local lcName, lcType, lnEndByte, lnI, lnLines, lnStartByte, lnStartLine, loProcs

loProcs	 = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetFullStartPositions', tcCode)
loResult = Createobject ('Collection')

If 0 = loProcs.Count
	loResult.Add (AddEntry('', 1, Len (tcCode)))
Else
	lnStartLine = 1
	* for a PRG with PROCs and FUNCs
	For lnI = 0 To loProcs.Count
		Do Case
			Case lnI = 0
				lnStartByte	= 0
				lnEndByte	= loProcs(1).StartByte
				If lnEndByte = 0
					Loop
				Endif
				lcName = ''
				lcType = 'Procedure'
			Case lnI < loProcs.Count
				lcName		= loProcs (lnI).Name
				lnStartByte	= loProcs (lnI).StartByte
				lnEndByte	= loProcs (lnI + 1).StartByte
				lcType		= loProcs (lnI).Type
			Otherwise
				lcName		= loProcs (lnI).Name
				lnStartByte	= loProcs (lnI).StartByte
				lnEndByte	= Len(tcCode)
				lcType		= loProcs (lnI).Type
		Endcase

		If Inlist (lcType, 'Procedure', 'Method') or (tlClass and lcType = 'Class')
			loResult.Add (AddEntry (lcName, lnStartByte + 1, lnEndByte - lnStartByte))
		Endif
	EndFor
Endif

ExecScript(_Screen.cThorDispatcher, 'Result=', loResult)

Return 



Procedure AddEntry (lcName, lnStartByte, lnLength)
	Local loResult As 'Empty'
	loResult = Createobject ('Empty')
	AddProperty (loResult, 'Name', lcName)
	AddProperty (loResult, 'Start', lnStartByte)
	AddProperty (loResult, 'Length', lnLength)
	Return loResult
Endproc


