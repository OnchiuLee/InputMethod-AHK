;桌面logo
Srf_Tip:
	if (Logo_Switch ~="i)on"&&!srfTool){
		Gui, logo:Destroy
		Gui, SrfTip:Destroy
		Gui, SrfTip:Default
		Scale:=DPIScale?"+DPIScale":"-DPIScale", SrfTip_Width:=SrfTip_Height:=LogoSize   ;方块Logo长宽尺寸
		Gui,SrfTip:+LastFound -Caption +AlwaysOnTop ToolWindow %Scale% +hwndSrf_Tip      ;; -DPIScale
		;;Gui,SrfTip: Add, Pic,x0 y0 w%SrfTip_Width% h%SrfTip_Height% BackgroundTrans gTipMore vTipMore HwndMyTextHwnd
		Gui,SrfTip: Add, Pic,x0 y0 w%SrfTip_Width% h%SrfTip_Height% gTipMore vTipMore, % "HBITMAP:" . CreateColoredBitmap(LogoSize, LogoSize, GetKeyState("CapsLock", "T")?"0x" SubStr(LogoColor_caps,5,2) SubStr(LogoColor_caps,3,2) SubStr(LogoColor_caps,1,2):srf_mode?"0x" SubStr(LogoColor_cn,5,2) SubStr(LogoColor_cn,3,2) SubStr(LogoColor_cn,1,2):"0x" SubStr(LogoColor_en,5,2) SubStr(LogoColor_en,3,2) SubStr(LogoColor_en,1,2))
		;;Gosub ChangeLogoColor
			Gui,SrfTip: Show,NA h%SrfTip_Width% w%SrfTip_Height% x%Logo_X% y%Logo_Y%,Srf_Tip
		Gosub IsExStyle
	}
	Gosub Schema_logo
Return

Schema_logo:
	if (Logo_Switch ~="i)on"&&srfTool){
		Gui, SrfTip:Destroy
		Gui, logo:Destroy
		Gui, logo:Default
		Scale:=DPIScale?"+DPIScale":"-DPIScale", IconMode:=srf_mode?1:3
		Gui, logo: -Caption +AlwaysOnTop ToolWindow border %Scale% +hwndWubi_Gui          ;  -DPIScale 禁止放大
		if FileExist(A_ScriptDir "\config\background.png"){
			Gui, logo:Add, Picture,x0 y0 w191 ,config\background.png
			Gui, logo:Add, Picture,x4 y4 h26 w181 border, config\background.png
		}else{
			Gui, logo:Add, Picture,x0 y0 w191 Icon33,config\WubiIME.icl
			Gui, logo:Add, Picture,x4 y4 h26 w181 border Icon33, config\WubiIME.icl
		}
		Gui, logo:Add, Picture,xp+3 yp+1 w22 BackgroundTrans Icon9 vPics gPics, config\Skins\logoStyle\%StyleN%.icl
		Gui, logo:Add, text,x+3 yp-1 h28 w1 border
		Gui, logo:Add, Picture,x+3 yp+3 w22 BackgroundTrans Icon5 vPics2 gPics2, config\Skins\logoStyle\%StyleN%.icl
		Gui, logo:Add, text,x+3 yp-3 h28 w1 border
		Gui, logo:Add, Picture,x+3 yp+3 w22 BackgroundTrans Icon7 vPics3 gPics3, config\Skins\logoStyle\%StyleN%.icl
		Gui, logo:Add, text,x+3 yp-3 h28 w1 border
		Gui, logo:Add, Picture,x+4 yp+2 w22 BackgroundTrans Icon9 vPics4 gPics4, config\Skins\logoStyle\%StyleN%.icl
		Gui, logo:font
		Gui, logo:font,s12 bold,songti
		Gui, logo:Add, text,x+3 yp-2 h28 w1 border
		sicon:=Wubi_Schema~="i)ci"?11:(Wubi_Schema~="i)zi"?13:Wubi_Schema~="i)chaoji"?12:14)
		Gui, logo:Add, Picture,x+9 yp+3 w44 BackgroundTrans Icon%sicon% gMoveGui vMoveGui Center, config\Skins\logoStyle\%StyleN%.icl
		Gosub SwitchSC
		Gui, logo:Color, EFEFEF
		Gui, logo:Margin, 0,0
		Gui, logo:Show, NA h36 x%Logo_X% y%Logo_Y%,sign_wb
		Gosub IsExStyle
	}
Return

IsExStyle:
	If (Logo_ExStyle)
		WinSet, ExStyle, ^0x20, ahk_id %Srf_Tip%  ;鼠标穿透
	else{
		WinSet, ExStyle, -0x000000A8, ahk_id %Srf_Tip%
		Gui SrfTip:+ToolWindow
	}
	WinSet, TransColor, ffffff %transparentX%,Srf_Tip
	WinSet, TransColor, EFEFEF %transparentX%,sign_wb   ;方案Logo的透明度 数字越大透明度越低最大255，0为完全透明
Return

ChangeLogoColor:
	TipBackgroundBrush := DllCall("CreateSolidBrush", UInt, GetKeyState("CapsLock", "T")?"0x" LogoColor_caps:srf_mode?"0x" LogoColor_cn:"0x" LogoColor_en),GuiHwnd := WinExist("Srf_Tip")
	WindowProcOld := DllCall(A_PtrSize=8 ? "SetWindowLongPtr" : "SetWindowLong", Ptr, Srf_Tip, Int, -4, Ptr, RegisterCallback("WindowProc", "", 4, MyTextHwnd), Ptr) ; 返回值必须设置为 Ptr 或 UPtr 而不是 Int.
Return

ChangeLogoColor2:
	GuiControl,SrfTip:, TipMore,% "HBITMAP:" . CreateColoredBitmap(LogoSize, LogoSize, GetKeyState("CapsLock", "T")?"0x" SubStr(LogoColor_caps,5,2) SubStr(LogoColor_caps,3,2) SubStr(LogoColor_caps,1,2):srf_mode?"0x" SubStr(LogoColor_cn,5,2) SubStr(LogoColor_cn,3,2) SubStr(LogoColor_cn,1,2):"0x" SubStr(LogoColor_en,5,2) SubStr(LogoColor_en,3,2) SubStr(LogoColor_en,1,2))
Return

ShowSrfTip:
	Gosub % srfTool?"Schema_logo":"Srf_Tip"
Return

RestLogo:
	Gosub % srfTool?"SwitchSC":"ChangeLogoColor2"
Return

SwitchSC:
	if Logo_Switch ~="i)on"{
		IconMode:=srf_mode?1:3
		if GetKeyState("CapsLock", "T")
			GuiControl,logo:, Pics,*Icon2 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, Pics,*Icon%IconMode% config\Skins\logoStyle\%StyleN%.icl
		if (symb_mode=2)
			GuiControl,logo:, Pics3,*Icon7 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, Pics3,*Icon8 config\Skins\logoStyle\%StyleN%.icl
		if Trad_Mode~="i)on"
			GuiControl,logo:, Pics2,*Icon6 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, Pics2,*Icon5 config\Skins\logoStyle\%StyleN%.icl
		if Initial_Mode~="i)on"
			GuiControl,logo:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, Pics4,*Icon9 config\Skins\logoStyle\%StyleN%.icl
		sicon_:=Wubi_Schema~="i)ci"?11:(Wubi_Schema~="i)zi"?13:Wubi_Schema~="i)chaoji"?12:14)
		GuiControl,logo:, MoveGui,*Icon%sicon_% config\Skins\logoStyle\%StyleN%.icl
	}
Return

DROP_Status:
	WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
	ToolTip(1, "", "Q1 B" BgColor " T" FontCodeColor " S" 12 " F" Font_)
	ToolTip(1, "词条处理中。。。", "x" A_ScreenWidth-300 " y" A_ScreenHeight-Shell_Wnd-40)
Return

InputStatusInfo(status=1,time=200){
	global tip_pos:={x:GetCaretPos().x,y:GetCaretPos().y+30}
	if not A_OSVersion ~="i)WIN_XP"
	{
		Gosub Ime_Tips
		Sleep,%time%
		Gui, tips: Destroy
	}else{
		WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
		ToolTip,中,% !status?A_ScreenWidth-50:GetCaretPos().x ,% !status?A_ScreenHeight-Shell_Wnd-40:GetCaretPos().y+30
		ToolTip,中,% GetCaretPos().x ,% GetCaretPos().y+30
		Sleep,%time%
		ToolTip
	}
}

Get_IME:
	InputStatusInfo(A_Cursor ~= "i)IBeam"?0:1,180)
Return

; 中英文切换模式
SetHotkey:
	If (A_thishotkey~="i)^(LShift|RShift)$"&&ChoiceItems=3&&srf_all_input) {
		srf_select(A_thishotkey="LShift"?2:3)
	}else{
		srf_mode:=!srf_mode
		if !srf_mode
			UpperScreenMode( RegExReplace(srf_all_input,"\'|\``") )
		If GetKeyState("CapsLock", "T")
			SetCapsLockState , off
		If Logo_Switch~="i)on"
			Gosub RestLogo
		If Logo_Switch~="i)on"
			Gosub Write_Pos
		Gosub Get_IME
	}
	Gosub srf_value_off
Return

Pics:
	if (A_GuiEvent = "Normal"&&srfTool)
	{
			SetCapsLockState , off
			srf_mode:=!srf_mode
			Gosub SwitchSC
	}
Return

Pics2:
	if (A_GuiEvent = "Normal")
	{
		Trad_Mode :=WubiIni.Settings["Trad_Mode"]:=Trad_Mode~="i)off"?"on":"off",WubiIni.save()
		Gosub SwitchSC
	}
Return

Pics3:
	if (A_GuiEvent = "Normal")
	{
		symb_mode :=WubiIni.Settings["symb_mode"]:=symb_mode=1?2:1,WubiIni.save()
		Gosub SwitchSC
	}
Return

Pics4:
	if (A_GuiEvent = "Normal")
	{
		Initial_Mode:=WubiIni.Settings["Initial_Mode"] :=Initial_Mode~="i)off"?"on":"off", WubiIni.save()
		Gosub SwitchSC
	}
Return

;logo开关
Logo_Switch:
	Logo_Switch :=WubiIni.Settings["Logo_Switch"] :=Logo_Switch="off"?"on":"off", WubiIni.save()
	if Logo_Switch ~="i)off"{
		Menu, More, Rename, 隐藏Logo , 显示Logo
		Gui, SrfTip:Destroy
		Gui, logo:Destroy
	}else{
		Menu, More, Rename, 显示Logo , 隐藏Logo
		Gosub ShowSrfTip
	}
Return

;logo移动写入坐标
Write_Pos:
	If Logo_Switch ~="i)on" {
		WinGetPos, X_, Y_, , , % srfTool?"sign_wb":"Srf_Tip"
		LWidth:=A_ScreenWidth-LogoSize, LHeight:=A_ScreenHeight-LogoSize
		If X_ not between 0 and %LWidth%
			Logo_X :=WubiIni.Settings["Logo_X"]:=200
		else
			Logo_X :=WubiIni.Settings["Logo_X"]:=X_
		If Y_ not between 0 and %LHeight%
			Logo_Y :=WubiIni.Settings["Logo_Y"]:=y2
		else
			Logo_Y :=WubiIni.Settings["Logo_Y"]:=Y_
		WubiIni.save()
	}
Return

;logo双击操作设定
TipMore:
	if (A_GuiEvent = "DoubleClick")
	{
		srf_mode:=!srf_mode
		Gosub RestLogo
	}
Return

MoveGui:
	if (A_GuiEvent = "Normal"&&!srfTool||srfTool&&A_GuiEvent = "DoubleClick")
	{
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema~="ci"?"zi":(Wubi_Schema~="zi"?"chaoji":(Wubi_Schema~="chaoji"?"zg":"ci")), WubiIni.save()
		Gosub ChangeTray
	}
Return

Switchhxk:
	FontSize :=WubiIni.TipStyle["FontSize"] :=ToolTipStyle~="off|on"?16:22, WubiIni.Save()
	if ToolTipStyle ~="i)on|off"{
		If WinExist("输入法设置") {
			For k,v In ["LineColor","BorderColor","set_GdipRadius","GdipRadius","SBA9","SBA10","SBA12","SBA19","set_FocusRadius","set_FocusRadius_value"]
				GuiControl, 98:Disable, %v%
			For k,v In ["set_regulate_Hx","set_regulate"]
				GuiControl, 98:Enable, %v%
		}
	}else{
		If WinExist("输入法设置") {
			For k,v In ["LineColor","BorderColor","SBA9","SBA10","SBA12","SBA19"]
				GuiControl, 98:Enable, %v%
			For k,v In ["set_regulate_Hx","set_regulate"]
				GuiControl, 98:Disable, %v%
			if Radius~="i)on" {
				For k,v In ["set_GdipRadius","GdipRadius","set_FocusRadius","set_FocusRadius_value"]
					GuiControl, 98:Enable, %v%
			}
		}
	}
	GdipText(""), FocusGdipGui("", "")
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
Return

ChangeTray:
	if Wubi_Schema~="ci" {
		Gosub Enable_Tray
		Menu, More, Enable, 批量造词
		If WinExist("输入法设置") {
			For k,v In ["SBA23","Frequency"]
				GuiControl, 98:Enable, %v%
			if !Frequency {
				For k,v In ["FTip","set_Frequency","RestDB"]
					GuiControl, 98:Disable, %v%
				;;OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
			}else{
				For k,v In ["FTip","set_Frequency","RestDB"]
					GuiControl, 98:Enable, %v%
				;;OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x0178d6})
			}
		}
		If (Logo_Switch~="i)on")
			Gosub SwitchSC
	}else if Wubi_Schema~="zi"{
		Gosub Disable_Tray
		Menu, More, Disable, 批量造词
		If WinExist("输入法设置") {
			For k,v In ["SBA23"]
				GuiControl, 98:Enable, %v%
			For k,v In ["FTip","set_Frequency","RestDB","Frequency"]
				GuiControl, 98:Disable, %v%
			;;OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		}
		If (Logo_Switch~="i)on")
			Gosub SwitchSC
	}else if Wubi_Schema~="chaoji" {
		Gosub Enable_Tray
		Menu, More, Disable, 批量造词
		CharFliter:=WubiIni.Settings["CharFliter"]:= 0, WubiIni.save()
		If WinExist("输入法设置") {
			GuiControl,98:, SBA23, 0
			For k,v In ["SBA23","FTip","set_Frequency","RestDB","Frequency"]
				GuiControl, 98:Disable, %v%
			;;OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		}
		If (Logo_Switch~="i)on")
			Gosub SwitchSC
	}else if Wubi_Schema~="zg"{
		Gosub Disable_Tray
		Menu, More, Disable, 批量造词
		CharFliter:=WubiIni.Settings["CharFliter"]:= 0, WubiIni.save()
		If WinExist("输入法设置") {
			GuiControl,98:, SBA23, 0
			For k,v In ["SBA23", "Frequency", "FTip", "set_Frequency", "RestDB"]
				GuiControl, 98:Disable, %v%
			;;OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		}
		If (Logo_Switch~="i)on")
			Gosub SwitchSC
	}
	Gosub SelectItems
Return

Backup_Conf:
	default_obj:={}
	For Section, element In srf_default_obj
		For key, value In element
			default_obj[Section,key]:=%key%
	if FileExist(A_ScriptDir "\Sync\Default.json")
		FileDelete, %A_ScriptDir%\Sync\Default.json
	Json_ObjToFile(default_obj, A_ScriptDir "\Sync\Default.json", "UTF-8")
	if FileExist(A_ScriptDir "\Sync\Default.json"){
		GuiControl, 98:Enable, Rest_Conf
		Traytip,,配置导出完成！
	}
Return

Rest_Conf:
	Gui +OwnDialogs
	MsgBox, 262452, 提示, 是否覆盖所有配置?
	IfMsgBox, Yes
	{
		default_obj:=Json_FileToObj(A_ScriptDir "\Sync\Default.json")
		For Section, element In default_obj
			For key, value In element
					%key%:=WubiIni[Section, key]:=value
		WubiIni.save()
		Gui,98:Hide
		Gui, 98:Destroy
	}
Return

;托盘菜单
TRAY_Menu:
	global Wubi_Schema
	Menu, Tray, UseErrorLevel
	Menu, TRAY, NoStandard
	Menu, TRAY, DeleteAll
	program:= "※ " Startup_Name " ※" "`n农历日期：" Date2LunarDate(SubStr( A_Now,1,10),GzType)[1] "`n农历时辰：" Time_GetShichen(SubStr( A_Now,9,2))
	Menu, Tray, Add, 帮助,OnHelp
	Menu, TRAY, Icon, 帮助, shell32.dll, 155
	Menu, Tray, Add
	Menu, DB, Add, 词库管理,DB_management
	Menu, DB, Icon, 词库管理, shell32.dll, 151
	Menu, DB, Add
	Menu, DB, Add, 导入词库,OnWrite
	if Wubi_Schema~="i)zi|zg"
		Menu, DB, Disable, 导入词库
	Menu, DB, Icon, 导入词库, shell32.dll, 60
	Menu, DB, Add
	Menu, DB, Add, 合并导出,OnBackup
	if Wubi_Schema~="i)zi|zg"
		Menu, DB, Disable, 合并导出
	Menu, DB, Icon, 合并导出, shell32.dll, 69
	Menu, DB, Add
	Menu, DB, Add, 自造词导出,ciku7
	Menu, DB, Icon, 自造词导出, shell32.dll, 69
/*
	Menu, DB, Add
	Menu, DB, Add, 长字符串导入,Write_LongChars
	Menu, DB, Icon, 长字符串导入, shell32.dll, 60
	Menu, DB, Add
	Menu, DB, Add, 长字符串导出,Backup_LongChars
	Menu, DB, Icon, 长字符串导出, shell32.dll, 69
	Menu, DB, Add
	Menu, DB, Add, 单/多义转换,TransformCiku
	Menu, DB, Icon, 单/多义转换, shell32.dll, 239
*/
	Menu, Tray, Add, 词库,:DB
	Menu, Tray, Icon, 词库, shell32.dll, 131
	Menu, Tray, Add
	Menu, Schema, Add, 含词, ChoiceItems
	Menu, Schema, Add
	Menu, Schema, Add, 单字, ChoiceItems
	Menu, Schema, Add
	Menu, Schema, Add, 超集, ChoiceItems
	Menu, Schema, Add
	Menu, Schema, Add, 五笔•字根, ChoiceItems
	Menu, Schema, Color, FFFFFF
	SCMENU := Menu_GetMenuByName("Schema")
	Menu, More, Add, 方案切换,:Schema
	Menu, More, Icon, 方案切换, shell32.dll, 42
	Menu, More, Add,
	Menu, ToolTipStyle, Add, 系统提示框, ChoiceItems
	Menu, ToolTipStyle, Add
	Menu, ToolTipStyle, Add, GUI候选框, ChoiceItems
	Menu, ToolTipStyle, Add
	Menu, ToolTipStyle, Add, GDI+绘图框, ChoiceItems
	Menu, ToolTipStyle, Color, FFFFFF
	TMENU := Menu_GetMenuByName("ToolTipStyle")
	Menu, More, Add, 批量造词,Add_Code
	Menu, More, Add
	Menu, More, Add, 划译反查,SetRlk
	Menu, More, Icon, 划译反查, shell32.dll, % rlk_switch?145:134
	Menu, More, Add
	Menu, More, Add,% Cut_Mode="on"?"隐藏拆分":"显示拆分",Cut_Mode
	Menu, More, Icon, % Cut_Mode="on"?"隐藏拆分":"显示拆分", shell32.dll, 222
	Menu, More, Add,
	Menu, More, Add, 候选框,:ToolTipStyle
	Menu, More, Icon, 候选框, shell32.dll, 81
	if (Wubi_Schema~="i)zi|chaoji"&&!Addcode_switch)
		Menu, More, Disable, 批量造词
	Menu, More, Icon, 批量造词, shell32.dll, 281
	Menu, More, Add,
	Menu, More, Add, % Logo_Switch="on"?"隐藏Logo":"显示Logo",Logo_Switch
	Menu, More, Icon, % Logo_Switch="on"?"隐藏Logo":"显示Logo", shell32.dll, 141
	Menu, More, Add
	Menu, More, Add, 初始化配置,Initialize
	Menu, More, Icon, 初始化配置, shell32.dll, 236
	Menu, Tray, Add, 更多,:More
	Menu, Tray, Icon, 更多, shell32.dll, 266
	Menu, Tray, Add
	Menu, Tray, Add, 设置, Show_Setting
	Menu, TRAY, Icon, 设置, shell32.dll, 174
	Menu, Tray, Add
	Menu, Tray, Add, 禁用,OnSuspend
	Menu, TRAY, Icon, 禁用, shell32.dll, 175
	Menu, Tray, Add
	Menu, Tray, Add, 更新,OnUpdate
	Menu, TRAY, Icon, 更新, shell32.dll, 14
	Menu, Tray, Add
	Menu, Tray, Add, 重载,OnReload
	Menu, TRAY, Icon, 重载, shell32.dll, 240
	Menu, Tray, Add
	Menu, Tray, Add, 退出,OnExit
	Menu, TRAY, Icon, 退出, shell32.dll, 28
	;Menu, Tray, Default,设置
	Menu, Tray, Color, FFFFFF
	;Menu, Tray, Click, 1
	Menu,Tray,Tip,%program%
	Gosub SelectItems
return

Write_LongChars:
	Gui +OwnDialogs
	MsgBox, 262452, 长字符串词库导入,导入文本遵循以下格式：`n编码+Tab`n+对候选栏显示的词条的说明项`n+Tab+候选栏显示的词条`n+Tab+要上屏的长文本字符串`n空格-->\s  换行-->\n  缩进-->\t`n===【输出方法：/+编码+z】===
	IfMsgBox, Yes
	{
		__Chars:=_Chars:=""
		FileSelectFile, FileContents, 3, , 请选择要导入的文本文件, Text Documents (*.txt)
		If (FileContents<>"")
		{
			SQL =CREATE TABLE IF NOT EXISTS 'extend'.'TangSongPoetics' ("A_Key" TEXT,"Author" TEXT, "B_Key" TEXT, "C_Key" TEXT);delete from TangSongPoetics
			DB.Exec(SQL)
			GetFileFormat(FileContents,_Chars,Encoding)
			If (Encoding="UTF-16BE BOM") {
				MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 10
				Return
			}
			Loop,parse,_Chars,`n,`r
				If A_LoopField 
					CharsObj:=StrSplit(A_LoopField,A_tab), __Chars.="('" RegExReplace(CharsObj[1],"\s+") "','" RegExReplace(CharsObj[2],"\s+") "','" RegExReplace(CharsObj[3],"\s+") "','" RegExReplace(CharsObj[4],"\s+") "')" ","
			If DB.Exec("INSERT INTO 'extend'.'TangSongPoetics' VALUES" RegExReplace(__Chars,"\,$") "")>0
				Traytip,,导入成功！
		}
		__Chars:=_Chars:=FileContents:="", CharsObj:=[]
	}
Return

Backup_LongChars:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,*%A_ScriptDir%\Sync\,3,请选择导出后保存的位置
	if (OutFolder<>"")
	{
		DB.gettable("select * from TangSongPoetics ORDER BY A_Key ASC;",Result)
		If Result.RowCount>0
		{
			For Section,element In Result.Rows
			{
				For key,value in element
					Result_.=value A_Tab
				Result_All.=RegExReplace(Result_,"\t$") "`r`n", Result_:=""
			}
			FileDelete, %OutFolder%\LongString.txt
			FileAppend,%Result_All%,%OutFolder%\LongString.txt,UTF-8
			Traytip,,导出成功！
		}
		OutFolder:=Result_:=Result_All:=""
	}
Return

TransformCiku:
	If FileExist("Config\Script\TransformCiku.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\TransformCiku.ahk"
	}else{
		Gui +OwnDialogs
		FileSelectFile, FileContents, 3, , 请选择要转换的词库文本文件, Text Documents (*.txt)
		If (FileContents<>"")
		{
			startTime:= CheckTickCount()
			Progress, M ZH-1 ZW-1 Y100 FM11 W420 C0 FM14 WS700 CTffffff CW0078d7,, 正在轉換碼錶格式。。。, 碼表轉換
			OnMessage(0x201, "MoveProgress")
			If (!TranCiku(FileContents)) {
				Progress, off
				MsgBox, 262192, 码表转换, 词库格式不支持！, 8
			}else{
				Progress, off
				MsgBox, 262208, 码表转换,% "转换完成耗时" CheckTickCount(startTime), 15
			}
			FileContents:=""
			Progress, off
		}
	}
Return

SelectItems:
	Menu_CheckRadioItem(SCMENU, Wubi_Schema~="i)ci"?1:Wubi_Schema~="i)zi"?3:Wubi_Schema~="i)chaoji"?5:7), Menu_CheckRadioItem(TMENU, ToolTipStyle~="i)on"?1:ToolTipStyle~="i)off"?3:5)
	SchemaType:=CheckWubiVersion(DB), Startup_Name:="五笔" SchemaType["ci"] "版"
	Menu, Schema, Rename, % Menu_GetItemName(SCMENU, 1) , % SchemaType["ci"] "五笔•含词"
	Menu, Schema, Rename, % Menu_GetItemName(SCMENU, 3) , % SchemaType["zi"] "五笔•单字"
	Menu, Schema, Rename, % Menu_GetItemName(SCMENU, 5) , % SchemaType["chaoji"] "五笔•超集"
	If WinExist("输入法设置") {
		Menu_CheckRadioItem(SMENU, Wubi_Schema="ci"?1:Wubi_Schema="zi"?2:Wubi_Schema="chaoji"?3:4), Menu_CheckRadioItem(HMENU, ToolTipStyle ~="i)on"?1:ToolTipStyle ~="i)off"?2:3)
		Menu, SchemaList, Rename, % Menu_GetItemName(SMENU, 1) , % SchemaType["ci"] "五笔•含词"
		Menu, SchemaList, Rename, % Menu_GetItemName(SMENU, 2) , % SchemaType["zi"] "五笔•单字"
		Menu, SchemaList, Rename, % Menu_GetItemName(SMENU, 3) , % SchemaType["chaoji"] "五笔•超集"
	}
Return

ChoiceItems:
	If (A_ThisMenu~="i)Schema"&&A_ThisMenuItemPos)
	{
		;;Menu_CheckRadioItem(SCMENU, A_ThisMenuItemPos)
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:=A_ThisMenuItemPos=1?"ci":A_ThisMenuItemPos=3?"zi":A_ThisMenuItemPos=5?"chaoji":A_ThisMenuItemPos=7?"zg":Wubi_Schema,WubiIni.save()
		Gosub ChangeTray
	}else If (A_ThisMenu~="i)ToolTipStyle"&&A_ThisMenuItemPos) {
		;;Menu_CheckRadioItem(TMENU, A_ThisMenuItemPos), Menu_CheckRadioItem(HMENU, ToolTipStyle ~="i)on"?1:ToolTipStyle ~="i)off"?2:3)
		ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :=A_ThisMenuItemPos=5?"Gdip":A_ThisMenuItemPos=3?"off":"on"
		Gosub Switchhxk
	}
	WubiIni.Save()
Return

Initialize:
	MsgBox, 262452,重置确认, 是否重置输入法配置重新生成？`n如果出现候选框不显示，请重置！
	IfMsgBox Yes
	{
		For Section,element In srf_default_obj
			WubiIni.DeleteSection(Section)
		RunWait *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" Initialize
	}
Return

set_top:
	set_top(PosIndex)
Return

Delete_Word:
	Delete_Word(PosIndex)
Return

set_add:
	set_add(PosIndex)
Return

set_next:
	set_next(PosIndex)
Return

Disable_Tray:
	Menu, DB, Disable, 导入词库
	Menu, DB, Disable, 合并导出
return

Enable_Tray:
	Menu, DB, Enable, 导入词库
	Menu, DB, Enable, 合并导出
return

;挂起操作
OnSuspend:
	Suspend
	if A_IsSuspended {
		Menu, Tray, Icon, config\WubiIME.icl,31, 1
		Menu, TRAY, Rename, 禁用 , 启用
		Menu, TRAY, Icon, 启用, config\WubiIME.icl, 4
		GuiControl,logo:, Pics,*Icon4 config\Skins\logoStyle\%StyleN%.icl
		Traytip,  提示:,已切换至挂起状态！
	}else if !A_IsSuspended {
		if FileExist(IconName_)
			Menu, Tray, Icon, %IconName_%
		else
			Menu, Tray, Icon, config\WubiIME.icl,30
		Menu, TRAY, Rename, 启用 , 禁用
		Menu, TRAY, Icon, 禁用, shell32.dll, 175
		Gosub SwitchSC
		Traytip,  提示:,已切换至启用状态！
	}
return

OnUpdate:
	If FileExist("Config\Script\CheckUpdate.ahk")
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\CheckUpdate.ahk" %versions% %Startup_Name%
	else
		MsgBox, 262160, 错误, %A_ScriptDir%\Config\Script\CheckUpdate.ahk执行脚本不存在！, 10
Return

RemoveFonts:
	if FileExist("Font\*.*tf") {
		Loop,Files,Font\*.*tf
		{
			RemoveFontResource(A_LoopFileLongPath)
		}
	}
Return

;重载操作
OnReload:
	if Logo_Switch ~="i)on"
		Gosub Write_Pos
	reload
return

;写入词库
OnWrite:
	If FileExist("Config\Script\ImportCiku.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\ImportCiku.ahk"
	}else
		Gosub Write_DB
Return

;合并导出
OnBackup:
	If FileExist("Config\Script\ExportCiku.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\ExportCiku.ahk"
	}else{
		MsgBoxRenBtn("单行单义","单行多义","取消")
		SchemaName_:=Wubi_Schema~="i)ci"?"含词":Wubi_Schema~="i)zi"?"单字":Wubi_Schema~="i)chaoji"?"超集":"字根"
		Gui +OwnDialogs
		MsgBox, 262723, 导出提示, 当前为「%SchemaName_%」方案，请选择码表导出格式！！！
		IfMsgBox, Yes
			Gosub Backup_DB
		else IfMsgBox, No
			Gosub Backup_DB_2
	}
Return

;帮助

OnHelp:
	Gui, Info:Destroy
	Gui, Info:Default
	Gui, Info: Margin,10,10
	Gui, Info: Color,ffffff
	Gui, Info:Font, s12 bold, %Font_%
	Gui Info:Add, GroupBox,xm w450 h375 vreadme, 常用快捷操作介绍：
	Gui, Info:Font, s10 norm, %Font_%
	Gui Info:Add, Edit,xm+10 yp+30 w430 h335 ReadOnly -WantCtrlA -WantReturn -border ,一、默认快捷操作：`n`t方案切换：/sc`n`t候选横竖排：/mode`n`t候选框风格：/hx`n`t拆分显示：/cf`n`t简繁切换：/jf`n`t上屏方式切换：/sp`n`t切换至英文键盘：/yw`n`t切换至中文键盘：/zw`n`t候选项位置调整：Ctrl+序号`n`t候选项删除：Ctrl+Alt+序号`n`n二、临时造词方式：`n1、以``键引导后打单字再以``键进行分词会自动组合首选，也可以自己组合，操作完成后上屏即保存。仅在「含词」方案下有效！`n`n2、不用``引导，打单字后同样以``键进行分词亦会自动组合，选择候选词后上屏即保存。这种方式对于首字为四码唯一的单字时无效(须关闭四码唯一上屏后才有效)。`n`n三、临时英文：以「双``键」引导`n四、英文输入模式： /en切换，重复切换反之。`n`n五、以形查音：以「~键(shift+``)」引导，输入单字反查单字读音。`n`n六、鼠标划词反查：默认是关闭的，快捷键Alt+Q开启，鼠标划选汉字后会显示反查后的五笔编码和单字读音以及五笔拆分（需字体支持，在设置窗口切换字体到以98开头的字体才能正常显示）`n`n七、长字符串输出：自带八百多首古诗词，/+作者+z可以快速选择要上屏的内容。需自定义的遵循格式自行导入。`n`n八、临时拼音：以z键引导+拼音、z键已保留原始的万能键匹配形式，默认是临时拼音需要自己更换。`n`n九、特殊符号：/+符号类型，更多/help查看。`n`n十、扩展功能：`n`n`t/+数字或有序日期==> 金额转换、农历转公历、公历转农历、节气查询、干支纪年查询。`n`n`t实时时间输出：/nl、/zznl、 /zzsj、 /zzrq`n`n`t/mac 输出电脑部分参数 /ip查询本机IP`n`n基本使用帮助提示输入help查看快捷键操作。`n`n如果初次运行候选框显示异常，请从托盘菜单--更多--初始化 来解决。
	GuiControl,Info:Focus,readme
	Gui, Info:Show,AutoSize,使用介绍
	Gosub ChangeWinIcon
	;;;Run, rundll32.exe "%A_ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll"`, ImageView_Fullscreen %A_ScriptDir%\config\ReadMe.png,, UseErrorLevel
return

;退出设定
OnExit:
	DB.CloseDB()
	;;Gosub RemoveFonts
	Json_ObjToFile(Frequency_Obj, A_ScriptDir "\Config\Script\WubiCiku.json", "UTF-8")
	if not A_OSVersion ~="i)WIN_XP"
		SwitchToChsIME()
	ExitApp
return

;gui候选框
houxuankuangguicreate:
	Gui, houxuankuang:Destroy
	Gui, houxuankuang:+ToolWindow -Caption -DPIScale +AlwaysOnTop +hWndguihouxuankuang +Border
	Gui, houxuankuang:Font,s%FontSize% , % EN_Mode||srf_all_input~="^[``]{2}\w+"?EnFontName:FontType
	Gui, houxuankuang:Color, %BgColor%
	Gui, houxuankuang:Add, Text, x5 y3 vmyedit1 BackgroundTrans c%FontCodeColor%
	if Gdip_Line ~="i)on"
		Gui, houxuankuang:Add, Text, x0 yp+15 w%A_ScreenWidth% h1 0x10 vfengefu
	Gui, houxuankuang:Add, Text, x5 vmyedit2 BackgroundTrans c%FontColor%
	Gui, houxuankuang:Show, % "Hide x" A_ScreenWidth//2-A_ScreenWidth//8 " y" A_ScreenHeight-200
	Tip1hWnd:=ToolTip(1, "", "Q1 B" BgColor " T" FontCodeColor " S" FontSize*A_ScreenDPI/96 " F" (EN_Mode||srf_all_input~="^[``]{2}\w+"?EnFontName:FontType))
	Tip2hWnd:=ToolTip(2, "", "Q1 B" BgColor " T" FontColor " S" FontSize*A_ScreenDPI/96 " F" (EN_Mode||srf_all_input~="^[``]{2}\w+"?EnFontName:FontType))
	Height:=60
Return

;提词结果处理
srf_tooltip:
	If (!EN_Mode){
		if (StrLen(srf_all_input)=4&&srf_all_input ~="^[a-yA-Y]+$")
		{
			if srf_for_select_Array.Length()=0{    ;如果无候选，则自动清空
				srf_for_select_for_tooltip:=
			}
			else if (srf_for_select_Array.Length()=1&&length_code="on") ;如果候选唯一，则自动上屏
			{
				srf_select(1)
				gosub srf_value_off
			}
		}
		else if (StrLen(srf_all_input)>4&&srf_all_input ~="^[a-yA-Y]+$"&&limit_code ="on") ;五码顶字上屏，排除编码含z的拼音反查
		{
			srf_for_select_for_tooltip:=RegExReplace(srf_for_select_for_tooltip,"\s.+|\n.+|^\w+\.|\〔.+")
			UpperScreenMode(StrSplit(srf_for_select_for_tooltip,Textdirection ~="i)vertical"?"`n":A_Space)[1])
			srf_all_input :=RegExReplace(srf_all_input, "^[a-zA-Z]{4}", ""), updateRecent(srf_for_select_for_tooltip)
			CharsTotalCount["Count"]:=InputCount:=SubStr(A_Now,1,8)<>SubStr(CharsTotalCount["Time"],1,8)?StrLen(srf_for_select_for_tooltip):InputCount+StrLen(srf_for_select_for_tooltip), CharsTotalCount["Time"]:=SubStr(A_Now,1,8)<>SubStr(CharsTotalCount["Time"],1,8)?A_Now:CharsTotalCount["Time"]
			, Json_ObjToFile(CharsTotalCount,A_Temp "\InputMethodData\CharacterCount.json")
			Gosub srf_tooltip_fanye
		}
		else if StrLen(srf_all_input)<4&&srf_for_select_Array.Length()=0&&srf_all_input ~="^[a-yA-Y]+$"
		{
			srf_for_select_for_tooltip :=
		}
	}
	else
	{
		if strlen(srf_all_input)>0&&srf_for_select_Array.Length()<1
			srf_for_select_for_tooltip :=
	}
	if srf_all_input ~="^z.+|^z|^``|^/|^~"
	{
		if (srf_for_select_Array.Length()<1)
			srf_for_select_for_tooltip :=
	}	
	Gosub showhouxuankuang
	srf_for_select_for_tooltip :=strlen(srf_all_input)>4&&srf_for_select_Array.Length()<1?"":srf_for_select_for_tooltip
Return

;候选下一页
MoreWait:
	If (waitnum*ListNum+ListNum<srf_for_select_Array.Length()){
		waitnum+=1
		Gosub srf_tooltip_cut
	}
Return

;候选上一页
lessWait:
	If (waitnum>0){
		waitnum-=1
		Gosub srf_tooltip_cut
	}
Return

Frequency:
	Frequency:=WubiIni.Settings["Frequency"]:=!Frequency, WubiIni.save()
	if !Frequency {
		For k,v In ["FTip","set_Frequency","RestDB"]
			GuiControl, 98:Disable, %v%
		;;OD_Colors.Attach(FRDL,{T: 0x767641, B: 0xb3b3b3})
	}else{
		For k,v In ["FTip","set_Frequency","RestDB"]
			GuiControl, 98:Enable, %v%
		;;OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x0178d6})
	}
Return

set_Frequency:
	GuiControlGet, set_Frequency,, set_Frequency, text
	Freq_Count:=WubiIni.Settings["Freq_Count"]:=set_Frequency, WubiIni.save()
Return

RestDB:
	Gui +OwnDialogs
	MsgBox, 262452,重置确认, 是否重置词频？
	IfMsgBox Yes
		if DB.Exec("UPDATE ci SET D_Key=B_Key;")>0
			Traytip,,重置成功！
	
Return

symbolsInfo:
	Textdirection:=Textdirection~="i)horizontal"?"vertical":"vertical", ListNum:=ListNum<10?10:10,FontSize:=ToolTipStyle~="i)Gdip"?18:FontSize
	SymList:=[["/+年月日⇒农历/公历互转 ● /+【date/week/time/nl/zzrq/zznl/zzsj】⇒输出日期时间 ● /+数字⇒金额大写转换"]
		,["数字/0-9 ● 分数/fs ● 月份/yf ● 日期/rq ● 符号/fh ● 电脑/dn ● 象棋/xq ● 麻将/mj ● 曜日/yr ● 地支/dz"]
		,["色子/sz  ● 扑克/pk ● 表情/bq ● 天气/tq ● 音乐/yy ● 两性/lx ● 八卦/bg ● 星座/xz ● 偏旁/pp ● 干支/gz"]
		,["上标/sb  ● 下标/xb ● 天体/tt ● 星号/xh ● 方块/fk ● 几何/jh ● 箭头/jt ● 数学/sx ● 声调/sd ● 结构/jg"]
		,["时间/sj  ● 货币/hb ● 节气/jq ● 单位/dw ● 笔画/bh ● 天干/tg ● 注音/zy ● 标点英/bd ● 标点中/bdz"]
		,["六十四卦/lssg ● 六十四卦名/lssgm ● 太玄经/txj ● 八卦名/bgm ● 十二宫/seg ● 苏州码/szm ● 康熙部首/kx"]
		,["星座名/xzm ● 拼音小写/py ● 拼音大写/pyd ● 俄语/ey ● 俄语大写/eyd ● 字母弧/zmh ● 汉字弧/hzh"]
		,["罗马数字/lm ● 罗马数字大写/lmd ● 希腊/xl ● 希腊大写/xld ● jいろは顺/iro ● 假名半角/jmb ● 韩文/hw"]
		,["韩文圈/hwq● 汉字圈/hzq ● 数字圈/szq ● 数字弧/szh ● 韩文弧/hwh ● 数字点/szd ● 字母圈/zmq ● 假名圈/jmq"]
		,["假名/jm/pjm/jmk/jmg/jms/jmz/jmt/jmd/jmn/jmh/jmb/jmp/jmm/jmy/jmr/jmw/jma/jmi/jmu/jme/jmo"]]
	srf_for_select_Array:=SymList
Return

helpInfo:
	Textdirection:="vertical", ListNum:=10
	srf_for_select_Array:=[["简繁模式"," 热键" GetkeysName(s2thotkey) " 组合","〔 热键" GetkeysName(s2thotkey) " 组合 〕"]
		,["程序挂起"," 热键" GetkeysName(Suspendhotkey) " 组合","〔 热键" GetkeysName(Suspendhotkey) " 组合 〕"]
		,["以形查音"," ~键引导 ","〔 ~键引导 〕"]
		,["方案切换","〔 /sc 切换方案 〕","〔 /sc 切换方案 〕"]
		,["精准造词"," ``键引导+``键分词 ","〔 ``键引导+``键分词 〕"]
		,["划译反查"," 热键" GetkeysName(tiphotkey) " 开/关 ","〔 热键" GetkeysName(tiphotkey) " 开/关 〕"]
		,["临时英文"," 双``键引导 ","〔 双``键引导 〕"]
		,["快捷退出"," 热键" GetkeysName(exithotkey) " 组合","〔 热键" GetkeysName(exithotkey) " 组合 〕"]
		,["编码反查"," 反查方式：" (zkey_mode=1?"模糊匹配":zkey_mode=2?"笔画反查":"临时拼音"),"〔  反查方式：" (zkey_mode=1?"模糊匹配":zkey_mode=2?"笔画反查":"临时拼音") " 〕"]
		,["拆分显示"," 热键" GetkeysName(cfhotkey) " 组合","〔 热键" GetkeysName(cfhotkey) " 组合 〕"]
		,["批量造词"," 热键" GetkeysName(AddCodehotkey) " 组合 ","〔 热键" GetkeysName(AddCodehotkey) " 组合 〕"]]
Return

;候选词条分页处理
srf_tooltip_fanye:
	;PrintObjects(srf_for_select_Array)
	for Section,element in {TipStyle:["Textdirection","ListNum","FontSize"]}
		for key,value in element
			if (WubiIni[Section, value]<>%value%)
				%value%:=WubiIni[Section,value]
	if srf_all_Input ~="^``"&&!EN_Mode{
		if (srf_all_Input~="^``[a-z]+"&&Wubi_Schema~="i)ci"&&!EN_Mode){
			srf_for_select_Array:=format_word(RegExReplace(srf_all_Input,"^``"))
			if (srf_for_select_Array[1]<>select_arr&&select_arr[1]<>""){
				srf_for_select_Array.InsertAt(1, select_arr)
			}
			Gosub srf_tooltip_cut
		}else if (RegExReplace(srf_all_Input,"^``")~="\``[a-z]+"&&!EN_Mode){
			srf_for_select_Array:=prompt_enword(RegExReplace(srf_all_Input,"^````",""))
			Gosub srf_tooltip_cut
		}else if (srf_all_Input~="^[``]{1,2}$"){
			Sym_Array[1,1]:="``", srf_for_select_Array:=Sym_Array, code_status:=localpos:=srfCounts:=1,select_arr:=[],Select_result:=""
			Gosub srf_tooltip_cut
		}else if (srf_all_Input~="^[``]{3,}$"){
			Gosub srf_value_off
		}
	}else if srf_all_Input ~="^/"{
		if srf_all_Input~="^/[a-z]+|^/[0-9]+"
		{
			labelObj:=[]
			if srf_all_input ~="/help"
				Gosub symbolsInfo
			else{
				srf_for_select_Array:=prompt_symbols(srf_all_Input)
				if (srf_all_input~="^\/[a-z]+z$"&&strlen(srf_all_Input)>3&&srf_for_select_Array.Length()>0) {
					ts_Array:=get_Longword(RegExReplace(srf_all_Input,"z$|^\/"))
					If ts_Array.Length()>0
					{
						Textdirection:="vertical"
						For Section,element In ts_Array
							srf_for_select_Array.InsertAt(Section+2,element)
					}
				}else If (srf_all_input~="^\/[a-z]+z$"&&strlen(srf_all_Input)>3&&srf_for_select_Array.Length()<1)
					Textdirection:="vertical", srf_for_select_Array:=get_Longword(RegExReplace(srf_all_Input,"z$|^\/"))
				If objCount(JsonData_Date[SubStr(srf_all_input,2)]) {
					Textdirection:="vertical"
					For key,value In JsonData_Date[SubStr(srf_all_input,2)]
						srf_for_select_Array.InsertAt(A_Index,[ value~="^[dghHmMsy]"?FormatTime("",value):FormatTime(formatDate(value),FormatDate(value,2,1))])
				}
			}
		}else{
			Sym_Array_1[1,1]:=srf_all_input, srf_for_select_Array:=Sym_Array_1
		}
		Gosub srf_tooltip_cut
	}else if (srf_all_Input ~="^z"&&!EN_Mode){
		if srf_all_Input~="^z\w+|^z\'\w+" {
			srf_all_input:=!zkey_mode?RegExReplace(srf_all_input,"^z|^z\'",srf_all_input~="'"?"z":"z'"):srf_all_input, srf_for_select_Array:=get_word(srf_all_input, Wubi_Schema)
		}else If srf_all_input~="^z$"&&zkey_mode<2{
			For key,value In recent
				srf_for_select_Array.Push([value])
		}
		Gosub srf_tooltip_cut
	}else if srf_all_Input ~="^~"&&!EN_Mode{
		if srf_all_Input ~="^~[a-z]+"
			srf_for_select_Array:=prompt_pinyin(srf_all_Input)
		else if srf_all_Input ~="^~$"
			Sym_Array:=[],Sym_Array[1,1]:=srf_all_Input, Sym_Array[2,1]:="～",srf_for_select_Array:=Sym_Array
		Gosub srf_tooltip_cut
	}else if (srf_all_Input ~="^[a-y]{1,4}``"&&!EN_Mode){
		srf_for_select_Array:=format_word_2(srf_all_Input)
		Gosub srf_tooltip_cut
	}else{
		If !EN_Mode {
			srf_for_select_Array:=get_word(srf_all_Input, Wubi_Schema)
			if (srf_all_Input ="help"&&!objLength(srf_for_select_Array))
				Gosub helpInfo
			Gosub srf_tooltip_cut
		}else{
			srf_for_select_Array:=Get_EnWord(srf_all_Input)
			Gosub srf_tooltip_cut
		} 

	}
Return

SendAttachChars:
	UpperScreenMode("〔" srf_for_select_Array[PosIndex+ListNum*waitnum,2] "〕")
Return

GetkeysName(hotkey:=""){
	if (hotkey="")
		Return
	Loop,% StrLen(hotkey)
	{
		hkey:=SubStr(hotkey,A_Index,1), hkey:=RegExReplace(RegExReplace(hkey,"\<","L"),"\>","R")
		hkey:=RegExReplace(RegExReplace(RegExReplace(RegExReplace(hkey,"\+","Shift • "),"\^","Ctrl • "),"\!","Alt • "),"\#","Win • ")
		hkey_.= hkey
	}
	Return hkey_
}

srf_tooltip_cut:
	srf_for_select_string:="", localpos:=1, srf_for_select_obj:=[], loopindex:=srf_for_select_Array.Length()-ListNum*waitnum
	, loopindex:=(loopindex>ListNum?ListNum:loopindex)
	;PrintObjects(srf_for_select_Array)
	If (Textdirection="horizontal")
	{

		for Section,element In srf_for_select_Array
		{
			for key,value in element
			{
				if (Section>ListNum*waitnum&&Section<=ListNum*(waitnum+1)){
					if (key=1) {
						srf_for_select_part:= (StrLen(value)>25&&srf_all_input~="^[a-y]"?SubStr(value,1,25) " •••••":value) ( Cut_Mode="on"&&a_FontList ~="i)" FontExtend &&FontType ~="i)" FontExtend &&srf_for_select_Array[Section, valueindex]<>""?(srf_all_input~="^[a-z]+"?"〔":A_Space) . srf_for_select_Array[Section, valueindex] . (srf_all_input~="^[a-z]+"?"〕":A_Space):A_Space . srf_for_select_Array[Section, 3])
						if (srf_for_select_part<>"") {
							srf_for_select_string.=((srf_all_Input~="\d+"?A_Space A_Space SubStr(Select_Code, Section-ListNum*waitnum , 1):(Cut_Mode~="on"?A_Space:A_Space A_Space) Section-ListNum*waitnum) "." srf_for_select_part), srf_for_select_obj.Push(((srf_all_Input~="\d+"?SubStr(Select_Code, Section-ListNum*waitnum , 1):A_Space Section-ListNum*waitnum) "." srf_for_select_part))
						}
					}
				}
			}
		}
	}
	Else
	{
		for Section,element In srf_for_select_Array
		{
			for key,value in element
			{
				if (Section>ListNum*waitnum&&Section<=ListNum*(waitnum+1)){
					if (key=1) {
						srf_for_select_part:=(value (Cut_Mode="on"&&a_FontList ~="i)" FontExtend &&FontType ~="i)" FontExtend &&srf_for_select_Array[Section, valueindex]<>""?(srf_all_input~="^[a-z]+"?"〔":A_Space) . srf_for_select_Array[Section, valueindex] . (srf_all_input~="^[a-z]+"?"〕":A_Space):A_Space . srf_for_select_Array[Section, 3]))
						if (srf_for_select_part<>""){
							srf_for_select_string.=("`n" (srf_all_Input~="\d+"?SubStr(Select_Code, Section-ListNum*waitnum , 1):Section-ListNum*waitnum) "." srf_for_select_part)
							srf_for_select_obj.Push(((srf_all_Input~="\d+"?SubStr(Select_Code, Section-ListNum*waitnum , 1):A_Space Section-ListNum*waitnum) "." srf_for_select_part))
						}
					}
				}
			}
		}
	}
	if (srf_for_select_Array.Length()>0&&Ceil(srf_for_select_Array.Length()/ListNum)>1&&PageShow) {
		pagetip:=A_Space (Ceil(srf_for_select_Array.Length()/ListNum)>1?(Cut_Mode="on"&&srf_for_select_Array[1,2]<>""?("[ 第" waitnum+1 "页/共" Ceil(srf_for_select_Array.Length()/ListNum) "页 ]"):("[ " waitnum+1 "/" Ceil(srf_for_select_Array.Length()/ListNum) " ]")):"")
		srf_for_select_obj.Push(pagetip)
	}
	if srf_for_select_string
		srf_for_select_for_tooltip:=Trim(srf_for_select_string,". `n") (Textdirection="vertical"?"`n":(Textdirection="horizontal"&&Ceil(srf_for_select_Array.Length()/ListNum)>1?A_Space:"")) (Ceil(srf_for_select_Array.Length()/ListNum)>1&&PageShow?(Cut_Mode="on"?("[ 第" waitnum+1 "页/共" Ceil(srf_for_select_Array.Length()/ListNum) "页 ]"):("[ " waitnum+1 "/" Ceil(srf_for_select_Array.Length()/ListNum) " ]")):"")
	Gosub srf_tooltip
Return

;候选框样式判断
showhouxuankuang:
	If (srf_all_Input=""){
		srf_for_select_for_tooltip:=""
		If (ToolTipStyle ~="i)off")
			ToolTip(1,""), ToolTip(2,"")
		Else
			Gui, houxuankuang:Hide
		Return
	}
	If !EN_Mode {
		srf_code:=srf_all_input~="^z\'[a-z]"?RegExReplace(srf_all_input,"^z\'"):(srf_all_input~="^``$"?RegExReplace(srf_all_input,"^``",(Wubi_Schema~="i)ci"&&!EN_Mode?"〔精准造词〕":"〔常用符号〕")):srf_all_input~="^~$"?RegExReplace(srf_all_input,"^~","〔以形查音〕"):srf_all_input~="^[``]{2}$"&&!EN_Mode?RegExReplace(srf_all_input,"^````","〔临时英文〕"):srf_all_input)
		,srf_code:=srf_code~="^``|^~"?RegExReplace(RegExReplace(srf_code,"^``|^~"),"``","'"):srf_code~="^z"&&zkey_mode=2?Char2Num(srf_code,1):srf_code
	}else
		srf_code:=srf_all_input
	SysGet, _height, 14
	if Fix_Switch~="i)on"{
		Caret:={x:Fix_X,y:Fix_Y,h:_height}
	}else{
		Caret:=PosLimit&&ToolTipStyle~="i)on"?Carets:GetCaretPos()
	}
	llen:=srf_for_select_Array.Length()
	If (ToolTipStyle ~="i)on"){
		ToolTip(1, srf_code, "x" Caret.x " y" Caret.y+Caret.h)
		WinGetPos, x, y, Width, Height, % "ahk_id" Tip1hWnd  ;
		ToolTip(2, srf_for_select_for_tooltip, "x" x " y" y+Height+5+Set_Range)
		WinGetPos, xx2, yy2, Width2, Height2, % "ahk_id" Tip2hWnd  ;
		if (tty:=yy2+Height2>A_ScreenHeight&&Fix_Switch~="i)off"){
			ToolTip(1, srf_code, "x" Caret.x " y" y-Height-Caret.h-Height2-5-Set_Range)
			WinGetPos, x_t, y_t, Width, Height, % "ahk_id" Tip1hWnd  ;
			ToolTip(2, srf_for_select_for_tooltip, "x" x_t " y" y_t+Height+5+Set_Range)
			Carets:={x:Caret.x,y:y_t-Height-5-Set_Range,h:30,n:llen}, PosLimit:=1
		}else if (tty:=xx2+Width2>A_ScreenWidth&&Fix_Switch~="i)off"){
			ToolTip(1, srf_code, "x" A_ScreenWidth-Width2 " y" Caret.y+Caret.h)
			WinGetPos, x_t, y_t, Width, Height, % "ahk_id" Tip1hWnd  ;
			ToolTip(2, srf_for_select_for_tooltip, "x" x_t-Width " y" y_t+Height+5+Set_Range)
			Carets:={x:x_t-Width,y:Caret.y,h:30,n:llen}, PosLimit:=1
		}else
			Carets.n:=llen
	} Else If (ToolTipStyle ~="i)off"){
		Gui, measure:Destroy
		Gui, measure:+ToolWindow -Caption -DPIScale +AlwaysOnTop
		Gui, measure:Font,s%FontSize% , % EN_Mode||srf_all_input~="^[``]{2}\w+"?EnFontName:FontType
		Try {
			Gui, measure:Add, Text, vmeasureedit1, %srf_all_Input%
			GuiControlGet, measure_P1, measure:Pos, measureedit1
			Gui, measure:Add, Text, x0 yp+20 vmeasureedit2, % srf_for_select_for_tooltip
			GuiControlGet, measure_P2, measure:Pos, measureedit2
		}
		guihouxuankuang_width:=Max(measure_P1w, measure_P2w)+FontSize*0.7
		if (srf_for_select_Array.Length()>0)
		{
			guihouxuankuang_height:=measure_P1h+measure_P2h+( Textdirection ~="i)horizontal"?25:0)
		/*
			guihouxuankuang_x:=Max(Min(A_ScreenWidth-guihouxuankuang_width, Caret.X+15), 0), guihouxuankuang_y:=Max(Min(A_ScreenHeight-guihouxuankuang_height, Caret.Y+_height), 0)
		*/
			guihouxuankuang_x:=(guihouxuankuang_width>A_ScreenWidth?0:(Caret.X+guihouxuankuang_width>A_ScreenWidth?A_ScreenWidth-guihouxuankuang_width:Caret.X+10))
			, guihouxuankuang_y:=(guihouxuankuang_height>A_ScreenHeight?0:(Caret.Y+guihouxuankuang_height>A_ScreenHeight?Caret.Y-guihouxuankuang_height-10:(Caret.X+guihouxuankuang_width>A_ScreenWidth?Caret.Y-guihouxuankuang_height-_height/2: Caret.Y+_height)))
			Gui, houxuankuang:Show, % "NA w" guihouxuankuang_width " h" guihouxuankuang_height " x" guihouxuankuang_x " y" guihouxuankuang_y
			;WinSet, Region, % "0-0 w" guihouxuankuang_width+3 " h" guihouxuankuang_height+3 " R15-15", ahk_id%guihouxuankuang%
			GuiControl, houxuankuang:Move, myedit1, % "w" measure_P1w " h" measure_P1h
			if Gdip_Line ~="i)on"{
				GuiControl, houxuankuang:Show, fengefu
				GuiControl, houxuankuang:Move, fengefu, % "y" measure_P1h+7
			}
			GuiControl, houxuankuang:Move, myedit2, % "w" measure_P2w " h" measure_P2h " y" measure_P1h+20
			GuiControl, houxuankuang:Text, myedit1, %srf_code%
			GuiControl, houxuankuang:Show, myedit2
			GuiControl, houxuankuang:Text, myedit2, %srf_for_select_for_tooltip%
		}
		else
		{
			guihouxuankuang_height:=measure_P1h+measure_P2h/2
		/*
			guihouxuankuang_x:=Max(Min(A_ScreenWidth-guihouxuankuang_width, Caret.X+15), 0), guihouxuankuang_y:=Max(Min(A_ScreenHeight-guihouxuankuang_height, Caret.Y+_height), 0)
		*/
			guihouxuankuang_x:=(guihouxuankuang_width>A_ScreenWidth?0:(Caret.X+guihouxuankuang_width>A_ScreenWidth?A_ScreenWidth-guihouxuankuang_width:Caret.X+10))
			, guihouxuankuang_y:=(guihouxuankuang_height>A_ScreenHeight?0:(Caret.Y+guihouxuankuang_height>A_ScreenHeight?Caret.Y-guihouxuankuang_height-10:(Caret.X+guihouxuankuang_width>A_ScreenWidth?Caret.Y-guihouxuankuang_height-_height/2: Caret.Y+_height)))
			Gui, houxuankuang:Show, % "NA w" guihouxuankuang_width " h" guihouxuankuang_height " x" guihouxuankuang_x " y" guihouxuankuang_y
			GuiControl, houxuankuang:Move, myedit1, % "w" measure_P1w " h" measure_P1h
			GuiControl, houxuankuang:Hide, fengefu
			GuiControl, houxuankuang:Text, myedit1, %srf_code%
			GuiControl, houxuankuang:Hide, myedit2
		}
	} Else {
		if FocusStyle
			FocusGdipGui(srf_code, srf_for_select_obj, Caret.X, Caret.Y+_height, EN_Mode||srf_all_input~="^[``]{2}\w+"?EnFontName:FontType)
		else
			GdipText(srf_code, srf_for_select_for_tooltip, Caret.X , Caret.Y+_height , EN_Mode||srf_all_input~="^[``]{2}\w+"?EnFontName:FontType)
	}
Return

;清除操作
srf_value_off:
	Critical, On
	If (ToolTipStyle ~="i)on")
		ToolTip(1,""), ToolTip(2,"")
	Else If (ToolTipStyle ~="i)off")
		Gui, houxuankuang:Hide
	Else
		GdipText(""), FocusGdipGui("", "")
	srf_all_Input:=srf_for_select_for_tooltip:=CheckFilterControl:="", waitnum:=select_sym:=PosLimit:=0
	srf_for_select_Array :=select_arr:=srf_for_select_obj:=select_value_arr:=add_Result:=add_Array:=Result_:=Results_:=Result:=labelObj:=[],Select_result:=selectallvalue:="",code_status:=localpos:=srfCounts:=select_pos:=1
Return

DestroyGui:
	Gui, IM:Destroy
	Gui, label:Destroy
	Gui, themes:Destroy
	Gui, DB:Destroy
	Gui, diy:Destroy
	Gui, Sym:Destroy
	Gui, SymList:Destroy
	Gui, ts:Destroy
	Gui, Date:Destroy
	Gui, Info:Destroy
	Gui,SKey:Destroy
	CaptainHook(KeyInitStatus:=false)
Return

diyColor:
	Gosub DestroyGui
	Gui, diy: +hwndDIYTheme +Owner98 -MinimizeBox   ; -DPIScale +AlwaysOnTop
	Gui,diy:Font, s10 Bold, %font_%
	Gui diy:Add, GroupBox, y+15 w385 h250, 配色项
	Gui,diy:Font
	Gui,diy:Font, s9, %font_%
	Gui, diy:Add, Text,
	Gui, diy:Add, Text, xm+15 yp-225 left, 编码选色：
	Gui, diy:Add, Button, x+0 w80 h30 hwndhwndFontCodeColor gsetcolor vFontCodeColor
	Gui, diy:Add, Text,
	Gui, diy:Add, Text, yp-35 x+105 left, 候选词选色：
	Gui, diy:Add, Button, x+0 w80 h30 hwndhwndfontcolor gsetcolor vFontColor
	Gui, diy:Add, Text,
	Gui, diy:Add, Text, xm+15 ym+80 left, 背景选色：
	Gui, diy:Add, Button, x+0 w80 h30 hwndhwndbgcolor gsetcolor vBgColor
	Gui, diy:Add, Text, yp+0 x+35 left, 分隔线选色：
	Gui, diy:Add, Button, x+0 w80 h30 hwndhwndlinecolor gsetcolor vLineColor
	Gui, diy:Add, Text, xm+15 ym+120 left, 边框选色：
	Gui, diy:Add, Button, x+0 w80 h30 hwndhwndbordercolor gsetcolor vBorderColor
	Gui, diy:Add, Text, yp+0 x+20 left, 焦点候选背景：
	Gui, diy:Add, Button, x+0 w80 h30 hwndhwndFocusBackColor gsetcolor vFocusBackColor
	Gui, diy:Add, Text, xm+15 ym+160 left, 焦点词色：
	Gui, diy:Add, Button, x+0 w80 h30 hwndhwndFocusColor gsetcolor vFocusColor
	Gui, diy:Add, Text, yp+0 x+20 left, 编码背景选色：
	Gui, diy:Add, Button, x+0 w80 h30 hwndhwndFocusCodeColor gsetcolor vFocusCodeColor
	Gui, diy:Add, Button , xm+15 ym+210 gBackLogo hWndBUBT,导出配色
	ImageButton.Create(BUBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, diy:Add, Edit, x+5 yp w130 vBUTheme hwndBUTheme
	Gui, diy:Add, Text, x+10 yp+3 w150 vtipColor left,
	EM_SetCueBanner(BUTheme, "请输入文件名称")
	CreateImageButton(hwndFontCodeColor,[{BC: FontCodeColor, 3D: 0}],5)
	CreateImageButton(hwndfontcolor,[{BC: fontcolor, 3D: 0}],5)
	CreateImageButton(hwndbgcolor,[{BC: bgcolor, 3D: 0}],5)
	CreateImageButton(hwndlinecolor,[{BC: linecolor, 3D: 0}],5)
	CreateImageButton(hwndbordercolor,[{BC: bordercolor, 3D: 0}],5)
	CreateImageButton(hwndFocusBackColor,[{BC: FocusBackColor, 3D: 0}],5)
	CreateImageButton(hwndFocusColor,[{BC: FocusColor, 3D: 0}],5)
	CreateImageButton(hwndFocusCodeColor,[{BC: FocusCodeColor, 3D: 0}],5)
	Gui, diy:Color,ffffff
	Gui, diy:Show,AutoSize,配色管理
	Gosub ChangeWinIcon
	ControlFocus , Edit1, A
Return

;样式面板
More_Setting:
	Gui, 98:Destroy
	Gui, 98:Default
	SysGet, SGW, 71
	Menu, SchemaList, Add, % SchemaType["ci"] "五笔•含词", sChoice4
	Menu, SchemaList, Add, % SchemaType["zi"] "五笔•单字", sChoice4
	Menu, SchemaList, Add, % SchemaType["chaoji"] "五笔•超集", sChoice4
	Menu, SchemaList, Add, 五笔•字根, sChoice4
	Menu, SchemaList, Color, FFFFFF
	Menu, StyleMenu, Add, Tooltip样式, ChangeTooltipstyle
	Menu, StyleMenu, Add, Gui候选框样式, ChangeTooltipstyle
	Menu, StyleMenu, Add, Gdip候选框样式, ChangeTooltipstyle
	Menu, StyleMenu, Color, FFFFFF
	if A_OSVersion ~="i)WIN_XP"
		Menu, StyleMenu, Disable, Gdip候选框样式
	HMENU := Menu_GetMenuByName("StyleMenu")
	SMENU := Menu_GetMenuByName("SchemaList")
	Menu, MainMenu, Add, 方案选择, :SchemaList
	Menu, MainMenu, Add,
	Menu, ImportCiku, Add, 方案码表导入, ciku1
	Menu, ImportCiku, Add, 英文词库导入, ciku3
	Menu, ImportCiku, Add, 特殊符号导入, ciku5
	Menu, ImportCiku, Add, 注音词库导入, ciku10
	Menu, ImportCiku, Add, 造词源表导入, ciku12
	Menu, ImportCiku, Add, 拆分源表导入, ciku14
	Menu, ImportCiku, Add, 笔画码表导入, Write_Strocke
	Menu, ImportCiku, Add, 临时拼音导入, ImportPinyin
	;;Menu, ImportCiku, Disable, 笔画码表导入
	Menu, MainMenu, Add, 词库导入, :ImportCiku
	Menu, MainMenu, Add,
	Menu, ExportCiku, Add, 原始词库导出, ciku8
	Menu, ExportCiku, Add, 词库合并导出, ciku2
	Menu, ExportCiku, Add, 英文词库导出, ciku4
	Menu, ExportCiku, Add, 特殊符号导出, ciku6
	Menu, ExportCiku, Add, 注音词库导出, ciku11
	Menu, ExportCiku, Add, 笔画词库导出, Export_Strocke
	Menu, ExportCiku, Add, 临时拼音导出, ExportPinyin
	Menu, MainMenu, Add, 词库导出, :ExportCiku
	Menu, MainMenu, Add,
	Menu, MainMenu, Add, 自造词管理, DB_management
	Menu, MainMenu, Color, FFFFFF
	Menu, Main, Add, 方案管理, :MainMenu
	Menu, Custom, Add, 候选框风格, :StyleMenu
	Menu, Custom, Add,
	Menu, Custom, Add, 自定义配色, diyColor
	Menu, Custom, Add,
	Menu, Custom, Add, 主题管理, themelists
	Menu, Custom, Color, FFFFFF
	Menu, Main, Add, 候选框 , :Custom
	Menu, ExtendTool, Add, 自定义标点, Sym_Gui
	Menu, ExtendTool, Add, 超级标签管理, Label_management
	Menu, ExtendTool, Add, 长字符串管理, LongStringlists
	Menu, ExtendTool, Add, 时间输出设定, format_Date
	Menu, ExtendTool, Add, 全码单字提取, ciku13
	Menu, ExtendTool, Add, 码表格式转换, TransformCiku
	Menu, ExtendTool, Add, 按键键值获取, GetkeyCode
	Menu, ExtendTool, Color, FFFFFF
	Menu, Main, Add, 扩展工具, :ExtendTool
	Menu, Main, Color, FFFFFF
	Gui, 98: +hwndhwndgui98 +OwnDialogs    ;;+ToolWindow -DPIScale +AlwaysOnTop
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Menu, Main
	Gui, 98:Add, Custom, ClassToolbarWindow32 hwndTopBar vTop 0x0800 0x0100 0x0020 0x0040
	Gui, 98:Add, TreeView,x10 yp h400 w150 AltSubmit 0x20 0x200 -Buttons -WantF2 gTVGUI vTVGUI   ;-Buttons 
	TV1 := TV_Add("基础设置",, "Bold")
	TV1_1 := TV_Add("主题设置", TV1)  ; 指定项目的父项目.
	TV_Modify(TV1, "Expand"),TV_Modify(TV1_1, "Select")
	TV2 := TV_Add("功能设置",, "Bold")
	TV2_1 := TV_Add("候选框参数", TV2)
	TV2_2 := TV_Add("输出设置", TV2)
	TV2_3 := TV_Add("其它设置", TV2)
	TV_Modify(TV2, "Expand")
	TV3 := TV_Add("快捷键",, "Bold")
	TV4 := TV_Add("关于",, "Bold")
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	TV_obj:={GBoxList1:["GBox1","themelogo","lineText1","Initialize","SBA13","TextInfo1","showtools","SrfSlider","SizeValue","set_SizeValue","ExSty","DPISty","select_theme","diycolor","themelists","TextInfo2","Backup_Conf","Rest_Conf","select_logo","TextInfo3","TextInfo4","TextInfo27","LogoColor_cn","LogoColor_en","LogoColor_caps"]
		,GBoxList2:["GBox2","TextInfo25","SBA5","SBA0","TextInfo12","SBA9","SBA10","SBA12","SBA19","SBA20","set_select_value","font_size","TextInfo11","FontSelect","TextInfo5","FontType","TextInfo6","font_value","TextInfo7","select_value","TextInfo8","set_regulate_Hx","set_regulate","TextInfo9","GdipRadius","set_GdipRadius","TextInfo10","set_FocusRadius","set_FocusRadius_value"]
		,GBoxList3:["GBox3","SBA7","SBA26","SBA27","SBA28","SBA23","SBA24","TextInfo29","TextInfo22","zKeySet","UIAccess","SBA6","SBA14","SBA18","SBA21","SBA3","SBA25","TextInfo13","TextInfo28","Frequency","TextInfo14","set_Frequency","RestDB","InputStatus","WinMode","CreateSC","Cursor_Status","yaml_", "SBA11"]
		,GBoxList4:["GBox4","TextInfo15","lineText2","SBA4","TextInfo16","sChoice1","InitiaMode","TextInfo17","sChoice2","TextInfo18","sChoice3","TextInfo19","sethotkey_2","hk_1","tip_text","TextInfo20","SetInput_CNMode","SetInput_ENMode","TextInfo21","PageChoice","sethotkey_4","TextInfo23", "ChoiceCode"]
		,GBoxList5:["GBox5","SBA1","s2thotkeys","SBA2","cfhotkeys","SBA15","tiphotkey","SBA16","Suspendhotkey","SBA17","Addcodehotkey","Exithotkey","SBA22"]
		,GBoxList6:["GBox6","linkinfo1","linkinfo2","linkinfo3","versionsinfo","infos_"]}

	Gui, 98:Add, GroupBox,x+10 yp w400 h400 vGBox1, 主题配置
	Gui, 98:Add, Picture,xp+100 yp+30 h-1 vthemelogo, Config\Skins\preview\默认.png
	Gui 98:Add, Text,x190 y+5 w365 h2 0x10 vlineText1
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	;;OD_Colors.SetItemHeight("S10 bold" , font_)
	Gui, 98:Add, Text,x190 y+15 vTextInfo1 left, 主题选择：
	themelist:=logoList:=""
	Loop Files, config\Skins\*.json
		themelist.="|" SubStr(A_LoopFileName,1,-5)
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, DDL,x+5 yp vselect_theme gselect_theme Section hwndHDDL , % RegExReplace(themelist,"^\|")    ;;+0x0210
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, Text,
	Gui, 98:Add, Text,x190 yp+5 vTextInfo3 left, 配置管理：
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,x+5 yp-2 cred gBackup_Conf vBackup_Conf hwndCBT,备份配置
	ImageButton.Create(CBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, 98:Add, Button,x+10 yp gRest_Conf vRest_Conf hwndRBT,恢复配置
	ImageButton.Create(RBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, 98:Add, Button,x+10 yp gInitialize vInitialize hwndINBT,初始化
	ImageButton.Create(INBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	Loop Files, config\Skins\logoStyle\*.icl
		logoList.="|" SubStr(A_LoopFileName,1,-4)
	GuiControlGet, scvar, Pos , Backup_Conf
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text,x190 y+10 vTextInfo4 left, 功能条：
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, DDL,x%scvarX% yp vselect_logo gselect_logo hWndSLCT , % RegExReplace(logoList,"^\|")    ;;+0x0210
	;;OD_Colors.Attach(HDDL,{T: 0xffe89e, B: 0x0178d6})
	;;OD_Colors.Attach(SLCT,{T: Logo_Switch~="i)on"?0xffe89e:0x767641, B: Logo_Switch~="i)on"?0x0178d6:0xb3b3b3})
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x+10 yp+2 vshowtools gshowtools Checked%srfTool%, 独立显示
	GuiControl, 98:ChooseString, select_logo, %StyleN%
	Gui, 98:Add, Text,x190 y+10 vTextInfo27 left, 色块调整：
	Gui,98:Font
	Gui,98:Font, s9 norm, %font_%
	Gui, 98:Add, Button, x%scvarX% yp w60 hwndhwndLogoColor_cn gsetlogocolor vLogoColor_cn
	Gui, 98:Add, Button, x+5 w60 hwndhwndLogoColor_en gsetlogocolor vLogoColor_en
	Gui, 98:Add, Button, x+5 w60 hwndhwndLogoColor_caps gsetlogocolor vLogoColor_caps
	CreateImageButton(hwndLogoColor_cn,[{BC: SubStr(LogoColor_cn,5,2) SubStr(LogoColor_cn,3,2) SubStr(LogoColor_cn,1,2), 3D: 0}],5)
	CreateImageButton(hwndLogoColor_en,[{BC: SubStr(LogoColor_en,5,2) SubStr(LogoColor_en,3,2) SubStr(LogoColor_en,1,2), 3D: 0}],5)
	CreateImageButton(hwndLogoColor_caps,[{BC: SubStr(LogoColor_caps,5,2) SubStr(LogoColor_caps,3,2) SubStr(LogoColor_caps,1,2), 3D: 0}],5)
	Gui, 98:Add, Edit, x+10 w45 Limit3 Number vSizeValue gSizeValue
	Gui, 98:Add, UpDown, x+0 w45 Range1-150 gset_SizeValue vset_SizeValue, % (LogoSize>0&&LogoSize<=150?LogoSize:36)
	GuiControlGet, lcvar, Pos , LogoColor_cn
	lctY:=lcvarY+lcvarH+10, lctW:=lcvarW*4
	Gui, 98:Add, Slider,x%lcvarX% y+10 w%lctW% h25 gSrfSlider vSrfSlider Center NoTicks Thick20 ToolTipLeft Range0-255, % transparentX
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x%lcvarX% y+10 vSBA13 gSBA13, 指示器显隐
	Gui, 98:Add, CheckBox,x+5 Checked%DPIScale% vDPISty gDPISty, +DPIScale
	Gui, 98:Add, CheckBox,x+5 Checked%Logo_ExStyle% vExSty gExSty, 鼠标穿透
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox2, 候选框参数
	Gui,98:Font
	Gui,98:Font, s10 , %font_%
	Gui, 98:Add, CheckBox,x190 yp+40 vSBA5 gSBA5, 跟随光标
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,yp-3 x+5 vSBA0 gSBA0 hwndPBT, 坐标设置
	ImageButton.Create(PBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui 98:Add, Text,x190 y+10 w365 h2 0x10 vTextInfo12
	Gui, 98:Add, CheckBox,x190 y+10 vSBA9 gSBA9, 候选框圆角
	Gui, 98:Add, CheckBox,yp+0 x+5 vSBA10 gSBA10, 候选框分割线
	GuiControlGet, CheckVar1, Pos , SBA10
	Gui, 98:Add, CheckBox,yp+0 x+5 vSBA12 gSBA12, 粗体
	GuiControlGet, CheckVar2, Pos , SBA12
	Gui, 98:Add, CheckBox,x190 y+10 vSBA19 gSBA19, 焦点候选框
	Gui, 98:Add, CheckBox,yp+0 x%CheckVar1X% vSBA20 gSBA20, 页数显示
	Gui 98:Add, Text,x190 y+10 w365 h2 0x10 vTextInfo25
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	DllCall("gdi32\EnumFontFamilies","uint",DllCall("GetDC","uint",0),"uint",0,"uint",RegisterCallback("EnumFontFamilies"),"uint",a_FontList:="")
	Gui, 98:Add, Text, x190 y+10 left vTextInfo5, 中文字体：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, ComboBox,x+2 w150 gfonts_type vFontType hwndFontLists, % a_FontList
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 y+10 left vTextInfo11, 英文字体：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, ComboBox,x+2 w150 gFontSelect vFontSelect hwndFontLists2, % a_FontList
	CtlColors.Attach(FontLists, "0178d6", "ffffff")
	CtlColors.Attach(FontLists2, "0178d6", "ffffff")
	GuiControl, 98:ChooseString, FontType, %FontType%
	GuiControl, 98:ChooseString, FontSelect, %EnFontName%
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 y+10 left vTextInfo8, 候选框偏移：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, Edit, x+0 yp-3 w45 Limit2 Number vset_regulate_Hx gset_regulate_Hx
	Gui, 98:Add, UpDown, x+0 w45 Range3-25 gset_regulate vset_regulate, %Set_Range%
	GuiControlGet, EditVar1, Pos , set_regulate_Hx
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x+20 yp+3 left vTextInfo7, 候选项数目：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, Edit, x+0 yp-3 w45 Limit2 Number vselect_value gselect_value
	Gui, 98:Add, UpDown, x+0 w45 Range3-10 gset_select_value vset_select_value, %ListNum%
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 y+10 left vTextInfo9, 候选框圆角：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, Edit, x%EditVar1X% yp-3 w45 Limit2 Number vGdipRadius gGdipRadius
	Gui, 98:Add, UpDown, x+0 w45 Range0-15 gset_GdipRadius vset_GdipRadius, %Gdip_Radius%
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x+20 yp-3 left vTextInfo10, 焦点项圆角：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, Edit, x+0 yp+3 w45 Limit2 Number vset_FocusRadius gset_FocusRadius
	Gui, 98:Add, UpDown, x+0 w45 Range0-18 gset_FocusRadius_value vset_FocusRadius_value, %FocusRadius%
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 y+10 left vTextInfo6, 字体字号：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, Edit, x%EditVar1X% yp-3 w45 Limit2 Number vfont_value gfont_value
	Gui, 98:Add, UpDown, x+0 w45 Range9-40 gfont_size vfont_size, %FontSize%
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox3, 输出设置
	Gui,98:Font
	Gui,98:Font, s8, %font_%
	Gui, 98:Add, Text, x190 yp+25 left vTextInfo22 cred, ⚑ 提权操作首次运行非管理员身份不提供选择！
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, CheckBox, x190 y+5 gEnableUIAccess vUIAccess , 权限提升
	;;GuiControlGet, CheckVar1, Pos , EnableUIAccess
	Gui, 98:Add, CheckBox,x+8 yp+0 vSBA6 gSBA6, 符号顶字上屏
	Gui, 98:Add, CheckBox,x+8 yp+0 vSBA3 gSBA3, 空码模糊提示
	Gui, 98:Add, CheckBox,x190 y+10 vSBA24 gSBA24 Checked%PromptChar%, 逐码提示
	Gui, 98:Add, CheckBox,x+8 yp+0 vSBA25 gSBA25 Checked%EN_Mode%, 英文输入模式
	Gui, 98:Add, CheckBox,x+8 yp+0 vSBA7 gSBA7, 五码首选上屏
	Gui, 98:Add, CheckBox,x190 y+10 vSBA23 gSBA23 Checked%CharFliter%, 字集过滤
	Gui, 98:Add, CheckBox, x+8 yp+0 Checked%EnKeyboardMode% vSBA28 gSBA28, 默认美式键盘
	Gui, 98:Add, CheckBox,x+8 yp+0 vSBA26 gSBA26, 四码唯一上屏
	Gui, 98:Add, CheckBox,x190 y+10 vSBA11 gSBA11 , 输简出繁
	Gui, 98:Add, CheckBox,x+8 yp+0 vyaml_ gyaml_, 导出yaml格式
	Gui 98:Add, Text,x190 y+10 w365 h2 0x10 vTextInfo28
	Gui, 98:Add, CheckBox,x190 y+10 vSBA14 gSBA14, 中文时使用英文标点
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,x+10 yp-2 vSBA21 gSBA21 hwndBBT, 自定义标点
	ImageButton.Create(BBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 y+10 left vTextInfo29, 反查方式：
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, DDL,x+5 w90  vzKeySet gzKeySet  AltSubmit HwndZDDL , 临时拼音|模糊匹配|笔画反查    ;;+0x0210
	;;OD_Colors.Attach(ZDDL,{T: 0xffe89e, B: 0x0178d6})
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,x+10 yp-2 vSBA18 gSBA18 hwndBHBT, 设置笔画键位
	ImageButton.Create(BHBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui 98:Add, Text,x190 y+10 w365 h2 0x10 vTextInfo13
	Gui, 98:Add, CheckBox,x190 y+10 Checked%Frequency% vFrequency gFrequency, 动态调频
	Gui, 98:Add, Text, x+5 yp vFTip left vTextInfo14, 调频参数：
	Gui,98:Font
	Gui,98:Font, s9 norm, %font_%
	Gui, 98:Add, DDL,x+5 yp-3 w50 vset_Frequency gset_Frequency hWndFRDL , 2|3|4|5|6|7|8    ;;+0x0210
	;;OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x0178d6})
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button, x+10 yp-1 vRestDB gRestDB hWndRDBT, 初始化词频
	ImageButton.Create(RDBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 Checked%IStatus% vInputStatus gInputStatus, 输入状态控制
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button, yp-4 x+10 gWinMode vWinMode hWndWMBT,输入状态管理
	ImageButton.Create(WMBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, 98:Add, Button,x+10 yp vSBA27 gSBA27 hwndFTBT, 时间输出管理
	ImageButton.Create(FTBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 Checked%CursorStatus% vCursor_Status gCursor_Status, 光标监控
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,yp-4 x+10 cred gCreateSC vCreateSC hWndSCBT,创建快捷方式
	ImageButton.Create(SCBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox4, 其它设置
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 yp+35  left vTextInfo17, 回车键设定：
	Gui, 98:Add, Text, x+100 yp left vTextInfo18, 候选框显示：
	GuiControlGet, TextInfo, Pos , TextInfo18
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, DDL,x190 y+5 w110 vsChoice2 gsChoice2 HwndSCDL2 , 编码上屏|清空编码    ;;+0x0210
	;;OD_Colors.Attach(SCDL2,{T: 0xffe89e, B: 0x0178d6})
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, DDL,x%TextInfoX% yp w110 vsChoice3 gsChoice3 HwndSCDL3 , 候选横排|候选竖排    ;;+0x0210
	;;OD_Colors.Attach(SCDL3,{T: 0xffe89e, B: 0x0178d6})
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, Text, x190 y+5 left vTextInfo15, 自启方式：
	Gui, 98:Add, Text, x%TextInfoX% yp left vTextInfo16, 上屏方式：
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, DDL,x190 y+5 w110  vSBA4 gSBA4 HwndSDDL4 , 计划任务自启|快捷方式自启|不自启    ;;+0x0210
	;;OD_Colors.Attach(SDDL4,{T: 0xffe89e, B: 0x0178d6})
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, DDL,x%TextInfoX% yp w110  vsChoice1 gsChoice1  AltSubmit HwndSCDL1 , 常规上屏|剪切板上屏    ;;+0x0210
	;;OD_Colors.Attach(SCDL1,{T: 0xffe89e, B: 0x0178d6})
	Gui, 98:Add, CheckBox,x+10 yp+3 Checked%InitiaMode% vInitiaMode gInitiaMode, 
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, Text, x190 y+10 left vTextInfo21, 翻页按键：
	Gui, 98:Add, Text, x%TextInfoX% yp left vTextInfo23, 次选三选：
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, DDL,x190 y+5 w110  vPageChoice gPageChoice  AltSubmit HwndPCDL , 逗号-句号|减号-等号|左右方括号|PgUp-PgDn    ;;+0x0210
	;;OD_Colors.Attach(PCDL,{T: 0xffe89e, B: 0x0178d6})
	Gui, 98:Add, DDL,yp x%TextInfoX% w110  vChoiceCode gChoiceCode  AltSubmit HwndTCDL , 逗号-句号|分号-引号|左右Shift
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, Text, x190 y+10  left vTextInfo20, 默认状态：
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Radio,x190 y+5 vSetInput_CNMode gSetInput_Mode, 中文
	Gui, 98:Add, Radio,yp x+30 vSetInput_ENMode gSetInput_Mode, 英文
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui 98:Add, Text,x190 y+20 w365 h2 0x10 vlineText2
	Gui, 98:Add, Text, x190 y+10 left vTextInfo19, 中英文切换：
	Gui,98:Font, s9 bold, %font_%
	KeyInitStatus:=false, Control0:=0
	Gui 98:Add, Button, x+10 yp h22 w65 Center vsethotkey_2 gsethotkey_2 hWndKNBT, 获取键名
	ImageButton.Create(KNBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	;ImageButton.Create(KNBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	Gui, 98:Add, text, yp+3 x+15 cred vtip_text gtip_text, 清空
	Gui,98:Font, s9 norm , %font_%
	;;GuiControl,98:Disable,sethotkey_2
	If WubiIni.Settings["Srf_Hotkey"]~="&" {
		hkobj:=[], hkobj:=StrSplit(WubiIni.Settings["Srf_Hotkey"],"&")
	}
	Gui, 98:Add, Hotkey, x190 y+10 w205 vsethotkey_4 gsethotkey_4 Center,% Srf_Hotkey~="i)RShift"?RegExReplace(Srf_Hotkey,"i)RShift","Shift"):Srf_Hotkey
	GuiControlGet, hkInfo, Pos , sethotkey_4
	Gui, 98:Add, Edit, vsethotkey_1 gsethotkey_1 x190 yp w100 h%hkInfoH% Center -WantCtrlA -WantReturn -Wrap, % objCount(hkobj)?(objCount(hkobj)=2?hkobj[1]:objCount(hkobj)>2?hkobj[1] "+" hkobj[2]:Srf_Hotkey):Srf_Hotkey
	Gui, 98:Add, Edit, vsethotkey_3 gsethotkey_3 x+5 yp w100 h%hkInfoH% Center -WantCtrlA -WantReturn -Wrap, % objCount(hkobj)?(objCount(hkobj)=2?hkobj[2]:objCount(hkobj)=3?hkobj[3]:hkobj[3] "+" hkobj[4]):""
	GuiControl,98:Hide,sethotkey_1
	GuiControl,98:Hide,sethotkey_3
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button, yp+0 x+10 vhk_1 ghk_1 hWndGBKBT, 设置
	ImageButton.Create(GBKBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,98:Font, s9 norm, %font_%
	Gui, 98:Add, CheckBox,yp+4 x+10 gControl0 vControl0 Checked%Control0%,中性键
	GuiControl,98:Hide,Control0
	GuiControl,98:Disable,hk_1
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox5, 快捷键
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x190 yp+35 vSBA1 gSBA1, 简繁切换>>
	Gui,98:Font
	Gui,98:Font, s9 , %font_%
	Gui, 98:Add, Hotkey, x+0 yp-3 vs2thotkeys gs2thotkeys,% s2t_hotkey
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 vSBA2 gSBA2, 拆分显示>>
	Gui,98:Font
	Gui,98:Font, s9 , %font_%
	Gui, 98:Add, Hotkey, x+0 yp-3 vcfhotkeys gcfhotkeys,% cf_hotkey
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 vSBA15 gSBA15 Checked%rlk_switch%, 划译反查>>
	Gui,98:Font
	Gui,98:Font, s9 , %font_%
	Gui, 98:Add, Hotkey, x+0 yp-3 vtiphotkey gtiphotkey,% tip_hotkey
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 vSBA16 gSBA16 Checked%Suspend_switch%, 程序挂起>>
	Gui,98:Font
	Gui,98:Font, s9 , %font_%
	Gui, 98:Add, Hotkey, x+0 yp-3 vSuspendhotkey gSuspendhotkey,% Suspend_hotkey
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 vSBA17 gSBA17 Checked%Addcode_switch%, 批量造词>>
	Gui,98:Font
	Gui,98:Font, s9 , %font_%
	Gui, 98:Add, Hotkey, x+0 yp-3 vAddcodehotkey gAddcodehotkey,% Addcode_hotkey
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 vSBA22 gSBA22 Checked%Exit_switch%, 快捷退出>>
	Gui,98:Font
	Gui,98:Font, s9 , %font_%
	Gui, 98:Add, Hotkey, x+0 yp-3 vExithotkey gExithotkey,% exit_hotkey
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox6, 关于
	Gui,98:Font
	Gui,98:Font, s9 c757575, %font_%
	Gui,98:Add, Text, x190 yp+35 w360 vinfos_ , `t%Startup_Name%是以AutoHotkey脚本语言编写的外挂类型形码输入法，借用同类型的「影子输入法」的实现思路通过调用众多WinAPI整合SQLite数据库实现文字输出等一系列功能。以「数据库码表性能」和「前端呈现」（调用Windows的GdiPlus.dll）两方面对文字内容直接发送上屏，而不进行传统输入法的转换操作，从XP至Win10皆能流畅运行。此版本为王码五笔专用，非王码五笔移步至「影子输入法」。
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui,98:Add, Link, y+15 vlinkinfo1, 简介：<a href="https://wubi98.gitee.io/2020/04/27/2019-12-03-031.yours/">程序简介</a>`nGit：<a href="https://github.com/OnchiuLee/AHK-Input-method">GitHub查看</a> | <a href="https://gitee.com/leeonchiu/AHK-Input-method">Gitee查看</a>
	Gui,98:Add, Link, y+5 glinkinfo3 vlinkinfo3, 更新：<a>点击更新</a>
	Gui,98:Add, Link, y+5 vlinkinfo2, 关于：<a href="https://wubi98.gitee.io/">https://wubi98.gitee.io/</a>`n资源库：<a href="http://98wb.ys168.com">http://98wb.ys168.com</a>
	Gui,98:Add, Text, y+5 vversionsinfo, 版本日期：%Versions%
	For Section, element In TV_obj
		For key,value In element
			if (Section<>"GBoxList1")
				GuiControl, 98:Hide, % value
	Gui 98:color,ffffff
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, StatusBar,,❖ 设置面板
	SB_SetText(A_Is64bitOS?" ❖ " ComInfo.GetOSVersionInfo()[1] "〔 AutoHotkey " A_AhkVersion "#64位 〕":" ❖ " ComInfo.GetOSVersionInfo() "〔 AutoHotkey " A_AhkVersion "#32位 〕" )
	Gui, 98:Show,AutoSize,输入法设置
	Gosub ChangeWinIcon
	Gosub ControlGui
Return

ChangeWinIcon:
	;ChangeWindowIcon(IconName_)
	ChangeWindowIcon(A_ScriptDir "\Config\WubiIME.icl",, 30)
Return

linkinfo3:
	Gosub OnUpdate
Return

InitiaMode:
	GuiControlGet, InitiaMode ,, InitiaMode, Checkbox
	InitiaMode:=WubiIni.Settings["InitiaMode"]:=InitiaMode, WubiIni.save()
Return

ExSty:
	GuiControlGet, ExSty ,, ExSty, Checkbox
	Logo_ExStyle:=WubiIni.TipStyle["Logo_ExStyle"]:=ExSty, WubiIni.save()
	Gosub IsExStyle
Return

DPISty:
	GuiControlGet, DPISty ,, DPISty, Checkbox
	DPIScale:=WubiIni.Settings["DPIScale"]:=DPISty, WubiIni.save()
	Gosub ShowSrfTip
Return

SrfSlider:
	transparentX:=WubiIni.TipStyle["transparentX"]:=SrfSlider, WubiIni.save()
	Gosub IsExStyle
Return

SizeValue:
	GuiControlGet, SizeValue,, SizeValue, text
	LogoSize:=WubiIni.TipStyle["LogoSize"]:=SizeValue>0&&SizeValue<=150?SizeValue:36, WubiIni.save()
	Gosub ShowSrfTip
Return

set_SizeValue:
	LogoSize:=WubiIni.TipStyle["LogoSize"]:=set_SizeValue>0&&set_SizeValue<=150?set_SizeValue:36, WubiIni.save()
	Gosub ShowSrfTip
Return

CreateSC:
	if FileExist(A_Desktop "\五笔*版.lnk"){
		FileDelete, %A_Desktop%\五笔*版.lnk
		FileCreateShortcut, %A_AhkPath%, %A_Desktop%\%Startup_Name%.lnk , %A_ScriptDir%, "%A_ScriptFullPath%", % "位置: " A_Space SubStr(RegExReplace(A_AhkPath,".+\\"),1,-4) "(" SubStr(RegExReplace(A_AhkPath,RegExReplace(A_AhkPath,".+\\")),1,-1) ")", %A_ScriptDir%\config\WubiIME.icl, , 30, 1
	}else{
		FileCreateShortcut, %A_AhkPath%, %A_Desktop%\%Startup_Name%.lnk , %A_ScriptDir%, "%A_ScriptFullPath%", % "位置: " A_Space SubStr(RegExReplace(A_AhkPath,".+\\"),1,-4) "(" SubStr(RegExReplace(A_AhkPath,RegExReplace(A_AhkPath,".+\\")),1,-1) ")", %A_ScriptDir%\config\WubiIME.icl, , 30, 1
	}
Return

TVGUI:
	Index_:= GetVisible()
	if (A_GuiEvent = "Normal"&&A_EventInfo) {
		TV_GetText(SelectedItem_, A_EventInfo)
		If (A_EventInfo != TV1&&A_EventInfo != TV2){
			If (TV2_3 <> A_EventInfo)
				Gosub HideHotkeyControl_1
			SetVisibleHide(Index_,A_EventInfo), SetVisibleShow(A_EventInfo)
			If (TV2_3 = A_EventInfo)
				Gosub HideHotkeyControl_2
		}else{
			TV_Modify(A_EventInfo , TV_Get(A_EventInfo, "Expand")?"-Expand":"Expand")
		}
	}
Return

GetVisible(){
	Loop,% TV_GetCount()
	{
		GuiControlGet, VisiVar, Visible , GBox%A_Index%
		if VisiVar
			Return A_Index
	}
}

SetVisibleHide(Index,EventInfo){
	global TV_obj
	if !TV_Get(EventInfo, "Expand"){
		Loop,% TV_obj["GBoxList" Index].Length()
		{
			GuiControl, 98:Hide, % TV_obj["GBoxList" Index,A_Index]
		}
	}
}

SetVisibleShow(EventInfo){
	global TV_obj,Index_,TV1_1,TV1,TV2,TV2_1,TV2_2,TV2_3,TV3,TV4
	_objNum:=EventInfo=TV1_1?1:EventInfo=TV2_1?2:EventInfo=TV2_2?3:EventInfo=TV2_3?4:EventInfo=TV3?5:EventInfo=TV4?6:Index_
	Loop,% TV_obj["GBoxList" _objNum].Length()
	{
		if not TV_obj["GBoxList" _objNum,A_Index]~="i)^Setlabel$|^Savelabel$"
			GuiControl, 98:Show, % TV_obj["GBoxList" _objNum,A_Index]
	}
}

select_logo:
	GuiControlGet, select_logo,, select_logo, text
	if (select_logo<>"")
	{
		StyleN:=WubiIni.TipStyle["StyleN"]:=select_logo, WubiIni.save()
		Gui, logo:Destroy
		Gosub Schema_logo
	}
Return

InputStatus:
	GuiControlGet, InputStatus ,, InputStatus, Checkbox
	IStatus :=WubiIni.Settings["IStatus"]:=InputStatus,WubiIni.save()
	if IStatus {
		GuiControl,98:Enable,WinMode
		CursorStatus :=WubiIni.Settings["CursorStatus"]:=0, WubiIni.save()
		GuiControl,98:, Cursor_Status , 0
	}else
		GuiControl,98:Disable,WinMode
Return

Cursor_Status:
	GuiControlGet, Cursor_Status ,, Cursor_Status, Checkbox
	CursorStatus :=WubiIni.Settings["CursorStatus"]:=Cursor_Status,WubiIni.save()
	if Cursor_Status {
		IStatus :=WubiIni.Settings["IStatus"]:=0, WubiIni.save()
		GuiControl,98:, InputStatus , 0
		GuiControl,98:Disable,WinMode
	}else
		GuiControl,98:Enable,WinMode
Return

WinMode:
	Gosub DestroyGui
	Gui IM:Default
	Gui IM:+LastFound +Owner98 -MinimizeBox     ;; +AlwaysOnTop
	Gui, IM:font,10 bold,%Font_%
	Gui, IM:Add, Button, y+10 vDTxck gDTxck hWndDTBT,删除
	ImageButton.Create(DTBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	GuiControl,IM:Disable,DTxck
	Gui, IM:Add, Button, x+10 vAddProcess gAddProcess hWndAPBT,添加
	ImageButton.Create(APBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, IM:Add, DropDownList ,Choose1 w80 x+10 vIM_DDL gIM_DDL hWndIDDL , 中文|英文|剪切板    ;;+0x0210
	;;OD_Colors.Attach(IDDL,{T: 0x767641, B: 0xb3b3b3})
	GuiControl,IM:Disable,IM_DDL
	Gui, IM:font,10 norm,%Font_%
	Gui, IM:Add, ListView, AltSubmit Grid r15 x10 yp+30 -LV0x10 -Multi Checked NoSortHdr -wscroll -WantF2 0x8 LV0x40 hwndIPView gIPView vIPView  ,进程名|输入状态
	For Section, element In InputModeData
		For key, value In element
			if (value<>""&&Section~="CN|EN|CLIP")
				LV_Add(value=InputModeData["CN",1]?"Select":"" ,value,Section="CN"?"中文":Section="EN"?"英文":"剪切板"),LV_ModifyCol()
	LV_ModifyCol(2,"100 center")
	ColWidth:=0
	GuiControlGet, IMVar, Pos , IPView
	Loop % LV_GetCount("Column")
	{
		dIndex:=A_Index-1
		SendMessage, 4125, %dIndex%, , , ahk_id %IPView%  ; 4125 为 LVM_GETCOLUMNWIDTH.
		ColWidth+=ErrorLevel
	}
	if LV_GetCount()<1
		ColWidth:=240
	Gui, IM:font,10 bold,%Font_%
	Gui, IM:Add, Button, y+10 vRTxck gRTxck hWndRTBT,刷新列表
	Gui, IM:Color,ffffff
	Gui, IM:font,
	Gui, IM:font,9 norm,%Font_%
	Gui, IM:Add, StatusBar,
	ImageButton.Create(RTBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	GuiControl, IM:Move, IPView, % "w" (A_ScreenDPI/96>1?ColWidth/(A_ScreenDPI/96):ColWidth)
	SB_SetParts(ColWidth*0.4, ColWidth*0.5)
	SB_SetText( " ❖ 输入状态管理") 
	Gui,IM:Show, AutoSize,状态管理
	Gosub ChangeWinIcon
Return

IsProcessInfo(ProcessName){
	CaptionObj:=[],ProcessFullPath:=""
	for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
	{
		CaptionObj.push([process.Caption,process.ExecutablePath])
		if (process.Caption=ProcessName)
			ProcessFullPath:=CaptionObj[A_Index,2]
	}
	If Array_isInValue(CaptionObj, ProcessFullPath)
		return GetProcessInfo(ProcessFullPath)
}

GetProcessInfo(filepath){
	SplitPath, filepath , FileName, DirPath,
	objShell := ComObjCreate("Shell.Application")
	objFolder := objShell.NameSpace(DirPath)
	objFolderItem := objFolder.ParseName(FileName)
	Loop 283
		if propertyitem :=objFolder.GetDetailsOf(objFolderItem, A_Index)
			if objFolder.GetDetailsOf(objFolder.Items, A_Index)="文件说明"
				if propertyitem
					return propertyitem
}

IPView:
	if A_GuiEvent~="i)Normal" {
		LV_GetText(LVName_,A_EventInfo,2),LV_GetText(LVName,A_EventInfo,1), LVPOS:= A_EventInfo
		GuiControl,IM:,IM_DDL,% LVName_~="中文"?"|英文|剪切板":LVName_~="英文"?"|中文|剪切板":LVName_~="剪切板"&&GetArrIndex(InputModeData["CN"],LVName)?"|英文":LVName_~="剪切板"&&GetArrIndex(InputModeData["EN"],LVName)?"|中文":"|中文|英文"
		;;GuiControl, IM:ChooseString, IM_DDL, % LVName_
		GuiControl,IM:Enable,IM_DDL
		;;OD_Colors.Attach(IDDL,{T: 0xffffff, B: 0x0178d6})
		if LVName_~="剪切板" {
			GuiControl,IM:Disable,IM_DDL
			;;OD_Colors.Attach(IDDL,{T: 0xffffff, B: 0x0178d6})
		}else{
			GuiControl,IM:Enable,IM_DDL
			;;OD_Colors.Attach(IDDL,{T: 0xffffff, B: 0x0178d6})
		}
		LVName__:=LVName_="中文"?"CN":LVName_="英文"?"EN":"CLIP"
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, IM:Enable, DTxck
				GuiControl,IM:Disable,IM_DDL
				;;OD_Colors.Attach(IDDL,{T: 0xffffff, B: 0x0178d6})
				break
			}else{
				GuiControl, IM:Disable, DTxck
				GuiControl,IM:Enable,IM_DDL
				;;OD_Colors.Attach(IDDL,{T: 0xffffff, B: 0x0178d6})
				break
			}
		}
		ToolTip, % IsProcessInfo(LVName)   ;显示进程描述
	}
Return

AddProcess:
	Gui, 98:Hide
	Gui, IM:hide
	Progress, M ZH-1 ZW-1 W420 C0 FM14 WS700 CTffffff CW0078d7,, 将光标放在要选择窗口的位置，然后按<左Ctrl键>获取进程名，限时20秒！, 窗口进程获取
	OnMessage(0x201, "MoveProgress")
	keywait, LControl, D T20
	keywait, LControl
	Progress, off
	MouseGetPos, , , id
	WinGet, win_exe, ProcessName, ahk_id %id%,
	Set_IMode:=IMEmode~="i)off"?"EN":"CN", lineNum:=RowExist(win_exe)
	If (win_exe&&!lineNum) {
		If objCount(InputModeData[Set_IMode])
			InputModeData[Set_IMode].Push(win_exe)
		else
			InputModeData[Set_IMode]:=[win_exe]
		LV_Insert(LV_GetCount() ,"", win_exe, "中文")
		Json_ObjToFile(InputModeData, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
		LV_ModifyCol(2,"100 center"), ColWidth:=0
		GuiControlGet, IMVar, Pos , IPView
		Loop % LV_GetCount("Column")
		{
			dIndex:=A_Index-1
			SendMessage, 4125, %dIndex%, , , ahk_id %IPView%  ; 4125 为 LVM_GETCOLUMNWIDTH.
			ColWidth+=ErrorLevel
		}
		GuiControl, IM:Move, IPView, % "w" (A_ScreenDPI/96>1?ColWidth/(A_ScreenDPI/96):ColWidth)
	}
	Gui, 98:Show
	Gui, IM:show
	LV_Modify(lineNum?lineNum:LV_GetCount(), "Select")
	If (lineNum) {
		SB_SetText("`t ⛔ 该进程已存在！",2)
		Sleep 4000
		SB_SetText( "" ,2)
	}
Return

RowExist(ColumText,colum=1){
	Loop,% LV_GetCount()
	{
		LV_GetText(RetrievedText, A_Index,colum)
		If (RetrievedText=ColumText)
			Return A_Index
	}
}

RTxck:
	LV_Delete()
	For Section, element In InputModeData
		For key, value In element
			if (value<>""&&Section~="CN|EN|CLIP")
				LV_Add(value=InputModeData["CN",1]?"Select":"" ,value,Section="CN"?"中文":Section="EN"?"英文":"剪切板")
Return

GetRowNum(Text1,Text2){
	Loop,% LV_GetCount()
	{
		LV_GetText(RetrievedText1, A_Index,1), LV_GetText(RetrievedText2, A_Index,2)
			If (Text1=RetrievedText1&&Text2=RetrievedText2)
				Return A_Index
	}
}

IM_DDL:
	GuiControlGet, IM_DDL,, IM_DDL, text 
	if (IM_DDL&&IM_DDL<>LVName_&&LVName_&&LVName~="i)\.exe$") 
	{
		if IM_DDL ~="中文" {
			If (Ikey:=GetArrIndex(InputModeData["EN"],LVName)) {
				If (Ikey>1)
					InputModeData["EN"].RemoveAt(Ikey)
				else
					InputModeData.Delete("EN")
			}
			If objCount(InputModeData["CN"])
				InputModeData["CN"].Push(LVName)
			else
				InputModeData["CN"]:=[ LVName ]
			GetLineNum:=GetRowNum(InputModeData["CN",objCount(InputModeData["CLIP"])],"中文")
			LVPOS:=LVName__="CLIP"?GetRowNum(LVName,"英文"):LVPOS, LV_Modify(Ikey?LVPOS:GetLineNum?GetLineNum:LV_GetCount(),"text",LVName,IM_DDL)
		}else if IM_DDL ~="英文" {
			If (Ikey:=GetArrIndex(InputModeData["CN"],LVName)) {
				If (Ikey>1)
					InputModeData["CN"].RemoveAt(Ikey)
				else
					InputModeData.Delete("CN")
			}
			If objCount(InputModeData["EN"])
				InputModeData["EN"].Push(LVName)
			else
				InputModeData["EN"]:=[ LVName ]
			GetLineNum:=GetRowNum(InputModeData["EN",objCount(InputModeData["CLIP"])],"英文")
			LVPOS:=LVName__="CLIP"?GetRowNum(LVName,"中文"):LVPOS, LV_Modify(Ikey?LVPOS:GetLineNum?GetLineNum:LV_GetCount(),"text",LVName,IM_DDL)
		}else if IM_DDL ~="剪切板" {
			If objCount(InputModeData["CLIP"])
				InputModeData["CLIP"].Push(LVName)
			else
				InputModeData["CLIP"]:=[ LVName ]
			GetLineNum:=GetRowNum(InputModeData["CLIP",objCount(InputModeData["CLIP"])],"剪切板")
			LV_Insert(GetLineNum?GetLineNum+1:LVPOS ,"Select", LVName, "剪切板")
			;;Gosub RTxck
		}
		Json_ObjToFile(InputModeData, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
	}
Return

DTxck:
	DelRows()
	Json_ObjToFile(InputModeData, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
Return

DelRows(deb=""){
	global InputModeData
	Loop % (LV_GetCount(),a:=1)
	{	if ( LV_GetNext( 0, "C" ) = a )
		{	if ( !deb ){
				LV_GetText(LVar1, a , 1), LV_GetText(LVar2, a , 2)
				LV_Delete( a )
				Loop,% len:=objCount(InputModeData[LVar2="中文"?"CN":LVar2="英文"?"EN":"CLIP"])
				{
					if (InputModeData[LVar2="中文"?"CN":LVar2="英文"?"EN":"CLIP",A_Index]=LVar1) {
						If len>1
							InputModeData[LVar2="中文"?"CN":LVar2="英文"?"EN":"CLIP"].RemoveAt(A_Index)
						else
							InputModeData.Delete(LVar2="中文"?"CN":LVar2="英文"?"EN":"CLIP")
					}
				}
			}
		}else
			++a
	}
}

;样式面板关闭销毁保存操作
98GuiClose:
98GuiEscape:
	Gui, 98:Destroy
	Gosub DestroyGui
	Menu, Custom, Delete,
	Menu, MainMenu, Delete,
	Menu, ExtendTool, Delete,
	LsVar:=opvar:=posInfo:=""
	Result_:=Results_:=Result:=[]
	CaptainHook(KeyInitStatus:=false)
	WubiIni.Save()
Return

IMGuiClose:
	IMGuiEscape:
	Gui, IM:Destroy
	LVName_:=LVName:=LVName__=IM_DDL:=""
	WubiIni.Save()
Return

diyGuiClose:
	diyGuiEscape:
	Gui, diy:Destroy
	Result_:=Results_:=Result:=[]
	WubiIni.Save()
Return

costomcolor:
	Gosub diyColor
Return

Label_management:
	Gosub DestroyGui
	Gui, label:Default
	Gui, label: +hwndGuiLabel +Owner98 +OwnDialogs -MinimizeBox     ;+ToolWindow -DPIScale +AlwaysOnTop
	Gui,label:Font
	Gui,label:Font, s10 bold, %font_%
	Gui label:Add, GroupBox, y+10 w500 h450 vGBox8, 标签管理
	Gui,label:Font
	Gui,label:Font, s9, %font_%
	Gui, label:Add,CheckBox,xm+15 yp+40 gDellabel vDellabel,批量`n删除
	Gui, label:Add,Button,x+5 gDlabel vDlabel hWndDLBT, 删除
	ImageButton.Create(DLBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	GuiControl, label:Disable, Dlabel
	Gui, label:Add, Button,x+15 gRestlabel vRestlabel hWndRLBT, 重置
	ImageButton.Create(RLBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	Gui, label:Add, Button,x+8 gBlabel vBlabel hWndBLBT, 导出
	ImageButton.Create(BLBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, label:Add, Button,x+8 gWlabel vWlabel hWndWLBT, 导入
	ImageButton.Create(WLBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, label:Add, Button,x+8 gReloadlabel vReloadlabel hWndSLBT, 刷新
	ImageButton.Create(SLBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, label:Add, text,x+20 yp+2 w150 cred vupdatetip,
	Gui, label:Add, ListView,xm+15 y+20 h350 w450 Grid AltSubmit NoSortHdr NoSort -ReadOnly -Multi 0x8 LV0x40 -LV0x10 gMyLabel vMyLabel hwndHLV, 别名|标签名|标签说明
	GuiControl, +Hdr, MyLabel
	Gosub Glabel
	labellv := New LV_InCellEdit(HLV)
	labellv.SetColumns(1, 3)
	labellv.OnMessage()
	Gui, label:Color,ffffff
	Gui, label:add,StatusBar,, ❖ 双击修改，勾选批量删除，/+标签别名 执行标签！
	Gui, label:Show,AutoSize, 标签管理
	Gosub ChangeWinIcon
Return

Reloadlabel:
	LV_Delete()
	Gosub Glabel
Return

Dellabel:
	GuiControlGet, Dellabel ,, Dellabel, Checkbox
	If Dellabel
		GuiControl +Checked, MyLabel
	else
		GuiControl -Checked, MyLabel
Return

Glabel:
	If DB.gettable("SELECT * FROM 'extend'.'label';", Result){
		loop, % Result.RowCount
		{
			If islabel(Result.Rows[A_index,3])
				LV_Add("", Result.Rows[A_index,2], Result.Rows[A_index,3],Result.Rows[A_index,4])    ;, LV_ModifyCol()
		}
		LV_ModifyCol(1,"60 Center")
		LV_ModifyCol(2,"180 left")
		LV_ModifyCol(3,"190 left")
		;;CLV := New LV_Colors(HLV)
		;;CLV.SelectionColors(0xfecd1b)
	}
Return

MyLabel:
	If (A_GuiEvent == "F") {
		If (labellv["Changed"]) {
			For k, v In labellv.Changed    ;;v.Row   v.Col    v.Txt
			{
				If (v.Col=1&&v.Txt){
					if DB.Exec("UPDATE 'extend'.'label' SET B_Key ='" v.Txt "' WHERE C_Key ='" labelText2 "' AND B_Key ='" labelText1 "';")>0
					{
						DB.gettable("select B_Key from 'extend'.'label' WHERE C_Key ='" labelText2 "' AND D_Key ='" labelText3 "';",Result)
						If (Result.Rows[1,1]=v.txt) {
							GuiControl,label:,updatetip,修改成功！
							Sleep 2500
							GuiControl,label:,updatetip,
						}else{
							LV_Modify(v.Row,"text",labelText1,labelText2,labelText3)
							GuiControl,label:,updatetip,修改失败！
							Sleep 2500
							GuiControl,label:,updatetip,
						}
					}
				}else If (v.Col=3&&v.Txt) {
					if DB.Exec("UPDATE 'extend'.'label' SET D_Key ='" v.Txt "' WHERE C_Key ='" labelText2 "' AND D_Key ='" labelText3 "';")>0
					{
						DB.gettable("SELECT D_Key FROM 'extend'.'label' WHERE C_Key ='" labelText2 "' AND B_Key ='" labelText1 "'",Result)
						If (Result.Rows[1,1]=v.txt) {
							GuiControl,label:,updatetip,修改成功！
							Sleep 2500
							GuiControl,label:,updatetip,
						}else{
							LV_Modify(v.Row,"text",labelText1,labelText2,labelText3)
							GuiControl,label:,updatetip,修改失败！
							Sleep 2500
							GuiControl,label:,updatetip,
						}
					}
				}else If (v.Txt=""){
					LV_Modify(v.Row,"text",labelText1,labelText2,labelText3)
				}
			}
			labellv.Remove("Changed")
		}
	}else if (A_GuiEvent = "Normal"&&Dellabel) {
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, label:Enable, Dlabel
				break
			}else{
				GuiControl, label:Disable, Dlabel
				break
			}
		}
	}else if (A_GuiEvent = "DoubleClick"&&A_EventInfo) {
		LV_GetText(labelText1,A_EventInfo,1),LV_GetText(labelText2,A_EventInfo,2), LV_GetText(labelText3,A_EventInfo,3)
	}
return

Restlabel:
	Gui +OwnDialogs
	MsgBox, 262452, 提示, 是否重置所有标签?
	IfMsgBox, Yes
	{
		LV_Delete()
		if DB.Exec("DROP TABLE 'extend'.'label';")>0
		{
			DB.Exec("create table 'extend'.'label' as select * from 'extend'.'label_init';")
			Gosub Glabel
		}
	}
return

Blabel:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,,3,请选择导出后保存的位置
	if OutFolder<>
	{
		if DB.gettable("SELECT B_Key,C_Key,D_Key FROM 'extend'.'label';",Result){
			FileDelete, %OutFolder%\label.txt
			Loop % Result.RowCount
			{
				Resoure_ .=Result.Rows[A_index,1] A_tab Result.Rows[A_index,2] A_tab Result.Rows[A_index,3] "`n"
			}
			FileAppend,%Resoure_%,%OutFolder%\label.txt, UTF-8
			TrayTip,, 导出完成，文件名路径为：`n「%OutFolder%\label.txt」
			Resoure_ :=OutFolder :=""
		}
	}
Return

Wlabel:
	Gui +OwnDialogs
	FileSelectFile, LabelFile, 3, , 导入标签文件, Text Documents (*.txt)
	SplitPath, LabelFile, , , , filename
	If (LabelFile = ""){
		TrayTip,, 取消导入
		Return
	} Else {
		TrayTip,, 你选择了文件「%filename%」
	}
	If !filename
		Return
	Gui +OwnDialogs
	MsgBox, 262452, 提示, 要导入以下标签文件进行替换？`n标签格式为：标签别名+Tab+标签名+Tab+标签说明
	IfMsgBox, No
	{
		TrayTip,, 导入已取消！
		Return
	} Else {
		TrayTip,, 标签写入中，请稍后...
		Create_label(DB,LabelFile)
		tarr:=[],count :=0
		GetFileFormat(LabelFile,label_all,Encoding)
		If (Encoding="UTF-16BE BOM") {
			MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 10
			Return
		}
		Loop, Parse, label_all, `n, `r
		{
			count++
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
			Insert_label .="(null,'" tarr[1] "','" tarr[2] "','" tarr[3] "')" ","
		}
		Insert_label :=RegExReplace(Insert_label,"\,$","")
		if DB.Exec("INSERT INTO 'extend'.'label' VALUES" Insert_label "")>0
		{
			LV_Delete()
			Gosub Glabel
			TrayTip,, 写入%count%行label标签！
		}
		else
		{
			TrayTip,, 格式不对...
			return
		}
	}
	label_all:=Insert_label:=""
Return

Dlabel:
	DelLabel()
Return

DelLabel(deb =""){
	Loop % (LV_GetCount(),a:=1)
	{	if ( LV_GetNext( 0, "Checked" ) = a )
		{	if ( !deb ){
				LV_GetText(LVar1, a , 1)
				LV_Delete( a )
				DB.Exec("DELETE FROM 'extend'.'label' WHERE B_Key ='" LVar1 "';")
			}
		}else
			++a
	}
}

SetInput_Mode:
	GuiControlGet, CNMode ,, SetInput_CNMode, Checkbox
	GuiControlGet, ENMode ,, SetInput_ENMode, Checkbox
	if CNMode&&!ENMode
		IMEmode:=WubiIni.Settings["IMEmode"]:="on",WubiIni.save()
	else
		IMEmode:=WubiIni.Settings["IMEmode"]:="off",WubiIni.save()
Return

;快捷键选择键盘界面
Key_:
	KeyName:={ "":"Space", Caps:"CapsLock", App:"AppsKey", Psc:"PrintScreen", Slk:"ScrollLock", "↑":"Up", "↓":"Down", "←":"Left", "→":"Right" ,"清空":""}
	w1:=35, h1:=20, w2:=50, w3:=w1*14+2*13

	s1:=[ ["Esc"],["F1",,w3-w1*13-15*2-2*9],["F2"],["F3"],["F4"],["F5",,15],["F6"],["F7"],["F8"],["F9",,15],["F10"],["F11"],["F12"],["Psc",w2,10],["Slk",w2],["Pause",w2] ]

	s2:=[ ["``"],["1"],["2"],["3"],["4"],["5"],["6"],["7"],["8"],["9"],["0"],["-"],["="],["BS"],["Ins",w2,10],["Home",w2],["PgUp",w2] ]

	s3:=[ ["Tab"],["q"],["w"],["e"],["r"],["t"],["y"],["u"],["i"],["o"],["p"],["["],["]"],["\"],["Del",w2,10],["End",w2],["PgDn",w2] ]

	s4:=[ ["Caps",w2],["a"],["s"],["d"],["f"],["g"],["h"],["j"],["k"],["l"],["`;"],["'"],["Enter",w3-w1*11-w2-2*12] ,["清空",w2,10]]

	s5:=[ ["Shift",w1*2],["z"],["x"],["c"],["v"],["b"],["n"],["m"],[","],["."],["/"],["Shift",w3-w1*12-2*11],["↑",w2,10+w2+2] ]

	s6:=[ ["Ctrl",w2],["Win",w2],["Alt",w2],["",w3-w2*7-2*7],["Alt",w2],["Win",w2],["App",w2],["Ctrl",w2],["←",w2,10],["↓",w2],["→",w2] ]

	Gui, Key: Destroy
	Gui, Key: +Owner98 +ToolWindow +E0x08000000 -MinimizeBox ;;+AlwaysOnTop
	Gui, Key: Font, s9, Verdana
	Gui, Key: Margin, 10, 10
	Gui, Key: Color, ffffff
	Loop, 6 {
		if (A_Index<=2)
		j=
		For i,v in s%A_Index%
		{
			w:=v.2 ? v.2 : w1, d:=v.3 ? v.3 : 2
			j:=j="" ? "xm" : i=1 ? "xm y+2" : "x+" d
			Gui, Key: Add, Button, %j% w%w% h%h1% -Wrap gRunKey, % v.1
		}
	}
	Gui, Key: Add, StatusBar,vsbt,❖ 请选取按键 。。。
	Gui, Key: Show, NA, 小键盘
return

KeyGuiClose:
	Gui, Key: Destroy
return

RunKey:
	k:=A_GuiControl
return

Control0:
	GuiControlGet, Control0 ,, Control0, Checkbox
Return

hk_1:
	GuiControlGet, OVar, 98:Visible , sethotkey_4
	If OVar {
		CaptainHook(KeyInitStatus:=false), KeyCodeObj:={}
		GuiControlGet, hotkey_4, ,sethotkey_4 , text
		Hotkey, %Srf_Hotkey%, SetHotkey,off
		Srf_Hotkey:=hotkey_4?hotkey_4:Srf_Hotkey, HotkeyRegister()
		WubiIni.Settings["Srf_Hotkey"]:=hotkey_4?formatHotkey(hotkey_4):Srf_Hotkey, WubiIni.save()
		hkobj:=StrSplit(WubiIni.Settings["Srf_Hotkey"],"&")
		GuiControl,98:,sethotkey_1,% objCount(hkobj)=2?hkobj[1]:(objCount(hkobj)>2?hkobj[1] "+" hkobj[2]:Srf_Hotkey)
		GuiControl,98:,sethotkey_3,% objCount(hkobj)=2?hkobj[2]:(objCount(hkobj)=3?hkobj[3]:objCount(hkobj)>3?hkobj[3] "+" hkobj[4])
	}else{
		CaptainHook(KeyInitStatus:=false), KeyCodeObj:={}
		GuiControl,98:,sethotkey_2,获取键名
		ImageButton.Create(KNBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
		GuiControl,98:,sethotkey_2,获取键名
		GuiControlGet, hotkey_1, ,sethotkey_1 , text
		GuiControlGet, hotkey_3, ,sethotkey_3 , text
		If (hotkey_1&&hotkey_3) {
			Hotkey, %Srf_Hotkey%, SetHotkey,off
			Srf_Hotkey:=formatHotkey_2(hotkey_1 " & " hotkey_3), HotkeyRegister()
			WubiIni.Settings["Srf_Hotkey"]:=formatHotkey(Srf_Hotkey), WubiIni.save()
		}else If (hotkey_1&&!hotkey_3||hotkey_3&&!hotkey_1){
			Hotkey, %Srf_Hotkey%, SetHotkey,off
			Srf_Hotkey:=formatHotkey_2(hotkey_1?hotkey_1:hotkey_3), HotkeyRegister()
			WubiIni.Settings["Srf_Hotkey"]:=Srf_Hotkey, WubiIni.save()
		}
		hotkey_1:=hotkey_3:=""
		GuiControl,98:Disable,hk_1
		GuiControl,98:Hide,sethotkey_1
		GuiControl,98:Hide,sethotkey_3
		GuiControl,98:Hide,Control0
		GuiControl,98:Show,sethotkey_4
		GuiControl,98:,sethotkey_4,% Srf_Hotkey~="i)RShift"?RegExReplace(Srf_Hotkey,"i)RShift","Shift"):Srf_Hotkey
	}
Return

tip_text:
	GuiControlGet, OVar, 98:Visible , sethotkey_4
	If OVar
		GuiControl,98:,sethotkey_4,
	else{
		GuiControl,98:,sethotkey_1,
		GuiControl,98:,sethotkey_3,
		GuiControl,98:Enable,Control0
		GuiControl,98:Enable,sethotkey_1
		GuiControl,98:Enable,sethotkey_3
	}
Return

sethotkey_1:
	GuiControl,98:Enable,hk_1
Return

sethotkey_2:
	If (KeyInitStatus=false) {
		GuiControl,98:Show,sethotkey_1
		GuiControl,98:Show,sethotkey_3
		GuiControl,98:Show,Control0
		GuiControl,98:Hide,sethotkey_4
		srf_mode:=0
		Gosub Srf_Tip
		GuiControl,98:,sethotkey_2,已开启
		ImageButton.Create(KNBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
		GuiControl,98:,sethotkey_2,已开启
		CaptainHook(KeyInitStatus:=true)
	}else{
		GuiControl,98:Hide,sethotkey_1
		GuiControl,98:Hide,sethotkey_3
		GuiControl,98:Hide,Control0
		GuiControl,98:Show,sethotkey_4
		CaptainHook(KeyInitStatus:=false), KeyCodeObj:={}
		GuiControl,98:,sethotkey_2,获取键名
		ImageButton.Create(KNBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
		GuiControl,98:,sethotkey_2,获取键名
	}
Return

HideHotkeyControl_1:
	GuiControl,98:Hide,sethotkey_1
	GuiControl,98:Hide,sethotkey_3
	GuiControl,98:Hide,Control0
	GuiControl,98:Hide,sethotkey_4
	CaptainHook(KeyInitStatus:=false), KeyCodeObj:={}
	GuiControl,98:,sethotkey_2,获取键名
	ImageButton.Create(KNBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	GuiControl,98:,sethotkey_2,获取键名
Return

HideHotkeyControl_2:
	GuiControl,98:Hide,sethotkey_1
	GuiControl,98:Hide,sethotkey_3
	GuiControl,98:Hide,Control0
	GuiControl,98:Show,sethotkey_4
	CaptainHook(KeyInitStatus:=false), KeyCodeObj:={}
	GuiControl,98:,sethotkey_2,获取键名
	ImageButton.Create(KNBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	GuiControl,98:,sethotkey_2,获取键名
Return

sethotkey_3:
	GuiControl,98:Enable,hk_1
Return

sethotkey_4:
	GuiControl,98:Enable,hk_1
Return

yaml_:
	GuiControlGet, yamls ,, yaml_, Checkbox
	if yamls
		BUyaml:=WubiIni.Settings["BUyaml"]:=1, WubiIni.save()
	else
		BUyaml:=WubiIni.Settings["BUyaml"]:=0, WubiIni.save()
Return

ControlGui:
	SendMessage,0xC,, "输入法设置"
	if FileExist(A_ScriptDir "\Config\Skins\preview\" ThemeName ".png")
		GuiControl,98:, themelogo,Config\Skins\preview\%ThemeName%.png
	else
		GuiControl,98:, themelogo,Config\Skins\preview\Error.png
	if !FileExist(A_ScriptDir "\Sync\Default.json")
		GuiControl, 98:Disable, Rest_Conf
	If Logo_Switch~="i)off"
		GuiControl, 98:Disable, select_logo
	If !FileExist(BaseDir)
		GuiControl,98:Disable,UIAccess

	if PromptChar
	{
		Prompt_Word:=WubiIni.Settings["Prompt_Word"]:="off"
		GuiControl,98:, SBA24 , 0
	}
	if Prompt_Word~="i)on" {
		PromptChar:=WubiIni.Settings["PromptChar"]:=0
		GuiControl,98:, SBA3 , 0
	}
	if (not Wubi_Schema ~="i)zi|ci")
		GuiControl, 98:Disable, SBA23
	if !FileExist(A_ScriptDir "\Sync\header.txt")
		GuiControl, 98:Disable, yaml_
	if (not Wubi_Schema~="i)ci"||Trad_Mode~="i)on"||Prompt_Word~="i)on") {
		GuiControl, 98:Disable, Frequency
	}
	if (not Wubi_Schema~="i)ci"||Trad_Mode~="i)on"||Prompt_Word~="i)on"||!Frequency) {
		;;OD_Colors.Attach(FRDL,{T: 0x767641, B: 0xb3b3b3})
		GuiControl, 98:Disable, FTip
		GuiControl, 98:Disable, set_Frequency
		GuiControl, 98:Disable, RestDB
	}
	if !IStatus
		GuiControl,98:Disable,WinMode

	For k,v In ["on","off","Gdip","ci","zi","chaoji","zg"]
	{
		if (ToolTipStyle~="i)" v)
			Menu_CheckRadioItem(HMENU, k)
		if (Wubi_Schema~="i)" v){
			Menu_CheckRadioItem(SMENU, k-3)
		}
	}
	if ToolTipStyle ~="i)off|on"{
		For k,v In ["SBA12","SBA9","SBA10","SBA19","set_FocusRadius","set_FocusRadius_value","set_FocusRadius","set_FocusRadius_value"]
			GuiControl, 98:Disable, %v%
	}
	For k,v In {Logo_ExStyle:"ExSty",PromptChar:"SBA24",BUyaml:"yaml_",PageShow:"SBA20",Exit_switch:"SBA22",FocusStyle:"SBA19",UIAccess:"UIAccess"}
		If (%k%)
			GuiControl,98:, %v% , 1

	For k,v In {Radius:"SBA9",FontStyle:"SBA12",Logo_Switch:"SBA13",Gdip_Line:"SBA10",Prompt_Word:"SBA3",symb_send:"SBA6",limit_code:"SBA7",length_code:"SBA26",Trad_Mode:"SBA11"}
		if (%k%~="i)on")
			GuiControl,98:, %v% , 1
	If (Fix_Switch="off")
		GuiControl,98:, SBA5 , 1
	if Logo_Switch~="off" {
		For k,v In ["SrfSlider","select_logo","ExSty","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps", "showtools","DPISty"]
			GuiControl, 98:Disable, %v%
	}
	If srfTool {
		For k,v In ["ExSty","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps"]
			GuiControl, 98:Disable, %v%
	}
	if ToolTipStyle ~="i)on|off"{
		For k,v In ["LineColor","BorderColor","SBA19"]
			GuiControl, 98:Disable, %v%
	}
	GuiControl, 98:ChooseString, set_Frequency, %Freq_Count%
	if themelist~=ThemeName "|"
		GuiControl, 98:ChooseString, select_theme, % ThemeName
	else
		GuiControl, 98:Choose, select_theme, 0

	if IMEmode~="on"
		GuiControl,98:, SetInput_CNMode , 1
	else
		GuiControl,98:, SetInput_ENMode , 1

	if !rlk_switch
		GuiControl, 98:Disable, tiphotkey
	else
		GuiControl,98:, SBA15 , 1
	if !Suspend_switch
		GuiControl, 98:Disable, Suspendhotkey
	else
		GuiControl,98:, SBA16 , 1
	if !Addcode_switch
		GuiControl, 98:Disable, Addcodehotkey
	else
		GuiControl,98:, SBA17 , 1
	If (zkey_mode=2){
		GuiControl,98:choose, zKeySet , 3
	}else If (zkey_mode=1){
		GuiControl,98:choose, zKeySet , 2
		GuiControl, 98:Disable, SBA18
	}else{
		GuiControl,98:choose, zKeySet , 1
		GuiControl, 98:Disable, SBA18
	}
	If (symb_mode=1)
		GuiControl,98:, SBA14 , 1
	if Initial_Mode~="i)on" {
		GuiControl,98:choose, sChoice1 , 2
	}else{
		GuiControl,98:choose, sChoice1 , 1
		GuiControl, 98:Disable, InitiaMode
	}
	if Select_Enter~="i)clean" {
		GuiControl,98:choose, sChoice2 , 2
	}else{
		GuiControl,98:choose, sChoice2 , 1
	}
	GuiControl,98:choose, PageChoice , %TurnPage%
	GuiControl,98:choose, ChoiceCode,%ChoiceItems%
	if Textdirection~="i)vertical" {
		GuiControl,98:choose, sChoice3 , 2
	}else{
		GuiControl,98:choose, sChoice3 , 1
	}

	if Fix_Switch~="i)on"{
		GuiControl, 98:Enable, SBA0
	}else{
		GuiControl, 98:Disable, SBA0
	}

	if cf_swtich {
		GuiControl,98:, SBA2 , 1
	}else{
		GuiControl, 98:Disable, cfhotkeys
	}
	if s2t_swtich {
		GuiControl,98:, SBA1 , 1
	}else{
		GuiControl, 98:Disable, s2thotkeys
	}

	if Startup~="i)on" {
		GuiControl,98:choose, SBA4 , 1
	}else if Startup~="i)sc"{
		GuiControl,98:choose, SBA4 , 2
	}else{
		GuiControl,98:choose, SBA4 , 3
	}

	if ToolTipStyle ~="i)off|gdip" {
		For k,v In ["set_regulate_Hx","set_regulate"]
			GuiControl, 98:Disable, %v%
	}
	if (ToolTipStyle ~="i)off|on"||Radius~="i)off") {
		For k,v In ["set_GdipRadius","GdipRadius","set_FocusRadius","set_FocusRadius_value"]
			GuiControl, 98:Disable, %v%
	}
Return

Show_Setting:
	Gosub More_Setting
Return

EnableUIAccess(path="", flag=0){
	global WubiIni, UIAccess, BaseDir
	If (A_GuiEvent){
		GuiControlGet, UIA, 98:, UIAccess
		WubiIni["Settings","UIAccess"]:=UIA, WubiIni.Save()
		EXEPath:=RegExReplace(A_AhkPath,"_UIA")
		Run *RunAs "%EXEPath%" "%A_ScriptFullPath%"
	}
	If (!path||path~="^\d+$"||path="Normal")
		Loop, Files, %BaseDir%\*.exe
			If !InStr(A_LoopFileLongPath,"_UIA")
				path:=A_LoopFileLongPath
	flag:=UIAccess?UIAccess:flag=1?flag:0
	If (flag&&!InStr(DllCall("GetCommandLine", "Str"), "_UIA.exe")){  ;;InStr(DllCall("GetCommandLine", "Str"), "_UIA.exe")
		AhkName:=RegExReplace(path,"\.exe","_UIA.exe"), ProcessName :=RegExReplace(A_AhkPath,".+\\")
		If FileExist(AhkName) {
			Run *RunAs "%AhkName%" "%A_ScriptFullPath%"
		}else{
			Program:=RegExReplace(AhkName,"\s+","/")
			Try RunWait *RunAs "%A_AhkPath%" "%A_ScriptDir%\Config\Script\EnableUIAccess.ahk" %Program%
			Catch
				Goto Exception
			If FileExist(AhkName) {
				Run *RunAs "%AhkName%" "%A_ScriptFullPath%"
				runwait, %ComSpec% /c taskkill /f /IM %ProcessName%, , Hide
			}
		}
	}
	Return
	Exception:
		WubiIni["Settings","UIAccess"]:=UIAccess:=0
		If (A_GuiEvent)
			GuiControl, 98:, UIAccess, 0
	Return
}

zKeySet:
	GuiControlGet, Keypos, ,zKeySet , text
	If Keypos~="拼音"{
		zkey_mode:=WubiIni.Settings["zkey_mode"]:=0,WubiIni.save()
		GuiControl, 98:Disable, SBA18
	}else If Keypos~="笔画"{
		zkey_mode:=WubiIni.Settings["zkey_mode"]:=2,WubiIni.save()
		GuiControl, 98:Enable, SBA18
	}else{
		zkey_mode:=WubiIni.Settings["zkey_mode"]:=1,WubiIni.save()
		GuiControl, 98:Disable, SBA18
	}
Return

ChoiceCode:
	GuiControlGet, ChoiceCode,, ChoiceCode, text
	If ChoiceCode~="句号" {
		ChoiceItems:=WubiIni.Settings["ChoiceItems"]:=1,WubiIni.save(), HotkeyRegister()
	}else If ChoiceCode~="引号"{
		ChoiceItems:=WubiIni.Settings["ChoiceItems"]:=2,WubiIni.save(), HotkeyRegister()
	}else If ChoiceCode~="i)shift" {
		ChoiceItems:=WubiIni.Settings["ChoiceItems"]:=3,WubiIni.save(), HotkeyRegister()
	}
Return

SetChoiceCodeHotkey:
	If (ChoiceItems=3&&srf_all_input)
		srf_select(A_thishotkey="lshift"?2:3)
	Gosub srf_value_off
Return

PageChoice:
	GuiControlGet, PageChoice,, PageChoice, text
	If PageChoice~="句号"
		TurnPage:=WubiIni.Settings["TurnPage"]:=1,WubiIni.save()
	else If PageChoice~="等号"
		TurnPage:=WubiIni.Settings["TurnPage"]:=2,WubiIni.save()
	else If PageChoice~="括号"
		TurnPage:=WubiIni.Settings["TurnPage"]:=3,WubiIni.save()
	else
		TurnPage:=WubiIni.Settings["TurnPage"]:=4,WubiIni.save()
Return

sChoice1:
	GuiControlGet, sChoice1,, sChoice1, text
	if sChoice1~="常规" {
		Initial_Mode:=WubiIni.Settings["Initial_Mode"]:="off",WubiIni.save()
		GuiControl, 98:Disable, InitiaMode
	}else{
		Initial_Mode:=WubiIni.Settings["Initial_Mode"]:="on",WubiIni.save()
		GuiControl, 98:Enable, InitiaMode
	}
	Gosub SwitchSC
Return

sChoice2:
	GuiControlGet, sChoice2,, sChoice2, text
	if sChoice2~="清空"
		Select_Enter:=WubiIni.Settings["Select_Enter"]:="clean",WubiIni.save()
	else
		Select_Enter:=WubiIni.Settings["Select_Enter"]:="send",WubiIni.save()
Return

LongStringlists:
	Gosub DestroyGui
	Gui, ts:Default
	Gui, ts: +Owner98  ;+ToolWindow -MinimizeBox   ;;+AlwaysOnTop -DPIScale 
	Gui, ts:font,,%Font_%
	SysGet, CXVSCROLL, 2
	ts_width:=620+CXVSCROLL, CountNum:=0
	Gui, ts:Add, ListView, r15 w%ts_width% Grid AltSubmit ReadOnly NoSortHdr NoSort -WantF2 -Multi 0x8 LV0x40 -LV0x10 vLongString hwndLSLV, 编码|【 副标题 】|【 标题 】|【 标题释义 】
	Gosub GetLongString
	Gui, ts:font
	Gui, ts:font,bold,%Font_%
	Gui, ts:Add, Button, Section gLongStringWrite vLongStringWrite hWndLSBT1, 导入
	ImageButton.Create(LSBT1, [6, 0x80404040, 0xC0C0C0, "yellow"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, ts:Add, Button, x+10 yp Section gLongStringBackup vLongStringBackup hWndLSBT2, 导出
	ImageButton.Create(LSBT2, [6, 0x80404040, 0xC0C0C0, "yellow"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	ts_width:=ts_width-310
	Gui, ts:Add, Button, x+%ts_width% yp Section gtoppage_chars vtoppage_chars hWndtoppage_chars, 首页
	ImageButton.Create(toppage_chars, [6, 0x80404040, 0xC0C0C0, "blue"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, ts:Add, Button, x+10 yp Section gLastpage_chars vLastpage_chars hWndLastpage_chars, 上一页
	ImageButton.Create(Lastpage_chars, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, ts:Add, Button, x+10 yp Section gNextpage_chars vNextpage_chars hWndNextpage_chars, 下一页
	ImageButton.Create(Nextpage_chars, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, ts:Add, Button, x+10 yp Section gEndpage_chars vEndpage_chars hWndEndpage_chars, 末页
	ImageButton.Create(Endpage_chars, [6, 0x80404040, 0xC0C0C0, "blue"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	GuiControl,ts:Disable,Lastpage_chars
	GuiControl,ts:Disable,toppage_chars
	If (lineCount<40||!lineCount) {
		GuiControl,ts:Disable,Nextpage_chars
		GuiControl,ts:Disable,Endpage_chars
	}
	Gui, ts:font
	Gui, ts:font,norm,%Font_%
	Gui, ts:Add, StatusBar,, ❖
	SB_SetText(" ❖ " A_Space CountNum+1 "/" pageNum . "页 -" lineCount "条")
	Gui, ts:show, AutoSize, 长字符串管理 ● 输出方法：/+编码+z结尾
	Gosub ChangeWinIcon
Return

GetLongString:
	DB.gettable("select * from TangSongPoetics ORDER BY A_Key,Author ASC;",Result)
	lineCount:=Result.RowCount, pageNum:=ceil(lineCount/40)
	If Result.RowCount>0
		loop,% (CountNum>=pageNum?lineCount-(CountNum-1)*40:40)
			LV_Add("", Result.Rows[CountNum*40+A_Index,1],Result.Rows[CountNum*40+A_Index,2],Result.Rows[CountNum*40+A_Index,3],substr(Result.Rows[CountNum*40+A_Index,4],1,25))
	LV_ModifyCol(1,"60 "), LV_ModifyCol(2,"120 Center"), LV_ModifyCol(3,"200 Center"), LV_ModifyCol(4,"240 ")
	SB_SetText(" ❖ " A_Space CountNum+1 "/" pageNum . "页 -" lineCount "条")
Return

tsGuiClose:
tsGuiEscape:
	Gui, ts:Destroy
	WubiIni.Save()
Return

Endpage_chars:
	CountNum:=Floor(lineCount/40)
	GuiControl,ts:Disable,Nextpage_chars
	GuiControl,ts:Disable,Endpage_chars
	GuiControl,ts:Enable,toppage_chars
	GuiControl,ts:Enable,Lastpage_chars
	LV_Delete()
	Gosub GetLongString
Return

toppage_chars:
	CountNum:=0
	GuiControl,ts:Disable,toppage_chars
	GuiControl,ts:Disable,Lastpage_chars
	GuiControl,ts:Enable,Nextpage_chars
	GuiControl,ts:Enable,Endpage_chars
	LV_Delete()
	Gosub GetLongString
Return

Nextpage_chars:
	CountNum++
	LV_Delete()
	Gosub GetLongString
	if (CountNum+1>=pageNum) {
		GuiControl,ts:Disable,Nextpage_chars
		GuiControl,ts:Disable,Endpage_chars
	}else{
		GuiControl,ts:Enable,Lastpage_chars
		GuiControl,ts:Enable,toppage_chars
	}
Return

Lastpage_chars:
	CountNum--
	LV_Delete()
	Gosub GetLongString
	if (CountNum<1) {
		GuiControl,ts:Disable,Lastpage_chars
		GuiControl,ts:Disable,toppage_chars
	}else{
		GuiControl,ts:Enable,Nextpage_chars
		GuiControl,ts:Enable,Endpage_chars
	}
Return

LongStringWrite:
	Gosub Write_LongChars
	LV_Delete(), CountNum:=0
	Gosub GetLongString
Return

LongStringBackup:
	Gosub Backup_LongChars
	LV_Delete(), CountNum:=0
	Gosub GetLongString
Return

themelists:
	Gosub DestroyGui
	Gui, themes:Default
	Gui, themes: +Owner98  ;+ToolWindow -MinimizeBox   ;;+AlwaysOnTop -DPIScale 
	Gui, themes:font,,%Font_%
	Gui, themes:Add, ListView, r15 w425 Grid AltSubmit ReadOnly NoSortHdr NoSort -WantF2 Checked -Multi 0x8 LV0x40 -LV0x10 gMyTheme vMyTheme hwndThemeLV, 主题名称|预览图|文件路径
	themelist:=""
	Loop Files, config\Skins\*.json
	{
		themelist.="|" SubStr(A_LoopFileName,1,-5)
		if SubStr(A_LoopFileName,1,-5){
			if FileExist(A_ScriptDir "\config\Skins\preview\" SubStr(A_LoopFileName,1,-5) ".png")
				IsExists:="存在"
			else
				IsExists:="不存在"
			LV_Add(SubStr(A_LoopFileName,1,-5)~=ThemeName?"Select":"", SubStr(A_LoopFileName,1,-5),IsExists,A_LoopFileLongPath), LV_ModifyCol()
		}
	}
	;LV_ModifyCol(1,"120 Integer left")
	LV_ModifyCol(2,"80 Integer center")
	Gui, themes:font
	Gui, themes:font,bold,%Font_%
	themelist:=RegExReplace(themelist,"\|$")
	Gui, themes:Add, Button, Section gSelectV2 vSelectV2 hWndSEBT, 删除
	ImageButton.Create(SEBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	GuiControl, themes:Disable, SelectV2
	Gui, themes:Add, Button, x+10 yp Section gSelectV3 hWndODBT, 打开目录
	ImageButton.Create(ODBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, themes:font
	Gui, themes:font,norm,%Font_%
	Gui, themes:Add, StatusBar,, ❖
	colum:=colum_:=0
	Loop % LV_GetCount("Column")
	{
		Index:=A_Index-1
		SendMessage, 4125, %Index%, , , ahk_id %ThemeLV%  ; 4125 为 LVM_GETCOLUMNWIDTH.
		colum%A_Index%:=ErrorLevel, colum+=ErrorLevel
	}
	SysGet, CXVSCROLL, 2
	colum:=colum/(A_ScreenDPI/96)+CXVSCROLL, colum_:=colum+30
	GuiControl, themes:Move, MyTheme, w%colum%
	SB_SetText(" ❖ " A_Space LV_GetCount() . "个主题")
	;;SB_SetIcon("Config\WubiIME.icl",30)
	Gui, themes:show, AutoSize, 主题管理
	Gosub ChangeWinIcon
Return

themesGuiClose:
	themesGuiEscape:
	Gui, themes:Destroy
	WubiIni.Save()
Return

MyTheme:
	if (A_GuiEvent = "RightClick"){
		LV_GetText(pos_name, A_EventInfo)
		if pos_name
			select_theme:=pos_name, lineInfo:=A_EventInfo
	}else if (A_GuiEvent = "DoubleClick"){
		LV_GetText(themes_name, A_EventInfo,3)
		Gosub SelectV3
	}else if (A_GuiEvent = "Normal"){
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, themes:Enable, SelectV2
				break
			}else{
				GuiControl, themes:Disable, SelectV2
				break
			}
		}
	}
Return

; 创建弹出菜单:
themesGuiContextMenu:
	Menu, SelectContextMenu, Add, 应用, SelectV1
	Menu, SelectContextMenu, Default, 应用
	Menu, SelectContextMenu, Show, %A_CaretX%, %A_CaretY%
Return

ClearItems(deb =""){
	global themelist,ThemeName
	Loop % (LV_GetCount(),a:=1)
	{	if ( LV_GetNext( 0, "Checked" ) = a )
		{	if ( !deb ){
				LV_GetText(LVar_, a , 1),LV_GetText(LVar, a , 3),themelist_.=LVar_ "|"
				FileDelete, %LVar%
				LV_Delete( a )
			}
		}else
			++a
	}
	themelist_:=RegExReplace(themelist_,"\|$")
	themelist:=RegExReplace(RegExReplace(themelist,themelist_),"\|{2,}","|")
	SB_SetText(" ❖ " A_Space LV_GetCount() . "个主题")
	GuiControl,98:, select_theme , "|"
	GuiControl,98:, select_theme , %themelist%
	if FileExist(A_ScriptDir "\Config\Skins\" ThemeName ".json")
		GuiControl, 98:ChooseString, select_theme, %ThemeName%
}

SelectV1:
	Gosub _FileToObj
	if FileExist(A_ScriptDir "\Config\Skins\" ThemeName ".json")
		GuiControl, 98:ChooseString, select_theme, %ThemeName%
Return

SelectV2:
	ClearItems()
Return

SelectV3:
	Run explorer.exe /select`, %themes_name%
	WinMinimize, ahk_id %hwndgui98%
Return

BackLogo:
	GuiControlGet, backtheme,, BUTheme, text
	if (not backtheme~="\s+"&&backtheme<>"")
	{
		Themeinfo:={}
		For Section, element In srf_default_obj
			For key, value In element
				If key in BgColor,BorderColor,FocusBackColor,FocusColor,FontCodeColor,FontColor,LineColor,FocusCodeColor
					Themeinfo["color_scheme",key]:=SubStr(%key%,5,2) SubStr(%key%,3,2) SubStr(%key%,1,2)
		if FileExist(A_ScriptDir "\Config\Skins\" backtheme ".json")
			backtheme:=backtheme "-New"
		Themeinfo["themeName"]:=backtheme
		Json_ObjToFile(Themeinfo, A_ScriptDir "\Config\Skins\" backtheme ".json", "UTF-8")
		if FileExist(A_ScriptDir "\Config\Skins\" backtheme ".json"){
			Traytip,,导出成功，文件路径为:`n%A_ScriptDir%Config\Skins\%backtheme%.json
			Gui, diy:Font, cRed Bold 
			GuiControl, diy:Font, tipColor
			GuiControl,diy:, tipColor ,配色导出成功！！
		}
		GuiControl,98:, select_theme , %backtheme%
	}else{
		Gui, diy:Font,s9 cRed Bold 
		GuiControl, diy:Font, tipColor
		GuiControl,diy:, tipColor ,文件名不能为空！
	}
Return

select_theme:
	GuiControlGet, select_theme,, select_theme, text
	Gosub _FileToObj
	Gosub IsGdipline
Return

_FileToObj:
	Colors_part:=Json_FileToObj("Config\Skins\" select_theme ".json")
	For Section, element In Colors_part
		For key, value In element
			If (WubiIni["TipStyle", key]<>""&&key<>""&&value<>"")
				%key%:=WubiIni["TipStyle", key]:=SubStr(value,5,2) SubStr(value,3,2) SubStr(value,1,2)
	ThemeName:=WubiIni.TipStyle["ThemeName"]:=Colors_part["ThemeName"]
	WubiIni.save()
	if !FileExist(A_ScriptDir "\Config\Skins\preview\" ThemeName ".png")
		GuiControl,98:, themelogo,Config\Skins\preview\Error.png
	else
		GuiControl,98:, themelogo,Config\Skins\preview\%ThemeName%.png
Return

sChoice3:
	GuiControlGet, sChoice3,, sChoice3, text
	if sChoice3~="横"
		Textdirection:=WubiIni.TipStyle["Textdirection"]:="horizontal" ,WubiIni.save()
	else
		Textdirection:=WubiIni.TipStyle["Textdirection"]:="vertical" ,WubiIni.save()
	WubiIni.save()
Return

sChoice4:
	Menu_CheckRadioItem(SMENU, A_ThisMenuItemPos)
	Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:=A_ThisMenuItemPos=1?"ci":A_ThisMenuItemPos=2?"zi":A_ThisMenuItemPos=3?"chaoji":A_ThisMenuItemPos=4?"zg":Wubi_Schema,WubiIni.save()
	Gosub ChangeTray
Return

ImportPinyin:
	If FileExist("Config\Script\ImportPinyin.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\ImportPinyin.ahk"
	}else
		MsgBox, 262160, 错误提示, ImportPinyin.ahk脚本不存在！, 10
Return

GetkeyCode:
	srf_mode:=0
	Gosub Srf_Tip
	If FileExist("Config\Script\GetkeyCode.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\GetkeyCode.ahk"
	}else
		MsgBox, 262160, 错误提示, GetkeyCode.ahk脚本不存在！, 10
Return

ExportPinyin:
	If FileExist("Config\Script\ExportPinyin.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\ExportPinyin.ahk"
	}else
		MsgBox, 262160, 错误提示, ExportPinyin.ahk脚本不存在！, 10
Return

ciku1:
	If FileExist("Config\Script\ImportCiku.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\ImportCiku.ahk"
	}else
		Gosub Write_DB
Return

ciku12:
	If FileExist("Config\Script\EtymologyTable.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\EtymologyTable.ahk"
	}else
		MsgBox, 262160, 错误, %A_ScriptDir%\Config\Script\EtymologyTable.ahk执行脚本不存在！, 10
Return

ciku14:
	If FileExist("Config\Script\ImportEtymology.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\ImportEtymology.ahk"
	}else
		MsgBox, 262160, 错误, %A_ScriptDir%\Config\Script\ImportEtymology.ahk执行脚本不存在！, 10
Return

ciku13:
	If FileExist("Config\Script\GetCikuFullcode.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\GetCikuFullcode.ahk"
	}else
		MsgBox, 262160, 错误, %A_ScriptDir%\Config\Script\GetCikuFullcode.ahk执行脚本不存在！, 10
Return

ciku2:
	Gosub OnBackup
Return

ciku3:
	bd:="En"
	Gosub Write_En
	bd:=""
Return

ciku4:
	bd:="En"
	Gosub Backup_En
	bd:=""
Return

ciku5:
	bd:="Sym"
	Gosub Write_En
	bd:=""
Return

ciku6:
	bd:="Sym"
	Gosub Backup_En
	bd:=""
Return

ciku7:
	custom_db:=1
	Gosub Backup_DB
	custom_db:=0
Return

ciku8:
	init_db:=1
	Gosub OnBackup
	init_db:=0
Return

ciku9:
	Gosub DB_management
Return

ciku10:
	Gui +OwnDialogs
	FileSelectFile, FileNamePath, 3,%A_Desktop%\ , 导入单字读音词库, Text Documents (*.txt)
	If (FileNamePath<>"") {
		MsgBox, 262452, 提示, 要导入以下词库进行替换？`n〔 单字+Tab+读音 〕
		IfMsgBox, No
		{
			TrayTip,, 导入已取消！
			Return
		} Else {
			Create_pinyin(DB)
			GetFileFormat(FileNamePath,pyAll,Encoding)
			If (Encoding="UTF-16BE BOM") {
				MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 10
				Return
			}
			If pyAll {
				If DB_WritePy(pyAll)>0
					Traytip,,导入完成！
				else
					Traytip,,导入失败！
			}
		}
	}else
		Traytip,,导入已取消！
Return

ciku11:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,*%A_Desktop%\,3,请选择导出后保存的位置
	if (OutFolder<>"")
	{
		If DB_BackUpPy(OutFolder)>0
			Traytip,,导出完成！
		else
			Traytip,,导出失败！
	}
Return

DB_WritePy(Strs){
	global DB
	Insert_ci:=""
	Loop, Parse, Strs, `n, `r
	{
		If (A_LoopField = "")
			Continue
		tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
		if tarr[3]
			Insert_ci .="('" A_Index "','" tarr[1] "','" tarr[2] "','" tarr[3] "')" ","
		else
			Insert_ci .="('" A_Index "','" tarr[1] "','" tarr[2] "','')" ","
	}
	Traytip,,写入中。。。
	If DB.Exec("INSERT INTO 'extend'.'PY' VALUES" RegExReplace(Insert_ci,"\,$","") "")>0
		Return 1
}

DB_BackUpPy(FolderPath){
	global DB
	Result_All:=""
	DB.gettable("Select * from 'extend'.'PY';",Result)
	Traytip,,正在执行导出。。。
	If Result.RowCount>0
	{
		Loop, % Result.RowCount
		{
			If Result.Rows[A_index,4]
				Result_All .= Result.Rows[A_index,2] A_tab Result.Rows[A_index,3] A_tab Result.Rows[A_index,4] "`n"
			else
				Result_All .= Result.Rows[A_index,2] A_tab Result.Rows[A_index,3] "`n"
		}
		Traytip,,正在生成文件。。。
		FileDelete %FolderPath%\pinyin.txt
		FileAppend,%Result_All%,%FolderPath%\pinyin.txt,UTF-8
		if Result_All
			Return 1
	}
	Result_All:=""
}

SBA0:
	Gui,98:Hide
	TransGui("将光标放在要选择的位置，然后按<左Ctrl键>获取坐标!`n如果不操作3s内自动获取鼠标光标当前坐标！", A_ScreenWidth/4 , A_ScreenHeight/2 , "s22","bold","cred")
	keywait, LControl, D T3
	keywait, LControl
	mousegetpos, XXX, YYY
	GuiControl,, xx, %XXX%
	GuiControl,, yy, %YYY%
	Fix_X:=WubiIni.TipStyle["Fix_X"]:=XXX
	Fix_Y:=WubiIni.TipStyle["Fix_Y"]:=YYY ,WubiIni.Save()
	Gui, Submit
	TransGui()
	Gui, 98:show,NA
Return

SBA1:
	GuiControlGet, SBA ,, SBA1, Checkbox
	if SBA {
		GuiControl, 98:Enable, s2thotkeys
	}else{
		GuiControl, 98:Disable, s2thotkeys
	}
	s2t_swtich:=WubiIni.Settings["s2t_swtich"]:=SBA,WubiIni.save(), HotkeyRegister()
Return

showtools:
	GuiControlGet, showtools ,, showtools, Checkbox
	srfTool:=WubiIni.Settings["srfTool"]:=showtools, WubiIni.save()
	Gosub ShowSrfTip
	For k,v In ["ExSty","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps"]
	{
		If showtools
			GuiControl, 98:Disable, %v%
		else
			GuiControl, 98:Enable, %v%
	}
Return

SBA2:
	GuiControlGet, SBA ,, SBA2, Checkbox
	if SBA {
		GuiControl, 98:Enable, cfhotkeys
	}else{
		GuiControl, 98:Disable, cfhotkeys
	}
	cf_swtich:=WubiIni.Settings["cf_swtich"]:=SBA,WubiIni.save(), HotkeyRegister()
Return

CheckFilter:
	If (A_GuiControl="SBA3"||CheckFilterControl="kmts") {
		CharFliter:=WubiIni.Settings["CharFliter"]:= Prompt_Word="on"?0:CharFliter
		, PromptChar:=WubiIni.Settings["PromptChar"]:=Prompt_Word="on"?0:PromptChar, CheckFilterControl:= ""
		If WinExist("输入法设置") {
			GuiControl,98:, SBA3, % Prompt_Word="on"?1:0
			If (Prompt_Word="on") {
				GuiControl,98:, SBA24, 0
				GuiControl,98:, SBA23, 0
			}
		}
	}else If (A_GuiControl="SBA23"||CheckFilterControl="gl") {
		PromptChar:=WubiIni.Settings["PromptChar"]:= CharFliter?0:PromptChar
		, Prompt_Word:=WubiIni.Settings["Prompt_Word"]:= CharFliter?"off":Prompt_Word, CheckFilterControl:=""
		If WinExist("输入法设置") {
			GuiControl,98:, SBA23, %CharFliter%
			If (CharFliter) {
				GuiControl,98:, SBA3, 0
				GuiControl,98:, SBA24, 0
			}
		}
	}else If (A_GuiControl="SBA24"||CheckFilterControl="zmts") {
		Prompt_Word:=WubiIni.Settings["Prompt_Word"]:= PromptChar?"off":Prompt_Word
		, CharFliter:=WubiIni.Settings["CharFliter"]:=PromptChar?0:CharFliter
		Trad_Mode :=WubiIni.Settings["Trad_Mode"] :=PromptChar?"off":Trad_Mode, CheckFilterControl:= ""
		If WinExist("输入法设置") {
			GuiControl,98:, SBA24, %PromptChar%
			If (PromptChar) {
				GuiControl,98:, SBA3, 0
				GuiControl,98:, SBA23, 0
			}
		}
	}else If (CheckFilterControl="trad") {
		Prompt_Word:=WubiIni.Settings["Prompt_Word"]:=Trad_Mode="on"?"off":Prompt_Word
		, PromptChar:=WubiIni.Settings["PromptChar"]:=Trad_Mode="on"?0:PromptChar, CheckFilterControl:=""
		If WinExist("输入法设置") {
			If (Trad_Mode="on") {
				GuiControl,98:, SBA3, 0
				GuiControl,98:, SBA24, 0
			}
		}
	}
	If (Wubi_Schema="ci"&&Prompt_Word="off"&&Trad_Mode="off") {
		For k,v In ["Frequency","FTip","set_Frequency","RestDB"]
			GuiControl, 98:Enable, %v%
		;;OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x0178d6})
	}else If (Wubi_Schema<>"ci"&&WinExist("输入法设置")||Prompt_Word="on"&&WinExist("输入法设置")||WinExist("输入法设置")&&Trad_Mode="on"){
		For k,v In ["Frequency","FTip","set_Frequency","RestDB"]
			GuiControl, 98:Disable, %v%
		;;OD_Colors.Attach(FRDL,{T: 0x767641, B: 0xb3b3b3})
	}
	WubiIni.save()
Return

SBA3:
	GuiControlGet, SBA ,, SBA3, Checkbox
	Prompt_Word:=WubiIni.Settings["Prompt_Word"]:=SBA?"on":"off", WubiIni.save()
	Gosub CheckFilter
Return

SBA4:
	GuiControlGet, SBA,, SBA4, text
	if SBA~="计划任务" {
		Gosub Startup
	}else if SBA~="快捷方式" {
		if FileExist(A_Startup "\五笔*版.lnk")
			FileDelete,%A_Startup%\五笔*版.lnk
		Gosub CreateShortcut_Startup
	}else{
		Command = schtasks /Delete /TN %Startup_Name% /F
		Run *RunAs cmd.exe /c %Command%, , Hide
		if FileExist(A_Startup "\五笔*版.lnk") {
			FileDelete,%A_Startup%\五笔*版.lnk
			Startup :=WubiIni.Settings["Startup"]:="off", WubiIni.save()
			Traytip,自启提示:,已取消开机自启!
		}else if not cmdClipReturn(cmd_zq)~=Startup_Name{
			Startup :=WubiIni.Settings["Startup"]:="off", WubiIni.save()
			Traytip,自启提示:,已取消开机自启!
		}
	}
Return

SBA5:
	GuiControlGet, SBA ,, SBA5, Checkbox
	Fix_Switch:=WubiIni.TipStyle["Fix_Switch"]:=SBA?"off":"on", WubiIni.save()
	GuiControl, 98:Disable%SBA%, SBA0
Return

SBA6:
	GuiControlGet, SBA ,, SBA6, Checkbox
	if (SBA==1) {
		symb_send:=WubiIni.Settings["symb_send"]:="on",WubiIni.save()
	}else{
		symb_send:=WubiIni.Settings["symb_send"]:="off",WubiIni.save()
	}
Return

SBA7:
	GuiControlGet, SBA ,, SBA7, Checkbox
	limit_code:=WubiIni.Settings["limit_code"]:=SBA?"on":"off",WubiIni.save()
Return

SBA26:
	GuiControlGet, SBA ,, SBA26, Checkbox
	length_code:=WubiIni.Settings["length_code"]:=SBA?"on":"off",WubiIni.save()
Return
	GuiControlGet, SBA ,, SBA26, Checkbox
	length_code:=WubiIni.Settings["length_code"]:=SBA?"on":"off",WubiIni.save()
SBA11:
	Gosub Trad_Mode
Return

format_Date:
	Gosub DestroyGui
	Gui, Date:Destroy
	Gui, Date:Default
	Gui, Date: +Owner98 hWndFormatDate -MinimizeBox
	Gui, Date: Margin,10,10
	Gui, Date: Color,ffffff
	Gui, Date:Font, s9 , %Font_%
	Gui, Date:Add, Button, xm-4 gUpLine vUpLine hWndUPBT, 上`n移
	GuiControl, Date:Disable,UpLine
	Gui, Date:Add, Button, gDnLine vDnLine hWndDnBT, 下`n移
	Gui, Date:Add, Button, gDelLine vDelLine hWndDELBT, 清`n空
	ImageButton.Create(UPBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	ImageButton.Create(DnBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	ImageButton.Create(DELBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	Gui, Date:Font, s9 , %Font_%
	Gui, Date:Add, ListView,x+6 ym r10 w530 Grid AltSubmit NoSortHdr NoSort -Readonly -Multi 0x8 LV0x40 -LV0x10 gSetsj vSetsj hwndSJLV, 关键字|效果预览|编码 
	SysGet, CXVSCROLL, 2
	For Section,element In JsonData_Date
	{
		If objCount(element)
			For key,value In element
				LV_Add(A_Index=1?"select":"",value,value~="^[dghHmMsy]"?FormatTime("",value):FormatTime(value,FormatTime(formatDate(value),FormatDate(value,2,1))),Section)
	}
	LV_ModifyCol(1,150), LV_ModifyCol(2,300), LV_ModifyCol(3,80-CXVSCROLL " Center")
	SJLVLIST := New LV_InCellEdit(SJLV)
	SJLVLIST.SetColumns(1, 3)
	ICELV2.OnMessage()
	Gui, Date:Font, s9 norm, %Font_%
	Gui, Date:Add, Edit, R1 w60 vSettKey -Wrap -WantReturn Lowercase -WantTab hWndSetKey
	Gui, Date:Add, Edit,x+8 R1 w320 vSettime -Wrap -WantTab hWndSettime
	Gui, Date:Add, Button,x+5 gSaveSJ vSaveSJ hWndSSBT, 添加
	Gui, Date:Add, Button,x+5 gReloadSJ vReloadSJ hWndRSBT, 刷新
	Gui, Date:Add, Picture,x+5 yp+2 w18 h-1 BackgroundTrans Icon155 vhelpico ghelpico, shell32.dll
	Gui, Date:Add, CheckBox,x+15 yp+2 vGzType gGzType Checked%GzType%,
	EM_SetCueBanner(SetKey, "编码")
	EM_SetCueBanner(Settime, "示例格式：公元年(ln)月日-周 周数 ")
	ImageButton.Create(SSBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	ImageButton.Create(RSBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, Date:Add,StatusBar,, ❖ 输出以/+编码、双击更改列值、编码或关键字任意一列置空则执行删除操作！
	Gui, Date:Show,AutoSize,时间格式输出设定
	Gosub ChangeWinIcon
	ControlFocus , Edit1, A
Return

DateGuiClose:
DateGuiEscape:
	Gui, Date:Destroy
	Gui, Info:Destroy
Return

SBA27:
	Gosub format_Date
Return

GzType:
	GuiControlGet, GzType_ ,, GzType, Checkbox
	GzType:=WubiIni.Settings["GzType"]:=GzType_, WubiIni.save()
Return

UpLine:
	RowNum := 0, SelectLine:=0, Text:=Text_1:=Text_1_3:=Text1_3:=""
	Loop % LV_GetCount()+1
	{
		RowNum := LV_GetNext(RowNum)
		if not RowNum
			break
		LV_GetText(Text, RowNum),LV_GetText(Text1_3, RowNum,3), LV_GetText(Text_1, RowNum-1), LV_GetText(Text_1_3, RowNum-1,3), SelectLine:=RowNum
	}
	If (Text1_3=Text_1_3) {
		If (SelectLine>1) {
			GuiControl, date:Enable,UpLine
			If (SelectLine=LV_GetCount())
				GuiControl, date:Disable,DnLine
			else
				GuiControl, date:Enable,DnLine
			If (SelectLine<3)
				GuiControl, date:Disable,UpLine
			else
				GuiControl, date:Enable,UpLine
			LV_Modify(SelectLine-1 , "Select Focus", Text, Text~="^[dghHmMsy]"?FormatTime("",Text):FormatTime(Text,FormatTime(formatDate(Text),FormatDate(Text,2,1))),Text1_3)
			LV_Modify(SelectLine , "", Text_1, Text_1~="^[dghHmMsy]"?FormatTime("",Text_1):FormatTime(Text_1,FormatTime(formatDate(Text_1),FormatDate(Text_1,2,1))),Text_1_3)
			JsonData_Date[Text1_3,Index:=GetArrIndex(JsonData_Date[Text1_3],Text)] :=Text_1, JsonData_Date[Text1_3,Index-1] :=Text
			Json_ObjToFile(JsonData_Date, A_ScriptDir "\Sync\JsonData_Date.json", "UTF-8")
		}else{
			GuiControl, date:Disable,UpLine
			GuiControl, date:Enable,DnLine
		}
	}
Return

DnLine:
	RowNum := 0, SelectLine:=0, Text:=Text_1:=Text_1_3:=Text1_3:=""
	Loop % LV_GetCount()+1
	{
		RowNum := LV_GetNext(RowNum)
		if not RowNum
			break
		LV_GetText(Text, RowNum),LV_GetText(Text1_3, RowNum,3), LV_GetText(Text_1, RowNum+1),LV_GetText(Text_1_3, RowNum+1,3), SelectLine:=RowNum
	}
	If (Text1_3=Text_1_3) {
		If (SelectLine<LV_GetCount()) {
			If (SelectLine=LV_GetCount()-1)
				GuiControl, date:Disable,DnLine
			else
				GuiControl, date:Enable,DnLine
			if SelectLine>1
				GuiControl, date:Enable,UpLine
			LV_Modify(SelectLine+1 , "Select Focus", Text, Text~="^[dghHmMsy]"?FormatTime("",Text):FormatTime(Text,FormatTime(formatDate(Text),FormatDate(Text,2,1))),Text1_3)
			LV_Modify(SelectLine , "", Text_1, Text_1~="^[dghHmMsy]"?FormatTime("",Text_1):FormatTime(Text_1,FormatTime(formatDate(Text_1),FormatDate(Text_1,2,1))),Text_1_3)
			JsonData_Date[Text1_3,Index:=GetArrIndex(JsonData_Date[Text1_3],Text)] :=Text_1, JsonData_Date[Text1_3,Index+1] :=Text
			Json_ObjToFile(JsonData_Date, A_ScriptDir "\Sync\JsonData_Date.json", "UTF-8")
		}else{
			GuiControl, date:Enable,UpLine
			GuiControl, date:Disable,DnLine
		}
	}
Return

DelLine:
	JsonData_Date:={}, Json_ObjToFile(JsonData_Date, A_ScriptDir "\Sync\JsonData_Date.json", "UTF-8")
	Gosub ReloadSJ
Return

FormatInfo:
	Gui, Info:Destroy
	Gui, Info:Default
	Gui, Info: +Owner98 -MinimizeBox
	Gui, Info: Margin,10,10
	Gui, Info: Color,ffffff
	Gui, Info:Font, s10 bold, %Font_%
	Gui Info:Add, GroupBox,xm w450 h300, 格式设置说明：
	Gui, Info:Font, s9 bold, %Font_%
	Gui Info:Add, text,xm+10 yp+30 cred,中文格式：（分割符自行定义、输出以/+编码、双击修改）
	Gui, Info:Font, s8 norm, %Font_%
	Gui Info:Add, text,y+5,年、月、日、时/点/全时/全点、分、秒、星期/周、周数、公元、ln(农历年)、ly(农历月)`n、lr(农历日)、ls(农历时辰)、节气、干支、中文格式(中文格式日期)`n，关键字以``键转义可以不当作参数使用。
	Gui, Info:Font, s9 bold, %Font_%
	Gui Info:Add, text,xm+10 y+5 cred,英文格式：（分割符自行定义、输出以/+编码、双击修改）
	Gui, Info:Font, s8 norm, %Font_%
	Gui Info:Add, text,y+5,年：【yyyy 含世纪的年份】【yy 不含世纪的年份, 含前导零】【gg 公元纪年】`n       【y 不含世纪的年份, 不含前导零】`n月：【MMMM 当前语言月份全称】【MMM 当前语言月份简称】【MM 含前导零】`n       【M 不含前导零】`n日：【dddd 当前语言星期全称】【ddd 当前语言星期简称】【dd 含前导零】`n       【d 不含前导零】`n时：【hh 含前导零12小时制】【h 不含前导零12小时制】【HH 含前导零24小时制】`n       【H 不含前导零24小时制】`n分：【mm 含前导零】【m 不含前导零】`n秒：【ss 含前导零】【s 不含前导零】
	InfoWidth:=A_ScreenWidth/2-600
	Gui, Info:Show,x%InfoWidth%,格式定义说明
	Gosub ChangeWinIcon
Return

helpico:
	if (A_GuiEvent="Normal")
		Gosub FormatInfo
Return

GetArrIndex(Arr,Chars){
	If (!objCount(Arr)||Chars="")
		Return 0
	For key,value In Arr
	{
		If (value=Chars)
			Return key
	}
	Return 0
}

Setsj:
	If (A_GuiEvent == "F") {
		If (SJLVLIST["Changed"]) {
			For k, v In SJLVLIST.Changed    ;;v.Row   v.Col    v.Txt
			{
				If (v.Col=3&&objCount(JsonData_Date[v.Txt])&&v.Txt<>""){
					If !GetArrIndex(JsonData_Date[v.Txt],formatText1)
						JsonData_Date[v.Txt].Push(formatText1)
					If (Index:=GetArrIndex(JsonData_Date[formatText3],formatText1)) {
						If (objCount(JsonData_Date[formatText3])=1)
							JsonData_Date.Delete(formatText3)
						else
							JsonData_Date[formatText3].RemoveAt(Index)
					}
				}else If (v.Col=1&&objCount(JsonData_Date[formatText3])&&v.Txt<>"") {
					If (Index:=GetArrIndex(JsonData_Date[formatText3],formatText1))
						JsonData_Date[formatText3,Index]:=v.Txt
					LV_Modify(v.Row,"text",v.Txt,v.Txt~="^[dghHmMsy]"?FormatTime("",v.Txt):FormatTime(v.Txt,FormatTime(formatDate(v.Txt),FormatDate(v.Txt,2,1))),formatText3)
				}else If (v.Col=3&&!objCount(JsonData_Date[v.Txt])&&v.Txt<>"") {
					JsonData_Date[v.Txt]:=[formatText1]
					If (Index:=GetArrIndex(JsonData_Date[formatText3],formatText1)) {
						If (objCount(JsonData_Date[formatText3])=1)
							JsonData_Date.Delete(formatText3)
						else
							JsonData_Date[formatText3].RemoveAt(Index)
					}
				}else If (v.Txt="") {
					If (Index:=GetArrIndex(JsonData_Date[formatText3],formatText1)) {
						If (objCount(JsonData_Date[formatText3])=1)
							JsonData_Date.Delete(formatText3)
						else
							JsonData_Date[formatText3].RemoveAt(Index)
					}
					LV_Delete(v.Row)
				}
			}
			SJLVLIST.Remove("Changed")
			Json_ObjToFile(JsonData_Date, A_ScriptDir "\Sync\JsonData_Date.json", "UTF-8")
		}
	}else if (A_GuiEvent = "Normal"&&A_EventInfo) {
		If (A_EventInfo=1)
			GuiControl, Date:Disable,UpLine
		else
			GuiControl, Date:Enable,UpLine
		If (A_EventInfo=LV_GetCount())
			GuiControl, Date:Disable,DnLine
		else
			GuiControl, Date:Enable,DnLine
	}else if (A_GuiEvent = "DoubleClick"&&A_EventInfo) {
		LV_GetText(formatText1,A_EventInfo,1), LV_GetText(formatText3,A_EventInfo,3)
	}
Return

ReloadSJ:
	LV_Delete()
	For Section,element In JsonData_Date
	{
		If objCount(element)
			For key,value In element
				LV_Add(A_Index=1?"select":"",value,value~="^[dghHmMsy]"?FormatTime("",value):FormatTime(value,FormatTime(formatDate(value),FormatDate(value,2,1))),Section)
	}
	ControlFocus , Edit1, A
Return

SaveSJ:
	GuiControlGet, Settime,, Settime, text
	GuiControlGet, Keys,, SettKey, text
	Keys:=RegExReplace(Keys,"\t|\s|\n")
	If (Settime&&Keys~="[a-z]") {
		If (!GetArrIndex(JsonData_Date[Keys],Settime)) {
			FTime:= Settime~="^[dghHmMsy]"?FormatTime("",Settime):FormatTime(formatDate(Settime),FormatDate(Settime,2,1))
			LV_Add("",Settime,FTime,Keys)
			If objCount(JsonData_Date[Keys])
				JsonData_Date[Keys].Push(Settime)
			else
				JsonData_Date[Keys]:=[Settime]
			;;PrintObjects(JsonData_Date)
			GuiControl,date:,SettKey,
			GuiControl,date:,Settime,
			ControlFocus , Edit1, A
			Json_ObjToFile(JsonData_Date, A_ScriptDir "\Sync\JsonData_Date.json", "UTF-8")
		}else
			MsgBox, 262160, 错误提示, 参数已存在！
	}else If (Settime&&not Keys~="[a-z]")
		MsgBox, 262160, 错误提示, 编码格式不支持！
	else If (!Settime&&Keys~="[a-z]")
		MsgBox, 262160, 错误提示, 时间格式关键字不能为空！
	else If (!Settime&&not Keys~="[a-z]")
		MsgBox, 262160, 错误提示, 不符合添加条件！
	ControlFocus , Edit1, A
Return

SBA9:
	GuiControlGet, SBA ,, SBA9, Checkbox
	if (SBA==1) {
		Radius:=WubiIni.TipStyle["Radius"]:="on",WubiIni.save()
		For k,v In ["set_GdipRadius","GdipRadius","set_FocusRadius","set_FocusRadius_value"]
			GuiControl, 98:Enable, %v%
	}else{
		Radius:=WubiIni.TipStyle["Radius"]:="off",WubiIni.save()
		For k,v In ["set_GdipRadius","GdipRadius","set_FocusRadius","set_FocusRadius_value"]
			GuiControl, 98:Disable, %v%
	}
Return

IsGdipline:
	ThemeObject:=GetThemeColor(ThemeName)
	If (Gdip_Line="on"&&FocusStyle||!FocusStyle) {
		FontCodeColor:=FontCodeColor=BgColor?ThemeObject["FontColor"]:FontCodeColor
	}else If (Gdip_Line="off"&&FocusStyle) {
		FontCodeColor:=ThemeObject["FontCodeColor"]
	}
Return

SBA10:
	GuiControlGet, SBA ,, SBA10, Checkbox
	if (SBA==1) {
		Gdip_Line:=WubiIni.TipStyle["Gdip_Line"]:="on",WubiIni.save()
	}else{
		Gdip_Line:=WubiIni.TipStyle["Gdip_Line"]:="off",WubiIni.save()
	}
	Gosub IsGdipline
Return

SBA12:
	GuiControlGet, SBA ,, SBA12, Checkbox
	if (SBA==1) {
		FontStyle:=WubiIni.TipStyle["FontStyle"]:="on",WubiIni.save()
	}else{
		FontStyle:=WubiIni.TipStyle["FontStyle"]:="off",WubiIni.save()
	}
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
Return

SBA13:
	Gosub Logo_Switch
	if Logo_Switch~="off" {
		For k,v In ["ExSty","SrfSlider","select_logo","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps", "showtools","DPISty"]
			GuiControl, 98:Disable, %v%
		;;OD_Colors.Attach(SLCT,{T: 0x767641, B: 0xb3b3b3})
	}else{
		For k,v In ["ExSty","SrfSlider","select_logo","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps", "showtools","DPISty"]
		{
			If (srfTool&&not v~="select_logo|showtools") {
				GuiControl, 98:Disable, %v%
			}else
				GuiControl, 98:Enable, %v%
		}
		;;OD_Colors.Attach(SLCT,{T: 0xffe89e, B: 0x0178d6})
	}
Return

SBA14:
	GuiControlGet, SBA ,, SBA14, Checkbox
	if (SBA) {
		global symb_mode:=WubiIni.Settings["symb_mode"]:=1
		GuiControl,logo:, Pics3,*Icon7 config\Skins\logoStyle\%StyleN%.icl
	}else{
		global symb_mode:=WubiIni.Settings["symb_mode"]:=2
		GuiControl,logo:, Pics3,*Icon8 config\Skins\logoStyle\%StyleN%.icl
	}
	WubiIni.save()
Return

SBA15:
	GuiControlGet, SBA ,, SBA15, Checkbox
	if (SBA) {
		GuiControl, 98:Enable, tiphotkey
	}else{
		GuiControl, 98:Disable, tiphotkey
	}
		rlk_switch:=WubiIni.Settings["rlk_switch"]:=SBA,WubiIni.save(), HotkeyRegister()
Return

SBA16:
	GuiControlGet, SBA ,, SBA16, Checkbox
	if (SBA) {
		GuiControl, 98:Enable, Suspendhotkey
	}else{
		GuiControl, 98:Disable, Suspendhotkey
	}
	Suspend_switch:=WubiIni.Settings["Suspend_switch"]:=SBA,WubiIni.save(), HotkeyRegister()
Return

SBA18:
	Gosub DestroyGui
	Gui,SKey:+Owner98 hwndSkeyShow -MinimizeBox
	Gui,SKey:Add,Edit,w250 vEditBox3 hwndSkeyEdit,
	Gui,SKey:Add,Button,x+10 gsetStrockekey,保存
	Gui,SKey:Margin,5,5
	Gui,SKey:Add,StatusBar,,❖ 键位0-9a-z用|分隔五位
	Gui,SKey:Show,AutoSize,笔画反查键位设置
	EM_SetCueBanner(SkeyEdit,"当前键位：" StrockeKey)
	ChangeWindowIcon(A_ScriptDir "\Config\WubiIME.icl",, 30)
Return

setStrockekey:
	GuiControlGet, Skeyvar,, EditBox3, text
	If (Skeyvar~="^(\w\|){4}\w$"&&Skeyvar~="[a-z]"&&Skeyvar~="[^0-9]"||Skeyvar~="^(\w\|){4}\w$"&&Skeyvar~="[^a-z]"&&Skeyvar~="[0-9]"){
		Skeyvar:=RegExReplace(Skeyvar,"^\||\|$"),Skeyvar:=RegExReplace(Skeyvar,"[\|]{2,}","|")
		StrockeKey:=WubiIni.Settings["StrockeKey"]:=Skeyvar,WubiIni.save()
		GuiControl,SKey:,EditBox3,
		EM_SetCueBanner(SkeyEdit,"当前键位：" Skeyvar)
	}else{
		MsgBox, 262160, 格式错误, 参数格式错误！`n例如：1|2|3|4|5或h|s|p|n|z, 5
		ControlFocus , Edit1, ahk_id %SkeyShow%
	}
Return

SBA17:
	GuiControlGet, SBA ,, SBA17, Checkbox
	if (SBA) {
		GuiControl, 98:Enable, Addcodehotkey
	}else{
		GuiControl, 98:Disable, Addcodehotkey
	}
	Addcode_switch:=WubiIni.Settings["Addcode_switch"]:=SBA,WubiIni.save(), HotkeyRegister()
Return

SBA19:
	GuiControlGet, SBA ,, SBA19, Checkbox
	FocusStyle:=WubiIni.Settings["FocusStyle"]:=SBA,WubiIni.save()
	Gosub IsGdipline
Return

SBA20:
	GuiControlGet, SBA ,, SBA20, Checkbox
	if SBA
		PageShow:=WubiIni.Settings["PageShow"]:=1,WubiIni.save()
	else
		PageShow:=WubiIni.Settings["PageShow"]:=0,WubiIni.save()
Return

Sym_Gui:
	Gosub DestroyGui
	Gui, Sym:Destroy
	Gui, Sym:Default
	Gui, Sym: +Owner98 -MinimizeBox
	Gui, Sym:Font, s10 bold, %Font_%
	Gui, Sym:Add,Button,gInsert_sym hWndISBT,刷新
	ImageButton.Create(ISBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, Sym:Add,Button,x+10 yp gShowSymList vShowSymList hWndSSLBT,符号列表
	ImageButton.Create(SSLBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui, Sym:Font, s10 underline, %Font_%
	Gui, Sym:Add, CheckBox,x+10 yp+5 h20 vHL gHiddenCol1ListView, 更改
	Gui, Sym:Font, s10 norm, %Font_%
	Gui, Sym:Add, ListView, xm y+10 w320 Grid NoSortHdr NoSort -WantF2 r15 gSubLV2 hwndHLV2 AltSubmit vLV2, 基础|英文标点|中文标点
	Gosub Insert_sym
	LV_ModifyCol(1, "60 Center"), LV_ModifyCol(2, "120 Center"), LV_ModifyCol(3, "120 Center")
	ICELV2 := New LV_InCellEdit(HLV2, True, True)
	ICELV2.SetColumns(2, 3)
	ICELV2.OnMessage(False)
	Gui, Sym:Margin, 10, 10
	Gui, Sym:Color,ffffff
	Gui, Sym:Add, StatusBar,, ❖
	SB_SetText(" ❖ 共计"LV_GetCount() . "组标点")
	Gui, Sym:Show, , 标点符号映射 
	Gosub ChangeWinIcon
Return

Insert_sym:
	LV_Delete()
	For Section, element In srf_symblos
	{
		LV_Add(“”,Section,element[1],element[2])
	}
	SB_SetText(" ❖ 共计"LV_GetCount() . "组标点")
Return

HiddenCol1ListView:
	GuiControlGet, HL,, HL, Checkbox
	If (HL) {
		GuiControl, -Readonly, LV2
		ICELV2.OnMessage()
	}Else{
		GuiControl, +Readonly, LV2
		ICELV2.OnMessage(False)
	}
Return

SubLV2:
	If A_EventInfo
		LV_GetText(keys,A_EventInfo)
	If (A_GuiEvent == "K") && (Chr(A_EventInfo) = "e") {
		Gui, Sym:ListView, %A_GuiControl%
		If (Row := LV_GetNext(0, "Focused")) {
			ICELV2.EditCell(Row)
		}
	}else If (A_GuiEvent == "F") {
		If (ICELV2["Changed"]) {
			RowN:=ICELV2["Changed"][1,"Row"], ColN:=ICELV2["Changed"][1,"Col"]
			GetValue:=ICELV2["Changed"][1,"Txt"]
			srf_symblos[keys,ColN-1]:=GetValue?GetValue:Default_symblos[keys,ColN-1]
			ICELV2.Remove("Changed")
			Json_ObjToFile(srf_symblos, "Sync\srf_symblos.json")
		}
	}else if (A_GuiEvent="DoubleClick"&&A_EventInfo)
		LV_GetText(keys,A_EventInfo)
Return

ShowSymList:
	Gui, SymList:Destroy
	Gui, SymList:Default
	Gui, SymList: +OwnerSym -MinimizeBox     ;; -DPIScale
	Gui, SymList:Font, s10, %Font_%
	counts_:=0
	Gui, SymList:Add, ListView, xm y+10 Grid NoSortHdr NoSort -WantF2 R15 gSubLV1 hwndHLV1 AltSubmit vLV1, 名称|标点|名称|标点|名称|标点|名称|标点
	For setion,element In SymObiect
	{
		for key,value In element
		{
			counts_++
			If (counts_>30&&counts_<61)
				LV_Modify(counts_-30 , "", , ,value[1],value[2])
			else If (counts_>60&&counts_<91)
				LV_Modify(counts_-60 , "", , , , ,value[1],value[2])
			else If (counts_>90)
				LV_Modify(counts_-90 , "", , , , , , ,value[1],value[2])
			else
				LV_Add("",value[1],value[2])
		}
	}
	Loop 8
		LV_ModifyCol(A_Index, Mod(A_Index, 2)?"AutoHdr Left":"AutoHdr Center")
	Gui +LastFound
	TotalWidth:=0
	Loop % LV_GetCount("Column")
	{
		SendMessage, 4125, A_Index - 1, 0, SysListView321  ; 4125 为 LVM_GETCOLUMNWIDTH.
		TotalWidth:=TotalWidth+ErrorLevel
	}
	SysGet, CXVSCROLL, 2
	GuiControl,SymList:Move,LV1,% "w" TotalWidth/(A_ScreenDPI/96)+CXVSCROLL
	Gui, SymList:Color,ffffff
	Gui, SymList:Add, StatusBar,, ❖
	SB_SetText(" ❖ 双击复制到剪切板")
	Gui, SymList:show,AutoSize,标点符号选取列表
	Gosub ChangeWinIcon
Return

SubLV1:
	If (A_GuiEvent = "DoubleClick"&&A_EventInfo) {
		Column := LV_SubItemHitTest(HLV1)
		If (!Mod(Column, 2)&&Column) {
			LV_GetText(ColVar, A_EventInfo , Column), Clipboard:=ColVar
			ToolTip, 已复制到剪切板！
			Sleep 400
			Gosub SymListGuiClose
		}
	}
Return

KillToolTip:
	ToolTip
Return

SymListGuiClose:
SymListGuiEscape:
	Gui, SymList:Destroy
Return

SBA21:
	Gosub Sym_Gui
Return

SBA22:
	GuiControlGet, SBA ,, SBA22, Checkbox
	if (SBA==1) {
		GuiControl, 98:Enable, Exithotkey
	}else{
		GuiControl, 98:Disable, Exithotkey
	}
	Exit_switch:=WubiIni.Settings["Exit_switch"]:=SBA,WubiIni.save(), HotkeyRegister()
Return

SBA23:
	GuiControlGet, SBA ,, SBA23, Checkbox
	CharFliter:=WubiIni.Settings["CharFliter"]:=SBA, WubiIni.save()
	Gosub CheckFilter
Return

CodingTips:
	PromptChar:=WubiIni.Settings["PromptChar"]:=!PromptChar,CheckFilterControl:="zmts", WubiIni.save()
	Gosub CheckFilter
Return

SBA24:
	GuiControlGet, SBA ,, SBA24, Checkbox
	PromptChar:=WubiIni.Settings["PromptChar"]:=SBA, WubiIni.save()
	Gosub CheckFilter
Return

SBA25:
	GuiControlGet, SBA ,, SBA25, Checkbox
	EN_Mode:=WubiIni.Settings["EN_Mode"]:=SBA, WubiIni.save()
Return

SBA28:
	GuiControlGet, SBA ,, SBA28, Checkbox
	EnKeyboardMode:=WubiIni.Settings["EnKeyboardMode"]:=SBA,WubiIni.save()
	If SBA
		SwitchToEngIME()
	else
		SwitchToChsIME()
Return

CharFliter:
	if Wubi_Schema~="i)zi|ci"
		CharFliter:=WubiIni.Settings["CharFliter"]:=!CharFliter, CheckFilterControl:="gl", WubiIni.save()
	else{
		CharFliter:=WubiIni.Settings["CharFliter"]:=0,WubiIni.save()
		Traytip,  警告提示:,当前方案无效，请切换至「单字/含词」方案！,,2
	}
	Gosub CheckFilter
Return

s2thotkeys:
	if s2thotkeys {
		Hotkey, %s2t_hotkey%, Trad_Mode,off
		s2thotkey:=WubiIni.Settings["s2t_hotkey"]:=s2thotkeys?s2thotkeys:"^+f", WubiIni.save(), HotkeyRegister()
	}
Return

cfhotkeys:
	if cfhotkeys {
		Hotkey, %cf_hotkey%, Cut_Mode,off
		cfhotkey:=WubiIni.Settings["cf_hotkey"]:=cfhotkeys?cfhotkeys:"^+h", WubiIni.save(), HotkeyRegister()
	}
Return

Suspendhotkey:
	if Suspendhotkey {
		Hotkey, %Suspend_hotkey%, SetSuspend,off
		Suspendhotkey:=WubiIni.Settings["Suspend_hotkey"]:=Suspendhotkey?Suspendhotkey:"!z", WubiIni.save(), HotkeyRegister()
	}
Return

tiphotkey:
	if tiphotkey {
		Hotkey, %tip_hotkey%, SetRlk,off
		tiphotkey:=WubiIni.Settings["tip_hotkey"]:=tiphotkey?tiphotkey:"!q", WubiIni.save(), HotkeyRegister()
	}
Return

Addcodehotkey:
	if Addcodehotkey {
		Hotkey, %AddCode_hotkey%, Batch_AddCode,off
		AddCodehotkey:=WubiIni.Settings["Addcode_hotkey"]:=Addcodehotkey?Addcodehotkey:"^CapsLock", WubiIni.save(), HotkeyRegister()
	}
Return

Exithotkey:
	if Exithotkey {
		Hotkey, %Exit_hotkey%, OnExit,off
		exithotkey:=WubiIni.Settings["Exit_hotkey"]:=Exithotkey?Exithotkey:"^Esc", WubiIni.save(), HotkeyRegister()
	}
Return

ChangeTooltipstyle:
	Menu_CheckRadioItem(HMENU, A_ThisMenuItemPos)
	ToolTipStyle:=WubiIni.TipStyle["ToolTipStyle"] :=A_ThisMenuItemPos=3?"Gdip":A_ThisMenuItemPos=2?"off":A_ThisMenuItemPos=1?"on":ToolTipStyle, WubiIni.Save()
	Gosub Switchhxk
	Gosub SelectItems
Return

;gdip边框线开关（边框线开则中间的分割线消除，反之）
Gdip_Line:
	Gdip_Line :=(Gdip_Line~="off"?"on":"off")
	WubiIni.TipStyle["Gdip_Line"] :=Gdip_Line
	WubiIni.save()
Return

;中文状态下使用英文符号
En_Sym:
	symb_mode:=WubiIni.Settings["symb_mode"] :=symb_mode~=1?2:1
	if (symb_mode=1)
		GuiControl,logo:, Pics3,*Icon7 config\Skins\logoStyle\%StyleN%.icl
	else
		GuiControl,logo:, Pics3,*Icon8 config\Skins\logoStyle\%StyleN%.icl
	WubiIni.save()
Return

;剪切板通道
Initial_Mode:
	Initial_Mode :=(Initial_Mode~="i)off"?"on":"off")
	if Initial_Mode~="i)off" {
		GuiControl,logo:, Pics4,*Icon9 config\Skins\logoStyle\%StyleN%.icl
	}else{
		GuiControl,logo:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
	}
	WubiIni.Settings["Initial_Mode"] :=Initial_Mode
	WubiIni.save()
Return

SetCustomColors:
	CustomColors :=[]
	loop,parse,Color_Row1,`,
	{
		StrLen(A_LoopField)=8?(A_LoopField:=A_LoopField):(A_LoopField :=RegExReplace(A_LoopField,"0x","0x0"))
		CustomColors[A_index] := SubStr(A_LoopField,1,2) SubStr(A_LoopField,7,2) SubStr(A_LoopField,5,2) SubStr(A_LoopField,3,2)
	}
	loop,parse,Color_Row2,`,
	{
		StrLen(A_LoopField)=8?(A_LoopField:=A_LoopField):(A_LoopField :=RegExReplace(A_LoopField,"0x","0x0"))
		CustomColors[A_index+8] := SubStr(A_LoopField,1,2) SubStr(A_LoopField,7,2) SubStr(A_LoopField,5,2) SubStr(A_LoopField,3,2)
	}
	if (CustomColors.Length()<>16){   ;色值区域超规默认值设置
		CustomColors :=[0x99731C,0xECEEEE,0x8B4E01,0x444444,0xE89F00,0xFAF9DE,0x2DB6F8,0xFFC90,0xD77800,0x0A1B0D,0x97D4B9,0xEFAD00,0xBF7817,0xE3F6FD,0x362B00,0xDEDEDE]
		WubiIni.CustomColors["Color_Row1"]:= "0x1C7399,0xEEEEEC,0x014E8B,0x444444,0x009FE8,0xDEF9FA,0xF8B62D,0x90FC0F"
		WubiIni.CustomColors["Color_Row2"]:= "0x0078D7,0x0D1B0A,0xB9D497,0x00ADEF,0x1778BF,0xFDF6E3,0x002B36,0xDEDEDE"
	}
Return

;选色面板结果处理
setcolor:
	Gosub SetCustomColors
	If Dlg_Color(tempColor, DIYTheme, CustomColors*){
		WubiIni.TipStyle[A_GuiControl]:=%A_GuiControl%:=SubStr(tempColor, 3)
		CreateImageButton(hwnd%A_GuiControl%,[{BC: %A_GuiControl%, 3D: 0}],5)
	}
	GuiControl,98:, themelogo,Config\Skins\preview\Error.png
	WubiIni.TipStyle["ThemeName"]:="自定义..."
	GuiControl, 98:Choose, select_theme, 0
	WubiIni.Save()
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
Return

setlogocolor:
	Gosub SetCustomColors
	If Dlg_Color(tempColor, hwndgui98, CustomColors*){
		%A_GuiControl%:=WubiIni.LogoColor[A_GuiControl]:=SubStr(SubStr(tempColor, 3),5,2) SubStr(SubStr(tempColor, 3),3,2) SubStr(SubStr(tempColor, 3),1,2), WubiIni.Save()
		CreateImageButton(hwnd%A_GuiControl%,[{BC: SubStr(tempColor, 3), 3D: 0}],5)
	}
	Gosub ChangeLogoColor2
Return

;设置页面字号输入结果处理
font_value:
	GuiControlGet, font_value,, font_value, text
	FontSize :=WubiIni.TipStyle["FontSize"]:= font_value>40?40:font_value, WubiIni.Save()
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
Return

;设置页面字号选择结果处理
font_size:
	global FontSize :=WubiIni.TipStyle["FontSize"]:= font_size
	WubiIni.Save()
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
Return

FontSelect:
	GuiControlGet, FontSelect,, FontSelect, text
	EnFontName :=WubiIni.TipStyle["EnFontName"]:= FontSelect
	WubiIni.Save()
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
Return

;设置页面字体选择结果处理
fonts_type:
	GuiControlGet, fonts_type_add,, FontType, text
	FontType :=WubiIni.TipStyle["FontType"]:= fonts_type_add
	GuiControl, 98:ChooseString, FontType, %FontType%
	if FontType ~="i)" FontExtend
		GuiControl, 98:Enable, SBA2
	else
		GuiControl, 98:Disable, SBA2
	if not FontType ~="i)" FontExtend
		WubiIni.Settings["Cut_Mode"] :="off"
	WubiIni.Save()
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
Return

;设置页面候选数量输入结果处理
select_value:
	GuiControlGet, select_value,, select_value, text
	ListNum := WubiIni.TipStyle["ListNum"]:= select_value>10?10:select_value, WubiIni.Save()
Return

;设置页面候选数量选择结果处理
set_select_value:
	ListNum := WubiIni.TipStyle["ListNum"]:= set_select_value, WubiIni.Save()
Return

set_FocusRadius:
	GuiControlGet, set_FocusRadius,, set_FocusRadius, text
	FocusRadius:=WubiIni.TipStyle["FocusRadius"]:=set_FocusRadius>18?18:set_FocusRadius, WubiIni.Save()
Return

set_FocusRadius_value:
	FocusRadius:=WubiIni.TipStyle["FocusRadius"]:=set_FocusRadius_value, WubiIni.Save()
Return

GdipRadius:
	GuiControlGet, GdipRadius,, GdipRadius, text
	Gdip_Radius := WubiIni.TipStyle["Gdip_Radius"]:= GdipRadius>15?15:GdipRadius, WubiIni.Save()
Return

set_GdipRadius:
	Gdip_Radius := WubiIni.TipStyle["Gdip_Radius"]:= set_GdipRadius, WubiIni.Save()
Return

;ToolTip偏移距离选择结果处理
set_regulate:
	Set_Range :=WubiIni.TipStyle["Set_Range"]:= set_regulate, WubiIni.Save()
Return

;ToolTip偏移距离输入结果处理
set_regulate_Hx:
	GuiControlGet, set_regulate_Hx,, set_regulate_Hx, text
	Set_Range :=WubiIni.TipStyle["Set_Range"]:= set_regulate_Hx>25?25:set_regulate_Hx, WubiIni.Save()
Return

;开机自启动>>>系统自启目录建立快捷方式
CreateShortcut_Startup:
	zq_:= cmdClipReturn(cmd_zq)
	if zq_~=Startup_Name {
		Command = schtasks /Delete /TN %Startup_Name% /F
		Run *RunAs cmd.exe /c %Command%, , Hide
	}
	if FileExist(A_Startup "\五笔*版.lnk")
		FileDelete,%A_Startup%\五笔*版.lnk
	FileCreateShortcut, %A_AhkPath%, %A_Startup%\%Startup_Name%.lnk , %A_ScriptDir%, "%A_ScriptFullPath%",便携式五笔外挂式脚本输入法, %A_ScriptDir%\config\WubiIME.icl, , 30, 1
	Startup :=WubiIni.Settings["Startup"]:="sc",WubiIni.save()
	Traytip,,你已建立「%Startup_Name%」开机自启！
Return

;开机自启动>>>批处理创建系统自启任务
Startup:
	if FileExist(A_Startup "\五笔*版.lnk"){
		FileDelete,%A_Startup%\五笔*版.lnk
	}
	Startup_path:=RegExReplace(DllCall("GetCommandLine", "Str"),"i)""( | /restart )"""," ")
	Command = schtasks /Create /TN %Startup_Name% /TR %Startup_path% /SC ONLOGON /RL HIGHEST /F
	Try {
			Run *RunAs %A_WinDir%\System32\schtasks.exe /Create /TN %Startup_Name% /TR %Startup_path% /SC ONLOGON /RL HIGHEST /F, ,Hide
			Result:= cmdClipReturn(cmd_zq)
			if Result~=Startup_Name{
				Startup :=WubiIni.Settings["Startup"]:="on", WubiIni.save()
				Traytip,自启提示:,已设为开机自启!
			}else{
				Startup :=WubiIni.Settings["Startup"]:="off", WubiIni.save()
				Traytip,失败提示:,设置失败，请「以管理员身份」运行后重新设置！,,2
			}
	} Catch {
		Startup :=WubiIni.Settings["Startup"]:="off", WubiIni.save()
	}
Return

;符号顶屏
symb_send:
	symb_send :=WubiIni.Settings["symb_send"] :=symb_send~="i)off"?"on":"off", WubiIni.save()
/*
	if symb_send~="i)off"
		Menu, setting, Rename, 符号顶屏	√ , 符号顶屏	×
	else
		Menu, setting, Rename, 符号顶屏	× , 符号顶屏	√
*/
Return

;Gdip候选框圆角
Radius:
	Radius :=WubiIni.TipStyle["Radius"] :=Radius~="i)off"?"on":"off", WubiIni.save()
	if Radius~="i)on"
		WubiIni.TipStyle["Gdip_Line"] :="on"
return

;空码提示
Prompt_Word:
	Prompt_Word :=WubiIni.Settings["Prompt_Word"] :=Prompt_Word~="i)off"?"on":"off",CheckFilterControl:="kmts", WubiIni.save()
	Gosub CheckFilter
return

;含词/单字选择
Wubi_Schema:
	Wubi_Schema :=WubiIni.Settings["Wubi_Schema"] :=Wubi_Schema<>"ci"?"ci":"zi", WubiIni.save()
	Gosub ChangeTray
return

;超集方案选择
Extend_Schema:
	Wubi_Schema :=WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema<>"chaoji"?"chaoji":"ci", WubiIni.save()
	If (Wubi_Schema="chaoji"&&a_FontList~="i)98WB-V|98WB-P0")
		FontType :=WubiIni.TipStyle["FontType"]:=a_FontList~="i)98WB-V"?"98WB-V":a_FontList~="i)98WB-P0"?98WB-P0:Font_, WubiIni.save()
	Gosub ChangeTray
return

;字根码表选择
ZG_Schema:
	Wubi_Schema :=WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema<>"zg"?"zg":"ci", WubiIni.save()
	If (a_FontList~="i)98WB\-"&&SchemaType[Wubi_Schema]=98)
		FontType :=WubiIni.TipStyle["FontType"]:=a_FontList~="i)98WB-0"?"98WB-0":a_FontList~="i)98WB-V"?"98WB-V":a_FontList~="i)98WB-3"?"98WB-3":a_FontList~="i)98WB-1"?"98WB-1":Font_, WubiIni.Save()
	else If (a_FontList~="五笔拆字字根字体"&&SchemaType[Wubi_Schema]<>98||a_FontList~="五笔拆字字根字体"&&not a_FontList~="i)98WB\-"&&SchemaType[Wubi_Schema]=98)
		FontType :=WubiIni.TipStyle["FontType"]:="五笔拆字字根字体", WubiIni.Save()
	Gosub ChangeTray
Return

;字根拆分
Cut_Mode:
	Cut_Mode :=WubiIni.Settings["Cut_Mode"] :=Cut_Mode~="i)off"?"on":"off", WubiIni.save()
	Menu, More, Rename, % Cut_Mode="off"?"隐藏拆分":"显示拆分" , % Cut_Mode="off"?"显示拆分":"隐藏拆分"
	If (Cut_Mode ~="i)on"&&a_FontList~="i)98WB\-"&&SchemaType[Wubi_Schema]=98)
		FontType :=WubiIni.TipStyle["FontType"]:=a_FontList~="i)98WB-0"?"98WB-0":a_FontList~="i)98WB-V"?"98WB-V":a_FontList~="i)98WB-3"?"98WB-3":a_FontList~="i)98WB-1"?"98WB-1":Font_, WubiIni.Save()
	else If (Cut_Mode ~="i)on"&&a_FontList~="五笔拆字字根字体"&&SchemaType[Wubi_Schema]<>98||Cut_Mode ~="i)on"&&a_FontList~="五笔拆字字根字体"&&not a_FontList~="i)98WB\-"&&SchemaType[Wubi_Schema]=98)
		FontType :=WubiIni.TipStyle["FontType"]:="五笔拆字字根字体", WubiIni.Save()
	if srf_all_input
		Gosub srf_tooltip_fanye
return

EN_Mode:
	EN_Mode :=WubiIni.Settings["EN_Mode"] :=!EN_Mode, WubiIni.save()
Return

;四码上屏
limit_code:
	limit_code :=WubiIni.Settings["limit_code"] :=limit_code~="i)off"?"on":"off", WubiIni.save()
	If limit_code~="i)on"
		GuiControl,98:Enable,SBA26
	else
		GuiControl,98:Disable,SBA26
return

;简繁转换
Trad_Mode:
	Trad_Mode :=WubiIni.Settings["Trad_Mode"] :=Trad_Mode~="i)off"?"on":"off", CheckFilterControl:="trad", WubiIni.save()
	Gosub CheckFilter
	Gosub SwitchSC
	if srf_all_input
		Gosub srf_tooltip_fanye
return

SwitchToEngIME:
	SwitchToEngIME()
return

SwitchToChsIME:
	SwitchToChsIME()
return

;候选样式标签选择处理
ToolTipStyle:
	ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"]:=ToolTipStyle="on"?"off":ToolTipStyle="off"?"Gdip":ToolTipStyle="Gdip"?"on":ToolTipStyle, WubiIni.save()
	Gosub Switchhxk
	Gosub SelectItems
return

;批量造词
Add_Code:
	ACTitle:="造词窗口"
	if WinExist(ACTitle){
		Traytip,  警告提示:,不能重复打开「批量造词」窗口！,,2
		Return
	}
	else
	{
		Gui, 29:Destroy
		Gui, 29:Default              ;A_ScreenDPI/96
		Gui, 29: +LastFound hwndEditPlus -MinimizeBox    ;+ToolWindow +OwnDialogs +MinSize260x250 -MaximizeBox +Resize +AlwaysOnTop
		Gui, 29:font,s12
		Gui, 29:Margin,12,12
		Gui,29:Add, ListBox, r15 w420 gSet_Value vSet_Value +Multi hwndCodeEdit  ;+Multi
		Gui, 29:Font
		Gui, 29:font,s10 bold
		Gui, 29: add, Edit, r1 y+10 w290 gEditBox2 vEditBox2 hwndCodeEdit2, 
		Gui, 29: add, Button,x+5 gaddChars hWndGCBT, 添加
		ImageButton.Create(GCBT, [6, 0x80404040, 0x008000, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x008000],"", [0, 0xC0A0A0A0, , 0xC0008000])
		Gui, 29: add, Button,x+5 w60 gaddFiles vaddFiles HWNDAFBT, 批量导入
		ImageButton.Create(AFBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
		Gui, 29:font,
		Gui, 29:font,s11 bold
		Gui, 29:Add, Button,xm gSave vSave hWndSVBT, 保存
		ImageButton.Create(SVBT, [6, 0x80404040, 0x008000, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x008000],"", [0, 0xC0A0A0A0, , 0xC0008000])
		Gui, 29:font,
		Gui, 29:font,s10 underline
		Gui, 29:Add, text,x+20 yp+6 w320 cred vsaveTip hWndsaveTip,
		Gui, 29:font,
		Gui, 29:Submit
		Gui,29:show,AutoSize,%ACTitle%
		Gosub SetGuiTitle
	}
return

EM_SetCueBanner(hWnd, Cue)
{
	static EM_SETCUEBANNER := 0x1501
	return DllCall("User32.dll\SendMessage", "Ptr", hWnd, "UInt", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}

SetGuiTitle:
	Gosub ChangeWinIcon
	; WinGetTitle, _WinTitle, A
	; WinGetClass, _WinClass, A
	SendMessage,0xC,, "造词窗口"
	EM_SetCueBanner(CodeEdit2, "请输入词条,以分号结尾自动添加")
	;SendMessage, 0x1501, 1, "请输入词条,以分号结尾自动添加", Edit1, ahk_id%EditPlus%
	ControlFocus , Edit1, A
Return

EditBox2:
	ControlGetText, EditBox2, Edit1
	if EditBox2~="\;$|；$" {
		EditBox2:=RegExReplace(EditBox2,"\;|；")
		Gosub addChars
	}
Return

Set_Value:
	If (A_GuiEvent ="DoubleClick"&&A_EventInfo) {
		ControlGet, ListContent, List, Count,ListBox1, A
		GuiControlGet, Content ,, Set_Value, ListBox
		if (ListContent&&Content) {
			List_Content:=ListContent~="\n"?RegExReplace(ListContent,(A_EventInfo=1?Content "\n":"\n" Content)):""
			GuiControl,29:, Set_Value ,% "|" RegExReplace(List_Content,"`n","|")
			ControlFocus , Edit1, A
		}
	}
Return

addChars:
	if not EditBox2~="\=|^\;|^\；" {
		If StrLen(EditBox2)>0 {
			GuiControl,29:, Set_Value ,% get_en_code(EditBox2) "=" EditBox2 "|"
			GuiControl,29:, EditBox2 ,
		}
	}else if EditBox2~="\=" {
		If StrLen(EditBox2)>0 {
			GuiControl,29:, Set_Value ,% RegExReplace(EditBox2,"^\s+|\s+$") "|"
			GuiControl,29:, EditBox2 ,
		}
	}
	ControlFocus , Edit1, A
Return

addFiles(){
	global Wubi_Schema, Frequency, Prompt_Word, Trad_Mode
	If FileExist("Config\Script\CompoundPhrase.ahk") {
		Run *RunAs "%A_AhkPath%" /restart "Config\Script\CompoundPhrase.ahk"
	}else{
		FileSelectFile, MaBiaoFile, 3,%A_Desktop% , 批量导入词组, Text Documents (*.txt)
		SplitPath, MaBiaoFile, , , , filename
		If (MaBiaoFile<> ""&&filename){
			startTime:= CheckTickCount()
			tarr:=[],count :=counts:=0
			GetFileFormat(MaBiaoFile,MaBiao,Encoding)
			If (Encoding="UTF-16BE BOM") {
				GuiControl,29:,saveTip, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！
			}
			totalCount:=CountLines(MaBiao), num:=totalCount>100?Ceil(totalCount/100):totalCount>50?Ceil(totalCount/10):Ceil(totalCount/5)
			Progress, M1 Y10 FM14 W350, 1/%totalCount%, 词条处理中..., 1`%
			OnMessage(0x201, "MoveProgress")
			Loop, Parse, MaBiao, `n, `r
			{
				If (A_LoopField = "")
					Continue
				If A_LoopField~="^[^\w]+$" {    ;纯词条
					citiao:=A_LoopField, bianma:=get_en_code(citiao), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
				}else If A_LoopField~="^.+\t[a-z]+$" {   ;单行单义无词频
					citiao:=RegExReplace(A_LoopField,"\t.+"), bianma:=RegExReplace(A_LoopField,".+\t"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
				}else If A_LoopField~="^[a-z]+\=.+" {    ;编码=词条
					citiao:=RegExReplace(A_LoopField,"^[a-z]+\="), bianma:=RegExReplace(A_LoopField,"(?<=[a-z])\=.+"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
				}else If A_LoopField~="^.+\t[a-z]+\t\d+" {   ;单行单义带词频
					citiao:=RegExReplace(A_LoopField,"\t([a-z]+)\t\d+$"), bianma:=RegExReplace(A_LoopField,citiao "\t|\t\d+$"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
				}
				If cipin 
					Insert_ci .="('" citiao "','" bianma "','" cipin "','" cipin "','" caifen "','" get_en_code(citiao) "')" ",", count++
				If (Mod(counts, num)=0) {
					tx :=Ceil(count/num)
					Progress, %tx% , %count%/%totalCount%`n, %tip%词库处理中..., 已完成%tx%`%
				}
			}
			Progress,off
			If Insert_ci
			{
				if DB.Exec("INSERT INTO ci(aim_chars,A_Key,B_Key,D_Key,E_Key,F_Key) VALUES " RegExReplace(Insert_ci,"\,$","") ";")>0
				{
					GuiControl,29:,saveTip,% "写入" count "条" (count<>counts?"重复" counts-count "条":"") "，完成用时" CheckTickCount(startTime)" ！"
					Sleep 3000
					GuiControl,29:,saveTip,
				}
				else
				{
					GuiControl,29:,saveTip, 格式不对！
					return
				}
			}else{
				GuiControl,29:,saveTip, 词条已存在，无需重复导入。。。
			}
			MaBiao:=Insert_ci:="", tarr:=[]
		}
	}
}

;造词窗口关闭销毁
29GuiClose:
29GuiEscape:
	ControlGet, mb_add, List, Count,ListBox1, A
	if mb_add {
		Gui +OwnDialogs
		MsgBox, 262452,退出提示, 检测到你还没有保存，是否写入至词库？
		IfMsgBox, Yes
		{
			GuiControl,29:, Set_Value ,|
			if (objLength(return_num :=Save_word(mb_add))>1)
				GuiControl,29:,saveTip,% "成功写入" return_num[1] (return_num[2]?"条，重复" return_num[2]:"") "条！耗时" return_num[3]
			else
				GuiControl,29:,saveTip, % return_num[1]
			Sleep 3000
			GuiControl,29:,saveTip,
		}
	}
	Gui,29:Destroy
Return

;造词保存处理
Save:
	ControlGet, mb_add, List, Count,ListBox1, A
	if mb_add {
		Gui +OwnDialogs
		MsgBox, 262452,批量造词,% "是否写入" _ListCount:= StrSplit(mb_add,"`n").Length() "行数据？"
		IfMsgBox, Yes
		{
			GuiControl,29:, Set_Value ,|
			if (objLength(return_num :=Save_word(mb_add))>1)
				GuiControl,29:,saveTip,% "成功写入" return_num[1] (return_num[2]?"条，重复" return_num[2]:"") "条！耗时" return_num[3]
			else
				GuiControl,29:,saveTip, % return_num[1]
			Sleep 3000
			GuiControl,29:,saveTip,
		}
	}
return

;方案词库导入（超集+含词+单字）
Write_DB:
	Gui +OwnDialogs
	FileSelectFile, MaBiaoFile, 3,%A_Desktop% , 导入词库, Text Documents (*.txt)
	SplitPath, MaBiaoFile, , , , filename
	If (MaBiaoFile<> ""&&filename){
		MsgBox, 262452, 提示, 要导入以下词库进行替换？`n词库格式为：单行单义/单行多义`n码表处理过程中耗时30秒左右，请稍等。。。
		IfMsgBox, Yes
		{
			startTime:= CheckTickCount()
			TrayTip,, 码表处理中，请稍后...
			tarr:=[],count :=0
			GetFileFormat(MaBiaoFile,MaBiao,Encoding)
			If (Encoding="UTF-16BE BOM")
				MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 5
			if MaBiao~="`n[a-z]\s.+\s.+"
				MaBiao:=TransformCiku(MaBiao)
			else if not MaBiao~="\t[a-z]+\t\d+"&&MaBiao~="\t[a-z]+$"
				MaBiao:=Transform_cp(MaBiao)
			If MaBiao~="\t[a-z]+\t\d+" {
				totalCount:=CountLines(MaBiao), num:=Ceil(totalCount/100), EtymologyPhrase:=GetEtymologyPhrase(DB), EnPhrase:=GetEnPhrase(DB)
				tip:=Wubi_Schema~="i)ci"?"【含词】":Wubi_Schema~="i)zi"?"【单字】":Wubi_Schema~="i)chaoji"?"【超集】":"【字根】"
				Progress, M1 Y10 FM14 W350, 1/%totalCount%, %tip%词库处理中..., 1`%
				Loop, Parse, MaBiao, `n, `r
				{
					If (A_LoopField = "")
						Continue
					tarr:=StrSplit(A_LoopField,A_Tab)
					if (tarr[3]){
						count++
						If (Wubi_Schema="ci") {
							If (strlen(tarr[1])=1)
								Etymology:=EtymologyPhrase[tarr[1],1], bianma:=EnPhrase[tarr[1],1]
							else If (strlen(tarr[1])=2) {
								Etymology:=EtymologyPhrase[SubStr(tarr[1],1,1),2] EtymologyPhrase[SubStr(tarr[1],1,1),3] EtymologyPhrase[SubStr(tarr[1],2,1),2] EtymologyPhrase[SubStr(tarr[1],2,1),3]
								bianma:=EnPhrase[SubStr(tarr[1],1,1),2] EnPhrase[SubStr(tarr[1],1,1),3] EnPhrase[SubStr(tarr[1],2,1),2] EnPhrase[SubStr(tarr[1],2,1),3]
							}else If (strlen(tarr[1])=3) {
								Etymology:=EtymologyPhrase[SubStr(tarr[1],1,1),2] EtymologyPhrase[SubStr(tarr[1],2,1),2] EtymologyPhrase[SubStr(tarr[1],3,1),2] EtymologyPhrase[SubStr(tarr[1],3,1),3]
								bianma:=EnPhrase[SubStr(tarr[1],1,1),2] EnPhrase[SubStr(tarr[1],2,1),2] EnPhrase[SubStr(tarr[1],3,1),2] EnPhrase[SubStr(tarr[1],3,1),3]
							}else If (strlen(tarr[1])>3) {
								Etymology:=EtymologyPhrase[SubStr(tarr[1],1,1),2] EtymologyPhrase[SubStr(tarr[1],2,1),2] EtymologyPhrase[SubStr(tarr[1],3,1),2] EtymologyPhrase[SubStr(tarr[1],0),2]
								bianma:=EnPhrase[SubStr(tarr[1],1,1),2] EnPhrase[SubStr(tarr[1],2,1),2] EnPhrase[SubStr(tarr[1],3,1),2] EnPhrase[SubStr(tarr[1],0),2]
							}
							Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "','" tarr[3] "','" tarr[3] "','" Etymology "','" bianma "')" ","

						}else If Wubi_Schema~="i)zi|chaoji" {
							Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "','" EtymologyPhrase[tarr[1],1] "','" EnPhrase[tarr[1],1] "')" ","
						}else
							Insert_ci .="('" tarr[1] "','" tarr[2] "')" ","
					}
					If (Mod(count, num)=0) {
						tx :=Ceil(count/num)
						Progress, %tx% , %count%/%totalCount%`n, %tip%词库处理中..., 已完成%tx%`%
					}
				}

				Progress,off
				If Insert_ci
				{
					MsgBox, 262452, 写入提示, 码表处理完成是否写入到词库？`n写入需要几秒钟，请等待。。。
					IfMsgBox, Yes
					{
						Create_Ci(DB,MaBiaoFile)
						if DB.Exec("INSERT INTO " Wubi_Schema " VALUES " RegExReplace(Insert_ci,"\,$","") ";")>0
						{
							timecount:= CheckTickCount(startTime)
							Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 写入%count%行！完成用时 %timecount%！, 完成提示
							TrayTip,完成提示, 写入%count%行！完成用时 %timecount%！
							Sleep 3000
						}
						else
						{
							MsgBox, 262160, 错误提示, 导入失败！, 8
							return
						}
					}
				}else
					MsgBox, 262160, 错误提示, 格式不对！, 5
			}else
				MsgBox, 262160, 错误提示, 码表格式不对, 10
		}else
			TrayTip,, 导入已取消...
	}
	Progress,off
	Gosub OnReload
return

Write_Strocke:
	Gui +OwnDialogs
	FileSelectFile, MaBiaoFile, 3, , 导入词库, Text Documents (*.txt)
	SplitPath, MaBiaoFile, , , , filename
	If (MaBiaoFile = ""){
		TrayTip,, 取消导入
		Return
	} Else {
		TrayTip,, 你选择了文件「%filename%」
	}
	If !filename
		Return
	Gui +OwnDialogs
	MsgBox, 262452, 提示, 要导入以下词库进行替换？`n文件格式：汉字+Tab+笔画编码(数字1-5)+词频
	IfMsgBox, No
	{
		TrayTip,, 导入已取消！
		Return
	} Else {
		startTime:= CheckTickCount()
		TrayTip,, 词库写入中，请稍后...
		Create_Strocke(DB,MaBiaoFile)
		tarr:=[],count :=0
		GetFileFormat(MaBiaoFile,MaBiao,Encoding)
		If (Encoding="UTF-16BE BOM") {
			MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 10
			Return
		}
		If MaBiao~="\n\W+\t[1-5]+" {
			totalCount:=CountLines(MaBiaoFile), num:=Ceil(totalCount/100)
			Progress, M1 FM14 Y100 W380, 1/%totalCount%, 笔画词库写入中,请稍候..., 1`%
			OnMessage(0x201, "MoveProgress")
			Loop, Parse, MaBiao, `n, `r
			{
				count++
				If (A_LoopField = "")
					Continue
				tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
				If objCount(tarr)>3
					Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "','" tarr[4] "')" ","
				else{
					If (objCount(tarr)=3&&tarr[3]~="^\d+$")
						Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "',null)" ","
					else If (objCount(tarr)=2)
						Insert_ci .="('" tarr[1] "','" tarr[2] "','" ((dzcp:=Get_Weight(tarr[1]))?dzcp:1) "',null)" ","
					else
						Continue
				}
				If (Mod(count, num)=0) {
					tx :=Ceil(count/num)
					Progress, %tx% , %count%/%totalCount%`n, 笔画词库写入中,请稍候..., 已完成%tx%`%
				}
			}
			Progress,off
			if DB.Exec("INSERT INTO 'extend'.'Strocke' VALUES" RegExReplace(Insert_ci,"\,$") "")>0
			{
				timecount:= CheckTickCount(startTime)
				Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 写入%count%行！完成用时 %timecount%！, 完成提示
				TrayTip,, 写入%count%行！完成用时 %timecount%
				Sleep 5000
				Progress,off
			}
			else
			{
				MsgBox, 262160, 导入错误, 导入失败！, 10
				return
			}
		}else{
			MsgBox, 262160, 格式错误, 码表格式不支持！, 10
		}
	}
	MaBiao:=Insert_ci:=""
Return

Export_Strocke:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,*%A_ScriptDir%\Sync\,3,请选择导出后保存的位置
	if OutFolder<>
	{
		startTime:= CheckTickCount()
		Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, % "笔画码表导出中...", 码表导出
		if DB.gettable("SELECT * FROM 'extend'.'Strocke';",Result){
			FileDelete, %OutFolder%\Strocke.txt
			Loop % Result.RowCount
			{
				Resoure_ .=Result.Rows[A_index,1] A_tab Result.Rows[A_index,2] A_tab Result.Rows[A_index,3] (Result.Rows[A_index,4]?A_tab Result.Rows[A_index,4]:"") "`n"
			}
			timecount:= CheckTickCount(startTime)
			FileAppend,%Resoure_%,%OutFolder%\Strocke.txt, UTF-8
			Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 导出完成用时 %timecount%！, 码表导出
			Resoure_ :=OutFolder :="", Result:={}
			TrayTip,, 导出完成用时 %timecount%
			Sleep 4000
		}
		Progress, off
	}
Return

;词库导入（英文+symbols）
Write_En:
	Gui +OwnDialogs
	FileSelectFile, MaBiaoFile, 3, , 导入词库, Text Documents (*.txt)
	SplitPath, MaBiaoFile, , , , filename
	If (MaBiaoFile = ""){
		TrayTip,, 取消导入
		Return
	} Else {
		TrayTip,, 你选择了文件「%filename%」
	}
	If !filename
		Return
	Gui +OwnDialogs
	MsgBox, 262452, 提示, 要导入以下词库进行替换？
	IfMsgBox, No
	{
		TrayTip,, 导入已取消！
		Return
	} Else {
		startTime:= CheckTickCount()
		TrayTip,, 词库写入中，请稍后...
		Create_En(DB,MaBiaoFile)
		tarr:=[],count :=0
		GetFileFormat(MaBiaoFile,MaBiao,Encoding)
		If (Encoding="UTF-16BE BOM") {
			MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 10
			Return
		}
		totalCount:=CountLines(MaBiao), num:=Ceil(totalCount/100)
		Loop, Parse, MaBiao, `n, `r
		{
			count++
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
			Insert_ci .="('" tarr[1] "','" tarr[2] "')" ","
			If (Mod(count, num)=0) {
				tx :=Ceil(count/num)
				Progress, %tx% , %count%/%totalCount%`n, 词库导入中..., 已完成%tx%`%
			}
		}
		Insert_ci :=RegExReplace(Insert_ci,"\,$","")
		if bd ~="i)En"?(DB.Exec("INSERT INTO encode VALUES" Insert_ci "")):(DB.Exec("INSERT INTO 'extend'.'symbols' VALUES" Insert_ci ""))>0
		{
			timecount:= CheckTickCount(startTime)
			Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 写入%count%行！完成用时 %timecount%！, 完成提示
			TrayTip,, 写入%count%行！完成用时 %timecount%
			Sleep 3000
		}
		else
		{
			TrayTip,, 格式不对...
			return
		}
		Progress, off
	}
	MaBiao:=Insert_ci:=""
return

;备份自造词
Backup_CustomDB:
	Gui +OwnDialogs
	if DB.GetTable("SELECT aim_chars,A_Key,B_Key FROM ci WHERE C_Key IS NULL AND B_Key>0 ORDER BY A_Key,B_Key DESC;",Result)>0{
		CFileName:="自造词_" A_Now ".txt"
		if Result.RowCount>0{
			Loop, Files, Sync\自造词*.txt
				FileDelete, %A_LoopFileFullPath%
			Loop % Result.RowCount
			{
				custom_mb .=Result.Rows[A_index,1] A_tab Result.Rows[A_index,2] A_tab Result.Rows[A_index,3] "`n"
			}
			FileAppend,%custom_mb%,%A_ScriptDir%\Sync\%CFileName%, UTF-8
			;Loop, Files, Sync\自造词*.txt
			;	if (A_Now-A_LoopFileTimeCreated>10000)
			;		FileDelete, %A_LoopFileFullPath%
			custom_mb:="", Result_:=Results_:=Result:=[]
		}
	}
	Result_:=Results_:=Result:=[]
Return

Backup_DB_2:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,*%A_ScriptDir%\Sync\,3,请选择导出后保存的位置
	if OutFolder<>
	{
		startTime:= CheckTickCount()
		if Wubi_Schema~="i)ci"{
			if init_db
				SQL := "SELECT aim_chars,A_Key,C_Key FROM ci WHERE C_Key>0 ORDER BY A_Key,C_Key DESC;"
			else if custom_db
				SQL := "SELECT aim_chars,A_Key,B_Key FROM ci WHERE C_Key IS NULL AND B_Key>0 ORDER BY A_Key,B_Key DESC;"
			else if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off")
				SQL := "SELECT aim_chars,A_Key,D_Key FROM ci WHERE D_Key>0 ORDER BY A_Key,D_Key DESC;"
			else
				SQL := "SELECT aim_chars,A_Key,B_Key FROM ci WHERE B_Key>0 ORDER BY A_Key,B_Key DESC;"
		}else
			SQL := "SELECT aim_chars,A_Key,B_Key FROM " Wubi_Schema " ORDER BY A_Key,B_Key DESC;"
		Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, % "〔" (Wubi_Schema~="i)ci"?"含词":Wubi_Schema~="i)zi"?"单字":Wubi_Schema~="i)chaoji"?"超集":"字根") "〕单行多义码表导出中...", 码表导出
		if DB.gettable(SQL,Result){
			For Section,element In Result.Rows
			{
				if (element[2]=bianma)
					Resoure_ .=A_Space element[1]
				else
					Resoure_ .="`n" element[2] A_Space element[1]
				bianma:=element[2]
			}
			Resoure_:=RegExReplace(Resoure_,"^\n")
			timecount:= CheckTickCount(startTime)
			FileDelete, %OutFolder%\WubiCiku-%Wubi_Schema%_多义.txt
			FileAppend,%Resoure_%,%OutFolder%\WubiCiku-%Wubi_Schema%_多义.txt, UTF-8
			Resoure_ :=OutFolder :="", custom_db:=init_db:=0, Result_:=Results_:=Result:=[]
			Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 导出完成用时 %timecount%！, 码表导出
			TrayTip,, 导出完成用时 %timecount%
			Sleep 4000
			Progress,off
		}else{
			TrayTip,, 导出失败！
			custom_db:=init:=0
		}
		Progress,off
	}
Return

;词库导出（超集+含词+单字）
Backup_DB:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,*%A_ScriptDir%\Sync\,3,请选择导出后保存的位置
	if OutFolder<>
	{
		startTime:= CheckTickCount()
		if Wubi_Schema~="i)ci"{
			if init_db
				SQL := "SELECT aim_chars,A_Key,C_Key FROM ci WHERE C_Key>0 ORDER BY A_Key,C_Key DESC;"
			else if custom_db
				SQL := "SELECT aim_chars,A_Key,B_Key FROM ci WHERE C_Key IS NULL AND B_Key>0 ORDER BY A_Key,B_Key DESC;"
			else if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off")
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
			timecount:= CheckTickCount(startTime)
			fileNewname:=init_db?"主码表":custom_db?"用户词":Wubi_Schema
			If (FileExist(A_ScriptDir "\Sync\header.txt")&&BUyaml&&!custom_db){
				GetFileFormat(A_ScriptDir "\Sync\header.txt",HeadInfo,Encoding)
				If (Encoding="UTF-16BE BOM") {
					MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 5
				}
				HeadInfo:=Wubi_Schema~="i)ci"?HeadInfo:(Wubi_Schema~="i)chaoji"?RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "WubiCiku_U"):Wubi_Schema~="i)zi"?RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "WubiCiku_dz"):RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "WubiCiku_zg"))
				RegExMatch(HeadInfo,"(?<=name\:).+",FileInfo)
				FileInfo:=RegExReplace(FileInfo,"\s+")
				FileDelete, %OutFolder%\%FileInfo%.dict.yaml
				Resoure_:=HeadInfo "`n" Resoure_, HeadInfo:=""
				FileAppend,%Resoure_%,%OutFolder%\%FileInfo%.dict.yaml, UTF-8
			}else{
				FileDelete, %OutFolder%\WubiCiku-%fileNewname%_单义.txt
				FileAppend,%Resoure_%,%OutFolder%\WubiCiku-%fileNewname%_单义.txt, UTF-8
			}
			Resoure_ :=OutFolder :="", custom_db:=init_db:=0, Result_:=Results_:=Result:=[]
			TrayTip,, 导出完成用时 %timecount%
		}else{
			TrayTip,, 导出失败！
			custom_db:=init:=0
		}
	}
return

;词库导出（英文db+特殊符号db）	
Backup_En:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,*%A_ScriptDir%\Sync\,3,请选择导出后保存的位置
	if OutFolder<>
	{
		startTime:= CheckTickCount()
		Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, % "英文词库导出中...", 码表导出
		if DB.gettable("SELECT aim_chars,A_Key FROM " (bd~="En"?"encode":"'extend'.'symbols'") "",Result){
			FileDelete, %OutFolder%\WubiCiku-%bd%.txt
			Loop % Result.RowCount
			{
				Resoure_ .=Result.Rows[A_index,1] A_tab Result.Rows[A_index,2] "`n"
			}
			timecount:= CheckTickCount(startTime)
			FileAppend,%Resoure_%,%OutFolder%\WubiCiku-%bd%.txt, UTF-8
			Resoure_ :=OutFolder :=""
			Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 导出完成用时 %timecount%！, 码表导出
			TrayTip,, 导出完成用时 %timecount%
			Sleep 4000
		}
		Progress,off
	}
return

;候选横竖排
Textdirection:
	Textdirection :=WubiIni.TipStyle["Textdirection"] :=Textdirection="vertical"?"horizontal":"vertical", WubiIni.save()
return

;回车设定
Select_Enter:
	Select_Enter :=WubiIni.Settings["Select_Enter"] :=(Select_Enter="send"?"clean":"send"), WubiIni.save()
return

;划词反查ToolTip窗口关闭设定
RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip(1,"")
return

;农历日期时间获取
get_lunarDate_now:
	FormatTime, MIVar, , H
	FormatTime, RQVar, , yyyyMMdd
	lunar :=Date2LunarDate(RQVar,GzType)[1]
	lunar_time :=Time_GetShichen(MIVar)
	UpperScreenMode(lunar lunar_time)
return

Ime_Tips:
	
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		Return
	}
	OnExit, TipExit
	Width := A_Cursor ~= "i)IBeam"?34*(A_ScreenDPI/96):38*(A_ScreenDPI/96), Height := A_Cursor ~= "i)IBeam"?34*(A_ScreenDPI/96):38*(A_ScreenDPI/96)
	Gui, tips: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
	Gui, tips: Add, Edit, w%Width% h%Height%, vMeEdit
	Gui, tips: Show, NA
	hwnd1 := WinExist(),hbm := CreateDIBSection(Width, Height)
	hdc := CreateCompatibleDC(),obm := SelectObject(hdc, hbm),G := Gdip_GraphicsFromHDC(hdc),Gdip_SetSmoothingMode(G, 4)
	pBrush := Gdip_BrushCreateSolid("0x" SubStr("FF" FocusBackColor, -7))   ;"0xaa" FocusBackColor
	Gdip_FillRoundedRectangle(G, pBrush, 0, 0, Width, Height, 0),Gdip_DeleteBrush(pBrush)
	tips_text:=GetKeyState("CapsLock", "T")?"A":srf_mode?"中":"英",tipSize:=A_Cursor ~= "i)IBeam"?"24":"28"
	If !Gdip_FontFamilyCreate(Font_)
	{
		MsgBox, 48, Font error!, The font you have specified does not exist on the system
		Gui, tips: Destroy
	}
	pPen := Gdip_CreatePen("0x" SubStr("FF" FocusBackColor, -7), 1), Gdip_DrawRoundedRectangle(G, pPen, 0, 0, Width-2, Height-2, 0)
	Gdip_TextToGraphics(G, tips_text, "Center" "c" SubStr("ff" FocusColor, -7) " r4" "S" tipSize*(A_ScreenDPI/96) "bold", Font_, Width, Height)
	WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
	UpdateLayeredWindow(hwnd1, hdc, A_Cursor ~= "i)IBeam"?tip_pos.x:A_ScreenWidth-Width, A_Cursor ~= "i)IBeam"?tip_pos.y:A_ScreenHeight-Shell_Wnd-Height, Width, Height)
	SelectObject(hdc, obm)
	DeleteObject(hbm)
	DeleteDC(hdc)
	Gdip_DeleteGraphics(G)
Return

TipExit:
	Gdip_Shutdown(pToken)
	ExitApp
Return

SetSuspend:
	Suspend
	if A_IsSuspended {
		Menu, Tray, Icon, config\WubiIME.icl,31, 1
		;if !GET_IMESt()
		;	SwitchToChsIME()
		Menu, TRAY, Rename, 禁用 , 启用
		Menu, TRAY, Icon, 启用, config\WubiIME.icl, 4
		GuiControl,logo:, Pics,*Icon4 config\Skins\logoStyle\%StyleN%.icl
		Traytip,  提示:,已切换至挂起状态！
	}else if !A_IsSuspended {
		if FileExist(IconName_)
			Menu, Tray, Icon, %IconName_%
		else
			Menu, Tray, Icon, config\WubiIME.icl,30
		Traytip,  提示:,已切换至启用状态！
		;if GET_IMESt()
		;	SwitchToEngIME()
		Menu, TRAY, Rename, 启用 , 禁用
		Menu, TRAY, Icon, 禁用, shell32.dll, 175
		if srf_mode
			GuiControl,logo:, Pics,*Icon1 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, Pics,*Icon3 config\Skins\logoStyle\%StyleN%.icl
	}
	;DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("ActivateKeyboardLayout", UInt, 1, UInt, 256))
return

SetRlk:
	rlk_switch:=WubiIni.Settings["rlk_switch"]:=!rlk_switch,WubiIni.save()
	Menu, More, Icon, 划译反查, shell32.dll, % rlk_switch?145:134
	if rlk_switch
		Traytip,,划译反查功能已开启！
	else
		Traytip,,划译反查功能已关闭！
Return

RlkResult:
	select_for_code:=select_for_code_result:=rlk_for_select_tooltip:="", select_for_code := getSelectText()
	if (StrLen(select_for_code)<20&&StrLen(select_for_code)>0)
	{
		select_for_code :=RegExReplace(select_for_code, "\d+|[a-zA-Z]{1,}|\s+|`n", "")
		if select_for_code_result := Tip_rvlk(select_for_code)
		{
			MouseGetPos, xpos, ypos
			if (a_FontList ~="i)" FontExtend && FontType ~="i)" FontExtend )          ;判断是否安装「折分显示的字体」没安装的话只显示编码
			{
				ToolTip(1, "", "Q1 B" FocusBackColor " T" FocusColor " S16" " F" FontType)
				ToolTip(1, select_for_code_result, "x" xpos " y" ypos+30)
				select_for_code_result :=""
			}
			else          ;判断是否安装「折分显示的字体」没安装的话只显示编码
			{
				Loop, Parse, select_for_code_result, `n
					rlk_for_select_tooltip .=RegExReplace(A_LoopField, "〔.+\〕|^`n", "") . "`n"
				ToolTip(1, "", "Q1 B" FocusBackColor " T" FocusColor " S16" " F" FontType)
				ToolTip(1, rlk_for_select_tooltip, "x" xpos " y" ypos+30)
				rlk_for_select_tooltip :=""
			}
			;SetTimer, RemoveToolTip, 3200  ;定时关闭启用
		}
	}
return

Batch_AddCode:
if WinExist("造词窗口"){
	Traytip,  警告提示:,不能重复打开「批量造词」窗口！,,2
	Return
}
else
{
	if Wubi_Schema~="ci"
		gosub Add_Code
	else
		Traytip,,造词仅在98含词方案有效！
}
return

DB_management:
	Gosub DestroyGui
	Gui, DB:Default
	Gui, DB: +hwndDB_ +OwnDialogs +LastFound -MinimizeBox   ;+ToolWindow +OwnDialogs +MinSize435x470 +MaxSize550x520 -MaximizeBox +Resize -DPIScale +AlwaysOnTop
	Gui,DB:Font, s9 bold , %Font_%
	Gui, DB:Add, Button,y+10 Section gDB_Delete vDB_Delete hWndDDBT, 删除
	ImageButton.Create(DDBT, [6, 0x80404040, 0xe81010, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0xe81010],"", [0, 0xC0A0A0A0, , 0xC0e81010])
	Gui, DB:Add, Button,x+8 Section gDB_reload vDB_reload hWndDRBT, 刷新
	ImageButton.Create(DRBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	GuiControl, DB:Disable, DB_Delete
	Gui, DB:Add, Button,x+8 Section gDB_search vDB_search hWndDSBT, 搜索
	ImageButton.Create(DSBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,DB:Font,
	Gui,DB:Font, s8 norm, %font_%
	Gui, DB:Add, Edit, x+8 yp w180 vsearch_text hwndDBEdit
	Gui,DB:Font,
	Gui,DB:Font, s8 bold, %font_%
	Gui, DB:Add, CheckBox, x+2 yp-3 vsearch_1 gsearch_1, 词频`n为零
	GuiControl, DB:Disable, search_1
	Gui,DB:Font,
	Gui,DB:Font, s9 norm, %font_%
	Gui, DB:Add, Button,x+2 Section gDB_Submit vDB_Submit hWndDB_Submit, 确定
	ImageButton.Create(DB_Submit, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,DB:Font,
	Gui,DB:Font, s10, %font_%
	GuiControl, DB:Hide, search_text
	GuiControl, DB:Hide, search_1
	GuiControl, DB:Hide, DB_Submit
	Gui, DB:Add, ListView,R15 w400 xm+0 y+8 Grid AltSubmit ReadOnly NoSortHdr NoSort -WantF2 Checked -Multi 0x8 LV0x40 -LV0x10 gMyDB vMyDB hwndDBLV, 词条|编码|词频
	GuiControl, +Hdr, MyDB
	;;DLV := New LV_Colors(DBLV)
	;;DLV.SelectionColors(0xfecd1b)
	Gui,DB:Font,
	Gui,DB:Font, s9 bold, %font_%
	Gui, DB:Add, Button,y+10 Section gDB_BU vDB_BU hWndDBBT, 导出全部
	ImageButton.Create(DBBT, [6, 0x80404040, 0x0078D7, 0xffffff], [ , 0x80606060, 0xF0F0F0, 0x0078D7],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cblue, %font_%
	Gui, DB:Add, Button,x+150 yp Section vToppage gToppage hWndTPBT,首页
	ImageButton.Create(TPBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cred, %font_%
	Gui, DB:Add, Button,x+5 Section vuppage guppage HwndUPBT,上一页
	ImageButton.Create(UPBT, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0008000])
	Gui, DB:Add, Button,x+5 Section vnextpage gnextpage hWndNPBT,下一页
	ImageButton.Create(NPBT, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0008000])
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cblue, %font_%
	Gui, DB:Add, Button,x+5 Section vLastpage gLastpage hWndLPBT,尾页
	ImageButton.Create(LPBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC00078D7])
	Gui,DB:Font,
	Gui,DB:Font, s10, %font_%
	Gui, DB:Add, StatusBar,vSBTIP,❖
	Gui, DB:Margin , 10, 10
	DB_Page:=1, DB_Count:=40
	Gosub ReadDB
	LV_ModifyCol(1,"150 left")
	LV_ModifyCol(2,"80 Center")
	LV_ModifyCol(3,"150 Integer Center")
	SB_SetText(" ❖ " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条 ")
	;SB_SetIcon("Config\WubiIME.icl",30)
	EM_SetCueBanner(DBEdit, "请输入搜索的字词或编码")
	Gui,DB:Show,AutoSize,自造词管理
	Gosub ChangeWinIcon
Return

DBGuiClose:
	search_1:=ss:=ResultCount:=RCount:=0
	Result_:=Results_:=[]
	DBGuiEscape:
	Gui, DB:Destroy
Return
/*
DBGuiSize:
	GuiControlGet, LVVar, Pos , MyDB
	if A_GuiWidth>435
	{
		GuiControl, DB:Move, MyDB,% "w" LVVarW+A_GuiWidth-435-30
		LV_ModifyCol(1,"" 150+(A_GuiWidth-435)/3 " left")
		LV_ModifyCol(2,"" 80+(A_GuiWidth-435)/3 " Center")
		LV_ModifyCol(3,"" 150+(A_GuiWidth-435)/3 " Integer Center")
	;	GuiControl, DB:Move, Toppage,% "x+" EVVarX+EVVarW+165+A_GuiWidth-435
	;	GuiControl, DB:Move, uppage,% "x+" EVVarX+EVVarW+165+A_GuiWidth-400
	;	GuiControl, DB:Move, nextpage,% "x+" EVVarX+EVVarW+165+A_GuiWidth-350
	;	GuiControl, DB:Move, Lastpage,% "x+" EVVarX+EVVarW+165+A_GuiWidth-295
	}
	if A_GuiHeight>470
	{
		GuiControl, DB:Move, MyDB, % "h" A_GuiHeight-135
		GuiControl, DB:Move, DB_BU,% "y+" LVVarY+A_GuiHeight-135+15
		GuiControl, DB:Move, Toppage,% "y+" LVVarY+A_GuiHeight-135+20
		GuiControl, DB:Move, uppage,% "y+" LVVarY+A_GuiHeight-135+20
		GuiControl, DB:Move, nextpage,% "y+" LVVarY+A_GuiHeight-135+20
		GuiControl, DB:Move, Lastpage,% "y+" LVVarY+A_GuiHeight-135+20
	}
Return
*/

DB_reload:
	LV_Delete()
	lineInfo:=lineInfo?lineInfo:1
	Gosub ReadDB
	GuiControl,DB:, search_text ,
	ss:=ResultCount:=RCount:=0
Return

DB_BU:
	custom_db:=1
	Gosub Backup_DB
Return

uppage:
	DB_Page--
	Gosub NextRows
Return

nextpage:
	DB_Page++
	Gosub NextRows
Return

Toppage:
	DB_Page:=1
	Gosub NextRows
Return

Lastpage:
	DB_Page:=Ceil(Result_.RowCount/DB_Count)
	Gosub NextRows
Return

NextRows:
	counts:=0
	;;DLV.SelectionColors(0xfecd1b)
	if (DB_Page=1||DB_Page>=Ceil(Result_.RowCount/DB_Count)-1)
		LV_Delete()
	loop % DB_Count
	{
		if (Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1]<>""){
			if (DB_Page=1||DB_Page>=Ceil(Result_.RowCount/DB_Count)-1)
				LV_Add(A_Index=1?"Select":"",Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,2],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,3])
			else
				LV_Modify(A_Index, A_Index=1?"Select":"",Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,2],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,3])
		}
/*
		if (Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1]<>""){
			counts:=A_Index
			if !LV_Modify(A_Index, A_Index=1?"Select":"",Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,2],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,3]){
				LV_Add(A_Index=1?"Select":"",Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,2],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,3])
			}
		}else{
			LV_Delete(counts+1)
		}
*/
	}
	if (Ceil(Result_.RowCount/DB_Count)<>1&&DB_Page<Ceil(Result_.RowCount/DB_Count)){
		For k,v In ["nextpage","Lastpage"]
			GuiControl, DB:Enable, %v%
	}else{
		For k,v In ["nextpage","Lastpage"]
			GuiControl, DB:Disable, %v%
	}
	if (DB_Page<2){
		For k,v In ["uppage","Toppage"]
			GuiControl, DB:Disable, %v%
	}else{
		For k,v In ["uppage","Toppage"]
			GuiControl, DB:Enable, %v%
	}
	;GuiControlGet, BUVar, Pos , DB_BU
	SB_SetText(" ❖ " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条 ")
Return

ReadDB:
	;;DLV.SelectionColors(0xfecd1b)
	if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
		SQL:="SELECT aim_chars,A_Key,D_Key FROM ci WHERE C_Key is NULL or D_Key ='0' ORDER BY A_Key,B_Key DESC;"
	else
		SQL:="SELECT aim_chars,A_Key,B_Key FROM ci WHERE C_Key is NULL or B_Key ='0' ORDER BY A_Key,B_Key DESC;"
	if DB.gettable(SQL,Result_){
		loop % DB_Count
		{
			if (Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1]<>"")
				LV_Add(A_Index=1?"Select":"", Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,2],Result_.Rows[A_Index+(DB_Page-1)*DB_Count,3])
		}
	}
	if (Ceil(Result_.RowCount/DB_Count)<>1&&DB_Page<Ceil(Result_.RowCount/DB_Count)){
		For k,v In ["nextpage","Lastpage"]
			GuiControl, DB:Enable, %v%
	}else{
		For k,v In ["nextpage","Lastpage"]
			GuiControl, DB:Disable, %v%
	}
	if (DB_Page<2){
		For k,v In ["uppage","Toppage"]
			GuiControl, DB:Disable, %v%
	}else{
		For k,v In ["uppage","Toppage"]
			GuiControl, DB:Enable, %v%
	}
	;GuiControlGet, BUVar, Pos , DB_BU
	SB_SetText(" ❖ " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条 ")
Return

DB_search:
	GuiControlGet, tVar, DB:Visible , search_text
	if !tVar{
		For k,v In ["search_text","search_1", "DB_Submit"]
			GuiControl, DB:Show, %v%
		For k,v In ["uppage","nextpage","Lastpage","Toppage"]
			GuiControl, DB:Disable, %v%
		ControlFocus , Edit1, A
	}else{
		For k,v In ["search_text","search_1", "DB_Submit"]
			GuiControl, DB:Hide, %v%
		GuiControl,DB:, search_text ,
		GuiControl,DB:, search_1 , 0
		LV_Delete(),ss:=ResultCount:=RCount:=search_1:=0
		Gosub ReadDB
		if (Ceil(Result_.RowCount/DB_Count)<>1&&DB_Page<Ceil(Result_.RowCount/DB_Count)) {
			GuiControl, DB:Enable, nextpage
			GuiControl, DB:Enable, Lastpage
		}else{
			GuiControl, DB:Disable, nextpage
			GuiControl, DB:Disable, Lastpage
		}
		if (DB_Page<2) {
			GuiControl, DB:Disable, uppage
			GuiControl, DB:Disable, Toppage
		}else{
			GuiControl, DB:Enable, uppage
			GuiControl, DB:Enable, Toppage
		}
	}
Return

search_1:
	GuiControlGet, search_1 ,, search_1, CheckBox
	if (search_text<>"")
		Gosub search_result
Return

DB_Submit:
	GuiControlGet, tVar, DB:Visible , search_text
	GuiControlGet, search_text,, search_text, text
	If (search_text<>""&&tVar){
		For k,v In ["uppage","nextpage","Lastpage","Toppage"]
			GuiControl, DB:Disable, %v%
		For k,v In ["search_1"]
			GuiControl, DB:Enable, %v%
		LV_Delete()
		Gosub search_result
	}else if (search_text=""&&tVar){
		For k,v In ["search_1"]
			GuiControl, DB:Disable, %v%
		For k,v In ["uppage","nextpage","Lastpage","Toppage"]
			GuiControl, DB:Enable, %v%
		ss:=0
		LV_Delete()
		Gosub ReadDB
		SB_SetText(" ❖ "  (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条 ")
	}
Return

search_result:
	ss:=0
	;;DLV.SelectionColors(0xC0C0C0)
	if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci"){
		if search_1
			SQL:="SELECT aim_chars,A_Key,D_Key FROM ci WHERE aim_chars LIKE '%" search_text "%' AND D_Key ='0' or A_Key LIKE '%" search_text "%' AND D_Key ='0';"
		else
			SQL:="SELECT aim_chars,A_Key,D_Key FROM ci WHERE aim_chars LIKE '%" search_text "%' AND C_Key is NULL or D_Key ='0' AND aim_chars LIKE '%" search_text "%' or A_Key LIKE '%" search_text "%' AND C_Key is NULL or D_Key ='0' AND A_Key LIKE '%" search_text "%';"
	}else{
		if search_1
			SQL:="SELECT aim_chars,A_Key,B_Key FROM ci WHERE aim_chars LIKE '%" search_text "%' AND B_Key ='0' or A_Key LIKE '%" search_text "%' AND B_Key ='0';"
		else
			SQL:="SELECT aim_chars,A_Key,B_Key FROM ci WHERE aim_chars LIKE '%" search_text "%' AND C_Key is NULL or B_Key ='0' AND aim_chars LIKE '%" search_text "%' or A_Key LIKE '%" search_text "%' AND C_Key is NULL or B_Key ='0' AND A_Key LIKE '%" search_text "%';"
	}
	if DB.gettable(SQL,Results_){
		ss:=1, counts:=0
		if Results_.RowCount>0
			loop % Results_.RowCount
				LV_Add(A_Index=1?"Select":"", Results_.Rows[A_Index,1],Results_.Rows[A_Index,2],Results_.Rows[A_Index,3])
	}
	SB_SetText(" ❖ 共" LV_GetCount() . "条记录")
Return

MyDB:
	if (A_GuiEvent = "RightClick"){
		LV_GetText(pos_name, A_EventInfo)
		if pos_name
			lineInfo:=A_EventInfo
	}else if (A_GuiEvent = "Normal"){
		lineInfo:=A_EventInfo
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, DB:Enable, DB_Delete
				break
			}else{
				GuiControl, DB:Disable, DB_Delete
				break
			}
		}
		LV_GetText(LVars_1, A_EventInfo , 1), LV_GetText(LVars_2, A_EventInfo , 2), LV_GetText(LVars_, A_EventInfo , 3)
		if ss{
			SB_SetText(" ❖ 第 " A_EventInfo " / " LV_GetCount() . " 条记录")
		}else{
			SB_SetText(" ❖ " (DB_Page-1)*DB_Count+A_EventInfo . " / " Result_.RowCount " 条 ")
		}
	}
Return

DB_Delete:
	DelCode()
Return

DelCode(deb =""){
	global Frequency,Prompt_Word,Trad_Mode,Wubi_Schema,DB_Page,DB_Count,Result_,lineInfo, DB_Page, DB_Page,ss
	count:=0
	Loop % (LV_GetCount(),a:=1)
	{	if ( LV_GetNext( 0, "Checked" ) = a )
		{	if ( !deb ){
				LV_GetText(LVar1, a , 1),LV_GetText(LVar2, a , 2),LV_GetText(LVar3, a , 3)
				LV_Delete( a )
				if !ss
					Result_.Rows.RemoveAt((DB_Page-1)*DB_Count+a)
				if (LVar3=0){
					if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
						DB.Exec("UPDATE ci SET D_Key=C_Key WHERE aim_chars ='" LVar1 "';")
					else
						DB.Exec("UPDATE ci SET B_Key=C_Key WHERE aim_chars ='" LVar1 "';")
					count++
				}else{
					DB.Exec("DELETE FROM ci WHERE aim_chars ='" LVar1 "';")
					count++
				}
			}
		}else
			++a
	}
	SB_SetText(" ❖ " (DB_Page-1)*DB_Count+lineInfo . " / " Result_.RowCount-count " 条 ")

}
