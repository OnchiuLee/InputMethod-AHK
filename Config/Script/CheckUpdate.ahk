#NoEnv
#NoTrayIcon
#SingleInstance, Force
Sourceurl:="https://github.com/OnchiuLee/AHK-Input-method/blob/master/Version.txt"
IniRead, Versions, %A_Temp%\InputMethodData\Config.ini, Settings, versions

If (!DllCall("Wininet.dll\InternetCheckConnection", "Str", Sourceurl, "UInt", 0x1, "UInt", 0x0, "Int"))
	MsgBox, 262160, 检查更新, 网络异常！, 8
else{
	_sj:=StrSplit(GetVersion(Sourceurl), "@")
	If (_sj[2]>SubStr(Versions,1,10)&&_sj.Length()) {
		MsgBoxRenBtn("下载","打开下载页","取消")
		MsgBox, 262723, 更新提示, 发现新版本，是否下载至电脑桌面？`n下载过程中，请该干嘛去干嘛！！！
		IfMsgBox, Yes
			UrlDownloadToFile("https://github.com/OnchiuLee/AHK-Input-method/archive/master.zip", "柚子98五笔版-" _sj[2] ".zip",1800)
		else IfMsgBox, No
		{
			Run, https://gitee.com/leeonchiu/AHK-Input-method,, UseErrorLevel
			if (ErrorLevel = "ERROR")
				Run, iexplore.exe "https://gitee.com/leeonchiu/AHK-Input-method",, UseErrorLevel
		}else IfMsgBox, Cancel
			ExitApp
	}else If (_sj[2]<=SubStr(Versions,1,10)&&_sj.Length()) {
		MsgBox, 262208, 检查更新, 已是最新版！, 8
	}else{
		MsgBox, 262160, 检查更新, 检查失败！, 8
	}
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
		return,UpdateVersion
	}else{
		ADO:=ComObjCreate("adodb.stream"), ADO.Type:=1, ADO.Mode:=3
		ADO.Open(), ADO.Write(WebRequest.ResponseBody())
		ADO.Position:=0, ADO.Type:=2, ADO.Charset:=Charset
		RegExMatch(WebRequest.ResponseText(), "/[a-zA-Z0-9]*@20[2-3][0-5][0-9]{6}", UpdateVersion)
		return,UpdateVersion
	}
}

UrlDownloadToFile(URL, FilePath:="",Timeout=-1){   ;Timeout 超时限制设置 单位为秒 不超时处理为-1 
	If (FilePath="")
		FilePath:=Url2Decode(RegExReplace(URL,".+\/"))
	ComObjError(1)
	If RegExMatch(LTrim(FilePath, "\"), "(.*\\)?([^\\]+)$", FilePath){
		Progress,B2 M ZH-1 ZW-1 FS12 WS600, %FilePath%-从GitHub下载中...
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
		ADO.Close(), WebRequest:=ADO:=""
		Progress, Off
		MsgBox, 262208, 检查更新, 下载成功，文件%FilePath%在电脑桌面请解压更新！！, 8
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

Url2Decode(Str)
{
	Static doc := ComObjCreate("HTMLfile")
	Try
	{
		doc.write("<body><script>document.body.innerText = decodeURIComponent(""" . Str . """);</script>")
		Return, doc.body.innerText, doc.body.innerText := ""
	}
}
