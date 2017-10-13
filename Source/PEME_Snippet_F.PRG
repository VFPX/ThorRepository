****************************************************************
****************************************************************
******
****** First Section: Compile-time constants -- modify as needed
******
****************************************************************
****************************************************************

* snippet-keyword: case insensitive, NOT in quotes
#Define Snippet_Keyword 	F

* delimiter between parameters, IN QUOTES; if empty, only one parameter
#Define Delimiter_Char	 	'='

* minimum number of parameters to be accepted
#Define Min_Parameters      1

* maximum number of parameters to be accepted
#Define Max_Parameters      2




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
		lcParams = _oPEMEditor.ExtractSnippetParameters(lcParameters, Delimiter_Char, [Snippet_Keyword], Min_Parameters, Max_Parameters)
		If 'C' = VarType (lcParams)
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
	Lparameters lcAlias, lcPrefix
	Local laFields[1], lcFieldName, lcOpenFilePRG, lcResult, lcThisPRG, lcType, lnDecimals, lnFieldCount
	Local lnI, lnWidth

	Do Case
		Case Pcount() = 1
			lcPrefix = lcAlias + '.'
		Case Not Empty (lcPrefix)
			lcPrefix = lcPrefix + '.'
	Endcase

	If Not Used (lcAlias)
		lcNewAlias = ExecScript(_Screen.cThorDispatcher, 'PEME_OpenTable', lcAlias)
		If [C] = Vartype (lcNewAlias)
			lcAlias = lcNewAlias
		Endif
		If Not Used (lcAlias)
			Return .T. && mine, nothing to change
		Endif
	Endif

	*** JRN 2010-10-28 : away we go
	lnFieldCount = Afields (laFields, lcAlias)
	lcResult	 = []
	For lnI = 1 To lnFieldCount
		lcFieldName	= laFields[lnI, 1]
		lcType		= laFields[lnI, 2]
		lnWidth		= laFields[lnI, 3]
		lnDecimals	= laFields[lnI, 4]
		lcResult	= lcResult						;
			+ IIf (Empty (lcResult), [], Tab)		;
			+ lcPrefix + lcFieldName				;
			+ IIf (lnI < lnFieldCount, [, ;] + CRLF, [])
	Endfor
	Return lcResult
Endproc


****************************************************************

* Publish the help for this snippet: calls function CreateHelpResult with three parameters:
*    Syntax
*    Summary
*    Full description

* Note that all have these may contain HTML tags

Function PublishHelp
	Local lcDetailHTML, lcSummaryHTML, lcSyntax

	lcSyntax = 'Alias[=Prefix]'

	Text To lcSummaryHTML Noshow Textmerge
		Creates a list of all fields from <u>Alias</u> (for SQL-SELECT)
	Endtext

	Text To lcDetailHTML Noshow Textmerge
		Inserts the list of all fields from <u>Alias</u> (an open cursor or table in DataSession 1), 
		one per line, as used by SQL-SELECT.  Field names look like Alias.Fld1, Alias.Fld2, etc.   <br><br>
		To use a different prefix for the field names, use the equal sign and the prefix (Alias=OtherPrefix) <br><br>
		To not have any prefix for the field names, use just the equal sign (Alias=) <br><br>
		If the table is not open, PEME_OpenTable.PRG is called to allow you to open the table; make modifications
		to it as desired to fit your own needs.
	Endtext

	Return CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
Endproc


