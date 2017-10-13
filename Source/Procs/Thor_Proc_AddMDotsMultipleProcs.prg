Lparameters tcCode, tlUpperCase

Local lcCode, lcNewCode, lcResult, lnI, loBlock, loCodeBlocks
loCodeBlocks = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetProcedureStartPositions.prg', tcCode)

lcResult = tcCode

* Going backwards so that the replacements do not move
For lnI = loCodeBlocks.Count To 1 Step - 1
	loBlock	  = loCodeBlocks[lnI]
	lcCode	  = Substr (tcCode, loBlock.Start, loBlock.Length)
	lcNewCode = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_AddMDotsSingleProc', lcCode, tlUpperCase)
	lcResult  = Stuff (lcResult, loBlock.Start, loBlock.Length, lcNewCode)
Endfor

Execscript (_Screen.cThorDispatcher, 'Result=', lcResult)

