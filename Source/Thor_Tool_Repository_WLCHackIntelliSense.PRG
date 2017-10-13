********************************************************************************
*  PROGRAM: Thor_Tool_WLCHackIntellisense.prg
*
*  AUTHOR:  Richard A. Schummer, October, 2014
*
*  COPYRIGHT © 2014   All Rights Reserved.
*     Richard A. Schummer
*     White Light Computing, Inc.
*     PO Box 391
*     Washington Twp., MI  48094
*     raschummer@whitelightcomputing.com
*     rick@rickschummer.com
*
*     Contributed to VFPX in Thor Repository, for use under VFPX license.
*
*  PROGRAM DESCRIPTION:
*     Alternative UI to modify Intellisense (_foxcode) table.
*
*  CALLING SYNTAX:
*     DO Thor_tool_wlclistfields.prg WITH [lxParam1], [tcCursorName], [tlModifyFile]
*
*  INPUT PARAMETERS:
*     txParam1     = object if called from VFPX Thor or character if called from 
*                    command line. Object from Thor is used to work with settings. 
*                    When you call with character it is the file name used to create 
*                    and potentially display the column listing (typically a text file)
*     tcCursorName = character, the name of the cursor you want to list fields. 
*                    Optionally used if you want to work with a cursor that is not in 
*                    the current workarea.
*     tlModifyFile = logical, true if you want the text file to be opened after the 
*                    listing is created. This parameter is set to .T. when called from
*                    Thor.
*
*  OUTPUT PARAMETERS:
*     None
*
*  DATABASES ACCESSED:
*     None
* 
*  GLOBAL PROCEDURES REQUIRED:
*     None
* 
*  CODING STANDARDS:
*     Version 5.0 compliant with no exceptions
*  
*  TEST INFORMATION:
*     None
*   
*  SPECIAL REQUIREMENTS/DEVICES:
*     None
*
*  FUTURE ENHANCEMENTS:
*     None
*
*  LANGUAGE/VERSION:
*     Visual FoxPro 09.00.0000.7423 or higher
* 
********************************************************************************
*                             C H A N G E    L O G                              
*
*    Date     Developer               Version  Description
* ----------  ----------------------  -------  ---------------------------------
* 10/26/2014  Richard A. Schummer     1.0      Updated to work with VFPX Thor
* ------------------------------------------------------------------------------
*
********************************************************************************
LPARAMETERS txParam1

* Standard prefix for all tools for Thor, allowing this tool to tell Thor about itself.
IF PCOUNT() = 1 AND 'O' = VARTYPE(m.txParam1) AND 'thorinfo' = LOWER(m.txParam1.Class)
   WITH m.txParam1
      * Required
      .Prompt  = 'WLC Hack IntelliSense (_foxcode) table'
      .Summary = "WLC Hack IntelliSense (_foxcode) table by White Light Computing."

      * Optional
      .Source   = "Thor Repository"
      .Category = 'Applications'
      .Author   = "Rick Schummer"
      .Version  = '1.4.3'
      .CanRunAtStartUp = .F.
      * For public tools, such as PEM Editor, etc.
      .Link    = "http://www.whitelightcomputing.com/resourcesfreedevelopertools.htm"
   ENDWITH 

   RETURN m.txParam1
ENDIF 

DO FORM EXECSCRIPT(_Screen.cThorDispatcher, 'full path=Thor_Tool_WLCHackIntelliSense.scx')

RETURN 

*: EOF :*