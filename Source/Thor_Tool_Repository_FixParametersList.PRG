Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'Compress Parameters List' && used in menus

		Text To .Description Noshow
Compress the list of parameters by removing white space.

This is done to avoid buffer overrun errors that occur when the parameters line is too long (about 250 characters, although the exact value has not been determined.)

Highlight the entire parameters list first.
		Endtext
		.Category = 'Code|Highlighted text'
		.Author	  = 'JRN'
		.Sort	  = 15
	Endwith

	Return m.lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With m.lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
#Define 	Tab Chr[9]
#Define 	CR 	Chr[13]
#Define 	LF 	Chr[10]
#Define 	DoubleAmps ('&' + '&')

Procedure ToolCode
	Lparameters lxParam1

	Local lcAllComments, lcComments, lcReplaceText, lcText, lnI, loHighlightedText

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG')
	If Not Empty(m.loHighlightedText.cError)
		Messagebox(m.loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	lcText	= m.loHighlightedText.cHighLightedText

	* tabs to spaces
	lcText	= Chrtran(m.lcText, Tab, ' ')

	* remove comments on end of any line
	lcAllComments = ''

	Do While DoubleAmps $ m.lcText
		lcComments	  = Strextract(m.lcText, DoubleAmps, CR, 1, 2)
		lcAllComments = m.lcAllComments + '*  ' + m.lcComments + CR
		lcText		  = Strtran(m.lcText, DoubleAmps + m.lcComments, '', 1, 1)
	Enddo

	* remove multiple spaces
	lcText = Chrtran(m.lcText, CR + LF + ';', '   ')
	For lnI = 1 To 5
		lcText = Strtran(m.lcText, '  ', ' ')
	Endfor

	* spaces before and after commas and parens
	lcText = Strtran(m.lcText, ' ,', ',')
	lcText = Strtran(m.lcText, ', ', ',')

	lcText = Strtran(m.lcText, '( ', '(')
	lcText = Strtran(m.lcText, ' (', '(')
	lcText = Strtran(m.lcText, ') ', ')')
	lcText = Strtran(m.lcText, ' )', ')')

	lcReplaceText = m.lcText + CR + m.lcAllComments

	m.loHighlightedText.PasteText(m.lcReplaceText)

Endproc
