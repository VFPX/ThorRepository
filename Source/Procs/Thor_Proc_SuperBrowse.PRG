Lparameters tcAlias

Local llSuccess, lnSelect

llSuccess = .F.
Do Case
	Case Empty(m.tcAlias)
		If Used(Alias())
			SuperBrowse(Alias())
			llSuccess = .T.
		Endif

	Case Used(m.tcAlias)

		lnSelect = Select()
		Select(m.tcAlias)

		SuperBrowse(m.tcAlias)
		Select(m.lnSelect)
		llSuccess = .T.

Endcase

If Not m.llSuccess
	Messagebox('Alias not found', 16, 'Alias not found')
Endif
Return



*****************************************************

Procedure SuperBrowse(tcAlias)

	Local lcVCXFileName, llDockable, lnI, lnLeft, lnTop, loFP_Form, loForm

	For lnI = 1 To _Screen.FormCount
		loForm = _Screen.Forms[m.lnI]
		If 'fp_form' == Lower(m.loForm.Class)					;
				And Pemstatus(m.loForm, 'lSuperBrowse', 5)		;
				And Lower(m.loForm.cAlias) == Lower(m.tcAlias)
			m.loForm.Show()
			loForm = .Null.
			Return
		Endif
	Endfor

	lcVCXFileName = Execscript(_Screen.cThorDispatcher, 'Full Path=PEME_SNIPPET_FP.VCX')
	loFP_Form	  = Newobject('FP_FORM', m.lcVCXFileName, '', m.tcAlias)

	llDockable = Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Dockable', 'Super Browse')

	With m.loFP_Form
		.WindowType	= 0
		.nStartPage	= 2
		.RestoreSettings( 'PEME_Snippet_FP2.Settings', 'nDockable')

		.SetAlias(.cAlias)

		Do Case
			Case Not m.llDockable

			Case .nDockable = 2
				.Dockable = 2

			Otherwise
				lnTop	  = .Top
				lnLeft	  = .Left
				.Dockable = 1
				.Top	  = m.lnTop
				.Left	  = m.lnLeft
		Endcase

		.Show()
		.Width = .Width + 1
		.Width = .Width - 1
		.SetReadonly()
	Endwith

	_Screen.AddProperty(Sys(2015), m.loFP_Form)

	Return


