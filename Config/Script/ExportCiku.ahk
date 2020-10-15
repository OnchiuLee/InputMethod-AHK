#NoEnv
#NoTrayIcon
#SingleInstance, Force
#Include %A_ScriptDir%
#Include ..\Lib\Class_EasyIni.ahk
SetWorkingDir %A_ScriptDir%

WubiIni:=class_EasyIni(A_Temp "\InputMethodData\Config.ini"), Wubi_Schema:=WubiIni.Settings["Wubi_Schema"], BUyaml:=WubiIni.Settings["BUyaml"] 
Frequency:=WubiIni.Settings["Frequency"], Prompt_Word:=WubiIni.Settings["Prompt_Word"], Trad_Mode:=WubiIni.Settings["Trad_Mode"]
MsgBoxRenBtn("单行单义","单行多义","取消")
SchemaName_:=Wubi_Schema~="i)ci"?"含词":Wubi_Schema~="i)zi"?"单字":Wubi_Schema~="i)chaoji"?"超集":"字根"
Gui +OwnDialogs
MsgBox, 262723, 导出提示, 当前为「%SchemaName_%」方案，请选择码表导出格式！！！
IfMsgBox, No
	mabiao:=1
else IfMsgBox, Cancel
{
	DB.CloseDB()
	ExitApp
}
FileSelectFolder, OutFolder,*%A_ScriptDir%\,3,请选择导出后保存的位置
if (OutFolder<>"")
{
	DBFileName:=SubStr(A_ScriptDir,1,-13) "DB\wubi98.db", DB := New SQLiteDB
	If !FileExist(DBFileName) {
		MsgBox, 262160, 错误警告, %DBFileName%不存在, 5
		ExitApp
	}
	If !DB.OpenDB(DBFileName) {
		MsgBox, 262160, 数据库DB错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode, 5
		ExitApp
	}
	Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, % "〔" SchemaName_ "〕" (mabiao?"单行多义":"单行单义") "码表导出中...", 码表导出
	startTime:= CheckTickCount()
	if Wubi_Schema~="i)ci"{
		if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off")
			SQL := "SELECT aim_chars,A_Key,D_Key FROM ci WHERE D_Key>0 ORDER BY A_Key,D_Key DESC;"
		else
			SQL := "SELECT aim_chars,A_Key,B_Key FROM ci WHERE B_Key>0 ORDER BY A_Key,B_Key DESC;"
	}else
		SQL := "SELECT aim_chars,A_Key,B_Key FROM " Wubi_Schema " ORDER BY A_Key,B_Key DESC;"
	if DB.gettable(SQL,Result){
		Loop % Result.RowCount
		{
			Resoure_ .=Result.Rows[A_index,1] A_tab Result.Rows[A_index,2] A_tab Result.Rows[A_index,3] "`n"
		}
		If mabiao
			Resoure_:=TransformCiku(Resoure_)
		timecount:= CheckTickCount(startTime)
		If (FileExist("..\..\Sync\header.txt")&&BUyaml&&!mabiao){
			GetFileFormat("..\..\Sync\header.txt",HeadInfo,Encoding)
			If (Encoding="UTF-16BE BOM") {
				MsgBox, 262160, 错误提示, 文件编码格式为〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 5
			}
			HeadInfo:=Wubi_Schema~="i)ci"?HeadInfo:(Wubi_Schema~="i)chaoji"?RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "wubi98_U"):Wubi_Schema~="i)zi"?RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "wubi98_dz"):RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "wubi98_zg"))
			RegExMatch(HeadInfo,"(?<=name\:).+",FileInfo)
			FileInfo:=RegExReplace(FileInfo,"\s+")
			FileDelete, %OutFolder%\%FileInfo%.dict.yaml
			Resoure_:=HeadInfo "`n" Resoure_, HeadInfo:=""
			FileAppend,%Resoure_%,%OutFolder%\%FileInfo%.dict.yaml, UTF-8
		}else{
			FileName:=mabiao?"wubi98-" Wubi_Schema "_多义.txt":"wubi98-" Wubi_Schema "_单义.txt"
			FileDelete, %OutFolder%\%FileName%
			FileAppend,%Resoure_%,%OutFolder%\%FileName%, UTF-8
		}
		Resoure_ :=OutFolder :="", Result_:=Results_:=Result:=[]
		;;MsgBox, 262208, 完成提示, 导出完成用时 %timecount%！,8
		Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 导出完成用时 %timecount%！, 码表导出
		Sleep 8000
		Progress,off
	}else{
		Progress,off
		MsgBox, 262160, 错误提示, 导出失败！, 8
	}
	DB.CloseDB()
}
ExitApp

;;单行单义格式转换为单行多义
TransformCiku(Chars){
	If (Chars="")
		return ""
	If chars~="[^a-zA-Z0-9]\t[a-z]+" {
		consistent_all:={}
		Loop,parse,chars,`n,`r
		{
			If A_LoopField
			{
				consistent_part:=StrSplit(A_LoopField,A_tab)
				If (IsObject(consistent_all[consistent_part[2]]))
					consistent_all[consistent_part[2]].push(consistent_part[1])
				else
					consistent_all[consistent_part[2]]:=[consistent_part[1]]
			}
		}
		For section,element in consistent_all
		{
			For key,value in element
				If value
					loopvalue_.=A_space value
			If loopvalue_
				loopvalue.=section loopvalue_ "`r`n", loopvalue_:=""
		}
		return loopvalue
	}else{
		return 0
	}
}

CheckTickCount(TC:=0){
	if !TC {
		DllCall("QueryPerformanceFrequency", "Int64*", freq), DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
		Return {CB:CounterBefore,Perf:freq}
	}Else{
		DllCall("QueryPerformanceCounter", "Int64*", CounterAfter), t:=(CounterAfter-TC.CB)/TC.Perf
		TickCount:=t<1?t*1000 "毫秒":(t>60?Floor(t/60) "分" mod(t,60) "秒":t "秒")
		Return TickCount
	}
}

GetFileFormat(FilePath,ByRef FileContent,ByRef Encoding){
	FileRead,text,*c %FilePath%
	If (0xBFBBEF=NumGet(&text,"UInt") & 0xFFFFFF){
		Encoding:= "UTF-8 BOM" 
	}else if (0xFFFE=NumGet(&text,"UShort") ){
		Encoding:= "UTF-16BE BOM"
	}else If (0xFEFF=NumGet(&text,"UShort") ){
		Encoding:= "UTF-16LE BOM"
	}
	FileRead,FileContent, %FilePath%
}

MsgBoxRenBtn(btn1="",btn2="",btn3=""){
	Static sbtn1:="", sbtn2:="", sbtn3:="", i=0
	sbtn1 := btn1, sbtn2 := btn2, sbtn3 := btn3, i=0
	SetTimer, MsgBoxRenBtn, 1
	Return

	MsgBoxRenBtn:
		If (hwnd:=WinActive("ahk_class #32770")) {
			if (sbtn1)
				ControlSetText, Button1, % sbtn1, ahk_id %hwnd%
			if (sbtn2)
				ControlSetText, Button2, % sbtn2, ahk_id %hwnd%
			if (sbtn3)
				ControlSetText, Button3, % sbtn3, ahk_id %hwnd%
			SetTimer, MsgBoxRenBtn, Off
		}
		if (i >= 1000)
			SetTimer, MsgBoxRenBtn, Off
		i++
	Return
}
;;=============================================================Class SQLite=========================================================================================
Class SQLiteDB {
	Static Version := ""
	Static _SQLiteDLL := A_ScriptDir . "\SQLite3.dll"    ; 
	Static _RefCount := 0
	Static _MinVersion := "3.6"
	Class _Table {
		__New() {
			This.ColumnCount := 0          ; Number of columns in the result table         (Integer)
			This.RowCount := 0             ; Number of rows in the result table            (Integer)     
			This.ColumnNames := []         ; Names of columns in the result table          (Array)
			This.Rows := []                ; Rows of the result table                      (Array of Arrays)
			This.HasNames := False         ; Does var ColumnNames contain names?           (Bool)
			This.HasRows := False          ; Does var Rows contain rows?                   (Bool)
			This._CurrentRow := 0          ; Row index of last returned row                (Integer)
		}
		GetRow(RowIndex, ByRef Row) {
			Row := ""
			If (RowIndex < 1 || RowIndex > This.RowCount)
				Return False
			If !This.Rows.HasKey(RowIndex)
				Return False
			Row := This.Rows[RowIndex]
			This._CurrentRow := RowIndex
			Return True
		}
		Next(ByRef Row) {
			Row := ""
			If (This._CurrentRow >= This.RowCount)
				Return -1
			This._CurrentRow += 1
			If !This.Rows.HasKey(This._CurrentRow)
				Return False
			Row := This.Rows[This._CurrentRow]
			Return True
		}
		Reset() {
			This._CurrentRow := 0
			Return True
		}
	}  
	Class _RecordSet {
		__New() {
			This.ColumnCount := 0         ; Number of columns                             (Integer)
			This.ColumnNames := []        ; Names of columns in the result table          (Array)
			This.HasNames := False        ; Does var ColumnNames contain names?           (Bool)
			This.HasRows := False         ; Does _RecordSet contain rows?                 (Bool)
			This.CurrentRow := 0          ; Index of current row                          (Integer)
			This.ErrorMsg := ""           ; Last error message                            (String)
			This.ErrorCode := 0           ; Last SQLite error code / ErrorLevel           (Variant)
			This._Handle := 0             ; Query handle                                  (Pointer)
			This._DB := {}                ; SQLiteDB object                               (Object)
		}
		__Delete() {
			If (This._Handle)
				This.Free()
		}
		Next(ByRef Row) {
			Static SQLITE_NULL := 5
			Static SQLITE_BLOB := 4
			Static EOR := -1
			Row := ""
			This.ErrorMsg := ""
			This.ErrorCode := 0
			If !(This._Handle) {
				This.ErrorMsg := "Invalid query handle!"
				Return False
			}
			RC := DllCall("SQLite3.dll\sqlite3_step", "Ptr", This._Handle, "Cdecl Int")
			If (ErrorLevel) {
				This.ErrorMsg := "DllCall sqlite3_step failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			If (RC <> This._DB._ReturnCode("SQLITE_ROW")) {
				If (RC = This._DB._ReturnCode("SQLITE_DONE")) {
					This.ErrorMsg := "EOR"
					This.ErrorCode := RC
					Return EOR
				}
				This.ErrorMsg := This._DB.ErrMsg()
				This.ErrorCode := RC
				Return False
			}
			RC := DllCall("SQLite3.dll\sqlite3_data_count", "Ptr", This._Handle, "Cdecl Int")
			If (ErrorLevel) {
				This.ErrorMsg := "DllCall sqlite3_data_count failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			If (RC < 1) {
				This.ErrorMsg := "Recordset is empty!"
				This.ErrorCode := This._DB._ReturnCode("SQLITE_EMPTY")
				Return False
			}
			Row := []
			Loop, %RC% {
				Column := A_Index - 1
				ColumnType := DllCall("SQLite3.dll\sqlite3_column_type", "Ptr", This._Handle, "Int", Column, "Cdecl Int")
				If (ErrorLevel) {
					This.ErrorMsg := "DllCall sqlite3_column_type failed!"
					This.ErrorCode := ErrorLevel
					Return False
				}
				If (ColumnType = SQLITE_NULL) {
					Row[A_Index] := ""
				} Else If (ColumnType = SQLITE_BLOB) {
					BlobPtr := DllCall("SQLite3.dll\sqlite3_column_blob", "Ptr", This._Handle, "Int", Column, "Cdecl UPtr")
					BlobSize := DllCall("SQLite3.dll\sqlite3_column_bytes", "Ptr", This._Handle, "Int", Column, "Cdecl Int")
					If (BlobPtr = 0) || (BlobSize = 0) {
						Row[A_Index] := ""
					} Else {
						Row[A_Index] := {}
						Row[A_Index].Size := BlobSize
						Row[A_Index].Blob := ""
						Row[A_Index].SetCapacity("Blob", BlobSize)
						Addr := Row[A_Index].GetAddress("Blob")
						DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", Addr, "Ptr", BlobPtr, "Ptr", BlobSize)
					}
				} Else {
					StrPtr := DllCall("SQLite3.dll\sqlite3_column_text", "Ptr", This._Handle, "Int", Column, "Cdecl UPtr")
					If (ErrorLevel) {
						This.ErrorMsg := "DllCall sqlite3_column_text failed!"
						This.ErrorCode := ErrorLevel
						Return False
					}
					Row[A_Index] := StrGet(StrPtr, "UTF-8")
				}
			}
			This.CurrentRow += 1
			Return True
		}
		Reset() {
			This.ErrorMsg := ""
			This.ErrorCode := 0
			If !(This._Handle) {
				This.ErrorMsg := "Invalid query handle!"
				Return False
			}
			RC := DllCall("SQLite3.dll\sqlite3_reset", "Ptr", This._Handle, "Cdecl Int")
			If (ErrorLevel) {
				This.ErrorMsg := "DllCall sqlite3_reset failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			If (RC) {
				This.ErrorMsg := This._DB._ErrMsg()
				This.ErrorCode := RC
				Return False
			}
			This.CurrentRow := 0
			Return True
		}
		Free() {
			This.ErrorMsg := ""
			This.ErrorCode := 0
			If !(This._Handle)
				Return True
			RC := DllCall("SQLite3.dll\sqlite3_finalize", "Ptr", This._Handle, "Cdecl Int")
			If (ErrorLevel) {
				This.ErrorMsg := "DllCall sqlite3_finalize failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			If (RC) {
				This.ErrorMsg := This._DB._ErrMsg()
				This.ErrorCode := RC
				Return False
			}
			This._DB._Queries.Delete(This._Handle)
			This._Handle := 0
			This._DB := 0
			Return True
		}
	}
	Class _Statement {
		__New() {
			This.ErrorMsg := ""           ; Last error message                            (String)
			This.ErrorCode := 0           ; Last SQLite error code / ErrorLevel           (Variant)
			This.ParamCount := 0          ; Number of SQL parameters for this statement   (Integer)
			This._Handle := 0             ; Query handle                                  (Pointer)
			This._DB := {}                ; SQLiteDB object                               (Object)
		}
		__Delete() {
			If (This._Handle)
				This.Free()
		}
		Bind(Index, Type, Param3 := "", Param4 := 0, Param5 := 0) {
			Static SQLITE_STATIC := 0
			Static SQLITE_TRANSIENT := -1
			Static Types := {Blob: 1, Double: 1, Int: 1, Text: 1}
			This.ErrorMsg := ""
			This.ErrorCode := 0
			If !(This._Handle) {
				This.ErrorMsg := "Invalid statement handle!"
				Return False
			}
			If (Index < 1) || (Index > This.ParamCount) {
				This.ErrorMsg := "Invalid parameter index!"
				Return False
			}
			If (Types[Type] = "") {
				This.ErrorMsg := "Invalid parameter type!"
				Return False
			}
			If (Type = "Blob") { ; -----------------; Param3 = BLOB pointer, Param4 = BLOB size in bytes
				If Param3 Is Not Integer
				{
					This.ErrorMsg := "Invalid blob pointer!"
					Return False
				}
				If Param4 Is Not Integer
				{
					This.ErrorMsg := "Invalid blob size!"
					Return False
				}    ; Let SQLite always create a copy of the BLOB
				RC := DllCall("SQLite3.dll\sqlite3_bind_blob", "Ptr", This._Handle, "Int", Index, "Ptr", Param3, "Int", Param4, "Ptr", -1, "Cdecl Int")
				If (ErrorLeveL) {
					This.ErrorMsg := "DllCall sqlite3_bind_blob failed!"
					This.ErrorCode := ErrorLevel
					Return False
				}
				If (RC) {
					This.ErrorMsg := This._ErrMsg()
					This.ErrorCode := RC
					Return False
				}
			}
			Else If (Type = "Double") { ; -------------; Param3 = double value
				If Param3 Is Not Float
				{
					This.ErrorMsg := "Invalid value for double!"
					Return False
				}
				RC := DllCall("SQLite3.dll\sqlite3_bind_double", "Ptr", This._Handle, "Int", Index, "Double", Param3, "Cdecl Int")
				If (ErrorLeveL) {
					This.ErrorMsg := "DllCall sqlite3_bind_double failed!"
					This.ErrorCode := ErrorLevel
					Return False
				}
				If (RC) {
					This.ErrorMsg := This._ErrMsg()
					This.ErrorCode := RC
					Return False
				}
			}
			Else If (Type = "Int") { ;; Param3 = integer value
				If Param3 Is Not Integer
				{
					This.ErrorMsg := "Invalid value for int!"
					Return False
				}
				RC := DllCall("SQLite3.dll\sqlite3_bind_int", "Ptr", This._Handle, "Int", Index, "Int", Param3, "Cdecl Int")
				If (ErrorLeveL) {
					This.ErrorMsg := "DllCall sqlite3_bind_int failed!"
					This.ErrorCode := ErrorLevel
					Return False
				}
				If (RC) {
					This.ErrorMsg := This._ErrMsg()
					This.ErrorCode := RC
					Return False
				}
			}
			Else If (Type = "Text") { ; -------; Param3 = zero-terminated string
				This._DB._StrToUTF8(Param3, ByRef UTF8)
				RC := DllCall("SQLite3.dll\sqlite3_bind_text", "Ptr", This._Handle, "Int", Index, "Ptr", &UTF8, "Int", -1, "Ptr", -1, "Cdecl Int")
				If (ErrorLeveL) {
					This.ErrorMsg := "DllCall sqlite3_bind_text failed!"
					This.ErrorCode := ErrorLevel
					Return False
				}
				If (RC) {
					This.ErrorMsg := This._ErrMsg()
					This.ErrorCode := RC
					Return False
				}
			}
			Return True
		}
		
		Step() {
			This.ErrorMsg := ""
			This.ErrorCode := 0
			If !(This._Handle) {
				This.ErrorMsg := "Invalid statement handle!"
				Return False
			}
			RC := DllCall("SQLite3.dll\sqlite3_step", "Ptr", This._Handle, "Cdecl Int")
			If (ErrorLevel) {
				This.ErrorMsg := "DllCall sqlite3_step failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			If (RC <> This._DB._ReturnCode("SQLITE_DONE"))&& (RC <> This._DB._ReturnCode("SQLITE_ROW")) {
				This.ErrorMsg := This._DB.ErrMsg()
				This.ErrorCode := RC
				Return False
			}
			Return True
		}
		Reset(ClearBindings := True) {
			This.ErrorMsg := ""
			This.ErrorCode := 0
			If !(This._Handle) {
				This.ErrorMsg := "Invalid statement handle!"
				Return False
			}
			RC := DllCall("SQLite3.dll\sqlite3_reset", "Ptr", This._Handle, "Cdecl Int")
			If (ErrorLevel) {
				This.ErrorMsg := "DllCall sqlite3_reset failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			If (RC) {
				This.ErrorMsg := This._DB._ErrMsg()
				This.ErrorCode := RC
				Return False
			}
			If (ClearBindings) {
				RC := DllCall("SQLite3.dll\sqlite3_clear_bindings", "Ptr", This._Handle, "Cdecl Int")
				If (ErrorLevel) {
					This.ErrorMsg := "DllCall sqlite3_clear_bindings failed!"
					This.ErrorCode := ErrorLevel
					Return False
				}
				If (RC) {
					This.ErrorMsg := This._DB._ErrMsg()
					This.ErrorCode := RC
					Return False
				}
			}
			Return True
		}
		Free() {
			This.ErrorMsg := ""
			This.ErrorCode := 0
			If !(This._Handle)
				Return True
			RC := DllCall("SQLite3.dll\sqlite3_finalize", "Ptr", This._Handle, "Cdecl Int")
			If (ErrorLevel) {
				This.ErrorMsg := "DllCall sqlite3_finalize failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			If (RC) {
				This.ErrorMsg := This._DB._ErrMsg()
				This.ErrorCode := RC
				Return False
			}
			This._DB._Stmts.Delete(This._Handle)
			This._Handle := 0
			This._DB := 0
			Return True
		}
	}
	__New() {
		This._Path := ""                  ; Database path                                 (String)
		This._Handle := 0                 ; Database handle                               (Pointer)
		This._Queries := {}               ; Valid queries                                 (Object)
		This._Stmts := {}                 ; Valid prepared statements                     (Object)
		If (This.Base._RefCount = 0) {
			SQLiteDLL := This.Base._SQLiteDLL
			;;FileGetSize, Size_, %SQLiteDLL%, K
			If !FileExist(SQLiteDLL) {
					If (A_PtrSize=4)
						SQLiteDLL:=SubStr(A_ScriptDir,1,-6) "SQLite3_x86\SQLite3.dll"
					Else If (A_PtrSize=8)
						SQLiteDLL:=SubStr(A_ScriptDir,1,-6) "SQLite3_x64\SQLite3.dll"
					If !FileExist(SQLiteDLL){
						MsgBox, 16, SQLiteDB Error, % "SQLite3.dll 不存在!"
						ExitApp
					}
					This.Base._SQLiteDLL := SQLiteDLL
			}
			DllCall("LoadLibrary", "Str", This.Base._SQLiteDLL, "UPtr")
			If !(This.Base.Version := StrGet(DllCall("SQLite3.dll\sqlite3_libversion", "Cdecl UPtr"), "UTF-8")) {
				MsgBox, 16, SQLiteDB Error, % DLL " | " . SQLiteDLL . " 载入错误!",3
				ExitApp
			}
			SQLVersion := StrSplit(This.Base.Version, ".")
			MinVersion := StrSplit(This.Base._MinVersion, ".")
			If (SQLVersion[1] < MinVersion[1]) || ((SQLVersion[1] = MinVersion[1]) && (SQLVersion[2] < MinVersion[2])){
				DllCall("FreeLibrary", "Ptr", DLL)
				MsgBox, 16, SQLite ERROR, % "Version " . This.Base.Version .  " of SQLite3.dll is not supported!`n`n"
					. "You can download the current version from www.sqlite.org!"
				ExitApp
			}
		}
		This.Base._RefCount += 1
	}
	__Delete() {
		If (This._Handle)
			This.CloseDB()
		This.Base._RefCount -= 1
		If (This.Base._RefCount = 0) {
			If (DLL := DllCall("GetModuleHandle", "Str", This.Base._SQLiteDLL, "UPtr"))
				DllCall("FreeLibrary", "Ptr", DLL)
		}
	}
	_StrToUTF8(Str, ByRef UTF8) {
		VarSetCapacity(UTF8, StrPut(Str, "UTF-8"), 0)
		StrPut(Str, &UTF8, "UTF-8")
		Return &UTF8
	}
	_UTF8ToStr(UTF8) {
		Return StrGet(UTF8, "UTF-8")
	}
	_ErrMsg() {
		If (RC := DllCall("SQLite3.dll\sqlite3_errmsg", "Ptr", This._Handle, "Cdecl UPtr"))
			Return StrGet(&RC, "UTF-8")
		Return ""
	}
	_ErrCode() {
		Return DllCall("SQLite3.dll\sqlite3_errcode", "Ptr", This._Handle, "Cdecl Int")
	}
	_Changes() {
		Return DllCall("SQLite3.dll\sqlite3_changes", "Ptr", This._Handle, "Cdecl Int")
	}
	_ReturnCode(RC) {
		Static RCODE := {SQLITE_OK: 0          ; Successful result
			, SQLITE_ERROR: 1       ; SQL error or missing database
			, SQLITE_INTERNAL: 2    ; NOT USED. Internal logic error in SQLite
			, SQLITE_PERM: 3        ; Access permission denied
			, SQLITE_ABORT: 4       ; Callback routine requested an abort
			, SQLITE_BUSY: 5        ; The database file is locked
			, SQLITE_LOCKED: 6      ; A table in the database is locked
			, SQLITE_NOMEM: 7       ; A malloc() failed
			, SQLITE_READONLY: 8    ; Attempt to write a readonly database
			, SQLITE_INTERRUPT: 9   ; Operation terminated by sqlite3_interrupt()
			, SQLITE_IOERR: 10      ; Some kind of disk I/O error occurred
			, SQLITE_CORRUPT: 11    ; The database disk image is malformed
			, SQLITE_NOTFOUND: 12   ; NOT USED. Table or record not found
			, SQLITE_FULL: 13       ; Insertion failed because database is full
			, SQLITE_CANTOPEN: 14   ; Unable to open the database file
			, SQLITE_PROTOCOL: 15   ; NOT USED. Database lock protocol error
			, SQLITE_EMPTY: 16      ; Database is empty
			, SQLITE_SCHEMA: 17     ; The database schema changed
			, SQLITE_TOOBIG: 18     ; String or BLOB exceeds size limit
			, SQLITE_CONSTRAINT: 19 ; Abort due to constraint violation
			, SQLITE_MISMATCH: 20   ; Data type mismatch
			, SQLITE_MISUSE: 21     ; Library used incorrectly
			, SQLITE_NOLFS: 22      ; Uses OS features not supported on host
			, SQLITE_AUTH: 23       ; Authorization denied
			, SQLITE_FORMAT: 24     ; Auxiliary database format error
			, SQLITE_RANGE: 25      ; 2nd parameter to sqlite3_bind out of range
			, SQLITE_NOTADB: 26     ; File opened that is not a database file
			, SQLITE_ROW: 100       ; sqlite3_step() has another row ready
			, SQLITE_DONE: 101}     ; sqlite3_step() has finished executing
		Return RCODE.HasKey(RC) ? RCODE[RC] : ""
	}
	ErrorMsg := ""              ; Error message                           (String) 
	ErrorCode := 0              ; SQLite error code / ErrorLevel          (Variant)
	Changes := 0                ; Changes made by last call of Exec()     (Integer)
	SQL := ""                   ; Last executed SQL statement             (String)
	OpenDB(DBPath, Access := "W", Create := True) {
		Static SQLITE_OPEN_READONLY  := 0x01 ; Database opened as read-only
		Static SQLITE_OPEN_READWRITE := 0x02 ; Database opened as read-write
		Static SQLITE_OPEN_CREATE    := 0x04 ; Database will be created if not exists
		Static MEMDB := ":memory:"
		This.ErrorMsg := ""
		This.ErrorCode := 0
		HDB := 0
		If (DBPath = "")
			DBPath := MEMDB
		If (DBPath = This._Path) && (This._Handle)
			Return True
		If (This._Handle) {
			This.ErrorMsg := "You must first close DB " . This._Path . "!"
			Return False
		}
		Flags := 0
		Access := SubStr(Access, 1, 1)
		If (Access <> "W") && (Access <> "R")
			Access := "R"
		Flags := SQLITE_OPEN_READONLY
		If (Access = "W") {
			Flags := SQLITE_OPEN_READWRITE
			If (Create)
				Flags |= SQLITE_OPEN_CREATE
		}
		This._Path := DBPath
		This._StrToUTF8(DBPath, UTF8)
		RC := DllCall("SQLite3.dll\sqlite3_open_v2", "Ptr", &UTF8, "PtrP", HDB, "Int", Flags, "Ptr", 0, "Cdecl Int")
		If (ErrorLevel) {
			This._Path := ""
			This.ErrorMsg := "DLLCall sqlite3_open_v2 failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This._Path := ""
			This.ErrorMsg := This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		This._Handle := HDB
		Return True
	}
	CloseDB() {
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := ""
		If !(This._Handle)
			Return True
		For Each, Query in This._Queries
			DllCall("SQLite3.dll\sqlite3_finalize", "Ptr", Query, "Cdecl Int")
		RC := DllCall("SQLite3.dll\sqlite3_close", "Ptr", This._Handle, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := "DLLCall sqlite3_close failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This.ErrorMsg := This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		This._Path := ""
		This._Handle := ""
		This._Queries := []
		Return True
	}
	AttachDB(DBPath, DBAlias) {
		Return This.Exec("ATTACH DATABASE '" . DBPath . "' As " . DBAlias . ";")
	}
	DetachDB(DBAlias) {
		Return This.Exec("DETACH DATABASE " . DBAlias . ";")
	}
 	Exec(SQL, Callback := "") {
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := SQL
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		CBPtr := 0
		Err := 0
		If (FO := Func(Callback)) && (FO.MinParams = 4)
			CBPtr := RegisterCallback(Callback, "F C", 4, &SQL)
		This._StrToUTF8(SQL, UTF8)
		RC := DllCall("SQLite3.dll\sqlite3_exec", "Ptr", This._Handle, "Ptr", &UTF8, "Int", CBPtr, "Ptr", Object(This), "PtrP", Err, "Cdecl Int")
		CallError := ErrorLevel
		If (CBPtr)
			DllCall("Kernel32.dll\GlobalFree", "Ptr", CBPtr)
		If (CallError) {
			This.ErrorMsg := "DLLCall sqlite3_exec failed!"
			This.ErrorCode := CallError
			Return False
		}
		If (RC) {
			This.ErrorMsg := StrGet(Err, "UTF-8")
			This.ErrorCode := RC
			DllCall("SQLite3.dll\sqlite3_free", "Ptr", Err, "Cdecl")
			Return False
		}
		This.Changes := This._Changes()
		Return True
	}
	GetTable(SQL, ByRef TB, MaxResult := 0) {
		TB := ""
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := SQL
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		If !RegExMatch(SQL, "i)^\s*(SELECT|PRAGMA)\s") {
			This.ErrorMsg := A_ThisFunc . " requires a query statement!"
			Return False
		}
		Names := ""
		Err := 0, RC := 0, GetRows := 0
		I := 0, Rows := Cols := 0
		Table := 0
		If MaxResult Is Not Integer
			MaxResult := 0
		If (MaxResult < -2)
			MaxResult := 0
		This._StrToUTF8(SQL, UTF8)
		RC := DllCall("SQLite3.dll\sqlite3_get_table", "Ptr", This._Handle, "Ptr", &UTF8, "PtrP", Table, "IntP", Rows, "IntP", Cols, "PtrP", Err, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := "DLLCall sqlite3_get_table failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This.ErrorMsg := StrGet(Err, "UTF-8")
			This.ErrorCode := RC
			DllCall("SQLite3.dll\sqlite3_free", "Ptr", Err, "Cdecl")
			Return False
		}
		TB := new This._Table
		TB.ColumnCount := Cols
		TB.RowCount := Rows
		If (MaxResult = -1) {
			DllCall("SQLite3.dll\sqlite3_free_table", "Ptr", Table, "Cdecl")
			If (ErrorLevel) {
				This.ErrorMsg := "DLLCall sqlite3_free_table failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			Return True
		}
		If (MaxResult = -2)
			GetRows := 0
		Else If (MaxResult > 0) && (MaxResult <= Rows)
			GetRows := MaxResult
		Else
			GetRows := Rows
		Offset := 0
		Names := Array()
		Loop, %Cols% {
			Names[A_Index] := StrGet(NumGet(Table+0, Offset, "UPtr"), "UTF-8")
			Offset += A_PtrSize
		}
		TB.ColumnNames := Names
		TB.HasNames := True
		Loop, %GetRows% {
			I := A_Index
			TB.Rows[I] := []
			Loop, %Cols% {
				TB.Rows[I][A_Index] := StrGet(NumGet(Table+0, Offset, "UPtr"), "UTF-8")
				Offset += A_PtrSize
			}
		}
		If (GetRows)
			TB.HasRows := True
		DllCall("SQLite3.dll\sqlite3_free_table", "Ptr", Table, "Cdecl")
		If (ErrorLevel) {
			TB := ""
			This.ErrorMsg := "DLLCall sqlite3_free_table failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		Return True
	}
	Prepare(SQL, ByRef ST) {
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := SQL
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		If !RegExMatch(SQL, "i)^\s*(INSERT|UPDATE|REPLACE)\s") {
			This.ErrorMsg := A_ThisFunc . " requires an INSERT/UPDATE/REPLACE statement!"
			Return False
		}
		Stmt := 0
		This._StrToUTF8(SQL, UTF8)
		RC := DllCall("SQLite3.dll\sqlite3_prepare_v2", "Ptr", This._Handle, "Ptr", &UTF8, "Int", -1, "PtrP", Stmt, "Ptr", 0, "Cdecl Int")
		If (ErrorLeveL) {
			This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_prepare_v2 failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		ST := New This._Statement
		ST.ParamCount := DllCall("SQLite3.dll\sqlite3_bind_parameter_count", "Ptr", This._Handle, "Cdecl Int")
		ST._Handle := Stmt
		ST._DB := This
		This._Stmts[Stmt] := Stmt
		Return True
	}
	Query(SQL, ByRef RS) {
		RS := ""
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := SQL
		ColumnCount := 0
		HasRows := False
		If !(This._Handle) {
			This.ErrorMsg := "Invalid dadabase handle!"
			Return False
		}
		If !RegExMatch(SQL, "i)^\s*(SELECT|PRAGMA)\s|") {
			This.ErrorMsg := A_ThisFunc . " requires a query statement!"
			Return False
		}
		Query := 0
		This._StrToUTF8(SQL, UTF8)
		RC := DllCall("SQLite3.dll\sqlite3_prepare_v2", "Ptr", This._Handle, "Ptr", &UTF8, "Int", -1, "PtrP", Query, "Ptr", 0, "Cdecl Int")
		If (ErrorLeveL) {
			This.ErrorMsg := "DLLCall sqlite3_prepare_v2 failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This.ErrorMsg := This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		RC := DllCall("SQLite3.dll\sqlite3_column_count", "Ptr", Query, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := "DLLCall sqlite3_column_count failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC < 1) {
			This.ErrorMsg := "Query result is empty!"
			This.ErrorCode := This._ReturnCode("SQLITE_EMPTY")
			Return False
		}
		ColumnCount := RC
		Names := []
		Loop, %RC% {
			StrPtr := DllCall("SQLite3.dll\sqlite3_column_name", "Ptr", Query, "Int", A_Index - 1, "Cdecl UPtr")
			If (ErrorLevel) {
				This.ErrorMsg := "DLLCall sqlite3_column_name failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			Names[A_Index] := StrGet(StrPtr, "UTF-8")
		}
		RC := DllCall("SQLite3.dll\sqlite3_step", "Ptr", Query, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := "DLLCall sqlite3_step failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC = This._ReturnCode("SQLITE_ROW"))
			HasRows := True
		RC := DllCall("SQLite3.dll\sqlite3_reset", "Ptr", Query, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := "DLLCall sqlite3_reset failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		RS := new This._RecordSet
		RS.ColumnCount := ColumnCount
		RS.ColumnNames := Names
		RS.HasNames := True
		RS.HasRows := HasRows
		RS._Handle := Query
		RS._DB := This
		This._Queries[Query] := Query
		Return True
	}
	CreateScalarFunc(Name, Args, Func, Enc := 0x0801, Param := 0) {
		This.ErrorMsg := ""
		This.ErrorCode := 0
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		RC := DllCall("SQLite3.dll\sqlite3_create_function", "Ptr", This._Handle, "AStr", Name, "Int", Args, "Int", Enc, "Ptr", Param, "Ptr", Func, "Ptr", 0, "Ptr", 0, "Cdecl Int")
		If (ErrorLeveL) {
			This.ErrorMsg := "DllCall sqlite3_create_function failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This.ErrorMsg := This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		Return True
	}
	LastInsertRowID(ByRef RowID) {
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := ""
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		RowID := 0
		RC := DllCall("SQLite3.dll\sqlite3_last_insert_rowid", "Ptr", This._Handle, "Cdecl Int64")
		If (ErrorLevel) {
			This.ErrorMsg := "DllCall sqlite3_last_insert_rowid failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		RowID := RC
		Return True
	}
	TotalChanges(ByRef Rows) {
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := ""
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		Rows := 0
		RC := DllCall("SQLite3.dll\sqlite3_total_changes", "Ptr", This._Handle, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := "DllCall sqlite3_total_changes failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		Rows := RC
		Return True
	}
	SetTimeout(Timeout := 1000) {
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := ""
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		If Timeout Is Not Integer
			Timeout := 1000
		RC := DllCall("SQLite3.dll\sqlite3_busy_timeout", "Ptr", This._Handle, "Int", Timeout, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := "DllCall sqlite3_busy_timeout failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This.ErrorMsg := This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		Return True
	}
	EscapeStr(ByRef Str, Quote := True) {
		This.ErrorMsg := ""
		This.ErrorCode := 0
		This.SQL := ""
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		If Str Is Number
			Return True
		OP := Quote ? "%Q" : "%q"
		This._StrToUTF8(Str, UTF8)
		Ptr := DllCall("SQLite3.dll\sqlite3_mprintf", "Ptr", &OP, "Ptr", &UTF8, "Cdecl UPtr")
		If (ErrorLevel) {
			This.ErrorMsg := "DllCall sqlite3_mprintf failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		Str := This._UTF8ToStr(Ptr)
		DllCall("SQLite3.dll\sqlite3_free", "Ptr", Ptr, "Cdecl")
		Return True
	}
	StoreBLOB(SQL, BlobArray) {
		Static SQLITE_STATIC := 0
		Static SQLITE_TRANSIENT := -1
		This.ErrorMsg := ""
		This.ErrorCode := 0
		If !(This._Handle) {
			This.ErrorMsg := "Invalid database handle!"
			Return False
		}
		If !RegExMatch(SQL, "i)^\s*(INSERT|UPDATE|REPLACE)\s") {
			This.ErrorMsg := A_ThisFunc . " requires an INSERT/UPDATE/REPLACE statement!"
			Return False
		}
		Query := 0
		This._StrToUTF8(SQL, UTF8)
		RC := DllCall("SQLite3.dll\sqlite3_prepare_v2", "Ptr", This._Handle, "Ptr", &UTF8, "Int", -1, "PtrP", Query, "Ptr", 0, "Cdecl Int")
		If (ErrorLeveL) {
			This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_prepare_v2 failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		For BlobNum, Blob In BlobArray {
			If !(Blob.Addr) || !(Blob.Size) {
				This.ErrorMsg := A_ThisFunc . ": Invalid parameter BlobArray!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			RC := DllCall("SQLite3.dll\sqlite3_bind_blob", "Ptr", Query, "Int", BlobNum, "Ptr", Blob.Addr, "Int", Blob.Size, "Ptr", SQLITE_STATIC, "Cdecl Int")
			If (ErrorLeveL) {
				This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_bind_blob failed!"
				This.ErrorCode := ErrorLevel
				Return False
			}
			If (RC) {
				This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
				This.ErrorCode := RC
				Return False
			}
		}
		RC := DllCall("SQLite3.dll\sqlite3_step", "Ptr", Query, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_step failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) && (RC <> This._ReturnCode("SQLITE_DONE")) {
			This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		RC := DllCall("SQLite3.dll\sqlite3_finalize", "Ptr", Query, "Cdecl Int")
		If (ErrorLevel) {
			This.ErrorMsg := A_ThisFunc . ": DllCall sqlite3_finalize failed!"
			This.ErrorCode := ErrorLevel
			Return False
		}
		If (RC) {
			This.ErrorMsg := A_ThisFunc . ": " . This._ErrMsg()
			This.ErrorCode := RC
			Return False
		}
		Return True
	}
}

SQLiteDB_RegExp(Context, ArgC, Values) {
	Result := 0
	If (ArgC = 2) {
		AddrN := DllCall("SQLite3.dll\sqlite3_value_text", "Ptr", NumGet(Values + 0, "UPtr"), "Cdecl UPtr")
		AddrH := DllCall("SQLite3.dll\sqlite3_value_text", "Ptr", NumGet(Values + A_PtrSize, "UPtr"), "Cdecl UPtr")
		Result := RegExMatch(StrGet(AddrH, "UTF-8"), StrGet(AddrN, "UTF-8"))
	}
	DllCall("SQLite3.dll\sqlite3_result_int", "Ptr", Context, "Int", !!Result, "Cdecl") ; 0 = false, 1 = trus
}
;;==========================================================================================================================================================
