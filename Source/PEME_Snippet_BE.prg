****************************************************************
*	First Section: Compile-time constants -- modify as needed  *
****************************************************************
*
* Author: Tore Bleken, January 2013
*
* snippet-keyword: case insensitive, NOT in quotes
#Define Snippet_Keyword 	BE

* delimiter between parameters, IN QUOTES; if empty, only one parameter
#Define Delimiter_Char	 	','

* minimum number of parameters to be accepted
#Define Min_Parameters      2    

* maximum number of parameters to be accepted
#Define Max_Parameters      2    




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


Procedure InThisFolder (tcFileName)
	Local lcSys16, lnI
	For lnI = Program (-1) To 1 Step - 1
		lcSys16 = Sys(16, lnI)
		If Not Upper (Getwordnum (lcSys16, 1)) == 'PROCEDURE'
			Return Forcepath (tcFileName, JustPath(lcSys16))
			Exit
		Endif
	Endfor

	Return tcFileName
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
    Lparameters lcParam1, lcParam2
    Local lcNewText
    lcNewText = 'Bindevent(' + Juststem(lcParam1) + ',"' + Justext(lcParam1) + '",';
       + Juststem(lcParam2) + ',"' + Justext(lcParam2) +'")'
    
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

	lcSyntax = [object1.event1,object2.event2]

	Text To lcSummaryHTML Noshow
        <b> <font color="red">BE object1.event1, object2.event2</font></b> lets you easily create Bindevent() syntax together with Intellisense
    EndText
	
	Text To lcDetailHTML Noshow
        <b> <font color="red">BE object1.event1 object2.event2</font></b> creates the correct Bindevent() syntax by specifying the source and delegate object.method as given by Intellisense<br />
        <br />
        Sample:<br /><br />
        <font color = "blue">BE this.cntmonth1.cbomonths1.InteractiveChange , this.cntshowmonthyear1.SetValues +</font> <font color="red">F5</font> creates this:<br />
        <font color = "blue">Bindevent(this.cntmonth1.cbomonths1,"InteractiveChange",this.cntshowmonthyear1,"InteractiveChange")</font><br /><br />
        (In this case F5 is defined as hot key for Dynamic Snippets)
        
    EndText

	Return CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
Endproc

