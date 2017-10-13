Lparameter oFoxScript

*******************************************************************
*** ZDEF from the FoxCode table, modified to work within Thor,
*** returning a result array
*******************************************************************



* This script iterates thru all the #DEFINEs in the routine and lists them.
* It also iterates through and #INCLUDE files that may exists as well (both for
* programs and snippets). The PARAMETER passed in is reference to 
* FoxCodeScript object. SCX files are not supported for #INCLUDES since
* VFP opens them up in designer exclusively.
*
* To enable this script, make sure that you have the lAllowCustomDefScripts 
* custom property set to .T. (you can set this in the IntelliSense Manager).

*!* * Removed 8/27/2012 / JRN
*!* Local laEnv, laLines, laObj[1], lcLastWord, lcSaveStr, lcStr, lcfxtoollib, lnLines, lnWinHdl

*!* If oFoxScript.oFoxcode.Location = 0	&&Command Window
*!* 	Return .F.
*!* Endif

*!* If Not Upper(oFoxScript.oFoxcode.UserTyped) == Upper(oFoxScript.cCustomScriptName)   && ZDEF script
*!* 	Return .F.
*!* Endif

*!* lcfxtoollib = Sys(2004) + 'FOXTOOLS.FLL'
*!* If Not File(lcfxtoollib)
*!* 	Return .F.
*!* Endif
*!* Set Library To(m.lcfxtoollib) Additive

Local loEditorWin As Editorwin Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_editorwin.vcx'
Local loFoxCode As 'Empty'
Local loResult As 'Empty'
Local laEnv[1], laObj[1], lcSaveStr, lcStr, lnWinType, lcWonTop, lnWinHdl, lnWinType, loException

loFoxCode = Createobject('Empty')
AddProperty(loFoxCode, 'Items[1,2]')
AddProperty(loFoxCode, 'FileList', Createobject('Collection'))

* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')

lnWinHdl  = loEditorWin.GetWindowHandle()
lnWinType = loEditorWin.GetEnvironment(25)
lcWonTop  = Wontop()

If lnWinType > 0
	lcStr = loEditorWin.GetString(0, 1000000)
	If Not Empty(lcStr)
		lcSaveStr = lcStr
		GetIncludeDefs(lcStr, loFoxCode)
	Endif
Endif

* Check for Code Snippet #INCLUDE files
If Inlist(lnWinType, -1, 10) Or Inlist(Upper(lcWonTop), 'FORM DESIGNER', 'CLASS DESIGNER')
	Dimension laObj[1]
	If Aselobj(laObj, 3) # 0 And File(laObj[3])
		loFoxCode.FileList.Add(GetFullPath(laObj[3]))
		GetIncludeDefs(Filetostr( laObj[3]), loFoxCode)
	Endif
Endif

loResult = Createobject('Empty')
AddProperty(loResult, 'aList[1]')
AddProperty(loResult, 'FileList', loFoxCode.FileList)
If 'C' = Vartype(loFoxCode.Items)
	Acopy(loFoxCode.Items, loResult.aList)
Endif
Return Execscript(_Screen.cThorDispatcher, 'Result=', m.loResult)

*!* * Removed 8/27/2012 / JRN
*!* If Not Empty(oFoxScript.oFoxcode.Items[1])
*!* 	Dimension laLines[1]
*!* 	lnLines	   = Alines(laLines, lcSaveStr )
*!* 	lcLastWord = Alltrim(Getwordnum( laLines[ALEN(laLines)], Getwordcount(laLines[ALEN(laLines)] )))
*!* 	lcLastWord = Left(lcLastWord, Len(lcLastWord) - Len(oFoxScript.cCustomScriptName))
*!* 	oFoxScript.ReplaceWord(lcLastWord)

*!* 	* Handle extra space
*!* 	If Asc(Right(oFoxScript.oFoxcode.FullLine, 1)) = 32
*!* 		_EDSETPOS(lnWinHdl, _EDGETPOS(lnWinHdl) - 1)
*!* 	Endif
*!* 	oFoxScript.oFoxcode.ValueType = 'L'
*!* Endif

*!* Return ''


Procedure GetIncludeDefs(tcStr, toFoxCode)
	Local lcStr1, lnLines, i, lcLine, lcDefDesc, laLines, lnALen, lcDefWord, lcIncludeFile, lcStr2

	If Empty(tcStr)
		Return
	Endif
	lcStr1 = tcStr

	Dimension laLines[1]
	lnLines = Alines(laLines, lcStr1)

	For i = 1 To lnLines
		lcLine = Alltrim(laLines[m.i], 1, ' ', Chr[9])
		If Upper(Left(lcLine, 5)) = '#INCL'
			lcIncludeFile = Getwordnum(lcLine, 2)
			If Upper(lcIncludeFile) == 'FOXPRO.H'
				lcIncludeFile = Addbs(Home()) + lcIncludeFile
			Endif
			If File(lcIncludeFile)
				toFoxCode.FileList.Add(GetFullPath(lcIncludeFile))
				lcStr2 = Filetostr( lcIncludeFile)
				GetIncludeDefs(lcStr2, toFoxCode)
			Endif
		Endif
		If Not Upper(Left(lcLine, 5)) = '#DEFI'
			Loop
		Endif
		lnALen = Alen(toFoxCode.Items, 1)
		If Not Empty(toFoxCode.Items[1])
			Dimension toFoxCode.Items[lnALen + 1, 2]
			lnALen = Alen(toFoxCode.Items, 1)
		Endif
		lcDefWord				   = Getwordnum(lcLine, 2)
		toFoxCode.Items[lnALen, 1] = lcDefWord
		lcDefDesc				   = Substr(lcLine, Atc(lcDefWord, lcLine) + Len(lcDefWord))
		toFoxCode.Items[lnALen, 2] = Alltrim(Strtran(lcDefDesc, Chr[9], '   '))
	Endfor
Endproc


Procedure GetFullPath(lcFileName)
	Local laFile[1], lcFullName
	lcFullName = Fullpath(lcFileName)
	If Adir(laFile, lcFullName, '', 1) = 1
		lcFullName = Addbs(Justpath(lcFullName)) + laFile[1]
	Endif
	Return lcFullName
Endproc
