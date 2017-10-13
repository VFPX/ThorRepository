****************************************************************
*   Author: Tore Bleken October 9, 2011                     *
****************************************************************

* snippet-keyword: case insensitive, NOT in quotes
#Define Snippet_Keyword    NO

* delimiter between parameters, IN QUOTES; if empty, only one parameter
#Define Delimiter_Char       ' '

* minimum number of parameters to be accepted
#Define Min_Parameters      1

* maximum number of parameters to be accepted
#Define Max_Parameters      2
*****************************************************************
Lparameters lcParameters, lcKeyWord

Local loParams As Collection
Local lcParams, lnI, lxResult

lxResult = .F.
Do Case
		* if no parameters passed, this is a request for Help
	Case Pcount() = 0
		lxResult = PublishHelp()

		* Only process our keyword 
	Case Pcount() = 2 And Not Upper ([Snippet_Keyword]) == lcKeyWord
		lxResult = .F. && not mine!

	Otherwise
		lcParams = _oPEMEditor.ExtractSnippetParameters(lcParameters, Delimiter_Char, [Snippet_Keyword], Min_Parameters, Max_Parameters)
		If 'C' = VarType (lcParams)
			lxResult = Process (&lcParams)
		Endif
Endcase

Execscript (_Screen.cThorDispatcher, 'Result=', lxResult)
Return lxResult


*****************************************************************
Function CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
   Local loResult As [Empty]
   loResult = Createobject ([Empty])
   AddProperty (loResult, [Name], [Snippet_Keyword])
   AddProperty (loResult, [Syntax], Evl (lcSyntax, []))
   AddProperty (loResult, [Summary], Evl (lcSummaryHTML, []))
   AddProperty (loResult, [Detail], Evl (lcDetailHTML, []))
   Return loResult
Endproc
*****************************************************************
#Define CRLF Chr(13) + Chr(10)
#Define DisplayCase Lower && Legal values: lower, upper, proper or leave blank
#Define Stripextension 'BIZ,$$$'

Function Process
   Lparameters pcVariable, pcClassFilter
   Local lcClass As String, ;
      lcClassFilter As String, ;
      lcClassInfo As String, ;
      lcClassLib As String, ;
      lcExact As String, ;
      lcNewText As String, ;
      lcPasteText As String, ;
      lcPrefix As String, ;
      lcVariable As String, ;
      llClipboard As Boolean, ;
      llCommandWindow As Boolean, ;
      llFullpath As Boolean, ;
      llMethod As Boolean, ;
      llPartOfClass As Boolean, ;
      llPartOfClasslib As Boolean, ;
      llRefresh As Boolean, ;
      lnClasses As Number, ;
      lnHits As Number, ;
      lnI As Number, ;
      loContextMenu As Object, ;
      loEditorWin As Object
   If Pcount() = 1
      pcClassFilter = Getwordnum(pcVariable, 2, [=])
      pcVariable = Getwordnum(pcVariable, 1, [=] )
   Endif
   If Empty(pcClassFilter)
      pcClassFilter = pcVariable
      pcVariable = []
   Endif
   Private llNoProject
   llFullpath = .F. && .T. will include the full path to the classlib also if a project is active
   llPartOfClass = [*] $ pcClassFilter
   llRefresh = [!] $ pcClassFilter
   llPartOfClasslib = [+] $ pcClassFilter
   llClipboard = [-] $ pcClassFilter
   lcClassFilter = Chrtran(pcClassFilter, [*!+-], [])
   llMethod = [.] $ pcVariable
   If llMethod
      lcPrefix = Getwordnum(pcVariable, 1, [.])
      lcVariable = Getwordnum(pcVariable, 2, [.])
   Else
      lcPrefix = []
      lcVariable = pcVariable
   Endif
   loEditorWin = Execscript (_Screen.cThorDispatcher, [class= editorwin from pemeditor])
   llCommandWindow = loEditorWin.FindWindow() = 0
   Do Case
      Case llMethod And Len(lcClassFilter) = 0
         Messagebox([Illegal input!], 0, [], 5000)
         Return
   Endcase
   lcExact = Set([Exact])
   Set Exact Off
   llNoProject = Type([_vfp.activeproject.name]) = [U] Or Empty(_vfp.ActiveProject.Name)
   lcNewText = []
   Do Case
      Case llNoProject
         readClassLibs()
      Case llRefresh Or !Pemstatus(_vfp, [noClasses], 5) Or Empty(_vfp.noClasses);
            Or !Pemstatus(_vfp, [noLenClasses], 5) Or _vfp.noLenClasses = 1
         lnClasses = readClassLibs()
      Otherwise
         lnClasses = _vfp.noLenClasses
   Endcase
   lcClassFilter = Lower(lcClassFilter)
   Do Case
      Case Type([_vfp.activeproject.name]) = [U] And !Pemstatus(_vfp, [noProject], 5)
         AddProperty(_vfp, [noProject], [])
      Case !Pemstatus(_vfp, [noProject], 5)
         AddProperty(_vfp, [noProject], _vfp.ActiveProject.Name)
   Endcase
   Do Case
      Case llNoProject
         _vfp.Noproject = []
         lnClasses = readClassLibs()
      Case llRefresh
         If Type([_vfp.activeproject.name]) = [C]
            _vfp.Noproject = _vfp.ActiveProject.Name
         Endif
         Do readClassLibs
      Case Type([_vfp.activeproject.name]) # [U] And !_vfp.Noproject == _vfp.ActiveProject.Name
         _vfp.Noproject = _vfp.ActiveProject.Name
         Do readClassLibs
   Endcase
   If lnClasses > 1
      loContextMenu = Execscript (_Screen.cThorDispatcher, [class= contextmenu]) &&1
      lnHits = 0
      For lnI = 1 To _vfp.noLenClasses
         lcClassLib  = _vfp.noClasses(lnI, 2)
         lcClass     = _vfp.noClasses(lnI, 1)
         Do Case
            Case llPartOfClass And Len(lcClassFilter) > 0 And lcClassFilter $ Lower(lcClass)
            Case llPartOfClasslib And Len(lcClassFilter) > 0 And;
                  (lcClassFilter $ Lower(lcClass) Or lcClassFilter $ Lower(lcClassLib))
            Case Len(lcClassFilter) > 0 And lcClass = Lower(lcClassFilter)
            Otherwise
               Loop
         Endcase
         lnHits = lnHits + 1
         If llFullpath
            lcClassInfo = ShowCase(lcClass) + [|] + ShowCase(Sys(2014, lcClassLib, Curdir()))
         Else
            lcClassInfo = ShowCase(lcClass) + [|] + ShowCase(lcClassLib)
         Endif
         loContextMenu.AddMenuItem (ShowCase(lcClass) + [ of ] + ShowCase(Sys(2014, lcClassLib, Curdir())), , , , lcClassInfo) &&2
      Endfor
      If lnHits > 0
         If loContextMenu.Activate() &&3
            lcClassInfo = loContextMenu.KeyWord &&4
            lcClass  = Getwordnum (lcClassInfo, 1, [|])
            lcClassLib     = Getwordnum (lcClassInfo, 2, [|])
            loEditorWin = Execscript (_Screen.cThorDispatcher, [Class= editorwin from pemeditor])
            lcPasteText = []
            If Empty(lcVariable)
               lcVariable = 'lo' + Proper(Juststem(lcClass))
               For lnX=1 To Getwordcount(Stripextension,',')
                  lcText = Getwordnum(Stripextension,lnX,',')
                  If Lower(Right(lcVariable,Len(lcText))) == Lower(lcText)
                     lcVariable = Left(lcVariable,Len(lcVariable)-Len(lcText))
                     Exit
                  Endif 
               Endfor
               
            Endif 
            If llMethod
               If llFullpath &&Or llNoProject
                  lcPasteText = lcPrefix + [.NewObject('] + lcVariable + [','] + Juststem(lcClass) + [', '] + Alltrim(lcClassLib) + [')]
               Else
                  lcPasteText = lcPrefix + [.NewObject('] + lcVariable + [','] + Juststem(lcClass) + [', '] + Justfname (lcClassLib) + [')]
               Endif
            Else
               If llFullpath &&Or llNoProject
                  If !llCommandWindow
                     lcPasteText = [Local ] + lcVariable + [ as ] + lcClass + [ of ] + Alltrim(lcClassLib) + CRLF
                  Endif
                  lcPasteText = lcPasteText + lcVariable + [ = NewObject('] + Juststem(lcClass) + [', '] + Alltrim(lcClassLib) + [')]
               Else
                  If llCommandWindow
                     lcPasteText = lcPasteText + lcVariable + [ = NewObject('] + Juststem(lcClass) + [', '] + lcClassLib + [')]
                  Else
                     lcPasteText = [Local ] + lcVariable + [ as ] + lcClass + [ of ] + Justfname (lcClassLib) + CRLF
                     lcPasteText = lcPasteText + lcVariable + [ = NewObject('] + Juststem(lcClass) + [', '] + Justfname (lcClassLib) + [')]
                  Endif
               Endif
            Endif
            If llClipboard
               _Cliptext = Iif(Empty(lcPrefix), lcVariable, lcPrefix + [.] + lcVariable)
            Endif
            If !llCommandWindow
               lcPasteText = lcPasteText + CRLF
            Endif
            loEditorWin.Paste (lcPasteText)
         Endif
      Else
         Messagebox([No match found!], 0 + 48, [], 5000)
      Endif
   Else
   Endif
   If lcExact = [ON]
      Set Exact On
   Endif
   Return
Endfunc
***************************************************************************************************
Function readClassLibs
   Local lcClass As String, ;
      lcFile As String, ;
      lnSelect As Number, ;
      lnX As Number, ;
      lnreturn As Number, ;
      loList As Object, ;
      loTools As Object, ;
      lx, i, lnClasses, laClasses[1]
   lnreturn = 0
   If llNoProject && No active project, use MRU
      loTools = Execscript (_Screen.cThorDispatcher, [Class= tools from pemeditor])
      loList = loTools.GetMRUList([VCX])
      lnSelect = Select()
      Select 0
      Create Cursor curClassLib (Class C(50), Classlib C(100))
      Index On Upper(Classlib) Tag Classlib
      Index On Upper(Class) Tag Class
      For Each lcClass In loList
         Try
            lcFile = Getwordnum(lcClass, 1, [|])
            If Adir(aDummy, lcFile) > 0
					lnClasses = AVcxClasses(laClasses, M.lcFile)
					For i = 1 to M.lnClasses
                     Insert Into curClassLib (Class, Classlib);
								Values (laClasses[M.i, 1], Lower(M.lcFile))
					EndFor
            Endif

         Catch
         Endtry
      Endfor
      Select Distinct Class, Classlib From curClassLib Order By 2, 1 Into Cursor curClassLib Readwrite
      If _Tally > 0
         AddProperty(_vfp, [noClasses(] + Transform(_Tally) + [,2)], .F.)
         AddProperty(_vfp, [noLenClasses], _Tally)
         lnreturn = _Tally
         lnX = 1
         Scan
            Store ShowCase(Trim(curClassLib.Class)) To ([_vfp.noClasses(] + Transform(lnX) + [,1)])
            Store ShowCase(curClassLib.Classlib) To ([_vfp.noClasses(] + Transform(lnX) + [,2)])
            lnX = lnX + 1
         Endscan
      Endif

      Select (lnSelect)
   Else
      loTools = Execscript (_Screen.cThorDispatcher, [class= tools from pemeditor])
      lx = loTools.GetClasslist(, , .T., .F., .T., .F.)
      If Alen(lx.List) > 1
         AddProperty(_vfp, [noClasses(] + Transform(Alen(lx.List, 1)) + [,2)], .F.)
         AddProperty(_vfp, [noLenClasses], Alen(lx.List, 1))
         For lnX = 1 To Alen(lx.List, 1)
            Store ShowCase(lx.List(lnX, 1)) To ([_vfp.noClasses(] + Transform(lnX) + [,1)])
            Store ShowCase(Justfname(lx.List(lnX, 2))) To ([_vfp.noClasses(] + Transform(lnX) + [,2)])
         Endfor
         lnreturn = Alen(lx.List, 1)
      Endif Alen(lx.List) > 1
   Endif

   Return lnreturn
***************************************************************************************************
Function ShowCase
   Lparameters lcText
   Return Trim(DisplayCase(lcText))
***************************************************************************************************
Function PublishHelp
   Local lcDetailHTML, lcSummaryHTML, lcSyntax
   lcSyntax = [Variable=Class]

   Text To lcSummaryHTML Noshow
        Displays a picklist of classes for creating NewObject syntax
   Endtext

   Text To lcDetailHTML Noshow
        Syntax: <b><font color=red>NO var=xxx</font></b><br />
        Displays a popup with all the VCX classes which begin with <b>xxx</b> and creates two lines of code:<br /><br />
        <b>Local var as myclass Of myclassLib<br />
        var = Newobject('myclass','myclasslib.vcx')</b><br /><br />
        If <b>var</b> contains a dot (.), the first part is treated as an object, <br />
        and the NewObject method is used<br /><br />
        <b>prefix.Newobject('var','myclass','myclassLib.vcx')</b><br /><br />
        <b>Options:</b><br /><br />
        <b><font color=red>!</font></b>: forces a refresh of the buffered class list before it is displayed<br />
        <b><font color=red>*</font></b>: <b>xxx</b> is a part of the class name<br />
        <b><font color=red>+</font></b>: <b>xxx</b> is a part of the class name or the classlib name<br />
        <b><font color=red>-</font></b>: puts the name of the variable into the clipboard<br />
        <b>The optional characters must be added immediately before or after xxx</b><br />
        Any combination of the options is legal<br /><br />
        Sample 1: <b><font color=red>NO loMyClass=frm</font></b><br />
        Sample 2: <b><font color=red>NO loMyClass=!frm*</font></b><br />
        Sample 3: <b><font color=red>NO loClock=+-clk</font></b><br /><br />
        <b>Variant: <font color=red>NO xxx</font></b><br />
        With only one parameter, the variable name is calculated as lo + selected class name.<br />
        When only one parameter is used, it is possible to specify certain endings which will be stripped by changing the values of a #define.<br /><br />
        <b>NB! </b>The = is optional, so this is also legal: <b><font color=red>NO var xxx</font></b><br />
        


   Endtext

   Return CreateHelpResult (lcSyntax, lcSummaryHTML, lcDetailHTML)
Endproc

