#Define CR   Chr(13)
#Define LF   Chr(10)
#Define CRLF Chr(13) + Chr(10)
#Define Tab  Chr(9)

Lparameters tcFileName

Local lcClipText, lcFileName, lcFormFileName, lcFullFileName, lcFullFilePath, lcPrivateFile
Local lcResponse, lcToolFolder, lnMsgBoxAns, loEditorWin, loTools

lcFullFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=' + m.tcFileName)

*** JRN 2023-08-10 : Use context menu for Thor tools
Do Case
	Case Empty(m.lcFullFileName)
		Return
	Case Atc('thor_tool_', m.tcFileName) # 0
		Execscript (_Screen.cThorDispatcher, 'thor_proc_toolcontextmenu', m.tcFileName)
		Return 
Endcase

lcFullFilePath = Upper (Addbs (Justpath (m.lcFullFileName)))
lcToolFolder   = Execscript (_Screen.cThorDispatcher, 'Tool Folder=')

* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
loTools = Execscript (_Screen.cThorDispatcher, 'Class= tools from pemeditor')

Do Case
	Case Empty (m.lcFullFileName)
		lcFileName = Forceext (m.tcFileName, 'PRG')
		lnMsgBoxAns = Messagebox ('Create "' + m.lcFileName + '" in folder "My Tools"?', 292	;
			  , 'File "' + m.lcFileName + '" not found')
		Do Case
			Case m.lnMsgBoxAns = 6
				lcPrivateFile = Forcepath (m.lcFileName, m.lcToolFolder + 'My Tools\')
				m.loTools.EditSourceX (m.lcPrivateFile)
			Case m.lnMsgBoxAns = 7
		Endcase

	Case m.lcFullFilePath == Upper (m.lcToolFolder) Or m.lcFullFilePath == Upper (m.lcToolFolder + 'Procs\')
		lcFormFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_Proc_EditProc.SCX')
		Do Form (m.lcFormFileName) With m.lcFullFileName To m.lcResponse
		Do Case
			Case m.lcResponse = 'Read Only'
				Modify Command (m.lcFullFileName) Nowait Noedit

			Case m.lcResponse = 'My Tools'
				lcPrivateFile = Forcepath (m.lcFullFileName, m.lcToolFolder + 'My Tools\')
				m.loTools.EditSourceX (m.lcPrivateFile)

				lcClipText = Filetostr (m.lcFullFileName)
				* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
				loEditorWin = Execscript (_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')
				m.loEditorWin.Paste (m.lcClipText)
				m.loEditorWin.SetInsertionPoint(0)
			Case m.lcResponse = 'Tools'
				EditFile (m.lcFullFileName)
		Endcase
	Otherwise
		EditFile (m.lcFullFileName)
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