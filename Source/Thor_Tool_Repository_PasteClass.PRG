Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		 = 'Insert reference to class' && used when tool appears in a menu
		Text to .Description NoShow
Inserts a reference to the class that an object belongs to; This.Parent.Parent, etc.

This can also be accomplished by using a Dynamic Snippet:
    TC <<Dynamic Snippet Tool>>
   		EndText

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		 = 'Thor Repository' && where did this tool come from?  Your own initials, for instance
		.Category	 = 'Code|Inserting text'
		.Sort		 = 0 && the sort order for all items from the same Source, Category and Sub-Category
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

	Local lcOldClipboard, lcPaste, loEditorWin, loObject, loThisClass, loTools

	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20EditorWindow%20Object
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')

	If 'O' # Vartype (loTools)
		Return
	Endif

	loObject = loTools.GetThis()
	If 'O' = Vartype (loObject)
		loThisClass	= loTools.GetCurrentObject (.T.)
		lcPaste		= 'This'
		Do While loObject # loThisClass
			lcPaste	 = lcPaste + '.Parent'
			loObject = loObject.Parent
		Enddo

		loEditorWin.Paste(lcPaste)

		Keyboard '.'
	Endif

Endproc
