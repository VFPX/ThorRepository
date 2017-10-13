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
		.Prompt		   = 'Install enhanced ZLOC' && used when tool appears in a menu
		.Summary       = 'Installs enhanced version of ZLOC' 
		
		* Optional
		Text to .Description NoShow
Installs an enhanced version of ZLOC, which will cause the pop-up list to also include all variables assigned in code, whether they are in the LOCALs list or not.

If you are not aware of ZLOC, it comes with VFP. If you enter ZLOC[Space] within a code window, you get a popup of all the locals and parameters defined the method (or PRG.)

This enhanced version causes variables assigned values but not yet added to the list of LOCALs to be included in the popup.

If you are annoying by having to enter ZLOC[Space], create a Thor Tool or On Key Label that executes Keyboard 'zloc '

Note that this only need be done once, is it updates the FoxCode table.
		EndText
		.StatusBarText = '' 

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source		   = 'Thor Repository' && where did this tool come from?  Your own initials, for instance
		.Category      = 'Code|Miscellaneous' && and sub-categorization
		.Sort		   = 40 && the sort order for all items from the same Source, Category and Sub-Category
		
		* For public tools, such as PEM Editor, etc.
		.Version	   = '' 
		.Author        = 'Jim Nelson'
		.Link          = '' 
		.CanRunAtStartup = .F.
		 
	Endwith

	Return lxParam1
Endif

Do ToolCode

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Local lnResponse
	lnResponse = Messagebox ('Install enhanced version of ZLOC?', 3 + 32)
	Do Case
		Case lnResponse = 6
			InstallZLoc (.T.)
			Messagebox ('Enhanced ZLOC installed', 64)
		Case lnResponse = 7
			lnResponse = Messagebox ('Re-install default version of ZLOC?', 3 + 32)
			If lnResponse = 6
				InstallZLoc (.F.)
				Messagebox ('Default ZLOC re-installed', 64)
			Endif
	Endcase
Endproc


Procedure InstallZLOC
	Lparameters llEnhancedVersion

	Local lcCode
	If llEnhancedVersion
		lcCode = GetEnhancedZLOCCode()
	Else
		lcCode = GetOriginalZLOCCode()
	Endif

	Use In (Select ('Foxcode')) && Close 'Foxcode'
	Select 0
	Use (_Foxcode) Again Shared Alias Foxcode

	Locate For Upper (abbrev) == Padr (Upper ('ZLOC'), 24)  And Not Deleted()

	If Found()
		Replace Data With lcCode
	Else
		Insert Into Foxcode														;
			(Type, abbrev, cmd, Data, Case, Save, Timestamp, Source, uniqueID)	;
			Values																;
			('S', 'zloc', '{}', lcCode, 'U', .T., Datetime(), 'RESERVED', Sys(2015))
	Endif

	Use

	Return
	
EndProc



**************************************************************************
**************************************************************************
**************************************************************************
Procedure GetEnhancedZLOCCode

	Text To lcCode Noshow
LPARAMETER oFoxScript

* This script iterates thru all the Locals in the routine and lists them.
* The PARAMETER passed in is reference to FoxCodeScript object.
* The routine is smart and detects scope so that locals in procedures
* above or below are excluded. 
*
* To enable this script, make sure that you have the lAllowCustomDefScripts 
* custom property set to .T. (you can set this in the IntelliSense Manager).

LOCAL lcfxtoollib, lnWinHdl, laEnv, lcStr, lnLines, i, lcLine, lcDefDesc, laLines, lcLastWord 
IF oFoxScript.oFoxcode.Location=0	&&Command Window
	RETURN .F.
ENDIF

IF !UPPER(oFoxScript.oFoxcode.UserTyped) == UPPER(oFoxScript.cCustomScriptName)   &&Script = ZLOC
	RETURN .F.
ENDIF

lcfxtoollib = SYS(2004)+"FOXTOOLS.FLL"
IF !FILE(lcfxtoollib)
	RETURN .F.
ENDIF
SET LIBRARY TO (m.lcfxtoollib) ADDITIVE

lnWinHdl = _WONTOP()
_wselect(lnWinHdl)

DIMENSION laEnv[25]
_EdGetEnv(lnWinHdl ,@laEnv)
lcStr = _EDGETSTR(lnWinHdl , 0, laEnv[17])

Try
	GetEnhancedLocDefs(lcStr, oFoxScript.oFoxCode)
Catch to loException
	GetLocDefs(lcStr, oFoxScript.oFoxCode)
EndTry 


IF !EMPTY(oFoxScript.oFoxcode.Items[1])
	DIMENSION laLines[1]
	lnLines = ALINES(laLines,lcStr)
	lcLastWord = ALLTRIM(GETWORDNUM( laLines[ALEN(laLines)] , GETWORDCOUNT(laLines[ALEN(laLines)] )))
	lcLastWord=LEFT(lcLastWord, LEN(lcLastWord) - LEN(oFoxScript.cCustomScriptName))
	oFoxScript.ReplaceWord(lcLastWord)
	* Handle extra space
	IF ASC(RIGHT(oFoxScript.oFoxCode.FullLine,1))=32
		_EDSETPOS(lnWinHdl, _EDGETPOS(lnWinHdl) - 1)
	ENDIF
	oFoxScript.oFoxCode.ValueType = "L"
ENDIF

RETURN ""


Procedure GetEnhancedLocDefs (tcStr, toFoxCode)

	Local laLines[1], lcCodeBlock, lcLine, lcStr, lcVar, lcWord, lnALen, lnI, lnLines, loTools, loVariables

	If Empty (tcStr)
		Return
	Endif
	lcStr = tcStr

	Dimension laLines[1]
	lnLines = Alines (laLines, lcStr)

	lcCodeBlock = ''
	* Quick search backward to find its procedure
	For lnI = lnLines To 1 Step - 1
		lcLine		= Alltrim (laLines[m.lnI])
		lcCodeBlock	= lcLine + Chr(13) + lcCodeBlock

		lcWord = Alltrim (Getwordnum (Alltrim (laLines[m.lnI]), 1))
		If Len (lcWord) > 3 And (					;
				  Atc (lcWord, 'PROCEDURE') # 0		;
				  Or Atc (lcWord, 'FUNCTION') # 0	;
				  Or Atc (lcWord, 'PROTECTED') # 0	;
				  Or Atc (lcWord, 'HIDDEN') # 0		;
				  )
			Exit
		Endif
	Endfor

	ExecScript(_Screen.cThorDispatcher, 'PEMEditor_StartIDETools')
	loTools = ExecScript(_Screen.cThorDispatcher, "Class= tools from pemeditor")
	loVariables = loTools.GetVariablesList (lcCodeBlock)

	If loVariables.Count = 0
		Return
	EndIf

	For Each lcVar In loVariables FoxObject
		lnALen = Alen (toFoxCode.Items, 1)
		If Not Empty (toFoxCode.Items[1])
			Dimension toFoxCode.Items[lnALen + 1, 2]
			lnALen = Alen (toFoxCode.Items, 1)
		Endif
		toFoxCode.Items[lnALen, 1] = m.lcVar
	Endfor

	Return
Endproc


PROCEDURE GetLocDefs(tcStr, toFoxCode)
	LOCAL lcStr, lnLines, i, lcLine, laLines, lnALen, j, lcWord, lcWords, lnFirstLine, lcInlineParms
	LOCAL lnPos1, lnPos2, lHasLineContinuation 
	lcInlineParms = ""
	
	IF EMPTY(tcStr)
		RETURN
	ENDIF
	lcStr = tcStr
	
	DIMENSION laLines[1]
	lnLines = ALINES(laLines,lcStr)

	* Quick search backward to find its procedure
	FOR i = lnLines TO 1 STEP -1
		lcWord = ALLTRIM(GETWORDNUM(ALLTRIM(laLines[m.i]), 1))
		IF LEN(lcWord)>3 AND (ATC(lcWord,"PROCEDURE")#0 OR ATC(lcWord,"FUNCTION")#0)
			* since we are here, let's handle any inline parms
			lcWord = ALLTRIM(laLines[m.i])
			IF ATC(REPLICATE("&",2), lcWord)#0   && strip out comments
				lcWord = ALLTRIM(LEFT(lcWord, ATC(REPLICATE("&",2),lcWord)-1) ) 
			ENDIF
			lnPos1 = ATC("(", lcWord)
			lnPos2 = RATC(")", lcWord)
			* Check for inline parms
			IF lnPos1#0 AND lnPos2#0
				* inline parms
				lcInlineParms = ALLTRIM(SUBSTRC(lcWord, lnPos1+1, lnPos2 - lnPos1 - 1))
			ENDIF
			EXIT
		ENDIF
	ENDFOR
	lnFirstLine = MAX(m.i,1)
		
	* Iterate through each line
	lHasLineContinuation = .F.
	FOR i = lnFirstLine TO lnLines
		lcLine = ALLTRIM(laLines[m.i])
		IF lHasLineContinuation
			IF LEFT(GETWORDNUM(lcLine,1),1)=","
				lcLine = SUBSTRC(lcLine,ATC(",",lcLine)+1)
			ENDIF
			lcLine = "LOCAL " + lcLine
		ENDIF
		lcWord = ALLTRIM(GETWORDNUM(lcLine, 1))
		
		* Loop upward until we encounter a PROC or 
		* FUNCTION call indicating out of scope.
		IF LEN(lcWord)>3 AND (ATC(lcWord,"PROCEDURE")#0 OR ATC(lcWord,"FUNCTION")#0)
			* Check for inline parms
			IF EMPTY(lcInlineParms)
				LOOP
			ENDIF
			lcLine = "LPARAMETERS " + lcInlineParms
			lcWord = "LPARAMETERS"
		ENDIF

		* Look only for LOCAL, PUBLIC, PARAM or LPARAM statements
		IF LEN(lcWord)>3 AND ;
		  	( ATC(lcWord+" ","LOCAL ")#0 OR ;
			 ATC(lcWord,"PUBLIC")#0 OR;
			 ATC(lcWord,"PARAMETERS")#0 OR;
			 ATC(lcWord,"LPARAMETERS")#0  )
		ELSE
			LOOP
		ENDIF

		lcWords = SUBSTRC(lcLine, ATC(GETWORDNUM(lcLine, 2), lcLine))
		IF ATC(REPLICATE("&",2), lcWords)#0   		&& strip out comments
			lcWords = ALLTRIM(LEFT(lcWords, ATC(REPLICATE("&",2),lcWords)-1) ) 	
		ENDIF
		
		* Have a valid statement so now Iterate through each word (separated by comma)
		FOR j = 1 to GETWORDCOUNT(lcWords, ",")

			lcWord = GETWORDNUM(lcWords, m.j, ",")
			
			* If arrays, then we need to parse out the indexes
			IF UPPER(GETWORDNUM(lcWord,1)) == "ARRAY"
				* Skip to second word
				lcWord = GETWORDNUM(lcWord,2)
			ENDIF

			lcWord = ALLTRIM(GETWORDNUM(lcWord,1))

			* Parse out any array stuff.
			DO CASE
			CASE ATC("[", lcWord)#0
				lcWord = LEFT(lcWord, ATC("[", lcWord)-1)
			CASE ATC("(", lcWord)#0
				lcWord = LEFT(lcWord, ATC("(", lcWord)-1)
			CASE ATC("]", lcWord)#0 OR ATC(")",lcWord)#0
				LOOP
			CASE ATC(";", lcWord)#0
				lcWord = LEFT(lcWord,  ATC(";", lcWord)-1)
				IF EMPTY(lcWord)
					LOOP
				ENDIF
			ENDCASE
			
			lnALen = ALEN(toFoxCode.Items,1)
			IF !EMPTY(toFoxCode.Items[1])
				DIMENSION toFoxCode.Items[lnALen+1,2]
				lnALen = ALEN(toFoxCode.Items,1)
			ENDIF
			toFoxCode.Items[lnALen, 1] = lcWord	
		ENDFOR
		* Check for line continuation
		lHasLineContinuation = (RIGHT(lcWords,1) = ";")
	ENDFOR
	
ENDPROC
	Endtext

	Return lcCode
Endproc




**************************************************************************
**************************************************************************
**************************************************************************
Procedure GetOriginalZLOCCode

	Text To lcCode Noshow
LPARAMETER oFoxScript

* This script iterates thru all the Locals in the routine and lists them.
* The PARAMETER passed in is reference to FoxCodeScript object.
* The routine is smart and detects scope so that locals in procedures
* above or below are excluded. 
*
* To enable this script, make sure that you have the lAllowCustomDefScripts 
* custom property set to .T. (you can set this in the IntelliSense Manager).

LOCAL lcfxtoollib, lnWinHdl, laEnv, lcStr, lnLines, i, lcLine, lcDefDesc, laLines, lcLastWord 
IF oFoxScript.oFoxcode.Location=0	&&Command Window
	RETURN .F.
ENDIF

IF !UPPER(oFoxScript.oFoxcode.UserTyped) == UPPER(oFoxScript.cCustomScriptName)   &&Script = ZLOC
	RETURN .F.
ENDIF

lcfxtoollib = SYS(2004)+"FOXTOOLS.FLL"
IF !FILE(lcfxtoollib)
	RETURN .F.
ENDIF
SET LIBRARY TO (m.lcfxtoollib) ADDITIVE

lnWinHdl = _WONTOP()
_wselect(lnWinHdl)

DIMENSION laEnv[25]
_EdGetEnv(lnWinHdl ,@laEnv)
lcStr = _EDGETSTR(lnWinHdl , 0, laEnv[17])

GetLocDefs(lcStr, oFoxScript.oFoxCode)

IF !EMPTY(oFoxScript.oFoxcode.Items[1])
	DIMENSION laLines[1]
	lnLines = ALINES(laLines,lcStr)
	lcLastWord = ALLTRIM(GETWORDNUM( laLines[ALEN(laLines)] , GETWORDCOUNT(laLines[ALEN(laLines)] )))
	lcLastWord=LEFT(lcLastWord, LEN(lcLastWord) - LEN(oFoxScript.cCustomScriptName))
	oFoxScript.ReplaceWord(lcLastWord)
	* Handle extra space
	IF ASC(RIGHT(oFoxScript.oFoxCode.FullLine,1))=32
		_EDSETPOS(lnWinHdl, _EDGETPOS(lnWinHdl) - 1)
	ENDIF
	oFoxScript.oFoxCode.ValueType = "L"
ENDIF

RETURN ""


PROCEDURE GetLocDefs(tcStr, toFoxCode)
	LOCAL lcStr, lnLines, i, lcLine, laLines, lnALen, j, lcWord, lcWords, lnFirstLine, lcInlineParms
	LOCAL lnPos1, lnPos2, lHasLineContinuation 
	lcInlineParms = ""
	
	IF EMPTY(tcStr)
		RETURN
	ENDIF
	lcStr = tcStr
	
	DIMENSION laLines[1]
	lnLines = ALINES(laLines,lcStr)

	* Quick search backward to find its procedure
	FOR i = lnLines TO 1 STEP -1
		lcWord = ALLTRIM(GETWORDNUM(ALLTRIM(laLines[m.i]), 1))
		IF LEN(lcWord)>3 AND (ATC(lcWord,"PROCEDURE")#0 OR ATC(lcWord,"FUNCTION")#0)
			* since we are here, let's handle any inline parms
			lcWord = ALLTRIM(laLines[m.i])
			IF ATC(REPLICATE("&",2), lcWord)#0   && strip out comments
				lcWord = ALLTRIM(LEFT(lcWord, ATC(REPLICATE("&",2),lcWord)-1) ) 
			ENDIF
			lnPos1 = ATC("(", lcWord)
			lnPos2 = RATC(")", lcWord)
			* Check for inline parms
			IF lnPos1#0 AND lnPos2#0
				* inline parms
				lcInlineParms = ALLTRIM(SUBSTRC(lcWord, lnPos1+1, lnPos2 - lnPos1 - 1))
			ENDIF
			EXIT
		ENDIF
	ENDFOR
	lnFirstLine = MAX(m.i,1)
		
	* Iterate through each line
	lHasLineContinuation = .F.
	FOR i = lnFirstLine TO lnLines
		lcLine = ALLTRIM(laLines[m.i])
		IF lHasLineContinuation
			IF LEFT(GETWORDNUM(lcLine,1),1)=","
				lcLine = SUBSTRC(lcLine,ATC(",",lcLine)+1)
			ENDIF
			lcLine = "LOCAL " + lcLine
		ENDIF
		lcWord = ALLTRIM(GETWORDNUM(lcLine, 1))
		
		* Loop upward until we encounter a PROC or 
		* FUNCTION call indicating out of scope.
		IF LEN(lcWord)>3 AND (ATC(lcWord,"PROCEDURE")#0 OR ATC(lcWord,"FUNCTION")#0)
			* Check for inline parms
			IF EMPTY(lcInlineParms)
				LOOP
			ENDIF
			lcLine = "LPARAMETERS " + lcInlineParms
			lcWord = "LPARAMETERS"
		ENDIF

		* Look only for LOCAL, PUBLIC, PARAM or LPARAM statements
		IF LEN(lcWord)>3 AND ;
		  	( ATC(lcWord+" ","LOCAL ")#0 OR ;
			 ATC(lcWord,"PUBLIC")#0 OR;
			 ATC(lcWord,"PARAMETERS")#0 OR;
			 ATC(lcWord,"LPARAMETERS")#0  )
		ELSE
			LOOP
		ENDIF

		lcWords = SUBSTRC(lcLine, ATC(GETWORDNUM(lcLine, 2), lcLine))
		IF ATC(REPLICATE("&",2), lcWords)#0   		&& strip out comments
			lcWords = ALLTRIM(LEFT(lcWords, ATC(REPLICATE("&",2),lcWords)-1) ) 	
		ENDIF
		
		* Have a valid statement so now Iterate through each word (separated by comma)
		FOR j = 1 to GETWORDCOUNT(lcWords, ",")

			lcWord = GETWORDNUM(lcWords, m.j, ",")
			
			* If arrays, then we need to parse out the indexes
			IF UPPER(GETWORDNUM(lcWord,1)) == "ARRAY"
				* Skip to second word
				lcWord = GETWORDNUM(lcWord,2)
			ENDIF

			lcWord = ALLTRIM(GETWORDNUM(lcWord,1))

			* Parse out any array stuff.
			DO CASE
			CASE ATC("[", lcWord)#0
				lcWord = LEFT(lcWord, ATC("[", lcWord)-1)
			CASE ATC("(", lcWord)#0
				lcWord = LEFT(lcWord, ATC("(", lcWord)-1)
			CASE ATC("]", lcWord)#0 OR ATC(")",lcWord)#0
				LOOP
			CASE ATC(";", lcWord)#0
				lcWord = LEFT(lcWord,  ATC(";", lcWord)-1)
				IF EMPTY(lcWord)
					LOOP
				ENDIF
			ENDCASE
			
			lnALen = ALEN(toFoxCode.Items,1)
			IF !EMPTY(toFoxCode.Items[1])
				DIMENSION toFoxCode.Items[lnALen+1,2]
				lnALen = ALEN(toFoxCode.Items,1)
			ENDIF
			toFoxCode.Items[lnALen, 1] = lcWord	
		ENDFOR
		* Check for line continuation
		lHasLineContinuation = (RIGHT(lcWords,1) = ";")
	ENDFOR
	
ENDPROC
	Endtext

	Return lcCode
Endproc

