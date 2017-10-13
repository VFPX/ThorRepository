Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (lxParam1)		;
		And 'thorinfo' == Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		   = 'Save As Class' && used in menus

		* Optional
		Text To .Description Noshow && a description for the tool
Saves the currently selected object as a new class.  (For use when the menu item "Save as Class..." is disabled.)

Pop up form allows selection of the name of the new class and the class library where it is to be stored.

The "Save as Class..." is disabled when editing a class. This tool fills that void.

Note that you can create a duplicate of a class by opening it and using this tool without selecting any child objects.
		Endtext
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category      = 'Objects and PEMs'

		* For public tools, such as PEM Editor, etc.
		.Version = '' && e.g., 'Version 7, May 18, 2011'
		.Author	 = 'Jim Nelson'

	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
	Local loTools As Pemeditor_tools Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_tools.vcx'
	Local laObjects[1], lcClassLibrary, loForm, loObject, loTopOfForm

	loTools = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')

	loObject = loTools.GetCurrentObject()
	If Isnull(loObject)
		Messagebox('No object selected in a form or class', 16, 'Nothing to do')
		Return
	Endif

	Aselobj(laObjects, 3)
	If Upper(Justext(laObjects[2])) = 'VCX'
		loTopOfForm	   = loTools.GetCurrentObject(.T.)
		lcClassLibrary = loTopOfForm.ClassLibrary
	Else
		lcClassLibrary = loObject.ClassLibrary
	Endif

	loForm				 = Execscript(_Screen.cThorDispatcher, 'Class= FrmSaveAsClass of Thor_Proc_SaveAsClass.VCX')
	loForm.oObject		 = loObject
	loForm.cClassLibrary = lcClassLibrary
	loForm.Show(1)

	If Vartype(loForm) = 'O' And loForm.lCreate
		CreateClass(loObject, Alltrim(loForm.cClass), Alltrim(loForm.cClassLibrary))
	Endif

Endproc


Procedure CreateClass(loObject, lcClass, lcClassLibrary)
	Local llFailed, loException, loTools

	Try
		loObject.SaveAsClass(lcClassLibrary, lcClass)
	Catch To loException
		llFailed   = .T.
		Messagebox('Unable to save ' + lcClass + ' into ' + Justfname(lcClassLibrary) + CR + CR + loException.Message, 16, 'Failed')
	Endtry

	If llFailed
		Return .F.
	Endif

	* --------------------------------------------------------------------------------
	loTools = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')
	loTools.EditSourceX(lcClassLibrary, lcClass)
	Return .T.

Endproc