#Define ccVERSION Version 1.0, May. 17, 2012

#Define 	ccTool 					'Modify Class for PRG Classes'
#Define     ccEditClassName 		'clsVCD4PRG from Thor_Options_VCD4PRG.VCX'

#Define 	ccBeautifyKey			'Use BeautifyX'
#Define 	ccProcedureDividers		'Procedure Dividers'
#Define 	ccDividerLineIndicator	'Divider Line Indicator'
 
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

Local loVCD4PRG As 'VCD4PRG'
If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt	 = 'Modify Class for PRG-based classes' && used when tool appears in a menu
		.Summary = 'Modify Class for PRG-based classes; see home page for details'

		* Optional
		Text To .Description Noshow
Provides the ability to modify PRG-based custom classes using the Visual Class Designer (limited to classes that do not contain child objects).

This gives all the benefits of the Visual Class Designer (inheritance, Intellisense, having multiple code windows open simultaneously, etc) and the IDE Tools of Thor (GoToDefinition, ExtractToMethod, etc.)

When focus is in a code window for a PRG-based class, use this tool to create a temporary VCX from which all the methods and properties can be modified, added, etc.

When the focus is on the temporary VCX, use the tool again to write back to the PRG (which must still be open).

For a fuller discussion, see the tool home page.
		Endtext
		.StatusBarText = ''
		.CanRunAtStartup = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Source	  = 'Thor Repository' && where did this tool come from?  Your own initials, for instance
		.Category = 'Code|Miscellaneous' && and sub-categorization
		.Sort	  = 50 && the sort order for all items from the same Source, Category and Sub-Category

		* For public tools, such as PEM Editor, etc.
		.Version	   = [ccVERSION] && e.g., 'Version 7, May 18, 2011'
		.Author		   = ''
		.Link		   = 'http://vfpx.codeplex.com/wikipage?title=VCD4PRG'
		.OptionClasses = 'clsVCD4PRGBeautifyX, clsVCD4PRGProcDividers, clsVCD4PRGDividerLineIndicator'
		.OptionTool		  = ccTool
	Endwith

	Return lxParam1
Endif

loVCD4PRG = Createobject ('VCD4PRG')
loVCD4PRG.Run (lxParam1)

Return


****************************************************************
****************************************************************
* Normal processing for this tool begins here.

#Include FoxPro.h
#Define CR Chr(13)
#Define LF Chr(10)
#Define CRLF CR + LF
#Define ccTempFolder Addbs(Sys(2023)) + 'VCD4PRG\'
#Define cnMaxDescriptionWidth 72
#Define ccINLINECOMMENTS '&' + '&'


Define Class VCD4PRG As Custom

	cBeautifyOptions = ''
	oTools			 = .Null.
	oEditorWin		 = .Null.
	Dimension nBeautifyOptions(9)

	Procedure Init

		If Not Directory (ccTempFolder)
			Mkdir (ccTempFolder)
		Endif

		This.oTools		= Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')
		This.oEditorWin	= Execscript (_Screen.cThorDispatcher, 'class= editorwin from pemeditor')

	Endproc


	Procedure Run

		Lparameters lxParam1

		* Parameter passed in: ClassLibrary or ClassLibrary|Class
		Local laClassInfo[1], lcClass, lcPRGFile, lcWontop, lnType, loEditorWin

		If Not Empty (lxParam1)
			Alines (laClassInfo, lxParam1 + '|', 3, '|')
			lcPRGFile = laClassInfo[1]
			lcClass	  = laClassInfo[2]
			If Empty (lcClass)
				This.FindClassInPRG (lcPRGFile)
			Else
				This.ModifyClass (lcClass, lcPRGFile)
			Endif
			Return
		Endif

		loEditorWin = This.oEditorWin

		If loEditorWin.nHandle > 0
			lnType   = loEditorWin.GetEnvironment(25)
		Else
			lnType = 0
		Endif
		lcWontop = Wontop()

		Do Case
			Case Lower ('Class Designer') $ Lower (lcWontop)
				This.SaveClassToPRG()

			Case lnType = 10 && SCX/VCX code window
				This.SaveClassToPRG()

			Case lnType = 1 && PRG
				This.SavePRGtoClass (loEditorWin)

			Otherwise
				This.PromptForPRG()

		Endcase

	Endproc


	Procedure SavePRGtoClass (loEditorWin)
		Local lcCode, lcCurrentClass, lcCurrentMethod, lcJustFName, lcPre, lcTempPRG, llAnyClasses, lnHandle
		Local lnPosition, loPosition, loStartPositions
		lcCode	   = loEditorWin.GetString(0, 1000000)
		lnPosition = loEditorWin.GetSelStart()

		* Correction for CRs not followed by LFs ... these cause problems for RegExp
		If Occurs (CR, lcCode) > Occurs (CRLF, lcCode)
			lcPre	   = Left (lcCode, lnPosition)
			lnPosition = lnPosition + Occurs (CR, lcPre) - Occurs (CRLF, lcPre)
			lcCode	   = This.AddLineFeeds (lcCode)
		Endif

		loStartPositions = This.GetProcedureStartPositions (lcCode)
		llAnyClasses	 = .F.
		lcCurrentClass	 = ''
		lcCurrentMethod	 = ''

		For Each loPosition In loStartPositions FoxObject
			If loPosition.Type = 'Class'
				llAnyClasses = .T.
			Endif

			Do Case
				Case loPosition.StartByte > lnPosition

				Case loPosition.Type = 'Class'
					lcCurrentClass	= loPosition.Name
					lcCurrentMethod	= ''

				Case loPosition.Type = 'End'
					lcCurrentClass	= ''
					lcCurrentMethod	= ''

				Otherwise
					lcCurrentMethod = Justext (loPosition.Name)

			Endcase
		Endfor

		lcJustFName	= loEditorWin.GetEnvironment(1)
		lcTempPRG	= ccTempFolder + lcJustFName + '_' + Forceext (Sys(2015), 'PRG')
		Strtofile (lcCode, lcTempPRG)

		lnHandle = loEditorWin.nHandle
		Do Case
			Case Not Empty (lcCurrentMethod)
				This.ModifyClass (lcCurrentClass, lcTempPRG, lcCurrentMethod, lnHandle, lcJustFName)
			Case Not Empty (lcCurrentClass)
				This.ModifyClass (lcCurrentClass, lcTempPRG, '', lnHandle, lcJustFName)
			Case llAnyClasses
				This.FindClassInPRG (lcTempPRG, lnHandle, lcJustFName)
			Otherwise
				This.PromptForPRG()
		Endcase
	Endproc


	Procedure PromptForPRG
		Local lcPRGFile
		lcPRGFile = Getfile ('PRG')
		If Not Empty (lcPRGFile)
			This.FindClassInPRG (lcPRGFile)
		Endif
	Endproc


	Procedure FindClassInPRG
		Lparameters tcFile, tnHandle, tcJustFName
		Local loClasses As 'Collection'
		Local lcClass, lcFormFileName, loPosition, loStartPositions, loTools

		loStartPositions = This.GetProcedureStartPositions (Filetostr (tcFile))
		loClasses		 = Createobject ('Collection')

		For Each loPosition In loStartPositions FoxObject
			If loPosition.Type = 'Class'
				loClasses.Add (loPosition.Name)
			Endif
		Endfor

		If loClasses.Count # 0

			lcFormFileName = Execscript (_Screen.cThorDispatcher, 'Full Path=Thor_Tool_Repository_VCD4PRG.SCX')
			Do Form (lcFormFileName) With loClasses, tcFile To lcClass

			Do Case
				Case Isnull (lcClass)
					Return
				Case lcClass = 'OPEN-IN-CLASS-BROWSER'
					Do (_Browser) With tcFile
				Case Not Empty (lcClass)
					This.ModifyClass (lcClass, tcFile, '', tnHandle, tcJustFName)
				Case Empty (tnHandle)
					This.oTools.EditSourceX (tcFile)
			Endcase

		Else
			This.oTools.EditSourceX (tcFile)
		Endif && loClasses.Count # 0


	Endproc


	Procedure SaveClassToPRG
		Local loVCDtoPrg As 'VCDtoPRG'

		* First things first ... close add VCX code windows
		_oPEMEditor.oUtils.oIDEx.CloseAllHandles(10)

		loVCDtoPrg = Createobject ('VCDtoPRG')
		If loVCDtoPrg.Run()
			Do Case
				Case Not Empty (loVCDtoPrg.cHandle)
					If Not This.SaveToCodeWindow (loVCDtoPrg)
						This.SaveToNewPRG (loVCDtoPrg)
					Endif
				Case (Not Empty (loVCDtoPrg.cSourceFile)) And File (loVCDtoPrg.cSourceFile)
					If Not This.SaveToExistingPRG (loVCDtoPrg, loVCDtoPrg.cSourceFile)
						This.SaveToNewPRG (loVCDtoPrg)
					Endif
				Otherwise
					This.SaveToNewPRG (loVCDtoPrg)
			Endcase
		Endif
	Endproc


	Procedure SaveToCodeWindow (loVCDtoPrg)
		Local lcCode, lcNewCode, lnPosition, loEditorWin
		loEditorWin = This.oEditorWin
		loEditorWin.SetHandle (Val (loVCDtoPrg.cHandle))
		Try
			lnPosition = loEditorWin.GetSelStart()
		Catch
			lnPosition = -1
		Endtry

		If Vartype (lnPosition) = 'N' And lnPosition >= 0
			lcCode	  = This.AddLineFeeds (loEditorWin.GetString(0, 1000000))
			lcNewCode = This.ReplaceClassCode (loVCDtoPrg.cClass, lcCode, loVCDtoPrg.cDefineText)
			loEditorWin.Select(0, 1000000)
			loEditorWin.Paste (lcNewCode)
			loEditorWin.SetInsertionPoint (lnPosition)
		Else
			Return This.SaveToSourcePRG (loVCDtoPrg)
		Endif
	Endproc


	Procedure SaveToSourcePRG (loVCDtoPrg)
		* called when VCX was created from code window, and that code window has since been closed
		* so we must go a-hunting for the file that was being edited
		Local lcFName, lcFile, lnAnswer, lnI, loFile, loPRGs, loTools

		lcFile = loVCDtoPrg.GetSourceFile()
		If Not Empty (lcFile)
			This.SaveToExistingPRG (loVCDtoPrg, lcFile)
			Return .T.
		Endif

		lcFName	= loVCDtoPrg.cJustFName
		loPRGs	= This.oTools.GetMRUList ('PRG')
		If File (lcFName)
			loPRGs.Add (Fullpath (lcFName))
		Endif
		If _vfp.Projects.Count # 0
			For Each loFile In _vfp.ActiveProject.Files
				lcFile = loFile.Name
				If Lower (Justfname (lcFile)) == Lower (lcFName)
					loPRGs.Add (lcFile)
				Endif
			Endfor
		Endif && _VFP.Projects.Count # 0

		For lnI = 1 To loPRGs.Count
			lcFile = loPRGs[lnI]
			If Lower (Justfname (lcFile)) == Lower (lcFName)
				lnAnswer = Messagebox ('Post to ' + Sys(2014, lcFile, Curdir()) + '?', MB_YESNO + MB_ICONQUESTION)
				If lnAnswer = IDYES
					This.SaveToExistingPRG (loVCDtoPrg, lcFile)
					loVCDtoPrg.SaveSourceFile (lcFile)
					Return .T.
				Endif
			Endif
		Endfor && lnI = 1 to loPRGS.count
		Return .F.
	Endproc


	Procedure SaveToNewPRG (loVCDtoPrg)
		* somewhat misleading -- prompts for PRG name, which may be new or existing
		Local lcFile
		lcFile = Getfile ('PRG')
		Do Case
			Case Empty (lcFile)
				Return
			Case File (lcFile)
				This.SaveToExistingPRG (loVCDtoPrg, lcFile)
			Otherwise
				Strtofile ('', lcFile)
				This.SaveToExistingPRG (loVCDtoPrg, lcFile)
		Endcase
	Endproc


	Procedure SaveToExistingPRG (loVCDtoPrg, tcFileName)
		Local lcCode, lcFileName, lcNewCode, llFailed, lnBytes, loException

		If ' ' $ tcFileName
			lcFileName = ['] + tcFileName + [']
		Else
			lcFileName = tcFileName
		Endif

		lcCode				   = This.AddLineFeeds (Filetostr (tcFileName))
		loVCDtoPrg.cDefineText = This.AddLineFeeds(loVCDtoPrg.cDefineText)
		lcNewCode			   = This.ReplaceClassCode (loVCDtoPrg.cClass, lcCode, loVCDtoPrg.cDefineText)

		Try
			Erase (Forceext (tcFileName, 'BAK'))
			Rename (tcFileName) To (Forceext (tcFileName, 'BAK'))
			llFailed = .F.
		Catch To loException
			Messagebox ('Unable to create backup of  ' + Justfname (lcFileName) + CR + CR + 'File possibly in use', MB_OK + MB_ICONSTOP)
			llFailed = .T.
		Endtry

		If llFailed
			Return
		Endif

		Set Safety Off
		lnBytes = Strtofile (lcNewCode, tcFileName)

		If lnBytes = Len (lcNewCode)
			Messagebox (Justfname (lcFileName) + ' updated', MB_OK + MB_ICONINFORMATION)
		Else
			Messagebox ('Unable to update ' + Justfname (lcFileName) + CR + CR + 'File possibly in use', MB_OK + MB_ICONSTOP)
		Endif
	Endproc


	Procedure ReplaceClassCode (tcClass, tcCode, tcDefineText)
		Local lcNewPRGText, lnEnd, lnLength, lnStart, loBoundaries
		loBoundaries = This.GetClassBoundaries (tcClass, tcCode)

		Do Case
			Case 'O' = Vartype (loBoundaries)
				lnStart		 = loBoundaries.StartPosition + 1
				lnEnd		 = loBoundaries.EndPosition
				lnLength	 = 1 + lnEnd - lnStart
				lcNewPRGText = Stuff (tcCode, lnStart, lnLength, Trim (tcDefineText, CR, LF))
			Case Empty (tcCode)
				lcNewPRGText = tcDefineText
			Otherwise
				lcNewPRGText = Trim (tcCode, CR, LF) + CRLF + CRLF + CRLF + CRLF + tcDefineText
		Endcase
		Return lcNewPRGText
	Endproc


	* ===============================================================
	* ===============================================================


	Procedure ModifyClass
		Lparameters tcClassName, tcFileName, tcMethodName, tnHandle, tcJustFName

		Local lcFileName, loClassInfo, loTools

		lcFileName  = Forceext (tcFileName, 'PRG')

		loClassInfo = This.CreateVCX (tcClassName, tcFileName, tnHandle, tcJustFName)
		If 'O' = Vartype (loClassInfo)
			This.oTools.EditSourceX (loClassInfo.VCXFile, tcClassName, tcMethodName)
		Endif
	Endproc


	Procedure CreateVCX
		Lparameters tcClassName, tcFileName, tnHandle, tcJustFName

		Local loPRGToVcx As 'PrgToVcx' Of 'PRGtoVCX.PRG'
		Local loResult As 'Empty'
		Local lcBaseClass, lcClass, lcClassLoc, lcPRGText, lcTempPRG, lcTempVCX, lcUserInfo, lnEnd, lnLength
		Local lnStart, loBoundaries, loClassInfo, loParentInfo

		lcTempVCX	 = ccTempFolder + Justfname (tcFileName) + Forceext (Sys(2015), 'VCX')
		lcTempPRG	 = Forceext (lcTempVCX, 'PRG')
		lcPRGText	 = Filetostr (tcFileName)
		loBoundaries = This.GetClassBoundaries (tcClassName, lcPRGText)

		If 'O' = Vartype (loBoundaries)
			lnStart	 = loBoundaries.StartPosition + 1
			lnEnd	 = loBoundaries.EndPosition
			lnLength = 1 + lnEnd - lnStart
			Strtofile (Substr (lcPRGText, lnStart, lnLength), lcTempPRG)

			loPRGToVcx = Createobject ('PrgToVcx')
			loPRGToVcx.Convert (lcTempPRG, lcTempVCX, tcClassName, .T.)
			Erase (lcTempPRG)

			loParentInfo = This.GetParentInfo (loBoundaries.Text, lcPRGText, loPRGToVcx)
			If 'O' # Vartype (loParentInfo)
				Return .F.
			Endif
			lcClass	   = loParentInfo.Class
			lcClassLoc = loParentInfo.ClassLoc
			Do Case
				Case loParentInfo.lBaseClass
					lcBaseClass = lcClass
				Case Upper (Justext (lcClassLoc)) = 'VCX'
					lcBaseClass = loParentInfo.BaseClass
				Otherwise
					loClassInfo	= This.CreateVCX (lcClass, Evl (lcClassLoc, tcFileName)) && recursive
					lcBaseClass	= loClassInfo.BaseClass
					lcClassLoc	= loClassInfo.VCXFile
			Endcase

			If Empty (tnHandle)
				lcUserInfo = 'File = ' + Fullpath (tcFileName)
			Else
				lcUserInfo = 'Handle = ' + Transform (tnHandle) + CR + 'JustFName = ' +  tcJustFName
			Endif

			lcUserInfo = 'VCD4PRG' + CRLF		 ;
				+ lcUserInfo + CR				 ;
				+ 'Class = ' + tcClassName + CR	 ;
				+ 'Define = ' + loBoundaries.Text + CRLF

			Select 0
			Use (lcTempVCX)

			Goto 2
			Replace	BaseClass  With	 lcBaseClass  ;
					Class	   With	 lcClass	  ;
					ClassLoc   With	 lcClassLoc	  ;
					User	   With	 lcUserInfo + User + CRLF
			Use

			loResult = Createobject ('Empty')
			AddProperty (loResult, 'BaseClass', lcBaseClass)
			AddProperty (loResult, 'Class', lcClass)
			AddProperty (loResult, 'ClassLoc', lcClassLoc)
			AddProperty (loResult, 'VCXFile', Fullpath (lcTempVCX))
			Return loResult
		Else
			Return .F.
		Endif
	Endproc


	Procedure GetParentInfo
		Lparameters lcDefineText, lcPRGText, loPRGToVcx

		Local loResult As 'Empty'
		Local lcClass, lcClassLoc, llFound, lnSelect, loBoundaries, loClasses

		lcClass	 = Lower (Getwordnum (lcDefineText, 5))
		loResult = Createobject ('Empty')
		AddProperty (loResult, 'Class', lcClass)
		AddProperty (loResult, 'ClassLoc', '')
		AddProperty (loResult, 'lBaseClass', .F.)

		If ccINLINECOMMENTS $ lcDefineText
			lcDefineText = Trim (Left (lcDefineText, At (ccINLINECOMMENTS, lcDefineText) - 1))
		Endif

		If loPRGToVcx.IsBaseClass (loResult.Class)
			loResult.lBaseClass = .T.
			* attempt to create custom baseclass for baseclasses not able to be edited as VCXs
			If Inlist (loResult.Class, 'session', 'column', 'header', 'exception')
				loResult.Class = 'custom'
			Endif
			Return loResult
		Endif

		If Getwordcount (lcDefineText) < 7
			loBoundaries = This.GetClassBoundaries (lcClass, lcPRGText)
			llFound		 = Vartype (loBoundaries) = 'O'
			lcClassLoc	 = ''
		Else
			lcClassLoc = Getwordnum (lcDefineText, 7)
			Do Case
				Case Left (lcClassLoc, 1) $ ['"]
					lcClassLoc = Strextract (lcClassLoc, Left (lcClassLoc, 1), Left (lcClassLoc, 1), 1)
				Case Left (lcClassLoc, 1) = '['
					lcClassLoc = Strextract (lcClassLoc, '[', ']', 1)
			Endcase
			llFound = .F.
		Endif

		If Not llFound
			loClasses = This.oTools.GetClassList (lcClass, lcClassLoc, .T., .T.) && classlib and procs
			If 'O' # Vartype (loClasses)
				loClasses = This.oTools.GetClassList (lcClass, lcClassLoc, , , .T., .T.) && current project
				If 'O' # Vartype (loClasses)
					loClasses = This.oTools.GetClassList (lcClass, lcClassLoc, , , , , Curdir(), .T.) && current folder
				Endif
			Endif

			If 'O' = Vartype (loClasses)
				loResult.Class	  = Lower (Trim (loClasses.List[1]))
				loResult.ClassLoc = Lower (Trim (loClasses.List[2]))
			Else
				Messagebox ('Unable to find parent class ' + lcClass + Iif (Empty (lcClassLoc), '', '  of ' + lcClassLoc), MB_OK + MB_ICONSTOP)
				Return ''
			Endif
		Endif

		If Upper (Justext (loResult.ClassLoc)) = 'VCX'
			lnSelect = Select()
			Select 0
			Use (loResult.ClassLoc) Again Shared
			Locate For Lower (ObjName) == Lower (lcClass) And Reserved1 = 'Class' And Not Deleted()
			AddProperty (loResult, 'BaseClass', BaseClass)
			Use
			Select (lnSelect)
		Endif

		Return loResult
	Endproc


	Procedure GetClassBoundaries
		Lparameters lcClassName, lcPRGText

		Local loBoundaries As 'Empty'
		Local llFound, loPosition, loStartPositions

		loStartPositions = This.GetProcedureStartPositions (lcPRGText)

		loBoundaries = Createobject ('Empty')
		AddProperty (loBoundaries, 'StartPosition', 0)
		AddProperty (loBoundaries, 'EndPosition', 0)
		AddProperty (loBoundaries, 'Text', '')
		llFound = .F.

		For Each loPosition In loStartPositions FoxObject
			Do Case
				Case loPosition.Type = 'Class'	;
						And Lower (lcClassName) == Lower (loPosition.Name)
					loBoundaries.StartPosition = loPosition.StartByte
					loBoundaries.Text		   = loPosition.Text
					llFound					   = .T.
				Case llFound And loPosition.Type = 'End Class'
					loBoundaries.EndPosition = loPosition.StartByte + Len (loPosition.Text)
					Return loBoundaries
			Endcase
		Endfor

		Return llFound
	Endproc


	Procedure GetProcedureStartPositions
		* code directly from PEM Editor, modified as follows
		* (1)  Only selects DEFINE CLASS and ENDDEFINE
		* (2)  Returns new property, (.Text), the entire text of the line
		* (3)  Does better job of removing leading blank lines

		Lparameters tcCode

		Local loObject As 'Empty'
		Local loRegExp As 'VBScript.RegExp'
		Local loResult As 'Collection'
		Local lcClassName, lcMatch, lcName, lcPattern, lcType, lcWord1, llClassDef, llTextEndText, lnI
		Local lnOffset, lnStartByte, loException, loMatches

		* Returns a collection indicating the beginning of each procedure / class / etc
		* Each member in the collection has these properties:
		*   .Type == 'Procedure' (Procedures and Functions)
		*         == 'Class'     (Class Definition)
		*         == 'End Class' (End of Class Definition)
		*         == 'Method'    (Procedures and Functions within a class)
		*   .StartByte == starts at zero; thus, # of chars preceding start position
		*   .Name
		*   .ClassName
		*   .Text

		****************************************************************
		loRegExp = Createobject ('VBScript.RegExp')
		With loRegExp
			.IgnoreCase	= .T.
			.Global		= .T.
			.MultiLine	= .T.
		Endwith

		lcPattern = 'DEFI(|N|NE)\s+CLASS\s+\w+'
		lcPattern = lcPattern + '|' + 'ENDD(E|EF|EFI|EFIN|EFINE)'
		lcPattern = lcPattern + '|' + 'PROC(|E|ED|EDU|EDUR|EDURE)\s+(\w|\.)+'
		lcPattern = lcPattern + '|' + 'FUNC(|T|TI|TIO|TION)\s+(\w|\.)+'

		With loRegExp
			.Pattern	= '^\s*(' + lcPattern + ').*$'
		Endwith

		loMatches = loRegExp.Execute (tcCode)
		****************************************************************

		loResult = Createobject ('Collection')

		llClassDef	  = .F. && currently within a class?
		llTextEndText = .F. && currently within a Text/EndText block?
		lcClassName	  = ''

		For lnI = 1 To loMatches.Count

			With loMatches.Item (lnI - 1)
				lcMatch		= Trim (.Value, 1, CR, LF)
				* ignore leading blank lines
				lnOffset = Max (Rat (CR, lcMatch), Rat (LF, lcMatch))
				lcMatch	 = Substr (lcMatch, lnOffset + 1)

				lnStartByte	= .FirstIndex + lnOffset

				lcName	= Getwordnum (lcMatch, 3)
				lcWord1	= Upper (Getwordnum (lcMatch, 1))
			Endwith

			Do Case
				Case llTextEndText
					If 'ENDTEXT' = lcWord1
						llTextEndText = .F.
					Endif
					Loop

				Case llClassDef
					If 'ENDDEFINE' = lcWord1
						llClassDef	= .F.
						lcType		= 'End Class'
						lcName		= lcClassName + '.-EndDefine'
						lcClassName	= ''
					Else
						lcType = 'Method'
						lcName = lcClassName + '.' + Getwordnum (lcMatch, 2)
						If '(' $ lcName
							lcName = Left (lcName, At ('(', lcName) - 1)
						Endif
					Endif

				Case 'DEFINE' = lcWord1
					llClassDef	= .T.
					lcType		= 'Class'
					lcClassName	= lcName

				Otherwise
					lcType = 'Procedure'

			Endcase

			loObject = Createobject ('Empty')
			AddProperty (loObject, 'Type')
			AddProperty (loObject, 'StartByte')
			AddProperty (loObject, 'Name')
			AddProperty (loObject, 'ClassName')
			AddProperty (loObject, 'Text')

			With loObject
				.StartByte = lnStartByte
				.Type	   = lcType
				.Name	   = lcName
				.ClassName = lcClassName
				.Text	   = lcMatch
			Endwith

			Try
				loResult.Add (loObject, lcName + 'Byte' + Transform (lnStartByte))
			Catch To loException
				This.ShowErrorMsg (loException)
			Endtry


		Endfor

		Return loResult

	Endproc


	Procedure AddLineFeeds (tcText)
		Return Strtran (Strtran (tcText, LF, ''), CR, CRLF)
	Endproc



	*!* * Removed 08/16/2011 We will get to this later
	*!* Procedure Save
	*!* 	Local loX2PRG As 'X2PRG' Of 'VCX2PRG.PRG'
	*!* 	Local lcClassCode, lcNewPRGText, lcPRGText, lnEnd, lnLength, lnStart, loBoundaries
	*!* 	lcPRGText    = Filetostr (This.cPRGFileName)
	*!* 	loBoundaries = This.GetClassBoundaries (This.cClassName, lcPRGText)

	*!* 	If 'O' = Vartype (loBoundaries)
	*!* 		lnStart  = loBoundaries.StartPosition + 1
	*!* 		lnEnd    = loBoundaries.EndPosition
	*!* 		lnLength = 1 + lnEnd - lnStart

	*!* 		loX2PRG     = Newobject ('X2PRG', 'VCXtoPRG.PRG')
	*!* 		lcClassCode = loX2PRG.Convert (This.cVCXFileName, This.cClassName)
	*!* 		lcClassCode = loBoundaries.Text + Substr (lcClassCode, At (CR, lcClassCode))
	*!* 		lcClassCode = Trim (lcClassCode, CR, LF)

	*!* 		lcNewPRGText = Stuff (lcPRGText, lnStart, lnLength, lcClassCode)
	*!* 		Strtofile (lcNewPRGText, This.cPRGFileName, 0)
	*!* 		Return .T.
	*!* 	Else
	*!* 		Return .F.
	*!* 	Endif

	*!* Endproc

Enddefine




* Program: PrgToVcx.prg
* Classes: PrgToVcx
*   Bases: Based on Custom
*  Notice: The author releases all rights to the public domain
*        : subject to the Warranty Disclaimer below.
*  Author: Tom Rettig
*        : Rettig Micro Corporation
* Version: PrgToVcx Version 1.0 July 15, 1995 (#defined in True.h)
*        : This copy Enhanced in a few places by Dave Lehr, Soft Classics, Ltd.
*        :   Affected code sections marked with "DJL" in comments nearby.
*  Action: Convert program class library (PRG) to visual class library (VCX).
*   Usage: SET PROCEDURE TO PrgToVcx
*        : oPtoV = CREATEOBJECT("PrgToVcx")
*        : oPtoV.Convert([cPrgName.prg [, cVcxName.vcx]])
*Requires: Visual FoxPro for Windows version 3.0 or later
*        : True.h named constant file (#included below)
*   Notes: - May be freely used, modified, and distributed in
*        : compiled and/or source code form.
*        : - The author appreciates acknowledgment in commercial
*        : products and publications that use or learn from this class.
*        : - Technical support is not officially provided.  The
*        : author is very interested in hearing about problems
*        : or enhancement requests you have, and will try to be
*        : helpful within reasonable limits.  Email or fax preferred.
*        : - Warranty Disclaimer: NO WARRANTY!!!
*        : THE AUTHOR RELEASES TO THE PUBLIC DOMAIN ALL CLAIMS TO ANY
*        : RIGHTS IN THIS PROGRAM AND FREELY PROVIDES IT “AS IS” WITHOUT
*        : WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
*        : LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*        : FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL THE AUTHOR, OR ANY
*        : OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THIS PROGRAM, BE
*        : LIABLE FOR ANY COMMERCIAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
*        : DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM
*        : INCLUDING, BUT NOT LIMITED TO, LOSS OF DATA OR DATA BEING
*        : RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR LOSSES
*        : SUSTAINED BY THIRD PARTIES OR A FAILURE OF THE PROGRAM TO
*        : OPERATE WITH ANY OTHER PROGRAMS, EVEN IF YOU OR OTHER PARTIES
*        : HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

* ADDITIONAL NOTES:
* All subclasses and Parent classes (super classes) must be in
*    the same program file
* All #DEFINEs must be in the #INCLUDE file, any in program are ignored.
* Use *>* (defined in True.h) to add property and method descriptions.
* Use *>> in method body to add description for the method
* Properties and methods cannot have the same name.
* Array initializations in the class body are moved to the Init event.
*    In forms and formsets, they are moved to the Load event.
* STORE ... TO in the class body is ignored.
*    Use <property> = <value> instead.
*
* VCX contents:
*    Protected lowercase list ?must be sorted?
*       In the case of an ADD OBJECT record, optionally contains
*       uppercase TRUE.
*    Properties Height and Width are first, Name is last, everything else
*       is in between.
*    Reserved1 = "Class"   && ///always? even on sub or contained classes?
*    Reserved2 = "1"       && number of objects in container
*    Reserved3 is a list of protected and exposed property and method names.
*      Lowercase name with * prefix if a method.
*      Optional 255 char description follows name.
*      Properties must be first, arrays and methods can be mixed.
*      Array dimensions must be stripped of spaces and one dimensional
*         arrays are shown as aName[1,0], an illegal DELCARE value.
*      Formats:
*         newproperty[<space><description>]<crlf>
*         ^newpropertyarray<dimensions>[<space><description>]<crlf>
*         *newmethod[<space><description>]<crlf>
*    Reserved4 is the icon name (always empty in custom classes)
*    Reserved5 is class browser icon (always empty in custom classes?)
*    Reserved6 = "Pixels"  && Pixels or Foxels (proper)
*    Reserved7 = PROGRAM() + " converted from " +  ;
*                lcLibProgram + ", " + TTOC(DATETIME())  && 255 char max
*    Reserved8 is the #INCLUDE file  && lowercase, relative path to vcx
*       In the case of an ADD OBJECT record, Reserved8 optionally
*       contains uppercase NOINIT.
*    User contains the program library's comment header

#Include Thor_Tool_Repository_VCD4PRG.h


*!*	*-- Class Browser Import add-in.  Contributed by Ken Levy.
*!*	*   Execute the following line in the Command Window while the
*!*	*   Class Browser is active to install PrgToVcx.prg as an add-in:
*!*	*     _oBrowser.AddIn("PrgToVcx", "PrgToVcx")
*!*	LPARAMETERS oSource
*!*	LOCAL oPrgToVcx, lcClass

*!*	IF NOT TYPE("oSource") == "O"
*!*	   RETURN .F.  && early exit
*!*	ENDIF
*!*	oPrgToVcx = CREATEOBJECT("PrgToVcx")

*!*	*-- Set class filter.
*!*	lcClass = oSource.cClass
*!*	IF "." $ lcClass
*!*	   lcClass = ""
*!*	ENDIF

*!*	IF NOT oPrgToVcx.Convert( , oSource.cFileName, lcClass)
*!*	   RETURN .F.  && early exit
*!*	ENDIF

*!*	*-- Refresh Class Browser.
*!*	oSource.RefreshClassList()
*!*	oSource.RefreshMembers()
*!*	RETURN
*!*	*-- End Class Browser Import add-in


Define Class PrgToVcx As Session

	cCommentBlock = ''
	oTools		  = .Null.
	lBeautifyX	  = .F.

	Procedure Convert (tcLibProgram, tcLibVisual, tcClass, tlCompile)
		Local laMembers[1], lcAdditionalIndent, lcAlias, lcArray, lcBaseClass, lcClass, lcClasslib
		Local lcCommentBlock, lcDesc, lcDescrip, lcDescription, lcHeader, lcInclude, lcIndent, lcInit
		Local lcLibProgram, lcLibVisual, lcMD, lcMemberData, lcName, lcNextString, lcPEMList, lcPlatform
		Local lcProperty, lcSourceString, lcString, lcTemp, lcValue, lcVcx, llBuiltin, llClass, llExact
		Local llHandled, llHeader, llInclude, llProtect, llTalk, lnBreak, lnCounter, lnCounter2, lnHandle
		Local lnHashIFLevel, lnParen, lnPos, lnPosition, lnRecno, lnSelect, lnTabSpaces
		Set Exact Off    && DJL
		llHeader = .T.   && until 1st class is found
		Store '' To lcHeader, lcClass, lcInclude
		lcLibProgram = Iif (Empty (tcLibProgram),  ;
			  Getfile ('prg'),					   ;
			  Alltrim (tcLibProgram) +			   ;
			  Iif ('.' $ tcLibProgram, '', '.prg'))
		If Empty (lcLibProgram)
			Return .F.    && early exit
		Endif
		lcLibVisual = Iif (Empty (tcLibVisual),						 ;
			  Left (lcLibProgram, Rat ('.', lcLibProgram)) + 'vcx',	 ;
			  Alltrim (tcLibVisual) + Iif ('.' $ tcLibVisual, '', '.vcx'))
		lnSelect = Select()

		Do Case
			Case _Windows
				lcPlatform = 'WINDOWS'
			Case _Mac
				lcPlatform = 'MAC'
			Case _Dos
				lcPlatform = 'DOS'
			Case _Unix
				lcPlatform = 'UNIX'
		Endcase

		lnHandle = Fopen (lcLibProgram)
		If lnHandle < 1
			Error 'Opening ' + Sys (cnVF_SYS_CROSSPATH, lcLibProgram)
			Return .F.  && early exit
		Endif

		* Only create VCX if it doesn't exist, otherwise we'll just
		* add into the existing VCX and delete the existing same class
		* record if any.
		If Not File (lcLibVisual)
			Create Classlib (lcLibVisual)
		Endif
		If Not File (lcLibVisual)
			Error cnVF_ERR_FILE_NOTEXIST,  ;
				Sys (cnVF_SYS_CROSSPATH, lcLibVisual)
			= Fclose (lnHandle)
			Return .F.  && early exit
		Endif

		lcVcx = Sys (cnVF_SYS_UNIQUEID)
		Select 0
		Use (lcLibVisual) Again Alias (lcVcx)
		If Not Used (lcVcx)  && may be exclusive or not
			Error 'Opening ' + Sys (cnVF_SYS_CROSSPATH, lcLibVisual)
			= Fclose (lnHandle)
			Select (lnSelect)
			Return .F.  && early exit
		Endif

		* No more early exits after here.
		* Set Message TO "Reading " + SYS(cnVF_SYS_CROSSPATH, lcLibProgram)

		* Temporary cursors.
		Select 0
		lcDescrip = Sys (cnVF_SYS_UNIQUEID)
		Create Cursor (lcDescrip)  ;
			(cClass     C(64),	   ;
			  mName      M,		   ;
			  mDescrip   M)
		Select 0
		lcAlias = Sys (cnVF_SYS_UNIQUEID)
		Create Cursor (lcAlias)	 ;
			(cClass     C(64),	 ;
			  cMember    C(10),	 ;
			  lProtect   L,		 ;
			  lBase      L,		 ;
			  mName      M,		 ;
			  mValue     M,		 ;
			  mArray     M,		 ;
			  mInit      M,		 ;
			  mClasslib  M,		 ;
			  mDescrip   M)
		*!* * Removed 8/30/2011
		*!* Index On Lower (cClass + cMember + Padr (Iif (cMember # 'Method', mName, ''), 128)) Tag PrimaryKey
		Index On Lower (cClass + cMember + Padr (mName, 128)) Tag PrimaryKey
		* Member can be "Property", "Method", "Class", or "Object"
		lcPEMList = ' '

		* Read prg strings into cursor.
		lnTabSpaces	   = This.nTabSpaces
		lcCommentBlock = ''
		
		Local loThor, lcDividerLineIndicator 
		loThor = Execscript(_Screen.cThorDispatcher, 'Thor Engine=')
		lcDividerLineIndicator = Textmerge(loThor.GetOption (ccDividerLineIndicator, ccTool))

		Do While Not Feof (lnHandle)
			llHandled = .T.
			* New line is obtained at bottom of loop or within CASEs.
			Do Case
					* Program header.
				Case llHeader  && shuts off after #INCLUDE or DEFINE CLASS
					lcString = Strtran (Fgets (lnHandle),  ;
						  ccTAB, Space (lnTabSpaces))
					* Only one allowed.  Ignores any after the first.
					Do While Upper (Left (Ltrim (lcString), 5)) # '#INCL' And ;
							Not (Upper (Left (Ltrim (lcString), 4)) == 'DEFI' And ;
							  Upper (Left (Ltrim (Substr (Ltrim (lcString), ;
									  At (' ', Ltrim (lcString)))),		;
								  4)) == 'CLAS')
						If Feof (lnHandle)
							Messagebox ('File contains no class definitions', 16, 'PrgToVcx')
							Exit
						Endif
						lcHeader = lcHeader + lcString + ccCRLF
						lcString = Strtran (Fgets (lnHandle),  ;
							  ccTAB, Space (lnTabSpaces))
					Enddo
					llHeader = .F.
					Loop  && don't get a new string below

					*!* * Removed 8/30/2011
					*!* * #INCLUDE file.
					*!* 				Case (Not llInclude) And Upper (Left (Ltrim (lcString), 5)) == '#INCL'
					*!* * Only one allowed.  Ignores any after the first.
					*!* llInclude = .T.
					*!* lcInclude = Trim (Substr (lcString, Rat (' ', lcString) + 1))
					*!* If Left (lcInclude, 1) $ [",',] + '['   && remove quotes if any
					*!* 	lcInclude = Substr (lcInclude, 2, Len (lcInclude) - 2)
					*!* Endif

					* DEFINE CLASS.
				Case Upper (Left (Ltrim (lcString), 4)) == 'DEFI' And  ;
						Upper (Left (Ltrim (Substr (Ltrim (lcString),  ;
								At (' ', Ltrim (lcString)))),		   ;
							4)) == 'CLAS'  && CLASS
					llClass		  = .T.
					lnHashIFLevel = 0

					* Remove semicolons.
					Do While Right (Trim (lcString), 1) == ';'
						lcString = Left (Trim (lcString), Len (Trim (lcString)) - 1) + ;
							' ' + Ltrim (Strtran (Fgets (lnHandle),		;
								ccTAB, Space (lnTabSpaces)))
					Enddo

					* Name.
					lcClass = Ltrim (Substr (Ltrim (lcString),	;
							At (' ', Ltrim (lcString))))
					lcClass	= Ltrim (Substr (lcClass, At (' ', lcClass)))
					lcClass	= Trim (Left (lcClass, At (' ', lcClass)))
					lcClass	= This.cDefined (@lcClass)

					* Check for parent class other than VFP base classes.
					* Will break if class name is "AS" because there's no RATC().
					Store '' To lcBaseClass, lcClasslib
					lcName = Alltrim (Substr (lcString, Atc (' AS ', lcString) + 4))
					If ' ' $ lcName
						lcName = Trim (Left (lcName, At (' ', lcName)))
					Endif

					* The &&>> after a "DEFINE CLASS name AS parent" specifies the parent Classib>>Baseclass
					If '&' + '&>>' $ lcName
						lcClasslib = Trim (Substr (lcName, At ('&' + '&>>', lcName) + 4))
						lcName	   = Trim (Left (lcName, At ('&' + '&>>', lcName) - 1))
						If '>>' $ lcClasslib
							lcBaseClass	= Trim (Substr (lcClasslib, At ('>>', lcClasslib) + 2))
							lcClasslib	= Trim (Left (lcClasslib, At ('>>', lcClasslib) - 1))
						Else
							Store '' To lcBaseClass, lcClasslib
						Endif
					Endif
					If ccINLINECOMMENTS $ lcName
						lcName = Trim (Left (lcName, At (ccINLINECOMMENTS, lcName) - 1))
					Endif
					lcName = This.cDefined (@lcName)

					* Check for specific class.
					If Empty (tcClass) Or  ;
							Lower (Alltrim (tcClass)) == Lower (Alltrim (lcName))
						* Write.
						llExact = Set ('EXACT') == 'ON'
						Set Exact On  && for ASCAN()
						Insert Into (lcAlias)							;
							(cClass,  cMember,  mName,  mValue,			;
							  lBase, mClasslib, mDescrip)				;
							Values (lcClass, 'Class',  lcName, Iif (Empty (lcBaseClass), lcName, lcBaseClass), ;
							  Not Empty (lcClasslib) Or Ascan (This.aBaseClass, Lower (lcName)) > 0, ;
							  lcClasslib,								;
							  Program() + ' converted from ' +			;
							  Sys (cnVF_SYS_CROSSPATH, lcLibProgram) + ', ' + ;
							  Ttoc (Datetime()) )
						If Not llExact
							Set Exact Off
						Endif
					Endif  && specific class to import

					* ENDDEFINE.
				Case llClass And Upper (Left (Ltrim (lcString), 9)) == '#ENDDEFINE'
					llClass = .F.

					* #IF
				Case llClass And Upper (Left (Ltrim (lcString), 3)) == '#IF'
					lnHashIFLevel = lnHashIFLevel + 1
					llHandled	  = .F.

					* #ENDIF
				Case llClass And Upper (Left (Ltrim (lcString), 4)) == '#END'
					lnHashIFLevel = lnHashIFLevel - 1
					llHandled	  = .F.

					* Between #IF / #ENDIF
				Case llClass And lnHashIFLevel > 0
					llHandled = .F.

					* PROCEDURE or FUNCTION, exposed or PROTECTED.
				Case llClass And										;
						(Inlist (Upper (Left (Ltrim (lcString), 4)), 'PROC', 'FUNC') Or ;
						  (Upper (Left (Ltrim (lcString), 4)) == 'PROT' And ;
							Inlist (Upper (Left (Ltrim (Substr (Ltrim (lcString), ;
									  At (' ', Ltrim (lcString)))),		;
								  4)),									;
							  'PROC', 'FUNC')))


					* Remove semicolons.
					Do While Right (Trim (lcString), 1) == ';'
						lcString = Left (Trim (lcString), Len (Trim (lcString)) - 1) + ;
							' ' + Ltrim (Strtran (Fgets (lnHandle),		;
								ccTAB, Space (lnTabSpaces)))
					Enddo

					* DJL - Indentation level
					lcIndent = Left (lcSourceString, Len (lcSourceString) - Len (Ltrim (lcSourceString, ' ', ccTAB)))

					* Name.
					llProtect = Upper (Left (Ltrim (lcString), 4)) == 'PROT'
					If llProtect
						lcName = Alltrim (Substr (Ltrim (lcString),	 ;
								At (' ', Ltrim (lcString))))
						lcName = Alltrim (Substr (lcName, At (' ', lcName)))
					Else
						lcName = Alltrim (Substr (Ltrim (lcString),	 ;
								At (' ', Ltrim (lcString))))
					Endif
					lcValue = ''
					If '(' $ lcName
						If Not '()' $ lcName
							lcValue = 'LPARAMETERS ' + Substr (lcName,	;
								  At ('(', lcName) + 1,					;
								  At (')', lcName) -					;
								  At ('(', lcName) - 1) + ccCRLF
						Endif
						lcName = Left (lcName, At ('(', lcName) - 1)
					Endif
					* Set Message TO "Reading " + lcClass + " " + lcName

					lcAdditionalIndent = .F.

					* Value.
					Do While .T.
						lcSourceString = Fgets (lnHandle)
						lcString = Strtran (lcSourceString,	 ;
							  ccTAB, Space (lnTabSpaces))
						If Inlist (Upper (Left (Ltrim (lcString), 7)),	;
								  'ENDPROC', 'ENDFUNC') Or				;
								Upper (Left (Ltrim (lcString), 9)) == 'ENDDEFINE' Or ;
								Inlist (Upper (Left (Ltrim (lcString), 4)), ;
								  'PROC', 'FUNC') Or					;
								(Upper (Left (Ltrim (lcString), 4)) == 'PROT' And ;
								  Inlist (Upper (Left (Ltrim (Substr (Ltrim (lcString), ;
											At (' ', Ltrim (lcString)))), 4)), ;
									'PROC', 'FUNC'))
							Exit
						Else
							*!* * Removed 8/30/2011
							*!* * DJL - If it is a Method description, add to description file.
							*!* If Left (Ltrim (lcString), 3) == '*>>'
							*!* 	Insert Into (lcDescrip)			 ;
							*!* 		(cClass,  mName,  mDescrip)	 ;
							*!* 		Values (lcClass, lcName, Left (Ltrim (Substr (Ltrim (lcString), 4)), 255))
							*!* Endif

							lcString = lcSourceString
							* Add line to method code body, un-indented to level of ititial PROCEDURE or FUNC keyword
							If Left (lcString, Len (lcIndent)) == lcIndent
								lcString = Substr (lcString, Len (lcIndent) + 1)
							Endif

							* additional un-indentation, corresponding to first non-empty line encountered
							Do Case
								Case Empty (lcString)
								Case 'L' = Vartype (lcAdditionalIndent)
									lcAdditionalIndent = Left (lcString, Len (lcString) - Len (Ltrim (lcString, ' ', ccTAB)) )
									lcString		   = Substr (lcString, Len (lcAdditionalIndent) + 1)
								Case Left (lcString, Len (lcAdditionalIndent)) == lcAdditionalIndent
									lcString = Substr (lcString, Len (lcAdditionalIndent) + 1)
							Endcase
							lcValue = lcValue + lcString + ccCRLF

						Endif
					Enddo

					* Write.
					lcPEMList = lcPEMList + lcName + ' '
					Insert Into (lcAlias)							   ;
						(cClass,  cMember,  mName,  mValue, lProtect)  ;
						Values (lcClass, 'Method', lcName, Substr (lcCommentBlock + CR, 2) + lcValue, llProtect)
					lcCommentBlock = ''

					* Keep current line unless ENDPROC/ENDFUNC.
					If Not Inlist (Upper (Left (Ltrim (lcString), 7)),	;
							  'ENDPROC', 'ENDFUNC')
						Loop
					Endif

					* Property declarations, exposed/protected array property
					* or protected variable property.
				Case llClass And  ;
						Upper (Left (Ltrim (lcString), 4)) $ 'PROT,DECL,DIME'

					* Set Message TO "Reading " + lcClass + " " + "Property list"
					llProtect = Upper (Left (Ltrim (lcString), 4)) == 'PROT'

					* Remove semicolons.
					lcString = Substr (Ltrim (lcString), At (' ', Ltrim (lcString)) + 1)
					Do While Right (Trim (lcString), 1) == ';'
						lcString = Left (Trim (lcString), Len (Trim (lcString)) - 1) + ;
							' ' + Ltrim (Strtran (Fgets (lnHandle),		;
								ccTAB, Space (lnTabSpaces)))
					Enddo

					Do While .T.
						lcArray = ''
						* Name.
						Do Case
							Case Empty (lcString)
								Exit
							Case Not ',' $ lcString
								Do Case
									Case '[' $ lcString
										lcName	= Left (  lcString, At ('[', lcString) - 1)
										lcArray	= Substr (lcString, At ('[', lcString))
									Case '(' $ lcString
										lcName	= Left (  lcString, At ('(', lcString) - 1)
										lcArray	= Substr (lcString, At ('(', lcString))
									Otherwise
										lcName  = Alltrim (lcString)
								Endcase
								lnPosition = Len (lcString)
							Case At ('[', lcString) > 0 And	 ;
									At ('[', lcString) < At (',', lcString)
								lcName	   = Left (  lcString, At ('[', lcString) - 1)
								lcArray	   = Substr (lcString, At ('[', lcString))
								lcArray	   = Left (lcArray, At (']', lcArray))
								lnPosition = At (']', lcString)
							Case At ('(', lcString) > 0 And	 ;
									At ('(', lcString) < At (',', lcString)
								lcName	   = Left (lcString, At ('(', lcString) - 1)
								lcArray	   = Substr (lcString, At ('(', lcString))
								lcArray	   = Left (lcArray, At (')', lcArray))
								lnPosition = At (')', lcString)
							Otherwise
								lcName	   = Ltrim (Left (lcString, At (',', lcString) - 1))
								lnPosition = At (',', lcString)
						Endcase

						* Remove inline comments.

						If Empty (lcCommentBlock)
							lcDescription = ''
						Else
							lnBreak		   = Rat (CR, lcCommentBlock)
							lcDescription  = Alltrim (Substr (lcCommentBlock, lnBreak + 1), 1, ' ', ccTAB)
							lcCommentBlock = Left (lcCommentBlock, lnBreak - 1)
							Do Case
								Case lcDescription = '*'
									lcDescription = Rtrim (Substr (lcDescription, 2))
								Case lcDescription = ccINLINECOMMENTS
									lcDescription = Rtrim (Substr (lcDescription, 3))
							Endcase
						Endif

						If ccINLINECOMMENTS $ lcName
							lnBreak		  = At (ccINLINECOMMENTS, lcName)
							lcDescription = lcDescription + ' ' + Substr (lcName, lnBreak + 2)
							lcName		  = Trim (Left (lcName, lnBreak - 1))
						Endif
						If ccINLINECOMMENTS $ lcArray
							lnBreak		  = At (ccINLINECOMMENTS, lcArray)
							lcDescription = lcDescription + ' ' + Substr (lcArray, lnBreak + 2)
							lcArray		  = Trim (Left (lcArray, lnBreak - 1))
						Endif

						* Remove spaces and substitute defined array dimensions.
						If Not Empty (lcArray)
							lcArray	= Strtran (lcArray, ' ')
							lcArray	= This.cDefined (@lcArray)
							lcArray	= Chrtran (lcArray, '()', '[]') && jrn 08-13-2011
						Endif

						* Write.
						lcPEMList = lcPEMList + lcName + ' '
						Insert Into (lcAlias)					  ;
							(cClass,  cMember,    mName,		  ;
							  lProtect,  mArray, mDescrip)		  ;
							Values (lcClass, 'Property', lcName,  ;
							  llProtect, lcArray, lcDescription)

						* Parse string.
						lcString = Iif (Len (lcString) == lnPosition,  ;
							  '',									   ;
							  Alltrim (Substr (lcString, lnPosition + 1)))
						If Left (lcString, 1) == ','
							lcString = Ltrim (Substr (lcString, 2))
						Endif
					Enddo  && WHILE .T. with EXIT

					* Property initializations, including arrays.
				Case llClass And									   ;
						'=' $ lcString And							   ;
						(Between (Lower (Left (Ltrim (lcString), 1)),  ;
							'a', 'z') Or							   ;
						  Inlist (Left (Ltrim (lcString), 1),		   ;
							'_'))

					* Remove semicolons.
					Do While Right (Trim (lcString), 1) == ';'
						lcString = Left (Trim (lcString), Len (Trim (lcString)) - 1) + ;
							' ' + Ltrim (Strtran (Fgets (lnHandle),		;
								ccTAB, Space (lnTabSpaces)))
					Enddo

					* Name and value.
					lnPosition = At ('=', lcString)
					lcName	   = Alltrim (Left (lcString, lnPosition - 1))
					* Set Message TO "Reading " + lcClass + " " + lcName
					If '[' $ lcName Or '(' $ lcName  && array element, move to init
						If Seek (Lower (Padr (lcClass,    Fsize ('cClass')) + ;
									Padr ('Property', Fsize ('cMember')) + ;
									Padr ( Left (lcName, At ('[', Chrtran (lcName, 'x', 'y')) - 1), 128)), ;
								  Alias(), 'PrimaryKey')
							Replace mInit								;
									  With 'THIS.' + Alltrim (lcString) + ccCRLF ;
									  Additive
						Endif  && ignore if not previously declared an array
					Else  && property (may be whole array name)
						lcValue = Alltrim (Substr (lcString, lnPosition + 1))

						If Empty (lcCommentBlock)
							lcDescription = ''
						Else
							lnBreak		  = Rat (CR, lcCommentBlock)
							lcDescription = Alltrim (Substr (lcCommentBlock, lnBreak + 1), 1, ' ', ccTAB)
							If lcDescription = '*'
								lcDescription = Alltrim (Substr (lcDescription, 2), ' ', ccTAB)
							Endif
							lcCommentBlock = Left (lcCommentBlock, lnBreak - 1)
							Do While Right (lcCommentBlock, 1) = ';'
								lnBreak	= Rat (CR, lcCommentBlock)
								lcDesc	= Substr (lcCommentBlock, lnBreak + 1)
								lcDesc	= Alltrim (Substr (lcDesc, 1, Len (lcDesc) - 1), 1, ' ', ccTAB)
								If lcDesc = '*'
									lcDesc = Alltrim (Substr (lcDesc, 2), ' ', ccTAB)
								Endif
								lcDescription  = lcDesc + ' ' + lcDescription
								lcCommentBlock = Left (lcCommentBlock, lnBreak - 1)
							Enddo
						Endif

						If ccINLINECOMMENTS $ lcValue  && remove inline comments
							lnBreak		  = At (ccINLINECOMMENTS, lcValue)
							lcDescription = lcDescription + ' ' + Alltrim (Substr (lcValue, lnBreak + 2))
							lcValue		  = Trim (Left (lcValue, lnBreak - 1))
						Endif

						If Seek (Lower (Padr (lcClass,    Fsize ('cClass')) + ;
									Padr ('Property', Fsize ('cMember')) + ;
									Padr (lcName,     128)),			;
								  Alias(), 'PrimaryKey')
							If Empty (mArray)  && protected property
								Replace mValue With lcValue
							Else   && array, so move to init method
								Replace mInit							;
										  With 'THIS.' + Alltrim (lcString) + ccCRLF ;
										  Additive
							Endif
						Else  && new, so not an array or protected property
							If Lower (lcName) # '_memberdata'
								lcPEMList = lcPEMList + lcName + ' '
								Insert Into (lcAlias)					;
									(cClass,  cMember,    mName,		;
									  mValue, lProtect, mDescrip)		;
									Values (lcClass, 'Property', lcName, ;
									  lcValue, .F., lcDescription)
							Endif
						Endif
					Endif  && not an array element

					*ADD OBJECT.
				Case llClass And										;
						Upper (Left (Ltrim (lcString), 4)) == 'ADD ' And ;
						Upper (Left (Ltrim (Substr (Ltrim (lcString),	;
								At (' ', Ltrim (lcString)))),			;
							4)) == 'OBJE'

					* Remove semicolons.
					Do While Right (Trim (lcString), 1) == ';'
						lcString = Left (Trim (lcString), Len (Trim (lcString)) - 1) + ;
							' ' + Ltrim (Strtran (Fgets (lnHandle),		;
								ccTAB, Space (lnTabSpaces)))
					Enddo

					lnPosition = Atc (' AS ', lcString)
					lcName	   = Alltrim (Left (lcString, lnPosition))
					If ' ' $ lcName
						lcName = Ltrim (Substr (lcName, Rat (' ', lcName)))
					Endif
					* Set Message TO "Reading " + lcClass + " " + lcName
					lcValue = Alltrim (Substr (lcString, lnPosition + 4))
					If ' ' $ lcValue
						lcValue = Trim (Left (lcValue, At (' ', lcValue)))
					Endif
					* Remove inline comments.
					If ccINLINECOMMENTS $ lcValue
						lcValue = Trim (Left (lcValue, At (ccINLINECOMMENTS, lcValue) - 1))
					Endif
					lcArray	   = ''
					lnPosition = Atc (' WITH ', lcString)
					If lnPosition > 0
						lcArray = Alltrim (Substr (lcString, lnPosition + 6))
						* Remove inline comments.
						If ccINLINECOMMENTS $ lcArray
							lcArray = Trim (Left (lcArray, At (ccINLINECOMMENTS, lcArray) - 1))
						Endif

						* Replace commas with ccCRLF unless they are within
						* parens as in some functions like RGB(0,0,0).
						Store 0 To lnCounter2, lnParen
						For lnCounter = 1 To Len (lcArray)
							lcTemp = Substr (lcArray, lnCounter, 1)
							Do Case
								Case lcTemp == '('
									lnParen = lnParen + 1
								Case lcTemp == ')'
									lnParen = Max(0, lnParen - 1)
								Case lcTemp == ',' And lnParen == 0
									lcArray = Stuff (lcArray, lnCounter, ;
										  1, ccCRLF)
									lnCounter2 = lnCounter2 + 1
							Endcase
						Endfor
						lcArray	   = lcArray + ccCRLF
						lnCounter2 = lnCounter2 + 1

						* Get rid of spaces around CRLFs and = signs.
						Do While ' ' + ccCRLF $ lcArray
							lcArray = Strtran (lcArray, ' ' + ccCRLF, ccCRLF)
						Enddo
						Do While ccCRLF + ' ' $ lcArray
							lcArray = Strtran (lcArray, ccCRLF + ' ', ccCRLF)
						Enddo
						Do While '  =' $ lcArray
							lcArray = Strtran (lcArray, '  =', ' =')
						Enddo
						Do While '=  ' $ lcArray
							lcArray = Strtran (lcArray, '=  ', '= ')
						Enddo

						* Now go back through and put parens around function
						* values unless it already has them.
						For lnCounter = 1 To lnCounter2
							lnPosition = At (ccCRLF, lcArray, lnCounter)
							If Right (Left (lcArray, lnPosition - 1), 1) == ','
								lnPosition = lnPosition - 1
							Endif
							If Right (Left (lcArray, lnPosition - 1), 1) == ')'
								lnParen = Rat (' = ', Left (lcArray, lnPosition - 1))
								If Not Left (Substr (lcArray, lnParen + 3), 1) == '('
									lcArray	= Stuff (lcArray, lnPosition - 1, 0, ')')
									lcArray	= Stuff (lcArray, lnParen + 3, 0, '(')
								Endif
							Endif
						Endfor
					Endif  && WITH string

					Insert Into (lcAlias)								;
						(cClass,   cMember, mName,  mValue,				;
						  lProtect,										;
						  mInit,										;
						  mArray)										;
						Values (lcClass, 'Object', lcName, lcValue,		;
						  Atc (' PROTECTED ', lcString) > 0,			;
						  Iif (Atc (' NOINIT', lcString) == 0, '', 'NOINIT'), ;
						  lcArray)

				Case llClass And At ('*>ToolbarIcon=', Ltrim (lcString)) = 1    && DJL - added icon spec
					Insert Into (lcAlias)			  ;
						(cClass,   cMember,  mValue)  ;
						Values (lcClass, 'ClassIcon', Alltrim (Substr (lcString, 15)))

				Case llClass And At ('*>BrowserIcon=', Ltrim (lcString)) = 1    && DJL - added icon spec
					Insert Into (lcAlias)			  ;
						(cClass,   cMember,  mValue)  ;
						Values (lcClass, 'ClassIcon2', Alltrim (Substr (lcString, 15)))

				Otherwise
					llHandled = .F.
			Endcase

			Do Case
				Case llHandled And Empty (lcCommentBlock)

				Case llHandled
					This.SaveCommentBlock (lcCommentBlock)
					lcCommentBlock = ''

				* ignore if the string matches the divider indicator between Procs
				Case LTrim(lcString) = lcDividerLineIndicator
				
				Case Left (Ltrim (lcString), 1) = '*' Or Left (Ltrim (lcString), 2) = ccINLINECOMMENTS
					lcCommentBlock = lcCommentBlock + CR + lcSourceString

				Case Empty (lcCommentBlock) And Empty (lcSourceString)

				Otherwise
					lcCommentBlock = lcCommentBlock + CR + lcSourceString
					This.SaveCommentBlock (lcCommentBlock)
					lcCommentBlock = ''

			Endcase

			* Get next string.
			lcSourceString = Fgets (lnHandle)
			lcString = Strtran (lcSourceString,	 ;
				  ccTAB, Space (lnTabSpaces))
		Enddo
		= Fclose (lnHandle)  && done reading the prg, all data is in lcAlias

		*******************************************************

		* Resolve BaseClass issues.
		* Set Message TO "Resolving base classes in "+	;
		SYS(cnVF_SYS_CROSSPATH, lcLibVisual)
		Index On Lower (cClass + cMember) Tag BaseKey

		Scan For cMember == Padr ('Class', Fsize ('cMember'))
			If Not lBase
				lnRecno	= Recno()
				lcValue	= ''
				* Search until we get to a base class.
				Do While Seek (Lower (Padr (mName,   Fsize ('cClass')) + ;
							Padr ('Class', Fsize ('cMember'))),			;
						  Alias(), 'BaseKey')
					If lBase
						lcValue = mValue
						Exit
					Endif
				Enddo
				Go lnRecno
				Replace mValue With lcValue
			Endif
		Endscan

		*******************************************************

		* Resolve descriptions.
		* Set Message TO "Resolving descriptions in "+	;
		SYS(cnVF_SYS_CROSSPATH, lcLibVisual)
		Select (lcDescrip)

		Scan
			* DJL - Allow descriptions for class records also.
			* Code depends on SET EXACT OFF
			If Seek (Lower (cClass +									;
						Padr ('Property', Fsize ('cMember', lcAlias)) +	;
						Padr (mName,      128)),						;
					  lcAlias, 'PrimaryKey')							;
					Or	Seek (Lower (cClass +							;
						Padr ('Method', Fsize ('cMember', lcAlias)) +	;
						Padr (mName,    128)),							;
					  lcAlias, 'PrimaryKey')							;
					Or	Seek (Lower (cClass +							;
						Padr ('Class', Fsize ('cMember', lcAlias)) ),	;
					  lcAlias, 'PrimaryKey')
				Replace (lcAlias + '.mDescrip')					   ;
						  With Evaluate (lcDescrip + '.mDescrip')  ;
					In (lcAlias)
			Else
				?'??No record for description: ' + Trim (cClass) + '.' + mName + ': ' + Evaluate (lcDescrip + '.mDescrip')
			Endif
		Endscan
		Select (lcAlias)

		*******************************************************

		* We've got all the data, so use the class lib and brute force.
		Store '' To lcArray, lcBaseClass, lcClass, lcInit, lcProperty, lcMemberData
		Set Order To PrimaryKey
		Scan  && in sorted order
			* Set Message TO "Building " + TRIM(cClass)+  ;
			" " + TRIM(cMember) +" "+ mName
			If Empty (lcClass) Or  ;
					Not Evaluate (lcVcx + '.ObjName') == Lower (Trim (cClass)) && new class

				If Not Empty (lcClass)  && write last class's saved variables
					= This.WriteClass (lcVcx, lcClass, lcBaseClass, lcProperty, ;
						  lcArray, lcInit, Program())
					Dimension laMembers[1]
					Store '' To lcProperty, lcArray, lcBaseClass,  ;
						lcInit, laMembers
				Endif

				* New class record.
				lcClass = Lower (Trim (cClass))

				* Delete any existing class definitions.
				Select (lcVcx)
				Locate For Platform = lcPlatform And		;
					Lower (ObjName) == Lower (lcClass) And	;
					Not (Empty (Reserved2) Or Deleted())
				If Found()
					For lnCounter = 1 To Val (Reserved2)
						Delete
						Skip
						If Eof()
							Exit
						Endif
					Endfor
					If Platform = 'COMMENT' And Lower (ObjName) == Lower (lcClass)
						Delete
					Endif
				Endif
				Select (lcAlias)

				* Insert new class definition.
				* DJL - remove hard-coded 'converted by' string from Reserved7
				* DJL - removed code to store lcHeader in the USER field
				Insert Into (lcVcx)										;
					(Platform, UniqueId, ObjName,						;
					  Reserved1, Reserved2, Reserved6,					;
					  Reserved8, User)									;
					Values (lcPlatform, Sys (cnVF_SYS_UNIQUEID), lcClass, ;
					  'Class', '1', 'Pixels',							;
					  Lower (lcInclude), lcPEMList + CRLF + This.cCommentBlock)
				lcClass = Lower (lcClass)
			Endif  && new class

			Do Case
				Case Trim (cMember) == 'Class'
					lcBaseClass	= Lower (Evaluate (lcAlias + '.mValue'))
					lcClasslib	= Lower (Evaluate (lcAlias + '.mClasslib'))
					= Amembers (laMembers, Createobject (lcBaseClass), 1)
					* DJL - update Reserved7 from stored description field.
					Replace	Class	   With	 Lower (Evaluate (lcAlias + '.mName')), ;
							BaseClass  With	 lcBaseClass,				;
							Reserved7  With	 Evaluate (lcAlias + '.mDescrip') ;
						In (lcVcx)
					If Not Empty (m.lcClasslib)
						Replace ClassLoc With Lower (m.lcClasslib) In (lcVcx)
					Else
						If Not lBase
							Replace	ClassLoc  With	Lower (Sys (cnVF_SYS_RELATIVEPATH, ;
										  Dbf (lcVcx),					;
										  Dbf (lcVcx)))					;
								In (lcVcx)
						Endif
					Endif

				Case Trim (cMember) == 'ClassIcon'
					Replace Reserved4 With Evaluate (lcAlias + '.mValue') In (lcVcx)

				Case Trim (cMember) == 'ClassIcon2'
					Replace Reserved5 With Evaluate (lcAlias + '.mValue') In (lcVcx)

				Case Trim (cMember) == 'Property'
					If Empty (mArray)
						* Don't store in Reserved3 (lcProperty string) if
						* it's a VFP built-in property.
						llExact = Set ('EXACT') == 'ON'
						Set Exact On  && for ASCAN()
						llBuiltin = Ascan (laMembers, Upper (mName)) > 0
						If Not llBuiltin
							* Put at end of property list before methods/arrays.
							lcProperty = lcProperty + Lower (mName) + Iif (Empty (mDescrip), '', ' ' + mDescrip) + ccCRLF
						Endif
						If Not Empty (mValue)
							lcValue = This.cDefined (mValue)
							* Put everything in parentheses.
							* lcValue = "(" + lcValue + ")"
							* DJL - Be a little smarter about what gets parened.
							Do Case
								Case Upper (Left (m.lcValue, 4)) == 'RGB(' And llBuiltin
									m.lcValue = Substr (m.lcValue, 5, Len (m.lcValue) - 5)
								Case Upper (mName) == 'NAME' Or Right (Upper (mName), 5) == '.NAME'
									If Not Inlist (Left (m.lcValue, 1), ['], ["])
										m.lcValue = ["] + m.lcValue + ["]
									Endif
								Case Not llBuiltin And Inlist (Left (m.lcValue, 1), ['], ["])
									m.lcValue = Substr (m.lcValue, 2, Len (m.lcValue) - 2)
								Case Inlist (Left (m.lcValue, 1), ['], ["]) And Not '+' $ m.lcValue
									m.lcValue = m.lcValue
								Case Not Isdigit (m.lcValue) And Not Inlist (Upper (m.lcValue), '.T.', '.F.', '.NULL.')
									m.lcValue = '(' + m.lcValue + ')'
							Endcase

							Replace Properties							;
									  With Lower (Evaluate (lcAlias + '.mName')) + ;
									  ' = ' + lcValue + ccCRLF			;
									  Additive In (lcVcx)
						Endif
						If Not llExact
							Set Exact Off
						Endif
					Else  && put in array list, lcArray
						lcValue = mArray
						If Not ',' $ lcValue  && reformat one dimensional array
							lcValue = Left (lcValue, Len (lcValue) - 1) + ;
								',0' +									;
								Right (lcValue, 1)
						Endif
						lcArray = lcArray +								;
							'^' + Lower (mName) +						;
							lcValue +									;
							Iif (Empty (mDescrip), '',  ' ' + mDescrip) + ;
							ccCRLF
						If Not Empty (mInit)
							lcInit = lcInit + mInit
						Endif
					Endif
					If lProtect
						Replace Protected								;
								  With Lower (Evaluate (lcAlias + '.mName')) + ccCRLF ;
								  Additive In (lcVcx)
					Endif

					* If "." as in Button.Click, can't do it.
				Case Trim (cMember) == 'Method' And Not '.' $ mName
					* Don't store in Reserved3 if it's a built-in method/event.
					llExact = Set ('EXACT') == 'ON'
					Set Exact On  && for ASCAN()
					If Ascan (laMembers, Upper (mName)) == 0
						Replace Reserved3								;
								  With '*' + Lower (Evaluate (lcAlias + '.mName')) + ;
								  Iif (Empty (Evaluate (lcAlias + '.mDescrip')), ;
									'',									;
									' ' + Evaluate (lcAlias + '.mDescrip')) + ;
								  ccCRLF								;
								  Additive In (lcVcx)
					Endif
					If Not llExact
						Set Exact Off
					Endif

					Local lcProcedureName, lcMethodText
					lcProcedureName = Alltrim(Evaluate (lcAlias + '.mName'))
					lcMethodText = Evaluate (lcAlias + '.mValue')
					*!* * Removed 5/11/2012 
					*!* If This.lBeautifyX
					*!* 	lcMethodText = This.oTools.BeautifyCode(lcMethodText)
					*!* Endif
					lcMethodText = 'PROCEDURE ' + Lower(lcProcedureName) + ccCRLF + ;
						lcMethodText +				;
						'ENDPROC' + ccCRLF

					Replace Methods	With lcMethodText Additive In (lcVcx)
					If lProtect
						Replace Protected								;
								  With Lower (Evaluate (lcAlias + '.mName')) + ccCRLF ;
								  Additive In (lcVcx)
					Endif

				Case Trim (cMember) == 'Object'
					lnRecno = Recno()
					= Seek (Lower (cClass + Padr ('Class', Fsize ('cMember'))), ;
						  Alias(), 'BaseKey')
					lcName = Lower (mValue)
					Go lnRecno

					* If "." as in Formset.Form.Button, can't do it.
					If Not '.' $ lcName
						Replace Reserved2								;
								  With Ltrim (Str (Val (Reserved2) + 1)) ;
							In (lcVcx)
						lnRecno = Recno (lcVcx)
						Insert Into (lcVcx)								;
							(Platform,									;
							  UniqueId,									;
							  Class,									;
							  ClassLoc,									;
							  BaseClass,								;
							  ObjName,									;
							  Parent,									;
							  Protected,								;
							  Properties,								;
							  Reserved8)								;
							Values (lcPlatform,							;
							  Sys (cnVF_SYS_UNIQUEID),					;
							  Lower (Evaluate (lcAlias + '.mValue')),	;
							  Lower (Substr (lcLibVisual, Rat ('\', lcLibVisual) + 1)), ;
							  lcName,									;
							  Lower (Evaluate (lcAlias + '.mName')),	;
							  lcClass,									;
							  Iif (Evaluate (lcAlias + '.lProtect'),	;
								'TRUE', ''),							;
							  Evaluate (lcAlias + '.mArray'),			;
							  Iif (Evaluate (lcAlias + '.mInit') == 'NOINIT', ;
								'NOINIT', ''))
						Go lnRecno In (lcVcx)
					Endif  && "." in object name

				Otherwise
					If Trim (cMember) == 'Method' And '.' $ mName
						Messagebox ('Unsupported PrgToVcx feature - Methods for contained objects: ' + mName, 16, 'PrgToVcx')
					Else
						Error 'Unknown member type ' + cMember
					Endif
			Endcase
			If (Trim (cMember) == 'Property' And Empty (mArray))  ;
					Or (Trim (cMember) == 'Method' And Not '.' $ mName)
				If mName # Lower (mName) And Ascan (laMembers, Upper (mName), 1, -1, 1, 15) = 0
					lcName		 = Trim (mName)
					lcMD		 = '<memberdata name="' + Lower (lcName) + '" display="' + lcName + '"/>'
					lcMemberData = lcMemberData + lcMD
				Endif
			Endif

		Endscan

		If Not Empty (lcMemberData)
			lcMD = '<VFPData>' + lcMemberData + '</VFPData>'
			Replace Reserved3			  ;
					  With '_memberdata'  ;
					  + ccCRLF			  ;
					  + Reserved3		  ;
				In (lcVcx)
			Replace Properties					 ;
					  With '_memberdata = '		 ;
					  + Replicate (Chr(1), 517)	 ;
					  + Str (Len (lcMD), 8, 0)	 ;
					  + lcMD					 ;
					  + ccCRLF					 ;
					  Additive In (lcVcx)
		Endif

		* Write last class.
		If Not Empty (lcClass)  && write last class's saved variables
			= This.WriteClass (lcVcx, lcClass, lcBaseClass, lcProperty,	;
				  lcArray, lcInit, Program())
		Endif

		* Delete cursors.  Comment out for testing.
		Use In (lcAlias)
		Use In (lcDescrip)

		If Isexclusive (lcVcx)
			* Set Message TO "Packing memos in "+  ;
			SYS(cnVF_SYS_CROSSPATH, lcLibVisual)
			Select (lcVcx)
			Pack Memo
		Endif

		Use In (lcVcx)
		* Set Message TO "Compiling methods in "+  ;
		SYS(cnVF_SYS_CROSSPATH, lcLibVisual)
		Select (lnSelect)

		* COMPILE FORM removes deleted records via PACK DBF.
		* It does not PACK MEMO.
		If tlCompile
			Compile Class (lcLibVisual)
		Endif

		* Set Message TO
		*	WAIT WINDOW NOWAIT PROGRAM() + " completed."
		Return
	Endproc  && Convert


	Procedure SaveCommentBlock (tcCommentBlock)
		This.cCommentBlock = This.cCommentBlock + tcCommentBlock
	Endproc


	Protected Procedure WriteClass (tcVcx, tcClass, tcBaseClass, tcProperty, ;
			  tcArray, tcInit, tcProgram)
		Local lnPosition,  ;
			lnPosition2,   ;
			lcValue,	   ;
			lcString,	   ;
			lcInit

		Replace Properties									  ;
				  With Properties +							  ;
				  Iif (Atc ('Name =', Properties) == 1 Or	  ;
					Atc (ccCRLF + 'Name =', Properties) > 0,  ;
					'',										  ;
					'Name = "' + tcClass + '"' + ccCRLF)	  ;
			In (tcVcx)

		* Write the properties to Reserved3 before methods/arrays.
		Replace Reserved3								 ;
				  With tcProperty + tcArray + Reserved3	 ;
			In (tcVcx)

		* Write the Init method, or Load if it's a form or formset.
		If Not Empty (tcInit)
			lcInit = '*** ' + tcProgram + ' BEGIN move from class body' + ccCRLF + ;
				tcInit +												;
				'*** ' + tcProgram + ' END move from class body' + ccCRLF
			* Place at beginning of Init or Load method.
			lnPosition = Atc ('PROCEDURE ' +			 ;
				  Iif (Left (tcBaseClass, 4) == 'form',	 ;
					'load', 'init') + ccCRLF,			 ;
				  Evaluate (tcVcx + '.Methods'))
			If lnPosition == 0
				lnPosition = Atc ('PROCEDURE ' +			 ;
					  Iif (Left (tcBaseClass, 4) == 'form',	 ;
						'load', 'init') + ' ' + ccCRLF,		 ;
					  Evaluate (tcVcx + '.Methods'))
			Endif
			If lnPosition == 0
				Replace Methods									 ;
						  With 'PROCEDURE ' +					 ;
						  Iif (Left (tcBaseClass, 4) == 'form',	 ;
							'load', 'init') + ccCRLF +			 ;
						  lcInit +								 ;
						  'ENDPROC' + ccCRLF					 ;
						  Additive In (tcVcx)
			Else
				lcString = Evaluate (tcVcx + '.Methods')
				lcValue   = Substr (lcString,			  ;
					  lnPosition,						  ;
					  Atc (ccCRLF + 'ENDPROC',			  ;
						Substr (lcString, lnPosition)) +  ;
					  Len (ccCRLF + 'ENDPROC'))
				lnPosition2 = Atc ('LPARAMETERS ', lcValue)
				If Empty (lnPosition2)
					lnPosition2 = Atc ('PARAMETERS ', lcValue)
					If Not Empty (lnPosition2)
						lnPosition2 = lnPosition2 +	 ;
							Atc (ccCRLF,			 ;
							  Substr (lcValue, lnPosition2)) + 2
					Endif
				Else
					lnPosition2 = lnPosition2 +	 ;
						Atc (ccCRLF,			 ;
						  Substr (lcValue, lnPosition2)) + 2
				Endif
				If Empty (lnPosition2)
					lnPosition2 = Atc (ccCRLF, lcValue) + 2
				Endif
				lcValue = Left (lcValue, lnPosition2 - 1) +	 ;
					lcInit +								 ;
					Substr (lcValue, lnPosition2)
				lcString = Left (lcString, lnPosition - 1) +  ;
					lcValue +								  ;
					Substr (lcString, lnPosition +			  ;
					  Atc (ccCRLF + 'ENDPROC',				  ;
						Substr (lcString,					  ;
						  lnPosition)) +					  ;
					  Len (ccCRLF + 'ENDPROC'))
				Replace Methods With lcString In (tcVcx)
			Endif
		Endif

		* Write the FONTINFO record.
		If Not Empty (tcClass)
			Insert Into (tcVcx)					  ;
				(Platform,  UniqueId,   ObjName)  ;
				Values ('COMMENT', 'FONTINFO', tcClass)
		Endif
	Endproc  && WriteClass


	Protected Function cDefined (tcString)
		* Enter additional defines and #INCLUDE your .h file here.
		Local lcString
		lcString = tcString

		* EDC specific.
		lcString = Strtran (lcString, 'cxCLASS_EDC', ccCLASS_EDC)
		lcString = Strtran (lcString, 'cxCLASS_MSG', ccCLASS_MSG)
		lcString = Strtran (lcString, 'ccCRLF', ccCRLF_DEF)
		lcString = Strtran (lcString, 'ccMSG_INSERT1', '"' + ccMSG_INSERT1 + '"')
		lcString = Strtran (lcString, 'ccMSG_INSERT2', '"' + ccMSG_INSERT2 + '"')
		lcString = Strtran (lcString, 'ccMSG_INSERT3', '"' + ccMSG_INSERT3 + '"')
		lcString = Strtran (lcString, 'ccEDC_REG_ALTERNATE',  ;
			  ccEDC_REG_ALTERNATE)
		lcString = Strtran (lcString, 'cnVF_FIELD_MAXCOUNT',  ;
			  Ltrim (Str (cnVF_FIELD_MAXCOUNT)))
		lcString = Strtran (lcString, 'cnVF_FIELD_MAXNAMELEN',	;
			  Ltrim (Str (cnVF_FIELD_MAXNAMELEN)))
		lcString = Strtran (lcString, 'cnALT_COLUMNS',	;
			  Ltrim (Str (cnALT_COLUMNS)))
		lcString = Strtran (lcString, 'cnOBJ_COLUMNS',	;
			  Ltrim (Str (cnOBJ_COLUMNS)))
		lcString = Strtran (lcString, 'cnAERR_MAX',	 ;
			  Ltrim (Str (cnAERR_MAX)))

		Return lcString
	Endfunc  && cDefined

	Function IsBaseClass (lcClass)
		Return Ascan (This.aBaseClass, lcClass, 1, -1, 1, 15) > 0
	Endfunc


	Protected aBaseClass[43],  ;
		nTabSpaces
	nTabSpaces = 4
	* Base classes here must be lowercase.
	aBaseClass[1]  = 'checkbox'
	aBaseClass[2]  = 'collection'
	aBaseClass[3]  = 'column'
	aBaseClass[4]  = 'combobox'
	aBaseClass[5]  = 'commandbutton'
	aBaseClass[6]  = 'commandgroup'
	aBaseClass[7]  = 'container'
	aBaseClass[8]  = 'control'
	aBaseClass[9]  = 'cursor'
	aBaseClass[10] = 'cursoradapter'
	aBaseClass[11] = 'custom'
	aBaseClass[12] = 'dataenvironment'
	aBaseClass[13] = 'editbox'
	aBaseClass[14] = 'empty'
	aBaseClass[15] = 'exception'
	aBaseClass[16] = 'form'
	aBaseClass[17] = 'formset'
	aBaseClass[18] = 'grid'
	aBaseClass[19] = 'header'
	aBaseClass[20] = 'hyperlink'
	aBaseClass[21] = 'image'
	aBaseClass[22] = 'label'
	aBaseClass[23] = 'line'
	aBaseClass[24] = 'listbox'
	aBaseClass[25] = 'olebound'
	aBaseClass[26] = 'olecontainer'
	aBaseClass[27] = 'optionbutton'
	aBaseClass[28] = 'optiongroup'
	aBaseClass[29] = 'page'
	aBaseClass[30] = 'pageframe'
	aBaseClass[31] = 'projecthook'
	aBaseClass[32] = 'relation'
	aBaseClass[33] = 'reportlistener'
	aBaseClass[34] = 'separator'
	aBaseClass[35] = 'session'
	aBaseClass[36] = 'shape'
	aBaseClass[37] = 'spinner'
	aBaseClass[38] = 'textbox'
	aBaseClass[39] = 'timer'
	aBaseClass[40] = 'toolbar'
	aBaseClass[41] = 'xmladapter'
	aBaseClass[42] = 'xmlfield'
	aBaseClass[43] = 'xmltable'


Enddefine  && CLASS PrgToVcx
*** PrgToVcx.prg ********************************************



*************************************************************
Define Class VCDtoPRG As Session

	cClass		= ''
	cSourceFile	= ''
	cHandle		= ''
	cDefineLine	= ''
	cJustFName	= ''

	oObject		 = .Null.
	cIncludeFile = ''
	cFileName	 = ''
	cDefineText	 = ''
	
	oThor        = .Null.

	Dimension nBeautifyOptions(9)
	Dimension aMembersList(1)

	#Define ccMembersCursor crsr_Member
	#Define CR Chr(13)
	#Define LF Chr(10)
	#Define Tab Chr(9)
	
	Procedure Init
		This.oThor = Execscript(_Screen.cThorDispatcher, 'Thor Engine=')
	EndProc
	
	Procedure Destroy
		This.oThor = .Null.
	EndProc

	Procedure Run
		Local laFileInfo[1], laObjects[1], lcClasslib, lcCodeIndent, lcCommentBlock, lcDefine, lcDefineText
		Local lcHandle, lcHeaderInfo, lcIndent, lcPEMList, lcPRGText, lcSourceFile, lcUserInfo, loObject

		If 0 = Aselobj (laObjects) And 0 = Aselobj (laObjects, 1)
			Return .F.
		Endif

		This.oObject = laObjects(1)

		Aselobj (laFileInfo, 3)
		This.cFileName	  = laFileInfo(2)
		This.cIncludeFile = laFileInfo(3)
		If 'VCX' # Upper (Justext (This.cFileName))
			Return .F.
		Endif

		Use (This.cFileName) Again Alias VCX

		This.cClass = This.oObject.Class
		Locate For Lower (ObjName) == Lower (This.cClass) And Reserved1 = 'Class' And Not Deleted()
		lcUserInfo = User
		If lcUserInfo = 'VCD4PRG'
			lcHeaderInfo	 = Strextract (lcUserInfo, CRLF, CRLF, 1, 4)
			This.cSourceFile = Strextract (lcHeaderInfo, 'File = ', CR)
			This.cHandle	 = Strextract (lcHeaderInfo, 'Handle = ', CR)
			This.cDefineLine = Strextract (lcHeaderInfo, 'Define = ', CR)
			This.cJustFName	 = Strextract (lcHeaderInfo, 'JustFName = ', CR)
			lcPEMList		 = Strextract (lcUserInfo, CRLF, CRLF, 2)
			lcCommentBlock	 = Strextract (lcUserInfo, CRLF, CRLF, 3, 3)
		Else
			lcClasslib = This.oObject.ClassLibrary
			If ' ' $ lcClasslib
				lcClasslib = ['] + lcClasslib + [']
			Endif
			This.cDefineLine = 'Define Class ' + This.oObject.Name + ' as ' + This.oObject.ParentClass ;
				+ Iif (Empty (lcClasslib), '', ' of ' + lcClasslib)
			lcPEMList = ''
			lcCommentBlock = ''
		Endif

		This.CreatePEMList (This.oObject, lcPEMList)
		This.SetBeautifyOptions()

		This.CreateDefineClass (This.cDefineLine + lcCommentBlock)

		lcIndent = Icase (This.nBeautifyOptions(4) = 1, Tab,			;
			  This.nBeautifyOptions(4) = 2, Replicate (' ', This.nBeautifyOptions(3)), ;
			  '')
		lcCodeIndent = lcIndent + Iif (This.nBeautifyOptions(8) = 1, lcIndent, '')

		This.ReadDescriptions (This.oObject)
		This.CreateProperties (This.oObject, lcIndent)
		This.CreateMethods (This.oObject, lcIndent, lcCodeIndent)

		This.CreateEndDefine()

		This.BeautifyCode()
		Return .T.
	Endproc


	Procedure ReadDescriptions (toObject)
		Amembers (This.aMembersList, toObject, 3)
	Endproc


	Procedure CreatePEMList (toObject, tcPEMList)
		Local laMembers[1], lcInfo, lcMemberData, lcName, lcType, llAdd, lnI, lnMemberCount
		lnMemberCount = Amembers (laMembers, toObject, 1, 'PHG#')
		Create Cursor ccMembersCursor (Name C(60), Type C(1), Order N(6))

		lcMemberData = This.GetAllMemberData (toObject)

		For lnI = 1 To lnMemberCount
			lcName = Lower (laMembers[lnI, 1])

			If lcName == 'name' Or lcName == '_memberdata'
				Loop
			Endif

			lcType = Left (laMembers[lnI, 2], 1)
			lcInfo = laMembers[lnI, 3]
			Do Case
				Case Not ('N' $ lcInfo Or 'I' $ lcInfo)
					llAdd = .T.
				Case lcType = 'P' And 'C' $ lcInfo
					llAdd = .T.
				Case lcType $ 'ME' And 'C' $ lcInfo And Not Empty (toObject.ReadMethod (Trim (lcName)))
					llAdd = .T.
				Otherwise
					llAdd = .F.
			Endcase

			If llAdd
				Insert Into ccMembersCursor Values	;
					(This.GetMemberDataName (lcMemberData, lcName), lcType, Evl (Atc (' ' + lcName + ' ', tcPEMList), 999999))
			Endif
		Endfor && lnI = 1 to lnMemberCount

		Index On Order Tag Order
	Endproc


	Procedure GetAllMemberData (toObject)
		* Returns complete list of memberdata, all the way back up the inheritance tree.

		#Define ccPROPERTIES_PADDING_CHAR		Chr(1)
		* the padding character used for properties with values > 255 characters
		#Define cnPROPERTIES_PADDING_SIZE		517
		* the size of the padding area for properties with values > 255 characters
		#Define cnPROPERTIES_LEN_SIZE			8
		* the size of the length structure for properties with values > 255 characters

		Local laMemberDatas[1], lcClass, lcLibrary, lcMemberData, lcNewMemberData, lcPrompt, lnLen, lnNFound
		Local lnPos, lnSelect
		If Not Pemstatus (toObject, '_MemberData', 5)
			Return ''
		Endif

		lnSelect = Select()
		If Pemstatus (toObject, '_MemberData', 0)
			lcMemberData = toObject._MemberData
		Else
			lcMemberData = ''
		Endif

		With toObject
			lcClass	  = Lower (.ParentClass)
			lcLibrary = .ClassLibrary
		Endwith

		Do While Not Empty (lcLibrary)
			If Not File (lcLibrary)
				lcPrompt = 'File not found: ' + Justfname (lcLibrary)
				Messagebox (lcPrompt)
				lcLibrary = ''
				Exit
			Endif

			Select 0
			Use (lcLibrary) Again Shared
			Locate For ObjName == lcClass And Lower (Reserved1) = 'class'

			lnPos = At ('_memberdata = ', Properties)
			If lnPos > 0
				lnPos = lnPos + 14

				* We have to handle properties with more than 255 characters in the value
				* differently.
				If Substr (Properties, lnPos, 1) = ccPROPERTIES_PADDING_CHAR
					lnLen        = Val (Alltrim (Substr (Properties,  ;
							  lnPos + cnPROPERTIES_PADDING_SIZE,	  ;
							  cnPROPERTIES_LEN_SIZE)))
					lcNewMemberData = Substr (Properties, lnPos +		;
						  cnPROPERTIES_PADDING_SIZE + cnPROPERTIES_LEN_SIZE, ;
						  lnLen)
				Else
					lcNewMemberData = Strextract (Substr (Properties, lnPos), ;
						  '', ccCR)
				Endif Substr (Properties, lnPos, 1) = ccPROPERTIES_PADDING_CHAR

				If Not Empty (lcNewMemberData)
					lcMemberData = lcMemberData + lcNewMemberData
				Endif
			Endif && lnPos > 0

			lcClass   = Lower (Class)

			If Not Empty (ClassLoc)
				lcLibrary = Fullpath (ClassLoc, Addbs (Justpath (lcLibrary)))
				If Not File ( m.lcLibrary )
					lcLibrary = Fullpath ( ClassLoc )
				Endif
			Else
				lcLibrary = ''
			Endif Not Empty (ClassLoc)

			Use
		Enddo While Not Empty (lcLibrary)

		Select  (lnSelect)
		Return lcMemberData

	Endproc


	Procedure CreateDefineClass (tcDefine)
		This.OutputText (tcDefine)
	Endproc


	Procedure CreateProperties (toObject, lcIndent)
		Local lcArrays, lcName, lcType, lcValue, lnMaxLength, lxValue
		lcArrays = ''
		This.OutputText ('')
		Calculate Max (Len (Trim (Name))) To lnMaxLength For Type = 'P'
		If lnMaxLength > 0
			Scan For Type = 'P'
				lcName  = Trim (Name)
				This.OutputDescription (toObject, lcName, lcIndent)
				lxValue	= Getpem (toObject, lcName)
				lcValue	= Transform (lxValue)
				lcType	= Vartype (lxValue)
				Do Case
					Case Isnull (lxValue)
						lcValue = '.Null.'
					Case 'U' # Type ('ALen(toObject.' + lcName + ')')
						If Not Empty (lcArrays)
							lcArrays = lcArrays + CR
						Endif
						lcArrays = lcArrays + lcIndent + 'Dimension '	;
							+ lcName + '[' + Transform (Alen (toObject.&lcName, 1)) ;
							+ Iif ( 0 # Alen (toObject.&lcName, 2),		;
							  ',' + Transform (Alen (toObject.&lcName, 2)), '') + ']'
						Loop
					Case lcType = 'C'
						Do Case
							Case Not ['] $ lcValue
								lcValue = ['] + lcValue + [']
							Case Not [''] $ lcValue
								lcValue = ["] + lcValue + ["]
							Case Otherwise
								lcValue = '[' + lcValue + ']'
						Endcase
					Case lcType = 'N'
					Case lcType = 'L'

				Endcase
				This.OutputText (lcIndent + Padr (lcName, lnMaxLength) + ' = ' + lcValue)
			Endscan
			If Not Empty (lcArrays)
				This.OutputText (lcArrays)
			Endif
			This.OutputText ('')
		Endif
	Endproc


	Procedure CreateMethods (toObject, lcIndent, lcCodeIndent)
		Local lcMethodText, lcName, lnCount
		Local lcPrefixText, lnPos

		lcPrefixText = This.oThor.GetOption (ccProcedureDividers, ccTool)

		Scan For Type $ 'ME'
			lcName  = Trim (Name)

			If not Empty(lcPrefixText)
				This.OutputText(Textmerge(lcPrefixText))
			EndIf 
			* 	This.OutputDescription (toObject, lcName, lcIndent)
			lcMethodText = Trim (toObject.ReadMethod (lcName), ' ', Tab)
			lcMethodText = Strtran (lcMethodText, Chr(10), '')
			lcMethodText = Trim(lcMethodText, 1, CR, ' ')
			Do while Ltrim(lcMethodText, 1, Tab, ' ') = '*'
				lnPos = Evl(At(CR, lcMethodText), Len(lcMethodText) + 1) 
				This.OutputText (lcIndent + Left(lcMethodText, lnPos - 1)) 
				lcMethodText = Substr(lcMethodText, lnPos + 1)
			EndDo 
			
			lcMethodText = lcIndent + 'Procedure ' + Trim (lcName) + CR	;
				+ lcCodeIndent + Strtran (lcMethodText, CR, CR + lcCodeIndent) + CR ;
				+ lcIndent + 'EndProc'
			This.OutputText (lcMethodText)
			This.OutputText ('')
			This.OutputText ('')
		Endscan
	Endproc


	Procedure OutputDescription (toObject, tcName, tcIndent)
		Local lcText, lnBlankPos, lnBreak, lnRow

		If Pemstatus (toObject, tcName, 6) && custom properties only!
			Return
		Endif

		lnRow = Ascan (This.aMembersList, tcName, 1, -1, 1, 15)
		If lnRow # 0 And Not Empty (This.aMembersList[lnRow, 4])
			lcText = tcIndent + '* ' + Alltrim (This.aMembersList[lnRow, 4])
			Do While Len (lcText) > cnMaxDescriptionWidth
				lnBreak = Rat (' ', Left (lcText, cnMaxDescriptionWidth + 1))
				This.OutputText (Left (lcText, lnBreak) + ';')
				lcText = tcIndent + '* ' + Alltrim (Substr (lcText, lnBreak))
			Enddo
			This.OutputText (lcText)
		Endif
	Endproc


	Procedure CreateEndDefine()
		This.OutputText ('EndDefine')
	Endproc


	Procedure OutputText (tcText)
		This.cDefineText = This.cDefineText + tcText + CR
	Endproc


	Procedure GetMemberDataName (lcMemberData, tcName)
		Local lcName
		lcName = Strextract (Strextract (lcMemberData, 'name="' + Trim (tcName) + '"', '/>'), ' display="', '"')
		If Not Empty (lcName)
			Return lcName
		Endif

		If Not Used ('VFP_Keywords')
			Use Home() + 'WIZARDS\FDKEYWRD' Order TOKEN Again Shared In 0 Alias Keywords
			Select TOKEN From Keywords Into Cursor VFP_Keywords Readwrite
			Index On Upper (TOKEN) Tag TOKEN
			Use In Keywords
		Endif

		Return Iif (Used ('VFP_Keywords') And							;
			  Seek (Upper (Padr (tcName, Len (VFP_Keywords.TOKEN))), 'VFP_Keywords'), ;
			  Trim (VFP_Keywords.TOKEN), tcName)

	Endproc


	Procedure GetSourceFile
		Local lcFile, lcTextFile
		lcTextFile = Forceext (This.cFileName, This.cClass + '.txt')
		If File (lcTextFile)
			lcFile = Filetostr (lcTextFile)
			If File (lcFile)
				Return (lcFile)
			Else
				Return ''
			Endif
		Else
			Return ''
		Endif
	Endproc


	Procedure SaveSourceFile (tcFile)
		Local lcTextFile
		lcTextFile = Forceext (This.cFileName, This.cClass + '.txt')
		Erase (lcTextFile)
		Strtofile (tcFile, lcTextFile)
	EndProc
	
	
	Procedure BeautifyCode
		If This.oThor.GetOption (ccBeautifyKey, ccTool)
			* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
			loTools = ExecScript(_Screen.cThorDispatcher, "Class= tools from pemeditor")
			This.cDefineText = loTools.BeautifyCode(This.cDefineText)
		EndIf 
	Endproc


	Procedure SetBeautifyOptions
		*    Options:
		*        1 = Variable case - 4 = no change, 3 = use 1st
		*        2 = command Case - 3 = mixed, 2 = lower, 1 = upper
		*        3 = number of spaces if option 4 (below) is 2
		*        4 = tabs/spaces, 						1 - use tabs, 2 - use spaces, 3 = no change
		*        5 =  ??
		*        6 = comments - 						1 = include comments, 0 = no
		*        7 = Line continuation 					1 = include, 0 = no
		*        8 = Extra indent beneath procedures 	1 = yes, 0 = no
		*        9 = Extra indent beneath Do Case 		1 = yes, 0 = no

		Local lcOptions, lnI, lnSelect

		lnSelect = Select()
		Select 0

		lcOptions =								 ;
			Chr(4) + Chr(0) + Chr(0) + Chr(0) +	 ;
			Chr(1) + Chr(0) + Chr(0) + Chr(0) +	 ;
			Chr(4) + Chr(0) + Chr(0) + Chr(0) +	 ;
			Chr(1) + Chr(0) + Chr(0) + Chr(0) +	 ;
			Chr(0) + Chr(0) + Chr(0) + Chr(0) +	 ;
			Chr(0) + Chr(0) + Chr(0) + Chr(0) +	 ;
			Chr(1) + Chr(0) + Chr(0) + Chr(0) +	 ;
			Chr(0) + Chr(0) + Chr(0) + Chr(0) +	 ;
			Chr(1) + Chr(0) + Chr(0) + Chr(0)

		If Set ('Resource') = 'ON'
			Use (Set ('Resource', 1)) Again Shared Alias Resource
			Locate For Id = 'BEAUTIFY'
			If Found()
				lcOptions = Right (Data, 36)
			Endif
			Use
		Endif

		For lnI = 1 To 9
			This.nBeautifyOptions (lnI) = Asc (Substr (lcOptions, (4 * lnI) - 3, 1))
		Endfor

		Select (lnSelect)

	Endproc


Enddefine


**********************************************************
**********************************************************

Define Class clsVCD4PRGBeautifyX As Custom

	Tool		  = ccTool
	Key			  = ccBeautifyKey
	Value		  = .T.
	EditClassName = ccEditClassName

Enddefine


Define Class clsVCD4PRGProcDividers As Custom

	Tool		  = ccTool
	Key			  = ccProcedureDividers
	Value		  = "<<Replicate('*', 80)>>" + Chr(13) + "<<Padr(Replicate('*', 20) + ' ' + lcName + ' ', 80, '*')>>"
	EditClassName = ccEditClassName

Enddefine


Define Class clsVCD4PRGDividerLineIndicator As Custom

	Tool		  = ccTool
	Key			  = ccDividerLineIndicator
	Value		  = "<<Replicate('*', 20)>>"
	EditClassName = ccEditClassName

Enddefine

