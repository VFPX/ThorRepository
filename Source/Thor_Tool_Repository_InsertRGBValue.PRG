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
		.Prompt	 = 'Insert color ... RGB(x,y,z)' && used when tool appears in a menu
		.Summary = 'Prompt for color and insert RGB value'
		Text to .Description NoShow
Prompts for color value (using GetColor) and inserts the result as RGB()
		EndText
		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source	  = 'Thor Repository' && where did this tool come from?  Your own initials, for instance
		.Category = 'Code|Inserting text'
		.Author   = 'Matt Slay'
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
	Local lcPreviousClipText, lcRGB, lnBlue, lnColor, lnGreen, lnRed, loEditorWin
	loEditorWin = Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')
	* locate the active editor window; exit if none active
	If loEditorWin.GetEnvironment(25) < 0
		Return
	Endif

	lnColor = Getcolor()
	If lnColor < 0
		Return
	Endif

	lnRed	= Bitand (lnColor, 255)
	lnGreen	= Bitrshift (Bitand (lnColor, 256 * 255), 8)
	lnBlue	= Bitrshift (Bitand (lnColor, 256 * 256 * 255), 16)
	lcRGB	= Transform (lnRed) + ',' + Transform (lnGreen) + ',' + Transform (lnBlue)

	loEditorWin.Paste('RGB(' + lcRGB + ')')

EndProc
