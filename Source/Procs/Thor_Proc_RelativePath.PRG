Lparameters lcName, lcPath

Local lcResult, lnPos

If Empty (lcPath)
	lcResult = Sys(2014, lcName)
Else
	lcResult = Sys(2014, lcName, lcPath)
Endif

If Len (lcResult) < Len (lcName)		;
		And lcResult = '..\'			;
		And Not lcResult = '..\..\..\'
Else
	lcResult = lcName
Endif

*!* * Removed 1/27/2013 / JRN
*!* If Len (lcResult) < Len (lcName) And Not lcResult = '..\..\..\'
*!* 	lnPos = Rat ('..\', lcResult)
*!* 	If lnPos # 0
*!* 		lnPos = lnPos + 2
*!* 	Endif
*!* 	lcResult = Left (lcResult, lnPos) + Right (lcName, Len (lcResult) - lnPos)
*!* Else
*!* 	lcResult = lcName
*!* Endif

Return Execscript(_Screen.cThorDispatcher, 'Result=', lcResult)