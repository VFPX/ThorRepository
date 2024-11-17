Return Execscript (_Screen.cThorDispatcher, 'Result=', Newobject('ThorUtilities'))


Define Class ThorUtilities As Custom


	Procedure AddMRU(lcFile, lcClass)

		Local loTools
		loTools = Execscript (_Screen.cThorDispatcher, 'class= tools from pemeditor')
		m.loTools.AddMRUFile(m.lcFile)
		If Pcount() > 1
			m.loTools.AddMRUFile(m.lcFile, m.lcClass)
		Endif

	Endproc


	Procedure ADirCursor(lcPath, lcCursorName, lcParams)

		Local lcFileList[1], lnNFiles

		Create Cursor &lcCursorName(FileName c(80), Size N(10), Date D, Time c(12), Attrib c(5), Datetime T)

		If 2 = Pcount()
			lnNFiles = Adir(lcFileList, m.lcPath)
		Else
			lnNFiles = Adir(lcFileList, m.lcPath, m.lcParams)
		Endif

		If m.lnNFiles > 0
			Append From Array m.lcFileList
			Replace All Datetime With Evaluate(Transform(Dtoc(Date, 1), '@R {^9999-99-99') + ' ' + Time + '}')
		Endif

		Return m.lnNFiles
	Endproc


	Procedure CloseTempFiles(lcFile1, lcFile2, lcFile3, lcFile4, lcFile5)
		Local lcN, lnI, lnLen, loCloseTemps
		loCloseTemps = Newobject('CloseTemps')

		For lnI = 1 To Pcount()
			lnLen = 1 + Alen( m.loCloseTemps.aStart, 1)
			Dimension m.loCloseTemps.aStart(m.lnLen, 2)
			lcN								= Transform(m.lnI)
			loCloseTemps.aStart(m.lnLen, 1)	= Upper(lcFile&lcN)
		Next m.lnI

		Return m.loCloseTemps
	Endproc


	Procedure OpenThorTables
		Local lcFolder

		lcFolder = _Screen.cThorFolder + 'Tables\'
		This.ADirCursor(m.lcFolder + '*.dbf', 'ThorFiles')
		Index on Upper(Filename) DESCENDING tag Order

		Scan
			If Not Used(Juststem(FileName))
				Use (m.lcFolder + Trim(FileName)) Again Shared In 0
			Endif
		Endscan

		Use In ThorFiles

		If Not Used('HotKeys')
			Use (_Screen.cThorFolder + 'Source\HotKeys') Again Shared In 0
		Endif

	Endproc


	Procedure PasteIntoCodeWindow(lcText)
		Local lcOldClipText, loEditorWin
	
		loEditorWin = Execscript(_Screen.cThorDispatcher, 'Class= editorwin from pemeditor')
	
		If Inlist(m.loEditorWin.FindWindow(), 0, 1, 8, 10)
			lcOldClipText	 = _Cliptext
	
			_Cliptext = m.lcText
			m.loEditorWin.Paste()
	
			_Cliptext = m.lcOldClipText
		Endif
	Endproc
	

	Procedure WaitWindow(lcText)
		* Position wait window near the cursor
		Local lnCol, lnRow
	
		lnRow = Mrow() + (_Screen.Top) / Fontmetric(1, _Screen.FontName, _Screen.FontSize)
		lnCol = Mcol()
		Wait m.lcText Window At m.lnRow, m.lnCol Nowait
	
	EndProc
	
	
	Procedure CleanUpThorTables
		Local laMenuIDs[1], lnCounter, lnI, loCloseTempFiles, loException
	
		* this closes tables left open in oThorEngine; no harm in doing so
		_Screen.oThorEngine = Null
	
		* when loCloseTempFiles goes out of scope, it closes any newly opened tables
		loCloseTempFiles = This.CloseTempFiles()
		* open all the tables in the Thor folder
		This.OpenThorTables()
	
		* Pack Thor
		Try
			Select Thor
			Use (Dbf()) Exclusive Alias (Alias())
			Pack
		Catch To m.loException
	
		Endtry
	
		* Pack ToolHotKeyAssignments
		Try
			Select ToolHotKeyAssignments
			Use (Dbf()) Exclusive Alias (Alias())
			Delete For HotKeyID <= 0
			Pack
		Catch To m.loException
	
		Endtry
	
		* Pack MenuDefinitions
		Try
			Select MenuDefinitions
			Use (Dbf()) Exclusive Alias (Alias())
			Pack
		Catch To m.loException
	
		EndTry
		
		* Pack MenuTools	
		Try
			Select MenuTools
			Use (Dbf()) Exclusive Alias (Alias())
			Delete For MenuID <= 0
			Pack
		Catch To m.loException
	
		Endtry
	
		* For MenuDefinitions, ensure that all MenuTools are numbereded 1, 2, ... with no holes
		Try
			Select  Id											;
				From MenuDefinitions							;
				Where (Not Internal)							;
					And Id # 8									;
					And Not Id In (Select  SubMenuID			;
									   From MenuTools			;
									   Where MenuID = 8)		;
				Into Array laMenuIDs
	
			For lnI = 1 To _Tally
				Set Filter To MenuID = m.laMenuIDs[m.lnI]
	
				Set Order To
				Replace All SortOrder With 1E9 + SortOrder
				Set Order To SortOrder
	
				lnCounter = 0
				Scan
					lnCounter = m.lnCounter + 1
					Replace SortOrder With m.lnCounter
				Endscan
			Endfor
		Catch To m.loException
	
		Endtry
	
	Endproc
		
	
	Procedure BackupThorTables
		* when loCloseTempFiles goes out of scope, it closes any newly opened tables
		Local lcDestFolder, lcFileName, lcTableFolder, loCloseTempFiles
	
		loCloseTempFiles = This.CloseTempFiles()
		
		* open all the tables in the Thor folder
		This.OpenThorTables()
	
		lcTableFolder = _Screen.cThorFolder + 'Tables\'
		lcDateTime = Ttoc(Datetime(), 1)
		lcDestFolder  = m.lcTableFolder + 'Backup.' + Left(m.lcDateTime, 8) + '.' + Right(m.lcDateTime, 6)
		MkDir(m.lcDestFolder) 
	
		This.ADirCursor(m.lcTableFolder + '*.dbf', 'ThorFiles')
		Scan
			lcFileName = Trim(FileName)
			Select (m.lcFileName)
			Copy To (m.lcDestFolder + '\' + m.lcFileName) CDX
		EndScan
		
		Return Execscript (_Screen.cThorDispatcher, 'Result=', m.lcDestFolder)
	
	Endproc
		

	Procedure GetMRUList
		Lparameters lcMRU_ID

		#Define DELIMITERCHAR Chr(0)

		Local loCollection As 'Collection'
		Local laItems(1), lcData, lcList, lcSourceFile, lnI, lnPos, lnSelect

		loCollection = Createobject ('Collection')

		If 'ON' # Set ('Resource')
			Return m.loCollection
		Endif

		lnSelect	 = Select()
		lcSourceFile = Set ('Resource', 1)
		Select 0
		Use (lcSourceFile) Again Shared Alias MRU_Resource

		If lcMRU_ID # 'MRU'
			lcMRU_ID = This.GetMRUID (lcMRU_ID)
			If '?' $ lcMRU_ID
				Return
			Endif
		Endif

		Locate For Id = lcMRU_ID
		If Found()
			lcData = Data
			Alines (laItems, Substr (lcData, 3), 0, DELIMITERCHAR)
			For lnI = 1 To Alen (laItems)
				If Not Empty (laItems (m.lnI))
					m.loCollection.Add (laItems (m.lnI))
				Endif
			Endfor
		Endif

		Use
		Select (lnSelect)
		Return m.loCollection

	EndProc
	
	
	Procedure GetMRUID
		Lparameters lcFileName
	
		Local lcExt, lcList, lcMRU_ID, lnPos
	
		lcExt = Upper (Justext ('.' + m.lcFileName))
	
		lcList = ',VCX=MRUI,PRG=MRUB,MPR=MRUB,QPR=MRUB,SCX=MRUH,MNX=MRUE,FRX=MRUG,DBF=MRUS,DBC=???,LBX=???,PJX=MRUL'
		lnPos  = At (',' + m.lcExt + '=', m.lcList)
		If m.lnPos = 0
			lcMRU_ID = 'MRUC'
		Else
			lcMRU_ID = Substr (m.lcList, m.lnPos + 5, 4)
		Endif
	
		Return m.lcMRU_ID
	Endproc
	
	
	
	Procedure GetDisplayRelativePath
		Lparameters lcFileName, lcFolder, lcClass
		* returns the display form of a file name
		Local lcFName, lcFileDisplayName, lcQuote, lcResult
	
		lcFileDisplayName = This.GetRelativePath (This.DiskFileName(m.lcFileName), Evl (m.lcFolder, Curdir()))
		lcFName			  = Justfname (m.lcFileDisplayName)
		lcQuote			  = Iif (' ' $ m.lcFName, ['], '')
		If m.lcFName == m.lcFileDisplayName
			lcResult = m.lcQuote + m.lcFName + m.lcQuote
		Else
			lcResult = m.lcQuote + m.lcFName + m.lcQuote + '  from  ' + Justpath (m.lcFileDisplayName)
		Endif
	
		Return m.lcResult
	
	Endproc
	

	Procedure GetRelativePath
		Lparameters lcName, lcPath
		Local lcNew, lnPos, loException
	
		Try
			If Empty (m.lcPath)
				lcNew = Sys(2014, m.lcName)
			Else
				lcNew = Sys(2014, m.lcName, m.lcPath)
			Endif
		Catch To m.loException
			lcNew = m.lcName
		Endtry
	
		If Len (m.lcNew) < Len (m.lcName)
			lnPos = Rat ('..\', m.lcNew)
			If m.lnPos # 0
				lnPos = m.lnPos + 2
			Endif
			Return Left (m.lcNew, m.lnPos) + Right (m.lcName, Len (m.lcNew) - m.lnPos)
		Else
			Return m.lcName
		Endif
	
	
	Endproc


	Procedure DiskFileName
		Lparameters lcFileName
	
		#Define MAX_PATH 260
	
		Local lcXXX, lnFindFileData, lnHandle
	
		Declare Integer FindFirstFile In win32api String @, String @
		Declare Integer FindNextFile In win32api Integer, String @
		Declare Integer FindClose In win32api Integer
	
		Do Case
			Case ( Right (m.lcFileName, 1) == '\' )
				Return Addbs (This.DiskFileName (Left (m.lcFileName, Len (m.lcFileName) - 1)))
	
			Case Empty (m.lcFileName)
				Return ''
	
			Case ( Len (m.lcFileName) == 2 ) And ( Right (m.lcFileName, 1) == ':' )
				Return Upper (m.lcFileName)	&& win2k gives curdir() for C:
		Endcase
	
		lnFindFileData = Space(4 + 8 + 8 + 8 + 4 + 4 + 4 + 4 + MAX_PATH + 14)
		lnHandle	   = FindFirstFile (@m.lcFileName, @m.lnFindFileData)
	
		If ( m.lnHandle < 0 )
			If ( Not Empty (Justfname (m.lcFileName)) )
				lcXXX = Justfname (m.lcFileName)
			Else
				lcXXX = m.lcFileName
			Endif
		Else
			= FindClose (m.lnHandle)
			lcXXX = Substr (m.lnFindFileData, 45, MAX_PATH)
			lcXXX = Left (m.lcXXX, At (Chr(0), m.lcXXX) - 1)
		Endif
	
	
		Do Case
			Case Empty (Justpath (m.lcFileName))
				Return m.lcXXX
			Case ( Justpath (m.lcFileName) == '\' ) Or (Left (m.lcFileName, 2) == '\\')	&& unc
				Return '\\' + m.lcXXX
			Otherwise
				Return Addbs (This.DiskFileName (Justpath (m.lcFileName))) + m.lcXXX
		Endcase
	
		Return
	
	Endproc

				
	****************************************************
	Function GoURL
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
		Lparameters tcUrl, tcAction, tcDirectory, tcParms

		If Empty(m.tcUrl)
			Return - 1
		Endif
		If Empty(m.tcAction)
			tcAction = 'OPEN'
		Endif
		If Empty(m.tcDirectory)
			tcDirectory = Sys(2023)
		Endif

		Declare Integer ShellExecute		;
			In SHELL32.Dll					;
			Integer nWinHandle,				;
			String cOperation,				;
			String cFileName,				;
			String cParameters,				;
			String cDirectory,				;
			Integer nShowWindow
		If Empty(m.tcParms)
			tcParms = ''
		Endif

		Declare Integer FindWindow		;
			In WIN32API					;
			String cNull, String cWinName

		Return ShellExecute(0,			;
			  m.tcAction, m.tcUrl,		;
			  m.tcParms, m.tcDirectory, 1)
	Endfunc

Enddefine


* ================================================================================
* ================================================================================
Define Class CloseTemps As Custom

	Dimension aStart[1]
	nfiles = 0

	Procedure Init
		Local aTemp[1]
		This.nfiles = Aused (aTemp)
		If This.nfiles > 0
			Acopy (aTemp, This.aStart)
		Else
			This.aStart = ''
		Endif
	Endproc

	Procedure Destroy
		Local lnI
		Local aNow[1]
		For lnI = 1 To Aused (aNow)
			If Ascan (This.aStart, m.aNow[m.lnI, 1], -1, -1, 1, 2 + 4) = 0
				Use In m.aNow[m.lnI, 1]
			Endif
		Endfor
	Endproc

Enddefine
 