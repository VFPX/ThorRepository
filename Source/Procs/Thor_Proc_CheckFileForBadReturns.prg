Lparameters lcFile

Local lcCode, lcExt, loLines, lxResult
lxResult = ''
lcExt	 = Upper(Justext(lcFile))

Do Case
	Case Not File(lcFile)
		Return Null

	Case lcExt == 'PRG'
		lcCode	= Filetostr(lcFile)
		loLines	= Execscript(_Screen.cThorDispatcher, 'Thor_Proc_CheckCodeBlockForBadReturns', lcCode)

	Case lcExt == 'VCX'

	Otherwise
		Return Null

Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result=', lxResult)
