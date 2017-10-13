Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1                       ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt      = 'Go To Object' && used when tool appears in a menu
		.Description = 'Go To Object: Select the object which the method belongs to'

		* For public tools, such as PEM Editor, etc.
		.Source   = 'Thor Repository'
		.Category = 'Go To'
		.Author   = 'Jim Nelson'
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
	Local loObject, loTools

	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')
	If 'O' # Vartype (loTools)
		Return
	Endif

	loObject = loTools.GetThis()
	If Type ('loobject') = 'O'
		loTools.SelectObject (loObject)
	Endif Type ('loobject') = 'O'

Endproc
