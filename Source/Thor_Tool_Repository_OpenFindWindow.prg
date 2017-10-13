Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1                    ;
      And [O] = Vartype (lxParam1)  ;
      And [thorinfo] = Lower (lxParam1.Class)
   #Define crlf Chr(13) + Chr(10)
   With lxParam1

* Required
      .Prompt         = [Go To 'Find' in PEM Editor] && used when tool appears in a menu
      .Summary       = [Activates PEM Editor and highlights Find]

* Optional
      .Description   = [This utility activates the Find textbox in PEM Editor] + crlf
      .Description   = .Description + [If PEM Editor is not active, it is activated]

* These are used to group and sort tools when they are displayed in menus or the Thor form
      .Source         = [Thor Repository] && where did this tool come from?  Your own initials, for instance
      .Category      = [Go To] && allows categorization for tools with the same source
      .SubCategory   = [] 
      .Sort         = 0 

* For public tools, such as PEM Editor, etc.
      .Version      = [1.1 October 9, 2011] 
      .Author        = [Tore Bleken]
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
   Execscript(_Screen.cThorDispatcher, [PEMEditor_StartIDETools])
      With _oPEMEditor.oPrefs
          .nGroupID = 1
          .lTypeEvent = .T.
          .lTypeMethod = .T.
          .lTypeProperty = .T.
          .lHierarchyCustom = .T.
          .lHierarchyInherited = .T.
          .lHierarchyNative = .T.
          .lNonDefault = .F.
          .lFavorites = .F.
      Endwith
   _oPEMEditor.oUtils.ShowForm()
   _opemeditor.oUtils.oPEMEditor.nmethodview = 1
   _opemeditor.oUtils.oPEMEditor.refresh()
   _oPEMEditor.oUtils.oPEMEditor.cntControls.cntfilters.txtSubString.SetFocus()
Endproc
