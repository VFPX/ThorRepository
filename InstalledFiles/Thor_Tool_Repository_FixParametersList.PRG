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
		.AppID 		   = 'ThorRepository'

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

	Local lcAllComments, lcChar, lcComments, lcIndent, lcRemainingText, lcReplaceText, lcText
	Local lcReplacementText, lnI, lnLineWidth, lnPos, loHighlightedText

	loHighlightedText = Execscript(_Screen.cThorDispatcher, 'class= HighlightedText from Thor_Proc_HighlightedText.PRG', 'Statement')
	If Not Empty(m.loHighlightedText.cError)
		Messagebox(m.loHighlightedText.cError, 16, 'Error', 0)
		Return
	Endif

	lcText	= m.loHighlightedText.cHighLightedText

	* Save indentation for first line
	lcIndent = ''
	For lnI = 1 To Len(m.lcText)
		lcChar = Substr(m.lcText, m.lnI, 1)
		If m.lcChar = ' ' Or m.lcChar = Tab
			lcIndent = m.lcIndent + m.lcChar
		Else
			Exit
		Endif
	Endfor

	* special characters to spaces
	lcText = Ltrim(Chrtran(m.lcText, CR + LF + Tab + ';', '   '))

	* space after commas
	lcText = Strtran(m.lcText, ',', ', ')

	* remove comments on end of any line
	lcAllComments = ''

	Do While DoubleAmps $ m.lcText
		lcComments	  = Strextract(m.lcText, DoubleAmps, CR, 1, 2)
		lcAllComments = m.lcAllComments + '*  ' + m.lcComments + CR
		lcText		  = Strtran(m.lcText, DoubleAmps + m.lcComments, '', 1, 1)
	Enddo

	* remove multiple spaces
	For lnI = 1 To 5
		lcText = Strtran(m.lcText, '  ', ' ')
	Endfor

	* spaces before and after commas and parens
	lcText = Strtran(m.lcText, ' ,', ',')
	For lnI = 1 To 5
		lcText = Strtran(m.lcText, ',,', ', ,')
	Endfor
	*!* ******** JRN Removed 2023-05-23 ********
	*!* lcText = Strtran(m.lcText, ', ', ',')

	lcText = Strtran(m.lcText, '( ', '(')
	lcText = Strtran(m.lcText, ' (', '(')
	lcText = Strtran(m.lcText, ') ', ')')
	lcText = Strtran(m.lcText, ' )', ')')

	lcReplacementText = ''
	lcRemainingText	  = m.lcIndent + m.lcText
	lnLineWidth		  = 80

	Do While Len(m.lcRemainingText) > m.lnLineWidth And ', ' $ m.lcRemainingText
		lnPos = Rat(', ', Left(m.lcRemainingText, m.lnLineWidth))
		lnPos = Evl(m.lnPos, At(', ', m.lcRemainingText))
		lcReplacementText = m.lcReplacementText + Left(m.lcRemainingText, m.lnPos + 1)		;
			+ ';' + CR + LF + m.lcIndent + Tab
		lcRemainingText = Substr(m.lcRemainingText, m.lnPos + 2)
	Enddo

	lcReplaceText = lcReplacementText + m.lcRemainingText + CR + m.lcAllComments

	m.loHighlightedText.PasteText(m.lcReplaceText)

Endproc
