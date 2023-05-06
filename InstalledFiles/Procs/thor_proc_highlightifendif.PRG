Local lcClipText, lnAfter, lnBefore, lnOrigSelEnd, lnOrigSelStart, loEditorWin

Execscript (_Screen.cThorDispatcher, 'PEMEditor_StartIDETools')

loEditorWin	   = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')
lnOrigSelStart = m.loEditorWin.GetSelStart()
lnOrigSelEnd   = m.loEditorWin.GetSelEnd()

Do While .T.
	lnBefore =	m.loEditorWin.GetSelStart()
	_oPEMEditor.oUtils.oIDEx.HighlightControlStructure()
	lnAfter =	m.loEditorWin.GetSelStart()

	If m.lnBefore = m.lnAfter
		m.loEditorWin.Select(m.lnOrigSelStart, m.lnOrigSelEnd)
		Return Execscript(_Screen.cThorDispatcher, 'Result= ', .F.)
	Endif

	lcClipText = m.loEditorWin.GetString (m.loEditorWin.GetSelStart(), m.loEditorWin.GetSelEnd())

	If Upper(Getwordnum(m.lcClipText, 1)) == 'IF'
		Return Execscript(_Screen.cThorDispatcher, 'Result= ', .T.)
	Endif
Enddo

