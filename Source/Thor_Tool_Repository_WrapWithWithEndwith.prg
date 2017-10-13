Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype(lxParam1)  ;
		And 'thorinfo' = Lower(lxParam1.Class)

	With lxParam1

* Required
		.Prompt		 = 'Wrap text with With / EndWith'
		Text to .Description NoShow
Wraps highlighted lines of text with With / EndWith

You are prompted for the name of the object to follow WITH.  The default value supplied will be the object referenced at the beginning of the first statement in the highlighted lines.
		EndText

* For public tools, such as PEM Editor, etc.
		.Source		 = 'Thor Repository'
		.Category	 = 'Code|Highlighted text|Wrap text'
		.Author		 = 'Andrew Nickless'
		.Link		 = 'http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object'
		.CanRunAtStartUp = .F.
	Endwith

	Return lxParam1
Endif

Do ToolCode

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode

* get the object which manages the editor window
* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
Local lcClipText, lcOldClipText, lnCursorPosition, loEditorWin
loEditorWin = Execscript(_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
* locate the active editor window; exit if none active
If loEditorWin.GetEnvironment(25) <= 0
	Return
Endif

lcOldClipText = _Cliptext
* copy highlighted text into clipboard
loEditorWin.Copy()
lcClipText = _Cliptext
If Empty(lcClipText)
	Return
Endif

lnCursorPosition = -1
ModifySelectedText(loEditorWin, @lcClipText, @lnCursorPosition)
****************************************************************
* This final block of code pastes in the modification (in <lcNewCliptext>)
loEditorWin.Paste(lcClipText)

If lnCursorPosition >= 0
	loEditorWin.SetInsertionPoint(lnCursorPosition)
Endif

Return
Endproc

Procedure ModifySelectedText(loEditorWin, lcClipText, lnCursorPosition)
* Parameters:
*	lcCliptext:  		Currently selected (or highlighted) text
* 	lnCursorPosition: 	Where to place the cursor when done (Passed in by reference)

#Define ccTab  		Chr(9)
#Define ccCR		Chr(13)

Local lLastChildfound, laLines[1], lcChild, lcCmd, lcExtraIndent, lcFirstLine, lcIndent
Local lcLastObject, lcLine, lcNewClipText, lcObjFamilyTree, lcObject, liOccurs[1], lnCol, lnI
Local lnLineCount, lnParents
lnLineCount	= Alines(laLines, lcClipText)
lcFirstLine	= Alltrim(laLines[1], 1, ' ', ccTab)
Do Case
Case '=' $ lcFirstLine
	lcObjFamilyTree = Substr(lcFirstLine, 1, At('=', lcFirstLine) - 1)
	If  '.' $ lcObjFamilyTree = .F.
		lcObjFamilyTree = Substr(lcFirstLine, At('=', lcFirstLine) + 1)
		Do Case
		Case '(' $ lcObjFamilyTree
			lcObjFamilyTree = Substr(lcObjFamilyTree, 1, At('(', lcObjFamilyTree) - 1)
		Case '[' $ 	lcObjFamilyTree
			lcObjFamilyTree = Substr(lcObjFamilyTree, 1, At('[', lcObjFamilyTree) - 1)
		Case '+' $ 	lcObjFamilyTree
			lcObjFamilyTree = Substr(lcObjFamilyTree, 1, At('+', lcObjFamilyTree) - 1)
		Case '-' $ 	lcObjFamilyTree
			lcObjFamilyTree = Substr(lcObjFamilyTree, 1, At('-', lcObjFamilyTree) - 1)
		Case '*' $ 	lcObjFamilyTree
			lcObjFamilyTree = Substr(lcObjFamilyTree, 1, At('*', lcObjFamilyTree) - 1)
		Case '/' $ 	lcObjFamilyTree
			lcObjFamilyTree = Substr(lcObjFamilyTree, 1, At('/', lcObjFamilyTree) - 1)
		Endcase
	Endif
Case '(' $ lcFirstLine
	lcObjFamilyTree = Substr(lcFirstLine, 1, At('(', lcFirstLine) - 1)
Case '[' $ lcFirstLine
	lcObjFamilyTree = Substr(lcFirstLine, 1, At('[', lcFirstLine) - 1)
Otherwise
	lcObjFamilyTree = lcFirstLine
Endcase

lnParents = Getwordcount(lcObjFamilyTree, '.') - 1
If lnParents > 0
	Dimension liOccurs(lnLineCount, lnParents) As Integer
	lcObject		= Iif(Substr(lcObjFamilyTree, 1) <> '.', Getwordnum(lcObjFamilyTree, 1, '.'), '.' + Getwordnum(lcObjFamilyTree, 1, '.'))
	lLastChildfound	= .F.
	lcChild			= ''
	lnCol			= 1
	Do While lLastChildfound = .F. And lnCol < lnParents + 1
		lcLastObject = lcObject
		lcObject	 = lcObject + lcChild
		For lnI = 1 To lnLineCount
			liOccurs(lnI, lnCol) = Occurs(Upper(lcObject), Upper(laLines[lnI]))
			If lnCol > 1 And liOccurs(lnI, lnCol) = 0 And liOccurs(lnI, lnCol - 1) > 0
				lLastChildfound	= .T.
				lcObject		= lcLastObject
				Exit
			Endif
		Endfor
		lnCol	= lnCol + 1
		lcChild	= '.' + Getwordnum(lcObjFamilyTree, lnCol, '.')
	Enddo
Else
	lcObject = ''
Endif

lcCmd = Inputbox('Enter With / EndWith parent object.', 'With Object', lcObject, 0, 'Timed Out', 'Canceled')
If lcCmd = 'Timed Out' Or lcCmd = 'Canceled'
	Return
Endif

lcObject		 = lcCmd
lcClipText		 = Strtran(lcClipText, lcObject, '', -1, -1, 1)
lnLineCount		 = Alines(laLines, lcClipText)
lcFirstLine		 = laLines[1]
lcIndent		 = Left(lcFirstLine, At(Getwordnum(lcFirstLine, 1), lcFirstLine) - 1)
lcNewClipText	 = lcIndent + 'With ' + lcObject
lnCursorPosition = loEditorWin.GetSelStart() + Len(lcNewClipText)
lcExtraIndent	 = GetNormalIndentation()

lnI = 1
For lnI = 1 To lnLineCount
	lcLine = laLines(lnI)
	Do Case
	Case Empty(lcLine)
		lcNewClipText = lcNewClipText + ccCR
	Case lcLine = lcIndent
		lcNewClipText = lcNewClipText + ccCR + lcIndent + lcExtraIndent + Substr(lcLine, 1 + Len(lcIndent))
	Otherwise
		lcNewClipText = lcNewClipText + ccCR + lcLine
	Endcase
Endfor

lcNewClipText = lcNewClipText + ccCR
lcNewClipText = lcNewClipText + lcIndent + 'EndWith' + ' &' + '& ' + lcObject + Iif(Substr(lcClipText, Len(lcClipText)) <> ccCR, '', ccCR)
lcClipText	  = lcNewClipText

Return
Endproc

Procedure GetNormalIndentation
If Execscript(_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 4) = 1
	Return ccTab
Else
	Return Space(Execscript(_Screen.cThorDispatcher, 'Thor_Proc_BeautifyOption', 3))
Endif
Endproc

