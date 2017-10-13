****************************************************************
****************************************************************
******
****** First Section: Compile-time constants -- modify as needed
******
****************************************************************
****************************************************************

* snippet-keyword: case insensitive, NOT in quotes
#Define Snippet_Keyword 	UC

* delimiter between parameters, IN QUOTES; if empty, only one parameter
#Define Delimiter_Char	 	'='

* minimum number of parameters to be accepted
#Define Min_Parameters      2

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
	Lparameters lcText1, lcText2
	Local lcResult

	lcResult = 'Upper(' + lcText1 + ') = Upper(' + lcText2 + ')'
	
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

	lcSyntax = 'Text1 = Text2'

	Text To lcSummaryHTML Noshow Textmerge
		Creates an uppercase comparison of Text1 with Text2.
	Endtext

	* No detail necessary!

	Return CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
Endproc


