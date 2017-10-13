#Define		ccThorKey			'File name'
#Define		ccThorTool			'HackCX'

Execscript(_Screen.cThorDispatcher, 'Result= ', GetHackCX())

Procedure GetHackCX
	Local lcDisplayName, lcExecutable, lcFile, lcFileName, lnMsgBoxAns
	lcExecutable = Execscript(_Screen.cThorDispatcher, 'Get Option=', ccThorKey, ccThorTool)
	*!* ******************** Removed 12/4/2014 *****************
	*!* If File(Nvl(lcExecutable, ''))
	*!* 	Return lcExecutable
	*!* Endif
	If File('HACKCX4.EXE')
		lcFile		  = Fullpath('HACKCX4.EXE')
		lcDisplayName = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_RelativePath', lcFile)
		lnMsgBoxAns	  = Messagebox('Use ' + lcDisplayName + '?', 35, 'Looking for HackCX')
		Do Case
			Case lnMsgBoxAns = 6 && Yes
				Execscript(_Screen.cThorDispatcher, 'Set Option=', ccThorKey, ccThorTool, lcFile)
				Return lcFile
			Case lnMsgBoxAns = 2 && Cancel
				Return ''
		Endcase
	Endif

	lcFile = Getfile('EXE', 'HackCX Executable', 'OK', 0, 'Find HackCX')
	If File(lcFile)
		Execscript(_Screen.cThorDispatcher, 'Set Option=', ccThorKey, ccThorTool, lcFile)
		Return lcFile
	Else
		Return ''
	Endif

Endproc
