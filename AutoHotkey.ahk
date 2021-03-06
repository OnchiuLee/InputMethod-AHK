﻿/*********************************************************************************
   脚本说明： 98五笔多功能版改装自--@河许人@天黑请闭眼联合开发的「影子输入法」与@hello_srf的柚子输入法代码结构
   资源库:https://wubi98.gitee.io/ && http://98wb.ys168.com/
   GitHub:https://github.com/OnchiuLee/AHK-Input-method
;~ 最低环境版本:   Autohotkey v1.1.31
*/
;*********************************************************************************

#NoEnv
#MaxMem 2048
;#NoTrayIcon
#SingleInstance, Force
#MaxThreadsPerHotkey 100
#MaxHotkeysPerInterval 400
#Persistent
#WinActivateForce
#Include %A_ScriptDir%
punctuate:=""""
If (A_AhkVersion < 1.1.31){
	MsgBox, 262452,兼容提示, 当前的AHK启动器低于1.1.31版本，请更换更高版本！,5
	ExitApp
}

full_command_line := RegExReplace(DllCall("GetCommandLine", "str"),punctuate)
If !A_IsAdmin {
	If A_IsCompiled {
		Run *RunAs "%full_command_line%" /restart
		ExitApp
	}else{
		Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	}
}

If FileExist(A_ScriptDir "\main\*_UIA.exe")
	FileDelete,main\*_UIA.exe
If FileExist(A_ScriptDir "\*_UIA.exe")
	FileDelete,*_UIA.exe
If !FileExist(A_Temp "\InputMethodData")
	FileCreateDir,%A_Temp%\InputMethodData

ProgramDir:=A_Is64bitOS?StrReplace(A_ProgramFiles, " (x86)") "\WubiInputMethod":A_ProgramFiles "\WubiInputMethod"
If !FileExist(ProgramDir) {
	FileCreateDir,%ProgramDir%\x64
	FileCreateDir,%ProgramDir%\x86
	FileCreateDir,%ProgramDir%\Font
	FileBitInfo:=FileGetBits(SubStr(A_ScriptName,1,-4) ".exe")   ;判断启动文件是32位还是64位
	If InStr(FileBitInfo,"86") {
		FileCopy, *.exe, %ProgramDir%\x86\*.*
		If A_Is64bitOS
			FileCopy, main\*.exe, %ProgramDir%\x64\*.*
	}else If InStr(FileBitInfo,"64"){
		If A_Is64bitOS
			FileCopy, *.exe, %ProgramDir%\x64\*.*
	}
}

If FileExist(ProgramDir){
	If FileExist("Font\*.otf")&&!FileExist(ProgramDir "\Font\*.otf")
		FileCopy, Font\*.otf, %ProgramDir%\*.otf
	If FileExist(ProgramDir "\*.otf")&&FileExist(ProgramDir "\Font")
		FileMove, %ProgramDir%\*.otf, %ProgramDir%\Font\*.otf
}

BaseDir:=A_Is64bitOS?(FileExist(A_ScriptDir "\main\*.exe")?ProgramDir "\x64":ProgramDir "\x86"):ProgramDir "\x86" 
If FileExist(BaseDir) {
	ProcessName :=RegExReplace(A_AhkPath,".+\\"), count:=count_:=0
	IniRead, UIA, %A_Temp%\InputMethodData\Config.ini, Settings, UIAccess ,0
	Loop, Files, %BaseDir%\*.exe
	{
		count_++
		If (UIA&&InStr(A_LoopFileLongPath,"_UIA")&&!InStr(A_AhkPath,"_UIA")) {
			Run *RunAs "%A_LoopFileLongPath%" /restart "%A_ScriptFullPath%"
			runwait, %ComSpec% /c taskkill /f /IM %ProcessName%, , Hide
			break
		}else If (!UIA&&!InStr(A_LoopFileLongPath,"_UIA")&&A_AhkPath<>A_LoopFileLongPath) {
			Run *RunAs "%A_LoopFileLongPath%" /restart "%A_ScriptFullPath%"
			runwait, %ComSpec% /c taskkill /f /IM %ProcessName%, , Hide
			break
		}else If (UIA&&!InStr(A_LoopFileLongPath,"_UIA")&&!InStr(A_AhkPath,"_UIA")) 
			sPath:=A_LoopFileLongPath, count++
	}
	If (UIA&&count=count_)
		EnableUIAccess(sPath,UIA)
}else
	MsgBox, 262452,权限提示, 当前为非管理员身份运行，首次运行请右击以「管理员身份」运行！,6

;;{{{{{{{{{{{{{{{{主题配色获取
DefaultThemeName:="游驿四"    ;默认的主题配色，主题文件在config\Skins目录
version :="2021011616"
;;--------------------------------------------------------
FileRead, inivar, %A_Temp%\InputMethodData\Config.ini
RegExMatch(inivar,"(?<=ThemeName\=).+",tName)
tName:=tName?tName:(FileExist("Config\Skins\" DefaultThemeName ".json")?DefaultThemeName:"Steam"), ThemeObject:=GetThemeColor(tName)
;;}}}}}}}}}}}}}}}

#Include Config\Lib\Class_Gdip.ahk
#Include Config\Lib\Class_EasyIni.ahk
#Include Config\Lib\Class_LV_Colors.ahk
#Include Config\Lib\Class_SQLiteDB.ahk
#Include Config\Lib\Class_ScrollGUI.ahk
#Include Config\Lib\Class_ToolTip.ahk
#Include Config\Lib\Class_Toolbar.ahk
#Include Config\Lib\Class_Json.ahk
#Include Config\Lib\Class_LV_InCellEdit.ahk
#Include Config\Lib\Class_CtlColors.ahk
#Include Config\Lib\Class_ImageButton.ahk
#Include Config\Lib\Class_OD_Colors.ahk
#Include Config\Lib\Class_WinClipAPI.ahk
#Include Config\Lib\Class_WinClip.ahk
#Include Config\Script\Function.ahk
#Include Config\Script\Sql_Func.ahk
SendMode Input
SetBatchLines, -1
SetKeyDelay, 30, 0
SetTitleMatchMode, RegEx
Process, Priority,, High
CoordMode, Caret, Screen
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
OnMessage(0x204, "WM_RBUTTONDOWN")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x200, "WM_MOUSEMOVE")
;OnMessage(0x020a, "WM_MOUSEWHEEL")
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
DetectHiddenText, On
WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
y2 :=A_ScreenHeight-Shell_Wnd-40, font_:=ComInfo.GetDefaultFontName(), font_:=font_?font_:"Microsoft YaHei UI"
DllCall("gdi32\EnumFontFamilies","uint",DllCall("GetDC","uint",0),"uint",0,"uint",RegisterCallback("EnumFontFamilies"),"uint",A_FontList:="")
Startup_Name :="五笔98版", FontExtend:="98WB-U|98WB-V|98WB-P0|五笔拆字字根字体|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_

Loop Files, config\Skins\logoStyle\*.icl
	if (A_LoopFileName&&a_index=1)
		StyleName:=SubStr(A_LoopFileName,1,-4)

;{{{{{读取配置及配置检测
If (!FileExist(A_Temp "\InputMethodData\Config.ini")||A_Args[1]="Initialize")
	status:=1

global srf_default_value,config_tip, WubiIni:=class_EasyIni(A_Temp "\InputMethodData\Config.ini")
, srf_default_obj:={LogoColor:{LogoColor_cn:"008000",LogoColor_en:"00FFFF",LogoColor_caps:"0000ff"}
	,Settings:{Startup:"off",IStatus:1,CharFliter:0,Exit_switch:1,PromptChar:0, DPIScale:1,CursorStatus:0,Exit_hotkey:"^esc", symb_mode:2,Frequency:0,StrockeKey:"h|s|p|n|z"
		,Freq_Count:3,srfTool:0,length_code:"on",GzType:0, BUyaml:0, s2t_swtich:1,FocusStyle:1,PageShow:1, s2t_hotkey:"^+f",versions:version,EnKeyboardMode:0, ChoiceItems:2
		, cf_swtich:1, cf_hotkey:"^+h", Prompt_Word:"off", Logo_X:"10", Logo_Y:A_ScreenHeight/2, UIAccess:0, Addcode_switch:1, Addcode_hotkey:"^CapsLock", InitiaMode:0
		, Suspend_switch:1,zkey_mode:0, Suspend_hotkey:"!z", tip_hotkey:"!q", rlk_switch:0, Logo_Switch:"on",Srf_Hotkey:"Shift", Select_Enter:"clean", TurnPage:2
		, symb_send:"on", set_color:"on", Wubi_Schema:"ci", Initial_Mode:"off",Cut_Mode:"off", limit_code:"on", Trad_Mode:"off", IMEmode:"on",InitStatus:0,EN_Mode:0}
	, TipStyle:{ThemeName:DefaultThemeName, StyleN:StyleName,Logo_ExStyle:0,transparentX:180,LogoSize:36, FontType:font_, FontSize:22, FontColor:ThemeObject["FontColor"],FocusBackColor:ThemeObject["FocusBackColor"]
		,FocusColor:ThemeObject["FocusColor"],FocusCodeColor:ThemeObject["FocusCodeColor"],FocusRadius:5, FontStyle:"off", FontCodeColor:ThemeObject["FontCodeColor"],LineColor:ThemeObject["LineColor"],BorderColor:ThemeObject["BorderColor"]
		, Gdip_Line:"off", ToolTipStyle:"Gdip", Radius:"off", BgColor:ThemeObject["BgColor"], ListNum:5,Gdip_Radius:5, EnFontName:font_, Textdirection:"horizontal", Set_Range:3
		, Fix_Switch:"off",Fix_X:A_ScreenWidth/2,Fix_Y:10}  ;竖排--vertical
	, CustomColors:{Color_Row1:"0x1C7399,0xEEEEEC,0x014E8B,0x444444,0x009FE8,0xDEF9FA,0xF8B62D,0x90FC0F", Color_Row2:"0x0078D7,0x0D1B0A,0xB9D497,0x00ADEF,0x1778BF,0xFDF6E3,0x002B36,0xDEDEDE"}}
;初始化默认配置
if (FileExist(A_ScriptDir "\Sync\Default.json")&&!status) {
	srf_default_value:=Json_FileToObj(A_ScriptDir "\Sync\Default.json")
	For Section, element In srf_default_obj
	{
		For key,value In element
		{
			if (!Array_ValueNotEmpty(srf_default_value, key)&&WubiIni[Section,key]=""){
				%key%:=WubiIni[Section,key]:=srf_default_value[Section,key]:= srf_default_obj[Section,key]
			}else if (!Array_ValueNotEmpty(srf_default_value, key)&&WubiIni[Section,key]<>"")
				%key%:=srf_default_value[Section,key]:=WubiIni[Section,key]
			else if (Array_ValueNotEmpty(srf_default_value, key)&&WubiIni[Section,key]=""&&key<>"FontType")
				%key%:=WubiIni[Section,key]:=srf_default_value[Section,key]
		}
	}
}else{
	srf_default_value:=srf_default_obj
}

;默认配置检测
For Section, element In srf_default_value
	For key, value In element
		If ((%key%:=WubiIni[Section, key])="")
			%key%:=WubiIni[Section, key]:=value

LWidth:=A_ScreenWidth-LogoSize, LHeight:=A_ScreenHeight-LogoSize
If Logo_X not between 0 and %LWidth%
	Logo_X :=WubiIni.Settings["Logo_X"]:=20
If Logo_X not between 0 and %LHeight%
	Logo_Y :=WubiIni.Settings["Logo_Y"]:=A_ScreenHeight/2
if not Wubi_Schema ~="i)ci|zi|chaoji|zg"
	Wubi_Schema :=WubiIni.Settings["Wubi_Schema"]:="ci"

versions :=WubiIni.Settings["versions"]:=version

if !WubiIni.GetTopComments()
	WubiIni.AddTopComment("程序运行时，配置文件直接修改无效！退出后修改才有效！！！")

/*
;;===================================配置项说明===================
config_tip:={LogoColor:{LogoColor_cn:"桌面色块中文状态颜色",LogoColor_en:"桌面色块英文状态颜色",LogoColor_caps:"桌面色块大写状态颜色"}
	,Settings:{Startup:"开机自启设置<on为建立系统计划任务实现自启/off为关闭开机自启/sc为在系统自启目录建立快捷方式实现自启>", versions:"版本日期",zkey_mode:"z键设定万能键与拼音反查"
			, CharFliter:"单字方案GB2312过滤",IStatus:"窗口程序输入状态配置开关",Exit_switch:"快捷退出快捷键启用开关",PromptChar:"逐码提示",EnKeyboardMode:"启动时切换到英语键盘模式开关项"
			, Exit_hotkey:"快捷退出快捷键",BUyaml:"导出文件为yaml格式文件，需要文件头支持才能导出",Frequency:"动态调频〔只对含词方案有效〕"
			, Freq_Count:"调频参数〔词条上屏次数〕",FocusStyle:"焦点候选样式<1为启用,反之>",EN_Mode:"英文模式",srfTool:"输入法指示条独立显示"
			, PageShow:"候选框页数显示", s2t_swtich:"简繁模式切换开关", s2t_hotkey:"简繁模式切换功能快捷键", cf_swtich:"拆分显示功能开关", CursorStatus:"工型光标为中文状态，反之"
			, cf_hotkey:"字根拆分快捷键", UIAccess:"候选框UI层级权限提升,1为开启 0为关闭", Addcode_switch:"批量造词开关<1为开启,0为关闭>"
			, Addcode_hotkey:"批量造词热键设置", Suspend_switch:"脚本挂起启用开关<1为开启,0为关闭>", Suspend_hotkey:"脚本挂起启用快捷键设置"
			, tip_hotkey:"划词反查快捷键设置", rlk_switch:"划词反查开关<1为开启,0为关闭>", symb_mode:"中英文符号模式，1为英文 2为中文", DPIScale:"指示器放大"
			, Prompt_Word:"空码提示设置<on/off>",Srf_Hotkey:"中英文切换热键", Logo_X:"输入法logo图标x坐标", Logo_Y:"输入法logo图标y坐标"
			, Logo_Switch:"logo图标显示与隐藏<on/off>", Select_Enter:"回车键功能定义<send为上屏编码/clean为清空编码>", Initial_Mode:"剪切板上屏开关<on/off>"
			, symb_send:"符号顶屏开关<on/off>", set_color:"取色开关", Wubi_Schema:"方案设置项<ci为含词方案/zi为单字方案/chaoji为超集方案/zg为字根单打方案>"
			,Cut_Mode:"字根拆分开关<on/off>", limit_code:"四码上屏开关<on/off>", Trad_Mode:"简繁模式切换<on为繁体/off为简体>", IMEmode:"中英文状态<on为中文/off为英文>"}
	, TipStyle:{ThemeName:"主题名称",StyleN:"logo样式编号",transparentX:"Logo透明值「0-255」",Logo_ExStyle:"Logo鼠标穿透开关",LogoSize:"Logo尺寸大小",FontType:"候选字体设置"
			,FontStyle:"候选词粗体开关",FocusBackColor:"候选框焦点背景颜色",FocusCodeColor:"候选框编码项背景",FocusColor:"候选框焦点字体颜色",FocusRadius:"焦点候选项圆角"
			, FontSize:"候选字号大小设置", FontColor:"候选项颜色", FontCodeColor:"候选编码颜色",BorderColor:"候选框边框线",LineColor:"候选分割线选色", Gdip_Line:"Gdip候选框样式边框及候选框编码与候选词分隔线"
			, ToolTipStyle:"候选框风格<on为tooltip样式/off为Gui候选样式/Gdip为Gdip候选样式>", Radius:"Gdip候选样式圆角开关<on/off>",Gdip_Radius:"Gdip候选框圆角大小", BgColor:"候选框背景色<16进制色值>"
			, ListNum:"候选数量", Textdirection:"horizontal为横排/vertical为竖排", Set_Range:"ToolTip样式编码与候选词距离", Fix_Switch:"候选框固定开关",Fix_X:"候选框固定x坐标",Fix_Y:"候选框固定y坐标"}
	, CustomColors:{Color_Row1:"配色对话框自定义颜色区域，第一排", Color_Row2:"配色对话框自定义颜色区域，第二排"}}

;配置项说明项写入
FileRead, ini_var, %A_Temp%\InputMethodData\Config.ini
For Section, element In config_tip
	For Comments, value In element
		If !WubiIni.GetKeyComments(Section, Comments)
			If ini_var not contains Comments
				WubiIni.AddKeyComment(Section, Comments, value)
;;======================================================
*/
Gosub IsGdipline
WubiIni.Save()
;}}}}}

Gosub TRAY_Menu
if FileExist(A_ScriptDir "\*.ico") {
	Loop,Files,*.ico
		If (A_LoopFileLongPath&&a_index=1)
			IconName_:=A_LoopFileLongPath   ;获取主目录第一个ico图标名称作为托盘图标
	Menu, Tray, Icon, %IconName_%
}else
	Menu, Tray, Icon, config\WubiIME.icl,30

srf_mode :=IMEmode~="off"?0:1
;;=======================装载字体=========================

If FileExist(ProgramDir "\*.otf")||FileExist(ProgramDir "\Font\*.otf") {
	;;Traytip,,正在检测并载入字体...
	Loop,Files,% FileExist(ProgramDir "\Font")?ProgramDir "\Font\*.otf":ProgramDir "\*.otf"
		If GetFontNamesFromFile(A_LoopFileLongPath)["family"]~="(^" a_FontList ")"
			AddFontResource(A_LoopFileLongPath)
}

if (!InitStatus) {
	;;Run, rundll32.exe "%A_ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll"`, ImageView_Fullscreen %A_ScriptDir%\config\ReadMe.png,, UseErrorLevel
	Run, http://98wb.ys168.com/,, UseErrorLevel
	if (ErrorLevel = "ERROR") {
		Run, iexplore.exe "98wb.ys168.com/",, UseErrorLevel
	}
	InitStatus:=WubiIni.Settings["InitStatus"]:=1, WubiIni.Save()
	If FileExist(ProgramDir "\*.otf")||FileExist(ProgramDir "\Font\*.otf")
		FontType:=WubiIni.TipStyle["FontType"]:="98WB-0",EnFontName:=WubiIni.TipStyle["EnFontName"]:="Andrich", WubiIni.Save()
	Gosub OnHelp
}
if (ToolTipStyle ~="i)gdip"&&A_OSVersion ~="i)WIN_XP") {
	;Traytip,,你的系统不支持当前Gdip候选框样式,请切换!,,2
	ToolTipStyle:=WubiIni.TipStyle["ToolTipStyle"]:="on", FontSize:=WubiIni.Settings["FontSize"]:=16, WubiIni.Save()
}

;{{{{{快捷键注册
HotkeyRegister()
;}}}}}

;{{{{{SQlite类创建,db文件读取
DBFileName:=A_ScriptDir "\DB\WubiCiku.db", ExtendDBName:=A_ScriptDir "\Config\ExtendData.db"
If FileExist("DB\wubi*.7z")&&!FileExist("DB\WubiCiku.7z")   ;;处理7z压缩包
	FileMove, DB\wubi*.7z, DB\WubiCiku.7z,1
If !FileExist(DBFileName)&&FileExist("DB\WubiCiku.7z")
	Un7Zip(A_ScriptDir "\DB\WubiCiku.7z",A_ScriptDir "\DB\")

If FileExist("DB\wubi*.zip")&&!FileExist("DB\WubiCiku.zip")   ;;处理zip压缩包
	FileMove, DB\wubi*.zip, DB\WubiCiku.zip,1
If !FileExist(DBFileName)&&FileExist("DB\WubiCiku.zip")
	Un7Zip(A_ScriptDir "\DB\WubiCiku.zip",A_ScriptDir "\DB\")

If FileExist("DB\wubi*.db")&&!FileExist(DBFileName)
	FileMove, DB\wubi*.db, DB\WubiCiku.db,1

If FileExist("DB\wubi*.rar")&&!FileExist(DBFileName)
	MsgBox, 262160, 错误警告,不支持RAR压缩格式自动解压，请手动释放「 WubiCiku.db 」,15
If !FileExist(DBFileName)&&FileExist("DB\WubiCiku.zip")||!FileExist(DBFileName)&&FileExist("DB\WubiCiku.7z")
	MsgBox, 262160, 错误警告, %DBFileName%不存在或解压失败导致DB目录词库错误！请自行解压, 15

If (DB._Handle)
	DB.CloseDB()
global DB := New SQLiteDB
If !DB.OpenDB(DBFileName)
	MsgBox, 16, 数据库DB错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
DB.AttachDB(ExtendDBName, "extend")

Gosub Backup_CustomDB

If FileExist("Config\6763字频表.txt") {
	DB.GetTable("PRAGMA table_info('GBChars');",Result)
	if (Result.RowCount<3) {
		SQL =DROP TABLE IF EXISTS 'extend'.'GBChars';CREATE TABLE 'extend'.'GBChars' ("Rid" int PRIMARY KEY NOT NULL, "Chars" TEXT, "weight" TEXT);
		DB.Exec(SQL)
		FileRead,Chars,Config\6763字频表.txt
		Loop,parse,Chars,`n,`r
		{
			If A_LoopField
				CharsArr:=StrSplit(A_LoopField,"`t"), __Chars .="('" a_index "','" CharsArr[1] "','" CharsArr[2] "')" ","
		}
		DB.Exec("INSERT INTO 'extend'.'GBChars' VALUES" RegExReplace(__Chars,"\,$") "")
	}
	__Chars:=Chars:="",CharsArr:=[]
}

;;=======================================

For key,value In ["GBChars","s2t","PY","label","label_init","TangSongPoetics","symbols"]
{
	DB.GetTable("select count(*) from sqlite_master where type='table' and name = '" value "';",Result)
	If Result.Rows[1,1] {
		Progress, M ZH-1 ZW-1 Y100 FM11 W420 C0 FM14 WS700 CTffffff CW0078d7,, 正在转移<%value%>词库数据，请稍候。。。, 词库检查 [ %key%/7 ]
		OnMessage(0x201, "MoveProgress")
		if DB.Exec("DROP TABLE 'extend'.'" value "';VACUUM")>0
			DB.Exec("create table 'extend'.'" value "' as select * from 'main'.'" value "';DROP TABLE 'main'.'" value "';VACUUM")
	}
}
Progress,off

If EnKeyboardMode
	SwitchToEngIME()

;PrintObjects(WubiIni)
;{{常用变量值初始化
global Carets:={}
global code_status:=localpos:=srfCounts:=select_pos:=1
global valueindex:=Cut_Mode?2:1
global waitnum:=select_sym:=PosLimit:=PosIndex:=InitSetting:=0
Select_Code=gfdsahjklm;'space           ;字母选词
global num__:=Result_Char:=Select_result :=selectallvalue:=ID_Cursor:=""
global recent:=select_arr:=select_value_arr:=srf_bianma:=add_Array:=add_Result:=Split_code:=labelObj:=[]
;}}

CharsTotalCount:=Json_FileToObj(A_Temp "\InputMethodData\CharacterCount.json"),CharsTotalCount:=ObjCount(CharsTotalCount)?CharsTotalCount:{}
, CharsTotalCount["UnitName"]:=CharsTotalCount["UnitName"]?CharsTotalCount["UnitName"]:Chr(0x4e0a) Chr(0x5c4f) Chr(0x7edf) Chr(0x8ba1)
, CharsTotalCount["Count"]:=SubStr(A_Now,1,8)<>SubStr(CharsTotalCount["Time"],1,8)?0:CharsTotalCount["Count"], CharsTotalCount["Time"]:=SubStr(A_Now,1,8)<>SubStr(CharsTotalCount["Time"],1,8)?A_Now:CharsTotalCount["Time"]
, InputCount:=CharsTotalCount["Count"], Frequency_obj:=Json_FileToObj(A_ScriptDir "\Config\Script\WubiCiku.json"), Frequency_obj:=ObjCount(Frequency_obj)?Frequency_obj:{}

;常用的符号列表（供选择用）
SymObiect:=[[["中文逗号", "，"], ["中文句号", "。"],["中文问号", "？"],["中文感叹号", "！"],["中文冒号", "："],["中文分号", "；"],["中文顿号", "、"],["水平省略号", "…"],["波浪线", "~"],["连接符", "&"],["邮箱符", "@"],["数字标记", "#"]]
	,[["英文逗号", ","],["英文句号", "."],["英文问号", "?"],["英文感叹号", "!"],["英文冒号", ":"],["英文分号", "`;"],["省略号", "……"],["全角波浪线", "～"],["全角连接符", "＆"],["全角邮箱符", "＠"],["全角数字标记", "＃"],["点", "·"]]
	,[["中文双引号", "“”"],["中文单引号", "‘’"],["中文双引号" ,"〝〞"],["英文半角双引号" ,""""],["英文半角单引号" ,"''"],["英文全角双引号" ,"＂"],["英文全角号" ,"＇"],["半角撇号" ,"´"],["全角撇号" ,"＇"]]
	,[["中文圆括号", "（）"],["实心括号", "【】"],["中文书名号", "《》"],["全角尖括号", "＜＞"],["半角龟壳型括号", "﹝﹞"],["英文尖括号", "<>"]]
	,[["英文圆括号", "()"],["英文方括号", "`[`]"],["双尖括号", "«»"],["尖括号", "‹›"],["全角龟壳型括号", "〔〕"],["单书名号", "〈〉"],["大括号", "`{`}"],["全角方括号", "［］"],["角括号", "「」"],["全角花括号", "｛｝"],["空心括号", "〖〗"],["空心角括号", "『』"]]
	,[["垂直上圆括号", "︵"],["垂直上花括号", "︷"],["垂直上龟壳型括号", "︹"],["垂直上尖括号", "︿"],["垂直上双尖括号", "︽"],["垂直上角括号", "﹁"],["垂直上空心角括号", "﹃"],["垂直上实心括号", "︻"],["垂直上空心括号", "︗"],["斜线", "/"],["竖线", "|"],["反斜线", "\"]]
	,[["垂直下圆括号", "︶"],["垂直下花括号", "︸"],["垂直下龟壳型括号", "︺"],["垂直下尖括号", "﹀"],["垂直下双尖括号", "︾"],["垂直下角括号", "﹂"],["垂直下空心角括号", "﹄"],["垂直下实心括号", "︼"],["垂直下空心括号", "︘"],["全角斜线", "／"],["全角竖线", "｜"],["全角反斜线", "＼"]]]
SymObiect.Insert([["全角上横线", "¯"],["全角上横线", "￣"],["波浪上横线", "﹋"],["虚线上横线", "﹉"],["中心线上横线", "﹊"],["全角抑音符", "ˋ"],["波形竖线", "︴"],["倒问号", "¿"],["抑扬符", "ˇ"],["下横线", "_"],["全角下横线", "＿"],["波浪下横线", "﹏"],["虚线下横线", "﹍"],["中心线下横线", "﹎"],["抑音符", "``"],["间段条", "¦"],["倒感叹号", "¡"],["扬抑符", "^"],["连字符", "­"],["分音符", "¨"],["锐音符", "ˊ"]])

;中英标点符号初始化映射
Default_symblos:={"``":["``","·"], "~":["~","～"], "`!":["+1","！"], "@":["@","@"], "#":["#","#"]
	, "$":["$","￥"], "%":["`%","`%"], "`^":["+6","……"], "&":["&","&"], "*":["*","*"], "(":["(","（）{Left}"]
	, ")":[")","）"], "-":["-","-"], "=":["=","="], "[":["[","「"], "]":["]","」"]
	, "{":["+[","【】{Left}"], "}":["+]","】"], "\":["\","、"], "|":["|","|"], "`;":["`;","；"], ":":[":","："]
	, "'":["'","‘’{left}"], "<":["<","《》{Left}"],">":[">","》"],",":[",","，"]
	,".":[".","。"], "/":["/","/"], "?":["?","？"], """":["""""{Left}","“”{left}"]}
If !FileExist("Sync\srf_symblos.json") {
	Json_ObjToFile(Default_symblos, "Sync\srf_symblos.json"), srf_symblos:=Default_symblos
}else{
	srf_symblos:=Json_FileToObj("Sync\srf_symblos.json")
	For Section,element In srf_symblos
		For key,value In element
			If (value="")
				srf_symblos[Section,key]:=Default_symblos[Section,key], Json_ObjToFile(srf_symblos, "Sync\srf_symblos.json")
}

WM_LBUTTONDOWN(){
	global Wubi_Schema, ToolTipStyle, FocusStyle, PosIndex, srfTool
	PosIndex:=0
	if (A_Gui="TSF"&&Wubi_Schema~="i)ci"&&ToolTipStyle~="i)Gdip"&&FocusStyle){
		mousegetpos, FX, FY
		PosIndex := TSFCheckClickPos(FX,FY)
		if (PosIndex>0)
		{
			srf_select(PosIndex)
		}
	}
	if (!srfTool&&A_Gui ="SrfTip"||srfTool&&A_Gui="logo"){
		PostMessage, 0xA1, 2
		Gosub Write_Pos
	}
}

WM_RBUTTONDOWN(){
	global Wubi_Schema, ToolTipStyle, FocusStyle, PosIndex, srf_for_select_Array, Trad_Mode, Prompt_Word, StyleN
		, srf_all_input, ListNum, TPosObj, waitnum, Logo_X, Logo_Y, Tip1hWnd, Tip2hWnd, Cut_Mode
	PosIndex:=0
	If (A_Gui="logo"||A_Gui="SrfTip"||A_Gui="TSF"&&!FocusStyle||A_Gui="houxuankuang"||Hex_Dec(WinExist("A"))=Tip2hWnd||A_Gui="TSF"&&not Wubi_Schema~="i)ci"&&FocusStyle||A_Gui="TSF"&&Trad_Mode~="i)on"||A_Gui="TSF"&&Prompt_Word~="i)on"){
		Menu, TRAY, Show
	}
	if (A_Gui="TSF"&&Wubi_Schema~="i)ci"&&ToolTipStyle~="i)Gdip"&&FocusStyle&&srf_all_input~="^[a-y]+"&&Prompt_Word~="i)off"&&Trad_Mode~="i)off"){
		mousegetpos, FX, FY
		PosIndex := TSFCheckClickPos(FX,FY)
		if (PosIndex>0&&PosIndex<ListNum+1)
		{
			Menu, selectmenu, Add, 置顶词条, set_top   ; +Break
			Menu, selectmenu, Icon, 置顶词条, config\WubiIME.icl, 36
			Menu, selectmenu, Add, 上屏拆分, SendAttachChars
			Menu, selectmenu, Icon, 上屏拆分,config\Skins\logoStyle\%StyleN%.icl,9
			Menu, selectmenu, Add, 前移一位, set_add   ; +Break
			Menu, selectmenu, Icon, 前移一位, config\WubiIME.icl, 37
			if ((PosIndex+ListNum*waitnum)=1){
				Menu, selectmenu, Disable, 置顶词条
				Menu, selectmenu, Disable, 前移一位
			}else{
				Menu, selectmenu, Enable, 置顶词条
				Menu, selectmenu, Enable, 前移一位
			}
			Menu, selectmenu, Add, 后移一位, set_next   ; +Break
			Menu, selectmenu, Icon, 后移一位, config\WubiIME.icl, 38
			if (srf_for_select_Array.length()=(PosIndex+ListNum*waitnum))
				Menu, selectmenu, Disable, 后移一位
			else
				Menu, selectmenu, Enable, 后移一位
			Menu, selectmenu, Add, 删除词条, Delete_Word   ; +Break
			Menu, selectmenu, Icon, 删除词条, config\WubiIME.icl, 39
			Menu, selectmenu, color, ffffff
			Menu, selectmenu, Show
		}else{
			Menu, TRAY, Show
		}
	}
}

/*
WM_MOUSEWHEEL(){
	if A_GuiControl in select_theme,FontType,font_size,set_select_value,set_regulate,set_GdipRadius,set_FocusRadius_value,sChoice4,SBA4,sChoice1,sChoice2,sChoice3, 
		Return
}
*/

WM_MOUSEMOVE()
{
	global Logo_X, Logo_Y, SrfTip_Width, SrfTip_Height, Logo_ExStyle, StrockeKey, transparentX, LogoSize, srfTool, Tip_Show:={LineColor:"Gdip样式中间分隔线颜色",SBA6:"符号顶首选屏并上屏该键符号",font_value:"候选字号大小`n范围[9-40]"
		,BorderColor : "Gdip样式四周边框线颜色", SBA16:"冻结/启用程序快捷键启用开关", SBA15:"鼠标划词反查编码功能启用开关", UIAccess:"候选框UI层级权限提升`n看不到候选框时开启",font_size:"候选字号大小`n范围[9-40]",sethotkey_4:"默认为程序自带热键设置方法可设置的热键有限`n点击「获取键名」可以自定义获取键名"
		, SBA0 :"候选框固定坐标设置",About:"软件使用说明",ciku3:"英文词库导入`n（单行单义格式，以tab符隔开）`n「英文词条+Tab+词频」",ciku4:"英文词库导出`n（导出为单行单义格式txt码表）", Cursor_Status:"在不同窗口情况下鼠标为‘工’字形时自动切换至中文状态，反之"
		,ciku5:"特殊符号词库导入`n（格式「/引导字母+Tab+多符号以英文逗号隔开」）", SBA5 : "取消为固定候选框的位置，不跟随光标",BgColor:"候选框背景色",FocusBackColor:"候选框焦点选项背景色", GzType:"农历干支输出默认以「春节」为生肖年开始`n选中后切换到以「立春」为换算起点。"
		,FocusColor:"候选框焦点选项字体色", FontColor:"候选词字体颜色", FontCodeColor:"候选框编码字体颜色", SBA1:"繁体开关（输简出繁）快捷键启用开关",select_value:"候选框词条显示数目`n范围[3-10]", SBA18:"当前笔画键位为：" StrockeKey, zKeySet:"Z键引导反查方式"
		, SBA4:"加入开机自启动任务：「`non＝>为建立系统计划任务实现自启`noff＝>为关闭开机自启`nsc＝>为在系统自启目录建立快捷方式实现自启」`n计划任务自启成功率不高，建议开启建立「快捷方式自启」的自启方式",ciku6:"特殊符号词库导出`n（导出为txt）",set_GdipRadius:"Gdip候选框圆角大小`n范围[0-15]"
		,tip_hotkey:"通过快捷键开关划词反查",SizeValue:"桌面色块尺寸`n范围[1-150]",SBA20:"候选框分页数显示",FontIN:"字根拆分字体安装",set_regulate_Hx:"ToolTip候选框编码框`n与选词框距离范围[3-25)]",FontType:"中文方案显示的字体",FontSelect:"英文方案或临时英文显示的字体"
		, SBA13:"显示/隐藏桌面色块图标",SBA19:"有焦点色块选项的候选框",SetInput_CNMode:"程序启动时默认中文输入模式",SetInput_ENMode:"程序启动时默认英文输入模式", SBA12 : "候选词显示粗体",SBA26:"四码候选唯一时自动上屏", Control0:"直接显示中性键，不分左右（例如LShift）"
		,ciku1:"导入txt词库至数据库`ntxt码表格式需为「单行单义」",ciku2:"导出词库为「单行单义」的txt格式文本",SBA2:"拆分功能快捷键启用开关`n（需特殊字体支持，字体在本程序Font目录）",GdipRadius:"Gdip候选框圆角大小`n范围[0-15]"
		,sethotkey_2:"开启获取取键名模式",InputStatus:"窗口程序输入状态配置，切换窗口有效！",set_SizeValue:"桌面色块尺寸`n范围[1-150]", vset_regulate:"ToolTip候选框编码框`n与选词框距离范围[3-25]",SBA28:"启动时切换到英语键盘模式"
		,set_FocusRadius:"焦点候选框焦点项背景圆角`n范围[0-18]",set_FocusRadius_value:"焦点候选框焦点项背景圆角`n范围[0-18]", SBA3:"当编码无词条时模糊匹配提示",SBA7:"五码时顶首选上屏", InitiaMode:"剪切板模式1：不影响剪切板本身数据。`n剪切板模式2：剪切板本身数据会被冲掉。`n-----------------------------------------`n选中切换到模式2，反之"
		,SBA9:"Gdip候选框圆角开关",SBA10:"Gdip候选样式中间分隔线",yaml_:"导出词库为yaml格式可直接应用于rime平台，`n需Sync目录有header.txt文件头支持",search_1:"〔 词频为0的为主词库已删除的，勾选删除即恢复！ 〕"
		,IM_DDL:"此处选择你要更改的内容",WinMode:"设置每个有窗口进程的输入状态与上屏方式",SBA22:"程序退出快捷键启用开关",Exit_hotkey:"程序退出操作快捷键",SBA23:"GB2312字集过滤", showtools:"独立显示指示功能条，不显示色块"
		,set_select_value:"候选框词条显示数目`n范围[3-10]", Save:"格式：“纯中文词条”或者“编码=词条”",SrfSlider:"当前透明值为：" transparentX,LogoColor_cn:"中文状态色块颜色",LogoColor_en:"英文状态色块颜色",LogoColor_caps:"大写状态色块颜色"
		,Frequency:"自动根据每个词条的输入频率进行顺序调整",set_Frequency:"设置词条的输入频率值来进行置顶调整",CreateSC:"建立桌面快捷启动图标",ExSty:"使鼠标穿透过色块，不影响正常操作`n开启后无法对色块进行操作", SBA27:"设置类似/week快速输出日期时间的格式"
		,AddProcess:"窗口切换有效,在同窗口时没有任何效果!`n添加进程名时,鼠标放在指定的窗口上,按下左Ctrl执行添加`n,20秒内无操作,自动添加当前鼠标所在窗口的进程.",SBA17:"批量造词快捷键启用开关",helpico:"查看时间格式说明"
		,ciku10:"汉字读音文件导入`n〔文本格式：单字+Tab+拼音〕",ciku11:"拼音文件导出为单行单义格式", addFiles:"文本中词条格式为：“纯中文词条“ 或者 ”编码=词条”`n多个词组以行隔开！",SBA25:"勾选切换至英文输入模式"
		,ShowSymList:"提供选择常用的标点符号，成对的标点`n光标居中效果清追加{left}",HL:"标点符号修改开关",DPISty:"桌面输入法指示器启用跟随系统DPI缩放",RestDB:"重置「含词」词库词频为初始状态",SBA21:"修改标点符号映射"}

	static CurRControl, PrevControl
	CurRControl := A_GuiControl
	if (CurRControl <> PrevControl and not InStr(CurRControl, " "))
	{
		ToolTip ; 关闭之前的 ToolTip.
		SetTimer, DisplayToolTip, 500
		PrevControl := CurRControl
	}

	SetTimer, Tip_timer, 1000
	Tip_timer:
		;aero_link:="C:\Windows\Cursors\aero_link.cur" ;小手
		;aero_arrow_l:="C:\Windows\Cursors\aero_arrow_l.cur" ;箭头
		if (A_GuiControl~="i)nextpage|uppage|MyDB|Lastpage|Toppage|Pics2|Pics3|Pics4|MoveGui|helpico|tip_text"){  ;&&FileExist(aero_link)
			;CursorHandle := DllCall( "LoadCursorFromFile", Str,aero_link )
			;DllCall( "SetSystemCursor", Uint,CursorHandle, Int,32512 )
			SetSystemCursor( "IDC_HAND" )
		}else{
			;DllCall( "SystemParametersInfo", UInt,0x57, UInt,0, UInt,0, UInt,0 )
			RestoreCursors()
		}
	Return

	DisplayToolTip:
		SetTimer, DisplayToolTip, Off
		;MouseGetPos, xpos, ypos
		ToolTip % Tip_Show[CurRControl]
		SetTimer, RMToolTip, 5000
	return

	RMToolTip:
		SetTimer, RMToolTip, Off
		ToolTip
	return
}
DefaultDate:={week:["公元年月日-周 周数"], time:["yyyy-MM-dd HH:mm:ss"],nl:["lnlylrls","干支"],date:["中文格式"]}, JsonData_Date:=Json_FileToObj(A_ScriptDir "\Sync\JsonData_Date.json")
if !ObjCount(JsonData_Date) {
	JsonData_Date:=DefaultDate, Json_ObjToFile(JsonData_Date, A_ScriptDir "\Sync\JsonData_Date.json", "UTF-8")
}
;{{{{{{应用状态管理{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{
DefaultModeData:={CN:["QQ.exe"],EN:["Notepad.exe"],CLIP:["Notepad.exe"]}
InputModeData:=Json_FileToObj(A_ScriptDir "\Sync\InputMode.json"), InputModeData:=ObjCount(InputModeData)?InputModeData:DefaultModeData

;;监控消息回调ShellIMEMessage监控窗口变化
Gui +LastFound
DllCall( "RegisterShellHookWindow", UInt,WinExist() )
OnMessage( DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" ), "ShellIMEMessage")
ShellIMEMessage( wParam,lParam ) {
	/*    wParam参数：
		;1 顶级窗体被创建 	;2 顶级窗体即将被关闭 	;54 退出全屏	;32772 窗口切换
		;3 SHELL 的主窗体将被激活 	;4 顶级窗体被激活 	;&H8000& 掩码 	;53 全屏
		;5 顶级窗体被最大化或最小化 	;6 Windows 任务栏被刷新，也可以理解成标题变更
		;7 任务列表的内容被选中 	;8 中英文切换或输入法切换 	;13 wParam=被替换的顶级窗口的hWnd 
		;9 显示系统菜单 	;10 顶级窗体被强制关闭 	;14 wParam=替换顶级窗口的窗口hWnd
		;12 没有被程序处理的APPCOMMAND。见WM_APPCOMMAND
	*/
	global srf_mode, InputModeData, Initial_Mode, WubiIni,StyleN,IStatus, program, IMEmode ,CursorStatus, versions, GzType, SchemaType
		, Startup_Name, Logo_X, Logo_Y, SrfTip_Width, SrfTip_Height, Logo_ExStyle, srf_all_input, ID_Cursor, Logo_Switch, InputCount
		
	If (wParam~="^(1|2|3|4|5|7|8|9|10|12|53|54|32772)$"&&IStatus) {
		WinGet, WinEXE, ProcessName , ahk_id %lParam%
		WinGetclass, WinClass, ahk_id %lParam%
		;WinActivate,ahk_class %WinClass%
		If (Array_isInValue(InputModeData["CN"], WinEXE)&&!srf_mode)
		{
			srf_mode:=1
			If Logo_Switch~="i)on"
				Gosub RestLogo
		}else If (Array_isInValue(InputModeData["EN"], WinEXE)&&srf_mode){
			srf_mode:=0
			If Logo_Switch~="i)on"
				Gosub RestLogo
		}else If (Array_isInValue(InputModeData["CLIP"], WinEXE)){
			if Initial_Mode~="i)off" {
				Initial_Mode:=WubiIni.Settings["Initial_Mode"] :="on", WubiIni.save()
			}
		}
	}
	If !FileExist(A_Temp "\InputMethodData")
		FileCreateDir,%A_Temp%\InputMethodData
	SetTimer, func_timer, 1000

	func_timer:
		WinID_:=WinExist("A")
		If (strLen(WinID_)>3){
			WinGet, WinEXE_, ProcessName , ahk_id %WinID_%
		}
		if (WinEXE_<>LastWinEXE&&Eid<>WinExist()&&Eid){
			If (Array_isInValue(InputModeData["CN"], WinEXE_)&&!srf_mode&&IStatus){
				srf_mode:=1
				If Logo_Switch~="i)on"
					Gosub RestLogo
			}else If (Array_isInValue(InputModeData["EN"], WinEXE_)&&srf_mode&&IStatus){
				srf_mode:=0
				If Logo_Switch~="i)on"
					Gosub RestLogo
			}else If (Array_isInValue(InputModeData["CLIP"], WinEXE_)&&IStatus){
				if Initial_Mode~="i)off" {
					Initial_Mode:=WubiIni.Settings["Initial_Mode"] :="on", WubiIni.save()
				}
			}else if (!Array_isInValue(InputModeData["EN"], WinEXE_)&&!Array_isInValue(InputModeData["CN"], WinEXE_)&&srf_mode<>(IMEmode~="off"?0:1)){
				srf_mode :=IMEmode~="off"?0:1, _Icon:=srf_mode?1:3
				If Logo_Switch~="i)on"
					Gosub RestLogo
			}
		}

		If (A_Cursor ~= "i)IBeam"&&CursorStatus&&!srf_mode&&ID_Cursor<>WinID_) {
			srf_mode:=1, ID_Cursor:=WinID_
			Gosub RestLogo
		}else If (not A_Cursor ~= "i)IBeam"&&CursorStatus&&srf_mode) {
			srf_mode:=0
			Gosub RestLogo
		}
		LastWinEXE:=WinEXE_, Eid:=WinExist(), lunarDate:=Date2LunarDate(SubStr( A_Now,1,10),GzType)
		program:="※ " Startup_Name " ※`n◆ 当前方案：" (Wubi_Schema~="i)ci"?"【" SchemaType["ci"] "五笔•含词】":Wubi_Schema~="i)zi"?"【" SchemaType["zi"] "五笔•单字】":Wubi_Schema~="i)zg"?"【五笔•字根】":"【" SchemaType["chaoji"] "五笔•超集】") "`n◆ 农历日期：" lunarDate[1] "〖 " A_DDDD " 〗`n◆ 甲子历：" lunarDate[2] "`n◆ 农历时辰：" Time_GetShichen(SubStr( A_Now,9,2)) "`n◆ 今日统计：" InputCount   ;;"`n◆ 版本日期：" versions
		Menu,Tray,Tip,%program%
		Gosub SelectItems
	Return
}
;}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

Gosub houxuankuangguicreate
Gosub Srf_Tip
;{{{{{Z键记录历史记录，最大数目为ListNum
updateRecent(Chars){
	global recent, ListNum
	loop % length:=objLength(recent){
		if(recent[a_index]==Chars){    ;删除重复的
			objRemoveAt(recent,a_index)
			break
		}
	}
	objInsertAt(recent,1,Chars)    ;新的放于最前
	if((length:=objLength(recent))>ListNum)    ;删除多的
	{
		objdelete(recent,ListNum+1,length)
	}
}

Gosub srf_value_off
#Include Config\Script\Label.ahk
#Include Config\Script\Srf_Conf.ahk
