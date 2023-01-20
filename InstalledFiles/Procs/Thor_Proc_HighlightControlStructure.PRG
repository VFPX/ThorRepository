Lparameters llHighlightProc

*** JRN 2021-04-01 : ripped off from PEMEditor

Local lcCodeSource, llStructureLine, lnEndByte, lnI, lnIndex, lnLevel, lnLineNumber, lnSelEnd
Local lnSelStart, lnStartByte, lnStartIndex, loControlStructures, loEditorWin, loItem, loMainItem
Local loTools, loTopItem

* Get the current window, code, and start and end of selected text
loEditorWin	= Execscript (_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')
loTools		= Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')

If 0 >= m.loEditorWin.FindWindow()
	Return
Endif

With m.loEditorWin
	lnSelStart	 = .GetSelStart()
	lnSelEnd	 = .GetSelEnd()
	lcCodeSource = .GetString (0, 1000000)
	lnLineNumber = .GetLineNumber(m.lnSelStart)
Endwith

* Get the collection of control structure positions
loControlStructures = m.loTools.Outils.GetControlStructurePositions (m.lcCodeSource)

* ================================================================================
* ================================================================================
*** JRN 2021-04-01 : Find start of current procedure
For lnIndex = m.loControlStructures.Count To 1 Step - 1
	loMainItem = m.loControlStructures.Item (m.lnIndex)
	If m.loMainItem.LineNumber <= m.lnLineNumber And (m.loMainItem.ProcedureBoundary Or m.llHighlightProc = .F.)
		Exit
	Endif
Endfor

* Find the starting item for the current control structure
Do Case

		* Procedure, Function, Define class
	Case m.loMainItem.ProcedureBoundary
		lnLevel = 0

		* If, Scan, Do Case, etc.  ... on same line
	Case m.loMainItem.StartStructure And m.loMainItem.LineNumber = m.lnLineNumber
		lnLevel			= 0
		llStructureLine	= .T.
		* following allows for repeated applications ... each time, finding next largest control structure
		If m.lnSelStart # m.lnSelEnd And m.lnSelStart = m.loEditorWin.GetByteOffset(m.loMainItem.LineNumber)
			lnLevel = -1
		Endif

		* Line following If, Scan, Do Case, etc.
	Case m.loMainItem.StartStructure
		lnLevel			= 0
		llStructureLine	= .F.

		* Endif, EndScan, EndCase, etc ... on same line
	Case m.loMainItem.EndStructure And m.loMainItem.LineNumber = m.lnLineNumber
		lnLevel			= 1
		llStructureLine	= .T.

		* Line following Endif, EndScan, EndCase, etc
	Case m.loMainItem.EndStructure
		lnLevel			= 0
		llStructureLine	= .F.

		* Else, Catch, Case, Otherwise ... on same line
	Case m.loMainItem.LineNumber = m.lnLineNumber
		lnLevel			= 0
		llStructureLine	= .T.

		* Line following Else, Catch, Case, Otherwise
	Otherwise
		lnLevel			= 0
		llStructureLine	= .F.

Endcase

For lnI = m.lnIndex To 1 Step - 1
	loItem = m.loControlStructures.Item (m.lnI)
	Do Case
		Case m.loItem.ProcedureBoundary
			lnStartIndex = m.lnI
			Exit
		Case m.loItem.StartStructure
			lnLevel = m.lnLevel + 1
			If m.lnLevel > 0
				lnStartIndex = m.lnI
				Exit
			Endif
		Case m.loItem.EndStructure
			lnLevel = m.lnLevel - 1
	Endcase
Endfor

* Find the ending item for the current control structure
loTopItem	= m.loControlStructures.Item (m.lnStartIndex)
If m.lnStartIndex > 1
	lnStartByte	= m.loEditorWin.GetByteOffset(m.loTopItem.LineNumber)
Else
	lnStartByte	= 0
Endif

If m.loTopItem.ProcedureBoundary
	lnLevel		 = 1
	lnStartIndex = m.lnStartIndex + 1
Else
	lnLevel = 0
Endif

lnEndByte	= Len (m.lcCodeSource)

For lnI = m.lnStartIndex To m.loControlStructures.Count
	loItem = m.loControlStructures.Item (m.lnI)
	Do Case
		Case m.loItem.ProcedureBoundary and lnStartByte > 0
			lnEndByte = m.loEditorWin.GetByteOffset(m.loItem.LineNumber + 1)
			Exit
		Case m.loItem.ProcedureBoundary
			lnEndByte = m.loEditorWin.GetByteOffset(m.loItem.LineNumber)
			Exit
		Case m.loItem.StartStructure
			lnLevel = m.lnLevel + 1
		Case m.loItem.EndStructure
			lnLevel = m.lnLevel - 1
			If m.lnLevel <= 0
				lnEndByte = m.loEditorWin.GetByteOffset(m.loItem.LineNumber + 1)
				Exit
			Endif
	Endcase
Endfor

* finis!

m.loEditorWin.Select (m.lnStartByte, m.lnEndByte)


