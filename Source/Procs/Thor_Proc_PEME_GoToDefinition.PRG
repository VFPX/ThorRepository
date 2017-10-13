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
	Case Empty(lcFileName)
		If Not AddMethodWithParameters(Alltrim(tcTextBefore, ' ', TAB)) 
			Execscript(_Screen.cThorDispatcher, 'Thor_Tool_PEME_QuickAddPEM')
		Endif
		* if the name of an open alias
	Case Used(lcFileName)
		ShowTable(lcFileName)
		Return .T.
		* if the name of one of Thor's Tools or Procs
	Case Not Isnull(Execscript(_Screen.cThorDispatcher, 'Edit=' + lcFileName))
		Return .T.
		* if the name of an existing object
	Case 'O' = Type(lcFileName) And 'O' = Vartype(&lcFileName)
		Execscript(_Screen.cThorDispatcher, 'Thor_Tool_ObjectInspector')
		Return .T.
		* well, then, maybe a table we can open
	Otherwise
		lcNewAlias = Execscript(_Screen.cThorDispatcher, 'PEME_OpenTable', lcFileName)
		If [C]	   = Vartype(lcNewAlias) And Used(lcNewAlias)
			ShowTable(lcNewAlias)
			Return .T.
		Else
			Return .F.
		Endif
Endcase


Procedure ShowTable(tcAlias)

	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SuperBrowse', tcAlias)

Endproc


Procedure AddMethodWithParameters(tcText)

	Local laObjects[1], lcMethod, lcMethodName, lcParameters, lnPos
	If 0 = Aselobj(laObjects) And 0 = Aselobj(laObjects, 1)
		Return .F.
	Endif

	If ')' # Right(tcText, 1)
		Return .F.
	Endif

	lnPos = At('(', tcText)
	If lnPos = 0
		Return .F.
	Endif

	lcMethod = Left(tcText, lnPos - 1)
	If Upper(lcMethod) # 'THIS' Or Not '.' $ lcMethod
		Return .F.
	Endif

	lcMethodName = Justext(lcMethod)
	lcParameters = Substr(tcText, lnPos + 1, Len(tcText) - lnPos - 1)
	If Not Empty(lcParameters)
		lcParameters = 'Lparameters ' + lcParameters
	Endif

	_oPEMEditor.oUtils.oIdex.QuickAddMethod(lcMethodName, lcParameters)

Endproc

