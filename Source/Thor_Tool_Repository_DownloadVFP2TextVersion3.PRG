Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype (m.lxParam1)		;
		And 'thorinfo' == Lower (m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'Download VFP2Text for Beyond Compare v3' && used in menus

		Text To .Description Noshow
Download the installer for VFP2Text for Beyond Compare v3.
		Endtext
		.Category = 'Applications|VFP2Text for Beyond Compare'
		.Author	  = 'Frank Perez, Jr.'
		.Sort	  = 15
	Endwith

	Return m.lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With m.lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	
	GoURL("http://pfsolutions-mi.com/Downloads/VFP2Text/VFP2Text-v3.exe")
Endproc


****************************************************
FUNCTION GoUrl
******************
***    Author: Rick Strahl
***            (c) West Wind Technologies, 1996
***   Contact: rstrahl@west-wind.com
***  Modified: 03/14/96
***  Function: Starts associated Web Browser
***            and goes to the specified URL.
***            If Browser is already open it
***            reloads the page.
***    Assume: Works only on Win95 and NT 4.0
***      Pass: tcUrl  - The URL of the site or
***                     HTML page to bring up
***                     in the Browser
***    Return: 2  - Bad Association (invalid URL)
***            31 - No application association
***            29 - Failure to load application
***            30 - Application is busy 
***
***            Values over 32 indicate success
***            and return an instance handle for
***            the application started (the browser) 
****************************************************
LPARAMETERS tcUrl, tcAction, tcDirectory, tcParms

IF EMPTY(tcUrl)
   RETURN -1
ENDIF
IF EMPTY(tcAction)
   tcAction = "OPEN"
ENDIF
IF EMPTY(tcDirectory)
   tcDirectory = SYS(2023) 
ENDIF

DECLARE INTEGER ShellExecute ;
    IN SHELL32.dll ;
    INTEGER nWinHandle,;
    STRING cOperation,;
    STRING cFileName,;
    STRING cParameters,;
    STRING cDirectory,;
    INTEGER nShowWindow
IF EMPTY(tcParms)
   tcParms = ""
ENDIF

DECLARE INTEGER FindWindow ;
   IN WIN32API ;
   STRING cNull,STRING cWinName

RETURN ShellExecute(0,;
                    tcAction,tcUrl,;
                    tcParms,tcDirectory,1)
