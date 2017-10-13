*==============================================================================
* Procedure:		GoToDefinition
* Purpose:			Customized handling of GoToDefinition.  This is called if 
*                      the normal processing of Go To Definition found no matches.
* Author:			Jim Nelson
* Parameters:		
*	tcText	  		= the text being searched for
*	tcTextBefore  	= the text (on the same line) preceding the text being search for
*	tcTextAfter  	= the text (on the same line) following the text being search for
* Returns:			.T. if matches found
* Added:			12/20/2009
*
*==============================================================================
* Notes:
*	This is a sample PRG for customized uses of GoToDefinition.  It does two things:
*     [1] - If the search text is the alias of a table/cursor, or is the name of
*           a table that can be opened, that table/cursor is displayed, showing
*           the list of fields and a grid for browsing the table
*     [2] - Else, if the search text is the name of a class, that class is opened
*           (using one of the methods from _oPEMEditor.oTools
*
* Other files needed for this example (which, of course, are also customizable)
*    PEME_Table.PRG
*    PEME_LS.SC*
*    PEME_mxBrowser.VC*

Lparameters tcText, tcTextBefore, tcTextAfter

#Define CR   Chr(13)
#Define LF   Chr(10)
#Define CRLF Chr(13) + Chr(10)
#Define Tab  Chr(9)

Local lcFileName, lcNewAlias

lcFileName = tcText
Do Case
	* if the name of an open alias
	Case Used (lcFileName)
		ShowTable (lcFileName)
		Return .T.
	* if the name of one of Thor's Tools or Procs
	Case Not IsNull (ExecScript(_Screen.cThorDispatcher, 'Edit=' + lcFileName))
		Return .T.
	* well, then, maybe a table we can open
	Otherwise
		lcNewAlias = Execscript (_Screen.cThorDispatcher, 'PEME_OpenTable', lcFileName)
		If [C] = Vartype (lcNewAlias) And Used (lcNewAlias)
			ShowTable (lcNewAlias)
			Return .T.
		Else
			Return .F.
		Endif
Endcase


Procedure ShowTable (lcFileName)

	Local lcToolFolder, lnI, lnSelect, lnTop, loFP_Form, loForm

	For lnI = 1 To _Screen.FormCount
		loForm = _Screen.Forms[lnI]
		If 'fp_form' == Lower (loForm.Class)			   ;
				And Pemstatus (loForm, 'lSuperBrowse', 5)  ;
				And Lower (loForm.calias) == Lower (lcFileName)
			loForm.Show()
			loForm = .Null.
			Return
		Endif
	Endfor

	lnSelect = Select()
	Select (lcFileName)
	lcVCXFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=PEME_SNIPPET_FP.VCX')
	loFP_Form	  = Newobject ('FP_FORM', lcVCXFileName, '', lcFileName)

	With loFP_Form
		.WindowType	= 0
		.nStartPage	= 2
		lnTop		= .Top
		.Top		= -1111
		.Dockable	= 1
		.RestoreSettings ( 'PEME_Snippet_FP2.Settings')
		.SetAlias (.calias)
		If .Top = -1111
			.Top = lnTop
		Endif
		.Show()
		.SetReadonly()
	Endwith

	_Screen.AddProperty (Sys(2015), loFP_Form)
	Select (lnSelect)

	Return


Endproc