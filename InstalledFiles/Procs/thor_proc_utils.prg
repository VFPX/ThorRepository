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
			Replace All Datetime With Ctot(Transform(Dtoc(Date, 1), '@R ^9999/99/99') + ' ' + Time)
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
		Local laMenuIDs[1], lnCounter, lnI, loCloseTempFiles
	
		* this closes tables left open in oThorEngine; no harm in doing so
		_Screen.oThorEngine = Null
	
		* when loCloseTempFiles goes out of scope, it closes any newly opened tables
		loCloseTempFiles = This.CloseTempFiles()
		* open all the tables in the Thor folder
		This.OpenThorTables()
	
		Select Thor
		Use (Dbf()) Exclusive Alias (Alias())
		Pack
	
		Select ToolHotKeyAssignments
		Use (Dbf()) Exclusive Alias (Alias())
		Delete For HotKeyID = 0
		Pack
	
		Select MenuDefinitions
		Use (Dbf()) Exclusive Alias (Alias())
		Pack
	
		Select MenuTools
		Use (Dbf()) Exclusive Alias (Alias())
		Delete For MenuID <= 0
		Pack
	
		Select  Id											;
			From MenuDefinitions							;
			Where (Not Internal)							;
				And Id # 8									;
				And Not Id In (Select  SubmenuID			;
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
	Endproc
			
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
