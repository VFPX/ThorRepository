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
		.Prompt		 = 'Go To Method' && used when tool appears in a menu
		.Summary	 = 'Go To Method' && may be lengthy, including CRs, etc
		.Description = 'Opens a dialog form to choose available methods to view or edit.' + Chr(13) + Chr(13) + 'Requires PEM Editor 7.'

		* For public tools, such as PEM Editor, etc.
		.Source	  = 'Thor Repository'
		.Category = 'Go To'
		.Author	  = 'Matt Slay'
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
	Local lcFormFileName, loFormMethodsCollection, loMethod, loObjectMethodsCollection, loPEME_Tools

	* see	http://vfpx.codeplex.com/wikipage?title=Thor%20Tools%20Object
	loPEME_Tools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')
	If 'O' # Vartype (loPEME_Tools)
		Return
	Endif

	loFormMethodsCollection	  = loPEME_Tools.GetPEMList (.T., 'ME')
	loObjectMethodsCollection = loPEME_Tools.GetPEMList (.F., 'ME')
	lcFormFileName			  = Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_Tool_Repository_GoToMethod.SCX')

	Do Form (lcFormFileName)									 ;
		With loFormMethodsCollection, loObjectMethodsCollection	 ;
		To loMethod

	If 'O' = Vartype (loMethod)
		loPEME_Tools.EditMethod (loMethod.Type = 1, loMethod.MethodName)
	Endif

Endproc
