****************************************************************
****************************************************************
******
****** First Section: Compile-time constants -- modify as needed
******
****************************************************************
****************************************************************

* snippet-keyword: case insensitive, NOT in quotes
#Define Snippet_Keyword 	LG

* delimiter between parameters, IN QUOTES; if empty, only one parameter
#Define Delimiter_Char	 	','

* minimum number of parameters to be accepted
#Define Min_Parameters      1

* maximum number of parameters to be accepted
#Define Max_Parameters      1




****************************************************************
****************************************************************
******
****** Middle Section: Setup and cleanup code:  DO NOT CHANGE!!!
******
****************************************************************
****************************************************************

Lparameters lcParameters, lcKeyWord

Local loParams As Collection
Local lcParams, lnI, lxResult

lxResult = .F.
Do Case
		* if no parameters passed, this is a request for Help
	Case Pcount() = 0
		lxResult = PublishHelp()

		* Only process our keyword 
	Case Pcount() = 2 And Not Upper ([Snippet_Keyword]) == lcKeyWord
		lxResult = .F. && not mine!

	Otherwise
		lcParams = _oPEMEditor.ExtractSnippetParameters (lcParameters, Delimiter_Char, [Snippet_Keyword], Min_Parameters, Max_Parameters)
		If 'C' = Vartype (lcParams)
			lxResult = Process (&lcParams)
		Endif
Endcase

Execscript (_Screen.cThorDispatcher, 'Result=', lxResult)
Return lxResult



Function CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
	Local loResult As 'Empty'
	loResult = Createobject ('Empty')
	AddProperty (loResult, 'Name', [Snippet_Keyword])
	AddProperty (loResult, 'Syntax', Evl (lcSyntax, ''))
	AddProperty (loResult, 'Summary', Evl (lcSummaryHTML, ''))
	AddProperty (loResult, 'Detail', Evl (lcDetailHTML, ''))
	Return loResult
Endproc

****************************************************************
****************************************************************
******
****** Last Section: Custom code for this snippet
******
****************************************************************
****************************************************************

#Define CR   Chr(13)
#Define LF   Chr(10)
#Define CRLF Chr(13) + Chr(10)
#Define Tab  Chr(9)

* Put your code here to process the parameters passed; make sure to set parameters appropriately
* Result is one of following:
*   character string -- string to insert into edit window, replacing the snippet there (usual case, by far)
*                       if the characters '^^^' are found, they indicate where the cursor is to be placed
*   .T.              -- handled, but edit window already updated (advanced use)
*   .F.              -- not handled

Function Process
	Lparameters lcFileName

	Local laFields[1], lcFieldName, lcFormFileName, lcHTMLHeader, lcNewAlias, lcOpenFilePRG, lcResult
	Local lcText, lcThisPRG, lcType, lnDecimals, lnFieldCount, lnI, lnWidth

	If Not Used (lcFileName)
		lcNewAlias = Execscript (_Screen.cThorDispatcher, 'PEME_OpenTable', lcFileName)
		If [C] = Vartype (lcNewAlias)
			lcFileName = lcNewAlias
		Endif
		If Not Used (lcFileName)
			Return .T. && mine, nothing to change
		Endif
	Endif

	lcHTMLHeader = _oPEMEditor.oUtils.oIDEx.GetHTMLHeader()
	*** JRN 2010-10-28 : away we go
	lnFieldCount = Afields (laFields, lcFileName)
	Text To lcResult Noshow
</head>
<body>
<table border="1">
	<tr>       
		<th>Field</th>
		<th>Type</th>      
		<th>Width</th>      
		<th>Decimals</th>      
	</tr>
	Endtext

	For lnI = 1 To lnFieldCount
		lcFieldName	= laFields[lnI, 1]
		lcType		= laFields[lnI, 2]
		lnWidth		= laFields[lnI, 3]
		lnDecimals	= laFields[lnI, 4]

		lcText = [<tr>]
		lcText = lcText + [<td >] + lcFieldName + [&nbsp;&nbsp;</td>] + CRLF
		lcText = lcText + '<td>' + lcType + [</td>] + CRLF
		lcText = lcText + [<td>] + Transform (lnWidth) + [</td>] + CRLF
		If lnDecimals > 0
			lcText		= lcText + [<td>] + Transform (lnDecimals) + [</td>] + CRLF
		Else
			lcText		= lcText + [<td>&nbsp;</td>] + CRLF
		Endif
		lcText	 = lcText + [</tr>]
		lcResult = lcResult + lcText + CRLF
	Endfor

	lcResult = lcResult + [</table>] + CRLF
	lcResult = lcResult + [</body>] + CRLF

	lcFormFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=PEME_Snippet_LG.SCX')
	Do Form (lcFormFileName) With lcFileName, lcHTMLHeader + lcResult, 800, 600

	Return '' && Handled it .. replace PMD with blank
Endproc


****************************************************************

* Publish the help for this snippet: calls function CreateHelpResult with three parameters:
*    Syntax
*    Summary
*    Full description

* Note that all have these may contain HTML tags

Function PublishHelp
	Local lcDetailHTML, lcSummaryHTML, lcSyntax

	lcSyntax = 'Alias'

	Text To lcSummaryHTML Noshow Textmerge
		Shows the data structure for <u>Alias</u> and also a grid for browsing.
	Endtext

	Text To lcDetailHTML Noshow Textmerge
		Opens a form showing the data structure of a table and a grid for browsing it.
		 <br><br>
		If the table is not open, PEME_OpenTable.PRG is called to allow you to open the table; make modifications
		to it as desired to fit your own needs.
	Endtext

	Return CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
Endproc


