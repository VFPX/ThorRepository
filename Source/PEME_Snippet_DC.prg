****************************************************************
*	First Section: Compile-time constants -- modify as needed  *
****************************************************************

* snippet-keyword: case insensitive, NOT in quotes
#Define Snippet_Keyword 	DC

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
    Lparameters lcParam1
    Local lcNewText
    Text to lcNewText TextMerge NoShow
Define Class <<lcParam1>>

	#If .F. && Make sure this is false, otherwise error
		*-- Define This for IntelliSense use
		Local This As <<GetWordNum(lcParam1,1)>> Of Wontop()
	#Endif
    
    EndText 
    Return lcNewText
EndFunc



***************************************************************************************************
* Publish the help for this snippet: calls function CreateHelpResult with three parameters:
*    Syntax
*    Summary
*    Full description

* Note that all have these may contain HTML tags
***************************************************************************************************

Function PublishHelp
	Local lcDetailHTML, lcSummaryHTML, lcSyntax

	lcSyntax = [class-definition-text]

	Text To lcSummaryHTML Noshow
        Creates a Define Class statement so that intellisense works.
    EndText
	
	Text To lcDetailHTML Noshow
        Creates a Define Class statement so that intellisense works for the class (but not for objects added to the class).
        <br><br>
        Note that intellisense only recognizes the code from the last time the file was saved.  So, after creating new
        properties or methods, use Ctrl-S, and then intellisense will recognize them.
        <br><br>
        Example:  DC cCustom as Custom

    EndText

	Return CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
Endproc

