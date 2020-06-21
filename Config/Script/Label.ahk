;桌面logo
Schema_logo:
	Gui, 3:Destroy
	Gui, 3:Default
	Gui, 3: -Caption +AlwaysOnTop ToolWindow border -DPIScale +hwndWubi_Gui          ;  -DPIScale 禁止放大
	if FileExist(A_ScriptDir "\config\background.png"){
		Gui, 3:Add, Picture,x0 y0 h-1 w190,config\background.png
		Gui, 3:Add, Picture,x4 y4 h26 w181 border, config\background.png
	}else{
		Gui, 3:Add, Picture,x0 y0 h-1 w190 Icon33,config\wubi98.icl
		Gui, 3:Add, Picture,x4 y4 h26 w181 border Icon33, config\wubi98.icl
	}
	Gui, 3:Add, Picture,xp+3 yp+2 w22 BackgroundTrans Icon9 vPics gPics, config\Skins\logoStyle\%StyleN%.icl
	Gui, 3:Add, text,x+3 yp-2 h28 w1 border
	Gui, 3:Add, Picture,x+3 yp+3 w22 BackgroundTrans Icon5 vPics2 gPics2, config\Skins\logoStyle\%StyleN%.icl
	Gui, 3:Add, text,x+3 yp-3 h28 w1 border
	Gui, 3:Add, Picture,x+3 yp+3 w22 BackgroundTrans Icon7 vPics3 gPics3, config\Skins\logoStyle\%StyleN%.icl
	Gui, 3:Add, text,x+3 yp-3 h28 w1 border
	Gui, 3:Add, Picture,x+4 yp+2 w22 BackgroundTrans Icon9 vPics4 gPics4, config\Skins\logoStyle\%StyleN%.icl
	Gui, 3:font
	Gui, 3:font,s12 bold,songti
	Gui, 3:Add, text,x+3 yp-2 h28 w1 border
	sicon:=Wubi_Schema~="i)ci"?11:(Wubi_Schema~="i)zi"?13:Wubi_Schema~="i)chaoji"?12:14)
	Gui, 3:Add, Picture,x+9 yp+3 w44 BackgroundTrans Icon%sicon% gMoveGui vMoveGui Center, config\Skins\logoStyle\%StyleN%.icl
	if GetKeyState("CapsLock", "T")
		GuiControl,3:, Pics,*Icon2 config\Skins\logoStyle\%StyleN%.icl
	else
	{
		if IMEmode~="i)off"
			GuiControl,3:, Pics,*Icon3 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,3:, Pics,*Icon1 config\Skins\logoStyle\%StyleN%.icl
	}
	if (symb_mode=2)
		GuiControl,3:, Pics3,*Icon7 config\Skins\logoStyle\%StyleN%.icl
	else
		GuiControl,3:, Pics3,*Icon8 config\Skins\logoStyle\%StyleN%.icl
	if Trad_Mode~="i)on"
		GuiControl,3:, Pics2,*Icon6 config\Skins\logoStyle\%StyleN%.icl
	else
		GuiControl,3:, Pics2,*Icon5 config\Skins\logoStyle\%StyleN%.icl
	if Initial_Mode~="i)on"
		GuiControl,3:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
	else
		GuiControl,3:, Pics4,*Icon9 config\Skins\logoStyle\%StyleN%.icl
	Gui, 3:Color, EFEFEF
	Gui, 3:Margin, 2,2
	if Logo_Switch ~="i)off"
		Gui, 3:Destroy
	else
		Gui, 3:Show, NA h36 x%Logo_X% y%Logo_Y%,sign_wb
	if logo_show
		WinSet, TransColor, EFEFEF 180,sign_wb   ;方案Logo的透明度 数字越大透明度越低最大255，0为完全透明
Return

3GuiDropFiles:
/*
	Loop, Parse, A_GuiEvent, `n
	{
		FilePath.= A_LoopField "`n"
	}
	FilePath:=RegExReplace(FilePath,"^\n|\n$")
	Clipboard:=FilePath
	Traytip,,已拷贝到剪切板!
	;FileAppend, %FilePath%, %A_Desktop%\FilePath.txt
*/
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
	WinGetPos, Xs, Ys, , , sign_wb
	ToolTip(1, "", "Q1 B" BgColor " T" FontCodeColor " S" 12 " F" Font_)
	ToolTip(1, "词条处理中。。。", "x" Xs " y" Ys-35)
Return

Get_IME:
	global tip_pos:={x:GetCaretPos().x,y:GetCaretPos().y+30}
	If A_Cursor ~= "i)IBeam" {
		if srf_mode
		{
			if not A_OSVersion ~="i)WIN_XP"
			{
				Gosub Ime_Tips
				Sleep,400
				Gui, tips: Destroy
			}else{
				ToolTip,中,% GetCaretPos().x ,% GetCaretPos().y+30
				Sleep,400
				ToolTip
			}
		}else{
			if not A_OSVersion ~="i)WIN_XP"
			{
				Gosub Ime_Tips
				Sleep,400
				Gui, tips: Destroy
			}else{
				ToolTip, 英,% GetCaretPos().x ,% GetCaretPos().y+30
				Sleep,400
				ToolTip
			}
		}
	}else{
		if srf_mode
		{
			if not A_OSVersion ~="i)WIN_XP"
			{
				Gosub Ime_Tips
				Sleep,400
				Gui, tips: Destroy
			}else{
				WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
				ToolTip,中,% A_ScreenWidth-50 ,% A_ScreenHeight-Shell_Wnd-40
				Sleep,400
				ToolTip
			}
		}else{
			if not A_OSVersion ~="i)WIN_XP"
			{
				Gosub Ime_Tips
				Sleep,400
				Gui, tips: Destroy
			}else{
				WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
				ToolTip, 英, % A_ScreenWidth-50,% A_ScreenHeight-Shell_Wnd-40
				Sleep,400
				ToolTip
			}
		}
	}
Return

; 中英文切换模式
SetHotkey:
	srf_mode := !srf_mode
	if  srf_mode
	{
		if Logo_Switch ~="on"{
			Logo_X :=WubiIni.Settings["Logo_X"]
			Logo_Y :=WubiIni.Settings["Logo_Y"]
			Gui, 3:Show, NA x%Logo_X% y%Logo_Y%,sign_wb
			GuiControl,3:, Pics,*Icon1 config\Skins\logoStyle\%StyleN%.icl
		}
		SetCapsLockState , off
		Gosub srf_value_off
		srf_for_select_Array :=select_arr:=srf_bianma:=[],Select_result:="",code_status:=localpos:=1, select_sym:=PosLimit:=0
	}
	else
	{
		Gosub Write_Pos
		GuiControl,3:, Pics,*Icon3 config\Skins\logoStyle\%StyleN%.icl
		;Gui, 3:Show, NA x%Logo_X% y%Logo_Y%,sign_wb
		sendinput % RegExReplace(srf_all_input,"^z\'","")
		SetCapsLockState , off
		Gosub srf_value_off
		srf_for_select_Array :=select_arr:=[],Select_result:="",code_status:=localpos:=1, select_sym:=PosLimit:=0
	}
	Gosub Get_IME
Return

Pics:
	if (A_GuiEvent = "Normal")
	{
			IconMode:=srf_mode?3:1
			SetCapsLockState , off
			srf_mode:=srf_mode?0:1
			GuiControl,3:, Pics,*Icon%IconMode% config\Skins\logoStyle\%StyleN%.icl
	}
Return

Pics2:
	if (A_GuiEvent = "Normal")
	{
		if Trad_Mode~="i)on" {
			GuiControl,3:, Pics2,*Icon5 config\Skins\logoStyle\%StyleN%.icl
			Menu, setting, Rename, 中文繁体 , 中文简体
			SetCapsLockState , off
			Trad_Mode :=WubiIni.Settings["Trad_Mode"]:="off",WubiIni.save()
		}else{
			GuiControl,3:, Pics2,*Icon6 config\Skins\logoStyle\%StyleN%.icl
			Menu, setting, Rename, 中文简体 , 中文繁体
			SetCapsLockState , off
			Trad_Mode :=WubiIni.Settings["Trad_Mode"]:="on",WubiIni.save()
		}
	}
Return

Pics3:
	if (A_GuiEvent = "Normal")
	{
		if (symb_mode=2) {
			GuiControl,3:, Pics3,*Icon8 config\Skins\logoStyle\%StyleN%.icl
			SetCapsLockState , off
			symb_mode :=WubiIni.Settings["symb_mode"]:=1,WubiIni.save()
		}else{
			GuiControl,3:, Pics3,*Icon7 config\Skins\logoStyle\%StyleN%.icl
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
			GuiControl,3:, Pics4,*Icon9 config\Skins\logoStyle\%StyleN%.icl
		}else{
			Initial_Mode:=WubiIni.Settings["Initial_Mode"] :="on", WubiIni.save()
			GuiControl,3:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
		}
	}
Return

;logo开关
Logo_Switch:
	Logo_Switch :=(Logo_Switch~="i)off"?"on":"off")
	if Logo_Switch ~="i)off"{
		Gui, 3:Destroy
		Menu, Tray, Rename, 显隐图标,显隐图标	×
	}else{
		Gosub Schema_logo
		Menu, Tray, Rename, 显隐图标	×,显隐图标
	}
	WubiIni.Settings["Logo_Switch"] :=Logo_Switch, WubiIni.save()
	Menu, Tray, Enable, 导入词库
	Menu, Tray, Enable, 导出词库
Return

Del_EnKeyboard:    ;彻底删除系统美式英文键盘，因为是增删注册表的原因不能实时失效，需重启生效!调用的话直接 Gosub+空格+Del_EnKeyboard即可
	DelRegKey("HKEY_CURRENT_USER", "Keyboard Layout\Preload")
	DelRegKey("HKEY_USERS", ".DEFAULT\Keyboard Layout\Preload")
	RegDelete, HKEY_CURRENT_USER\Software\Microsoft\CTF\SortOrder\AssemblyItem\0x00000409
Return

;logo移动写入坐标
Write_Pos:
	WinGetPos, X_, Y_, , , sign_wb
	if (X_=""||Y_="")
		Logo_X :=WubiIni.Settings["Logo_X"]:=200, Logo_Y :=WubiIni.Settings["Logo_Y"]:=y2, WubiIni.save()
	else
		Logo_X :=WubiIni.Settings["Logo_X"]:=X_, Logo_Y :=WubiIni.Settings["Logo_Y"]:=Y_, WubiIni.save()
Return

;logo双击操作设定
MoveGui:
	if (A_GuiEvent = "DoubleClick")
	{
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema~="ci"?"zi":(Wubi_Schema~="zi"?"chaoji":(Wubi_Schema~="chaoji"?"zg":"ci")), WubiIni.save()
		sicon_:=Wubi_Schema~="i)ci"?11:(Wubi_Schema~="i)zi"?13:Wubi_Schema~="i)chaoji"?12:14)
		GuiControl,3:, MoveGui,*Icon%sicon_% config\Skins\logoStyle\%StyleN%.icl
		if Wubi_Schema~="ci" {
			Gosub Enable_Tray
			Menu, Tray, Enable, 批量造词
		}else if Wubi_Schema~="zi"{
			Gosub Disable_Tray
			Menu, Tray, Disable, 批量造词
		}else if Wubi_Schema~="chaoji" {
			Gosub Enable_Tray
			Menu, Tray, Disable, 批量造词
		}else if Wubi_Schema~="zg"{
			Gosub Disable_Tray
			Menu, Tray, Disable, 批量造词
		}
	}
/*
	else if (A_GuiEvent = "Normal"){
		MouseGetPos, X_, Y_, Wubi_Gui
		WinGetPos, FX, FY, Width, Height
		WinMove, X_, Y_-Height
	}
*/
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
	Menu, TRAY, NoStandard
	Menu, TRAY, DeleteAll
	program:= "※ " Startup_Name " ※`n版本日期：" Versions "`n农历日期：" Date_GetLunarDate(SubStr( A_Now,1,8)) "`n农历时辰：" Time_GetShichen(SubStr( A_Now,9,2))
	Menu, Tray, Add, 使用帮助,OnHelp
	Menu, TRAY, Icon, 使用帮助, config\wubi98.icl, 3
	Menu, Tray, Add
	if (Cut_Mode ~="i)on"){
		Menu, setting, Add, 拆分显示	√, Cut_Mode
		Menu, setting, Icon, 拆分显示	√, config\wubi98.icl, 15
	}else{
		Menu, setting, Add, 拆分显示	×,Cut_Mode
		Menu, setting, Icon, 拆分显示	×, config\wubi98.icl, 15
	}
	Menu, setting, Add
	if (Prompt_Word ~="i)on"){
		Menu, setting, Add, 空码提示	√, Prompt_Word
		Menu, setting, Icon, 空码提示	√, config\wubi98.icl, 15
	}else{
		Menu, setting, Add, 空码提示	×,Prompt_Word
		Menu, setting, Icon, 空码提示	×, config\wubi98.icl, 15
	}
	Menu, setting, Add
	if (Trad_Mode ~="i)on"){
		Menu, setting, Add, 中文繁体, Trad_Mode
		Menu, setting, Icon, 中文繁体, config\wubi98.icl, 15
	}else{
		Menu, setting, Add, 中文简体,Trad_Mode
		Menu, setting, Icon, 中文简体, config\wubi98.icl, 15
	}
	Menu, setting, Add
	if (Textdirection ~="i)horizontal"){
		Menu, setting, Add, 候选横排, Textdirection
		Menu, setting, Icon, 候选横排, config\wubi98.icl, 15
	}else{
		Menu, setting, Add, 候选竖排,Textdirection
		Menu, setting, Icon, 候选竖排, config\wubi98.icl, 15
	}
	Menu, setting, Add
	if (limit_code ~="i)on"){
		Menu, setting, Add, 四码上屏	√, limit_code
		Menu, setting, Icon, 四码上屏	√, config\wubi98.icl, 15
	}else{
		Menu, setting, Add, 四码上屏	×,limit_code
		Menu, setting, Icon, 四码上屏	×, config\wubi98.icl, 15
	}
	Menu, setting, Add
/*
	if (symb_send ~="i)on"){
		Menu, setting, Add, 符号顶屏	√, symb_send
		Menu, setting, Icon, 符号顶屏	√, config\wubi98.icl, 15
	}else{
		Menu, setting, Add, 符号顶屏	×,symb_send
		Menu, setting, Icon, 符号顶屏	×, config\wubi98.icl, 15
	}
	Menu, setting, Add
*/
	if (Select_Enter ~="i)send"){
		Menu, setting, Add, 回车上屏, Select_Enter
		Menu, setting, Icon, 回车上屏, config\wubi98.icl, 15
	}else if (Select_Enter ~="i)clean"){
		Menu, setting, Add, 回车清屏,Select_Enter
		Menu, setting, Icon, 回车清屏, config\wubi98.icl, 15
	}
	Menu, Tray, Add, 更多设置,:setting
	Menu, TRAY, Icon, 更多设置, config\wubi98.icl, 14
	Menu, Tray, Add
	if ToolTipStyle ~="i)on"{
		Menu, Tip_Style, Add, ToolTip样式	√,Tip_Style
		Menu, Tip_Style, Icon, ToolTip样式	√, config\wubi98.icl, 15
	}else{
		Menu, Tip_Style, Add, ToolTip样式,Tip_Style
		Menu, Tip_Style, Icon, ToolTip样式, config\wubi98.icl, 15
	}
	Menu, Tip_Style, Add
	if ToolTipStyle ~="i)off"{
		Menu, Tip_Style, Add, Gui候选样式	√,Tip_Style
		Menu, Tip_Style, Icon, Gui候选样式	√, config\wubi98.icl, 15
	}else{
		Menu, Tip_Style, Add, Gui候选样式,Tip_Style
		Menu, Tip_Style, Icon, Gui候选样式, config\wubi98.icl, 15
	}
	Menu, Tip_Style, Add
	if ToolTipStyle ~="i)Gdip"{
		Menu, Tip_Style, Add, Gdip候选样式	√,Tip_Style
		Menu, Tip_Style, Icon, Gdip候选样式	√, config\wubi98.icl, 15
		if A_OSVersion ~="i)WIN_XP"
			Menu, Tip_Style, Disable, Gdip候选样式	√
	}else{
		Menu, Tip_Style, Add, Gdip候选样式,Tip_Style
		Menu, Tip_Style, Icon, Gdip候选样式, config\wubi98.icl, 15
		if A_OSVersion ~="i)WIN_XP"
			Menu, Tip_Style, Disable, Gdip候选样式
	}
	Menu, Tray, Add, 候选样式, :Tip_Style
	Menu, TRAY, Icon, 候选样式, config\wubi98.icl, 20
	Menu, Tray, Add
	;Menu, Tray, Default, 高级设置
	Menu, Tray, Add, 导入词库,OnWrite
	if Wubi_Schema~="i)zi"
		Menu, Tray, Disable, 导入词库
	Menu, TRAY, Icon, 导入词库, config\wubi98.icl, 10
	Menu, Tray, Add
	Menu, Tray, Add, 导出词库,OnBackup
	if Wubi_Schema~="i)zi"
		Menu, Tray, Disable, 导出词库
	Menu, TRAY, Icon, 导出词库, config\wubi98.icl, 11
	Menu, Tray, Add
	Menu, Tray, Add, 词库管理,DB_management
	Menu, TRAY, Icon, 词库管理, config\wubi98.icl, 35
	Menu, Tray, Add
	Menu, Tray, Add, 高级设置, Onconfig
	Menu, TRAY, Icon, 高级设置, config\wubi98.icl, 6
	Menu, Tray, Add
	Menu, Tray, Add, 批量造词,Add_Code
	if (Wubi_Schema~="i)zi|chaoji"&&!Addcode_switch)
		Menu, Tray, Disable, 批量造词
	Menu, TRAY, Icon, 批量造词, config\wubi98.icl, 13
	Menu, Tray, Add
	Menu, Tray, Add, 显隐图标,Logo_Switch
	Menu, TRAY, Icon, 显隐图标, config\wubi98.icl, 2
	Menu, Tray, Add
	Menu, Tray, Add, 启用状态	√,OnSuspend
	Menu, TRAY, Icon, 启用状态	√, config\wubi98.icl, 18
	Menu, Tray, Add
	Menu, Tray, Add, 重载脚本,OnReload
	Menu, TRAY, Icon, 重载脚本, config\wubi98.icl, 5
	Menu, Tray, Add
	Menu, Tray, Add, 退出程序,OnExit
	Menu, TRAY, Icon, 退出程序, config\wubi98.icl, 7
	Menu, Tray, Default,高级设置
	;Menu, Tray, Click, 1
	Menu,Tray,Tip,%program%
return

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
	Menu, Tray, Disable, 导入词库
	Menu, Tray, Disable, 导出词库
return

Enable_Tray:
	Menu, Tray, Enable, 导入词库
	Menu, Tray, Enable, 导出词库
return

;托盘菜单候选样式选择
Tip_Style:
	if A_ThisMenuItem ~="i)ToolTip"&&ToolTipStyle<>"on"{
		Menu, Tip_Style, Rename, ToolTip样式,ToolTip样式	√
		if ToolTipStyle ~="i)gdip"
			Menu, Tip_Style, Rename, Gdip候选样式	√,Gdip候选样式
		else if ToolTipStyle ~="i)off"
			Menu, Tip_Style, Rename, Gui候选样式	√,Gui候选样式
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="on"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="14"
	}
	else if A_ThisMenuItem ~="i)Gui"&&ToolTipStyle<>"off"{
		Menu, Tip_Style, Rename, Gui候选样式,Gui候选样式	√
		if ToolTipStyle ~="i)gdip"
			Menu, Tip_Style, Rename, Gdip候选样式	√,Gdip候选样式
		else if ToolTipStyle ~="i)on"
			Menu, Tip_Style, Rename, ToolTip样式	√,ToolTip样式
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="off"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="16"
	}
	else if A_ThisMenuItem ~="i)Gdip"&&ToolTipStyle<>"gdip"{
		Menu, Tip_Style, Rename, Gdip候选样式,Gdip候选样式	√
		if ToolTipStyle ~="i)off"
			Menu, Tip_Style, Rename, Gui候选样式	√,Gui候选样式
		else if ToolTipStyle ~="i)on"
			Menu, Tip_Style, Rename, ToolTip样式	√,ToolTip样式
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="gdip"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="20"
	}
	WubiIni.save()
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
Return

;挂起操作
OnSuspend:
	Suspend
	if A_IsSuspended {
		Menu, Tray, Icon, config\wubi98.icl,31, 1
		;if !GET_IMESt()
		;	SwitchToChsIME()
		Menu, TRAY, Rename, 启用状态	√ , 挂起状态	×
		Menu, TRAY, Icon, 挂起状态	×, config\wubi98.icl, 4
		GuiControl,3:, Pics,*Icon4 config\Skins\logoStyle\%StyleN%.icl
		Traytip,  提示:,已切换至挂起状态！
	}else if !A_IsSuspended {
		if FileExist(A_ScriptDir "\wubi98.ico")
			Menu, Tray, Icon, wubi98.ico
		else
			Menu, Tray, Icon, config\wubi98.icl,30
		Menu, TRAY, Rename, 挂起状态	× , 启用状态	√
		Menu, TRAY, Icon, 启用状态	√, config\wubi98.icl, 18
		if srf_mode
			GuiControl,3:, Pics,*Icon1 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,3:, Pics,*Icon3 config\Skins\logoStyle\%StyleN%.icl
		Traytip,  提示:,已切换至启用状态！
		;if GET_IMESt()
		;	SwitchToEngIME()
	}
return

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

;导出词库
OnBackup:
	Gosub Backup_DB
Return

;帮助
OnHelp:
	Run  config\ReadMe.png
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

	If limit_code ~="i)on"
	{
		if (StrLen(srf_all_input)=4&&srf_all_input ~="^[a-yA-Y]")
		{
			if srf_for_select_Array.Length()=0{    ;如果无候选，则自动清空历史
				srf_for_select_for_tooltip:=
			}
			else if srf_for_select_Array.Length()=1 ;如果候选唯一，则自动上屏
			{
				srf_select(1)
				gosub srf_value_off
				srf_for_select_Array :=[]
			}
		}
		else if (StrLen(srf_all_input)>4&&srf_all_input ~="^[a-yA-Y]") ;五码顶字上屏，排除编码含z的拼音反查
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
		else if StrLen(srf_all_input)<4&&srf_for_select_Array.Length()=0&&srf_all_input ~="^[a-yA-Y]"
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
		GuiControl, 98:Disable, FTip
		GuiControl, 98:Disable, set_Frequency
		GuiControl, 98:Disable, RestDB
	}else{
		GuiControl, 98:Enable, FTip
		GuiControl, 98:Enable, set_Frequency
		GuiControl, 98:Enable, RestDB
	}
Return

set_Frequency:
	GuiControlGet, set_Frequency,, set_Frequency, text
	Freq_Count:=WubiIni.Settings["Freq_Count"]:=set_Frequency, WubiIni.save()
Return

RestDB:
	MsgBox, 262404,重置确认, 是否重置词频？
	IfMsgBox Yes
		if DB.Exec("UPDATE ci SET D_Key=B_Key;")>0
			Traytip,,重置成功！
	
Return

;候选词条分页处理
srf_tooltip_fanye:
	if (WubiIni.TipStyle["Textdirection"]<>Textdirection&&Textdirection:="vertical")
		Textdirection:=WubiIni.TipStyle["Textdirection"]
	if (WubiIni.TipStyle["ListNum"]<>ListNum)
		ListNum:=WubiIni.TipStyle["ListNum"]
	if srf_all_Input ~="^``"{
		if srf_all_Input~="^``[a-z]+"{
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
			srf_for_select_Array:=prompt_symbols(srf_all_Input)
		}else{
			Sym_Array_1[1,1]:=srf_all_input, srf_for_select_Array:=Sym_Array_1
		}
		Gosub srf_tooltip_cut
	}else if srf_all_Input ~="^z"{
		if srf_all_Input~="^z[a-z]+|^z\'[a-z]+" {
			;if get_word(srf_all_input, Wubi_Schema).Length()>0
				srf_all_input:=RegExReplace(srf_all_input,"^z|^z\'",srf_all_input~="'"?"z":"z'"), srf_for_select_Array:=get_word(srf_all_input, Wubi_Schema)
			;else
				;Sym_Array:=[],Sym_Array[1,1]:=RegExReplace(srf_all_Input,"\'"),Sym_Array[1,1]<>RegExReplace(srf_all_Input,"^z\'")?(Sym_Array[2,1]:=RegExReplace(srf_all_Input,"^z\'")):"",srf_for_select_Array:=Sym_Array
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
	}else{
		srf_for_select_Array:=get_word(srf_all_Input, Wubi_Schema)
		if (srf_for_select_Array.Length()=0&&srf_all_Input ="help"){
			Textdirection:=Textdirection~="i)horizontal"?"vertical":"vertical", ListNum:=ListNum<10?10:10
			help_info:=[["拼音反查"," z键引导 ","〔 z键引导 〕"]
				,["以形查音"," ~键引导 ","〔 ~键引导 〕"]
				,["临时英文"," 双``键引导 ","〔 双``键引导 〕"]
				,["程序挂起"," 默认热键Alt+Z ","〔 默认热键Alt+Z 〕"]
				,["精准造词"," ``键引导+``键分词 ","〔 ``键引导+``键分词 〕"]
				,["快捷退出"," 默认热键Ctrl+Esc ","〔 默认热键Ctrl+Esc 〕"]
				,["简繁模式"," 默认热键Ctrl+Shift+F ","〔 默认热键Ctrl+Shift+F 〕"]
				,["拆分显示"," 默认热键Ctrl+Shift+H ","〔 默认热键Ctrl+Shift+H 〕"]
				,["批量造词"," 默认热键Ctrl+CapsLock调出窗口 ","〔 默认热键Ctrl+CapsLock调出窗口 〕"]], srf_for_select_Array:=help_info
		}
		Gosub srf_tooltip_cut
	}
Return

srf_tooltip_cut:
	srf_for_select_string:="", localpos:=1, srf_for_select_obj:=[]
	, loopindex:=srf_for_select_Array.Length()-ListNum*waitnum
	, loopindex:=(loopindex>ListNum?ListNum:loopindex)
	If (Textdirection="horizontal")
	{
		Loop %loopindex%
		{
			if srf_for_select_Array[ListNum*waitnum+A_Index,1] {
				srf_for_select_part:=((StrLen(srf_for_select_Array[ListNum*waitnum+A_Index,1])>25&&srf_all_input~="^[a-y]"?SubStr(srf_for_select_Array[ListNum*waitnum+A_Index,1],1,25) " •••••":srf_for_select_Array[ListNum*waitnum+A_Index,1]) (Cut_Mode="on"&&a_FontList ~="i)98WB-V|98WB-P0|五笔拆字字根字体|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_ &&FontType ~="i)98WB-V|98WB-P0|五笔拆字字根字体|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_&&srf_for_select_Array[ListNum*waitnum+A_Index, valueindex]<>""?(srf_all_input~="^[a-z]+"?"〔":A_Space) . srf_for_select_Array[ListNum*waitnum+A_Index, valueindex] . (srf_all_input~="^[a-z]+"?"〕":A_Space):A_Space . srf_for_select_Array[ListNum*waitnum+A_Index, 3]))
				if (srf_for_select_part<>""){
					srf_for_select_string.=((srf_all_Input~="/\d+"?A_Space A_Space SubStr(Select_Code, A_Index , 1):(Cut_Mode~="on"?A_Space:A_Space A_Space) A_Index) "." srf_for_select_part)
					srf_for_select_obj.Push(((srf_all_Input~="/\d+"?SubStr(Select_Code, A_Index , 1):A_Space A_Index) "." srf_for_select_part))
				}
			}
		}
	}
	Else
	{
		Loop %loopindex%
		{
			if srf_for_select_Array[ListNum*waitnum+A_Index,1] {
				srf_for_select_part:=(srf_for_select_Array[ListNum*waitnum+A_Index, 1] (Cut_Mode="on"&&a_FontList ~="i)98WB-V|98WB-P0|五笔拆字字根字体|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_&&FontType ~="i)98WB-V|98WB-P0|五笔拆字字根字体|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_&&srf_for_select_Array[ListNum*waitnum+A_Index, valueindex]<>""?(srf_all_input~="^[a-z]+"?"〔":A_Space) . srf_for_select_Array[ListNum*waitnum+A_Index, valueindex] . (srf_all_input~="^[a-z]+"?"〕":A_Space):A_Space . srf_for_select_Array[ListNum*waitnum+A_Index, 3]))
				if (srf_for_select_part<>""){
					srf_for_select_string.=("`n" (srf_all_Input~="/\d+"?SubStr(Select_Code, A_Index , 1):A_Index) "." srf_for_select_part)
					srf_for_select_obj.Push(((srf_all_Input~="/\d+"?SubStr(Select_Code, A_Index , 1):A_Space A_Index) "." srf_for_select_part))
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
	srf_code:=srf_all_input~="^z\'[a-z]"?RegExReplace(srf_all_input,"^z\'",""):(srf_all_input~="^``$"?RegExReplace(srf_all_input,"^``","〔精准造词〕"):srf_all_input~="^~$"?RegExReplace(srf_all_input,"^~","〔以形查音〕"):srf_all_input~="^````$"?RegExReplace(srf_all_input,"^````","〔临时英文〕"):srf_all_input)
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
	srf_for_select_Array :=select_arr:=srf_for_select_obj:=select_value_arr:=add_Result:=add_Array:=Result_:=Results_:=Result:=[],Select_result:=selectallvalue:="",code_status:=localpos:=srfCounts:=select_pos:=1
Return

diyColor:
	Gui, diy:Destroy
	Gui, diy: +hwndDIYTheme +AlwaysOnTop -DPIScale +Owner
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
	Gui, diy:Add, Button , xm+15 ym+210 gBackLogo,导出配色
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
	Gui, diy:Show,NA,配色管理
Return

;样式面板
More_Setting:
	Menu, StyleMenu, Add, Tooltip样式, Export
	Menu, StyleMenu, Add, Gui候选框样式, Export
	Menu, StyleMenu, Add, Gdip候选框样式, Export
	if A_OSVersion ~="i)WIN_XP"
		Menu, StyleMenu, Disable, Gdip候选框样式
	HMENU := Menu_GetMenuByName("StyleMenu")
	Gui, 98:Destroy
	Gui, 98:Default
	Gui, 98: +hwndhwndgui98 +AlwaysOnTop -DPIScale  ;+ToolWindow
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, TreeView,x10 y10 h400 w150 AltSubmit 0x20 0x200 -Buttons -WantF2 gTVGUI vTVGUI   ;-Buttons 
	TV1 := TV_Add("基础设置",, "Bold")
	TV1_1 := TV_Add("主题设置", TV1)  ; 指定项目的父项目.
	TV_Modify(TV1, "Expand"),TV_Modify(TV1_1, "Select")
	TV2 := TV_Add("功能设置",, "Bold")
	TV2_1 := TV_Add("候选框参数", TV2)
	TV2_2 := TV_Add("输入设定", TV2)
	TV2_3 := TV_Add("上屏设定", TV2)
	TV_Modify(TV2, "Expand")
	TV3 := TV_Add("快捷键设置",, "Bold")
	TV4 := TV_Add("标签管理",, "Bold")
	TV5 := TV_Add("码表管理",, "Bold")
	TV6 := TV_Add("关于",, "Bold")
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	TV_obj:={GBoxList1:["GBox1","themelogo","lineText1","TextInfo1","select_theme","diycolor","themelists","TextInfo2","Backup_Conf","Rest_Conf","select_logo","TextInfo3","TextInfo4","CreateSC"]
		,GBoxList2:["GBox2","set_select_value","FontIN","font_size","TextInfo5","FontType","TextInfo6","font_value","TextInfo7","select_value","TextInfo8","set_regulate_Hx","set_regulate","TextInfo9","GdipRadius","set_GdipRadius","TextInfo10","set_FocusRadius","set_FocusRadius_value"]
		,GBoxList3:["GBox3","TextInfo11","StyleMenu","SBA5","SBA0","TextInfo12","SBA9","SBA10","SBA12","SBA19","SBA20","SBA7","UIAccess","SBA6","SBA14","SBA21","SBA13","SBA3","logo_show","TextInfo13","Frequency","TextInfo14","set_Frequency","RestDB","InputStatus","WinMode"]
		,GBoxList4:["GBox4","TextInfo15","SBA4","TextInfo16","sChoice1","TextInfo17","sChoice2","TextInfo18","sChoice3","TextInfo19","sethotkey_1","sethotkey_2","hk_1","tip_text","TextInfo20","SetInput_CNMode","SetInput_ENMode"]
		,GBoxList5:["GBox5","SBA1","s2t_hotkeys","SBA2","cf_hotkeys","SBA15","tip_hotkey","SBA16","Suspend_hotkey","SBA17","Addcode_hotkey","Exit_hotkey","SBA22"]
		,GBoxList6:["GBox6","Dlabel","Rlabel","Blabel","Wlabel","Ulabel","Setlabel","Savelabel","MyLabel"]
		,GBoxList7:["GBox7","TextInfo21","sChoice4","ciku1","ciku9","ciku2","TextInfo22","ciku8","ciku7","yaml_","TextInfo23","ciku3","ciku4","TextInfo24","ciku5","ciku6"]
		,GBoxList8:["GBox8","linkinfo1","linkinfo2","linkinfo3","versionsinfo","infos_"]}

	Gui, 98:Add, GroupBox,x+10 yp w400 h400 vGBox1, 主题配置
	Gui, 98:Add, Picture,xp+80 yp+30 h-1 vthemelogo, Config\Skins\preview\默认.png
	if FileExist(A_ScriptDir "\Config\Skins\preview\" ThemeName ".png")
		GuiControl,98:, themelogo,Config\Skins\preview\%ThemeName%.png
	else
		GuiControl,98:, themelogo,Config\Skins\preview\Error.png
	Gui 98:Add, Text,x190 y+10 w365 h2 0x10 vlineText1
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text,
	Gui, 98:Add, Text,x190 yp+10 vTextInfo1 left, 主题选择：
	themelist:=logoList:=""
	Loop Files, config\Skins\*.json
		themelist.="|" SubStr(A_LoopFileName,1,-5)
	Gui, 98:Add, DDL,x+5 yp vselect_theme gselect_theme, % RegExReplace(themelist,"^\|")
	Gui, 98:Add, Text,x190 y+15  vTextInfo2 left, 主题管理：
	Gui, 98:Add, Button,x+5 yp-2 cred gdiycolor vdiycolor,自定义配色
	Gui, 98:Add, Button,x+5 cred gthemelists vthemelists,主题管理
	Gui, 98:Add, Text,x190 y+15 vTextInfo3 left, 配置管理：
	Gui, 98:Add, Button,x+5 yp-2 cred gBackup_Conf vBackup_Conf,备份配置
	Gui, 98:Add, Button,x+20 yp cred gRest_Conf vRest_Conf,恢复配置
	if !FileExist(A_ScriptDir "\Sync\Default.json")
		GuiControl, 98:Disable, Rest_Conf
	Loop Files, config\Skins\logoStyle\*.icl
		logoList.="|" SubStr(A_LoopFileName,1,-4)
	Gui, 98:Add, Text,x190 y+15 vTextInfo4 left, Logo样式：
	Gui, 98:Add, DDL,x+5 vselect_logo gselect_logo , % RegExReplace(logoList,"^\|")
	GuiControl, 98:ChooseString, select_logo, %StyleN%
	If Logo_Switch~="i)off"
		GuiControl, 98:Disable, select_logo
	GuiControlGet, scvar, Pos , select_logo
	Gui, 98:Add, Button,x%scvarX% y+10 cred gCreateSC vCreateSC,建立桌面快捷方式
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox2, 候选框参数
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	DllCall("gdi32\EnumFontFamilies","uint",DllCall("GetDC","uint",0),"uint",0,"uint",RegisterCallback("EnumFontFamilies"),"uint",a_FontList:="")
	Gui, 98:Add, Text, x190 yp+45 w150 left vTextInfo5, 候选框字体类型：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, ComboBox,x+0 w180 gfonts_type vFontType, % a_FontList
	GuiControl, 98:ChooseString, FontType, %FontType%
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	GuiControlGet, FontVar, Pos , FontType
	Gui, 98:Add, Button, x%FontVarX% y+5 cred gFontIN vFontIN,安装拆分字体
	if !FileExist(getPathByName("Font\*.exe"))
		GuiControl, 98:Disable, FontIN
	Gui, 98:Add, Text, x190 yp+45 w220 left vTextInfo6, 候选框字体字号[9-40]：
	Gui, 98:Add, Edit, x+0 w80 Limit2 Number vfont_value gfont_value
	Gui, 98:Add, UpDown, x+0 w160 Range9-40 gfont_size vfont_size, %FontSize%
	Gui, 98:Add, Text, x190 yp+45 w220 left vTextInfo7, 候选框候选数目[3-10]：
	Gui, 98:Add, Edit, x+0 w80 Limit2 Number vselect_value gselect_value
	Gui, 98:Add, UpDown, x+0 w160 Range3-10 gset_select_value vset_select_value, %ListNum%
	Gui, 98:Add, Text, x190 yp+45 w220 left vTextInfo8, ToolTip偏移量[3-25]：
	Gui, 98:Add, Edit, x+0 w80 Limit2 Number vset_regulate_Hx gset_regulate_Hx
	Gui, 98:Add, UpDown, x+0 w160 Range3-25 gset_regulate vset_regulate, %Set_Range%
	Gui, 98:Add, Text, x190 yp+45 w220 left vTextInfo9, Gdip候选框圆角[0-15]：
	Gui, 98:Add, Edit, x+0 w80 Limit2 Number vGdipRadius gGdipRadius
	Gui, 98:Add, UpDown, x+0 w160 Range0-15 gset_GdipRadius vset_GdipRadius, %Gdip_Radius%
	Gui, 98:Add, Text, x190 yp+45 w220 left vTextInfo10, 焦点候选项圆角[0-18]：
	Gui, 98:Add, Edit, x+0 w80 Limit2 Number vset_FocusRadius gset_FocusRadius
	Gui, 98:Add, UpDown, x+0 w160 Range0-18 gset_FocusRadius_value vset_FocusRadius_value, %FocusRadius%
	For Section, element In TV_obj
		if (Section="GBoxList2")
			Loop, % TV_obj[Section].Length()
				GuiControl, 98:Hide, % TV_obj[Section,A_Index]
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox3, 输入设定
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, Text, x190 yp+40 left vTextInfo11, 选框风格：
	Gui,98:Font
	Gui,98:Font, s8, %font_%
	Gui, 98:Add, Button,x+0 w125 hwndHExportBtn gStyleMenu vStyleMenu, % ToolTipStyle~="i)on"?"Tooltip样式":ToolTipStyle~="i)off"?"Gui候选框样式":"Gdip候选框样式"
	Gui, 98:Add, CheckBox,yp+0 x+15 vSBA5 gSBA5, 固定`n位置
	Gui, 98:Add, Button,yp+5 x+10 vSBA0 gSBA0, 坐标设置
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui 98:Add, Text,x190 y+15 w365 h2 0x10 vTextInfo12
	Gui, 98:Add, CheckBox,x190 yp+15 vSBA9 gSBA9, Gdip框圆角
	Gui, 98:Add, CheckBox,yp+0 x+5 vSBA10 gSBA10, Gdip分割线
	Gui, 98:Add, CheckBox,yp+0 x+5 vSBA12 gSBA12, 粗体
	Gui, 98:Add, CheckBox,x190 yp+40 vSBA19 gSBA19, 焦点候选框
	Gui, 98:Add, CheckBox,yp+0 x+5 vSBA20 gSBA20, 候选框页数显示
	Gui, 98:Add, CheckBox,x+5 yp+0 vSBA7 gSBA7, 四码上屏
	Gui, 98:Add, CheckBox, x190 yp+40 gEnableUIAccess vUIAccess , UIA（看不到候选框点我）
	Gui, 98:Add, CheckBox,x+5 yp+0 vSBA6 gSBA6, 符号顶屏
	Gui, 98:Add, CheckBox,x190 yp+40 vSBA14 gSBA14, 中文模式使用英文标点
	Gui, 98:Add, CheckBox,x+5 yp+0 vSBA21 gSBA21, 引号成对光标并居中
	Gui, 98:Add, CheckBox,x190 yp+40 vSBA13 gSBA13, Logo显隐
	Gui, 98:Add, CheckBox, x+5 yp+0 Checked%logo_show% glogo_show vlogo_show, Logo透明
	Gui, 98:Add, CheckBox,x+5 yp+0 vSBA3 gSBA3, 空码提示
	Gui 98:Add, Text,x190 y+15 w365 h2 0x10 vTextInfo13
	Gui, 98:Add, CheckBox,x190 yp+20 Checked%Frequency% vFrequency gFrequency, 动态调频
	if (not Wubi_Schema~="i)ci"||Trad_Mode~="i)on"||Prompt_Word~="i)on")
		GuiControl, 98:Disable, Frequency
	Gui, 98:Add, Text, x+5 yp vFTip left vTextInfo14, 调频参数：
	Gui, 98:Add, DDL,x+5 yp-3 w50 vset_Frequency gset_Frequency, 2|3|4|5|6|7|8
	Gui, 98:Add, Button, x+10 yp-1 vRestDB gRestDB, 重置词频
	if (not Wubi_Schema~="i)ci"||Trad_Mode~="i)on"||Prompt_Word~="i)on"||!Frequency) {
		GuiControl, 98:Disable, FTip
		GuiControl, 98:Disable, set_Frequency
		GuiControl, 98:Disable, RestDB
	}
	Gui, 98:Add, CheckBox,x190 yp+45 Checked%IStatus% vInputStatus gInputStatus, 输入状态控制
	Gui, 98:Add, Button, yp-4 x+10 gWinMode vWinMode,程序设置
	if !IStatus
		GuiControl,98:Disable,WinMode
	For Section, element In TV_obj
		if (Section="GBoxList3")
			Loop, % TV_obj[Section].Length()
				GuiControl, 98:Hide, % TV_obj[Section,A_Index]
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox4, 上屏设定
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 yp+45 left vTextInfo15, 开机自启：
	Gui, 98:Add, DDL,x+25 w135  vSBA4 gSBA4, 计划任务自启|快捷方式自启|不自启
	Gui, 98:Add, Text, x190 yp+45 left vTextInfo16, 上屏方式：
	Gui, 98:Add, DDL,x+25 w135  vsChoice1 gsChoice1, 常规上屏|剪切板上屏
	Gui, 98:Add, Text, x190 yp+45  left vTextInfo17, Enter设定：
	Gui, 98:Add, DDL,x+20 w135 vsChoice2 gsChoice2, 编码上屏|回车清空
	Gui, 98:Add, Text, x190 yp+45  left vTextInfo18, 候选模式：
	Gui, 98:Add, DDL,x+25 w135 vsChoice3 gsChoice3, 候选横排|候选竖排
	Gui, 98:Add, Text, x190 yp+45  left vTextInfo19, 中英切换：
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, DDL, vsethotkey_1 gsethotkey_1 x+25 yp-1 w60, Ctrl|Shift|Alt|LWin
	Gui 98:Add, Text, yp x+10 h30 w65 Center Border cblue vsethotkey_2 gsethotkey_2, % RegExReplace(Srf_Hotkey,"i)Shift|Ctrl|Alt|LWin|&","")
	Gui, 98:Add, Button, yp+0 x+10 vhk_1 ghk_1, 设置
	Gui, 98:Add, text, yp+5 x+5 w70 cred vtip_text, %A_Space%
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 yp+45  left vTextInfo20, 默认状态：
	Gui, 98:Add, Radio,yp+0 x+30 vSetInput_CNMode gSetInput_Mode, 中文
	Gui, 98:Add, Radio,yp+0 x+30 vSetInput_ENMode gSetInput_Mode, 英文
	For Section, element In TV_obj
		if (Section="GBoxList4")
			Loop, % TV_obj[Section].Length()
				GuiControl, 98:Hide, % TV_obj[Section,A_Index]
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
		if (Section="GBoxList5")
			Loop, % TV_obj[Section].Length()
				GuiControl, 98:Hide, % TV_obj[Section,A_Index]
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox6, 标签管理
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add,Button,x190 yp+40 gDlabel vDlabel, 删除
	GuiControl, 98:Disable, Dlabel
	Gui, 98:Add, Button,x+5 gRlabel vRlabel, 重置
	Gui, 98:Add, Button,x+5 gBlabel vBlabel, 导出
	Gui, 98:Add, Button,x+5 gWlabel vWlabel, 导入
	Gui, 98:Add, Button,x+5 gUlabel vUlabel, 编辑
	Gui, 98:Add, Edit, x+5 R1 w65 vSetlabel WantTab hWndLEdit
	Gui, 98:Add, Button,x+5 gSavelabel vSavelabel, 确定
	GuiControl, 98:Hide, Setlabel
	GuiControl, 98:Hide, Savelabel
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, ListView,x180 y+15 h300 w380 Grid AltSubmit NoSortHdr NoSort -WantF2 Checked -ReadOnly -Multi 0x8 LV0x40 -LV0x10 gMyLabel vMyLabel hwndHLV, 别名|标签名|标签说明|状态
	GuiControl, +Hdr, MyLabel
	Gosub Glabel
	For Section, element In TV_obj
		if (Section="GBoxList6")
			Loop, % TV_obj[Section].Length()
				GuiControl, 98:Hide, % TV_obj[Section,A_Index]
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox7, 码表管理
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui, 98:Add, Text, x190 yp+45 vTextInfo21 left, 码表选择：
	Gui, 98:Add, DDL,x+10 w100 vsChoice4 gsChoice4, 含词码表|单字码表|超集码表|字根码表
	Gui, 98:Add, Button, x+10 yp-1 vciku1 gciku1,导入
	Gui, 98:Add, Button, x+10 yp vciku9 gciku9,自造词管理
	Gui, 98:Add, Text, x190 yp+45 left vTextInfo22, 码表导出：
	Gui, 98:Add, Button, x+10 yp-1 vciku2 gciku2,码表合并导出
	Gui, 98:Add, Button, x+20 yp vciku8 gciku8,含词主码表导出
	GuiControlGet, budbvar, Pos , ciku2
	Gui, 98:Add, Button, x%budbvarX% yp+45 vciku7 gciku7,自造词导出
	Gui, 98:Add, CheckBox,x+15 yp+4 vyaml_ gyaml_, 导出为yaml文件
	if !FileExist(A_ScriptDir "\Sync\header.txt")
		GuiControl, 98:Disable, yaml_
	Gui, 98:Add, Text, x190 yp+55 vTextInfo23 left, 英文词库：
	Gui, 98:Add, Button, x+10 yp-1 vciku3 gciku3,导入
	Gui, 98:Add, Button, x+5 yp-1 vciku4 gciku4,导出
	Gui, 98:Add, Text, x190 yp+45 vTextInfo24 left, 特殊符号：
	Gui, 98:Add, Button, x+10 yp-1 vciku5 gciku5,导入
	Gui, 98:Add, Button, x+5 yp-1 vciku6 gciku6,导出
	For Section, element In TV_obj
		if (Section="GBoxList7")
			Loop, % TV_obj[Section].Length()
				GuiControl, 98:Hide, % TV_obj[Section,A_Index]
	Gui,98:Font
	Gui,98:Font, s10 bold, %font_%
	Gui 98:Add, GroupBox,x170 y10 w400 h400 vGBox8, 关于
	Gui,98:Font
	Gui,98:Font, s9 c757575, %font_%
	Gui,98:Add, Text, x190 yp+35 w360 vinfos_ , `t%Startup_Name%是以AutoHotkey脚本语言编写的外挂类型形码输入法，借用同类型的「影子输入法」的实现思路通过调用众多WinAPI整合SQLite数据库实现文字输出等一系列功能。以「数据库码表性能」和「前端呈现」（调用Windows的GdiPlus.dll）两方面对文字内容直接发送上屏，而不进行传统输入法的转换操作，从XP至Win10皆能流畅运行。此版本为王码五笔98版专用，非98五笔的用户移步至「影子输入法」。
	Gui,98:Font
	Gui,98:Font, s10, %font_%
	Gui,98:Add, Link, y+15 vlinkinfo1, 简介：<a href="https://wubi98.gitee.io/2020/04/27/2019-12-03-031.yours/">程序简介</a>`nGitHub：<a href="https://github.com/OnchiuLee/AHK-Input-method">GitHub查看</a>`n使用帮助：<a href="config\ReadMe.png">点我查看详细说明</a>
	Gui,98:Add, Link, y+5 vlinkinfo2, 关于：<a href="https://wubi98.gitee.io/">https://wubi98.gitee.io/</a>`n资源库：<a href="http://98wb.ys168.com">http://98wb.ys168.com</a>
	Gui,98:Add, Link, y+5 vlinkinfo3, 查看码元图：<a href="config\码元图.jpg">点我查看五笔98版码元图</a>
	Gui,98:Add, Text, y+5 vversionsinfo, 版本日期：%Versions%
	For Section, element In TV_obj
		if (Section="GBoxList8")
			Loop, % TV_obj[Section].Length()
				GuiControl, 98:Hide, % TV_obj[Section,A_Index]
	Gui 98:color,ffffff
	Gui,98:Font
	Gui,98:Font, s9, %font_%
	Gui, 98:Add, StatusBar,, 设置面板
	SB_SetText(A_Is64bitOS?"运行环境：" ComInfo.GetOSVersionInfo() "〔 AHK " A_AhkVersion "#64位 〕":"运行环境：" ComInfo.GetOSVersionInfo() "〔 AHK " A_AhkVersion "#32位 〕" )
	Gui, 98:Show,AutoSize,输入法设置
	Gosub ControlGui

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
	FontPathByName:=getPathByName("Font\*.exe")
	if FontPathByName {
		If FileExist(FontPathByName) {
			Gui,98:Hide
			Traytip,,字体安装中。。。
			RunWait,% FontPathByName
			if (ErrorLevel <> "ERROR"){
				Cut_Mode:=WubiIni.Settings["Cut_Mode"] :="on",FontType :=WubiIni.TipStyle["FontType"]:= "98WB-0", WubiIni.save()
				DllCall("gdi32\EnumFontFamilies","uint",DllCall("GetDC","uint",0),"uint",0,"uint",RegisterCallback("EnumFontFamilies"),"uint",a_FontList:="")
				GuiControl,98:, FontType , |%a_FontList%
				GuiControl, 98:ChooseString, FontType, %FontType%
			}
		}
		Gui,98:Show
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
		Gui, 3:Destroy
		Gosub Schema_logo
	}
Return

InputStatus:
	GuiControlGet, InputStatus ,, InputStatus, Checkbox
	IStatus :=WubiIni.Settings["IStatus"]:=InputStatus,WubiIni.save()
	if IStatus
		GuiControl,98:Enable,WinMode
	else
		GuiControl,98:Disable,WinMode
Return

WinMode:
	Gui, IM:Destroy
	Gui IM:Default
	Gui IM:+LastFound +AlwaysOnTop +Owner
	Gui, IM:Add, Button, y+10 vDTxck gDTxck,删除
	GuiControl,IM:Disable,DTxck
	Gui, IM:Add, Button, x+10 vAddProcess gAddProcess,添加
	Gui, IM:Add, DropDownList ,Choose1 w80 x+10 vIM_DDL gIM_DDL, 中文|英文|剪切板
	GuiControl,IM:Disable,IM_DDL
	Gui, IM:Add, ListView, AltSubmit Grid r15 x10 yp+30 -LV0x10 -Multi Checked NoSortHdr -wscroll -WantF2 0x8 LV0x40 hwndIPView gIPView vIPView  ,进程名|输入状态
	For Section, element In EXEList_obj
		For key, value In element
			if (value<>"")
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
	Gui, IM:Add, Button, y+10 vRTxck gRTxck,刷新列表
	GuiControl, IM:Move, IPView, % "w" (A_ScreenDPI/96>1?ColWidth/(A_ScreenDPI/96):ColWidth)
	Gui,IM:Show, AutoSize,程序配置
Return

IPView:
	if A_GuiEvent~="i)Normal" {
		LV_GetText(LVName_,A_EventInfo,2),LV_GetText(LVName,A_EventInfo,1), LVPOS:= A_EventInfo
		GuiControl,IM:,IM_DDL,% LVName_~="中文"?"|英文|剪切板":LVName_~="英文"?"|中文|剪切板":LVName_~="剪切板"?"|中文|英文":""
		;GuiControl, IM:ChooseString, IM_DDL, % LVName_
		GuiControl,IM:Enable,IM_DDL
		if LVName_~="剪切板"
			GuiControl,IM:Disable,IM_DDL
		else
			GuiControl,IM:Enable,IM_DDL
		LVName__:=LVName_="中文"?"CN":LVName_="英文"?"EN":"CLIP"
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, IM:Enable, DTxck
				GuiControl,IM:Disable,IM_DDL
				break
			}else{
				GuiControl, IM:Disable, DTxck
				GuiControl,IM:Enable,IM_DDL
				break
			}
		}
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
	Set_IMode:=IMEmode~="off"?"EN":"CN", IModeCount:=0
	if EXEList_obj[Set_IMode].Length()>0 {
		Loop,% EXEList_obj[Set_IMode].Length()
		{
			if (value<>win_exe)
				IModeCount++
		}
		if (EXEList_obj[Set_IMode].Length()=IModeCount&&win_exe~="i)\.exe") {
			LV_Insert(LV_GetCount()+1 , "", win_exe, Set_IMode="CN"?"中文":Section="EN"?"英文":"剪切板")
			EXEList_obj[Set_IMode].Push(win_exe)
			Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
		}
	}else{
		if win_exe~="i)\.exe"
		{
			LV_Insert(1 , "", win_exe, Set_IMode="CN"?"中文":Section="EN"?"英文":"剪切板"),LV_ModifyCol()
			EXEList_obj[Set_IMode,1]:=win_exe
			Json_ObjToFile(EXEList_obj, A_ScriptDir "\Sync\InputMode.json", "UTF-8")
			LV_ModifyCol(2,"100 center")
			ColWidth:=0
			GuiControlGet, IMVar, Pos , IPView
			Loop % LV_GetCount("Column")
			{
				dIndex:=A_Index-1
				SendMessage, 4125, %dIndex%, , , ahk_id %IPView%  ; 4125 为 LVM_GETCOLUMNWIDTH.
				ColWidth+=ErrorLevel
			}
			GuiControl, IM:Move, IPView, % "w" (A_ScreenDPI/96>1?ColWidth/(A_ScreenDPI/96):ColWidth)
		}
	}
	Gui, 98:Show
	Gui, IM:show
Return

RTxck:
	LV_Delete()
	For Section, element In EXEList_obj
		For key, value In element
			if (value<>"")
				LV_Add(value=EXEList_obj["CN",1]?"Select":"" ,value,Section="CN"?"中文":Section="EN"?"英文":"剪切板")
Return

IM_DDL:
	GuiControlGet, IM_DDL,, IM_DDL, text 
	if (IM_DDL<>LVName_&&IM_DDL<>""&&LVName_<>""&&LVName~="i)\.exe$"&&IM_DDL<>"") {
		if IM_DDL ~="中文" {
			if EXEList_obj["CN"].Length()>0
			{
				if LVName__~="EN" {
					IModeCount:=0
					Loop, % EXEList_obj["CN"].Length()
						if (EXEList_obj["CN",A_Index]=LVName)
							IModeCount:=1
					if !IModeCount
					{
						Loop, % EXEList_obj["EN"].Length()
						{
							if (EXEList_obj["EN",A_Index]=LVName)
								EXEList_obj["EN"].RemoveAt(A_Index)
						}
						LV_Modify(LVPOS,"text",LVName,"中文")
						EXEList_obj["CN"].Push(LVName)
					}
				}
			}else
				EXEList_obj["CN",1]:=LVName, LV_Insert(LV_GetCount() ,"", LVName, "中文")
		}else if IM_DDL ~="英文" {
			if EXEList_obj["EN"].Length()>0
			{
				if LVName__~="CN" {
					IModeCount:=0
					Loop, % EXEList_obj["EN"].Length()
						if (EXEList_obj["EN",A_Index]=LVName)
							IModeCount:=1
					if !IModeCount
					{
						Loop, % EXEList_obj["CN"].Length()
						{
							if (EXEList_obj["CN",A_Index]=LVName)
								EXEList_obj["CN"].RemoveAt(A_Index)
						}
						LV_Modify(LVPOS,"text",LVName,"英文")
						EXEList_obj["EN"].Push(LVName)
					}
				}
			}else
				EXEList_obj["EN",1]:=LVName, LV_Insert(LV_GetCount() ,"", LVName, "英文")
		}else if IM_DDL ~="剪切板" {
			if EXEList_obj["CLIP"].Length()>0
			{
				IModeCount:=0
				Loop, % EXEList_obj["CLIP"].Length()
					if (EXEList_obj["CLIP",A_Index]=LVName)
						IModeCount:=1
				if !IModeCount
				{
					LV_Insert(LVPOS+1 ,"", LVName, "剪切板")
					EXEList_obj["CLIP"].Push(LVName)
				}
			}else{
				LV_Insert(1 ,"", LVName, "剪切板"), EXEList_obj["CLIP",1]:=LVName
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

Glabel:
	If DB.gettable("SELECT * FROM label", Result){
		loop, % Result.RowCount
		{
			LV_Add("", Result.Rows[A_index,2], Result.Rows[A_index,3],SubStr(Result.Rows[A_index,4],2),(WubiIni.Settings[Result.Rows[A_index,3]]!=""?(WubiIni.Settings[Result.Rows[A_index,3]]~="i)^on"?"开":WubiIni.Settings[Result.Rows[A_index,3]]~="i)^off"?"关":WubiIni.Settings[Result.Rows[A_index,3]]):(WubiIni.TipStyle[Result.Rows[A_index,3]]~="i)^on"?"开":WubiIni.TipStyle[Result.Rows[A_index,3]]~="i)^off"?"关":WubiIni.TipStyle[Result.Rows[A_index,3]]))), LV_ModifyCol()
		}
		LV_ModifyCol(2,"120 left")
		;LV_ModifyCol(4,"60 left")
		CLV := New LV_Colors(HLV)
		CLV.SelectionColors(0xfecd1b)
	}
Return

MyLabel:
	if (A_GuiEvent = "Normal")
	{
		LV_GetText(labelName, A_EventInfo), posInfo:=A_EventInfo
		GuiControlGet, LsVar, 98:Visible , Setlabel
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, 98:Enable, Dlabel
				if LsVar {
					GuiControl, 98:Disable, Setlabel
					GuiControl, 98:Disable, Savelabel
				}
				break
			}else{
				GuiControl, 98:Disable, Dlabel
				if LsVar {
					GuiControl, 98:Enable, Setlabel
					GuiControl, 98:Enable, Savelabel
					GuiControl,98:, Setlabel ,
				}
				break
			}
		}
		if LsVar
			EM_SetCueBanner(LEdit, labelName)
			;GuiControl,98:, Setlabel ,% labelName
	}
return

Rlabel:
	LV_Delete()
	if DB.Exec("DROP TABLE label")>0
	{
		DB.Exec("create table label as select * from label_init")
		Gosub Glabel
	}
return

Blabel:
	Gui,98:Hide
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
	Gui, 98:show,NA
Return

Wlabel:
	Gui,98:Hide
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
	Gui, 98:show,NA
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
	GuiControlGet, LsVar, 98:Visible , Setlabel
	if LsVar {
		GuiControl, 98:Hide, Setlabel
		GuiControl, 98:Hide, Savelabel
		GuiControl, 98:Disable, Setlabel
		GuiControl, 98:Disable, Savelabel
		GuiControl,98:, Setlabel ,
	}else if (posInfo<>""&&!LsVar){
		GuiControlGet, opvar, 98:Enabled , Dlabel
		GuiControl, 98:Show, Setlabel
		GuiControl, 98:Show, Savelabel
		EM_SetCueBanner(LEdit, labelName)
		;GuiControl,98:, Setlabel ,% labelName
		if opvar {
			GuiControl, 98:Disable, Setlabel
			GuiControl, 98:Disable, Savelabel
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
		GuiControl, 98:Hide, Setlabel
		GuiControl, 98:Hide, Savelabel
		GuiControl,98:, Setlabel ,
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
	Gui, Key: +AlwaysOnTop +Owner +ToolWindow +E0x08000000
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
	if (ToolTipStyle~="i)on")
		Menu_CheckRadioItem(HMENU, 1)
	else if (ToolTipStyle~="i)off")
		Menu_CheckRadioItem(HMENU, 2)
	else if (ToolTipStyle~="i)Gdip")
		Menu_CheckRadioItem(HMENU, 3)
	if ToolTipStyle ~="i)off|on"{
		GuiControl, 98:Disable, SBA9
		GuiControl, 98:Disable, SBA12
		GuiControl, 98:Disable, SBA10
		GuiControl, 98:Disable, SBA19
	}

	if themelist~=ThemeName "|"
		GuiControl, 98:ChooseString, select_theme, % ThemeName
	else
		GuiControl, 98:Choose, select_theme, 0

	GuiControl, 98:ChooseString, set_Frequency, %Freq_Count%
	if Radius~="i)on" {
		GuiControl,98:, SBA9 , 1
	}
	if Logo_Switch~="off"
		GuiControl, 98:Disable, logo_show
	if FontStyle~="i)on" {
		GuiControl,98:, SBA12 , 1
	}
	if Logo_Switch~="i)on|off" {
		GuiControl,98:, SBA13 , 1
	}
	if IMEmode~="on"
		GuiControl,98:, SetInput_CNMode , 1
	else
		GuiControl,98:, SetInput_ENMode , 1

	if BUyaml
		GuiControl,98:, yaml_ , 1

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
	if Gdip_Line~="i)on" {
		GuiControl,98:, SBA10 , 1
	}
	if Fix_Switch~="i)on" {
		GuiControl,98:, SBA5 , 1
	}
	if ToolTipStyle ~="i)on|off"{
		GuiControl, 98:Disable, LineColor
		GuiControl, 98:Disable, BorderColor
		GuiControl, 98:Disable, SBA19
	}
	if PageShow
		GuiControl,98:, SBA20 , 1
	if sym_match
		GuiControl,98:, SBA21 , 1
	if Exit_switch
		GuiControl,98:, SBA22 , 1
	if Wubi_Schema~="zi|zg"{
		GuiControl, 98:Disable, ciku1
		GuiControl, 98:Disable, ciku2
	}
	if Srf_Hotkey~="i)Ctrl"
		GuiControl,98:choose, sethotkey_1 , 1
	else if Srf_Hotkey~="i)Shift"
		GuiControl,98:choose, sethotkey_1 , 2
	else if Srf_Hotkey~="i)Alt"
		GuiControl,98:choose, sethotkey_1 , 3
	else if Srf_Hotkey~="i)LWin"
		GuiControl,98:choose, sethotkey_1 , 4
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
	if FocusStyle
		GuiControl,98:, SBA19 , 1
	if Wubi_Schema~="i)ci" {
		GuiControl,98:choose, sChoice4 , 1
	}else if Wubi_Schema~="i)zi" {
		GuiControl,98:choose, sChoice4 , 2
	}else if Wubi_Schema~="i)chaoji" {
		GuiControl,98:choose, sChoice4 , 3
	}else if Wubi_Schema~="i)zg" {
		GuiControl,98:choose, sChoice4 , 4
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
	if UIAccess
		GuiControl,98:, UIAccess , 1
	if cf_swtich {
		GuiControl,98:, SBA2 , 1
	}else{
		GuiControl, 98:Disable, cf_hotkeys
	}
	if not FontType ~="i)98WB-V|98WB-P0|五笔拆字字根字体|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_
		GuiControl, 98:Disable, SBA2
	if s2t_swtich {
		GuiControl,98:, SBA1 , 1
	}else{
		GuiControl, 98:Disable, s2t_hotkeys
	}
	if Prompt_Word~="i)on" {
		GuiControl,98:, SBA3 , 1
	}
	if Startup~="i)on" {
		GuiControl,98:choose, SBA4 , 1
	}else if Startup~="i)sc"{
		GuiControl,98:choose, SBA4 , 2
	}else{
		GuiControl,98:choose, SBA4 , 3
	}
	if symb_send~="i)on" {
		GuiControl,98:, SBA6 , 1
	}
	if limit_code~="i)on" {
		GuiControl,98:, SBA7 , 1
	}
	if (symb_mode=1) {
		GuiControl,98:, SBA14 , 1
	}
	if ToolTipStyle ~="i)off|gdip" {
		GuiControl, 98:Disable, set_regulate_Hx
		GuiControl, 98:Disable, set_regulate
	}
	if (ToolTipStyle ~="i)off|on"||Radius~="i)off") {
		GuiControl, 98:Disable, set_GdipRadius
		GuiControl, 98:Disable, GdipRadius
	}
Return

Show_Setting:
	;if GET_IMESt()
	;	SwitchToEngIME()
	Gui, 98:Destroy
	Gosub More_Setting
	Gui,98:Show,NA
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
		GuiControl,3:, Pics4,*Icon9 config\Skins\logoStyle\%StyleN%.icl
	}else{
		Initial_Mode:=WubiIni.Settings["Initial_Mode"]:="on",WubiIni.save()
		GuiControl,3:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
	}
Return

sChoice2:
	GuiControlGet, sChoice2,, sChoice2, text
	if sChoice2~="清空"
		Select_Enter:=WubiIni.Settings["Select_Enter"]:="clean",WubiIni.save()
	else
		Select_Enter:=WubiIni.Settings["Select_Enter"]:="send",WubiIni.save()
Return

themelists:
	Gui, themes:Destroy
	Gui, themes:Default
	Gui, themes: +AlwaysOnTop -DPIScale +Owner  ;+ToolWindow
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
	themelist:=RegExReplace(themelist,"\|$")
	Gui, themes:Add, Button, Section gSelectV2 vSelectV2, 删除
	GuiControl, themes:Disable, SelectV2
	Gui, themes:Add, Button, x+10 yp Section gSelectV3, 打开目录
	Gui, themes:Add, StatusBar,, 1
	colum:=colum_:=0
	Loop % LV_GetCount("Column")
	{
		Index:=A_Index-1
		SendMessage, 4125, %Index%, , , ahk_id %ThemeLV%  ; 4125 为 LVM_GETCOLUMNWIDTH.
		colum%A_Index%:=ErrorLevel, colum+=ErrorLevel
	}
	colum:=colum+25, colum_:=colum+30
	GuiControl, themes:Move, MyTheme, w%colum%
	SB_SetText(A_Space LV_GetCount() . "个主题")
	SB_SetIcon("Config\wubi98.icl",30)
	Gui, themes:show,NA w%colum_%, 主题管理
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
	Run,% A_ScriptDir "\config\Skins"
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
		Textdirection:=WubiIni.Settings["Textdirection"]:="horizontal",WubiIni.save()
	else
		Textdirection:=WubiIni.Settings["Textdirection"]:="vertical",WubiIni.save()
Return

sChoice4:
	GuiControlGet, sChoice4,, sChoice4, text
	if sChoice4~="词" {
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="ci",WubiIni.save()
		Menu, Tray, Enable, 批量造词
		Menu, Tray, Enable, 导入词库
		Menu, Tray, Enable, 导出词库
		GuiControl, 98:Enable, ciku1
		GuiControl, 98:Enable, ciku2
		GuiControl,3:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
		GuiControl, 98:Enable, Frequency
		if !Frequency {
			GuiControl, 98:Disable, FTip
			GuiControl, 98:Disable, set_Frequency
			GuiControl, 98:Disable, RestDB
		}else{
			GuiControl, 98:Enable, FTip
			GuiControl, 98:Enable, set_Frequency
			GuiControl, 98:Enable, RestDB
		}
	}else if sChoice4~="单"{
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="zi",WubiIni.save()
		Menu, Tray, Disable, 批量造词
		Menu, Tray, Disable, 导入词库
		Menu, Tray, Disable, 导出词库
		GuiControl, 98:Disable, ciku1
		GuiControl, 98:Disable, ciku2
		GuiControl,3:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
		GuiControl, 98:Disable, Frequency
		GuiControl, 98:Disable, FTip
		GuiControl, 98:Disable, set_Frequency
		GuiControl, 98:Disable, RestDB
	}else if sChoice4~="超"{
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="chaoji",WubiIni.save()
		Menu, Tray, Disable, 批量造词
		Menu, Tray, Enable, 导入词库
		Menu, Tray, Enable, 导出词库
		GuiControl, 98:Enable, ciku1
		GuiControl, 98:Enable, ciku2
		GuiControl,3:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
		GuiControl, 98:Disable, Frequency
		GuiControl, 98:Disable, FTip
		GuiControl, 98:Disable, set_Frequency
		GuiControl, 98:Disable, RestDB
	}else if sChoice4~="字根"{
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"]:="zg",WubiIni.save()
		Menu, Tray, Disable, 批量造词
		Menu, Tray, Disable, 导入词库
		Menu, Tray, Disable, 导出词库
		GuiControl, 98:Disable, ciku1
		GuiControl, 98:Disable, ciku2
		GuiControl,3:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
		GuiControl, 98:Disable, Frequency
		GuiControl, 98:Disable, FTip
		GuiControl, 98:Disable, set_Frequency
		GuiControl, 98:Disable, RestDB
	}
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
	Gui,98:Hide
	GuiControlGet, Choice,, sChoice4, text
	Gosub Write_DB
	keywait, LControl, D T1
	keywait, LControl
	Gui, 98:show,NA
Return

ciku2:
	Gui,98:Hide
	GuiControlGet, Choice,, sChoice4, text
	Gosub Backup_DB
	keywait, LControl, D T1
	keywait, LControl
	Gui, 98:show,NA
Return

ciku3:
	Gui,98:Hide
	GuiControlGet, ck3,, ciku3, text
	bd:=""
	if ck3 {
		global bd:="En"
		Gosub Write_En
	}
	keywait, LControl, D T1
	keywait, LControl
	Gui, 98:show,NA
Return

ciku4:
	Gui,98:Hide
	GuiControlGet, ck4,, ciku4, text
	bd:=""
	if ck4 {
		global bd:="En"
		Gosub Backup_En
	}
	keywait, LControl, D T1
	keywait, LControl
	Gui, 98:show,NA
Return

ciku5:
	Gui,98:Hide
	GuiControlGet, ck5,, ciku5, text
	bd:=""
	if ck5 {
		global bd:="Sym"
		Gosub Write_En
	}
	keywait, LControl, D T1
	keywait, LControl
	Gui, 98:show,NA
Return

ciku6:
	Gui,98:Hide
	GuiControlGet, ck6,, ciku6, text
	bd:=""
	if ck6 {
		global bd:="Sym"
		Gosub Backup_En
	}
	keywait, LControl, D T1
	keywait, LControl
	Gui, 98:show,NA
Return

ciku7:
	Gui,98:Hide
	custom_db:=1
	Gosub Backup_DB
	Gui, 98:show,NA
Return

ciku8:
	Gui, 98:Hide
	init_db:=1
	Gosub Backup_DB
	Gui, 98:show,NA
Return

ciku9:
	Gosub DB_management
Return

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
		Prompt_Word:=WubiIni.Settings["Prompt_Word"]:="on",WubiIni.save()
		Menu, setting, Rename, 空码提示	× , 空码提示	√
		GuiControl, 98:Disable, Frequency
		GuiControl, 98:Disable, FTip
		GuiControl, 98:Disable, set_Frequency
		GuiControl, 98:Disable, RestDB
	}else{
		Prompt_Word:=WubiIni.Settings["Prompt_Word"]:="off",WubiIni.save()
		Menu, setting, Rename, 空码提示	√ , 空码提示	×
		GuiControl, 98:Enable, Frequency
		if Frequency {
			GuiControl, 98:Enable, FTip
			GuiControl, 98:Enable, set_Frequency
			GuiControl, 98:Enable, RestDB
		}else{
			GuiControl, 98:Disable, FTip
			GuiControl, 98:Disable, set_Frequency
			GuiControl, 98:Disable, RestDB
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
	if (SBA==1) {
		Fix_Switch:=WubiIni.TipStyle["Fix_Switch"]:="on",WubiIni.save()
		GuiControl, 98:Enable, SBA0
	}else{
		Fix_Switch:=WubiIni.TipStyle["Fix_Switch"]:="off",WubiIni.save()
		GuiControl, 98:Disable, SBA0
	}
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
		Menu, setting, Rename, 四码上屏	× , 四码上屏	√
	}else{
		limit_code:=WubiIni.Settings["limit_code"]:="off",WubiIni.save()
		Menu, setting, Rename, 四码上屏	√ , 四码上屏	×
	}
Return

SBA9:
	GuiControlGet, SBA ,, SBA9, Checkbox
	if (SBA==1) {
		Radius:=WubiIni.TipStyle["Radius"]:="on",WubiIni.save()
		GuiControl, 98:Enable, set_GdipRadius
		GuiControl, 98:Enable, GdipRadius
	}else{
		Radius:=WubiIni.TipStyle["Radius"]:="off",WubiIni.save()
		GuiControl, 98:Disable, set_GdipRadius
		GuiControl, 98:Disable, GdipRadius
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
		GuiControl, 98:Disable, logo_show
		GuiControl, 98:Disable, select_logo
	}else{
		GuiControl, 98:Enable, logo_show
		GuiControl, 98:Enable, select_logo
	}
Return

SBA14:
	GuiControlGet, SBA ,, SBA14, Checkbox
	if (SBA==1) {
		global symb_mode:=WubiIni.Settings["symb_mode"]:=1
		GuiControl,3:, Pics3,*Icon7 config\Skins\logoStyle\%StyleN%.icl
	}else{
		global symb_mode:=WubiIni.Settings["symb_mode"]:=2
		GuiControl,3:, Pics3,*Icon8 config\Skins\logoStyle\%StyleN%.icl
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

logo_show:
	GuiControlGet, SBA ,, logo_show, Checkbox
	if (SBA==1) {
		logo_show:=WubiIni.TipStyle["logo_show"]:=1,WubiIni.save()
	}else{
		logo_show:=WubiIni.TipStyle["logo_show"]:=0,WubiIni.save()
	}
	Gui, 3:Destroy
	Gosub Schema_logo
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
		Menu, Tray, Enable, 批量造词
		GuiControl, 98:Enable, Addcode_hotkey
	}else{
		Addcode_switch:=WubiIni.Settings["Addcode_switch"]:=0,WubiIni.save()
		Hotkey, %Addcodehotkey%, Batch_AddCode,off
		Menu, Tray, Disable, 批量造词
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

SBA21:
	GuiControlGet, SBA ,, SBA21, Checkbox
	if SBA
		sym_match:=WubiIni.Settings["sym_match"]:=1,WubiIni.save()
	else
		sym_match:=WubiIni.Settings["sym_match"]:=0,WubiIni.save()
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
		GuiControl, 98:Enable, SBA12
		GuiControl, 98:Enable, SBA9
		GuiControl, 98:Enable, SBA10
		GuiControl, 98:Enable, SBA19
	}else{
		GuiControl, 98:Disable, SBA9
		GuiControl, 98:Disable, SBA10
		GuiControl, 98:Disable, SBA12
		GuiControl, 98:Disable, SBA19
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
		if not ToolTipStyle ~="i)gdip"
			Menu, Tip_Style, Rename, Gdip候选样式,Gdip候选样式	√
		if ToolTipStyle ~="i)off"
			Menu, Tip_Style, Rename, Gui候选样式	√,Gui候选样式
		else if ToolTipStyle ~="i)on"
			Menu, Tip_Style, Rename, ToolTip样式	√,ToolTip样式
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="Gdip"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="20"
	}else if A_ThisMenuItem~="i)Gui"{
		GuiControl, 98:Text, StyleMenu , % A_ThisMenuItem
		if not ToolTipStyle ~="i)off"
			Menu, Tip_Style, Rename, Gui候选样式,Gui候选样式	√
		if ToolTipStyle ~="i)on"
			Menu, Tip_Style, Rename, ToolTip样式	√,ToolTip样式
		else if ToolTipStyle ~="i)gdip"
			Menu, Tip_Style, Rename, Gdip候选样式	√,Gdip候选样式
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="off"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="14"
	}else if A_ThisMenuItem~="i)ToolTip"{
		GuiControl, 98:Text, StyleMenu , % A_ThisMenuItem
		if not ToolTipStyle ~="i)on"
			Menu, Tip_Style, Rename, ToolTip样式,ToolTip样式	√
		if ToolTipStyle ~="i)off"
			Menu, Tip_Style, Rename, Gui候选样式	√,Gui候选样式
		else if ToolTipStyle ~="i)gdip"
			Menu, Tip_Style, Rename, Gdip候选样式	√,Gdip候选样式
		global ToolTipStyle :=WubiIni.TipStyle["ToolTipStyle"] :="on"
		global FontSize :=WubiIni.TipStyle["FontSize"] :="14"
	}
	WubiIni.Save()
	if ToolTipStyle ~="i)on|off"{
		GuiControl, 98:Disable, LineColor
		GuiControl, 98:Disable, BorderColor
		GuiControl, 98:Disable, set_GdipRadius
		GuiControl, 98:Disable, GdipRadius
		GuiControl, 98:Disable, SBA9
		GuiControl, 98:Disable, SBA10
		GuiControl, 98:Disable, SBA12
		GuiControl, 98:Disable, SBA19
		Gui, houxuankuang:Destroy
		Gosub houxuankuangguicreate
	}else{
		GuiControl, 98:Enable, LineColor
		GuiControl, 98:Enable, BorderColor
		GuiControl, 98:Enable, SBA9
		GuiControl, 98:Enable, SBA10
		GuiControl, 98:Enable, SBA12
		GuiControl, 98:Enable, SBA19
		GuiControl, 98:Enable, set_GdipRadius
		GuiControl, 98:Enable, GdipRadius
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
		GuiControl,3:, Pics3,*Icon7 config\Skins\logoStyle\%StyleN%.icl
	else
		GuiControl,3:, Pics3,*Icon8 config\Skins\logoStyle\%StyleN%.icl
	WubiIni.save()
Return

;剪切板通道
Initial_Mode:
	Initial_Mode :=(Initial_Mode~="i)off"?"on":"off")
	if Initial_Mode~="i)off" {
		GuiControl,3:, Pics4,*Icon9 config\Skins\logoStyle\%StyleN%.icl
	}else{
		GuiControl,3:, Pics4,*Icon10 config\Skins\logoStyle\%StyleN%.icl
	}
	WubiIni.Settings["Initial_Mode"] :=Initial_Mode
	WubiIni.save()
Return

;选色面板结果处理
setcolor:
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
	if FontType ~="i)98WB-V|98WB-P0|五笔拆字字根字体|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_
		GuiControl, 98:Enable, SBA2
	else
		GuiControl, 98:Disable, SBA2
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
			Run *RunAs cmd.exe /c %Command%, , Hide
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
	if Prompt_Word ~="i)off"
		Menu, setting, Rename, 空码提示	√,空码提示	×
	else
		Menu, setting, Rename,空码提示	×,空码提示	√
return

;含词/单字选择
Wubi_Schema:
	Wubi_Schema :=(Wubi_Schema~="i)zi|chaoji"?"ci":"zi")
	if Wubi_Schema ~="i)zi|zg"{
		Gosub Disable_Tray
		Menu, Tray, Disable, 批量造词
		if Wubi_Schema~="i)zi"
			GuiControl,3:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,3:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
	}
	else if Wubi_Schema~="i)ci|chaoji"{
		Gosub Enable_Tray
		if Wubi_Schema~="i)ci"{
			Menu, Tray, Enable, 批量造词
			GuiControl,3:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
		}else{
			Menu, Tray, Disable, 批量造词
			GuiControl,3:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
		}
	}
	WubiIni.Settings["Wubi_Schema"] :=Wubi_Schema
	WubiIni.save()
return

;超集方案选择
Extend_Schema:
	Wubi_Schema :=(Wubi_Schema~="i)zi|ci|zg"&&a_FontList ~="i)98WB-V|98WB-P0|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_?"chaoji":"ci")
	if Wubi_Schema~="i)ci|chaoji"{
		Gosub Enable_Tray
		if Wubi_Schema~="i)ci"{
			Menu, Tray, Enable, 批量造词
			GuiControl,3:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
		}else{
			Menu, Tray, Disable, 批量造词
			GuiControl,3:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
		}
	}else{
		Gosub Disable_Tray
		Menu, Tray, Disable, 批量造词
		if Wubi_Schema~="i)zi"
			GuiControl,3:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,3:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
	}
	if (Wubi_Schema<>"chaoji"){
		Traytip,  失败提示,您的电脑可能没有安装支持超集的字体`n或多次操作无效，当前切换为「98含词」方案!
		WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema
		GuiControl,3:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
	}
	else
		WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema
	WubiIni.save()
return

;字根码表选择
ZG_Schema:
	Wubi_Schema :=WubiIni.Settings["Wubi_Schema"]:=Wubi_Schema~="i)zi|ci|chaoji"?"zg":"ci", WubiIni.save()
	if Wubi_Schema~="i)zg|zi"{
		Menu, Tray, Disable, 批量造词
		if Wubi_Schema~="i)zi"
			GuiControl,3:, MoveGui,*Icon13 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,3:, MoveGui,*Icon14 config\Skins\logoStyle\%StyleN%.icl
	}else{
		Menu, Tray, Enable, 批量造词
		if Wubi_Schema~="i)ci"
			GuiControl,3:, MoveGui,*Icon11 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,3:, MoveGui,*Icon12 config\Skins\logoStyle\%StyleN%.icl
	}
Return

;字根拆分
Cut_Mode:
	Cut_Mode :=WubiIni.Settings["Cut_Mode"] :=Cut_Mode~="i)off"?"on":"off", WubiIni.save()
	if Cut_Mode~="i)off"
		Menu, setting, Rename, 拆分显示	√ , 拆分显示	×
	else
		Menu, setting, Rename, 拆分显示	× , 拆分显示	√
	if srf_all_input
		Gosub srf_tooltip_fanye
return

;四码上屏
limit_code:
	limit_code :=WubiIni.Settings["limit_code"] :=limit_code~="i)off"?"on":"off", WubiIni.save()
	if limit_code~="i)off"
		Menu, setting, Rename, 四码上屏	√ , 四码上屏	×
	else
		Menu, setting, Rename, 四码上屏	× , 四码上屏	√
return

;简繁转换
Trad_Mode:
	Trad_Mode :=WubiIni.Settings["Trad_Mode"] :=Trad_Mode~="i)off"?"on":"off", WubiIni.save()
	if Trad_Mode~="off"{
		Menu, setting, Rename, 中文繁体 , 中文简体
		GuiControl,3:, Pics2,*Icon5 config\Skins\logoStyle\%StyleN%.icl
	}else{
		Menu, setting, Rename, 中文简体 , 中文繁体
		GuiControl,3:, Pics2,*Icon6 config\Skins\logoStyle\%StyleN%.icl
	}
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
		Menu, Tip_Style, Rename, ToolTip样式	√,ToolTip样式
		Menu, Tip_Style, Rename, Gui候选样式,Gui候选样式	√
		WubiIni.TipStyle["ToolTipStyle"]:=ToolTipStyle, WubiIni.save()
	}
	else if ToolTipStyle ~="i)off"
	{
		Gui, houxuankuang:Hide
		global ToolTipStyle :="gdip"
		Menu, Tip_Style, Rename, Gui候选样式	√,Gui候选样式
		Menu, Tip_Style, Rename, Gdip候选样式,Gdip候选样式	√
		global FontSize :=WubiIni.TipStyle["FontSize"]:=20
		WubiIni.TipStyle["ToolTipStyle"]:=ToolTipStyle, WubiIni.save()
	}
	else if ToolTipStyle ~="i)gdip"
	{
		GdipText(""), FocusGdipGui("", "")
		global ToolTipStyle :="on"
		Menu, Tip_Style, Rename, Gdip候选样式	√,Gdip候选样式
		Menu, Tip_Style, Rename, ToolTip样式,ToolTip样式	√
		global FontSize :=WubiIni.TipStyle["FontSize"]:=14
		WubiIni.TipStyle["ToolTipStyle"]:=ToolTipStyle, WubiIni.save()
	}
	Gui, houxuankuang:Destroy
	Gosub houxuankuangguicreate
return

;批量造词
Add_Code:
if WinExist("造词窗口"){
	Traytip,  警告提示:,不能重复打开「批量造词」窗口！,,2
	Return
}
else
{
	Gui, 29:Default              ;A_ScreenDPI/96
	Gui, 29: +AlwaysOnTop +LastFound hwndEditPlus    ;+ToolWindow +OwnDialogs +MinSize260x250 -MaximizeBox +Resize 
	Gui,29:Add, Edit, x8 y+8 vSet_Value +Multi hwndCodeEdit  ;+Multi
	Gui, 29:Add, Button, gSave vSave, 确定
	Gui, 29:Add, CheckBox,x+20 yp+5 glastp vlastp, 连续造词
	Gui, 29:Submit
	Gui,29:show,w260 h250,造词窗口
	EM_SetCueBanner(CodeEdit, "造词格式有两种：⑴、无编码词条，例如「五笔」。⑵、固定格式，例如「ggte=五笔」。<<<多个词条以换行符隔开！>>>")
	;SendMessage, 0x1501, 1, "造词格式有两种：⑴、无编码词条，例如「五笔」。⑵、固定格式，例如「ggte=五笔」。<<<多个词条以换行符隔开！>>>", Edit1, ahk_id%EditPlus%
	GuiControl, 29:Move, Set_Value,% "w240 h200"
	GuiControlGet, EdVar, Pos , Set_Value
	GuiControl, 29:Move, Save,% "y+" EdVarY+EdVarH+6
	GuiControl, 29:Move, lastp,% "y+" EdVarY+EdVarH+10
	CBVar:=0
}
return

EM_SetCueBanner(hWnd, Cue)
{
	static EM_SETCUEBANNER := 0x1501
	return DllCall("User32.dll\SendMessage", "Ptr", hWnd, "UInt", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}

/*
29GuiSize:
	GuiControlGet, EdVar, Pos , Set_Value
	if A_GuiWidth>260
	{
		GuiControl, 29:Move, Set_Value,% "w" A_GuiWidth-18
	}
	if A_GuiHeight>250
	{
		GuiControl, 29:Move, Set_Value, % "h" A_GuiHeight-45
		GuiControl, 29:Move, Save,% "y+" EdVarY+EdVarH+6
		GuiControl, 29:Move, lastp,% "y+" EdVarY+EdVarH+10
	}
Return
*/

29GuiDropFiles:
	OPCode_all:=OPCode_part:=OPCode:=""
	Loop, Parse, A_GuiEvent, `n, `r
	{
		FileRead, OPCode, %A_LoopField%
		if OPCode~="\t[a-z]+"{
			Loop, Parse, OPCode, `n, `r
			{
				RegExMatch(RegExReplace(A_LoopField,"\t\d+$"),"(?<=\t)[a-z]+",L_)
				RegExMatch(RegExReplace(A_LoopField,"\t\d+$"),"^.+(?=\t[a-z])",R_)
				if (StrLen(L_)>1&&StrLen(L_)<5)
					OPCode_part .=L_ "=" R_  "`n"
			}
		}else{
			OPCode_part:=RegExReplace(OPCode,"\t\d+|\t[a-z]+")
		}
		OPCode_all.=OPCode_part "`n"
	}
	GuiControl,29:, Set_Value ,% RegExReplace(OPCode_all,"^\n|\n$")
Return

lastp:
	GuiControlGet, CBVar ,, lastp, CheckBox
Return

;造词窗口关闭销毁
29GuiClose:
	Gui, 29:Destroy
	CBVar:=0, Result_:=Results_:=Result:=[]
	29GuiEscape:
Return

;造词保存处理
Save:
	GuiControlGet, mb_add,, Set_Value, text
	Gosub DROP_Status
	return_num :=Save_word(mb_add)
	if (return_num>0)
	{
		if !CBVar
			Gosub 29GuiClose
		else
			GuiControl,29:, Set_Value ,
		TrayTip,, 写入成功%return_num%个
	}
	else
		TrayTip,, 该词条已存在或自由选词格式不正确！
	ToolTip(1, "")
return

;方案词库导入（超集+含词+单字）
Write_DB:
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
		Create_Ci(DB,MaBiaoFile)
		tarr:=[],count :=0
		FileEncoding, UTF-8
		FileRead, MaBiao, %MaBiaoFile%
		if MaBiao~="`n[a-z]+\s"
			MaBiao:=Transform_mb(MaBiao)
		else if not MaBiao~="\t\d+"
			MaBiao:=Transform_cp(MaBiao)
		Loop, Parse, MaBiao, `n, `r
		{
			count++
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
			if (tarr[3]){
				if Wubi_Schema~="i)ci"{
					if tarr[4]
						Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "','" tarr[4] "','" tarr[5] "')" ","
					else
						Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "','" tarr[3] "','" tarr[3] "')" ","
				}else
					Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "')" ","
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
	}
	MaBiao:=Insert_ci:="",tarr:=[]
return

;词库导入（英文+symbols）
Write_En:
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

;词库导出（超集+含词+单字）
Backup_DB:
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
				FileDelete, %OutFolder%\wubi98-%fileNewname%.txt
				FileAppend,%Resoure_%,%OutFolder%\wubi98-%fileNewname%.txt, UTF-8
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
	Textdirection :=(Textdirection="vertical"?"horizontal":"vertical")
	if Textdirection~="i)horizontal"
		Menu, setting, Rename, 候选竖排 , 候选横排
	else
		Menu, setting, Rename, 候选横排 , 候选竖排
	WubiIni.TipStyle["Textdirection"] :=Textdirection
	WubiIni.save()
return

;回车设定
Select_Enter:
	Select_Enter :=(Select_Enter="send"?"clean":"send")
	if Select_Enter~="i)send"
		Menu, setting, Rename, 回车清屏 , 回车上屏
	else
		Menu, setting, Rename, 回车上屏 , 回车清屏
	WubiIni.Settings["Select_Enter"] :=Select_Enter
	WubiIni.save()
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
	Width := 40, Height := A_Cursor ~= "i)IBeam"?38:40
	Gui, tips: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
	Gui, tips: Add, Edit, w%Width% h%Height%, vMeEdit
	Gui, tips: Show, NA
	hwnd1 := WinExist()
	hbm := CreateDIBSection(Width, Height)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetSmoothingMode(G, 4)
	pBrush := Gdip_BrushCreateSolid("0x" SubStr("FF" FocusBackColor, -7))   ;"0xaa" FocusBackColor
	Gdip_FillRoundedRectangle(G, pBrush, 0, 0, Width, Height, A_Cursor ~= "i)IBeam"?Gdip_Radius:0)
	Gdip_DeleteBrush(pBrush)
	tips_text:=GetKeyState("CapsLock", "T")?"A":srf_mode?"中":"英"
	tipSize:=A_Cursor ~= "i)IBeam"?"s24":"s30"
	If !Gdip_FontFamilyCreate(Font_)
	{
		MsgBox, 48, Font error!, The font you have specified does not exist on the system
		Gui, tips: Destroy
	}
	pPen := Gdip_CreatePen("0x" SubStr("FF" FocusBackColor, -7), 2), Gdip_DrawRoundedRectangle(G, pPen, 0, 0, Width-2, Height-2, A_Cursor ~= "i)IBeam"?Gdip_Radius:0)
	Gdip_TextToGraphics(G, tips_text, "Center" "c" SubStr("ff" FocusColor, -7) " r4" tipSize "bold", Font_, Width, Height)
	WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd
	UpdateLayeredWindow(hwnd1, hdc, A_Cursor ~= "i)IBeam"?tip_pos.x:A_ScreenWidth-40, A_Cursor ~= "i)IBeam"?tip_pos.y:A_ScreenHeight-Shell_Wnd-40, Width, Height)
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
		Menu, TRAY, Rename, 启用状态	√ , 挂起状态	×
		Menu, TRAY, Icon, 挂起状态	×, config\wubi98.icl, 4
		GuiControl,3:, Pics,*Icon4 config\Skins\logoStyle\%StyleN%.icl
		Traytip,  提示:,已切换至挂起状态！
	}else if !A_IsSuspended {
		if FileExist(A_ScriptDir "\wubi98.ico")
			Menu, Tray, Icon, wubi98.ico
		else
			Menu, Tray, Icon, config\wubi98.icl,30
		Traytip,  提示:,已切换至启用状态！
		;if GET_IMESt()
		;	SwitchToEngIME()
		Menu, TRAY, Rename, 挂起状态	× , 启用状态	√
		Menu, TRAY, Icon, 启用状态	√, config\wubi98.icl, 18
		if srf_mode
			GuiControl,3:, Pics,*Icon1 config\Skins\logoStyle\%StyleN%.icl
		else
			GuiControl,3:, Pics,*Icon3 config\Skins\logoStyle\%StyleN%.icl
	}
	;DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("ActivateKeyboardLayout", UInt, 1, UInt, 256))
return

SetRlk:
	rlk_switch:=WubiIni.Settings["rlk_switch"]:=rlk_switch?0:1,WubiIni.save()
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
			if (a_FontList ~="i)五笔拆字字根字体|98WB-V|98WB-P0|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_&&FontType ~="i)五笔拆字字根字体|98WB-V|98WB-P0|98WB-1|98WB-3|98WB-ZG|98WB-0|" font_)          ;判断是否安装「折分显示的字体」没安装的话只显示编码
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
	Gui, DB:Destroy
	Gui, DB:Default
	Gui, DB: +hwndDB_ +AlwaysOnTop +OwnDialogs +LastFound   ;+ToolWindow -DPIScale +OwnDialogs +MinSize435x470 +MaxSize550x520 -MaximizeBox +Resize
	Gui,DB:Font, s10 , %Font_%
	Gui, DB:Add, Button,y+10 Section gDB_Delete vDB_Delete, 删除
	Gui, DB:Add, Button,x+8 Section gDB_reload vDB_reload, 刷新
	GuiControl, DB:Disable, DB_Delete
	Gui, DB:Add, Button,x+8 Section gDB_search vDB_search, 搜索
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
	DLV := New LV_Colors(DBLV)
	DLV.SelectionColors(0xfecd1b)
	Gui,DB:Font,
	Gui,DB:Font, s10, %font_%
	Gui, DB:Add, Button,y+10 Section gDB_BU vDB_BU, 导出全部
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cblue, %font_%
	Gui, DB:Add, Button,x+150 yp Section vToppage gToppage,首页
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cred, %font_%
	Gui, DB:Add, Button,x+5 Section vuppage guppage,上一页
	Gui, DB:Add, Button,x+5 Section vnextpage gnextpage,下一页
	Gui,DB:Font,
	Gui,DB:Font, s9 bold cblue, %font_%
	Gui, DB:Add, Button,x+5 Section vLastpage gLastpage,尾页
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
	Gui,DB:Show,w435,自造词管理
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
	Gui, DB:Hide
	custom_db:=1
	Gosub Backup_DB
	Gui, DB:show,NA
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
	DLV.SelectionColors(0xfecd1b),counts:=0
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
		GuiControl, DB:Enable, nextpage
		GuiControl, DB:Enable, Lastpage
	}else{
		GuiControl, DB:Disable, nextpage
		GuiControl, DB:Disable, Lastpage
	}
	if (DB_Page<2){
		GuiControl, DB:Disable, uppage
		GuiControl, DB:Disable, Toppage
	}else{
		GuiControl, DB:Enable, uppage
		GuiControl, DB:Enable, Toppage
	}
	;GuiControlGet, BUVar, Pos , DB_BU
	SB_SetText(A_Space "[  " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条  ]")
Return

ReadDB:
	DLV.SelectionColors(0xfecd1b)
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
		GuiControl, DB:Enable, nextpage
		GuiControl, DB:Enable, Lastpage
	}else{
		GuiControl, DB:Disable, nextpage
		GuiControl, DB:Disable, Lastpage
	}
	if (DB_Page<2){
		GuiControl, DB:Disable, uppage
		GuiControl, DB:Disable, Toppage
	}else{
		GuiControl, DB:Enable, uppage
		GuiControl, DB:Enable, Toppage
	}
	;GuiControlGet, BUVar, Pos , DB_BU
	SB_SetText(A_Space "[  " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条  ]")
Return

DB_search:
	GuiControlGet, tVar, DB:Visible , search_text
	if !tVar{
		GuiControl, DB:Show, search_text
		GuiControl, DB:Show, search_1
		GuiControl, DB:Disable, uppage
		GuiControl, DB:Disable, nextpage
	}else{
		GuiControl, DB:Hide, search_text
		GuiControl, DB:Hide, search_1
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
		GuiControl, DB:Disable, uppage
		GuiControl, DB:Disable, nextpage
		GuiControl, DB:Disable, Lastpage
		GuiControl, DB:Disable, Toppage
		GuiControl, DB:Enable, search_1
		Gosub search_result
	}else if (search_text=""&&tVar){
		GuiControl, DB:Disable, search_1
		ss:=0
		LV_Delete()
		Gosub ReadDB
		SB_SetText(A_Space "[  " (DB_Page-1)*DB_Count+1 . " / " Result_.RowCount " 条  ]")
	}
Return

search_result:
	ss:=0
	DLV.SelectionColors(0xC0C0C0)
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
