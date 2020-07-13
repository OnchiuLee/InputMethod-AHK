#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
#Include lib\Class_WinClipAPI.ahk
#Include lib\Class_WinClip.ahk
#Include lib\Class_EasyIni.ahk
WinGetPos,,,,Shell_Wnd ,ahk_class Shell_TrayWnd

global default_obj, AHKIni:=class_EasyIni("setting.ini")
default_obj:={FilePath:["C:\Windows\System32\drivers\etc\hosts","C:\Windows\WMInfo"],FileLists:["C:\Windows\System32\drivers\etc\hosts"],Hotkeys:{RunHotkey:"!d"}}
Array_isInValue(aArr, aStr)
{
	for k,v in aArr
	{
		if (IsObject(v) && (aArr[k].count()>0))
		{
			if (Array_isInValue(aArr[k],aStr) = 1)
				return 1
		}
		else if (!IsObject(v) && (v=aStr))
			return 1
	}
}
For Section, element In default_obj
{
	if (AHKIni[Section].length()<1)
		For key, value In element
			AHKIni[Section, key]:=value
}
AHKIni.Save()
RunHotkey:=AHKIni["Hotkeys","RunHotkey"]
WinClip := new WinClip
Gosub TRAY_Menu
Gosub ReadInis
if FileExist(A_ScriptDir "\*.ico") {
	Loop,Files,*.ico
		IcoFileN:=A_LoopFileLongPath, break
	Menu, Tray, Icon, %IcoFileN%
}
;*****************¿ì½Ý¼ü²Ù×÷*****************
if RunHotkey
	Hotkey, %RunHotkey%, SendFile,on
;******************************************


#Include Script\Script1.ahk