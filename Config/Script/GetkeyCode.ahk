#NoEnv
#NoTrayIcon
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent
#SingleInstance, force

kbhk := 0, mhk := 0, DefaultFontName:=GetDefaultFontName()
KBCallback := RegisterCallback("KeyboardHookProc",,3)
MCallback := RegisterCallback("MouseHookProc",,3)

OnExit, _OnExit

CaptainHook(true)
return
_OnExit:
	CaptainHook(false)
	Gui Name:Destroy
	ExitApp, 0
return

SetWindowsHookEx(idHook, lpfn, hMod, dwthreadId) {
	return DllCall("SetWindowsHookEx", Int, idHook, Ptr, lpfn, Ptr, hMod, UInt, dwthreadId)
}
UnhookWindowsHookEx(hhk) {
	return DllCall("UnhookWindowsHookEx", Ptr, hhk)
}
CallNextHookEx(hhk, nCode, wParam, lParam) {
	return DllCall("CallNextHookEx", Ptr, hhk, Int, nCode, Ptr, wParam, Ptr, lParam)
}
GetLastError() {
	return DllCall("GetLastError")
}

EM_SetCueBanner(hWnd, Cue)
{
	static EM_SETCUEBANNER := 0x1501
	return DllCall("User32.dll\SendMessage", "Ptr", hWnd, "UInt", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}

MoveProgress() {
	PostMessage, 0xA1, 2 
}

CreateGUI() {
	global info, htky, htky2, DefaultFontName, Control1
	Gui Name:Destroy
	Gui,Name: +hWndKeyCode -MinimizeBox +AlwaysOnTop  ;-Theme
	Gui, Name:font,s9 bold, %DefaultFontName% 
	Gui, Name:font,s9 norm , %DefaultFontName%
	Gui, Name:Add, edit,xm+10 y+15 center w150 -WantReturn vinfo hWndinfo,
	GuiControl,Name:disable,info
	Gui, Name:Add, Text,x+10 gControl1 vControl1 cgreen -Wrap ,复制键名
	;;EM_SetCueBanner(info, "按键名")
	;Gui Name:Add, Text,xm+10 y+10 w230 h2 0x10
	Gui, Name:Add, edit,xm+10 y+15 center vhtky -WantReturn w150 hWndhtky,
	GuiControl,Name:disable,htky
	Gui, Name:Add, Text,x+10 gControl2 cgreen ,复制VK码
	;;EM_SetCueBanner(htky, "虚拟码(VK)")
	;Gui Name:Add, Text,xm+10 y+10 w230 h2 0x10
	Gui, Name:Add, edit,xm+10 y+15 center w150 -WantReturn vhtky2 hWndhtky2,
	GuiControl,Name:disable,htky2
	Gui, Name:Add, Text,x+10 gControl3 cgreen ,复制SC码
	;;EM_SetCueBanner(htky2, "扫描码(SC)")
	Gui, Name:Color,ffffff
	Gui, Name:font,s9 norm, %DefaultFontName%
	Gui, Name:Add, StatusBar,,  ⛳ 在此窗口活动的情况下按下按键
	DllCall("PrivateExtractIcons", "str", "shell32.dll", "int", 12, "int", 32, "int", 32, "ptr*", hIcon, "uint*", 0, "uint", 1, "uint", 0, "ptr")
	Gui, Name:Show, w280, 键值码获取
	SendMessage, 0x80, ICON_SMALL2:=0, hIcon,, ahk_id %KeyCode%
	SendMessage, 0x80, ICON_BIG:=1   , hIcon,, ahk_id %KeyCode%
	OnMessage(0x201, "MoveProgress")
	ControlFocus , button3, A

	Control1:
		If A_ThisLabel {
			GuiControlGet, info,, info, text
			If info {
				Clipboard:=info
				Gui +OwnDialogs
				MsgBox,0,键名获取 ,复制成功！,4
			}else
				MsgBox,0,键名获取 ,不能为空！,4
		}
	return
	Control2:
		If A_ThisLabel {
			GuiControlGet, htky,, htky, text
			If htky {
				Clipboard:=htky
				Gui +OwnDialogs
				MsgBox,0,虚拟码获取 ,复制成功！,4
			}else
				MsgBox,0,虚拟码获取 ,不能为空！,4
		}
	return

	Control3:
		If A_ThisLabel {
			GuiControlGet, htky2,, htky2, text
			If htky2 {
				Clipboard:=htky2
				Gui +OwnDialogs
				MsgBox,0,扫描码获取 ,复制成功！,4
			}else
				MsgBox,0,扫描码获取 ,不能为空！,4
		}
	return

	NameGuiClose:
	NameGuiEscape:
		CaptainHook(false)
		Gosub _OnExit
	return
}

GetDefaultFontName(){
	NumPut(VarSetCapacity(info, A_IsUnicode ? 504 : 344, 0), info, 0, "UInt")
	DllCall("SystemParametersInfo", "UInt", 0x29, "UInt", 0, "Ptr", &info, "UInt", 0)
	return StrGet(&info + 52)
}

CaptainHook(enable := false) {
	global kbhk, mhk, MCallback, KBCallback
	static WH_KEYBOARD := 2, WH_MOUSE := 7
	if(enable) {
		dwThreadId := DllCall("GetCurrentThreadId")

		if(kbhk or mhk) ;remove any old hooks
			CaptainHook(false)

		kbhk := SetWindowsHookEx(WH_KEYBOARD, KBCallback, 0, dwThreadId)
		if(!kbhk)
			MsgBox, % "Failed to set Keyboard hook: error " . GetLastError()
		mhk := SetWindowsHookEx(WH_MOUSE, MCallback, 0, dwThreadId)
		if(!mhk)
			MsgBox, % "Failed to set Mouse hook: error " . GetLastError()

		if(mhk and kbhk)
			CreateGUI()
	} else {
		if(kbhk) {
			UnhookWindowsHookEx(kbhk)
			kbhk := 0
		}

		if(mhk) {
			UnhookWindowsHookEx(mhk)
			mhk := 0
		}
		Gui Name:Destroy
	}
}


KeyboardHookProc(code, wParam, lParam) {
	if(code == 0 or code == 3) {
		vk := wParam, sc := lParam
		GuiControl,Name:,htky,% Format("VK{:X}", vk)
		sc:=RegExreplace(Format("{:2X}", sc-1),"[0]{4}$")
		GuiControl,Name:,htky2,% sc~="^C"?"S" sc:"SC" sc
		GuiControl,Name:,info,% GetKeyName(Format("vk{:x}", vk))
	} else {
		return CallNextHookEx(0, code, wParam, lParam)
	}
}

MouseHookProc(code, wParam, lParam) {
	if(code == 0 or code == 3) {
		m_id := wParam
		mousehookstruct := lParam
	} else {
		return CallNextHookEx(0, code, wParam, lParam)
	}
}
