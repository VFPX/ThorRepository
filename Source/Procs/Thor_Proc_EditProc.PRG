#Define CR   Chr(13)
#Define LF   Chr(10)
#Define CRLF Chr(13) + Chr(10)
#Define Tab  Chr(9)

Lparameters tcFileName

Local lcClipText, lcFileName, lcFormFileName, lcFullFileName, lcFullFilePath, lcPrivateFile
Local lcResponse, lcToolFolder, lnMsgBoxAns, loEditorWin, loTools

lcFullFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=' + tcFileName)
lcFullFilePath = Upper (Addbs (Justpath (lcFullFileName)))
lcToolFolder   = Execscript (_Screen.cThorDispatcher, 'Tool Folder=')

* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
loTools = Execscript (_Screen.cThorDispatcher, 'Class= tools from pemeditor')

Do Case
	Case Empty (lcFullFileName)
		lcFileName = Forceext (tcFileName, 'PRG')
		lnMsgBoxAns = Messagebox ('Create "' + lcFileName + '" in folder "My Tools"?', 292 ;
			  , 'File "' + lcFileName + '" not found')
		Do Case
			Case lnMsgBoxAns = 6
				lcPrivateFile = Forcepath (lcFileName, lcToolFolder + 'My Tools\')
				loTools.EditSourceX (lcPrivateFile)
			Case lnMsgBoxAns = 7
		Endcase

	Case lcFullFilePath == Upper (lcToolFolder) Or lcFullFilePath == Upper (lcToolFolder + 'Procs\')
		lcFormFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_Proc_EditProc.SCX')
		Do Form (lcFormFileName) With lcFullFileName To lcResponse
		Do Case
			Case lcResponse = 'Read Only'
				Modify Command (lcFullFileName) Nowait Noedit

			Case lcResponse = 'My Tools'
				lcPrivateFile = Forcepath (lcFullFileName, lcToolFolder + 'My Tools\')
				loTools.EditSourceX (lcPrivateFile)

				lcClipText = Filetostr (lcFullFileName)
				* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
				loEditorWin = Execscript (_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')
				loEditorWin.Paste (lcClipText)
				loEditorWin.SetInsertionPoint(0)
			Case lcResponse = 'Tools'
				EditFile (lcFullFileName)
		Endcase
	Otherwise
		EditFile (lcFullFileName)
Endcase


Procedure EditFile (lcFile)
	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
	Local loTools
	loTools = Execscript (_Screen.cThorDispatcher, 'Class= tools from pemeditor')
	If 'O' = Vartype (loTools)
		loTools.EditSourceX (lcFile)
		_oPEMEditor.oUtils.oIDEx.MoveWindow()
	Else
		Modify Command (lcFile) Nowait
	Endif
Endproc