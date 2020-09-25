;桌面logo
Srf_Tip:
	Gui, SrfTip:Destroy
	Gui, SrfTip:Default
	Scale:=DPIScale?"+DPIScale":"-DPIScale"
	SrfTip_Width:=SrfTip_Height:=LogoSize   ;方块Logo长宽尺寸
	Gui,SrfTip:+LastFound -Caption +AlwaysOnTop ToolWindow %Scale% +hwndSrf_Tip      ;; -DPIScale
	Gui,SrfTip: Add, Pic,x0 y0 h%SrfTip_Width% w%SrfTip_Height% gTipMore vTipMore HwndMyTextHwnd
	TipBackgroundBrush := DllCall("CreateSolidBrush", UInt, GetKeyState("CapsLock", "T")?"0x" LogoColor_caps:srf_mode?"0x" LogoColor_cn:"0x" LogoColor_en),GuiHwnd := WinExist()
	WindowProcNew := RegisterCallback("WindowProc", "", 4, MyTextHwnd)
	WindowProcOld := DllCall(A_PtrSize=8 ? "SetWindowLongPtr" : "SetWindowLong", Ptr, Srf_Tip, Int, -4, Ptr, WindowProcNew, Ptr) ; 返回值必须设置为 Ptr 或 UPtr 而不是 Int.
	if (Logo_Switch ~="i)off"||srfTool)
		Gui, SrfTip:Destroy
	else
		Gui,SrfTip: Show,NA h%SrfTip_Width% w%SrfTip_Height% x%Logo_X% y%Logo_Y%,Srf_Tip
	WinSet, TransColor, ffffff %transparentX%,Srf_Tip
	if Logo_ExStyle
		WinSet, ExStyle, ^0x20, ahk_id %Srf_Tip%  ;鼠标穿透
	Gosub Schema_logo
Return

ShowSrfTip:
	If srfTool
		Gosub Schema_logo
	else
		Gosub Srf_Tip
Return

Schema_logo:
	Gui, logo:Destroy
	Gui, logo:Default
	Scale:=DPIScale?"+DPIScale":"-DPIScale", IconMode:=srf_mode?1:3
	Gui, logo: -Caption +AlwaysOnTop ToolWindow border %Scale% +hwndWubi_Gui          ;  -DPIScale 禁止放大
	if FileExist(A_ScriptDir "\config\background.png"){
		Gui, logo:Add, Picture,x2 y0 w191,config\background.png
		Gui, logo:Add, Picture,x6 y4 h26 w181 border, config\background.png
	}else{
		Gui, logo:Add, Picture,x2 y0 w191 Icon33,config\wubi98.icl
		Gui, logo:Add, Picture,x6 y4 h26 w181 border Icon33, config\wubi98.icl
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
	Gui, logo:Color, EFEFEF
	Gui, logo:Margin, 2,2
	if (Logo_Switch ~="i)off"||!srfTool)
		Gui, logo:Hide
	else
		Gui, logo:Show, NA h36 x%Logo_X% y%Logo_Y%,sign_wb
	;WinSet, TransColor, EFEFEF %transparentX%,sign_wb   ;方案Logo的透明度 数字越大透明度越低最大255，0为完全透明
Return

logoGuiDropFiles:
SrfTipGuiDropFiles:
	Gui +OwnDialogs
	MsgBoxRenBtn("保存","不保存","单/多义互转")
	MsgBox, 266243,TXT码表处理,正在执行批量生词,是否保存至词库?
	IfMsgBox, No
		saveTodb:=0
	else IfMsgBox, Yes
		saveTodb:=1
	else IfMsgBox, Cancel
		saveTodb:=2
	if saveTodb>1
	{
		Loop, Parse, A_GuiEvent, `n, `r
		{
			if not A_LoopField~="\.txt" {
				Traytip,,文件格式不支持！
				break
			}
			filenames:=RegExReplace(A_LoopField, ".+\\|\..+")
			RegExMatch(A_LoopField,".+\\",File_Path)
			FileRead, CikuVar, %A_LoopField%
			Start:=A_TickCount
			ciku_all := Transform_mb(CikuVar)
			ciku_all:=RegExReplace(ciku_all,"^\s+`r`n{1,}")
			if (ciku_all=""){
				Traytip,,当前文件格式不支持转换!,, 2
				Return
			}
			ElapsedTime := (A_TickCount - Start)/1000
			if (ElapsedTime>60)
				timecount:=Ceil(ElapsedTime/60) "分" Mod(Ceil(ElapsedTime),60) "秒"
			Else
				timecount:=Ceil(ElapsedTime) "秒"
			if InStr(ciku_all,A_Tab){
				Traytip,,多义====>单义转换中。。。
				FileDelete, %File_Path%%filenames%_单义.txt
				FileAppend, %ciku_all%, %File_Path%%filenames%_单义.txt, UTF-8
				Traytip,,转换完成-`n耗时%timecount%
			}else if InStr(ciku_all,A_Space){
				Traytip,,单义====>多义转换中。。。
				FileDelete, %File_Path%%filenames%_多义.txt
				FileAppend, %ciku_all%, %File_Path%%filenames%_多义.txt, UTF-8
				Traytip,,转换完成-`n耗时%timecount%
			}
			ciku_all:=""
		}
	}else{
		Gosub DROP_Status
		Loop, Parse, A_GuiEvent, `n, `r
		{
			filenames:=RegExReplace(A_LoopField, ".+\\|\..+")
			RegExMatch(A_LoopField,".+\\",File_Path)
			FileRead, CikuVar, %A_LoopField%
			;CikuVar:=RegExReplace(CikuVar,"\t\d+|\t[a-z]+")
			count:=0
			Traytip,,词组生成中。。。
			Start:=A_TickCount
			Loop, Parse, CikuVar, `n, `r
			{
				If (A_LoopField = "")
					Continue
				if A_LoopField~="\t[a-z]+" {
					RegExMatch(RegExReplace(A_LoopField,"\t\d+$"),"^.+(?=\t[a-z])",Part1)
					RegExMatch(RegExReplace(A_LoopField,"\t\d+$"),"(?<=\t)[a-z]+",Part2)
					if (saveTodb=1){
						All_Word_part:=Part1 A_Tab Part2
						if Save_word(Part2 "=" Part1)>0
							count++
					}
				}else{
					bianmas:= get_en_code(RegExReplace(A_LoopField,"\t\d+|\t[a-z]+|\s+"))
					if (bianmas<>"") {
						All_Word_part:=RegExReplace(A_LoopField,"\t\d+|\t[a-z]+|\s+") A_Tab bianmas
						if (saveTodb=1){
							if Save_word(RegExReplace(A_LoopField,"\t\d+|\t[a-z]+|\s+"))>0
								count++
						}
					}
				}
				All_Word .=All_Word_part "`r`n" 
			}
			All_Word:=RegExReplace(All_Word,"^`r`n|.+\t`r`n|\t$")
			FileDelete, %File_Path%%filenames%-单义.txt
			FileAppend, %All_Word%, %File_Path%%filenames%-单义.txt, UTF-8
			All_Word:=All_Word_part:=""
			ElapsedTime := (A_TickCount - Start)/1000
			if (ElapsedTime>60)
				timecount:=Ceil(ElapsedTime/60) "分" Mod(Ceil(ElapsedTime),60) "秒"
			Else
				timecount:=Ceil(ElapsedTime) "秒"
			if count>0
				TrayTip,, 写入%count%行-耗时%timecount%
			else
				TrayTip,, 生成文件路径为:%A_Desktop%\%filenames%-单义.txt`n耗时%timecount%
		}
		ToolTip(1,""), Result_:=Results_:=Result:=[]
	}
Return

DROP_Status:
	WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
	ToolTip(1, "", "Q1 B" BgColor " T" FontCodeColor " S" 12 " F" Font_)
	ToolTip(1, "词条处理中。。。", "x" A_ScreenWidth-300 " y" A_ScreenHeight-Shell_Wnd-40)
Return

Get_IME:
	global tip_pos:={x:GetCaretPos().x,y:GetCaretPos().y+30}
	If A_Cursor ~= "i)IBeam" {
		if srf_mode
		{
			if not A_OSVersion ~="i)WIN_XP"
			{
				Gosub Ime_Tips
				Sleep,200
				Gui, tips: Destroy
			}else{
				ToolTip,中,% GetCaretPos().x ,% GetCaretPos().y+30
				Sleep,200
				ToolTip
			}
		}else{
			if not A_OSVersion ~="i)WIN_XP"
			{
				Gosub Ime_Tips
				Sleep,200
				Gui, tips: Destroy
			}else{
				ToolTip, 英,% GetCaretPos().x ,% GetCaretPos().y+30
				Sleep,200
				ToolTip
			}
		}
	}else{
		if srf_mode
		{
			if not A_OSVersion ~="i)WIN_XP"
			{
				Gosub Ime_Tips
				Sleep,200
				Gui, tips: Destroy
			}else{
				WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
				ToolTip,中,% A_ScreenWidth-50 ,% A_ScreenHeight-Shell_Wnd-40
				Sleep,200
				ToolTip
			}
		}else{
			if not A_OSVersion ~="i)WIN_XP"
			{
				Gosub Ime_Tips
				Sleep,200
				Gui, tips: Destroy
			}else{
				WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
				ToolTip, 英, % A_ScreenWidth-50,% A_ScreenHeight-Shell_Wnd-40
				Sleep,200
				ToolTip
			}
		}
	}
Return

; 中英文切换模式
SetHotkey:
	srf_mode := !srf_mode, IconMode:=srf_mode?1:3
	SetCapsLockState , off
	srf_for_select_Array :=select_arr:=srf_bianma:=[],Select_result:="",code_status:=localpos:=1, select_sym:=PosLimit:=0
	If !srfTool
		Gosub ShowSrfTip
	GuiControl,logo:, Pics,*Icon%IconMode% config\Skins\logoStyle\%StyleN%.icl
	if srf_mode
	{
		if Logo_Switch ~="on" {
			Logo_X :=WubiIni.Settings["Logo_X"],Logo_Y :=WubiIni.Settings["Logo_Y"],WubiIni.save()
		}
	}
	else
	{
		if Logo_Switch ~="on" {
			Gosub Write_Pos
		}
		sendinput % RegExReplace(srf_all_input,"\'","")
	}
	Gosub srf_value_off
	Gosub Get_IME
Return

Pics:
	if (A_GuiEvent = "Normal"&&srfTool)
	{
			SetCapsLockState , off
			srf_mode:=srf_mode?0:1, IconMode:=srf_mode?1:3
			GuiControl,logo:, Pics,*Icon%IconMode% config\Skins\logoStyle\%StyleN%.icl
	}
Return

Pics2:
	if (A_GuiEvent = "Normal")
	{
		if Trad_Mode~="i)on" {
			GuiControl,logo:, Pics2,*Icon5 config\Skins\logoStyle\%StyleN%.icl
			SetCapsLockState , off
			Trad_Mode :=WubiIni.Settings["Trad_Mode"]:="off",WubiIni.save()
		}else{
			GuiControl,logo:, Pics2,*Icon6 config\Skins\logoStyle\%StyleN%.icl
			SetCapsLockState , off
			Trad_Mode :=WubiIni.Settings["Trad_Mode"]:="on",WubiIni.save()
		}
	}
Return

Pics3:
	if (A_GuiEvent = "Normal")
	{
		if (symb_mode=2) {
			GuiControl,logo:, Pics3,*Icon8 config\Skins\logoStyle\%StyleN%.icl
			SetCapsLockState , off
			symb_mode :=WubiIni.Settings["symb_mode"]:=1,WubiIni.save()
		}else{
			GuiControl,logo:, Pics3,*Icon7 config\Skins\logoStyle\%StyleN%.icl
			SetCapsLockState , off
			symb_mode :=WubiIni.Settings["symb_mode"]:=2,WubiIni.save()
		}
	}
Return

Pics4:
	if (A_GuiEvent = "Normal")
	{
		if Initial_Mode~="i)on" {
			Initial_Mode:=WubiIni.Settings["Initial_Mode"] :="off", WubiIni.save()
			GuiControl,logo:, Pics4,*Icon9 config\Skins\logoStyle\%StyleN%.icl
		}else{
			Initial_Mode:=WubiIni.Settings["Initial_Mode"] :="on", WubiIni.save()
			GuiControl,logo:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
		}
	}
Return

;logo开关
Logo_Switch:
	Logo_Switch :=WubiIni.Settings["Logo_Switch"] :=Logo_Switch~="i)off"?"on":"off", WubiIni.save()
	if Logo_Switch ~="i)off"{
		Gui, SrfTip:Destroy
		If srfTool
			Gui, logo:Destroy
	}else{
		If srfTool {
			Gosub Schema_logo
			Gui, logo:Show, NA h36 x%Logo_X% y%Logo_Y%,sign_wb
		}else
			Gosub Srf_Tip
	}
	GuiControl,98:, SBA13 , % Logo_Switch~="i)on"?1:0
	Menu, More, Icon, 指示器, shell32.dll, % Logo_Switch~="i)on"?145:141
Return

Del_EnKeyboard:    ;彻底删除系统美式英文键盘，因为是增删注册表的原因不能实时失效，需重启生效!调用的话直接 Gosub+空格+Del_EnKeyboard即可
	DelRegKey("HKEY_CURRENT_USER", "Keyboard Layout\Preload")
	DelRegKey("HKEY_USERS", ".DEFAULT\Keyboard Layout\Preload")
	RegDelete, HKEY_CURRENT_USER\Software\Microsoft\CTF\SortOrder\AssemblyItem\0x00000409
Return

;logo移动写入坐标
Write_Pos:
	WinGetPos, X_, Y_, , , % srfTool?"sign_wb":"Srf_Tip"
	if (X_=""||Y_="")
		Logo_X :=WubiIni.Settings["Logo_X"]:=200, Logo_Y :=WubiIni.Settings["Logo_Y"]:=y2, WubiIni.save()
	else
		Logo_X :=WubiIni.Settings["Logo_X"]:=X_, Logo_Y :=WubiIni.Settings["Logo_Y"]:=Y_, WubiIni.save()
Return

;logo双击操作设定
TipMore:
	if (A_GuiEvent = "DoubleClick")
	{
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema~="ci"?"zi":(Wubi_Schema~="zi"?"chaoji":(Wubi_Schema~="chaoji"?"zg":"ci")), WubiIni.save()
		sicon_:=Wubi_Schema~="i)ci"?11:(Wubi_Schema~="i)zi"?13:Wubi_Schema~="i)chaoji"?12:14)
		GuiControl,logo:, MoveGui,*Icon%sicon_% config\Skins\logoStyle\%StyleN%.icl
		if Wubi_Schema~="ci" {
			Gosub Enable_Tray
			Menu, More, Enable, 批量造词
			GuiControl, 98:Disable, SBA23
		}else if Wubi_Schema~="zi"{
			Gosub Disable_Tray
			GuiControl, 98:Enable, SBA23
			Menu, More, Disable, 批量造词
		}else if Wubi_Schema~="chaoji" {
			Gosub Enable_Tray
			GuiControl, 98:Disable, SBA23
			Menu, More, Disable, 批量造词
		}else if Wubi_Schema~="zg"{
			Gosub Disable_Tray
			GuiControl, 98:Disable, SBA23
			Menu, More, Disable, 批量造词
		}
		Gosub SelectItems
	}
Return

MoveGui:
	if (A_GuiEvent = "Normal"&&!srfTool||srfTool&&A_GuiEvent = "DoubleClick")
	{
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema~="ci"?"zi":(Wubi_Schema~="zi"?"chaoji":(Wubi_Schema~="chaoji"?"zg":"ci")), WubiIni.save()
		sicon_:=Wubi_Schema~="i)ci"?11:(Wubi_Schema~="i)zi"?13:Wubi_Schema~="i)chaoji"?12:14)
		GuiControl,logo:, MoveGui,*Icon%sicon_% config\Skins\logoStyle\%StyleN%.icl
		if Wubi_Schema~="ci" {
			Gosub Enable_Tray
			Menu, More, Enable, 批量造词
			GuiControl, 98:Disable, SBA23
		}else if Wubi_Schema~="zi"{
			Gosub Disable_Tray
			GuiControl, 98:Enable, SBA23
			Menu, More, Disable, 批量造词
		}else if Wubi_Schema~="chaoji" {
			Gosub Enable_Tray
			GuiControl, 98:Disable, SBA23
			Menu, More, Disable, 批量造词
		}else if Wubi_Schema~="zg"{
			Gosub Disable_Tray
			GuiControl, 98:Disable, SBA23
			Menu, More, Disable, 批量造词
		}
		Gosub SelectItems
	}
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
	program:= "※ " Startup_Name " ※" "`n农历日期：" Date_GetLunarDate(SubStr( A_Now,1,8)) "`n农历时辰：" Time_GetShichen(SubStr( A_Now,9,2))
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
	Menu, DB, Add
	Menu, DB, Add, 长字符串导入,Write_LongChars
	Menu, DB, Icon, 长字符串导入, shell32.dll, 60
	Menu, DB, Add
	Menu, DB, Add, 长字符串导出,Backup_LongChars
	Menu, DB, Icon, 长字符串导出, shell32.dll, 69
	Menu, DB, Add
	Menu, DB, Add, 单/多义转换,TransformCiku
	Menu, DB, Icon, 单/多义转换, shell32.dll, 239
	Menu, Tray, Add, 词库,:DB
	Menu, Tray, Icon, 词库, shell32.dll, 131
	Menu, Tray, Add
	Menu, Schema, Add, 含词, ChoiceItems
	Menu, Schema, Add
	Menu, Schema, Add, 单字, ChoiceItems
	Menu, Schema, Add
	Menu, Schema, Add, 超集, ChoiceItems
	Menu, Schema, Add
	Menu, Schema, Add, 字根, ChoiceItems
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
	Menu, ToolTipStyle, Add
	Menu, ToolTipStyle, Color, FFFFFF
	TMENU := Menu_GetMenuByName("ToolTipStyle")
	Menu, More, Add, 批量造词,Add_Code
	Menu, More, Add
	Menu, More, Add, 划译反查,SetRlk
	Menu, More, Icon, 划译反查, shell32.dll, % rlk_switch?145:134
	Menu, More, Add
	Menu, More, Add, 五笔拆分,Cut_Mode
	Menu, More, Icon, 五笔拆分, shell32.dll, % Cut_Mode~="i)on"?145:222
	Menu, More, Add,
	Menu, More, Add, 候选框,:ToolTipStyle
	Menu, More, Icon, 候选框, shell32.dll, 81
	if (Wubi_Schema~="i)zi|chaoji"&&!Addcode_switch)
		Menu, More, Disable, 批量造词
	Menu, More, Icon, 批量造词, shell32.dll, 281
	Menu, More, Add,
	Menu, More, Add, 指示器,Logo_Switch
	Menu, More, Icon, 指示器, shell32.dll, % Logo_Switch~="i)on"?145:141
	Menu, More, Add
	Menu, More, Add, 初始化,Initialize
	Menu, More, Icon, 初始化, shell32.dll, 236
	Menu, Tray, Add, 更多,:More
	Menu, Tray, Icon, 更多, shell32.dll, 266
	Menu, Tray, Add
	Menu, Tray, Add, 设置, Onconfig
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
	MsgBox, 262452, 长字符串词库导入,导入文本遵循以下格式：`n编码+Tab`n+对候选栏显示的词条的说明项`n+Tab+候选栏显示的词条`n+Tab+要上屏的长文本字符串`n===【输出方法：/+编码+z】===
	IfMsgBox, Yes
	{
		__Chars:=_Chars:=""
		FileSelectFile, FileContents, 3, , 请选择要导入的文本文件, Text Documents (*.txt)
		If (FileContents<>"")
		{
			SQL =CREATE TABLE IF NOT EXISTS TangSongPoetics ("A_Key" TEXT,"Author" TEXT, "B_Key" TEXT, "C_Key" TEXT);delete from TangSongPoetics
			DB.Exec(SQL)
			FileRead,_Chars,%FileContents%
			Loop,parse,_Chars,`n,`r
				If A_LoopField 
					CharsObj:=StrSplit(A_LoopField,A_tab), __Chars.="('" RegExReplace(CharsObj[1],"\s+") "','" RegExReplace(CharsObj[2],"\s+") "','" RegExReplace(CharsObj[3],"\s+") "','" RegExReplace(CharsObj[4],"\s+") "')" ","
			If DB.Exec("INSERT INTO TangSongPoetics VALUES" RegExReplace(__Chars,"\,$") "")>0
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
	Gui +OwnDialogs
	FileSelectFile, FileContents, 3, , 请选择要转换的词库文本文件, Text Documents (*.txt)
	If (FileContents<>"")
	{
		startTime:= CheckTickCount()
		If !TranCiku(FileContents)
			MsgBox, 262192, 码表转换, 词库格式不支持！, 8
		else{
			MsgBox, 262208, 码表转换,% "转换完成耗时" CheckTickCount(startTime), 15
		}
		FileContents:=""
	}
Return

SelectItems:
	Menu_CheckRadioItem(SCMENU, Wubi_Schema~="i)ci"?1:Wubi_Schema~="i)zi"?3:Wubi_Schema~="i)chaoji"?5:7)
	Menu_CheckRadioItem(TMENU, ToolTipStyle~="i)on"?1:ToolTipStyle~="i)off"?3:5), Menu_CheckRadioItem(HMENU, ToolTipStyle ~="i)on"?1:ToolTipStyle ~="i)off"?2:3)
Return

ChoiceItems:
	If (A_ThisMenu~="i)Schema"&&A_ThisMenuItemPos)
	{
		;;Menu_CheckRadioItem(SCMENU, A_ThisMenuItemPos)
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="ci",WubiIni.save()
		If (A_ThisMenuItemPos=1) {
			Menu, More, Enable, 批量造词
			Menu, DB, Enable, 导入词库
			Menu, DB, Enable, 合并导出
			For k,v In ["ciku1","ciku2"]
				GuiControl, 98:Enable, %v%
			For k,v In ["SBA23"]
				GuiControl, 98:Disable, %v%
			GuiControl,logo:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
			GuiControl, 98:Enable, Frequency
			if !Frequency {
				For k,v In ["FTip","set_Frequency","RestDB"]
					GuiControl, 98:Disable, %v%
				OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
			}else{
				For k,v In ["FTip","set_Frequency","RestDB"]
					GuiControl, 98:Enable, %v%
				OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x292421})
			}
		}else If (A_ThisMenuItemPos=3) {
			Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="zi",WubiIni.save()
			Menu, More, Disable, 批量造词
			Menu, DB, Disable, 导入词库
			Menu, DB, Disable, 合并导出
			For k,v In ["ciku1","ciku2"]
				GuiControl, 98:Disable, %v%
			if FileExist("config\GB*.txt")
				GuiControl, 98:Enable, SBA23
			GuiControl,logo:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
			For k,v In ["FTip","set_Frequency","RestDB","Frequency"]
				GuiControl, 98:Disable, %v%
			OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		} else If (A_ThisMenuItemPos=5) {
			Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="chaoji",WubiIni.save()
			Menu, More, Disable, 批量造词
			Menu, DB, Enable, 导入词库
			Menu, DB, Enable, 合并导出
			For k,v In ["ciku1","ciku2"]
				GuiControl, 98:Enable, %v%
			For k,v In ["SBA23"]
				GuiControl, 98:Disable, %v%
			GuiControl,logo:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
			For k,v In ["FTip","set_Frequency","RestDB","Frequency"]
				GuiControl, 98:Disable, %v%
			OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		}else If (A_ThisMenuItemPos=7) {
			Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="zg",WubiIni.save()
			Menu, More, Disable, 批量造词
			Menu, DB, Disable, 导入词库
			Menu, DB, Disable, 合并导出
			For k,v In ["ciku1", "ciku2", "SBA23", "Frequency", "FTip", "set_Frequency", "RestDB"]
				GuiControl, 98:Disable, %v%
			GuiControl,logo:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
			OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		}
	}else If (A_ThisMenu~="i)ToolTipStyle"&&A_ThisMenuItemPos) {
		;;Menu_CheckRadioItem(TMENU, A_ThisMenuItemPos), Menu_CheckRadioItem(HMENU, ToolTipStyle ~="i)on"?1:ToolTipStyle ~="i)off"?2:3)
		ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :=A_ThisMenuItemPos=5?"Gdip":A_ThisMenuItemPos=3?"off":"on"
		FontSize :=WubiIni.TipStyle["FontSize"] :=A_ThisMenuItemPos=5?22:16
		if ToolTipStyle ~="i)on|off"{
			For k,v In ["LineColor","BorderColor","set_GdipRadius","GdipRadius","SBA9","SBA10","SBA12","SBA19"]
				GuiControl, 98:Disable, %v%
			Gui, houxuankuang:Destroy
			Gosub houxuankuangguicreate
		}else{
			For k,v In ["LineColor","BorderColor","SBA9","SBA10","SBA12","SBA19"]
				GuiControl, 98:Enable, %v%
			if Radius~="i)on" {
				For k,v In ["set_GdipRadius","GdipRadius"]
					GuiControl, 98:Enable, %v%
			}
		}
	}
	Gosub SelectItems
	WubiIni.Save()
Return

Initialize:
	MsgBox, 262452,重置确认, 是否重置输入法配置重新生成？`n如果出现候选框不显示，请重置！
	IfMsgBox Yes
	{
		For Section,element In srf_default_obj
			WubiIni.DeleteSection(Section)
		WubiIni.AddSection("Initialize", "status", 1), WubiIni.save()
		Gosub OnReload
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
		Menu, Tray, Icon, config\wubi98.icl,31, 1
		;if !GET_IMESt()
		;	SwitchToChsIME()
		Menu, TRAY, Rename, 禁用 , 启用
		Menu, TRAY, Icon, 启用, config\wubi98.icl, 4
		GuiControl,logo:, Pics,*Icon4 config\Skins\logoStyle\%StyleN%.icl
		Traytip,  提示:,已切换至挂起状态！
	}else if !A_IsSuspended {
		if FileExist(A_ScriptDir "\wubi98.ico")
			Menu, Tray, Icon, wubi98.ico
		else
			Menu, Tray, Icon, config\wubi98.icl,30
		Menu, TRAY, Rename, 启用 , 禁用
		Menu, TRAY, Icon, 禁用, shell32.dll, 175
		if srf_mode
			GuiControl,logo:, Pics,*Icon1 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, Pics,*Icon3 config\Skins\logoStyle\%StyleN%.icl
		Traytip,  提示:,已切换至启用状态！
		;if GET_IMESt()
		;	SwitchToEngIME()
	}
return

OnUpdate:
	;;FileGetTime, _VersionVar, % GetModuleExeName(DllCall("GetCurrentProcessId"))
	Run *RunAs "%A_AhkPath%" /restart "Config\Script\CheckUpdate.ahk"
Return

;重载操作
OnReload:
	if Logo_Switch ~="i)on"
		Gosub Write_Pos
	reload
return

;写入词库
OnWrite:
	Gosub Write_DB
Return

;合并导出
OnBackup:
	MsgBoxRenBtn("单行单义","单行多义","取消")
	SchemaName_:=Wubi_Schema~="i)ci"?"含词":Wubi_Schema~="i)zi"?"单字":Wubi_Schema~="i)chaoji"?"超集":"字根"
	Gui +OwnDialogs
	MsgBox, 262723, 导出提示, 当前为「%SchemaName_%」方案，请选择码表导出格式！！！
	IfMsgBox, Yes
		Gosub Backup_DB
	else IfMsgBox, No
		Gosub Backup_DB_2
Return

;帮助
OnHelp:
	Run, rundll32.exe "%A_ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll"`, ImageView_Fullscreen %A_ScriptDir%\config\ReadMe.png,, UseErrorLevel
return

;设置面板
Onconfig:
if WinExist("样式面板"){
	Traytip,  警告提示:,不能重复打开「样式面板」窗口！,,2
	Return
}
else
	Gosub Show_Setting
return

;退出设定
OnExit:
	DB.CloseDB()
	;FileDelete, %A_ScriptDir%\Config\Script\wubi98_ci.json
	;Gosub Backup_Conf
	if Logo_Switch ~="i)on"
		Gosub Write_Pos
	;if not A_OSVersion ~="i)WIN_XP"
	;{
		;SwitchToChsIME()
	;	Traytip,  退出提示:,已切换至中文键盘！
	;}
	ExitApp
return

;gui候选框
houxuankuangguicreate:
	Gui, houxuankuang:Destroy
	Gui, houxuankuang:+ToolWindow -Caption -DPIScale +AlwaysOnTop +hWndguihouxuankuang +Border
	Gui, houxuankuang:Font,s%FontSize% , %FontType%
	Gui, houxuankuang:Color, %BgColor%
	Gui, houxuankuang:Add, Text, x5 y3 vmyedit1 BackgroundTrans c%FontCodeColor%
	if Gdip_Line ~="i)on"
		Gui, houxuankuang:Add, Text, x0 yp+15 w%A_ScreenWidth% h1 0x10 vfengefu
	Gui, houxuankuang:Add, Text, x5 vmyedit2 BackgroundTrans c%FontColor%
	Gui, houxuankuang:Show, % "Hide x" A_ScreenWidth//2-A_ScreenWidth//8 " y" A_ScreenHeight-200
	Tip1hWnd:=ToolTip(1, "", "Q1 B" BgColor " T" FontCodeColor " S" FontSize*A_ScreenDPI/96 " F" FontType)
	Tip2hWnd:=ToolTip(2, "", "Q1 B" BgColor " T" FontColor " S" FontSize*A_ScreenDPI/96 " F" FontType)
	Height:=60
Return

;提词结果处理
srf_tooltip:
	if srf_all_Input ~="^[\,\#0-9]+"
	{
		srf_all_Input :=RegExReplace(srf_all_Input,"^\,","#")
		num_switch :=numTohz(srf_all_Input)
		StringSplit, num_for_select_arrays, num_switch, `n, `n
		if !num_switch
			tooltip(1)
		else
		{
			srf_for_select_for_tooltip :=num_for_select_arrays1 . "`n" . num_for_select_arrays2 . "`n" . num_for_select_arrays3 . "`n" . num_for_select_arrays4 . "`n" . num_for_select_arrays5
		}
	}

	If (limit_code ~="i)on"&&!EN_Mode)
	{
		if (StrLen(srf_all_input)=4&&srf_all_input ~="^[a-yA-Y]*$")
		{
			if srf_for_select_Array.Length()=0{    ;如果无候选，则自动清空历史
				srf_for_select_for_tooltip:=
			}
			else if (srf_for_select_Array.Length()=1&&length_code~="i)on") ;如果候选唯一，则自动上屏
			{
				srf_select(1)
				gosub srf_value_off
				srf_for_select_Array :=[]
			}
		}
		else if (StrLen(srf_all_input)>4&&srf_all_input ~="^[a-yA-Y]*$") ;五码顶字上屏，排除编码含z的拼音反查
		{
			if Textdirection ~="i)vertical"
			{
				loop,parse,srf_for_select_for_tooltip ,`n
				{
					sendinput % RegExReplace(A_LoopField,"^\d\.|〔.+|#\〔.+|>\d+\、|\d+\、|\s+","")
					break
				}
			}
			else
			{
				loop,parse,srf_for_select_for_tooltip ,%A_Space%
				{
					sendinput % RegExReplace(A_LoopField,"^\d\.|〔.+|#\〔.+|>\d+\.|\d+\.","")
					break
				}
			}
			srf_all_input :=RegExReplace(srf_all_input, "^[a-zA-Z]{4}", "")
			Gosub srf_tooltip_fanye
		}
		else if StrLen(srf_all_input)<4&&srf_for_select_Array.Length()=0&&srf_all_input ~="^[a-yA-Y]*$"
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
	global Caret:=GetCaretPos()
	Gosub showhouxuankuang
	strlen(srf_all_input)>4&&srf_for_select_Array.Length()<1?"":(srf_for_select_for_tooltip :=)
Return

;候选下一页
MoreWait:
	If (waitnum*ListNum+ListNum<srf_for_select_Array.Length()){
		waitnum+=1
		Gosub srf_tooltip_fanye
	}
Return

;候选上一页
lessWait:
	If (waitnum>0){
		waitnum-=1
		Gosub srf_tooltip_fanye
	}
Return

Frequency:
	Frequency:=WubiIni.Settings["Frequency"]:=Frequency?0:1, WubiIni.save()
	if !Frequency {
		For k,v In ["FTip","set_Frequency","RestDB"]
			GuiControl, 98:Disable, %v%
		OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
	}else{
		For k,v In ["FTip","set_Frequency","RestDB"]
			GuiControl, 98:Enable, %v%
		OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x292421})
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

MacInfo:
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
	if (srf_for_select_Array.Length()=0&&srf_all_Input ="help"){
		Textdirection:=Textdirection~="i)horizontal"?"vertical":"vertical", ListNum:=ListNum<10?11:10
		help_info:=[["简繁模式"," 热键" GetkeyName(s2thotkey) " 组合","〔 热键" GetkeyName(s2thotkey) " 组合 〕"]
			,["程序挂起"," 热键" GetkeyName(Suspendhotkey) " 组合","〔 热键" GetkeyName(Suspendhotkey) " 组合 〕"]
			,["以形查音"," ~键引导 ","〔 ~键引导 〕"]
			,["方案切换","〔 /sc 切换方案 〕","〔 /sc 切换方案 〕"]
			,["精准造词"," ``键引导+``键分词 ","〔 ``键引导+``键分词 〕"]
			,["划译反查"," 热键" GetkeyName(tiphotkey) " 开/关 ","〔 热键" GetkeyName(tiphotkey) " 开/关 〕"]
			,["临时英文"," 双``键引导 ","〔 双``键引导 〕"]
			,["快捷退出"," 热键" GetkeyName(exithotkey) " 组合","〔 热键" GetkeyName(exithotkey) " 组合 〕"]
			,["拼音反查"," z键引导 ","〔 z键引导 〕"]
			,["拆分显示"," 热键" GetkeyName(cfhotkey) " 组合","〔 热键" GetkeyName(cfhotkey) " 组合 〕"]
			,["批量造词"," 热键" GetkeyName(AddCodehotkey) " 组合 ","〔 热键" GetkeyName(AddCodehotkey) " 组合 〕"]], srf_for_select_Array:=help_info
	}else if (srf_for_select_Array.Length()=0&&srf_all_Input ="mac"){
		Textdirection:=Textdirection~="i)horizontal"?"vertical":"vertical", ListNum:=ListNum<10?10:10
		Mac_Array:=ComInfo.GetMacAddress_1(),IP_Array:=ComInfo.GetIPAddress_1()
		srf_for_select_Array.Push(ComInfo.GetSNCode_1()), srf_for_select_Array.Push(ComInfo.GetMacName())
	;获取本机外网IP接口
		if ipInfo:= ComInfo.GetIPAPI_2(),ipInfo.Length()>0
			srf_for_select_Array.Push(ipInfo)
	/*获取本机外网IP方法有：
		ComInfo.GetIPAPI_3()
		ComInfo.GetIPAPI_1()
		ComInfo.GetIPAPI()
		;;其它的接口方法在function.ahk文件中对照现成的方法自己写
	*/
		Loop,% Max(Mac_Array.Length(),IP_Array.Length())
		{
			srf_for_select_Array.Push(Mac_Array[A_Index])
			if not IP_Array[A_Index,1]~="^0\."
				srf_for_select_Array.Push(IP_Array[A_Index])
		}
	}
Return

;候选词条分页处理
srf_tooltip_fanye:
	;PrintObjects(srf_for_select_Array)
	for k,v in ["Textdirection","ListNum","FontSize"]
		if (WubiIni.TipStyle[v]<>%v%)
			%v%:=Textdirection:=WubiIni[Array_GetParentKey(WubiIni, v),v]
	if srf_all_Input ~="^``"{
		if (srf_all_Input~="^``[a-z]+"&&Wubi_Schema~="i)ci"){
			srf_for_select_Array:=format_word(RegExReplace(srf_all_Input,"^``"))
			if (srf_for_select_Array[1]<>select_arr&&select_arr[1]<>""){
				srf_for_select_Array.InsertAt(1, select_arr)
			}
			Gosub srf_tooltip_cut
		}else if RegExReplace(srf_all_Input,"^``")~="\``[a-z]+"{
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
				Gosub MacInfo
			else{
				srf_for_select_Array:=prompt_symbols(srf_all_Input), bianmaSJ:=StrSplit(EXEList_obj["FormatKey"],"/")
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
				If Array_isInValue(bianmaSJ,SubStr(srf_all_input,2)) {
					Textdirection:="vertical"
					If srf_for_select_Array.Length()>0 
						For key,value In EXEList_obj["formatDate"]
							srf_for_select_Array.InsertAt(A_Index,[ value[1]~="^[dghHmMsy]"?FormatTime("",value[1]):FormatTime(formatDate(value[1]),FormatDate(value[1],2,1))])
					else{
						For key,value In EXEList_obj["formatDate"]
							srf_for_select_Array.Push([ value[1]~="^[dghHmMsy]"?FormatTime("",value[1]):FormatTime(formatDate(value[1]),FormatDate(value[1],2,1))])
					}
				}
			}
		}else{
			Sym_Array_1[1,1]:=srf_all_input, srf_for_select_Array:=Sym_Array_1
		}
		Gosub srf_tooltip_cut
	}else if srf_all_Input ~="^z"{
		if srf_all_Input~="^z[a-z]+|^z\'[a-z]+" {
			srf_all_input:=RegExReplace(srf_all_input,"^z|^z\'",srf_all_input~="'"?"z":"z'"), srf_for_select_Array:=get_word(srf_all_input, Wubi_Schema)
		}else{
			if recent[1]{
				loop % objLength(recent)
					srf_for_select_Array[A_Index,1]:=recent[A_Index]
			}else{
				Sym_Array:=[],Sym_Array[1,1]:=srf_all_Input,srf_for_select_Array:=Sym_Array
			}
		}
		Gosub srf_tooltip_cut
	}else if srf_all_Input ~="^~"{
		if srf_all_Input ~="^~[a-z]+"
			srf_for_select_Array:=prompt_pinyin(srf_all_Input)
		else if srf_all_Input ~="^~$"
			Sym_Array:=[],Sym_Array[1,1]:=srf_all_Input, Sym_Array[2,1]:="～",srf_for_select_Array:=Sym_Array
		Gosub srf_tooltip_cut
	}else if srf_all_Input ~="^[a-y]{1,4}``"{
		srf_for_select_Array:=format_word_2(srf_all_Input)
		Gosub srf_tooltip_cut
	}else{
		If !EN_Mode {
			srf_for_select_Array:=get_word(srf_all_Input, Wubi_Schema)
			Gosub helpInfo
			Gosub srf_tooltip_cut
		}else{
			srf_for_select_Array:=Get_EnWord(srf_all_Input)
			Gosub srf_tooltip_cut
		} 

	}
Return

GetkeyName(hotkey:=""){
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
	srf_for_select_string:="", localpos:=1, srf_for_select_obj:=[]
	, loopindex:=srf_for_select_Array.Length()-ListNum*waitnum
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
							srf_for_select_string.=((srf_all_Input~="/\d+"?A_Space A_Space SubStr(Select_Code, Section-ListNum*waitnum , 1):(Cut_Mode~="on"?A_Space:A_Space A_Space) Section-ListNum*waitnum) "." srf_for_select_part), srf_for_select_obj.Push(((srf_all_Input~="/\d+"?SubStr(Select_Code, Section-ListNum*waitnum , 1):A_Space Section-ListNum*waitnum) "." srf_for_select_part))
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
							srf_for_select_string.=("`n" (srf_all_Input~="/\d+"?SubStr(Select_Code, Section-ListNum*waitnum , 1):Section-ListNum*waitnum) "." srf_for_select_part)
							srf_for_select_obj.Push(((srf_all_Input~="/\d+"?SubStr(Select_Code, Section-ListNum*waitnum , 1):A_Space Section-ListNum*waitnum) "." srf_for_select_part))
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
	srf_code:=srf_all_input~="^z\'[a-z]"?RegExReplace(srf_all_input,"^z\'"):(srf_all_input~="^``$"?RegExReplace(srf_all_input,"^``",(Wubi_Schema~="i)ci"?"〔精准造词〕":"〔常用符号〕")):srf_all_input~="^~$"?RegExReplace(srf_all_input,"^~","〔以形查音〕"):srf_all_input~="^````$"?RegExReplace(srf_all_input,"^````","〔临时英文〕"):srf_all_input)
	srf_code:=srf_code~="^``|^~"?RegExReplace(RegExReplace(srf_code,"^``|^~"),"``","'"):srf_code
	SysGet, _height, 14       ;获取光标高度
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
		Gui, measure:Font,s%FontSize% , %FontType%
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
			FocusGdipGui(srf_code, srf_for_select_obj, Caret.X, Caret.Y+_height, FontType)
		else
			GdipText(srf_code, srf_for_select_for_tooltip, Caret.X , Caret.Y+_height , FontType)
	}
Return

;清除操作
srf_value_off:
	Critical, On
	If (ToolTipStyle ~="i)on")
		ToolTip(1), ToolTip(2)
	Else If (ToolTipStyle ~="i)off")
		Gui, houxuankuang:Hide
	Else
		GdipText(""), FocusGdipGui("", "")
	srf_all_Input:=srf_for_select_for_tooltip:="", waitnum:=select_sym:=PosLimit:=0
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
Return

diyColor:
	Gosub DestroyGui
	Gui, diy: +hwndDIYTheme +Owner98   ; -DPIScale +AlwaysOnTop
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
	ImageButton.Create(BUBT, [6, 0x80404040, 0xC0C0C0, 0xFFD700], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
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
	Menu, SchemaList, Add, 98五笔•含词, sChoice4
	Menu, SchemaList, Add, 98五笔•单字, sChoice4
	Menu, SchemaList, Add, 98五笔•超集, sChoice4
	Menu, SchemaList, Add, 98五笔•字根, sChoice4
	Menu, SchemaList, Color, FFFFFF
	Menu, StyleMenu, Add, Tooltip样式, Export
	Menu, StyleMenu, Add, Gui候选框样式, Export
	Menu, StyleMenu, Add, Gdip候选框样式, Export
	Menu, StyleMenu, Color, FFFFFF
	if A_OSVersion ~="i)WIN_XP"
		Menu, StyleMenu, Disable, Gdip候选框样式
	HMENU := Menu_GetMenuByName("StyleMenu")
	SMENU := Menu_GetMenuByName("SchemaList")
	Menu, MainMenu, Add, 方案选择, :SchemaList
	Menu, MainMenu, Add,
	Menu, MainMenu, Add, 词库导入, ciku1
	Menu, MainMenu, Add, 词库合并导出, ciku2
	Menu, MainMenu, Add, 用户词管理, DB_management
	Menu, MainMenu, Color, FFFFFF
	Menu, Main, Add, 方案管理, :MainMenu
	Menu, Custom, Add, 自定义配色, diyColor
	Menu, Custom, Add, 主题管理, themelists
	Menu, Custom, Add,
	Menu, Custom, Add, 候选框风格, :StyleMenu
	Menu, Custom, Color, FFFFFF
	Menu, Main, Add, 候选框 , :Custom
	Menu, ExtendTool, Add, 超级标签管理, Label_management
	Menu, ExtendTool, Add, 标点符号映射, Sym_Gui
	Menu, ExtendTool, Add, 长字符串管理, LongStringlists
	Menu, ExtendTool, Add, 时间输出设定, format_Date
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
	TV2_2 := TV_Add("输入设定", TV2)
	TV2_3 := TV_Add("上屏设定", TV2)
	TV_Modify(TV2, "Expand")
	TV3 := TV_Add("快捷键设置",, "Bold")
	TV4 := TV_Add("码表管理",, "Bold")
	TV5 := TV_Add("关于",, "Bold")
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	TV_obj:={GBoxList1:["GBox1","themelogo","lineText1","Initialize","SBA13","TextInfo1","showtools","SrfSlider","SizeValue","set_SizeValue","ExSty","DPISty","select_theme","diycolor","themelists","TextInfo2","Backup_Conf","Rest_Conf","select_logo","TextInfo3","TextInfo4","TextInfo27","LogoColor_cn","LogoColor_en","LogoColor_caps"]
		,GBoxList2:["GBox2","TextInfo11","TextInfo25","StyleMenu","SBA5","SBA0","TextInfo12","SBA9","SBA10","SBA12","SBA19","SBA20","set_select_value","FontIN","font_size","TextInfo5","FontType","TextInfo6","font_value","TextInfo7","select_value","TextInfo8","set_regulate_Hx","set_regulate","TextInfo9","GdipRadius","set_GdipRadius","TextInfo10","set_FocusRadius","set_FocusRadius_value"]
		,GBoxList3:["GBox3","SBA7","SBA26","SBA27","SBA23","SBA24","UIAccess","SBA6","SBA14","SBA21","SBA3","SBA25","TextInfo13","TextInfo28","Frequency","TextInfo14","set_Frequency","RestDB","InputStatus","WinMode","CreateSC","Cursor_Status"]
		,GBoxList4:["GBox4","TextInfo15","SBA4","TextInfo16","sChoice1","TextInfo17","sChoice2","TextInfo18","sChoice3","TextInfo19","sethotkey_1","sethotkey_2","hk_1","tip_text","TextInfo20","SetInput_CNMode","SetInput_ENMode"]
		,GBoxList5:["GBox5","SBA1","s2t_hotkeys","SBA2","cf_hotkeys","SBA15","tip_hotkey","SBA16","Suspend_hotkey","SBA17","Addcode_hotkey","Exit_hotkey","SBA22"]
		,GBoxList6:["GBox6","sChoice4","TransformCiku","ciku9","ciku2","ciku8","ciku7","yaml_","ciku3","ciku4","ciku5","ciku6","ciku10","ciku11"]
		,GBoxList7:["GBox7","linkinfo1","linkinfo2","linkinfo3","versionsinfo","infos_"]}

	Gui, 98:Add, GroupBox,x+10 yp w400 h400 vGBox1, 主题配置
	Gui, 98:Add, Picture,xp+100 yp+30 h-1 vthemelogo, Config\Skins\preview\默认.png
	if FileExist(A_ScriptDir "\Config\Skins\preview\" ThemeName ".png")
		GuiControl,98:, themelogo,Config\Skins\preview\%ThemeName%.png
	else
		GuiControl,98:, themelogo,Config\Skins\preview\Error.png
	Gui 98:Add, Text,x190 y+5 w365 h2 0x10 vlineText1
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text,
	OD_Colors.SetItemHeight("S10 bold" , font_)
	Gui, 98:Add, Text,x190 yp vTextInfo1 left, 主题选择：
	themelist:=logoList:=""
	Loop Files, config\Skins\*.json
		themelist.="|" SubStr(A_LoopFileName,1,-5)
	Gui, 98:Add, DDL,x+5 yp w150 vselect_theme gselect_theme Section hwndHDDL +0x0210, % RegExReplace(themelist,"^\|")
	Gui, 98:Add, Text,x190 y+10 vTextInfo3 left, 配置管理：
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,x+5 yp-2 cred gBackup_Conf vBackup_Conf hwndCBT,备份配置
	ImageButton.Create(CBT, [6, 0x80404040, 0xC0C0C0, 0x00220b], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button,x+10 yp gRest_Conf vRest_Conf hwndRBT,恢复配置
	ImageButton.Create(RBT, [6, 0x80404040, 0xC0C0C0, 0x00220b], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button,x+10 yp gInitialize vInitialize hwndINBT,初始化
	ImageButton.Create(INBT, [6, 0x80404040, 0xC0C0C0, 0xc13a37], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	if !FileExist(A_ScriptDir "\Sync\Default.json")
		GuiControl, 98:Disable, Rest_Conf
	Loop Files, config\Skins\logoStyle\*.icl
		logoList.="|" SubStr(A_LoopFileName,1,-4)
	GuiControlGet, scvar, Pos , Backup_Conf
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text,x190 y+10 vTextInfo4 left, 功能条：
	Gui, 98:Add, DDL,x%scvarX% yp vselect_logo gselect_logo hWndSLCT +0x0210, % RegExReplace(logoList,"^\|")
	OD_Colors.Attach(HDDL,{T: 0xffe89e, B: 0x292421})
	OD_Colors.Attach(SLCT,{T: 0xffe89e, B: 0x292421})
	Gui, 98:Add, CheckBox,x+10 yp+2 vshowtools gshowtools Checked%srfTool%, 独立显示
	GuiControl, 98:ChooseString, select_logo, %StyleN%
	If Logo_Switch~="i)off"
		GuiControl, 98:Disable, select_logo
	Gui, 98:Add, Text,x190 y+10 vTextInfo27 left, 色块调整：
	Gui, 98:Add, Button, x%scvarX% yp w60 hwndhwndLogoColor_cn gsetlogocolor vLogoColor_cn
	Gui, 98:Add, Button, x+5 w60 hwndhwndLogoColor_en gsetlogocolor vLogoColor_en
	Gui, 98:Add, Button, x+5 w60 hwndhwndLogoColor_caps gsetlogocolor vLogoColor_caps
	CreateImageButton(hwndLogoColor_cn,[{BC: SubStr(LogoColor_cn,5,2) SubStr(LogoColor_cn,3,2) SubStr(LogoColor_cn,1,2), 3D: 0}],5)
	CreateImageButton(hwndLogoColor_en,[{BC: SubStr(LogoColor_en,5,2) SubStr(LogoColor_en,3,2) SubStr(LogoColor_en,1,2), 3D: 0}],5)
	CreateImageButton(hwndLogoColor_caps,[{BC: SubStr(LogoColor_caps,5,2) SubStr(LogoColor_caps,3,2) SubStr(LogoColor_caps,1,2), 3D: 0}],5)
	Gui, 98:Add, Edit, x+10 w60 Limit3 Number vSizeValue gSizeValue
	Gui, 98:Add, UpDown, x+0 w160 Range1-150 gset_SizeValue vset_SizeValue, % (LogoSize>0&&LogoSize<=150?LogoSize:36)
	GuiControlGet, lcvar, Pos , LogoColor_cn
	lctY:=lcvarY+lcvarH+10
	Gui, 98:Add, Slider,x%lcvarX% y%lctY% gSrfSlider vSrfSlider Center TickInterval10 ToolTipLeft Range0-255, % transparentX
	Gui, 98:Add, CheckBox,x%lcvarX% y+5 vSBA13 gSBA13, 指示器显隐
	Gui, 98:Add, CheckBox,x+5 Checked%DPIScale% vDPISty gDPISty, +DPIScale
	Gui, 98:Add, CheckBox,x+5 Checked%Logo_ExStyle% vExSty gExSty, 鼠标穿透
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox2, 候选框参数
	Gui,98:Font
	Gui,98:Font, s10 , %font_%
	Gui, 98:Add, CheckBox,x190 yp+40 vSBA5 gSBA5, 候选框位置固定
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,yp-3 x+5 vSBA0 gSBA0 hwndPBT, 坐标设置
	ImageButton.Create(PBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
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
	Gui, 98:Add, Text, x190 y+15 left vTextInfo5, 字体选择：
	Gui, 98:Add, ComboBox,x+10 gfonts_type vFontType hwndFontLists, % a_FontList
	CtlColors.Attach(FontLists, "black", "ffe89e")
	GuiControl, 98:ChooseString, FontType, %FontType%
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	if !FileExist("Font\*.otf")
		GuiControl, 98:Disable, FontIN
	Gui, 98:Add, Text, x190 y+15 left vTextInfo8, 候选框偏移：
	Gui, 98:Add, Edit, x+0 yp-3 w60 Limit2 Number vset_regulate_Hx gset_regulate_Hx
	Gui, 98:Add, UpDown, x+0 w160 Range3-25 gset_regulate vset_regulate, %Set_Range%
	GuiControlGet, EditVar1, Pos , set_regulate_Hx
	Gui, 98:Add, Text, x+20 yp+3 left vTextInfo7, 候选项数目：
	Gui, 98:Add, Edit, x+0 yp-3 w60 Limit2 Number vselect_value gselect_value
	Gui, 98:Add, UpDown, x+0 w160 Range3-10 gset_select_value vset_select_value, %ListNum%

	Gui, 98:Add, Text, x190 y+15 left vTextInfo9, 候选框圆角：
	Gui, 98:Add, Edit, x%EditVar1X% yp-3 w60 Limit2 Number vGdipRadius gGdipRadius
	Gui, 98:Add, UpDown, x+0 w160 Range0-15 gset_GdipRadius vset_GdipRadius, %Gdip_Radius%
	Gui, 98:Add, Text, x+20 yp-3 left vTextInfo10, 焦点项圆角：
	Gui, 98:Add, Edit, x+0 yp+3 w60 Limit2 Number vset_FocusRadius gset_FocusRadius
	Gui, 98:Add, UpDown, x+0 w160 Range0-18 gset_FocusRadius_value vset_FocusRadius_value, %FocusRadius%
	Gui, 98:Add, Text, x190 y+15 left vTextInfo6, 字体字号：
	Gui, 98:Add, Edit, x%EditVar1X% yp-3 w60 Limit2 Number vfont_value gfont_value
	Gui, 98:Add, UpDown, x+0 w160 Range9-40 gfont_size vfont_size, %FontSize%
	For Section, element In TV_obj
		For key,value In element
			if (Section="GBoxList2")
				GuiControl, 98:Hide, % value
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox3, 输入设定
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, CheckBox, x190 yp+45 gEnableUIAccess vUIAccess , 权限提升
	GuiControlGet, CheckVar1, Pos , EnableUIAccess
	Gui, 98:Add, CheckBox,x%CheckVar1X% yp+0 vSBA6 gSBA6, 符号顶屏
	GuiControlGet, CheckVar2, Pos , EnableUIAccess
	Gui, 98:Add, CheckBox,x%CheckVar2X% yp+0 vSBA3 gSBA3, 空码提示
	if PromptChar
	{
		Prompt_Word:=WubiIni.Settings["Prompt_Word"]:="off"
		GuiControl,98:, SBA24 , 0
	}
	Gui, 98:Add, CheckBox,x190 y+10 vSBA24 gSBA24 Checked%PromptChar%, 逐码提示
	Gui, 98:Add, CheckBox,x%CheckVar1X% yp+0 vSBA25 gSBA25 Checked%EN_Mode%, 英文模式
	Gui, 98:Add, CheckBox,x%CheckVar2X% yp+0 vSBA7 gSBA7, 四码唯一`n五码顶屏
	If limit_code~="i)off"
		GuiControl,98:Disable,SBA26
	if Prompt_Word~="i)on" {
		PromptChar:=WubiIni.Settings["PromptChar"]:=0
		GuiControl,98:, SBA3 , 0
	}
	Gui, 98:Add, CheckBox,x190 y+10 vSBA23 gSBA23 Checked%CharFliter%, GB2312过滤（单字方案）
	Gui, 98:Add, CheckBox,x%CheckVar2X% yp+0 vSBA26 gSBA26, 四码唯一上屏
	if (not Wubi_Schema ~="i)zi"||!FileExist("config\GB*.txt"))
		GuiControl, 98:Disable, SBA23
	Gui 98:Add, Text,x190 y+10 w365 h2 0x10 vTextInfo28
	Gui, 98:Add, CheckBox,x190 y+10 vSBA14 gSBA14, 中文模式使用英文标点
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,x+10 yp-2 vSBA21 gSBA21 hwndBBT, 标点映射设置
	ImageButton.Create(BBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui 98:Add, Text,x190 y+10 w365 h2 0x10 vTextInfo13
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 Checked%Frequency% vFrequency gFrequency, 动态调频
	if (not Wubi_Schema~="i)ci"||Trad_Mode~="i)on"||Prompt_Word~="i)on") {
		GuiControl, 98:Disable, Frequency
	}
	Gui, 98:Add, Text, x+5 yp vFTip left vTextInfo14, 调频参数：
	Gui, 98:Add, DDL,x+5 yp-3 w50 vset_Frequency gset_Frequency hWndFRDL +0x0210, 2|3|4|5|6|7|8
	OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x292421})
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button, x+10 yp-1 vRestDB gRestDB hWndRDBT, 重置词频
	ImageButton.Create(RDBT, [6, 0x80404040, 0xC0C0C0, "Red"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	if (not Wubi_Schema~="i)ci"||Trad_Mode~="i)on"||Prompt_Word~="i)on"||!Frequency) {
		OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		GuiControl, 98:Disable, FTip
		GuiControl, 98:Disable, set_Frequency
		GuiControl, 98:Disable, RestDB
	}
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 Checked%IStatus% vInputStatus gInputStatus, 输入状态控制
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button, yp-4 x+10 gWinMode vWinMode hWndWMBT,程序设置
	ImageButton.Create(WMBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button,x+10 yp vSBA27 gSBA27 hwndFTBT, 日期格式
	ImageButton.Create(FTBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, CheckBox,x190 y+10 Checked%CursorStatus% vCursor_Status gCursor_Status, 光标监控
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button,yp-4 x+10 cred gCreateSC vCreateSC hWndSCBT,建立桌面捷径
	ImageButton.Create(SCBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	if !IStatus
		GuiControl,98:Disable,WinMode
	For Section, element In TV_obj
		For key,value In element
			if (Section="GBoxList3")
				GuiControl, 98:Hide, % value
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox4, 上屏设定
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 yp+45 left vTextInfo15, 开机自启：
	Gui, 98:Add, DDL,x+25 w135  vSBA4 gSBA4 HwndSDDL4 +0x0210, 计划任务自启|快捷方式自启|不自启
	OD_Colors.Attach(SDDL4,{T: 0xffe89e, B: 0x292421})
	Gui, 98:Add, Text, x190 yp+45 left vTextInfo16, 上屏方式：
	Gui, 98:Add, DDL,x+25 w135  vsChoice1 gsChoice1 HwndSCDL1 +0x0210, 常规上屏|剪切板上屏
	OD_Colors.Attach(SCDL1,{T: 0xffe89e, B: 0x292421})
	Gui, 98:Add, Text, x190 yp+45  left vTextInfo17, Enter设定：
	Gui, 98:Add, DDL,x+20 w135 vsChoice2 gsChoice2 HwndSCDL2 +0x0210, 编码上屏|回车清空
	OD_Colors.Attach(SCDL2,{T: 0xffe89e, B: 0x292421})
	Gui, 98:Add, Text, x190 yp+45  left vTextInfo18, 候选模式：
	Gui, 98:Add, DDL,x+25 w135 vsChoice3 gsChoice3 HwndSCDL3 +0x0210, 候选横排|候选竖排
	OD_Colors.Attach(SCDL3,{T: 0xffe89e, B: 0x292421})
	Gui, 98:Add, Text, x190 yp+45  left vTextInfo19, 中英切换：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, DDL, vsethotkey_1 gsethotkey_1 x+25 yp-1 w60 HwndHKDL +0x0210, Ctrl|Shift|Alt|LWin
	OD_Colors.Attach(HKDL,{T: 0xffe89e, B: 0x292421})
	Gui 98:Add, Text, yp x+10 h22 w65 Center Border cblue vsethotkey_2 gsethotkey_2, % RegExReplace(Srf_Hotkey,"i)Shift|Ctrl|Alt|LWin|&","")
	Gui,98:Font
	Gui,98:Font, s9 bold, %font_%
	Gui, 98:Add, Button, yp+0 x+10 vhk_1 ghk_1 hWndGBKBT, 设置
	ImageButton.Create(GBKBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, text, yp+5 x+5 w70 cred vtip_text, %A_Space%
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 yp+45  left vTextInfo20, 默认状态：
	Gui, 98:Add, Radio,yp+0 x+30 vSetInput_CNMode gSetInput_Mode, 中文
	Gui, 98:Add, Radio,yp+0 x+30 vSetInput_ENMode gSetInput_Mode, 英文
	For Section, element In TV_obj
		For key,value In element
			if (Section="GBoxList4")
				GuiControl, 98:Hide, % value
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox5, 快捷键设置
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, CheckBox,x190 yp+45 vSBA1 gSBA1, 简繁切换>>
	Gui, 98:Add, Hotkey, x+0 yp-3 vs2t_hotkeys gs2t_hotkeys,% s2thotkey
	Gui, 98:Add, CheckBox,x190 yp+45 vSBA2 gSBA2, 拆分显示>>
	Gui, 98:Add, Hotkey, x+0 yp-3 vcf_hotkeys gcf_hotkeys,% cfhotkey
	Gui, 98:Add, CheckBox,x190 yp+45 vSBA15 gSBA15 Checked%rlk_switch%, 划译反查>>
	Gui, 98:Add, Hotkey, x+0 yp-3 vtip_hotkey gtip_hotkey,% tiphotkey
	Gui, 98:Add, CheckBox,x190 yp+45 vSBA16 gSBA16 Checked%Suspend_switch%, 程序挂起>>
	Gui, 98:Add, Hotkey, x+0 yp-3 vSuspend_hotkey gSuspend_hotkey,% Suspendhotkey
	Gui, 98:Add, CheckBox,x190 yp+45 vSBA17 gSBA17 Checked%Addcode_switch%, 批量造词>>
	Gui, 98:Add, Hotkey, x+0 yp-3 vAddcode_hotkey gAddcode_hotkey,% Addcodehotkey
	Gui, 98:Add, CheckBox,x190 yp+45 vSBA22 gSBA22 Checked%Exit_switch%, 快捷退出>>
	Gui, 98:Add, Hotkey, x+0 yp-3 vExit_hotkey gExit_hotkey,% exithotkey
	For Section, element In TV_obj
		For key,value In element
			if (Section="GBoxList5")
				GuiControl, 98:Hide, % value
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox6, 码表管理
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui, 98:Add, Button, x220 yp+45 vciku2 gciku2 hwndCKBT1,码表合并导出
	ImageButton.Create(CKBT1, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button, x+30 yp vciku8 gciku8 hWndCKBT8,含词主码表导出
	ImageButton.Create(CKBT8, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	GuiControlGet, budbvar, Pos , ciku2
	Gui, 98:Add, Button, x%budbvarX%  yp+50 vciku3 gciku3 hWndCKBT3,英文词库导入
	ImageButton.Create(CKBT3, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button, x+30 yp vciku4 gciku4 hWndCKBT4,英文词库导出
	ImageButton.Create(CKBT4, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button, x%budbvarX%  yp+50 vciku5 gciku5 hWndCKBT5,特殊符号导入
	ImageButton.Create(CKBT5, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button, x+30 yp vciku6 gciku6 hWndCKBT6,特殊符号导出
	ImageButton.Create(CKBT6, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button, x%budbvarX%  yp+50 vciku10 gciku10 hWndCKBT10,汉字拼音导入
	ImageButton.Create(CKBT10, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button, x+30 yp vciku11 gciku11 hWndCKBT11,汉字拼音导出
	ImageButton.Create(CKBT11, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button, x%budbvarX% yp+50 vciku7 gciku7 hWndCKBT7,自造词条导出
	ImageButton.Create(CKBT7, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, 98:Add, Button, x+30 yp vTransformCiku gTransformCiku hWndCKBT12,单义/多义转换
	ImageButton.Create(CKBT12, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui,98:Font
	Gui,98:Font, s10 norm, %font_%
	Gui, 98:Add, CheckBox,x%budbvarX% yp+50 vyaml_ gyaml_, 导出为yaml格式
	if !FileExist(A_ScriptDir "\Sync\header.txt")
		GuiControl, 98:Disable, yaml_
	For Section, element In TV_obj
		For key,value In element
			if (Section="GBoxList6")
				GuiControl, 98:Hide, % value
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox7, 关于
	Gui,98:Font
	Gui,98:Font, s9 c757575, %font_%
	Gui,98:Add, Text, x190 yp+35 w360 vinfos_ , `t%Startup_Name%是以AutoHotkey脚本语言编写的外挂类型形码输入法，借用同类型的「影子输入法」的实现思路通过调用众多WinAPI整合SQLite数据库实现文字输出等一系列功能。以「数据库码表性能」和「前端呈现」（调用Windows的GdiPlus.dll）两方面对文字内容直接发送上屏，而不进行传统输入法的转换操作，从XP至Win10皆能流畅运行。此版本为王码五笔98版专用，非98五笔的用户移步至「影子输入法」。
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui,98:Add, Link, y+15 vlinkinfo1, 简介：<a href="https://wubi98.gitee.io/2020/04/27/2019-12-03-031.yours/">程序简介</a>`nGit：<a href="https://github.com/OnchiuLee/AHK-Input-method">GitHub查看</a> | <a href="https://gitee.com/leeonchiu/AHK-Input-method">Gitee查看</a>`n使用帮助：<a href="config\ReadMe.png">点我查看详细说明</a>
	Gui,98:Add, Link, y+5 vlinkinfo2, 关于：<a href="https://wubi98.gitee.io/">https://wubi98.gitee.io/</a>`n资源库：<a href="http://98wb.ys168.com">http://98wb.ys168.com</a>
	Gui,98:Add, Link, y+5 vlinkinfo3, 查看码元图：<a href="config\码元图.jpg">点我查看五笔98版码元图</a>
	Gui,98:Add, Text, y+5 vversionsinfo, 版本日期：%Versions%
	For Section, element In TV_obj
		For key,value In element
			if (Section="GBoxList7")
				GuiControl, 98:Hide, % value
	Gui 98:color,ffffff
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, StatusBar,, 设置面板
	SB_SetText(A_Is64bitOS?"运行环境：" ComInfo.GetOSVersionInfo() "〔 AHK " A_AhkVersion "#64位 〕":"运行环境：" ComInfo.GetOSVersionInfo() "〔 AHK " A_AhkVersion "#32位 〕" )
	Gui, 98:Show,AutoSize,输入法设置
	Gosub ChangeWinIcon
	Gosub ControlGui
Return

ChangeWinIcon:
	;ChangeWindowIcon(IconName_)
	ChangeWindowIcon(A_ScriptDir "\Config\wubi98.icl",, 30)
Return

ChangeWindowIcon(IconFile, hWnd:="A", IconNumber:=1, IconSize:=128) {    ;ico图标文件IconNumber和IconSize不用填，如果是icl图标库需要填
	if (hWnd="A")
		hWnd := WinExist(hWnd)
	if (!hWnd)
		return "窗口不存在！"
	if not IconFile~="\.ico$"
		hIcon := LoadIcon(IconFile, IconNumber, IconSize)
	else
		hIcon := DllCall("LoadImage", uint, 0, str, IconFile, uint, 1, int, 0, int, 0, uint, LR_LOADFROMFILE:=0x10)
	if (!hIcon)
		return "图标文件不存在！"
	SendMessage, WM_SETICON:=0x80, ICON_SMALL2:=0, hIcon,, ahk_id %hWnd%  ; Set the window's small icon
	;;;SendMessage, STM_SETICON:=0x0170, hIcon, 0,, Ahk_ID %hWnd%
	SendMessage, WM_SETICON:=0x80, ICON_BIG:=1   , hIcon,, ahk_id %hWnd%  ; Set the window's big icon to the same one.
}


;获取exe/dll/icl文件中指定图标找返回
LoadIcon(Filename, IconNumber, IconSize)
{
	if DllCall("PrivateExtractIcons"
		, "str", Filename, "int", IconNumber-1, "int", IconSize, "int", IconSize
		, "ptr*", hIcon, "uint*", 0, "uint", 1, "uint", 0, "ptr")
		return hIcon
}

ExSty:
	GuiControlGet, ExSty ,, ExSty, Checkbox
	If ExSty {
		Logo_ExStyle:=WubiIni.TipStyle["Logo_ExStyle"]:=1, WubiIni.save()
	}else{
		Logo_ExStyle:=WubiIni.TipStyle["Logo_ExStyle"]:=0, WubiIni.save()
	}
	Gosub ShowSrfTip
Return

DPISty:
	GuiControlGet, DPISty ,, DPISty, Checkbox
	DPIScale:=WubiIni.Settings["DPIScale"]:=DPISty, WubiIni.save()
	if srfTool
		Gosub Schema_logo
	else
		Gosub Srf_Tip
Return

SrfSlider:
	transparentX:=WubiIni.TipStyle["transparentX"]:=SrfSlider, WubiIni.save()
	WinSet, TransColor, ffffff %transparentX%,Srf_Tip
	;WinSet, TransColor, EFEFEF %transparentX%,sign_wb
Return

SizeValue:
	GuiControlGet, SizeValue,, SizeValue, text
	if (SizeValue>0&&SizeValue<=150)
		LogoSize:=WubiIni.TipStyle["LogoSize"]:=SizeValue, WubiIni.save()
	else{
		LogoSize:=WubiIni.TipStyle["LogoSize"]:=36, WubiIni.save()
		GuiControl,98:, SizeValue ,% LogoSize
		Traytip,,输入的尺寸超限！
	}
	Gosub ShowSrfTip
Return

set_SizeValue:
	if (set_SizeValue>0&&set_SizeValue<=150)
		LogoSize:=WubiIni.TipStyle["LogoSize"]:=set_SizeValue, WubiIni.save()
	else{
		LogoSize:=WubiIni.TipStyle["LogoSize"]:=36, WubiIni.save()
		GuiControl,98:, set_SizeValue ,% set_SizeValue
		Traytip,,输入的尺寸超限！
	}
	Gosub ShowSrfTip
Return

CreateSC:
	if FileExist(A_Desktop "\" Startup_Name ".lnk"){
		FileGetShortcut, %A_Desktop%\%Startup_Name%.lnk , OutAHKPath, AHKOutDir, AHKOutArgs, , , ,
		if (A_ScriptFullPath<>SubStr(AHKOutArgs,2,-1)){
			FileDelete, %A_Desktop%\%Startup_Name%.lnk
			FileCreateShortcut, %A_AhkPath%, %A_Desktop%\%Startup_Name%.lnk , %A_ScriptDir%, "%A_ScriptFullPath%", % "位置: " A_Space SubStr(RegExReplace(A_AhkPath,".+\\"),1,-4) "(" SubStr(RegExReplace(A_AhkPath,RegExReplace(A_AhkPath,".+\\")),1,-1) ")", %A_ScriptDir%\config\wubi98.icl, , 30, 1
		}
	}else{
		FileCreateShortcut, %A_AhkPath%, %A_Desktop%\%Startup_Name%.lnk , %A_ScriptDir%, "%A_ScriptFullPath%", % "位置: " A_Space SubStr(RegExReplace(A_AhkPath,".+\\"),1,-4) "(" SubStr(RegExReplace(A_AhkPath,RegExReplace(A_AhkPath,".+\\")),1,-1) ")", %A_ScriptDir%\config\wubi98.icl, , 30, 1
	}
Return

FontIN:
	If FileExist("Font\*.otf") {
		Traytip,,字体安装中。。。
		Loop,Files,Font\*.otf
			AddFontResource(A_LoopFileLongPath)
		FontType:=WubiIni.TipStyle["FontType"]:="98WB-0", Cut_Mode:=WubiIni.Settings["Cut_Mode"] :="on", WubiIni.Save()
		DllCall("gdi32\EnumFontFamilies","uint",DllCall("GetDC","uint",0),"uint",0,"uint",RegisterCallback("EnumFontFamilies"),"uint",a_FontList:="")
		GuiControl,98:, FontType , |%a_FontList%
		GuiControl, 98:ChooseString, FontType, 98WB-0
	}else{
		Traytip,文件不存在！,,,3
	}
Return

TVGUI:
	Index_:= GetVisible()
	if (A_GuiEvent = "Normal"&&A_EventInfo) {
		TV_GetText(SelectedItem_, A_EventInfo)
		If (A_EventInfo != TV1&&A_EventInfo != TV2){
			SetVisibleHide(Index_,A_EventInfo), SetVisibleShow(A_EventInfo)
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
	global TV_obj,Index_,TV1_1,TV1,TV2,TV2_1,TV2_2,TV2_3,TV3,TV4,TV5,TV6
	_objNum:=EventInfo=TV1_1?1:EventInfo=TV2_1?2:EventInfo=TV2_2?3:EventInfo=TV2_3?4:EventInfo=TV3?5:EventInfo=TV4?6:EventInfo=TV5?7:EventInfo=TV6?8:Index_
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
	Gui IM:+LastFound +Owner98      ;; +AlwaysOnTop
	Gui, IM:Add, Button, y+10 vDTxck gDTxck hWndDTBT,删除
	ImageButton.Create(DTBT, [6, 0x80404040, 0xC0C0C0, "red"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	GuiControl,IM:Disable,DTxck
	Gui, IM:Add, Button, x+10 vAddProcess gAddProcess hWndAPBT,添加
	ImageButton.Create(APBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, IM:Add, DropDownList ,Choose1 w80 x+10 vIM_DDL gIM_DDL hWndIDDL +0x0210, 中文|英文|剪切板
	OD_Colors.Attach(IDDL,{T: 0x546a7c, B: 0xC0C0C0})
	GuiControl,IM:Disable,IM_DDL
	Gui, IM:Add, ListView, AltSubmit Grid r15 x10 yp+30 -LV0x10 -Multi Checked NoSortHdr -wscroll -WantF2 0x8 LV0x40 hwndIPView gIPView vIPView  ,进程名|输入状态
	For Section, element In EXEList_obj
		For key, value In element
			if (value<>""&&Section~="CN|EN|CLIP")
				LV_Add(value=EXEList_obj["CN",1]?"Select":"" ,value,Section="CN"?"中文":Section="EN"?"英文":"剪切板"),LV_ModifyCol()
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
	Gui, IM:Add, Button, y+10 vRTxck gRTxck hWndRTBT,刷新列表
	ImageButton.Create(RTBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	GuiControl, IM:Move, IPView, % "w" (A_ScreenDPI/96>1?ColWidth/(A_ScreenDPI/96):ColWidth)
	Gui,IM:Show, AutoSize,程序配置
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
		GuiControl,IM:,IM_DDL,% LVName_~="中文"?"|英文|剪切板":LVName_~="英文"?"|中文|剪切板":LVName_~="剪切板"?"|中文|英文":""
		;;GuiControl, IM:ChooseString, IM_DDL, % LVName_
		GuiControl,IM:Enable,IM_DDL
		OD_Colors.Attach(IDDL,{T: 0xffe89e, B: 0x292421})
		if LVName_~="剪切板" {
			GuiControl,IM:Disable,IM_DDL
			OD_Colors.Attach(IDDL,{T: 0x546a7c, B: 0xC0C0C0})
		}else{
			GuiControl,IM:Enable,IM_DDL
			OD_Colors.Attach(IDDL,{T: 0xffe89e, B: 0x292421})
		}
		LVName__:=LVName_="中文"?"CN":LVName_="英文"?"EN":"CLIP"
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, IM:Enable, DTxck
				GuiControl,IM:Disable,IM_DDL
				OD_Colors.Attach(IDDL,{T: 0x546a7c, B: 0xC0C0C0})
				break
			}else{
				GuiControl, IM:Disable, DTxck
				GuiControl,IM:Enable,IM_DDL
				OD_Colors.Attach(IDDL,{T: 0xffe89e, B: 0x292421})
				break
			}
		}
		ToolTip, % IsProcessInfo(LVName)   ;显示进程描述
	}
Return

AddProcess:
	Gui, 98:Hide
	TransGui("将光标放在要选择窗口的位置，然后按<左Ctrl键>获取进程名!`n如果不操作20s内自动获取位置进程名！", A_ScreenWidth/4 , A_ScreenHeight/2 , "s22","bold","cred")
	Gui, IM:hide
	keywait, LControl, D T20
	keywait, LControl
	TransGui()
	MouseGetPos, , , id
	WinGet, win_exe, ProcessName, ahk_id %id%,
	Set_IMode:=IMEmode~="i)off"?"EN":"CN", IModeCount:=Set_IMode~="i)EN"?"CN":"EN"
	If win_exe~="i)\.exe" 
	{
		if !Array_isInValue(EXEList_obj[Set_IMode], win_exe){
			if Array_isInValue(EXEList_obj[IModeCount], win_exe){
				Loop, % EXEList_obj[IModeCount].Length()
					if (EXEList_obj[IModeCount,A_Index]=win_exe)
						EXEList_obj[IModeCount].RemoveAt(A_Index)
				If EXEList_obj[Set_IMode].Length()>0
					EXEList_obj[Set_IMode].Push(win_exe), LV_Modify(LVPOS,"text",win_exe,IMEmode~="i)off"?"英文":"中文")
				else
					LV_Insert(LV_GetCount() ,"", win_exe, "中文"),EXEList_obj[Set_IMode]:=[ win_exe ]
			}else{
				If EXEList_obj[Set_IMode].Length()>0
					EXEList_obj[Set_IMode].Push(win_exe),LV_Insert(LV_GetCount() ,"", win_exe, IMEmode~="i)off"?"英文":"中文")
				else
					EXEList_obj[Set_IMode]:=[ win_exe ],LV_Insert(LV_GetCount() ,"", win_exe, IMEmode~="i)off"?"英文":"中文")
			}
			Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
			LV_ModifyCol(2,"100 center"), ColWidth:=0
			GuiControlGet, IMVar, Pos , IPView
			Loop % LV_GetCount("Column")
			{
				dIndex:=A_Index-1
				SendMessage, 4125, %dIndex%, , , ahk_id %IPView%  ; 4125 为 LVM_GETCOLUMNWIDTH.
				ColWidth+=ErrorLevel
			}
			GuiControl, IM:Move, IPView, % "w" (A_ScreenDPI/96>1?ColWidth/(A_ScreenDPI/96):ColWidth)
		}else
			Traytip,,该进程已存在！
	}
	Gui, 98:Show
	Gui, IM:show
Return

RTxck:
	LV_Delete()
	For Section, element In EXEList_obj
		For key, value In element
			if (value<>""&&Section~="CN|EN|CLIP")
				LV_Add(value=EXEList_obj["CN",1]?"Select":"" ,value,Section="CN"?"中文":Section="EN"?"英文":"剪切板")
Return

IM_DDL:
	GuiControlGet, IM_DDL,, IM_DDL, text 
	if (IM_DDL<>LVName_&&IM_DDL<>""&&LVName_<>""&&LVName~="i)\.exe$"&&IM_DDL<>"") 
	{
		if IM_DDL ~="中文" {
			if EXEList_obj["CN"].Length()>0
			{
				if Array_isInValue(EXEList_obj["EN"], LVName){
					Loop, % EXEList_obj["EN"].Length()
						if (EXEList_obj["EN",A_Index]=LVName)
							EXEList_obj["EN"].RemoveAt(A_Index), LV_Modify(LVPOS,"text",LVName,"中文"), EXEList_obj["CN"].Push(LVName)
				}else
					EXEList_obj["CN"].Push(LVName)
			}else{
				if Array_isInValue(EXEList_obj["EN"], LVName){
					Loop, % EXEList_obj["EN"].Length()
						if (EXEList_obj["EN",A_Index]=LVName)
							EXEList_obj["EN"].RemoveAt(A_Index), LV_Modify(LVPOS,"text",LVName,"中文"), EXEList_obj["CN"]:=[ LVName ]
				}else
					EXEList_obj["CN"]:=[ LVName ], LV_Insert(LV_GetCount() ,"", LVName, "中文")
			}
		}else if IM_DDL ~="英文" {
			if EXEList_obj["EN"].Length()>0
			{
				if Array_isInValue(EXEList_obj["CN"], LVName){
					Loop, % EXEList_obj["CN"].Length()
						if (EXEList_obj["CN",A_Index]=LVName)
							EXEList_obj["CN"].RemoveAt(A_Index), LV_Modify(LVPOS,"text",LVName,"英文"), EXEList_obj["EN"].Push(LVName)
				}else
					EXEList_obj["EN"].Push(LVName)
			}else{
				if Array_isInValue(EXEList_obj["CN"], LVName){
					Loop, % EXEList_obj["CN"].Length()
						if (EXEList_obj["CN",A_Index]=LVName)
							EXEList_obj["CN"].RemoveAt(A_Index), LV_Modify(LVPOS,"text",LVName,"英文"), EXEList_obj["EN"]:=[ LVName ]
				}else
					EXEList_obj["EN"]:=[ LVName ], LV_Insert(LV_GetCount() ,"", LVName, "英文")
			}
		}else if IM_DDL ~="剪切板" {
			if EXEList_obj["CLIP"].Length()>0
			{
				if !Array_isInValue(EXEList_obj["CLIP"], LVName){
					LV_Insert(LV_GetCount() ,"", LVName, "剪切板"), EXEList_obj["EN"].Push(LVName)
				}
			}else{
				LV_Insert(1 ,"", LVName, "剪切板"), EXEList_obj["CLIP"]:=[ LVName ]
			}
		}
		Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
	}
Return

DTxck:
	DelRows()
	Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
Return

DelRows(deb=""){
	global EXEList_obj
	Loop % (LV_GetCount(),a:=1)
	{	if ( LV_GetNext( 0, "C" ) = a )
		{	if ( !deb ){
				LV_GetText(LVar1, a , 1), LV_GetText(LVar2, a , 2)
				LV_Delete( a )
				Loop,% EXEList_obj[LVar2="中文"?"CN":LVar2="英文"?"EN":"CLIP"].Length()
					if (EXEList_obj[LVar2="中文"?"CN":LVar2="英文"?"EN":"CLIP",A_Index]=LVar1)
						EXEList_obj[LVar2="中文"?"CN":LVar2="英文"?"EN":"CLIP"].RemoveAt(A_Index)
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
	Gui, label: +hwndGuiLabel +Owner98 +OwnDialogs      ;+ToolWindow -DPIScale +AlwaysOnTop
	Gui,label:Font
	Gui,label:Font, s10 bold, %font_%
	Gui label:Add, GroupBox, y+10 w500 h450 vGBox8, 标签管理
	Gui,label:Font
	Gui,label:Font, s10, %font_%
	Gui, label:Add,Button,xm+15 yp+40 gDlabel vDlabel hWndDLBT, 删除
	ImageButton.Create(DLBT, [6, 0x80404040, 0xC0C0C0, "red"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	GuiControl, label:Disable, Dlabel
	Gui, label:Add, Button,x+5 gRlabel vRlabel hWndRLBT, 重置
	ImageButton.Create(RLBT, [6, 0x80404040, 0xC0C0C0, "Red"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, label:Add, Button,x+5 gBlabel vBlabel hWndBLBT, 导出
	ImageButton.Create(BLBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, label:Add, Button,x+5 gWlabel vWlabel hWndWLBT, 导入
	ImageButton.Create(WLBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, label:Add, Button,x+5 gUlabel vUlabel hWndULBT, 编辑
	ImageButton.Create(ULBT, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, label:Add, Edit, x+5 R1 w65 vSetlabel WantTab hWndLEdit
	Gui, label:Add, Button,x+5 gSavelabel vSavelabel hWndSLBT, 确定
	ImageButton.Create(SLBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	GuiControl, label:Hide, Setlabel
	GuiControl, label:Hide, Savelabel
	Gui,label:Font
	Gui,label:Font, s9, %font_%
	Gui, label:Add, ListView,xm+15 y+15 h350 w470 Grid AltSubmit NoSortHdr NoSort -WantF2 Checked -ReadOnly -Multi 0x8 LV0x40 -LV0x10 gMyLabel vMyLabel hwndHLV, 别名|标签名|标签说明
	GuiControl, +Hdr, MyLabel
	Gosub Glabel
	Gui, label:Color,ffffff
	Gui, label:Show,AutoSize, 标签管理
	Gosub ChangeWinIcon
Return

Glabel:
	If DB.gettable("SELECT * FROM label", Result){
		loop, % Result.RowCount
		{
			If islabel(Result.Rows[A_index,3])
				LV_Add("", Result.Rows[A_index,2], Result.Rows[A_index,3],SubStr(Result.Rows[A_index,4],2))    ;, LV_ModifyCol()
		}
		LV_ModifyCol(1,"80 left")
		LV_ModifyCol(2,"180 left")
		LV_ModifyCol(3,"190 left")
		;;CLV := New LV_Colors(HLV)
		;;CLV.SelectionColors(0xfecd1b)
	}
Return

MyLabel:
	if (A_GuiEvent = "Normal")
	{
		LV_GetText(labelName, A_EventInfo), posInfo:=A_EventInfo
		GuiControlGet, LsVar, label:Visible , Setlabel
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, label:Enable, Dlabel
				if LsVar {
					For k,v In ["Setlabel","Savelabel"]
						GuiControl, label:Disable, %v%
				}
				break
			}else{
				GuiControl, label:Disable, Dlabel
				if LsVar {
					For k,v In ["Setlabel","Savelabel"]
						GuiControl, label:Enable, %v%
					GuiControl,label:, Setlabel ,
				}
				break
			}
		}
		if LsVar
			EM_SetCueBanner(LEdit, labelName)
			;GuiControl,label:, Setlabel ,% labelName
	}
return

Rlabel:
	Gui +OwnDialogs
	MsgBox, 262452, 提示, 是否重置所有标签?
	IfMsgBox, Yes
	{
		LV_Delete()
		if DB.Exec("DROP TABLE label")>0
		{
			DB.Exec("create table label as select * from label_init")
			Gosub Glabel
		}
	}
return

Blabel:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,,3,请选择导出后保存的位置
	if OutFolder<>
	{
		if DB.gettable("SELECT B_Key,C_Key,D_Key FROM label",Result){
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
		FileEncoding, UTF-8
		FileRead, label_all, %LabelFile%
		Loop, Parse, label_all, `n, `r
		{
			count++
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
			Insert_label .="(null,'" tarr[1] "','" tarr[2] "','" tarr[3] "')" ","
		}
		Insert_label :=RegExReplace(Insert_label,"\,$","")
		if DB.Exec("INSERT INTO label VALUES" Insert_label "")>0
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
				DB.Exec("DELETE FROM label WHERE B_Key ='" LVar1 "';")
			}
		}else
			++a
	}
}

Ulabel:
	GuiControlGet, LsVar, label:Visible , Setlabel
	if LsVar {
		For k,v In ["Setlabel","Savelabel"]
			GuiControl, label:Hide, %v%
		For k,v In ["Setlabel","Savelabel"]
			GuiControl, label:Disable, %v%
		GuiControl,label:, Setlabel ,
	}else if (posInfo<>""&&!LsVar){
		GuiControlGet, opvar, label:Enabled , Dlabel
		For k,v In ["Setlabel","Savelabel"]
			GuiControl, label:Show, %v%
		ControlFocus , Edit1, A
		EM_SetCueBanner(LEdit, labelName)
		;GuiControl,label:, Setlabel ,% labelName
		if opvar {
			For k,v In ["Setlabel","Savelabel"]
				GuiControl, label:Disable, %v%
		}
	}
Return

Savelabel:
	GuiControlGet, Setlabel,, Setlabel, text
	if (not Setlabel~="\s+"&&Setlabel<>"") {
		if (DB.Exec("UPDATE label SET B_Key ='" Setlabel "' WHERE B_Key ='" labelName "';"))>0
		{
			LV_Modify(posInfo,"text",Setlabel)
			TrayTip,, 修改成功
		}
		For k,v In ["Setlabel","Savelabel"]
			GuiControl, label:Hide, %v%
		GuiControl,label:, Setlabel ,
	}
Return

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
	Gui, Key: +Owner98 +ToolWindow +E0x08000000  ;;+AlwaysOnTop
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
	Gui, Key: Add, StatusBar,vsbt,[ 请选取按键 。。。]
	Gui, Key: Show, NA, 小键盘
return

KeyGuiClose:
	Gui, Key: Destroy
	Gui, 98:show,NA
return

RunKey:
	k:=A_GuiControl
	GuiControl, 98:Text, tip_text,% ""
	if k not in Shift,Ctrl,Win,Alt
	{
		if not GetKeyState(k)~="\d" {
			Srf_Hotkey2:=KeyName[k]
		}else{
			Srf_Hotkey2:=k
		}
		sethotkey_2:=Srf_Hotkey2
		GuiControl, 98:Text, sethotkey_2, % Srf_Hotkey2
		Srf_Hotkey:=WubiIni.Settings["Srf_Hotkey"]:=(Srf_Hotkey1?Srf_Hotkey1:RegExReplace(Srf_Hotkey,"&.+","")) . (Srf_Hotkey2?"&":"") Srf_Hotkey2,WubiIni.save()
		Gosub KeyGuiClose
		Gui, 98:show,NA
	}else{
		Gui, Key:Font, s8 cRed Bold 
		GuiControl, Key:Font, sbt
		GuiControl,Key:, sbt , 该键名不支持，请重新选择！
	}
	if Srf_Hotkey2{
		GuiControl, 98:Text, tip_text , 已选择！
		Sleep 1500
		GuiControl, 98:Text, tip_text , 
	}
return

hk_1:
	if !sethotkey_2&&sethotkey_1
		Srf_Hotkey:=WubiIni.Settings["Srf_Hotkey"]:=Srf_Hotkey~="\&"?(Srf_Hotkey1 . "&" . RegExReplace(Srf_Hotkey,".+\&","")):Srf_Hotkey1, WubiIni.save()
	else if sethotkey_2&&!sethotkey_1
		Srf_Hotkey:=WubiIni.Settings["Srf_Hotkey"]:=Srf_Hotkey~="\&"?(RegExReplace(Srf_Hotkey,"\&.+","") . "&" . Srf_Hotkey2):RegExReplace(Srf_Hotkey,"\&.+",""), WubiIni.save()
	else if !sethotkey_2&&!sethotkey_1
		Srf_Hotkey:=Srf_Hotkey

	Hotkey, %Srf_Hotkey_%, SetHotkey,off
	Srf_Hotkeys :=hk_conv(Srf_Hotkey)
	Hotkey, %Srf_Hotkeys%, SetHotkey,on
	if ErrorLevel{
		Gui, 98:Font, s8 cRed Bold 
		GuiControl, 98:Font, tip_text
		GuiControl, 98:Text, tip_text , 设置失败，请重试!
		Sleep 2500
		GuiControl, 98:Text, tip_text , 
	}else{
		Gui, 98:Font, s8 cRed Bold 
		GuiControl, 98:Font, tip_text
		GuiControl, 98:Text, tip_text , 设置成功！
		Sleep 2500
		GuiControl, 98:Text, tip_text , 
	}
Return

sethotkey_1:
	GuiControlGet, sethotkey_1,, sethotkey_1, text
	global Srf_Hotkey1:=sethotkey_1
Return

sethotkey_2:
	Gui,98:Hide
	Gosub Key_
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
	For k,v In ["on","off","Gdip","ci","zi","chaoji","zg"]
	{
		if (ToolTipStyle~="i)" v)
			Menu_CheckRadioItem(HMENU, k)
		if (Wubi_Schema~="i)" v){
			Menu_CheckRadioItem(SMENU, k-3)
			GuiControl,98:choose, sChoice4 , % k-3
		}
	}
	if ToolTipStyle ~="i)off|on"{
		For k,v In ["SBA12","SBA9","SBA10","SBA19"]
			GuiControl, 98:Disable, %v%
	}
	For k,v In {Logo_ExStyle:"ExSty",PromptChar:"SBA24",BUyaml:"yaml_",PageShow:"SBA20",Exit_switch:"SBA22",FocusStyle:"SBA19",UIAccess:"UIAccess",symb_mode:"SBA14"}
		If (%k%)
			GuiControl,98:, %v% , 1
	For k,v In ["Ctrl","Shift","Alt","LWin"]
		if Srf_Hotkey~="i)" v
			GuiControl,98:choose, sethotkey_1 , %k%
	For k,v In {Radius:"SBA9",FontStyle:"SBA12",Logo_Switch:"SBA13",Gdip_Line:"SBA10",Fix_Switch:"SBA5",Prompt_Word:"SBA3",symb_send:"SBA6",limit_code:"SBA7",length_code:"SBA26"}
		if (%k%~="i)on")
			GuiControl,98:, %v% , 1
	if Logo_Switch~="off" {
		For k,v In ["SrfSlider","select_logo","ExSty","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps", "showtools","DPISty"]
			GuiControl, 98:Disable, %v%
	}
	If srfTool {
		For k,v In ["SrfSlider","ExSty","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps"]
			GuiControl, 98:Disable, %v%
	}
	if ToolTipStyle ~="i)on|off"{
		For k,v In ["LineColor","BorderColor","SBA19"]
			GuiControl, 98:Disable, %v%
	}
	if Wubi_Schema~="zi|zg"{
		For k,v In ["ciku1","ciku2"]
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
		GuiControl, 98:Disable, tip_hotkey
	else
		GuiControl,98:, SBA15 , 1
	if !Suspend_switch
		GuiControl, 98:Disable, Suspend_hotkey
	else
		GuiControl,98:, SBA16 , 1
	if !Addcode_switch
		GuiControl, 98:Disable, Addcode_hotkey
	else
		GuiControl,98:, SBA17 , 1

	if Initial_Mode~="i)on" {
		GuiControl,98:choose, sChoice1 , 2
	}else{
		GuiControl,98:choose, sChoice1 , 1
	}
	if Select_Enter~="i)clean" {
		GuiControl,98:choose, sChoice2 , 2
	}else{
		GuiControl,98:choose, sChoice2 , 1
	}
	if Textdirection~="i)vertical" {
		GuiControl,98:choose, sChoice3 , 2
	}else{
		GuiControl,98:choose, sChoice3 , 1
	}


	if !GET_IMESt(){
		GuiControl,98:choose, mothod , 1
	}else{
		GuiControl,98:choose, mothod , 2
	}
	if Fix_Switch~="i)on"{
		GuiControl, 98:Enable, SBA0
	}else{
		GuiControl, 98:Disable, SBA0
	}

	if cf_swtich {
		GuiControl,98:, SBA2 , 1
	}else{
		GuiControl, 98:Disable, cf_hotkeys
	}
	if not FontType ~="i)" FontExtend
		GuiControl, 98:Disable, SBA2
	if s2t_swtich {
		GuiControl,98:, SBA1 , 1
	}else{
		GuiControl, 98:Disable, s2t_hotkeys
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
		For k,v In ["set_GdipRadius","GdipRadius"]
			GuiControl, 98:Disable, %v%
	}
Return

Show_Setting:
	Gosub More_Setting
Return

EnableUIAccess(hwnd:=""){
	global WubiIni, UIAccess
	If (hwnd){
		GuiControlGet, UIAccess, 98:, UIAccess
		WubiIni["Settings","UIAccess"]:=UIAccess, WubiIni.Save()
		Try Run % StrReplace(DllCall("GetCommandLine", "Str"), "_UIA.exe", ".exe")
		ExitApp
	}
	If (UIAccess&&!InStr(DllCall("GetCommandLine", "Str"), "_UIA.exe")){
		AhkName:=RegExReplace(A_AhkPath,".+\\|\.exe"), AhkPath:=RegExReplace(A_AhkPath,".exe$",(A_AhkPath~="i)_UIA"?".exe":"_UIA.exe"))
		If FileExist(StrReplace(A_ProgramFiles, " (x86)") "\AutoHotkey\" AhkName "_UIA.exe"){
			Run % """" StrReplace(A_ProgramFiles, " (x86)") "\AutoHotkey\" AhkName "_UIA.exe"" """ A_ScriptFullPath """"
		} Else If (A_ScriptFullPath~=StrReplace(A_ProgramFiles, " (x86)")){
			If !FileExist(StrReplace(A_AhkPath, ".exe", "_UIA.exe"))
				Try RunWait *RunAs "%A_AhkPath%" "%A_ScriptDir%\Config\Script\EnableUIAccess.ahk" EnableUIAccess
				Catch
					Goto Exception
			Run % """" StrReplace(A_AhkPath, ".exe", "_UIA.exe") "\" AhkName "_UIA.exe"" """ A_ScriptFullPath """"
		} Else {
			Try RunWait *RunAs "%A_AhkPath%" "%A_ScriptDir%\Config\Script\EnableUIAccess.ahk" EnableUIAccess
			Catch
				Goto Exception
			if FileExist(StrReplace(A_ProgramFiles, " (x86)") "\AutoHotkey\" AhkName "_UIA.exe")
				Run % """" StrReplace(A_ProgramFiles, " (x86)") "\AutoHotkey\" AhkName "_UIA.exe"" """ A_ScriptFullPath """"
			else{
				Run *RunAs "%AhkPath%" /restart "%A_ScriptFullPath%"
			}
		}
		ExitApp
	} Else If (!hwnd&&!UIAccess&&FileExist(StrReplace(A_ProgramFiles, " (x86)") "\AutoHotkey"))
		Try Run *RunAs "%A_AhkPath%" "%A_ScriptDir%\Config\Script\EnableUIAccess.ahk"
	Return
	Exception:
		WubiIni["Settings","UIAccess"]:=UIAccess:=0
		If (hwnd)
			GuiControl, 98:, UIAccess, 0
	Return
	CNID:=WubiIni.Settings["CNID"]:=CpuID, WubiIni.Save()
}

sChoice1:
	GuiControlGet, sChoice1,, sChoice1, text
	if sChoice1~="常规" {
		Initial_Mode:=WubiIni.Settings["Initial_Mode"]:="off",WubiIni.save()
		GuiControl,logo:, Pics4,*Icon9 config\Skins\logoStyle\%StyleN%.icl
	}else{
		Initial_Mode:=WubiIni.Settings["Initial_Mode"]:="on",WubiIni.save()
		GuiControl,logo:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
	}
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
	Gui, ts: +Owner98  ;+ToolWindow   ;;+AlwaysOnTop -DPIScale 
	Gui, ts:font,,%Font_%
	SysGet, CXVSCROLL, 2
	ts_width:=620+CXVSCROLL
	Gui, ts:Add, ListView, r15 w%ts_width% Grid AltSubmit ReadOnly NoSortHdr NoSort -WantF2 -Multi 0x8 LV0x40 -LV0x10 vLongString hwndLSLV, 编码|【 副标题 】|【 标题 】|【 标题释义 】
	DB.gettable("select * from TangSongPoetics ORDER BY A_Key,Author ASC;",Result)
	CountNum:=0, lineCount:=Result.RowCount, pageNum:=ceil(lineCount/40)
	Gosub GetLongString
	Gui, ts:font
	Gui, ts:font,bold,%Font_%
	Gui, ts:Add, Button, Section gLongStringWrite vLongStringWrite hWndLSBT1, 导入
	ImageButton.Create(LSBT1, [6, 0x80404040, 0xC0C0C0, "yellow"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, ts:Add, Button, x+10 yp Section gLongStringBackup vLongStringBackup hWndLSBT2, 导出
	ImageButton.Create(LSBT2, [6, 0x80404040, 0xC0C0C0, "yellow"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, ts:Add, Button, x+10 yp Section gLastpage_chars vLastpage_chars hWndLastpage_chars, 上一页
	ImageButton.Create(Lastpage_chars, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, ts:Add, Button, x+10 yp Section gNextpage_chars vNextpage_chars hWndNextpage_chars, 下一页
	ImageButton.Create(Nextpage_chars, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	GuiControl,ts:Disable,Lastpage_chars
	If (lineCount<40||!lineCount)
		GuiControl,ts:Disable,Nextpage_chars
	Gui, ts:font
	Gui, ts:font,norm,%Font_%
	Gui, ts:Add, StatusBar,, 1
	SB_SetText(A_Space CountNum+1 "/" pageNum . "页")
	Gui, ts:show, AutoSize, 长字符串管理 ● 输出方法：/+编码+z结尾
	Gosub ChangeWinIcon
Return

GetLongString:
	If Result.RowCount>0
		loop,% (CountNum>=pageNum?lineCount-(CountNum-1)*40:40)
			LV_Add("", Result.Rows[CountNum*40+A_Index,1],Result.Rows[CountNum*40+A_Index,2],Result.Rows[CountNum*40+A_Index,3],Result.Rows[CountNum*40+A_Index,4])
	LV_ModifyCol(1,"60 "), LV_ModifyCol(2,"120 Center"), LV_ModifyCol(3,"200 Center"), LV_ModifyCol(4,"240 ")
	SB_SetText(A_Space CountNum+1 "/" pageNum . "页")
Return

tsGuiClose:
	tsGuiEscape:
	Gui, ts:Destroy
	WubiIni.Save()
Return

Nextpage_chars:
	CountNum++
	LV_Delete()
	Gosub GetLongString
	if (CountNum+1>=pageNum)
		GuiControl,ts:Disable,Nextpage_chars
	else
		GuiControl,ts:Enable,Lastpage_chars
Return

Lastpage_chars:
	CountNum--
	LV_Delete()
	Gosub GetLongString
	if (CountNum<1) 
		GuiControl,ts:Disable,Lastpage_chars
	else
		GuiControl,ts:Enable,Nextpage_chars
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
	Gui, themes: +Owner98  ;+ToolWindow   ;;+AlwaysOnTop -DPIScale 
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
	ImageButton.Create(SEBT, [6, 0x80404040, 0xC0C0C0, "red"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	GuiControl, themes:Disable, SelectV2
	Gui, themes:Add, Button, x+10 yp Section gSelectV3 hWndODBT, 打开目录
	ImageButton.Create(ODBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, themes:font
	Gui, themes:font,norm,%Font_%
	Gui, themes:Add, StatusBar,, 1
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
	SB_SetText(A_Space LV_GetCount() . "个主题")
	SB_SetIcon("Config\wubi98.icl",30)
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

themesGuiDropFiles:
	Loop, Parse, A_GuiEvent, `n, `r
	{
		if A_LoopField~="i)\.json$" {
			FileMove, %A_LoopField%, %A_ScriptDir%\config\Skins\, 1
			if FileExist(A_ScriptDir "\config\Skins\preview\" SubStr(RegExReplace(A_LoopField,".+\\"),1,-5) ".png")
				IsExists:="存在"
			else
				IsExists:="不存在"
			LV_Add("", SubStr(RegExReplace(A_LoopField,".+\\"),1,-5),IsExists,A_ScriptDir "\config\Skins\" RegExReplace(A_LoopField,".+\\")), LV_ModifyCol()
			GuiControl,98:, select_theme , % SubStr(RegExReplace(A_LoopField,".+\\"),1,-5)
			SB_SetText(A_Space LV_GetCount() . "个主题")
		}else if A_LoopField~="i)\.png$"{
			FileMove, %A_LoopField%, %A_ScriptDir%\config\Skins\preview\, 1
			if FileExist(A_ScriptDir "\config\Skins\preview\" RegExReplace(A_LoopField,".+\\"))
				IsExists:="存在"
			else
				IsExists:="不存在"
			loop, % LV_GetCount()
			{
				LV_GetText(OutTVar, A_Index , 1)
				if (OutTVar=SubStr(RegExReplace(A_LoopField,".+\\"),1,-4))
					LV_Modify(A_Index , ,, IsExists)
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
	SB_SetText(A_Space LV_GetCount() . "个主题")
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
	GuiControlGet, sChoice4,, sChoice4, text
	if (sChoice4~="词"||A_ThisMenuItem~="词") {
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="ci",WubiIni.save()
		Menu, More, Enable, 批量造词
		Menu, DB, Enable, 导入词库
		Menu, DB, Enable, 合并导出
		For k,v In ["ciku1","ciku2"]
			GuiControl, 98:Enable, %v%
		For k,v In ["SBA23"]
			GuiControl, 98:Disable, %v%
		GuiControl,logo:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
		GuiControl, 98:Enable, Frequency
		if !Frequency {
			For k,v In ["FTip","set_Frequency","RestDB"]
				GuiControl, 98:Disable, %v%
			OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		}else{
			For k,v In ["FTip","set_Frequency","RestDB"]
				GuiControl, 98:Enable, %v%
			OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x292421})
		}
	}else if (sChoice4~="单"||A_ThisMenuItem~="单"){
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="zi",WubiIni.save()
		Menu, More, Disable, 批量造词
		Menu, DB, Disable, 导入词库
		Menu, DB, Disable, 合并导出
		For k,v In ["ciku1","ciku2"]
			GuiControl, 98:Disable, %v%
		if FileExist("config\GB*.txt")
			GuiControl, 98:Enable, SBA23
		GuiControl,logo:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
		For k,v In ["FTip","set_Frequency","RestDB","Frequency"]
			GuiControl, 98:Disable, %v%
		OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
	}else if (sChoice4~="超"||A_ThisMenuItem~="超") {
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="chaoji",WubiIni.save()
		Menu, More, Disable, 批量造词
		Menu, DB, Enable, 导入词库
		Menu, DB, Enable, 合并导出
		For k,v In ["ciku1","ciku2"]
			GuiControl, 98:Enable, %v%
		For k,v In ["SBA23"]
			GuiControl, 98:Disable, %v%
		GuiControl,logo:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
		For k,v In ["FTip","set_Frequency","RestDB","Frequency"]
			GuiControl, 98:Disable, %v%
		OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
	}else if (sChoice4~="字根"||A_ThisMenuItem~="字根") {
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="zg",WubiIni.save()
		Menu, More, Disable, 批量造词
		Menu, DB, Disable, 导入词库
		Menu, DB, Disable, 合并导出
		For k,v In ["ciku1", "ciku2", "SBA23", "Frequency", "FTip", "set_Frequency", "RestDB"]
			GuiControl, 98:Disable, %v%
		GuiControl,logo:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
		OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
	}
	Gosub SelectItems
Return

mothod:
	;Hex2Str(DllCall("GetKeyboardLayout","UINT",DllCall("GetWindowThreadProcessId","UINT",WinActive("A"),"UINTP",0),UInt), 8, true)~="0409$"
	GuiControlGet, mothod,, mothod, text
	if mothod~="i)ime"{
		if !GET_IMESt(){
			if mothod~="英文键盘"{
				if A_IsSuspended
					Gosub OnSuspend
				SwitchIME(IME_GetKeyboardLayoutList()[mothod,3])
			}else{
				SwitchIME(IME_GetKeyboardLayoutList()[mothod,3])
				if !A_IsSuspended
					Gosub OnSuspend
			}
		}else
			SwitchIME(IME_GetKeyboardLayoutList()[mothod,3])
	}else{
		if !GET_IMESt()
			SwitchToChsIME()
		if !A_IsSuspended
			Gosub OnSuspend
		send {Ctrl down}{Shift down}{Ctrl up}{Shift up}
	}
Return

ciku1:
	Gosub Write_DB
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
			FileRead,pyAll,%FileNamePath%
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
	If DB.Exec("INSERT INTO PY VALUES" RegExReplace(Insert_ci,"\,$","") "")>0
		Return 1
}

DB_BackUpPy(FolderPath){
	global DB
	Result_All:=""
	DB.gettable("Select * from PY",Result)
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
		GuiControl, 98:Enable, s2t_hotkeys
		Hotkey, %s2thotkey%, Trad_Mode,on
	}else{
		GuiControl, 98:Disable, s2t_hotkeys
		Hotkey, %s2thotkey%, Trad_Mode,off
	}
	s2t_swtich:=WubiIni.Settings["s2t_swtich"]:=SBA,WubiIni.save()
Return

showtools:
	GuiControlGet, showtools ,, showtools, Checkbox
	srfTool:=WubiIni.Settings["srfTool"]:=showtools,WubiIni.save()
	If showtools {
		Gui, SrfTip:Hide
		Gui, logo:Show, NA h36 x%Logo_X% y%Logo_Y%,sign_wb
		For k,v In ["SrfSlider","ExSty","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps"]
			GuiControl, 98:Disable, %v%

	}else{
		Gui, logo:Hide
		Gosub Srf_Tip
		For k,v In ["SrfSlider","ExSty","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps"]
			GuiControl, 98:Enable, %v%
	}
Return

SBA2:
	GuiControlGet, SBA ,, SBA2, Checkbox
	if SBA {
		GuiControl, 98:Enable, cf_hotkeys
		Hotkey, %cfhotkey%, Cut_Mode,on
	}else{
		GuiControl, 98:Disable, cf_hotkeys
		Hotkey, %cfhotkey%, Cut_Mode,off
	}
	cf_swtich:=WubiIni.Settings["cf_swtich"]:=SBA,WubiIni.save()
Return

SBA3:
	GuiControlGet, SBA ,, SBA3, Checkbox
	if (SBA==1) {
		if PromptChar
			GuiControl,98:, SBA24 , 0
		Prompt_Word:=WubiIni.Settings["Prompt_Word"]:="on",PromptChar:=WubiIni.Settings["PromptChar"]:=0,WubiIni.save()
		For k,v In ["Frequency","FTip","set_Frequency","RestDB"]
			GuiControl, 98:Disable, %v%
		OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
	}else{
		Prompt_Word:=WubiIni.Settings["Prompt_Word"]:="off",WubiIni.save()
		GuiControl, 98:Enable, Frequency
		if Frequency {
			For k,v In ["FTip","set_Frequency","RestDB"]
				GuiControl, 98:Enable, %v%
			OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x292421})
		}else{
			For k,v In ["FTip","set_Frequency","RestDB"]
				GuiControl, 98:Disable, %v%
			OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
		}
	}
Return

SBA4:
	GuiControlGet, SBA,, SBA4, text
	if SBA~="计划任务" {
		Gosub Startup
	}else if SBA~="快捷方式" {
		Gosub CreateShortcut_Startup
	}else{
		Command = schtasks /Delete /TN %Startup_Name% /F
		Run *RunAs cmd.exe /c %Command%, , Hide
		if FileExist(A_Startup "\" Startup_Name ".lnk"){
			FileDelete, %A_Startup%\%Startup_Name%.lnk
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
	Fix_Switch:=WubiIni.TipStyle["Fix_Switch"]:=SBA?"on":"off", WubiIni.save()
	GuiControl, 98:Enable%SBA%, SBA0
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
	if (SBA==1) {
		limit_code:=WubiIni.Settings["limit_code"]:="on",WubiIni.save()
		GuiControl,98:Enable,SBA26
	}else{
		limit_code:=WubiIni.Settings["limit_code"]:="off",WubiIni.save()
		GuiControl,98:Disable,SBA26
	}
Return

SBA26:
	GuiControlGet, SBA ,, SBA26, Checkbox
	if (SBA==1) {
		length_code:=WubiIni.Settings["length_code"]:="on",WubiIni.save()
	}else{
		length_code:=WubiIni.Settings["length_code"]:="off",WubiIni.save()
	}
Return

format_Date:
	Gosub DestroyGui
	Gui, Date:Destroy
	Gui, Date:Default
	Gui, Date: +Owner98 hWndFormatDate
	Gui, Date: Margin,10,10
	Gui, Date: Color,ffffff
	Gui, Date:Font, s9 , %Font_%
	Gui, Date:Add, Button, xm-4 gUpLine vUpLine hWndUPBT, 上`n移
	GuiControl, Date:Disable,UpLine
	Gui, Date:Add, Button, gDnLine vDnLine hWndDnBT, 下`n移
	Gui, Date:Add, Button, gDelLine vDelLine hWndDELBT, 清`n空
	ImageButton.Create(UPBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	ImageButton.Create(DnBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	ImageButton.Create(DELBT, [6, 0x80404040, 0xC0C0C0, "Red"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, Date:Font, s9 , %Font_%
	Gui, Date:Add, ListView,x+6 ym r10 w450 Grid AltSubmit ReadOnly NoSortHdr NoSort -WantF2 -Multi 0x8 LV0x40 -LV0x10 gSetsj vSetsj hwndSJLV, 格式列|效果预览列
	SysGet, CXVSCROLL, 2
	LV_ModifyCol(1,"150"), LV_ModifyCol(2,300-CXVSCROLL)
	For Section,element In EXEList_obj["FormatDate"]
		If element[1]
			LV_Add(A_Index=1?"select":"",element[1],element[1]~="^[dghHmMsy]"?FormatTime("",element[1]):FormatTime(element[1],FormatTime(formatDate(element[1]),FormatDate(element[1],2,1))))
	Gui, Date:Font, s9 norm, %Font_%
	Gui, Date:Add,text,xm,输入字符设定：
	Gui, Date:Add, Edit,x+2 R1 w320 vSettKey WantTab hWndSetKey
	Gui, Date:Add, Button,x+5 gReloadSJ vReloadSJ hWndRSBT, 刷新
	Gui, Date:Add,text,xm,时间格式设定：
	Gui, Date:Add, Edit,x+2 R1 w320 vSettime WantTab hWndSettime
	EM_SetCueBanner(SetKey, "当前值：" EXEList_obj["FormatKey"] "【多个字段以/分离】")
	EM_SetCueBanner(Settime, "格式：公元年(ln)月日-周 周数 ")
	Gui, Date:Add, Button,x+5 gSaveSJ vSaveSJ hWndSSBT, 添加
	Gui, Date:Add, Picture,x+5 yp+4 w18 h-1 BackgroundTrans Icon155 vhelpico ghelpico, shell32.dll
	ImageButton.Create(SSBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	ImageButton.Create(RSBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, Date:Add,StatusBar,,输出以/+编码、双击删除行
	Gui, Date:Show,AutoSize,时间格式输出设定
	Gosub ChangeWinIcon
	ControlFocus , Edit2, A
Return

DateGuiClose:
DateGuiEscape:
	Gui, Date:Destroy
	Gui, Info:Destroy
Return

SBA27:
	Gosub format_Date
Return

UpLine:
	RowNum := 0, SelectLine:=0, Text:=Text_1:="", FormatDate:=[]
	Loop % LV_GetCount()+1
	{
		RowNum := LV_GetNext(RowNum)
		if not RowNum
			break
		LV_GetText(Text, RowNum), LV_GetText(Text_1, RowNum-1), SelectLine:=RowNum
	}
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
		LV_Modify(SelectLine-1 , "Select Focus", Text, Text~="^[dghHmMsy]"?FormatTime("",Text):FormatTime(Text,FormatTime(formatDate(Text),FormatDate(Text,2,1))))
		LV_Modify(SelectLine , "", Text_1, Text_1~="^[dghHmMsy]"?FormatTime("",Text_1):FormatTime(Text_1,FormatTime(formatDate(Text_1),FormatDate(Text_1,2,1))))
		Loop,% LV_GetCount() 
			LV_GetText(LineValue,A_Index), FormatDate.Push([LineValue])
		If (FormatDate.Length()=LV_GetCount())
			EXEList_obj["FormatDate"]:=FormatDate, Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
	}else{
		GuiControl, date:Disable,UpLine
		GuiControl, date:Enable,DnLine
	}
Return

DnLine:
	RowNum := 0, SelectLine:=0, Text:=Text_1:="", FormatDate:=[]
	Loop % LV_GetCount()+1
	{
		RowNum := LV_GetNext(RowNum)
		if not RowNum
			break
		LV_GetText(Text, RowNum), LV_GetText(Text_1, RowNum+1), SelectLine:=RowNum
	}
	If (SelectLine<LV_GetCount()) {
		If (SelectLine=LV_GetCount()-1)
			GuiControl, date:Disable,DnLine
		else
			GuiControl, date:Enable,DnLine
		if SelectLine>1
			GuiControl, date:Enable,UpLine
		LV_Modify(SelectLine+1 , "Select Focus", Text, Text~="^[dghHmMsy]"?FormatTime("",Text):FormatTime(Text,FormatTime(formatDate(Text),FormatDate(Text,2,1))))
		LV_Modify(SelectLine , "", Text_1, Text_1~="^[dghHmMsy]"?FormatTime("",Text_1):FormatTime(Text_1,FormatTime(formatDate(Text_1),FormatDate(Text_1,2,1))))
		Loop,% LV_GetCount() 
			LV_GetText(LineValue,A_Index), FormatDate.Push([LineValue])
		If (FormatDate.Length()=LV_GetCount())
			EXEList_obj["FormatDate"]:=FormatDate, Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
	}else{
		GuiControl, date:Enable,UpLine
		GuiControl, date:Disable,DnLine
	}
Return

DelLine:
	EXEList_obj["FormatDate"]:=[["yyyy-MM-dd HH:mm:ss"]], Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
	Gosub ReloadSJ
Return

FormatInfo:
	Gui, Info:Destroy
	Gui, Info:Default
	Gui, Info: +Owner98
	Gui, Info: Margin,10,10
	Gui, Info: Color,ffffff
	Gui, Info:Font, s10 bold, %Font_%
	Gui Info:Add, GroupBox,xm w450 h275, 格式设置说明：
	Gui, Info:Font, s9 bold, %Font_%
	Gui Info:Add, text,xm+10 yp+30 cred,中文格式：（分割符自行定义、输出以/+编码、双击删除行）
	Gui, Info:Font, s8 norm, %Font_%
	Gui Info:Add, text,y+5,年、月、日、时/点/全时/全点、分、秒、星期/周、周数、公元、ln(农历年)、ly(农历月)`n、lr(农历日)、ls(农历时辰)、节气、干支、关键字以``键转义可以不当作参数使用。
	Gui, Info:Font, s9 bold, %Font_%
	Gui Info:Add, text,xm+10 y+5 cred,英文格式：（分割符自行定义、输出以/+编码、双击删除行）
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

Setsj:
	if (A_GuiEvent = "DoubleClick"&&A_EventInfo) {
		LV_GetText(LineName, A_EventInfo), LV_Delete( A_EventInfo)
		For Section,element In EXEList_obj["FormatDate"]
		{
			If (element[1]= LineName) {
				If (EXEList_obj["FormatDate"].Length()=1)
					EXEList_obj["FormatDate"]:=[["yyyy-MM-dd HH:mm:ss"]]
				else
					EXEList_obj["FormatDate"].RemoveAt(Section)
			}
		}
		Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
	}else if (A_GuiEvent = "Normal"&&A_EventInfo) {
		If (A_EventInfo=1)
			GuiControl, Date:Disable,UpLine
		else
			GuiControl, Date:Enable,UpLine
		If (A_EventInfo=LV_GetCount())
			GuiControl, Date:Disable,DnLine
		else
			GuiControl, Date:Enable,DnLine
	}
Return

ReloadSJ:
	LV_Delete()
	For Section,element In EXEList_obj["FormatDate"]
		If element[1]
			LV_Add(A_Index=1?"select":"",element[1],element[1]~="^[dghHmMsy]"?FormatTime("",element[1]):FormatTime(element[1],FormatTime(formatDate(element[1]),FormatDate(element[1],2,1))))
	EM_SetCueBanner(SetKey, "当前值：" EXEList_obj["FormatKey"] "【多个字段以/分离】")
Return

SaveSJ:
	GuiControlGet, Settime,, Settime, text
	GuiControlGet, SettKey,, SettKey, text
	If (Settime||SettKey) {
		If (Settime<>"") {
			FTime:= Settime~="^[dghHmMsy]"?FormatTime("",Settime):FormatTime(formatDate(Settime),FormatDate(Settime,2,1))
			LV_Add("",Settime,FTime), EXEList_obj["FormatDate"].Push([Settime])
			GuiControl,date:,Settime,
		}
		If (SettKey<>"") {
			EXEList_obj["FormatKey"]:=SettKey
			GuiControl,date:,SettKey,
			EM_SetCueBanner(SetKey, "当前值：" EXEList_obj["FormatKey"] "【多个字段以/分离】")
		}
		Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
	}
Return

SBA9:
	GuiControlGet, SBA ,, SBA9, Checkbox
	if (SBA==1) {
		Radius:=WubiIni.TipStyle["Radius"]:="on",WubiIni.save()
		For k,v In ["set_GdipRadius","GdipRadius"]
			GuiControl, 98:Enable, %v%
	}else{
		Radius:=WubiIni.TipStyle["Radius"]:="off",WubiIni.save()
		For k,v In ["set_GdipRadius","GdipRadius"]
			GuiControl, 98:Disable, %v%
	}
Return

SBA10:
	GuiControlGet, SBA ,, SBA10, Checkbox
	if (SBA==1) {
		Gdip_Line:=WubiIni.TipStyle["Gdip_Line"]:="on",WubiIni.save()
	}else{
		Gdip_Line:=WubiIni.TipStyle["Gdip_Line"]:="off",WubiIni.save()
	}
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
	}else{
		For k,v In ["ExSty","SrfSlider","select_logo","set_SizeValue","SizeValue","LogoColor_cn","LogoColor_en","LogoColor_caps", "showtools","DPISty"]
		{
			If (srfTool&&not v~="select_logo|showtools") {
				GuiControl, 98:Disable, %v%
			}else
				GuiControl, 98:Enable, %v%
		}
	}
Return

SBA14:
	GuiControlGet, SBA ,, SBA14, Checkbox
	if (SBA==1) {
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
	if (SBA==1) {
		rlk_switch:=WubiIni.Settings["rlk_switch"]:=1,WubiIni.save()
		Hotkey, %tiphotkey%, SetRlk,on
		GuiControl, 98:Enable, tip_hotkey
	}else{
		rlk_switch:=WubiIni.Settings["rlk_switch"]:=0,WubiIni.save()
		Hotkey, %tiphotkey%, SetRlk,off
		GuiControl, 98:Disable, tip_hotkey
	}
Return

SBA16:
	GuiControlGet, SBA ,, SBA16, Checkbox
	if (SBA==1) {
		Suspend_switch:=WubiIni.Settings["Suspend_switch"]:=1,WubiIni.save()
		Hotkey, %Suspendhotkey%, SetSuspend,on
		GuiControl, 98:Enable, Suspend_hotkey
	}else{
		Suspend_switch:=WubiIni.Settings["Suspend_switch"]:=0,WubiIni.save()
		Hotkey, %Suspendhotkey%, SetSuspend,off
		GuiControl, 98:Disable, Suspend_hotkey
	}
Return

SBA17:
	GuiControlGet, SBA ,, SBA17, Checkbox
	if (SBA==1) {
		Addcode_switch:=WubiIni.Settings["Addcode_switch"]:=1,WubiIni.save()
		Hotkey, %Addcodehotkey%, Batch_AddCode,on
		if (Wubi_Schema~="i)ci"&&Addcode_switch)
		Menu, More, Enable, 批量造词
		GuiControl, 98:Enable, Addcode_hotkey
	}else{
		Addcode_switch:=WubiIni.Settings["Addcode_switch"]:=0,WubiIni.save()
		Hotkey, %Addcodehotkey%, Batch_AddCode,off
		Menu, More, Disable, 批量造词
		GuiControl, 98:Disable, Addcode_hotkey
	}
Return

SBA19:
	GuiControlGet, SBA ,, SBA19, Checkbox
	if SBA
		FocusStyle:=WubiIni.Settings["FocusStyle"]:=1,WubiIni.save()
	else
		FocusStyle:=WubiIni.Settings["FocusStyle"]:=0,WubiIni.save()
	Gosub srf_value_off
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
	Gui, Sym: +Owner98
	Gui, Sym:Font, s10 bold, %Font_%
	Gui, Sym:Add,Button,gInsert_sym hWndISBT,刷新
	ImageButton.Create(ISBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, Sym:Add,Button,x+10 yp gShowSymList vShowSymList hWndSSLBT,符号列表
	ImageButton.Create(SSLBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, Sym:Font, s10 underline, %Font_%
	Gui, Sym:Add, CheckBox,x+10 yp+5 h20 vHL gHiddenCol1ListView, 更改（首列禁止修改！）
	Gui, Sym:Font, s10 norm, %Font_%
	Gui, Sym:Add, ListView, xm y+10 w320 Grid NoSortHdr NoSort -WantF2 r15 gSubLV2 hwndHLV2 AltSubmit vLV2, 基础|英文标点|中文标点
	Gosub Insert_sym
	LV_ModifyCol(1, "60 Center"), LV_ModifyCol(2, "120 Center"), LV_ModifyCol(3, "120 Center")
	ICELV2 := New LV_InCellEdit(HLV2, True, True)
	ICELV2.OnMessage(False)
	Gui, Sym:Margin, 10, 10
	Gui, Sym:Color,ffffff
	Gui, Sym:Add, StatusBar,, 1
	SB_SetText("共计"LV_GetCount() . "组标点")
	Gui, Sym:Show, , 标点符号映射 
	Gosub ChangeWinIcon
Return

Insert_sym:
	LV_Delete()
	For Section, element In srf_symblos
	{
		LV_Add(“”,Section,element[1],element[2])
	}
	SB_SetText("共计"LV_GetCount() . "组标点")
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
			;ToolTip, % srf_symblos[keys,ColN-1] 
			ICELV2.Remove("Changed")
			Json_ObjToFile(srf_symblos, "Sync\srf_symblos.json")
		}
	}
Return

ShowSymList:
	Gui, SymList:Destroy
	Gui, SymList:Default
	Gui, SymList: +OwnerSym     ;; -DPIScale
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
	Gui, SymList:Add, StatusBar,, 1
	SB_SetText("双击复制到剪切板")
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
		Exit_switch:=WubiIni.Settings["Exit_switch"]:=1,WubiIni.save()
		Hotkey, %exithotkey%, OnExit,on
		GuiControl, 98:Enable, Exit_hotkey
	}else{
		Exit_switch:=WubiIni.Settings["Exit_switch"]:=0,WubiIni.save()
		Hotkey, %exithotkey%, OnExit,off
		GuiControl, 98:Disable, Exit_hotkey
	}
Return

SBA23:
	GuiControlGet, SBA ,, SBA23, Checkbox
	if (SBA==1) {
		CharFliter:=WubiIni.Settings["CharFliter"]:=1,WubiIni.save()
	}else{
		CharFliter:=WubiIni.Settings["CharFliter"]:=0,WubiIni.save()
	}
Return

CodingTips:
	PromptChar:=WubiIni.Settings["PromptChar"]:=PromptChar?0:1,WubiIni.save()
Return

SBA24:
	GuiControlGet, SBA ,, SBA24, Checkbox
	if (SBA==1) {
		if Prompt_Word~="i)on"
			GuiControl,98:, SBA3 , 0
		PromptChar:=WubiIni.Settings["PromptChar"]:=1, Prompt_Word:=WubiIni.Settings["Prompt_Word"]:="off",WubiIni.save()
		For k,v In ["Frequency","FTip","set_Frequency","RestDB"]
			GuiControl, 98:Enable, %v%
		OD_Colors.Attach(FRDL,{T: 0xffe89e, B: 0x292421})
	}else{
		PromptChar:=WubiIni.Settings["PromptChar"]:=0, WubiIni.save()
		For k,v In ["Frequency","FTip","set_Frequency","RestDB"]
			GuiControl, 98:Disable, %v%
		OD_Colors.Attach(FRDL,{T: 0x546a7c, B: 0xC0C0C0})
	}
Return

SBA25:
	GuiControlGet, SBA ,, SBA25, Checkbox
	EN_Mode:=WubiIni.Settings["EN_Mode"]:=SBA, WubiIni.save()
Return

CharFliter:
	if Wubi_Schema~="i)zi"
		CharFliter:=WubiIni.Settings["CharFliter"]:=CharFliter?0:1,WubiIni.save()
	else{
		CharFliter:=WubiIni.Settings["CharFliter"]:=0,WubiIni.save()
		Traytip,  警告提示:,当前方案无效，请切换至「单字」方案！,,2
	}
Return

s2t_hotkeys:
	if s2t_hotkeys
		Hotkey, %s2thotkey%, Trad_Mode,off
	s2thotkey:=WubiIni.Settings["s2t_hotkey"]:=s2t_hotkeys?s2t_hotkeys:"^+f", WubiIni.save()
	Hotkey, %s2thotkey%, Trad_Mode,on
Return

cf_hotkeys:
	if cf_hotkeys
		Hotkey, %cfhotkey%, Cut_Mode,off
	cfhotkey:=WubiIni.Settings["cf_hotkey"]:=cf_hotkeys?cf_hotkeys:"^+h", WubiIni.save()
	Hotkey, %cfhotkey%, Cut_Mode,on
Return

Suspend_hotkey:
	if Suspend_hotkey
		Hotkey, %Suspendhotkey%, SetSuspend,off
	Suspendhotkey:=WubiIni.Settings["Suspend_hotkey"]:=Suspend_hotkey?Suspend_hotkey:"!z", WubiIni.save()
	Hotkey, %Suspendhotkey%, SetSuspend,on
Return

tip_hotkey:
	if tip_hotkey
		Hotkey, %tiphotkey%, SetRlk,off
	tiphotkey:=WubiIni.Settings["tip_hotkey"]:=tip_hotkey?tip_hotkey:"!q", WubiIni.save()
	Hotkey, %tiphotkey%, SetRlk,on
Return

Addcode_hotkey:
	if Addcode_hotkey
		Hotkey, %AddCodehotkey%, Batch_AddCode,off
	AddCodehotkey:=WubiIni.Settings["Addcode_hotkey"]:=Addcode_hotkey?Addcode_hotkey:"^CapsLock", WubiIni.save()
	Hotkey, %AddCodehotkey%, Batch_AddCode,on
Return

Exit_hotkey:
	if Exit_hotkey
		Hotkey, %exithotkey%, OnExit,off
	exithotkey:=WubiIni.Settings["Exit_hotkey"]:=Exit_hotkey?Exit_hotkey:"^Esc", WubiIni.save()
	Hotkey, %exithotkey%, OnExit,on
Return

StyleMenu:
	WinGetPos, X, Y, W, H, ahk_id %HExportBtn%
	X += W // 2
	Menu_ShowAligned(HMENU, hwndgui98, X, Y, "Center", "Bottom")
	if A_ThisMenuItem~="i)gdip" {
		For k,v In ["SBA12","SBA9","SBA10","SBA19"]
			GuiControl, 98:Enable, %v%
	}else if A_ThisMenuItem~="i)on|off" {
		For k,v In ["SBA12","SBA9","SBA10","SBA19"]
			GuiControl, 98:Disable, %v%
	}else{
		if ToolTipStyle~="i)Gdip" {
			For k,v In ["SBA12","SBA9","SBA10","SBA19"]
				GuiControl, 98:Enable, %v%
		}else{
			For k,v In ["SBA12","SBA9","SBA10","SBA19"]
				GuiControl, 98:Disable, %v%
		}
	}
	if A_ThisMenuItem~="i)ToolTip" {
		GuiControl, 98:Enable, set_regulate_Hx
	}else{
		GuiControl, 98:Disable, set_regulate_Hx
	}
Return

Export:
	Menu_CheckRadioItem(HMENU, A_ThisMenuItemPos)
	if A_ThisMenuItem~="i)gdip"{
		GuiControl, 98:Text, StyleMenu , % A_ThisMenuItem
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="Gdip"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="22"
	}else if A_ThisMenuItem~="i)Gui"{
		GuiControl, 98:Text, StyleMenu , % A_ThisMenuItem
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="off"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="16"
	}else if A_ThisMenuItem~="i)ToolTip"{
		GuiControl, 98:Text, StyleMenu , % A_ThisMenuItem
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="on"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="16"
	}
	WubiIni.Save()
	Gosub SelectItems
	if ToolTipStyle ~="i)on|off"{
		For k,v In ["LineColor","BorderColor","set_GdipRadius","GdipRadius","SBA9","SBA10","SBA12","SBA19"]
			GuiControl, 98:Disable, %v%
		Gui, houxuankuang:Destroy
		Gosub houxuankuangguicreate
	}else{
		For k,v In ["LineColor","BorderColor","SBA9","SBA10","SBA12","SBA19"]
			GuiControl, 98:Enable, %v%
		if Radius~="i)on" {
			For k,v In ["set_GdipRadius","GdipRadius"]
				GuiControl, 98:Enable, %v%
		}
	}
Return

About:
	GuiControlGet, About,, About, text
	FileDelete, config\ReadMe.txt
	FileAppend,%About%, config\ReadMe.txt,UTF-8
return

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
	Gosub ShowSrfTip
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
	if FileExist(A_Startup "\" Startup_Name ".lnk"){
		FileGetShortcut, %A_Startup%\%Startup_Name%.lnk , OutAHKPath, AHKOutDir, AHKOutArgs, , , ,
		if (A_ScriptFullPath<>SubStr(AHKOutArgs,2,-1)){
			FileDelete, %A_Startup%\%Startup_Name%.lnk
			FileCreateShortcut, %A_AhkPath%, %A_Startup%\%Startup_Name%.lnk , %A_ScriptDir%, "%A_ScriptFullPath%", 一个便携式98五笔外挂式脚本输入法`n资源库下载地址:http://98wb.ys168.com/, %A_ScriptDir%\config\wubi98.icl, , 30, 1
			Startup :=WubiIni.Settings["Startup"]:="sc",WubiIni.save()
		}else{
			Startup :=WubiIni.Settings["Startup"]:="sc",WubiIni.save()
		}
		Traytip,,你已建立「%Startup_Name%」开机自启！
	}else{
		FileCreateShortcut, %A_AhkPath%, %A_Startup%\%Startup_Name%.lnk , %A_ScriptDir%, "%A_ScriptFullPath%", 一个便携式98五笔外挂式脚本输入法`n资源库下载地址:http://98wb.ys168.com/, %A_ScriptDir%\config\wubi98.icl, , 30, 1
		Startup :=WubiIni.Settings["Startup"]:="sc",WubiIni.save()
		Traytip,,你已建立「%Startup_Name%」开机自启！
	}
Return

;开机自启动>>>批处理创建系统自启任务
Startup:
	if FileExist(A_Startup "\" Startup_Name ".lnk"){
		FileDelete, %A_Startup%\%Startup_Name%.lnk
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
	Prompt_Word :=WubiIni.Settings["Prompt_Word"] :=Prompt_Word~="i)off"?"on":"off", WubiIni.save()
	if Prompt_Word ~="i)on"
		PromptChar:=WubiIni.Settings["PromptChar"] :=1?0:PromptChar, WubiIni.save()
return

;含词/单字选择
Wubi_Schema:
	Wubi_Schema :=WubiIni.Settings["Wubi_Schema"] :=Wubi_Schema~="i)zi|chaoji"?"ci":"zi", WubiIni.save()
	if Wubi_Schema ~="i)zi|zg"{
		Gosub Disable_Tray
		Menu, More, Disable, 批量造词
		if Wubi_Schema~="i)zi"
			GuiControl,logo:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
	}
	else if Wubi_Schema~="i)ci|chaoji"{
		Gosub Enable_Tray
		if Wubi_Schema~="i)ci"{
			Menu, More, Enable, 批量造词
			GuiControl,logo:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
		}else{
			Menu, More, Disable, 批量造词
			GuiControl,logo:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
		}
	}
	Gosub SelectItems
return

;超集方案选择
Extend_Schema:
	Wubi_Schema :=(Wubi_Schema~="i)zi|ci|zg"&&a_FontList ~="i)" FontExtend?"chaoji":"ci")
	if Wubi_Schema~="i)ci|chaoji"{
		Gosub Enable_Tray
		if Wubi_Schema~="i)ci"{
			Menu, More, Enable, 批量造词
			GuiControl,logo:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
		}else{
			Menu, More, Disable, 批量造词
			GuiControl,logo:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
		}
	}else{
		Gosub Disable_Tray
		Menu, More, Disable, 批量造词
		if Wubi_Schema~="i)zi"
			GuiControl,logo:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
	}
	if (Wubi_Schema<>"chaoji"){
		Traytip,提示,当前切换为「98含词」方案!
		WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema
		GuiControl,logo:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
	}
	else
		WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema
	WubiIni.save()
	Gosub SelectItems
return

;字根码表选择
ZG_Schema:
	Wubi_Schema :=WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema~="i)zi|ci|chaoji"?"zg":"ci", WubiIni.save()
	if Wubi_Schema~="i)zg|zi"{
		Menu, More, Disable, 批量造词
		if Wubi_Schema~="i)zi"
			GuiControl,logo:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
	}else{
		Menu, More, Enable, 批量造词
		if Wubi_Schema~="i)ci"
			GuiControl,logo:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,logo:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
	}
	Gosub SelectItems
Return

;字根拆分
Cut_Mode:
	Cut_Mode :=WubiIni.Settings["Cut_Mode"] :=Cut_Mode~="i)off"?"on":"off", WubiIni.save()
	Menu, More, Icon, 五笔拆分, shell32.dll, % Cut_Mode~="i)on"?145:222
	If (Cut_Mode ~="i)on")
		FontType :=WubiIni.TipStyle["FontType"]:="98WB-0", WubiIni.Save()
	if srf_all_input
		Gosub srf_tooltip_fanye
return

EN_Mode:
	EN_Mode :=WubiIni.Settings["EN_Mode"] :=EN_Mode?0:1, WubiIni.save()
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
	Trad_Mode :=WubiIni.Settings["Trad_Mode"] :=Trad_Mode~="i)off"?"on":"off", WubiIni.save()
	if Trad_Mode~="i)on"
		GuiControl,logo:, Pics2,*Icon6 config\Skins\logoStyle\%StyleN%.icl
	else
		GuiControl,logo:, Pics2,*Icon5 config\Skins\logoStyle\%StyleN%.icl
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
	if ToolTipStyle ~="i)on"
	{
		ToolTip(1), ToolTip(2)
		global ToolTipStyle :="off"
		global FontSize :=WubiIni.TipStyle["FontSize"]:=16
		WubiIni.TipStyle["ToolTipStyle"]:=ToolTipStyle, WubiIni.save()
	}
	else if ToolTipStyle ~="i)off"
	{
		Gui, houxuankuang:Hide
		global ToolTipStyle :="gdip"
		global FontSize :=WubiIni.TipStyle["FontSize"]:=22
		WubiIni.TipStyle["ToolTipStyle"]:=ToolTipStyle, WubiIni.save()
	}
	else if ToolTipStyle ~="i)gdip"
	{
		GdipText(""), FocusGdipGui("", "")
		global ToolTipStyle :="on"
		global FontSize :=WubiIni.TipStyle["FontSize"]:=14
		WubiIni.TipStyle["ToolTipStyle"]:=ToolTipStyle, WubiIni.save()
	}
	Gosub SelectItems
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
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
		Gui, 29: +LastFound hwndEditPlus    ;+ToolWindow +OwnDialogs +MinSize260x250 -MaximizeBox +Resize +AlwaysOnTop
		Gui, 29:font,s12
		Gui, 29:Margin,12,12
		Gui,29:Add, ListBox, r15 w420 gSet_Value vSet_Value +Multi hwndCodeEdit  ;+Multi
		Gui, 29:Font
		Gui, 29:font,s10 bold
		Gui, 29: add, Edit, r1 y+10 w290 gEditBox2 vEditBox2 hwndCodeEdit2, 
		Gui, 29: add, Button,x+5 gaddChars hWndGCBT, 添加
		ImageButton.Create(GCBT, [6, 0x80404040, 0xC0C0C0, "Green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
		Gui, 29: add, Button,x+5 w60 gaddFiles vaddFiles HWNDAFBT, 批量导入
		ImageButton.Create(AFBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
		Gui, 29:font,
		Gui, 29:font,s11 bold
		Gui, 29:Add, Button,xm gSave vSave hWndSVBT, 保存
		ImageButton.Create(SVBT, [6, 0x80404040, 0xC0C0C0, "Green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
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

addFiles:
	Gui +OwnDialogs
	FileSelectFile, SelectedFile, M3, %A_Desktop%, 选择你的纯词条文本文件, Documents (*.txt; *.yaml)
	if SelectedFile {
		FileArr:= StrSplit(SelectedFile,"`n"), OPCode_all:=OPCode_part:=OPCode:=ResultsAll:=""
		Loop, % FileArr.Length() 
		{
			if A_Index>1
			{
				FileEncoding,UTF-8
				FileRead, OPCode, %  FileArr[1] "\" FileArr[A_Index]
				Loop, Parse, OPCode, `n, `r
				{
					if A_LoopField~="\t[a-z]+"{
						RegExMatch(RegExReplace(A_LoopField,"\t\d+$"),"(?<=\t)[a-z]+",L_)
						RegExMatch(RegExReplace(A_LoopField,"\t\d+$"),"^.+(?=\t[a-z])",R_)
						if (StrLen(L_)>1&&StrLen(L_)<5)
							OPCode_part :=L_ "=" R_ 
					}else if A_LoopField~="^[a-z]+\="{
						OPCode_part:=RegExReplace(A_LoopField,"^\s+|\s+$")
					}else if not A_LoopField~="^[a-z0-9]+|\s+" {
						OPCode_part:=get_en_code(A_LoopField) "=" A_LoopField
					}
					OPCode_all.=OPCode_part "|", OPCode_part:=""
				}
				ResultsAll.=OPCode_all "|", OPCode_all:=""
			}
		}
		GuiControl,29:, Set_Value ,% ResultsAll
	}
Return

29GuiDropFiles:
	OPCode_all:=OPCode_part:=OPCode:=ResultsAll:=""
	Loop, % (_FilesPath:= StrSplit(A_GuiEvent,"`n")).Length()
	{
		FileEncoding,UTF-8
		FileRead, OPCode, % _FilesPath[A_Index]
		Loop, Parse, OPCode, `n, `r
		{
			if A_LoopField~="\t[a-z]+"{
				RegExMatch(RegExReplace(A_LoopField,"\t\d+$"),"(?<=\t)[a-z]+",L_)
				RegExMatch(RegExReplace(A_LoopField,"\t\d+$"),"^.+(?=\t[a-z])",R_)
				if (StrLen(L_)>1&&StrLen(L_)<5)
					OPCode_part :=L_ "=" R_ 
			}else if A_LoopField~="^[a-z]+\="{
				OPCode_part:=RegExReplace(A_LoopField,"^\s+|\s+$")
			}else if not A_LoopField~="^[a-z0-9]+|\s+" {
				OPCode_part:=get_en_code(A_LoopField) "=" A_LoopField
			}
			OPCode_all.=OPCode_part "|", OPCode_part:=""
		}
		ResultsAll.=OPCode_all "|", OPCode_all:=""
	}
	GuiControl,29:, Set_Value ,% ResultsAll
Return

;造词窗口关闭销毁
29GuiClose:
29GuiEscape:
	ControlGet, mb_add, List, Count,ListBox1, A
	if mb_add {
		Gui +OwnDialogs
		MsgBox, 262452,退出提示, 检测到你还没有保存，是否写入至词库？
		IfMsgBox, Yes
		{
			Gosub DROP_Status
			return_num :=Save_word(mb_add)
			if (return_num>0)
			{
				if (NotCount:=_ListCount-return_num)>0
					TrayTip,, 写入成功%return_num%条`n重复NotCount条
				else
					TrayTip,, 写入成功%return_num%条。
			}
			else
				TrayTip,, 词条已存在或格式不正确！
			ToolTip(1, "")
		}
	}
	Gui, 29:Destroy
	Result_:=Results_:=Result:=[]
Return

;造词保存处理
Save:
	ControlGet, mb_add, List, Count,ListBox1, A
	if mb_add {
		Gui +OwnDialogs
		MsgBox, 262452,批量造词,% "是否写入" _ListCount:= StrSplit(mb_add,"`n").Length() "行数据？"
		IfMsgBox, Yes
		{
			Gosub DROP_Status
			return_num :=Save_word(mb_add)
			if (return_num>0)
			{
				if (NotCount:=_ListCount-return_num)>0
					TrayTip,, 写入成功%return_num%条`n重复NotCount条
				else
					TrayTip,, 写入成功%return_num%条。
			}
			else
				TrayTip,, 词条已存在或格式不正确！
			ToolTip(1, "")
		}
		Gui, 29:Destroy
	}
return

;方案词库导入（超集+含词+单字）
Write_DB:
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
	MsgBox, 262452, 提示, 要导入以下词库进行替换？`n词库格式为：单行单义/单行多义
	IfMsgBox, No
	{
		TrayTip,, 导入已取消！
		Return
	} Else {
		if Wubi_Schema~="i)ci"
			Gosub Backup_CustomDB
		Start:=A_TickCount
		TrayTip,, 词库写入中，请稍后...
		Gosub DROP_Status
		Create_Ci(DB,MaBiaoFile)
		tarr:=[],count :=0
		FileEncoding, UTF-8
		FileRead, MaBiao, %MaBiaoFile%
		if MaBiao~="`n[a-z]+\s"
			MaBiao:=Transform_mb(MaBiao)
		else if not MaBiao~="\t\d+"
			MaBiao:=Transform_cp(MaBiao)
		totalCount:=CountLines(MaBiaoFile), num:=Ceil(totalCount/100)
		tip:=Wubi_Schema~="i)ci"?"【含词】":Wubi_Schema~="i)zi"?"【单字】":"【超集】"
		Progress, M1 FM14 W350, 1/%totalCount%, %tip%词库写入中..., 1
		Loop, Parse, MaBiao, `n, `r
		{
			count++
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
			if (tarr[3]){
				if Wubi_Schema~="i)ci"{
					if tarr[4]
						Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "','" tarr[4] "','" tarr[5] "','" split_wubizg(tarr[1]) "','" get_en_code(tarr[1]) "')" ","
					else
						Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "','" tarr[3] "','" tarr[3] "','" split_wubizg(tarr[1]) "','" get_en_code(tarr[1]) "')" ","
				}else{
					If not Wubi_Schema~="i)zg"
						Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "','" split_wubizg(tarr[1]) "','" get_en_code(tarr[1]) "')" ","
					else
						Insert_ci .="('" tarr[1] "','" tarr[2] "')" ","
				}
			}
			If (Mod(count, num)=0) {
				tx :=Ceil(count/num)
				Progress, %tx% , %count%/%totalCount%`n, %tip%词库写入中..., 已完成%tx%`%
			}
		}
		if DB.Exec(SQL :="INSERT INTO " Wubi_Schema " VALUES " RegExReplace(Insert_ci,"\,$","") ";")>0
		{
			ElapsedTime := (A_TickCount - Start)/1000
			if (ElapsedTime>60)
				timecount:=Ceil(ElapsedTime/60) "分" Mod(Ceil(ElapsedTime),60) "秒"
			Else
				timecount:=Ceil(ElapsedTime) "秒"
			TrayTip,, 写入%count%行！完成用时 %timecount%
			if Wubi_Schema~="i)ci"
				FileDelete, %A_ScriptDir%\Config\Script\wubi98_ci.json
		}
		else
		{
			TrayTip,, 格式不对...
			return
		}
		ToolTip(1,"")
	}
	Progress,off
	MaBiao:=Insert_ci:="",tarr:=[]
return

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
		Start:=A_TickCount
		TrayTip,, 词库写入中，请稍后...
		Create_En(DB,MaBiaoFile)
		tarr:=[],count :=0
		FileEncoding, UTF-8
		FileRead, MaBiao, %MaBiaoFile%
		Loop, Parse, MaBiao, `n, `r
		{
			count++
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
			Insert_ci .="('" tarr[1] "','" tarr[2] "')" ","
		}
		Insert_ci :=RegExReplace(Insert_ci,"\,$","")
		if bd ~="i)En"?(DB.Exec("INSERT INTO encode VALUES" Insert_ci "")):(DB.Exec("INSERT INTO symbols VALUES" Insert_ci ""))>0
		{
			ElapsedTime := (A_TickCount - Start)/1000
			if (ElapsedTime>60)
				timecount:=Ceil(ElapsedTime/60) "分" Mod(Ceil(ElapsedTime),60) "秒"
			Else
				timecount:=Ceil(ElapsedTime) "秒"
			TrayTip,, 写入%count%行！完成用时 %timecount%
		}
		else
		{
			TrayTip,, 格式不对...
			return
		}
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
		Start_out:=A_TickCount
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
			For Section,element In Result.Rows
			{
				if (element[2]=bianma)
					Resoure_ .=A_Space element[1]
				else
					Resoure_ .="`n" element[2] A_Space element[1]
				bianma:=element[2]
			}
			Resoure_:=RegExReplace(Resoure_,"^\n")
			ElapsedTime := (A_TickCount - Start_out)/1000
			if (ElapsedTime>60)
				timecount:=Ceil(ElapsedTime/60) "分" Mod(Ceil(ElapsedTime),60) "秒"
			Else
				timecount:=Ceil(ElapsedTime) "秒"
			fileNewname:=init_db?"主码表":custom_db?"用户词":Wubi_Schema
			FileDelete, %OutFolder%\wubi98-%fileNewname%_多义.txt
			FileAppend,%Resoure_%,%OutFolder%\wubi98-%fileNewname%_多义.txt, UTF-8
			Resoure_ :=OutFolder :="", custom_db:=init_db:=0, Result_:=Results_:=Result:=[]
			TrayTip,, 导出完成用时 %timecount%
		}else{
			TrayTip,, 导出失败！
			custom_db:=init:=0
		}
	}
Return

;词库导出（超集+含词+单字）
Backup_DB:
	Gui +OwnDialogs
	FileSelectFolder, OutFolder,*%A_ScriptDir%\Sync\,3,请选择导出后保存的位置
	if OutFolder<>
	{
		Start_out:=A_TickCount
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
			ElapsedTime := (A_TickCount - Start_out)/1000
			if (ElapsedTime>60)
				timecount:=Ceil(ElapsedTime/60) "分" Mod(Ceil(ElapsedTime),60) "秒"
			Else
				timecount:=Ceil(ElapsedTime) "秒"
			fileNewname:=init_db?"主码表":custom_db?"用户词":Wubi_Schema
			If (FileExist(A_ScriptDir "\Sync\header.txt")&&BUyaml&&!custom_db){
				FileRead,HeadInfo,%A_ScriptDir%\Sync\header.txt
				HeadInfo:=Wubi_Schema~="i)ci"?HeadInfo:(Wubi_Schema~="i)chaoji"?RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "wubi98_U"):Wubi_Schema~="i)zi"?RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "wubi98_dz"):RegExReplace(HeadInfo,"(?<=name\:).+",A_Space "wubi98_zg"))
				RegExMatch(HeadInfo,"(?<=name\:).+",FileInfo)
				FileInfo:=RegExReplace(FileInfo,"\s+")
				FileDelete, %OutFolder%\%FileInfo%.dict.yaml
				Resoure_:=HeadInfo "`n" Resoure_, HeadInfo:=""
				FileAppend,%Resoure_%,%OutFolder%\%FileInfo%.dict.yaml, UTF-8
			}else{
				FileDelete, %OutFolder%\wubi98-%fileNewname%_单义.txt
				FileAppend,%Resoure_%,%OutFolder%\wubi98-%fileNewname%_单义.txt, UTF-8
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
		Start_out:=A_TickCount
		if DB.gettable("SELECT aim_chars,A_Key FROM " (bd~="En"?"encode":"symbols") "",Result){
			FileDelete, %OutFolder%\wubi98-%bd%.txt
			Loop % Result.RowCount
			{
				Resoure_ .=Result.Rows[A_index,1] A_tab Result.Rows[A_index,2] "`n"
			}
			ElapsedTime := (A_TickCount - Start_out)/1000
			if (ElapsedTime>60)
				timecount:=Ceil(ElapsedTime/60) "分" Mod(Ceil(ElapsedTime),60) "秒"
			Else
				timecount:=Ceil(ElapsedTime) "秒"
			FileAppend,%Resoure_%,%OutFolder%\wubi98-%bd%.txt, UTF-8
			Resoure_ :=OutFolder :=""
		}	TrayTip,, 导出完成用时 %timecount%
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

;当前时间获取
get_time_now:
	StringRight, wk, A_YWeek, 2
	FormatTime, TimeVar, , tth时mm分ss秒
	FormatTime, DateVar, , ggyyyy年M月d日-ddd
	time=「%TimeVar%%A_MSec%"」
	send %time%
return

;农历日期时间获取
get_lunarDate_now:
	FormatTime, MIVar, , H
	FormatTime, RQVar, , yyyyMMdd
	lunar :=Date_GetLunarDate(RQVar)
	lunar_time :=Time_GetShichen(MIVar)
	send %lunar%%lunar_time%
return

;当前日期获取
get_date_now:
	StringRight, wk, A_YWeek, 2
	FormatTime, TimeVar, , tth时mm分ss秒
	FormatTime, DateVar, , ggyyyy年M月d日-ddd
	date=「%DateVar%｜第%wk%周」
	send %date%
return

;当前日期+时间获取
get_week_now:
	StringRight, wk, A_YWeek, 2
	FormatTime, TimeVar, , tth时mm分ss秒
	FormatTime, DateVar, , ggyyyy年M月d日-ddd
	week=「%DateVar%｜第%wk%周｜%TimeVar%%A_MSec%"」
	send %week%
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
		Menu, Tray, Icon, config\wubi98.icl,31, 1
		;if !GET_IMESt()
		;	SwitchToChsIME()
		Menu, TRAY, Rename, 禁用 , 启用
		Menu, TRAY, Icon, 启用, config\wubi98.icl, 4
		GuiControl,logo:, Pics,*Icon4 config\Skins\logoStyle\%StyleN%.icl
		Traytip,  提示:,已切换至挂起状态！
	}else if !A_IsSuspended {
		if FileExist(A_ScriptDir "\wubi98.ico")
			Menu, Tray, Icon, wubi98.ico
		else
			Menu, Tray, Icon, config\wubi98.icl,30
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
	rlk_switch:=WubiIni.Settings["rlk_switch"]:=rlk_switch?0:1,WubiIni.save()
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
	Gui, DB: +hwndDB_ +OwnDialogs +LastFound   ;+ToolWindow +OwnDialogs +MinSize435x470 +MaxSize550x520 -MaximizeBox +Resize -DPIScale +AlwaysOnTop
	Gui,DB:Font, s10 , %Font_%
	Gui, DB:Add, Button,y+10 Section gDB_Delete vDB_Delete hWndDDBT, 删除
	ImageButton.Create(DDBT, [6, 0x80404040, 0xC0C0C0, "red"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, DB:Add, Button,x+8 Section gDB_reload vDB_reload hWndDRBT, 刷新
	ImageButton.Create(DRBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	GuiControl, DB:Disable, DB_Delete
	Gui, DB:Add, Button,x+8 Section gDB_search vDB_search hWndDSBT, 搜索
	ImageButton.Create(DSBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, DB:Add, Edit, x+8 yp w180 vsearch_text gsearch_text hwndDBEdit
	Gui,DB:Font,
	Gui,DB:Font, s9, %font_%
	Gui, DB:Add, CheckBox, x+8 yp-2 vsearch_1 gsearch_1, 词频`n为零
	GuiControl, DB:Disable, search_1
	Gui,DB:Font,
	Gui,DB:Font, s10, %font_%
	GuiControl, DB:Hide, search_text
	GuiControl, DB:Hide, search_1
	Gui, DB:Add, ListView,R15 w400 xm+0 y+10 Grid AltSubmit ReadOnly NoSortHdr NoSort -WantF2 Checked -Multi 0x8 LV0x40 -LV0x10 gMyDB vMyDB hwndDBLV, 词条|编码|词频
	GuiControl, +Hdr, MyDB
	;;DLV := New LV_Colors(DBLV)
	;;DLV.SelectionColors(0xfecd1b)
	Gui,DB:Font,
	Gui,DB:Font, s10, %font_%
	Gui, DB:Add, Button,y+10 Section gDB_BU vDB_BU hWndDBBT, 导出全部
	ImageButton.Create(DBBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cblue, %font_%
	Gui, DB:Add, Button,x+150 yp Section vToppage gToppage hWndTPBT,首页
	ImageButton.Create(TPBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cred, %font_%
	Gui, DB:Add, Button,x+5 Section vuppage guppage HwndUPBT,上一页
	ImageButton.Create(UPBT, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui, DB:Add, Button,x+5 Section vnextpage gnextpage hWndNPBT,下一页
	ImageButton.Create(NPBT, [6, 0x80404040, 0xC0C0C0, "green"], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cblue, %font_%
	Gui, DB:Add, Button,x+5 Section vLastpage gLastpage hWndLPBT,尾页
	ImageButton.Create(LPBT, [6, 0x80404040, 0xC0C0C0, 0x0078D7], [ , 0x80606060, 0xF0F0F0, 0x606000],"", [0, 0xC0A0A0A0, , 0xC0606000])
	Gui,DB:Font,
	Gui,DB:Font, s10, %font_%
	Gui, DB:Add, StatusBar,vSBTIP,
	Gui, DB:Margin , 10, 10
	DB_Page:=1, DB_Count:=40
	Gosub ReadDB
	LV_ModifyCol(1,"150 left")
	LV_ModifyCol(2,"80 Center")
	LV_ModifyCol(3,"150 Integer Center")
	SB_SetText(A_Space "[  " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条  ]")
	;SB_SetIcon("Config\wubi98.icl",30)
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
	if (DB_Page=1||DB_Page=Ceil(Result_.RowCount/DB_Count))
		LV_Delete()
	loop % DB_Count
	{
		if (Result_.Rows[A_Index+(DB_Page-1)*DB_Count,1]<>""){
			if (DB_Page=1||DB_Page=Ceil(Result_.RowCount/DB_Count))
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
	SB_SetText(A_Space "[  " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条  ]")
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
	SB_SetText(A_Space "[  " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条  ]")
Return

DB_search:
	GuiControlGet, tVar, DB:Visible , search_text
	if !tVar{
		For k,v In ["search_text","search_1"]
			GuiControl, DB:Show, %v%
		For k,v In ["uppage","nextpage"]
			GuiControl, DB:Disable, %v%
		ControlFocus , Edit1, A
	}else{
		For k,v In ["search_text","search_1"]
			GuiControl, DB:Hide, %v%
		GuiControl,DB:, search_text ,
		GuiControl,DB:, search_1 , 0
		LV_Delete(),ss:=ResultCount:=RCount:=search_1:=0
		Gosub ReadDB
		if (Ceil(Result_.RowCount/DB_Count)<>1&&DB_Page<Ceil(Result_.RowCount/DB_Count))
			GuiControl, DB:Enable, nextpage
		else
			GuiControl, DB:Disable, nextpage
		if (DB_Page<2)
			GuiControl, DB:Disable, uppage
		else
			GuiControl, DB:Enable, uppage
	}
Return

search_1:
	GuiControlGet, search_1 ,, search_1, CheckBox
	if (search_text<>"")
		Gosub search_result
Return

search_text:
	GuiControlGet, tVar, DB:Visible , search_text
	GuiControlGet, search_text,, search_text, text
	If (search_text<>""&&tVar){
		For k,v In ["uppage","nextpage","Lastpage","Toppage"]
			GuiControl, DB:Disable, %v%
		For k,v In ["search_1"]
			GuiControl, DB:Enable, %v%
		Gosub search_result
	}else if (search_text=""&&tVar){
		For k,v In ["search_1"]
			GuiControl, DB:Disable, %v%
		ss:=0
		LV_Delete()
		Gosub ReadDB
		SB_SetText(A_Space "[  " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条  ]")
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
		{
			ResultCount:=RCount>Results_.RowCount?RCount:Results_.RowCount>DB_Count?Results_.RowCount:DB_Count
			loop % ResultCount
			{
				if (Results_.Rows[A_Index,1]<>""){
					counts:=A_Index
					if !LV_Modify(A_Index, A_Index=1?"Select":"", Results_.Rows[A_Index,1],Results_.Rows[A_Index,2],Results_.Rows[A_Index,3])
						LV_Add(A_Index=1?"Select":"", Results_.Rows[A_Index,1],Results_.Rows[A_Index,2],Results_.Rows[A_Index,3])
				}else{
					LV_Delete(counts+1)
				}
			}
			RCount:=ResultCount
		}else
			LV_Delete()
	}
	SB_SetText(A_Space "[ 共" LV_GetCount() . "条记录 ]")
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
			SB_SetText(A_Space "[ 第 " A_EventInfo " / " LV_GetCount() . " 条记录 ]")
		}else{
			SB_SetText("[  " (DB_Page-1)*DB_Count+A_EventInfo . " / " Result_.RowCount " 条  ]")
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
	SB_SetText(A_Space "[  " (DB_Page-1)*DB_Count+lineInfo . " / " Result_.RowCount-count " 条  ]")

}
