*-----------------------------------------------------------------------------------   
*--Support library to allow getting and setting customer colors for the VFP editor
*--far beyond the built in colors.
*-----------------------------------------------------------------------------------   


*---------------------------------------------
DEFINE CLASS _vfpEditorColorMgr AS Custom
*
DIMENSION aEditorColors[1]


*---------------------------------------
FUNCTION Init
*
*DIMENSION This.aEditorColors[1] 
=This.InitColorArray()
*
ENDFUNC  


*-----------------------------------------------------------------------------------   
*--Loop through the VFP Registry entries
FUNCTION InitColorArray
LOCAL lnLoop    AS Integer    ,; 
      lcRegKey  AS String     ,; 
      lcValue   AS String 
WITH THIS 
   *\\ Redimension array 
   DIMENSION .aEditorColors[7,10]  
   *\\ Fill default values 
   .aEditorColors[1,1] = "EditorCommentColor" 
   .aEditorColors[2,1] = "EditorKeywordColor" 
   .aEditorColors[3,1] = "EditorConstantColor" 
   .aEditorColors[4,1] = "EditorNormalColor" 
   .aEditorColors[5,1] = "EditorOperatorColor" 
   .aEditorColors[6,1] = "EditorStringColor" 
   .aEditorColors[7,1] = "EditorVariableColor"  
   *\\ Get color settings from registry 
   lcRegKey = ; 
   "Software\Microsoft\VisualFoxPro\9.0\Options" 
   *//  
   FOR lnLoop = 1 TO ALEN(.aEditorColors,1) 
       *\\ retrieve registry key value 
       lcValue = .GetRegKey1(.aEditorColors[m.lnLoop,1], m.lcRegKey) 
       IF NOT ISNULL(m.lcValue) 
          *\\ no error condition 
          .aEditorColors[m.lnLoop,2] = m.lcValue 
       ELSE 
          *\\ in case of an error; 
              default to black on white 
          .aEditorColors[m.lnLoop,2] = ; 
           "RGB(0,0,0,255,255,255), Auto, Auto" 
       ENDIF 
       *\\ parse RGB() color expression 
       .ParseColorExpression(m.lnLoop) 
   NEXT 
   *// 
ENDWITH
ENDFUNC 



*-----------------------------------------------------------------------------------
Function GetRegKey1(tcValue AS STRING, tcBaseKey AS STRING)
*
#DEFINE HKEY_CURRENT_USER 0x80000001 
#DEFINE ERROR_SUCCESS     0 
#DEFINE KEY_READ          131097 
*// 
*\\ Mandatory parameter checking 
IF NOT VARTYPE(m.tcValue) == "C" ; 
        OR EMPTY(m.tcValue) 
    *\\ NULL := Error condition! 
    RETURN NULL 
    *// 
ENDIF 
*// 
*\\ Optional parameter normalization 
IF NOT VARTYPE(m.tcBaseKey) == "C" ; 
        OR EMPTY(m.tcBaseKey) 
  tcBaseKey = "Software\Microsoft\VisualFoxPro\9.0\Options" 
ELSE 
  tcBaseKey = ALLTRIM(m.tcBaseKey) 
ENDIF 
*// 

*--define the registry related API calls 
DECLARE INTEGER RegOpenKeyEx IN advapi32; 
    INTEGER hKey,; 
    STRING  lpSubKey,; 
    INTEGER ulOptions,; 
    INTEGER samDesired,; 
    INTEGER @phkResult

DECLARE INTEGER RegQueryValueEx IN advapi32; 
    INTEGER hKey,; 
    STRING  lpValueName,; 
    INTEGER lpReserved,; 
    INTEGER @lpType,; 
    STRING  @lpData,; 
    INTEGER @lpcbData

DECLARE INTEGER RegCloseKey IN advapi32; 
    INTEGER  hKey
    

LOCAL hKey     AS INTEGER ,; 
      lnSize   AS INTEGER ,; 
      lcData   AS STRING  ,; 
      lcResult AS STRING 
hKey = 0 
lnSize = 250 
lcData = SPACE(lnSize) 
lcResult = NULL 
*\\ Opening specified key 
IF RegOpenKeyEx(               ; 
        HKEY_CURRENT_USER    ,; 
        m.tcBaseKey            ,; 
        0                     ,; 
        KEY_READ             ,; 
        @hKey) = ERROR_SUCCESS  
    *\\ Querying the value name 
    IF RegQueryValueEx(      ; 
            m.hKey            ,; 
            m.tcValue        ,; 
            0                ,; 
            0                ,; 
            @lcData            ,; 
            @lnSize) = ERROR_SUCCESS  
        *\\ return value 
        lcResult = LEFT(m.lcData, m.lnSize-1)  
    ENDIF 
ENDIF 
*\\ releasing key handle 
= RegCloseKey(m.hKey) 
RETURN m.lcResult


ENDFUNC     


*---------------------------------------------------------------------------------------
FUNCTION SetRegKeyVal(tcKeyName, tcKeyValue)
*
#DEFINE HKEY_CURRENT_USER 0x80000001 
#DEFINE ERROR_SUCCESS     0 
*#DEFINE KEY_READ          131097

LOCAL rg As Registry, llSuccess, lcOrigVal, lcNewVal, lcOldRGB
rg = CREATEOBJECT("Registry")
llSuccess = .T.
lcNewVal = ""

*--Open the base key
LOCAL rgkey As regkey
rgkey = CREATEOBJECT("regkey", HKEY_CURRENT_USER, "Software\Microsoft\VisualFoxPro\9.0\Options")

*--Update the component keys of the base. 
IF rgkey.OpenKey()

  lcOrigVal = This.GetRegKey1(tcKeyName, "Software\Microsoft\VisualFoxPro\9.0\Options")
  lcOldRGB = SUBSTR(lcOrigVal, AT("RGB", lcOrigVal,1))
  lcOldRGB = LEFT(lcOldRGB, AT(")",lcOldRGB,1))
  
  lcNewVal = "RGB(" + tcKeyValue + "), NoAuto, NoAuto"
  
  x = rgkey.SetValue(tcKeyName, 1, lcNewVal) 
  
  
  IF x
    *Success
  ELSE
    llSuccess = .F.
  ENDIF 
ELSE
  llSuccess = .F.
ENDIF 
*
RETURN llSuccess
ENDFUNC 


*---------------------------------------------------------------------------------------
*--Now parse out the retrieved color values
FUNCTION ParseColorExpression(tnColorIndex AS Integer )
*
LOCAL   lcRGBexpr     AS String  ,; 
        lnAtPos1      AS Integer ,; 
        lnRGBArrayLen AS Integer ,; 
        lnLoop        AS Integer

LOCAL ARRAY aRGB[1,6] 
WITH THIS 
    *\\ extract color values from string 
    lcRGBexpr = .aEditorColors[m.tnColorIndex,2] 
    lnATPos1  = AT("(",m.lcRGBexpr,1)+1 
    lcRGBexpr = SUBSTR(m.lcRGBexpr   ,; 
                        m.lnATPos1   ,; 
                AT(")",m.lcRGBexpr,1)-; 
                        m.lnATPos1) 
    *// lcRGBexpr now looks like ; 
        "0,128,0,255,255,255" 

*\\ parse RGB values to temporary array "aRGB" 
    lnRGBArrayLen = ; 
        ALINES(aRGB, m.lcRGBexpr,1,",") 
*\\ copy RGB values to .aEditorColors array 
    FOR lnLoop = 1 TO m.lnRGBArrayLen 
      .aEditorColors[m.tnColorIndex, m.lnLoop + 1] = ; 
        INT(VAL(aRGB[m.lnLoop])) 
    NEXT 
    *\\ calculate RGB() forecolor hex value 
    .aEditorColors[m.tnColorIndex,8] = "#" + ; 
       RIGHT(TRANSFORM(.aEditorColors[m.tnColorIndex,2],"@0"),2) + ; 
       RIGHT(TRANSFORM(.aEditorColors[m.tnColorIndex,3],"@0"),2) + ; 
       RIGHT(TRANSFORM(.aEditorColors[m.tnColorIndex,4],"@0"),2)
    *\\ calculate RGB() backcolor hex value 
    .aEditorColors[m.tnColorIndex,9] =  "#" + ; 
       RIGHT(TRANSFORM(.aEditorColors[m.tnColorIndex,5],"@0"),2) +; 
       RIGHT(TRANSFORM(.aEditorColors[m.tnColorIndex,6],"@0"),2) +; 
       RIGHT(TRANSFORM(.aEditorColors[m.tnColorIndex,7],"@0"),2)
    *\\ add RTF control word 
    .aEditorColors[m.tnColorIndex,10] = ; 
             "\cf"+TRANSFORM(m.tnColorIndex-1) 
ENDWITH    
ENDFUNC     
    
ENDDEFINE     




* Using Win32 Functions in Visual FoxPro
* example=472
* Class library providing access to the System Registry
 
DEFINE CLASS Registry As Custom
#DEFINE KEY_ALL_ACCESS 0xf003f
*#DEFINE ERROR_SUCCESS 0
#DEFINE REG_SZ 1
#DEFINE REG_EXPAND_SZ 2
#DEFINE REG_BINARY 3
#DEFINE REG_DWORD 4
 
PROCEDURE Init
    DECLARE INTEGER RegOpenKeyEx IN advapi32;
        INTEGER hKey, STRING lpSubKey, INTEGER ulOptions,;
        INTEGER samDesired, INTEGER @phkResult
 
    DECLARE INTEGER RegCreateKeyEx IN advapi32;
        INTEGER hKey, STRING lpSubKey, INTEGER Reserved,;
        STRING lpClass, INTEGER dwOptions, INTEGER samDesired,;
        INTEGER lpSecurityAttributes, INTEGER @phkResult,;
        INTEGER @lpdwDisposition
 
    DECLARE INTEGER RegEnumKeyEx IN advapi32;
        INTEGER hKey, INTEGER dwIndex, STRING @lpName,;
        INTEGER @lpcbName, INTEGER lpReserved,;
        STRING @lpClass, INTEGER @lpcbClass, INTEGER lpftLastWriteTime
 
    DECLARE INTEGER RegQueryInfoKey IN advapi32;
        INTEGER hKey, STRING @lpClass, INTEGER @lpcbClass,;
        INTEGER lpReserved, INTEGER @lpcSubKeys,;
        INTEGER @lpcbMaxSubKeyLen, INTEGER @lpcbMaxClassLen,;
        INTEGER @lpcValues, INTEGER @lpcbMaxValueNameLen,;
        INTEGER @lpcbMaxValueLen, INTEGER lpcbSecurityDescr,;
        INTEGER lpftLastWriteTime 
 
    DECLARE INTEGER RegSetValueEx IN advapi32;
        INTEGER hKey, STRING lpValueName, INTEGER Reserved,;
        INTEGER dwType, STRING @lpData, INTEGER cbData
 
    DECLARE INTEGER RegEnumValue IN advapi32;
        INTEGER hKey, INTEGER dwIndex, STRING @lpszValueName,;
        INTEGER @lpcbValueName, INTEGER lpReserved, INTEGER @lpType,;
        STRING @lpData, INTEGER @lpcbData
 
    DECLARE INTEGER RegCloseKey IN advapi32 INTEGER hKey
    DECLARE INTEGER RegDeleteKey IN advapi32 INTEGER hKey, STRING lpSubKey
 
    DECLARE INTEGER RegDeleteValue IN advapi32;
        INTEGER hKey, STRING lpValueName
 
ENDDEFINE
 
Define Class regkey As Custom
    hparent=0
    hkey=0
    keyname=""
    classname=""
    subkeycount=0
    valuecount=0
    keyvalues=0
    errorcode=0
 
Procedure Init(hparent, keyname)
    This.hparent = Iif(Vartype(hparent)="N", m.hparent, 0)
    This.keyname = Iif(Vartype(m.keyname) = "C", m.keyname, "")
 
Procedure Destroy
    This.closekey
 
Procedure closekey
    If This.hkey <> 0
        = RegCloseKey(This.hkey)
        This.hkey = 0
    Endif
 
Procedure openkey
    This.closekey
    Local hkey
    hkey = 0
    This.errorcode = RegOpenKeyEx(This.hparent, THIS.keyname,;
        0, KEY_ALL_ACCESS, @hkey)
    This.hkey = m.hkey
Return (This.errorcode=ERROR_SUCCESS)
 
Procedure queryinfo
    Local cClass, nClassSize, nSubkeyCount, nMaxSubkeyLen,;
        nMaxClassLen, nValueCount, nMaxValueNameLen, nMaxValueLen
 
    nClassSize = 250
    cClass = Replicate(Chr(0), nClassSize*2)
    Store 0 To nSubkeyCount, nMaxSubkeyLen, nMaxClassLen,;
        nValueCount, nMaxValueNameLen, nMaxValueLen
 
    This.errorcode = RegQueryInfoKey(This.hkey, @cClass, @nClassSize, 0,;
        @nSubkeyCount, @nMaxSubkeyLen, @nMaxClassLen,;
        @nValueCount, @nMaxValueNameLen, @nMaxValueLen, 0,0)
 
    This.subkeycount = nSubkeyCount
    This.valuecount = nValueCount
    This.classname = Substr(cClass, 1, nClassSize*2)
 
Procedure getvalues
    This.keyvalues = Newobject("regvalues", "","", This.hkey)
 
PROCEDURE subkeyexists(cSubkeyName As String, lCreate As Boolean) As Boolean
    If This.hkey = 0
        Return .F.
    ENDIF
 
    LOCAL oSubKey As regkey, lResult
    oSubKey = CREATEOBJECT("regkey", THIS.hKey, cSubKeyName)
    lResult= oSubKey.OpenKey()
 
    IF ((NOT m.lResult) AND m.lCreate)
        THIS.createsubkey(cSubkeyName, "")
        RETURN THIS.subkeyexists(cSubkeyName)
    ENDIF
RETURN m.lResult
 
Procedure createsubkey(cSubkeyName, cSubkeyClass)
    If This.hkey = 0
        Return .F.
    Endif
 
    Local hSubkey, nDisp
    Store 0 To hSubkey, nDisp
 
    This.errorcode = RegCreateKeyEx(This.hkey, cSubkeyName, 0,;
        cSubkeyClass, 0, 0, 0, @hSubkey, @nDisp)
 
    If hSubkey <> 0
        = RegCloseKey(hSubkey)
    Endif
Return (This.errorcode=ERROR_SUCCESS)
 
Procedure deletesubkey(cSubkeyName)
    If This.hkey = 0
        Return .F.
    Endif
 
    IF RegDeleteKey(This.hkey, cSubkeyName) = ERROR_SUCCESS
        RETURN .T.
    ENDIF
 
    LOCAL oSubkey As regkey
    oSubkey = CREATEOBJECT("regkey", THIS.hkey, cSubkeyname)
    IF NOT oSubkey.openkey()
        RETURN .F.
    ENDIF
 
    LOCAL oSubSubkeys As regkeys
    oSubSubkeys = CREATEOBJECT("regkeys", oSubkey.hkey)
    FOR EACH oSubSubkey IN oSubSubkeys
        oSubkey.deletesubkey(oSubSubkey.keyname)
    NEXT
    oSubSubkey=Null
 
    This.errorcode = RegDeleteKey(This.hkey, cSubkeyName)
Return (This.errorcode=ERROR_SUCCESS)
 
Procedure setvalue(cValueName, nValueType, vValue)
    Do Case
    Case This.hkey = 0
        Return .F.
    Case INLIST(nValueType, REG_SZ, REG_EXPAND_SZ)
        If Vartype(vValue)<>"C"
            vValue = TRANSFORM(m.vValue)
        Endif
        vValue = Alltrim(Strtran(vValue, Chr(0),""))+Chr(0)
    Case nValueType=REG_DWORD
        IF Vartype(vValue)<>"N"
            vValue = VAL(m.vValue)
        ENDIF
    Case nValueType=REG_BINARY
        IF NOT Vartype(vValue) $ "CN"
            vValue = TRANSFORM(m.vValue)
        ENDIF
    Case Not Inlist(nValueType, 0,1,2,3,4)
        Return .F.
    Endcase
 
    If Vartype(vValue)="N"
        vValue = num2dword(vValue)
    Endif
 
    This.errorcode = RegSetValueEx(This.hkey, cValueName, 0,;
        nValueType, @vValue, Len(vValue))
Return (This.errorcode=ERROR_SUCCESS)
 
Procedure setvalueint(cValueName, nValue)
Return This.setvalue(cValueName, 4, nValue)
 
Procedure setvaluestr(cValueName, cValue)
Return This.setvalue(cValueName, 1, cValue)
 
Procedure setvaluebin(cValueName, vValue)
Return This.setvalue(cValueName, 3, vValue)
 
Procedure deletevalue(cValueName)
    If This.hkey = 0
        Return .F.
    Else
        This.errorcode = RegDeleteValue(This.hkey, cValueName)
        Return (This.errorcode=ERROR_SUCCESS)
    Endif
 
Enddefine
 
Define Class regvalue As Custom
    valuename = ""
    valuetype = 0
    valuerawdata = ""
 
Procedure Init(cName, nType, cBuffer)
    This.valuename = m.cName
    This.valuetype = m.nType
    This.valuerawdata = m.cBuffer
 
Enddefine
 
Define Class regkeys As Collection
    hparent = 0
 
Procedure Init(hparent)
    This.hparent = m.hparent
 
    Local nIndex, cName, cClass
    nIndex = 0
 
    Do While .T.
        Store "" To cName, cClass
        If This.getsubkey(nIndex, @cName, @cClass) = 0
            Local oSubkey
            oSubkey = CreateObject ("regkey", This.hparent, cName)
            oSubkey.classname = cClass
            This.Add(oSubkey, cName)
            Release oSubkey
        Else
            Exit
        Endif
        nIndex = nIndex + 1
    Enddo
 
Protected Procedure getsubkey(nIndex, cName, cClass)
    Local nNameSize, nClassSize, nResult
    Store 250 To nNameSize, nClassSize
    Store Replicate(Chr(0),nNameSize*2) To cName, cClass
 
    nResult = RegEnumKeyEx(This.hparent, m.nIndex,;
        @cName, @nNameSize, 0, @cClass, @nClassSize, 0)
 
    If nResult = ERROR_SUCCESS
        cName = Substr(cName, 1, nNameSize*2)
        cClass = Substr(cClass, 1, nClassSize*2)
    Else
        Store "" To cName, cClass
    Endif
Return nResult
 
Procedure getregkey(cName As String)
    Local oRegKey As regkey
    oRegKey = Newobject("regkey", "","", This.hparent, m.cName)
Return m.oRegKey
 
Enddefine
 
Define Class regvalues As Collection
    hkey = 0
 
Procedure Init(hkey)
    If Vartype(hkey)="N"
        This.hkey=m.hkey
        This.getvalues
    Endif
 
Procedure getvalues
    Local nIndex
    nIndex = 0
    Do While This.GetValue(nIndex)
        nIndex = nIndex + 1
    Enddo
 
Protected Procedure GetValue(nIndex)
    Local cName, nNameSize, nType, cBuffer, nBufsize, nResult, oValue
    nNameSize = 250
    cName = Replicate(Chr(0), nNameSize*2)
    nType = 0
    nBufsize = 4096
    cBuffer = Replicate(Chr(0), nBufsize*2)
 
    If RegEnumValue(This.hkey, nIndex, @cName, @nNameSize,;
            0, @nType, @cBuffer, @nBufsize) <> ERROR_SUCCESS
        Return .F.
    Endif
 
    cName = Substr(cName, 1, nNameSize*2)
    cBuffer = Substr(cBuffer, 1, nBufsize)
    oValue = Newobject("regvalue", "","", cName, nType, cBuffer)
 
    This.Add(oValue, cName)
 
Enddefine
 
FUNCTION num2dword(lnValue)
#DEFINE m0  256
#DEFINE m1  65536
#DEFINE m2  16777216
    IF lnValue < 0
        lnValue = 0x100000000 + lnValue
    ENDIF
    LOCAL b0, b1, b2, b3
    b3 = Int(lnValue/m2)
    b2 = Int((lnValue - b3*m2)/m1)
    b1 = Int((lnValue - b3*m2 - b2*m1)/m0)
    b0 = Mod(lnValue, m0)
RETURN Chr(b0)+Chr(b1)+Chr(b2)+Chr(b3)
 
FUNCTION num2word(lnValue)
RETURN Chr(MOD(m.lnValue,256)) + CHR(INT(m.lnValue/256))


*-------------------------------------------------------------------------
* Converts color number into RGB components and RGB() string  
FUNCTION Color2RGB(tnColor)
* nColor = nR + nG*256 + nB*256*256
 
LOCAL loColor 
loColor = CREATEOBJECT("Empty") 
ADDPROPERTY(loColor, "nR", BITAND(tnColor, 0xFF))
ADDPROPERTY(loColor, "nG", BITAND(BITRSHIFT(tnColor, 8), 0xFF)) 
ADDPROPERTY(loColor, "nB", BITAND(BITRSHIFT(tnColor, 16), 0xFF))

*--Sometimes return values with preceding zeros were happening.  IIF(EMPTY... fixes this. 
ADDPROPERTY(loColor, "cRGB", ;
    IIF(EMPTY(LTRIM(TRANSFORM(loColor.nR),1,"0")), "0", LTRIM(TRANSFORM(loColor.nR),1,"0")) + "," +  ; 
    IIF(EMPTY(LTRIM(TRANSFORM(loColor.nG),1,"0")), "0", LTRIM(TRANSFORM(loColor.nG),1,"0")) + "," +  ; 
    IIF(EMPTY(LTRIM(TRANSFORM(loColor.nB),1,"0")), "0", LTRIM(TRANSFORM(loColor.nB),1,"0")) )
    
*RETURN loColor
RETURN loColor.cRGB
*
ENDFUNC  











































