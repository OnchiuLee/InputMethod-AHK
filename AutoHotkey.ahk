/*********************************************************************************
   脚本说明： 98五笔多功能版改装自--@河许人@天黑请闭眼联合开发的「影子输入法」与@hello_srf的柚子输入法代码结构
   资源库:https://wubi98.gitee.io/ && http://98wb.ys168.com/
   GitHub:https://github.com/OnchiuLee/AHK-Input-method
;~ 环境 版本:   Autohotkey v1.1.32.00
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
;;{{{{{启动文件位数判断
/*
Loop, Files, main\*.exe
{
	if (A_LoopFileFullPath~="i)AutoHotkey|U64"&&A_PtrSize=4&&A_Is64bitOS){
		Run *RunAs "%A_LoopFileFullPath%" /restart "%A_ScriptFullPath%" 
		break
	}
}
*/

Loop, Files, main\*.exe
{
	If (InStr( GetFileInfo(A_LoopFileLongPath), 64)&&InStr( GetFileInfo(A_AhkPath), 32)&&A_Is64bitOS) {
		Run *RunAs "%A_LoopFileLongPath%" /restart "%A_ScriptFullPath%"
		break
	}
}
;}}}}}

if FileExist(A_ScriptDir "\Config\Theme_Color\")
	FileRemoveDir, %A_ScriptDir%\Config\Theme_Color , 1
if FileExist(A_ScriptDir "\Config\*.ahk")
	Loop Files, %A_ScriptDir%\Config\*.ahk
		FileDelete, %A_LoopFileLongPath%

#Include Config\Lib\Class_Gdip.ahk
#Include Config\Lib\Class_EasyIni.ahk
#Include Config\Lib\Class_LV_Colors.ahk
#Include Config\Lib\Class_SQLiteDB.ahk
#Include Config\Lib\Class_ScrollGUI.ahk
#Include Config\Lib\Class_ToolTip.ahk
#Include Config\Lib\Class_Json.ahk
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
OnMessage(0x020a, "WM_MOUSEWHEEL")
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On
DetectHiddenText, On
WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
global y2 :=A_ScreenHeight-Shell_Wnd-40, CpuID:=ComInfo.GetCpuID_2()
font_:=ComInfo.GetDefaultFontName(), font_:=font_?font_:"Microsoft YaHei UI"

;;===============输入法名称（可修改）==================
global Startup_Name :="柚子98五笔"   
;拆分字体名变量，拆分开启时用来过滤字体以完美显示拆分
FontExtend:="98WB-U|98WB-V|98WB-P0|五笔拆字字根字体|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_
;;====================================================

;;{{{{{config.ini去重
FileRead,content,config.ini
New_Content:=""
Loop,parse,content, `n ,`r
	IfNotInString,New_Content,%A_LoopField%
		New_Content.=A_LoopField "`r`n"
FileDelete, config.ini
FileAppend,%New_Content%,config.ini,utf-8
New_Content:=""
Loop Files, config\Skins\logoStyle\*.icl
{
	if A_LoopFileName {
		StyleName:=SubStr(A_LoopFileName,1,-4)
		break
	}
}
;}}}}}

;{{{{{读取配置及配置检测
global srf_default_value,config_tip,srf_default_obj, WubiIni:=class_EasyIni("config.ini")
	srf_default_obj:={Settings:{Startup:"off",CNID:CpuID,IStatus:1,Exit_switch:1,Exit_hotkey:"^esc", symb_mode:2,sym_match:0,Frequency:0,Freq_Count:3, BUyaml:0, s2t_swtich:1,FocusStyle:1,PageShow:1, s2t_hotkey:"^+f", cf_swtich:1, cf_hotkey:"^+h", Prompt_Word:"off", Logo_X:"200", Logo_Y:y2, UIAccess:0, Addcode_switch:1, Addcode_hotkey:"^CapsLock", Suspend_switch:1, Suspend_hotkey:"!z", tip_hotkey:"!q", rlk_switch:0, Logo_Switch:"on",Srf_Hotkey:"Shift", Select_Enter:"clean", Initial_Mode:"off", symb_send:"on", set_color:"on", Wubi_Schema:"ci",Cut_Mode:"off", limit_code:"on", Trad_Mode:"off", IMEmode:"on",InitStatus:0}
		, TipStyle:{ThemeName:"经典商务风格", StyleN:StyleName,Logo_ExStyle:0, FontType:font_, FontSize:20, FontColor:"2C3D4F",FocusBackColor:"2C3D4F",FocusColor:"CA3936",FocusCodeColor:"DEDEDE",FocusRadius:5, logo_show:0, FontStyle:"off", FontCodeColor:"2C3D4F",LineColor:"444444",BorderColor:"ECF0F1", Gdip_Line:"off", ToolTipStyle:"Gdip", Radius:"on", BgColor:"ECF0F1", ListNum:5,Gdip_Radius:5, Textdirection:"horizontal", Set_Range:3, Fix_Switch:"off",Fix_X:A_ScreenWidth/2,Fix_Y:10}  ;竖排--vertical
		, CustomColors:{Color_Row1:"0x1C7399,0xEEEEEC,0x014E8B,0x444444,0x009FE8,0xDEF9FA,0xF8B62D,0x90FC0F", Color_Row2:"0x0078D7,0x0D1B0A,0xB9D497,0x00ADEF,0x1778BF,0xFDF6E3,0x002B36,0xDEDEDE"}
		, Versions:{Version:A_YYYY A_MM A_DD "-1"}
		, YSDllPath:{SQLDllPath_x86:"config\SQLite3_x86\SQLite3.dll", SQLDllPath_x64:"config\SQLite3_x64\SQLite3.dll"}}
;初始化默认配置
if FileExist(A_ScriptDir "\Sync\Default.json"){
	srf_default_value:=Json_FileToObj(A_ScriptDir "\Sync\Default.json")
	For Section, element In srf_default_obj
	{
		For key,value In element
		{
			if (!Array_ValueNotEmpty(srf_default_value, key)&&WubiIni[Section,key]=""){
				%key%:=WubiIni[Section,key]:=srf_default_value[Section,key]:= srf_default_obj[Section,key]
			}else if (!Array_ValueNotEmpty(srf_default_value, key)&&WubiIni[Section,key]<>"")
				%key%:=srf_default_value[Section,key]:=WubiIni[Section,key]
			else if (Array_ValueNotEmpty(srf_default_value, key)&&WubiIni[Section,key]="")
				%key%:=WubiIni[Section,key]:=srf_default_value[Section,key]
		}
	}
}else{
	srf_default_value:=srf_default_obj
}

;配置项说明
config_tip:={Settings:{Startup:"开机自启设置<on为建立系统计划任务实现自启/off为关闭开机自启/sc为在系统自启目录建立快捷方式实现自启>",IStatus:"窗口程序输入状态配置开关",Exit_switch:"快捷退出快捷键启用开关",Exit_hotkey:"快捷退出快捷键",BUyaml:"导出文件为yaml格式文件，需要文件头支持才能导出",Frequency:"动态调频〔只对含词方案有效〕",Freq_Count:"调频参数〔词条上屏次数〕",FocusStyle:"焦点候选样式<1为启用,反之>",sym_match:"引号成对上屏光标并居中",PageShow:"候选框页数显示", s2t_swtich:"简繁模式切换开关", s2t_hotkey:"简繁模式切换功能快捷键", cf_swtich:"拆分显示功能开关", cf_hotkey:"字根拆分快捷键", UIAccess:"候选框UI层级权限提升,1为开启 0为关闭", Addcode_switch:"批量造词开关<1为开启,0为关闭>", Addcode_hotkey:"批量造词热键设置", Suspend_switch:"脚本挂起启用开关<1为开启,0为关闭>", Suspend_hotkey:"脚本挂起启用快捷键设置", tip_hotkey:"划词反查快捷键设置", rlk_switch:"划词反查开关<1为开启,0为关闭>", symb_mode:"中英文符号模式，1为英文 2为中文", Prompt_Word:"空码提示设置<on/off>",Srf_Hotkey:"中英文切换热键", Logo_X:"输入法logo图标x坐标", Logo_Y:"输入法logo图标y坐标", Logo_Switch:"logo图标显示与隐藏<on/off>"
	, Select_Enter:"回车键功能定义<send为上屏编码/clean为清空编码>", Initial_Mode:"剪切板上屏开关<on/off>", symb_send:"符号顶屏开关<on/off>", set_color:"取色开关", Wubi_Schema:"方案设置项<ci为含词方案/zi为单字方案/chaoji为超集方案/zg为字根单打方案>",Cut_Mode:"字根拆分开关<on/off>", limit_code:"四码上屏开关<on/off>", Trad_Mode:"简繁模式切换<on为繁体/off为简体>", IMEmode:"中英文状态<on为中文/off为英文>"}
	, TipStyle:{ThemeName:"主题名称",StyleN:"logo样式编号",Logo_ExStyle:"Logo鼠标穿透开关",FontType:"候选字体设置",FontStyle:"候选词粗体开关",FocusBackColor:"候选框焦点背景颜色",FocusCodeColor:"候选框编码项背景",FocusColor:"候选框焦点字体颜色",FocusRadius:"焦点候选项圆角", logo_show:"桌面logo背景透明开关", FontSize:"候选字号大小设置", FontColor:"候选项颜色", FontCodeColor:"候选编码颜色",BorderColor:"候选框边框线",LineColor:"候选分割线选色", Gdip_Line:"Gdip候选框样式边框及候选框编码与候选词分隔线", ToolTipStyle:"候选框风格<on为tooltip样式/off为Gui候选样式/Gdip为Gdip候选样式>", Radius:"Gdip候选样式圆角开关<on/off>",Gdip_Radius:"Gdip候选框圆角大小", BgColor:"候选框背景色<16进制色值>", ListNum:"候选数量", Textdirection:"horizontal为横排/vertical为竖排", Set_Range:"ToolTip样式编码与候选词距离", Fix_Switch:"候选框固定开关",Fix_X:"候选框固定x坐标",Fix_Y:"候选框固定y坐标"}
	, CustomColors:{Color_Row1:"配色对话框自定义颜色区域，第一排", Color_Row2:"配色对话框自定义颜色区域，第二排"}
	, Versions:{Version:"版本日期"}
	, YSDllPath:{SQLDllPath_x86:"SQlite数据库dll 32位路径", SQLDllPath_x64:"SQlite数据库dll 64位路径"}}
;默认配置检测
For Section, element In srf_default_value
	For key, value In element
		If ((%key%:=WubiIni[Section, key])="")
			%key%:=WubiIni[Section, key]:=value
;配置项说明项写入
if !WubiIni.GetTopComments()
	WubiIni.AddTopComment("程序运行时，配置文件直接修改无效！退出后修改才有效！！！")

FileRead, ini_var, config.ini
For Section, element In config_tip
	For Comments, value In element
		If !WubiIni.GetKeyComments(Section, Comments)
			If ini_var not contains Comments
				WubiIni.AddKeyComment(Section, Comments, value)

if (Logo_X<0||Logo_X>A_ScreenWidth||Logo_Y<0||Logo_Y>A_ScreenHeight)
	Logo_X :=WubiIni.Settings["Logo_X"]:=200,Logo_Y :=WubiIni.Settings["Logo_Y"]:=y2
if (Wubi_Schema<>"ci"&&Wubi_Schema<>"zi"&&Wubi_Schema<>"chaoji"&&Wubi_Schema<>"zg")
	Wubi_Schema :=WubiIni.Settings["Wubi_Schema"]:="ci"

;开机自启项检测是否开启，以便与配置文件同步
cmd_zq= schtasks /Query /TN %Startup_Name%
global zq_:= cmdClipReturn(cmd_zq)
if FileExist(A_Startup "\" Startup_Name ".lnk"){
	Startup :=WubiIni.Settings["Startup"]:="sc"
}else{
	Startup :=WubiIni.Settings["Startup"]:=zq_~=Startup_Name?"on":"off"
}
versions :=WubiIni.Versions["Version"]:=A_YYYY A_MM A_DD "-1"      ;版本日期设置
if not Srf_Hotkey ~="i)Ctrl|Shift|Alt|LWin"||Srf_Hotkey ~="\&$"
	Srf_Hotkey:=WubiIni.Settings["Srf_Hotkey"]:="Shift"
WubiIni.Save()
;}}}}}

If (UIAccess&&CNID=CpuID){             ;FileExist(RegExReplace(A_AhkPath,RegExReplace(A_AhkPath,".+\\")) "*_UIA.exe")
	EnableUIAccess()
}else If (CNID<>CpuID){
	UIAccess:=WubiIni.Settings["UIAccess"]:=0,CNID:=WubiIni.Settings["CNID"]:=CpuID, WubiIni.Save()
	If FileExist(RegExReplace(A_AhkPath,RegExReplace(A_AhkPath,".+\\")) "*_UIA.exe")
		FileDelete, % RegExReplace(A_AhkPath,RegExReplace(A_AhkPath,".+\\")) "*_UIA.exe"
}else If (UIAccess&&not RegExReplace(A_AhkPath,".+\\")~="i)\_UIA"){
	UIAccess:=WubiIni.Settings["UIAccess"]:=0,CNID:=WubiIni.Settings["CNID"]:=CpuID, WubiIni.Save()
}
Gosub TRAY_Menu

if FileExist(A_ScriptDir "\wubi98.ico")
	Menu, Tray, Icon, wubi98.ico
else
	Menu, Tray, Icon, config\wubi98.icl,30

srf_mode :=IMEmode~="off"?0:1
if !InitStatus {
	run,http://98wb.ys168.com/
	InitStatus:=WubiIni.Settings["InitStatus"]:=1,WubiIni.Save()
	run,config\ReadMe.png
}
if (ToolTipStyle ~="i)gdip"&&A_OSVersion ~="i)WIN_XP") {
	;Traytip,,你的系统不支持当前Gdip候选框样式,请切换!,,2
	ToolTipStyle:=WubiIni.TipStyle["ToolTipStyle"]:="on", FontSize:=WubiIni.Settings["FontSize"]:=16, WubiIni.Save()
	Menu, Tip_Style, Rename, Gdip候选样式	√,Gdip候选样式
	Menu, Tip_Style, Rename, ToolTip样式,ToolTip样式	√
}

;{{{{{快捷键注册
hk_conv(Srf_Hotkey){
	if Srf_Hotkey~="``|`;" {
		Srf_Hotkey:=RegExReplace(Srf_Hotkey,"``|`;",Srf_Hotkey~="``"?"``":"`;")
	} else if not Srf_Hotkey~="&" {
		Srf_Hotkey_:=(not Srf_Hotkey~="LWin"?"~":"") . Srf_Hotkey_
		;Srf_Hotkey_:="~" . Srf_Hotkey_   ;注释上行 启用此行如果设定是单独win键 则不屏蔽打开开始菜单功能
	}
	Srf_Hotkey_ :=Srf_Hotkey~="i)Shift"?RegExReplace(Srf_Hotkey,"i)Shift\&","+"):(Srf_Hotkey~="i)Ctrl"?RegExReplace(Srf_Hotkey,"i)Ctrl\&","^"):(Srf_Hotkey~="i)Alt"?RegExReplace(Srf_Hotkey,"i)Alt\&","!"):RegExReplace(Srf_Hotkey,"i)LWin\&","<#")))
	Return Srf_Hotkey_
}
if not GetKeyState(RegExReplace(Srf_Hotkey,".+\&",""))~="\d"
	Srf_Hotkey:=RegExReplace(Srf_Hotkey,"\&.+","")
global Srf_Hotkey_ :=hk_conv(Srf_Hotkey)
Hotkey, %Srf_Hotkey_%, SetHotkey,on

tiphotkey:=tip_hotkey, AddCodehotkey:=Addcode_hotkey, s2thotkey:=s2t_hotkey, cfhotkey:=cf_hotkey, Suspendhotkey:=Suspend_hotkey,exithotkey:=Exit_hotkey
if tip_hotkey
	Hotkey, %tiphotkey%, SetRlk,on
if Suspend_switch
	Hotkey, %Suspendhotkey%, SetSuspend,on
if Addcode_switch
	Hotkey, %AddCodehotkey%, Batch_AddCode,on
if s2t_hotkey&&s2t_swtich
	Hotkey, %s2thotkey%, Trad_Mode,on
if cf_hotkey&&cf_swtich
	Hotkey, %cfhotkey%, Cut_Mode,on
if Exit_switch&&Exit_hotkey
	Hotkey, %exithotkey%, OnExit,on
;}}}}}

;{{{{{SQlite类创建,db文件读取
If (DB._Handle)
	DB.CloseDB()
DBFileName:="DB\wubi98.db"
global DB := New SQLiteDB
If !DB.OpenDB(DBFileName)
	MsgBox, 16, 数据库DB错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
Gosub Backup_CustomDB
;}}}}}
;SwitchToEngIME()

;{{常用变量值初始化
global recent:=Carets:={}
global code_status:=localpos:=srfCounts:=select_pos:=1
global valueindex:=Cut_Mode?2:1
global waitnum:=select_sym:=sym_qmarks:=PosLimit:=PosIndex:=InitSetting:=0
Select_Code=gfdsahjklm;'space           ;字母选词
global num__:=Result_Char:=Select_result :=selectallvalue:=""
global select_arr:=select_value_arr:=srf_bianma:=add_Array:=add_Result:=Split_code:=[]
;}}

Frequency_obj:=Json_FileToObj(A_ScriptDir "\Config\Script\wubi98_ci.json")
if !Frequency_obj.Count()
	Frequency_obj:={}

;中英标点符号映射
srf_symblos:={"``":["``","·"], "~":["~","～"], "!":["`!","！"], "@":["@","@"], "#":["#","#"]
	, "$":["$","￥"], "%":["`%","`%"], "^":["^","……"], "&":["&","&"], "*":["*","*"], "(":["(","（）{Left}"]
	, ")":[")","）"], "-":["-","-"], "=":["=","="], "[":["[","「"], "]":["]","」"]
	, "{":["{{}{}}{Left}","【】{Left}"], "}":["{}}","】"], "\":["\","、"], "|":["|","|"], ";":[";","；"], ":":[":","："]
	, "'":["'","‘"], "<":["<","《》{Left}"],">":[">","》"],",":[",","，"]
	,".":[".","。"], "/":["/","/"], "?":["?","？"], """":["""""{Left}","“"]}           ;中文单引号"‘’"

WM_LBUTTONDOWN(){
	global Wubi_Schema, ToolTipStyle, FocusStyle, PosIndex
	PosIndex:=0
	if (A_Gui="TSF"&&Wubi_Schema~="i)ci"&&ToolTipStyle~="i)Gdip"&&FocusStyle){
		mousegetpos, FX, FY
		PosIndex := TSFCheckClickPos(FX,FY)
		if (PosIndex>0)
		{
			srf_select(PosIndex)
		}
	}
	if (A_Gui="TSF"||A_Gui ="houxuankuang"||A_Gui ="SrfTip"){
		PostMessage, 0xA1, 2
		Gosub Write_Pos
	}
}

WM_RBUTTONDOWN(){
	global Wubi_Schema, ToolTipStyle, FocusStyle, PosIndex, srf_for_select_Array, Trad_Mode, Prompt_Word, srf_all_input, ListNum, TPosObj, waitnum, Logo_X, Logo_Y
	PosIndex:=0
	If (A_Gui="logo"){
		Menu, TRAY, Show, x%Logo_X%, y%Logo_Y%
	}
	if (A_Gui="TSF"&&Wubi_Schema~="i)ci"&&ToolTipStyle~="i)Gdip"&&FocusStyle&&srf_all_input~="^[a-y]+"&&Prompt_Word~="i)off"&&Trad_Mode~="i)off"){
		mousegetpos, FX, FY
		PosIndex := TSFCheckClickPos(FX,FY)
		if (PosIndex>0&&PosIndex<ListNum+1)
		{
			Menu, selectmenu, Add, 置顶, set_top   ; +Break
			Menu, selectmenu, Icon, 置顶, config\wubi98.icl, 36
			Menu, selectmenu, Add, 前移, set_add   ; +Break
			Menu, selectmenu, Icon, 前移, config\wubi98.icl, 37
			if ((PosIndex+ListNum*waitnum)=1){
				Menu, selectmenu, Disable, 置顶
				Menu, selectmenu, Disable, 前移
			}else{
				Menu, selectmenu, Enable, 置顶
				Menu, selectmenu, Enable, 前移
			}
			Menu, selectmenu, Add, 后移, set_next   ; +Break
			Menu, selectmenu, Icon, 后移, config\wubi98.icl, 38
			if (srf_for_select_Array.length()=(PosIndex+ListNum*waitnum))
				Menu, selectmenu, Disable, 后移
			else
				Menu, selectmenu, Enable, 后移
			Menu, selectmenu, Add, 删除, Delete_Word   ; +Break
			Menu, selectmenu, Icon, 删除, config\wubi98.icl, 39
			Menu, selectmenu, Show
		}
	}
}

/*
WM_MOUSEWHEEL(){
	if A_GuiControl in select_theme,FontType,font_size,set_select_value,set_regulate,set_GdipRadius,set_FocusRadius_value,sChoice4,SBA4,sChoice1,sChoice2,sChoice3,sethotkey_1
		Return
}
*/

WM_MOUSEMOVE()
{
	global Logo_X, Logo_Y, SrfTip_Width, SrfTip_Height, Logo_ExStyle, Tip_Show:={LineColor:"Gdip样式中间分隔线颜色",BorderColor : "Gdip样式四周边框线颜色", SBA16:"冻结/启用程序快捷键启用开关", SBA15:"鼠标划词反查编码功能启用开关", UIAccess:"候选框UI层级权限提升", SBA0 :"候选框固定坐标设置",About:"软件使用说明",ciku3:"英文词库导入`n（单行单义格式，以tab符隔开）`n「英文词条+Tab+词频」",ciku4:"英文词库导出`n（导出为单行单义格式txt码表）",ciku5:"特殊符号词库导入`n（格式「/引导字母+Tab+多符号以英文逗号隔开」）"
		, SBA5 : "固定候选框的位置，不跟随光标",BgColor:"候选框背景色",FocusBackColor:"候选框焦点选项背景色",FocusColor:"候选框焦点选项字体色", FontColor:"候选词字体颜色", FontCodeColor:"候选框编码字体颜色", SBA1:"繁体开关（输简出繁）快捷键启用开关", SBA4:"加入开机自启动任务：「`non＝>为建立系统计划任务实现自启`noff＝>为关闭开机自启`nsc＝>为在系统自启目录建立快捷方式实现自启」",ciku6:"特殊符号词库导出`n（导出为txt）",tip_hotkey:"通过快捷键开关划词反查"
		, SBA13:"显示/隐藏桌面Logo图标",SBA19:"有焦点色块选项的候选框",SetInput_CNMode:"程序启动时默认中文输入模式",SetInput_ENMode:"程序启动时默认英文输入模式", SBA12 : "候选词显示粗体",ciku1:"导入txt词库至数据库`ntxt码表格式需为「单行单义」",ciku2:"导出词库为「单行单义」的txt格式文本",SBA2:"拆分功能快捷键启用开关`n（需特殊字体支持，字体在本程序Font目录）",sethotkey_2:"打开小键盘选取键值",InputStatus:"窗口程序输入状态配置，只对新开窗口有效！"
		, SBA3:"当编码无词条时模糊匹配提示",SBA6:"符号顶首选屏并上屏该键符号",SBA7:"四位编码候选唯一时自动上屏，五码时顶首选上屏",SBA9:"Gdip候选框圆角开关",SBA10:"Gdip候选样式中间分隔线",yaml_:"导出词库为yaml格式可直接应用于rime平台，`n需Sync目录有header.txt文件头支持",search_1:"〔 词频为0的为主词库已删除的，勾选删除即恢复！ 〕",IM_DDL:"此处选择你要更改的内容",WinMode:"设置每个有窗口进程的输入状态与上屏方式",SBA22:"程序退出快捷键启用开关",Exit_hotkey:"程序退出操作快捷键"
		, Save:"无码造词和自由模式可以同时进行需分行输入。格式如下：`nuqid=http://98wb.ys168.com/`nggte=五笔`n柚子输入法",Frequency:"自动根据每个词条的输入频率进行顺序调整",set_Frequency:"设置词条的输入频率值来进行顺序调整",AddProcess:"只在新开启的窗口有效,在进行窗口切换时没有任何效果!`n添加进程名时,鼠标放在指定的窗口上,按下左Ctrl执行添加`n,20秒内无操作,自动添加当前鼠标所在窗口的进程.",SBA17:"批量造词快捷键启用开关"}   ;Lastpage:"首页",Toppage:"尾页"

	static CurRControl, PrevControl
	CurRControl := A_GuiControl
	if (CurRControl <> PrevControl and not InStr(CurRControl, " "))
	{
		ToolTip ; 关闭之前的 ToolTip.
		SetTimer, DisplayToolTip, 500
		PrevControl := CurRControl
	}

	aero_link:="C:\Windows\Cursors\aero_link.cur" ;小手
	;aero_arrow_l:="C:\Windows\Cursors\aero_arrow_l.cur" ;箭头
	if (A_GuiControl~="i)nextpage|uppage|MyDB|Lastpage|Toppage"&&FileExist(aero_link)){
		CursorHandle := DllCall( "LoadCursorFromFile", Str,aero_link )
		DllCall( "SetSystemCursor", Uint,CursorHandle, Int,32512 )
	}else{
		DllCall( "SystemParametersInfo", UInt,0x57, UInt,0, UInt,0, UInt,0 )
	}

	SetTimer, Tip_timer, 500
	Tip_timer:
		x_:=Logo_X+SrfTip_Width+5
		if (A_Gui~="i)SrfTip|logo"&&!Logo_ExStyle) {
			Gosub Write_Pos
			Gui, logo:Show, NA h36 x%x_% y%Logo_Y%,sign_wb
		}else{
			Gui, logo:Hide
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

;{{{{{{应用状态管理{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{
EXEList_obj:=Json_FileToObj(A_ScriptDir "\Sync\InputMode.json")
if !EXEList_obj.Count() {
	EXEList_obj:={CN:["QQ.exe"],EN:["Notepad.exe"],CLIP:["Notepad.exe"]}
	Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
}
Gui +LastFound
DllCall( "RegisterShellHookWindow", UInt,WinExist() )   ;WinActive()
OnMessage( DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" ), "ShellIMEMessage")
ShellIMEMessage( wParam,lParam ) {
	global srf_mode, EXEList_obj, Initial_Mode, WubiIni,StyleN,IStatus, Versions, program
		, Startup_Name, Logo_X, Logo_Y, SrfTip_Width, SrfTip_Height, Logo_ExStyle
	If ( wParam = 6 ||wParam = 1 ){
		WinGet, WinEXE, ProcessName , ahk_id %lParam%
		WinGetclass, WinClass, ahk_id %lParam%
		;WinActivate,ahk_class %WinClass%
		Loop,% EXEList_obj["CN"].length()+EXEList_obj["EN"].length()+EXEList_obj["CLIP"].length()
		{
			If (EXEList_obj["CN",a_index]=WinEXE&&!srf_mode&&EXEList_obj["CN",a_index]<>""&&IStatus)
			{
				srf_mode:=1
				GuiControl,logo:, Pics,*Icon1 config\Skins\logoStyle\%StyleN%.icl
				Gosub ShowSrfTip
				break
			}else If (EXEList_obj["EN",a_index]=WinEXE&&srf_mode&&EXEList_obj["EN",a_index]<>""&&IStatus){
				srf_mode:=0
				GuiControl,logo:, Pics,*Icon3 config\Skins\logoStyle\%StyleN%.icl
				Gosub ShowSrfTip
				break
			}else If (EXEList_obj["CLIP",a_index]=WinEXE&&EXEList_obj["CLIP",a_index]<>""&&IStatus){
				if Initial_Mode~="i)off" {
					Initial_Mode:=WubiIni.Settings["Initial_Mode"] :="on", WubiIni.save()
					GuiControl,logo:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
					break
				}
			}
		}
	}
	SetTimer, func_timer, 500

	func_timer:
		program:="※ " Startup_Name " ※`n版本日期：" Versions "`n农历日期：" Date_GetLunarDate(SubStr( A_Now,1,8)) "〖 " A_DDDD " 〗`n农历时辰：" Time_GetShichen(SubStr( A_Now,9,2))
		Menu,Tray,Tip,%program%
	Return
}
;}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}

Gosub houxuankuangguicreate
Gosub Schema_logo
;{{{{{Z键记录历史记录，最大数目为ListNum
updateRecent(date){
	global recent, ListNum
	loop % length:=objLength(recent){
		if(recent[a_index]==date){    ;删除重复的
			objRemoveAt(recent,a_index)
			break
		}
	}
	objInsertAt(recent,1,date)    ;新的放于最前
	if((length:=objLength(recent))>ListNum)    ;删除多的
	{
		objdelete(recent,ListNum+1,length)
	}
}

;获取返回系统存在的拆分字体名
GetCutModeFont(){
	global FontExtend,a_FontList
	fontName:=""
	for k,v in StrSplit(a_FontList , "|")
		if v~="i)" FontExtend
			fontName:= v
	Return fontName
}
;if GetFont:=GetCutModeFont()&&Cut_Mode~="i)on"&&not FontType~="i)" FontExtend
;	FontType :=WubiIni.TipStyle["FontType"]:= GetFont, WubiIni.Save()

Gosub srf_value_off
#Include Config\Script\Label.ahk
#Include Config\Script\Srf_Conf.ahk
