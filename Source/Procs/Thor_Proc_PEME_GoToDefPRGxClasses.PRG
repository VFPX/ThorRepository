Lparameters lcSearchText

* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object

Local lcCode, lcName, lcText, llResult, llWithinAClass, lnEndPosition, lnGoToPosition, lnHeight, lnI
Local lnMarginHeight, lnMarginWidth, lnPos, lnSelStart, lnWidth, loEditorWin, loProc, loProcs

loEditorWin	= Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')
lnSelStart	= loEditorWin.GetSelStart()
lcCode		= loEditorWin.GetString(0, 10000000)

m.loProcs	   = _oPEMEditor.oUtils.GetProcedureStartPositions(m.lcCode)

For lnI = 1 To loProcs.Count
	loProc = loProcs[lnI]
	Do Case

		Case loProc.Type = 'Class' And loProc.StartByte <= lnSelStart
			lnGoToPosition = -1
			llWithinAClass = .T.

		Case loProc.Type = 'Class'
			Exit

		Case loProc.Type = '-End'
			lnGoToPosition = -1

		Case llWithinAClass
			If Getwordcount(loProc.Name, '.') = 2
				lcName = Getwordnum(loProc.Name, 2, '.')
				If Upper(lcSearchText) == Upper('This.' + lcName)
					lnGoToPosition = loProc.StartByte
					lcText		   = loEditorWin.GetString(lnGoToPosition, lnGoToPosition + 100)
					lnPos		   = Atc(lcName, lcText)
					lnGoToPosition = lnGoToPosition + lnPos - 1
					lnEndPosition  = lnGoToPosition + Len(lcName)
				Endif
			Endif
	Endcase
Endfor

If lnGoToPosition >= 0
	ExecScript(_Screen.cThorDispatcher, 'THOR_PROC_SelectText', lnGoToPosition, lnEndPosition, loEditorWin)
	llResult = .T.
Else
	llResult = .F.
Endif

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.llResult)

