Lparameters lnStartPosition, lnEndPosition, loEditorWin

* selects text given by parameters
* and moves the selected line near the top of the window
Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
Local lnHeight, lnMarginHeight, lnMarginWidth, lnWidth

If 'O' # Vartype(loEditorWin)
	* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

Endif

If Vartype(lnStartPosition) # 'N'
	lnStartPosition	= loEditorWin.GetSelStart()
	lnEndPosition	= loEditorWin.GetSelEnd()
Endif

* get window dimensions
lnWidth	 = loEditorWin.GetWidth()
lnHeight = loEditorWin.GetHeight()

* but we must provide for the margins, else the window shrinks!
loEditorWin.ResizeWindow(lnWidth, lnHeight)
lnMarginWidth  = lnWidth - loEditorWin.GetWidth()
lnMarginHeight = lnHeight - loEditorWin.GetHeight()

* shrink the window vertically so that the selected line is in a tiny window
loEditorWin.ResizeWindow(lnWidth, lnMarginHeight + 10)

loEditorWin.SetInsertionPoint(loEditorWin.GetLineStart(lnStartPosition, 1))

loEditorWin.SetInsertionPoint(lnStartPosition)
loEditorWin.Select(lnStartPosition, lnEndPosition)

* and resize back to the original, but selected line at (or near) top
loEditorWin.ResizeWindow(lnWidth + lnMarginWidth, lnHeight + lnMarginHeight)
