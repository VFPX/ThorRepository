* Tore Bleken 28-9-2011

****************************************************************
****************************************************************
******
****** First Section: Compile-time constants -- modify as needed
******
****************************************************************
****************************************************************

* snippet-keyword: case insensitive, NOT in quotes
#Define Snippet_Keyword      FP

* delimiter between parameters, IN QUOTES; if empty, only one parameter
#Define Delimiter_Char       ' '

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
		lcParams = _oPEMEditor.ExtractSnippetParameters (lcParameters, Delimiter_Char, [Snippet_Keyword], Min_Parameters, Max_Parameters)
		If 'C' = Vartype (lcParams)
			lxResult = Process (&lcParams)
		Endif
Endcase

Execscript (_Screen.cThorDispatcher, 'Result=', lxResult)
Return lxResult


 Function CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
	Local loResult As [Empty]
	loResult = Createobject ([Empty])
	AddProperty (loResult, [Name], [Snippet_Keyword])
	AddProperty (loResult, [Syntax], Evl (lcSyntax, []))
	AddProperty (loResult, [Summary], Evl (lcSummaryHTML, []))
	AddProperty (loResult, [Detail], Evl (lcDetailHTML, []))
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
#Define CursorSeparator '>'
#Define PrefixSeparator '='

 Function Process
	Lparameters tcAlias, tcCursor
	Local lcAlias As String,	  ;
		lcCursor As String,		  ;
		lcDummy As String,		  ;
		lcNewAlias As String,	  ;
		lcOpenFilePRG As String,  ;
		lcPrefix As String,		  ;
		lcReturn As String,		  ;
		lcThisPRG As String,	  ;
		lnSelect As Number,       ;
		lcFormFileName as String
	lnSelect = Select()
	Store [] To lcCursor, lcPrefix
	If CursorSeparator $ tcAlias
		lcCursor = Getwordnum (tcAlias, 2, CursorSeparator)
		lcAlias	 = Getwordnum (tcAlias, 1, CursorSeparator)
	Else
		If Not Empty (tcCursor)
			lcCursor = tcCursor
		Endif
		lcAlias = tcAlias
	Endif
	If [.] $ lcAlias
		lcDummy	 = lcAlias
		lcPrefix = Getwordnum (lcDummy, 1, [.])
		lcAlias	 = Getwordnum (lcDummy, 2, [.])
	Endif
	Do Case
		Case PrefixSeparator $ lcAlias
			lcDummy	 = lcAlias
			lcAlias	 = Getwordnum (lcDummy, 1, PrefixSeparator)
			lcPrefix = Getwordnum (lcDummy, 2, PrefixSeparator)
		Case PrefixSeparator $ lcCursor
			lcCursor = Getwordnum (lcCursor, 1, PrefixSeparator)
	Endcase
	If lcAlias = '*'
		lcAlias = Alias()
	Endif
	If Not Used (lcAlias)
		lcNewAlias = Execscript(_Screen.cThorDispatcher, 'PEME_OpenTable', lcAlias)
		If [C] = Vartype (lcNewAlias)
			lcAlias = lcNewAlias
		Endif
		If Not Used (lcAlias)
			Return .T. && mine, nothing to change
		Endif
	Endif
	Select (lcAlias)
	If Empty(lcAlias)
	   lcAlias = Getfile([dbf], [Select a table:], [], 0, [No table is open, please pick one])
	   Try 
	      Use (lcAlias)
	   Catch 
	      lcAlias=''
	   Endtry 
	Endif
	If Not Empty (lcAlias)
		lcFormFileName = ExecScript(_Screen.cThorDispatcher, "Full Path=PEME_Snippet_FP.SCX")
		Do Form (lcFormFileName) With lcAlias, lcCursor, lcPrefix To lcReturn
	Else
		Messagebox ('No table to open!')
	Endif
	Select (lnSelect)
	Return lcReturn
Endproc

****************************************************************
****************************************************************

* Publish the help for this snippet: calls function CreateHelpResult with three parameters:
*    Syntax
*    Summary
*    Full description

* Note that all have these may contain HTML tags

 Function PublishHelp
	Local lcDetailHTML, lcSummaryHTML, lcSyntax

	lcSyntax = 'Table [Target]'

	TEXT To lcSummaryHTML Noshow Textmerge
            <b>FP (F</b>ield <b>P</b>icker lets you easily selected fields
            from <b>Table</b> for various uses.</br>
            Can also be used as a replacement for <b>Browse</b> in the command window.
	ENDTEXT

	TEXT To lcDetailHTML Noshow Textmerge
         List all the fields in <b>Table</b> and lets you easily create the necessary code for most SQL statements
         like Select, Insert, Update and Create, in addition to Browse.<br /><br />
         Syntax: <b><font color=red>FP Table[=Local_Alias] [Target|>Target]</font></b><br /><br />
         <b>Variants:</b><br />
         <b>1. <font color=red>FP Table</font></b>: Uses <b>Table</b><br />
         <b>2. <font color=red>FP Table=Local_Alias</font></b>: Uses a local alias ... from Table as Local_Alias<br />
         <b>3. <font color=red>FP Local_Alias.Table</font></b>: Alternate form of #2<br />
         <b>4. <font color=red>FP Table Target</font></b>: Specifies the name of the target cursor (where applicable)<br />
         <b>5. <font color=red>FP Table=Local_Alias >Target</font></b>: A combination of #2 and #4<br /><br />
         You may use <b><font color=red>*</font></b> instead of <b><font color=red>Table</font></b> to indicate the currently selected table/cursor<br /><br />
        Sample 1: <b><font color=red>FP *</font></b><br />
        Sample 2: <b><font color=red>FP mytable</font></b><br />
        Sample 3: <b><font color=red>FP mytable=m1</font></b><br />
        Sample 4: <b><font color=red>FP _foxcode foxcodecopy</font></b><br /><br />
        <b><font color=red>FP *</font></b> is indeed a Browse on Steroids<br />

	ENDTEXT

	Return CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
Endproc
 