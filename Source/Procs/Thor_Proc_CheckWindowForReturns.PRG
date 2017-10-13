Lparameters lnOptionLevel

* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
Local lcText, llHighlighted, loForm, loMatches
Private lnValue
loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

If loEditorWin.GetEnvironment(25) <= 0
	Return
Endif

lcText		  = m.loEditorWin.GetString(0, 10000000)
loMatches	  = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_CheckCodeBlockForBadReturns', lcText)
llHighlighted = .F.

Do Case
	Case loMatches.Count = 0
		If Evl(lnOptionLevel, 1) = 1
			Messagebox('None found', 64, 'Returns -- With/Endwith & Try/Catch')
		Endif

	Case loMatches.Count = 1 And Evl(lnOptionLevel, 1) = 3
		HighlightLine(m.loEditorWin, loMatches.Item[1])
		llHighlighted = .T.

	Otherwise
		loForm	= Execscript(_Screen.cThorDispatcher, 'Class= DynamicFormDeskTop')
		lnValue	= 1

		With loForm
			.Caption	 = 'Returns -- With/Endwith & Try/Catch'
			.MinWidth	 = 275
			.MinHeight	 = 100
			.MinButton	 = .F.
			.MaxButton	 = .F.
			.BorderStyle = 2

			.cHeading			= Transform(loMatches.Count) + ' match' + Iif(loMatches.Count > 1, 'es', '') + ' found'
			.cSaveButtonCaption	= 'Show me'
		Endwith


		Text To loForm.cBodyMarkup Noshow Textmerge
	lnValue 	.class 				= 'Spinner'
				.caption			= 'Select match to highlight:'
				.width				= 60
				.KeyboardLowValue 	= 1
				.KeyboardHighValue 	= <<loMatches.Count>>
				.SpinnerLowValue 	= 1
				.SpinnerHighValue 	= <<loMatches.Count>>
				.Increment			= 1			
				.margin-left		= 60
		Endtext

		loForm.Render()
		loForm.AlignToEditWindow(loEditorWin)		
		loForm.Show(1, .T.)

		If 'O' = Vartype(loForm) And loForm.lSaveClicked
			HighlightLine(m.loEditorWin, loMatches.Item[lnValue])
			llHighlighted = .T.
		Endif
Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result= ', llHighlighted)
Endproc


Procedure HighlightLine(toEditorWin, tnLine)
	Local lnEndByte, lnStartByte

	lnStartByte	= m.toEditorWin.GetByteOffset(m.tnLine - 1)
	lnEndByte	= m.toEditorWin.GetByteOffset(m.tnLine)
	m.toEditorWin.Select(m.lnStartByte, m.lnEndByte)
	m.toEditorWin.EnsureVisible(m.lnStartByte, .T.)

Endproc


