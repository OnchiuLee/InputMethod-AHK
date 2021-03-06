﻿#NoEnv
#NoTrayIcon
#SingleInstance, Force

Sourceurl:="https://gitee.com/leeonchiu/AHK-Input-method/blob/master/Version.txt"
downloadurl:=DllCall("Wininet.dll\InternetCheckConnection", "Str", downloadurl1, "UInt", 0x1, "UInt", 0x0, "Int")?downloadurl1:downloadurl2

Versions:=A_Args[1], InputMethodName:= A_Args[2]
Progress, M ZH-1 ZW-1 Y100 W420 C0 FM14 WS700 CTffffff CW0078d7,, 正在检查最新版本。。。, 检查更新
OnMessage(0x201, "MoveProgress")
If (!DllCall("Wininet.dll\InternetCheckConnection", "Str", Sourceurl, "UInt", 0x1, "UInt", 0x0, "Int"))
	MsgBox, 262160, 检查更新, 网络异常！, 8
else{
	GetVersionInfo:=GetVersion(Sourceurl), _sj:=StrSplit(GetVersionInfo[1], "@")
	If (_sj[2]>SubStr(Versions,1,10)&&_sj.Length()) {
		Progress, off
		MsgBoxRenBtn("打开下载页","取消")
		MsgBox, 262724, 更新提示, % "发现新版本>> " _sj[2] (GetVersionInfo[2]?"`n*********************************************************`n" GetVersionInfo[2] "`n*********************************************************`n":"`n")
		IfMsgBox, Yes
		{
			Run, https://gitee.com/leeonchiu/AHK-Input-method,, UseErrorLevel
			if (ErrorLevel = "ERROR")
				Run, iexplore.exe "https://gitee.com/leeonchiu/AHK-Input-method",, UseErrorLevel
		}else IfMsgBox, Cancel
			ExitApp
	}else If (_sj[2]<=SubStr(Versions,1,10)&&_sj.Length()) {
		Progress, off
		MsgBox, 262208, 检查更新, 已是最新版！, 8
	}else{
		Progress, off
		MsgBox, 262160, 检查更新, 检查失败！, 8
	}
	Progress, off
}
ExitApp

GetVersion(URL,Charset="",Timeout=-1)
{
	ComObjError(0)
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("GET", URL, true)
	WebRequest.Send()
	WebRequest.WaitForResponse(Timeout)
	if (Charset=""){
		RegExMatch(WebRequest.ResponseText(), "/[a-zA-Z0-9]*@20[2-3][0-5][0-9]{6}", UpdateVersion)
		RegExMatch(WebRequest.ResponseText(), "\〔(.*)\〕", UpdateInfo), UpdateInfo:=RegExReplace(UpdateInfo,"\〕.+\〕|^\〔|\〕$")
		return [UpdateVersion,UpdateInfo]
	}else{
		ADO:=ComObjCreate("adodb.stream"), ADO.Type:=1, ADO.Mode:=3
		ADO.Open(), ADO.Write(WebRequest.ResponseBody())
		ADO.Position:=0, ADO.Type:=2, ADO.Charset:=Charset
		RegExMatch(WebRequest.ResponseText(), "/[a-zA-Z0-9]*@20[2-3][0-5][0-9]{6}", UpdateVersion)
		RegExMatch(WebRequest.ResponseText(), "\〔(.*)\〕", UpdateInfo), UpdateInfo:=RegExReplace(UpdateInfo,"\〕.+\〕|^\〔|\〕$")
		return [UpdateVersion,UpdateInfo]
	}
}

UrlDownloadToFile(URL, FilePath:="",Timeout=-1){   ;Timeout 超时限制设置 单位为秒 不超时处理为-1 
	If (FilePath="")
		FilePath:=Url2Decode(RegExReplace(URL,".+\/"))
	ComObjError(1)
	If RegExMatch(LTrim(FilePath, "\"), "(.*\\)?([^\\]+)$", FilePath){
		TC:=CheckTickCount()
		Progress,M ZH-1 ZW-1 Y80 FM14 W400 C0 FS14 WS700 CW0078d7 CTffffff,, %FilePath%-下载中..., 检查更新
		OnMessage(0x201, "MoveProgress")
		If (FilePath1&&!FileExist(FilePath1)){
			FileCreateDir, %FilePath1%
			If ErrorLevel {
				Progress, Off
				Return 0
			}
		}
		WebRequest:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("GET", URL, 1)
		Try {
			WebRequest.Send()
			WebRequest.WaitForResponse(Timeout)
		} Catch {
			Progress, Off
			Run, https://gitee.com/leeonchiu/AHK-Input-method,, UseErrorLevel
			if (ErrorLevel = "ERROR") {
				Run, iexplore.exe "https://gitee.com/leeonchiu/AHK-Input-method",, UseErrorLevel
				MsgBox, 262160, 检查更新, 您的电脑未设定默认浏览器！, 8
			}
			MsgBox, 262192, 检查更新, 下载超时！, 8
			Return 0
		}
		If !WebRequest.ResponseBody() {
			Progress, Off
			MsgBox, 262192, 检查更新, 下载失败！, 8
			Return 0
		}
		ADO:=ComObjCreate("adodb.stream"), ADO.Type:=1, ADO.Mode:=3, ADO.Open()
		Try ADO.Write(WebRequest.ResponseBody())
		Try ADO.SaveToFile(A_Desktop "\" FilePath,2)
		ADO.Close(), WebRequest:=ADO:="", TimeCount:=CheckTickCount(TC)
		Progress, Off
		MsgBox, 262208, 检查更新, 下载成功，耗时%TimeCount%。`n文件%FilePath%在电脑桌面请解压更新！！, 8
		Return 1
	} Else{
		Progress, Off
		MsgBox, 262192, 检查更新, 下载失败！, 8
		Return 0
	}
}

DownloadToString(url, encoding = "utf-8")
{
	static a := "AutoHotkey/" A_AhkVersion
	if (!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
		return 0
	c := s := 0, o := ""
	if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr"))
	{
		while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s > 0)
		{
			VarSetCapacity(b, s, 0)
			DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
			o .= StrGet(&b, r >> (encoding = "utf-16" || encoding = "cp1200"), encoding)
		}
		DllCall("wininet\InternetCloseHandle", "ptr", f)
	}
	DllCall("wininet\InternetCloseHandle", "ptr", h)
	return o
}

DownloadToFile(url, filename)
{
	static a := "AutoHotkey/" A_AhkVersion
	if (!(o := FileOpen(filename, "w")) || !DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
		return 0
	c := s := 0
	if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr"))
	{
		while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s > 0)
		{
			VarSetCapacity(b, s, 0)
			DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b, "uint", s, "uint*", r)
			c += r
			o.rawWrite(b, r)
		}
		DllCall("wininet\InternetCloseHandle", "ptr", f)
	}
	DllCall("wininet\InternetCloseHandle", "ptr", h)
	o.close()
	return c
}

DownloadBin(url, byref buf)
{
	static a := "AutoHotkey/" A_AhkVersion
	if (!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
		return 0
	c := s := 0
	if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr"))
	{
		while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s > 0)
		{
			VarSetCapacity(b, c + s, 0)
			if (c > 0)
				DllCall("RtlMoveMemory", "ptr", &b, "ptr", &buf, "ptr", c)
			DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b + c, "uint", s, "uint*", r)
			c += r
			VarSetCapacity(buf, c, 0)
			if (c > 0)
				DllCall("RtlMoveMemory", "ptr", &buf, "ptr", &b, "ptr", c)
		}
		DllCall("wininet\InternetCloseHandle", "ptr", f)
	}
	DllCall("wininet\InternetCloseHandle", "ptr", h)
	return c
}

MoveProgress() {
	PostMessage, 0xA1, 2 
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

Url2Decode(Str)
{
	Static doc := ComObjCreate("HTMLfile")
	Try
	{
		doc.write("<body><script>document.body.innerText = decodeURIComponent(""" . Str . """);</script>")
		Return, doc.body.innerText, doc.body.innerText := ""
	}
}
