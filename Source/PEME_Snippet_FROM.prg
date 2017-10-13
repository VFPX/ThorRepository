****************************************************************
*	First Section: Compile-time constants -- modify as needed  *
****************************************************************

* snippet-keyword: case insensitive, NOT in quotes
#Define Snippet_Keyword 	From

* delimiter between parameters, IN QUOTES; if empty, only one parameter
#Define Delimiter_Char	 	''

* minimum number of parameters to be accepted
#Define Min_Parameters      1

* maximum number of parameters to be accepted
#Define Max_Parameters      1




*****************************************************************
*	 Middle Section: Setup and cleanup code:  DO NOT CHANGE!!!  *
*****************************************************************

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




*****************************************************************
****** Last Section: Custom code for this snippet				*
*****************************************************************

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
	Lparameters lcParameters
	Local laLines[1], laWords[1], lcDest, lcField, lcResult, lcSourceFile, lnCount, lnI
	If Empty (lcParameters)
		Return .T. && Nothing to do
	Endif

	lnCount		 = Alines (laLines, lcParameters, .T., ',')
	lcSourceFile = Alltrim (laLines(1))

	lcResult = 'From ' + lcSourceFile
	For lnI = 2 To lnCount
		If 2 = Alines (laWords, laLines (lnI), .T., '=')
			lcField	= Alltrim (laWords(1))
			If Not '.' $ lcField
				lcField = lcSourceFile + '.' + lcField
			Endif

			lcDest	= Alltrim (laWords(2))
			If Not '.' $ lcDest
				lcDest = lcDest + '.' + Justext (lcField)
			Endif

			lcResult = lcResult + ';' + CRLF + Tab		;
				+ 'Join ' + Juststem (lcDest) + ' on ' + lcField + ' = ' + lcDest
		Endif
	Endfor

	Return lcResult

Endproc



***************************************************************************************************
* Publish the help for this snippet: calls function CreateHelpResult with three parameters:
*    Syntax
*    Summary
*    Full description

* Note that all have these may contain HTML tags
***************************************************************************************************

Function PublishHelp
	Local lcDetailHTML, lcSummaryHTML, lcSyntax

	lcSyntax = 'FromFile, Key1 = OtherFile.Key2, ... '

	Text To lcSummaryHTML Noshow Textmerge
		Creates ... FROM FromFile JOIN OtherFile on ... 
	Endtext

	Text To lcDetailHTML Noshow Textmerge
		Create a FROM and JOIN clauses used in a SELECT statement.  As many JOIN clauses as
		desired may be entered, separated by commas.  The syntax for each is:<pre>     [FileX.]Field1 = File2.[Field2]</pre>
		For clarity, you may choose to list both of the optional items.<br>
		For brevity, you may choose to skip FileX if it is the same as FromFile, and you may
		choose to skip Field2 if it is the same as Field1.
		
		<table>
			<tr> <th> Sample </th> <th> Becomes</th> </tr>
			<tr> <td> Field1 = OtherFile </td> <td> FromFile.Field1 = OtherFile.Field1</td> </tr>
			<tr> <td> Field1 = OtherFile.Field2 </td> <td> FromFile.Field1 = OtherFile.Field2</td> </tr>
			<tr> <td> ThirdFile.Field1 = OtherFile </td> <td> ThirdFile.Field1 = OtherFile.Field1</td> </tr>
			<tr> <td> ThirdFile.Field1 = OtherFile.Field2 </td> <td> ThirdFile.Field1 = OtherFile.Field2</td> </tr>
		</table>
	Endtext

	Return CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
Endproc
