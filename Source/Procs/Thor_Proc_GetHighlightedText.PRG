Lparameters tcNameType

* tcNameType indicates what type of text to return
*   Empty    = Simply the current highlighted text
*   'Word'   = Includes characters before/after highlighted text that can be part of a variable name
*   'File Name' = Includes characters before/after that can be part of a file name (:\.)
*   'Object Name' = Includes characters before/after that can be part of an
*                   object name. Processes prior WITH statements if name begins with .

* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
Local lcChar, lcName, lcResult, lnFileSize, lnPosition, lnSelEnd, lnSelStart, loTools
loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

If 0 > loEditorWin.FindWindow()
	Return Execscript(_Screen.cThorDispatcher, 'Result=', '')
Endif

lnSelStart = loEditorWin.GetSelStart()
lnSelEnd   = loEditorWin.GetSelEnd()

If lnSelStart # lnSelEnd
	lcResult = loEditorWin.GetString(lnSelStart, lnSelEnd - 1)
Else
	lcResult = ''
Endif

Do Case
	Case Empty(tcNameType)

	Case Proper(tcNameType) = 'Object Name' and Empty(lcResult)
		* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
		loTools	 = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')
		lcResult = m.loTools.oUtils.oIDEx.GetCurrentHighlightedText(.T.)

	Otherwise

		*** JRN 2010-04-02 : add in preceding characters
		For lnPosition = lnSelStart - 1 To 0 Step - 1
			lcChar = loEditorWin.GetCharacter(lnPosition)
			If IsNameChar(lcChar, tcNameType)
				lcResult = lcChar + lcResult
			Else
				Exit
			Endif
		Endfor

		*** JRN 10/30/2012 : and following characters
		lnFileSize = loEditorWin.GetFileSize()
		For lnPosition = lnSelEnd To lnFileSize Step 1
			lcChar = loEditorWin.GetCharacter(lnPosition)
			If IsNameChar(lcChar, tcNameType)
				lcResult = lcResult + lcChar
			Else
				Exit
			Endif
		Endfor

Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result=', lcResult)



Procedure IsNameChar(tcChar, tcNameType)

	Do Case
		Case Proper(tcNameType) == 'Word'
			Return Isalpha(tcChar) Or Isdigit(tcChar) Or tcChar $ '_'
		Case Proper(tcNameType) == 'File Name'
			Return Isalpha(tcChar) Or Isdigit(tcChar) Or tcChar $ '_:\.'
		Otherwise
			Return .F.
	Endcase

Endproc

