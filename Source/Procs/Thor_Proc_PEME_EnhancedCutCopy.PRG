*** JRN 2010-04-02 : From Sergey
Lparameters lcCutOrCopy, llAdditive

Local lcCliptext, lnCurrentLineStart, lnFollowingLineStart, lnSelEnd, lnSelStart, loEditorWin

* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
loEditorWin = Execscript (_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

If 0 > loEditorWin.FindWindow()
	Return
Endif

lnSelStart = loEditorWin.GetSelStart()
lnSelEnd   = loEditorWin.GetSelEnd()

If lnSelStart = lnSelEnd
	* find the start of the current line
	lnCurrentLineStart = loEditorWin.SkipLine (lnSelStart, 0)
	* and of the following line
	lnFollowingLineStart = loEditorWin.SkipLine (lnSelStart, 1)
	* Mark the desired text
	loEditorWin.Select (lnCurrentLineStart, lnFollowingLineStart)
Endif

lcCliptext = _Cliptext
Do Case
	Case lcCutOrCopy = 'Cut'
		loEditorWin.Cut()
		If Empty(_Cliptext)
			_Cliptext = lcCliptext
			Return
		Endif
	Case lcCutOrCopy = 'Copy'
		loEditorWin.Copy()
		loEditorWin.Select (lnSelStart, lnSelEnd)
Endcase

If llAdditive
	_Cliptext = lcCliptext + _Cliptext
Endif
