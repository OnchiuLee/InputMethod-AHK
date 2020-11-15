;获取系统参数
Class ComInfo
{
	/*
		;http://pv.sohu.com/cityjson?ie=utf-8
		    ;返回值{"cip":"xxx","cid":"xxx","cname":"xxx"}
		    ;cip：ip地址
		    ;cid：邮编
		    ;cname：归属地
		;能获取外网ip的接口：
		;http://members.3322.org/dyndns/getip    ;直接返回ip
		;https://api.ipify.org/    ;直接返回ip
		;http://icanhazip.com/    ;直接返回ip
		;http://ident.me/    ;直接返回ip
		;http://ip.cip.cc/    ;直接返回ip
		;http://ip.qaros.com/    ;直接返回ip
		;https://api.ip.sb/ip    ;直接返回ip
		;http://ip.3322.net/    ;直接返回ip
		;http://ip.42.pl/raw    ;直接返回ip
		;https://www.fbisb.com/ip.php
		;http://myip.ipip.net/json    ;返回json格式参数如下：
			{"ret":"ok"
			,"data":
				{"ip":"59.173.134.130"
				,"location":["中国","xx省","xx","","电信"]}}
		;http://ip-api.com/json/?fields=520191&lang=zh-CN    ;返回json格式参数如下:
			{"status":"success","country":"中国"
			,"countryCode":"CN","region":"HB"
			,"regionName":"xx省","city":"xx市"
			,"zip":"","lat":30.5856,"lon":114.2665
			,"timezone":"Asia/Shanghai","isp":"Chinanet"
			,"org":"Chinanet HB","as":"AS4134 CHINANET-BACKBONE"
			,"mobile":false,"proxy":false,"accuracy":10
			,"query":"171.113.255.124"
		;https://api.ttt.sh/ip/qqwry/    返回json格式参数如下：
			{"code":200,"ip":"171.113.255.124"
			,"address":"\u6e56\u5317\u7701 \u7535\u4fe1"
			,"date":"2020-06-23 10:09:40"}
		;http://whois.pconline.com.cn/ipJson.jsp?json=true    返回json格式参数如下：
			{"ip":"171.113.255.124","pro":"xx省"
			,"proCode":"420000","city":"xx市"
			,"cityCode":"420100","region":""
			,"regionCode":"0","addr":"xx省xx市 电信"
			,"regionNames":"","err":""}
	*/
	;获取本机外网IP①
	GetIPAPI(url:="http://pv.sohu.com/cityjson?ie=utf-8") {
		/*
		;	;~ 测试网络连接
		;	if(!DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &Url, "UInt", 0x1, "UInt", 0x0, "Int"))
		;		return []
		;	iHTTP := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		;	iHTTP.Open("Get", URL , False)
		;	iHTTP.SetRequestHeader("User-Agent", "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)")
		;	iHTTP.SetRequestHeader("Referer", URL)
		;	iHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		;	iHTTP.Send()
		;	RegExMatch(iHTTP.ResponseText,"\{.+\}",ipobj)   ;iHTTP.ResponseText为接收的结果
		;	iJson:= Json_toObj(ipobj)
		;	return [ iJson["cip"], iJson["cname"],"〔 " iJson["cname"] " 〕"]
		*/
		if ipobj:=this.UrlDownloadToVars(url,,,,,,,,,3){   ;设定超时时长
			RegExMatch(ipobj,"\{.+\}",obj)
			iJson:= Json_toObj(obj)
			return [ iJson["cip"], iJson["cname"],"〔 " iJson["cname"] " 〕"]
		}
	}
	;获取本机外网IP②
	GetIPAPI_1(url:="http://myip.ipip.net/json") {
		if ipobj:=this.UrlDownloadToVars(url,,,,,,,,,3){   ;设定超时时长
			iJson:= Json_toObj(ipobj)
			ipLocal:= iJson["data","location"][1] iJson["data","location"][2] iJson["data","location"][3] iJson["data","location"][5]
			return [ iJson["data","ip"], ipLocal,"〔 " ipLocal " 〕"]
		}
	}
	;获取本机外网IP③
	GetIPAPI_2(url:="http://whois.pconline.com.cn/ipJson.jsp?json=true") {
		if ipobj:=this.UrlDownloadToVars(url,,,,,,,,,3){   ;设定超时时长
			iJson:= Json_toObj(ipobj)
			ipLocal:= iJson["pro"] iJson["city"] "-" iJson["addr"]
			return [ iJson["ip"], ipLocal,"〔 " ipLocal " 〕"]
		}
	}
	;获取本机外网IP④
	GetIPAPI_3(url:="https://api.ttt.sh/ip/qqwry/") {
		if ipobj:=this.UrlDownloadToVars(url,,,,,,,,,3){   ;设定超时时长
			iJson:= Json_toObj(ipobj)
			return [ iJson["ip"], iJson["address"],"〔 " iJson["address"] " 〕"]
		}
	}
	;获取设备型号
	GetMacName(){
		;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-computersystemproduct
		objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . "." . "\root\cimv2")
		colSysProduct := objWMIService.ExecQuery("Select * From Win32_ComputerSystemProduct")._NewEnum
		while,colSysProduct[objSysProduct]   ;PropertyList>>["Caption,Description,IdentifyingNumber,Name,SKUNumber,UUID,Vendor,Version"]
		{
			return [objSysProduct["Name"]," 设备品牌型号 ","〔 设备品牌型号 〕"]
		}
	}
	;获取网卡物理地址
	GetMacAddress(){
		;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-networkadapterconfiguration
		NetworkConfiguration:=ComObjGet("Winmgmts:").InstancesOf("Win32_NetworkAdapterConfiguration")
		for mo in NetworkConfiguration
		{
			if(mo.IPEnabled <> 0)
				return mo.MacAddress
		}
	}
	;获取网卡物理地址
	GetMacAddress_1(){
		Adlist:=[], info:=this.GetAdaptersInfo()
		for index, obj in info
			if (not obj["Description"] ~="i)Adapter"||obj["Description"] ~="i)Wifi|wlan")
				Adlist.Push([obj["Address"]," " . obj["Description"] . " ","〔 " . obj["Description"] . " 〕"])
		return Adlist
	}
	;获取IP地址
	GetIPAddress_1(){
		Adlist:=[], info:=this.GetAdaptersInfo()
		for index, obj in info
		{
			if (not obj["Description"] ~="i)Adapter"||obj["Description"] ~="i)Wifi|wlan")
				Adlist.Push([obj["IpAddressList"]," " . obj["Description"] . " ","〔 " . obj["Description"] . " 〕"])
		}
		return Adlist
	}
	;获取CPU串号
	GetCpuID_1(){
		;https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor
		objSWbemObject:=ComObjGet("winmgmts:Win32_Processor.DeviceID='cpu0'")
		return objSWbemObject.ProcessorId
	}
	;获取CPU串号
	GetCpuID_2(){
		CID := cmdClipReturn("wmic cpu get Processorid")
		loop, parse,CID,`n,`r
			if (A_LoopField&&not A_LoopField~="i)Process")
				CidList:= RegExReplace(A_LoopField,"\s+")
		return CidList
	}
	;获取CPU串号
	GetCpuID_3(){
		;https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor
		objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
		colCPU := objWMIService.ExecQuery("Select * From Win32_Processor")._NewEnum
		While colCPU[objCPU]
			return objCPU["ProcessorId"]    ;Name获取cpu名称
	}
	;获取系统版本信息
	GetOSVersionInfo()
	{
		;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-operatingsystem?redirectedfrom=MSDN
		osobj := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_OperatingSystem" )._NewEnum()
		if osobj[win]
			return [win.Caption,win.Version,win.Version]
	}
	;返回当前电脑BIOS里的SN机器码
	GetSNCode(){
		;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-bios
		objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . "." . "\root\cimv2")
		colSettings := objWMIService.ExecQuery("Select * from Win32_BIOS")._NewEnum
		While colSettings[objBiosItem]
			return [objBiosItem.SerialNumber," 设备S/N序列号 ","〔 设备S/N序列号 〕"]
	}
	;返回当前电脑BIOS里的SN机器码
	GetSNCode_1(){
		;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-computersystemproduct
		objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . "." . "\root\cimv2")
		colSysProduct := objWMIService.ExecQuery("Select * From Win32_ComputerSystemProduct")._NewEnum
		while,colSysProduct[objSysProduct]   ;PropertyList>>["Caption,Description,IdentifyingNumber,Name,SKUNumber,UUID,Vendor,Version"]
		{
			return [objSysProduct["IdentifyingNumber"]," 设备S/N序列号 ","〔 设备S/N序列号 〕"]
		}
	}
	;返回当前电脑BIOS里的SN机器码
	GetSNCode_2(){
		SID := cmdClipReturn("wmic bios get serialnumber")
		loop, parse,SID,`n,`r
			if (A_LoopField&&not A_LoopField~="i)seria")
				sidList:= RegExReplace(A_LoopField,"\s+")
		return sidList
	}
	;获取网卡mac地址
	GetAdaptersInfo(){
		; 对GetAdaptersInfo的初始调用以获取所需的大小
		if (DllCall("iphlpapi.dll\GetAdaptersInfo", "ptr", 0, "UIntP", size) = 111) ; ERROR_BUFFER_OVERFLOW
			if !(VarSetCapacity(buf, size, 0))  ; size ==>  1x = 704  |  2x = 1408  |  3x = 2112
				return "IP适配器信息结构的内存分配失败！"
		; 第二次调用GetAdapters地址以获取我们想要的实际数据
		if (DllCall("iphlpapi.dll\GetAdaptersInfo", "ptr", &buf, "UIntP", size) != 0) ; NO_ERROR / ERROR_SUCCESS
			return "调用GetAdaptersInfo失败，ERROR: " A_LastError
		; 从数据中获取信息
		addr := &buf, IP_ADAPTER_INFO := {}
		while (addr)
		{
			IP_ADAPTER_INFO[A_Index, "ComboIndex"]:= NumGet(addr+0, o := A_PtrSize, "UInt"), o += 4
			IP_ADAPTER_INFO[A_Index, "AdapterName"]:= StrGet(addr+0 + o, 260, "CP0"), o += 260
			IP_ADAPTER_INFO[A_Index, "Description"]:= StrGet(addr+0 + o, 132, "CP0"), o += 132
			IP_ADAPTER_INFO[A_Index, "AddressLength"]:= NumGet(addr+0, o, "UInt"), o += 4
			loop % IP_ADAPTER_INFO[A_Index].AddressLength
				mac .= Format("{:02X}",NumGet(addr+0, o + A_Index - 1, "UChar")) "-"
			IP_ADAPTER_INFO[A_Index, "Address"]:= SubStr(mac, 1, -1), mac := "", o += 8
			IP_ADAPTER_INFO[A_Index, "Index"]:= NumGet(addr+0, o, "UInt"), o += 4
			IP_ADAPTER_INFO[A_Index, "Type"]:= NumGet(addr+0, o, "UInt"), o += 4
			IP_ADAPTER_INFO[A_Index, "DhcpEnabled"]:= NumGet(addr+0, o, "UInt"), o += A_PtrSize
			Ptr := NumGet(addr+0, o, "UPtr"), o += A_PtrSize
			IP_ADAPTER_INFO[A_Index, "CurrentIpAddress"]:= Ptr ? StrGet(Ptr + A_PtrSize, "CP0") : ""
			IP_ADAPTER_INFO[A_Index, "IpAddressList"]:= StrGet(addr + o + A_PtrSize, "CP0")
			;~ IP_ADAPTER_INFO[A_Index, "IpMaskList"]:= StrGet(addr + o + A_PtrSize + 16, "CP0") , o += A_PtrSize + 32 + A_PtrSize
			IP_ADAPTER_INFO[A_Index, "IpMaskList"]:= StrGet(addr + o + A_PtrSize * 3, "CP0") , o += A_PtrSize + 32 + A_PtrSize
			IP_ADAPTER_INFO[A_Index, "GatewayList"]:= StrGet(addr + o + A_PtrSize, "CP0"), o += A_PtrSize + 32 + A_PtrSize
			IP_ADAPTER_INFO[A_Index, "DhcpServer"]:= StrGet(addr + o + A_PtrSize, "CP0"), o += A_PtrSize + 32 + A_PtrSize
			IP_ADAPTER_INFO[A_Index, "HaveWins"]:= NumGet(addr+0, o, "Int"), o += A_PtrSize
			IP_ADAPTER_INFO[A_Index, "PrimaryWinsServer"]:= StrGet(addr + o + A_PtrSize, "CP0"), o += A_PtrSize + 32 + A_PtrSize
			IP_ADAPTER_INFO[A_Index, "SecondaryWinsServer"] := StrGet(addr + o + A_PtrSize, "CP0"), o += A_PtrSize + 32 + A_PtrSize
			IP_ADAPTER_INFO[A_Index, "LeaseObtained"]:= DateAdd(NumGet(addr+0, o, "Int")), o += A_PtrSize
			IP_ADAPTER_INFO[A_Index, "LeaseExpires"]:= DateAdd(NumGet(addr+0, o, "Int"))
			addr := NumGet(addr+0, "UPtr")
		}
		; 输出数据并释放缓冲区
		return IP_ADAPTER_INFO, VarSetCapacity(buf, 0), VarSetCapacity(addr, 0)
	}
	;获取系统默认字体名
	GetDefaultFontName(){
		NumPut(VarSetCapacity(info, A_IsUnicode ? 504 : 344, 0), info, 0, "UInt")
		DllCall("SystemParametersInfo", "UInt", 0x29, "UInt", 0, "Ptr", &info, "UInt", 0)
		return StrGet(&info + 52)
	}
	;~ *****************说明*****************
	;~ 此函数与内置命令 UrlDownloadToFile 的区别有以下几点
	;~ 1.直接下载到变量，没有临时文件
	;~ 2.下载速度更快，大概100%
	;~ 3.支持超时，不必死等
	;~ 4.内置命令执行时，整个AHK程序都是卡顿状态。此函数不会
	;~ 5.内置命令下载一些诡异网站（例如“牛杂网”）时，会概率性让进程或线程彻底死掉。此函数不会
	;~ 6.支持设置网页字符集、URL的编码，乱码问题轻松解决
	;~ 7.支持设置Cookie、Referer、User-Agent，网站检测问题轻松解决
	;~ 8.支持设置代理服务器
	;~ 9.支持设置是否开启重定向
	;~ 10.这个版本是 0.5
	;~ *****************参数*****************
	;~ URL 网址，必须包含类似“http://www.”的开头。
	;~ Charset 网页字符集，不能是“936”之类的数字，必须是“gb2312”这样的字符。
	;~ URLCodePage URL的编码，是“936”之类的数字，默认是“65001”。有些网站需要UTF-8，有些网站又需要gb2312
	;~ Proxy 代理服务器，是形如“http://www.tuzi.com:80”的字符。
	;~ ProxyBypassList 代理服务器绕行名单，是形如“*.microsoft.com”的域名。符合域名的网址，将不通过代理服务器访问。
	;~ Cookie ，常用于登录验证。
	;~ Referer 引用网址，常用于防盗链。
	;~ UserAgent 用户信息，常用于防盗链。
	;~ EnableRedirects 重定向，默认获取跳转后的页面信息，0为不跳转。
	;~ Timeout 超时，单位为秒，默认不使用超时（Timeout=-1）。
	UrlDownloadToVars(URL,Charset="",URLCodePage="",Proxy="",ProxyBypassList="",Cookie="",Referer="",UserAgent="",EnableRedirects="",Timeout=-1)
	{
		ComObjError(0)  ;禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		if (URLCodePage<>"")    ;设置URL的编码
			WebRequest.Option(2):=URLCodePage
		if (EnableRedirects<>"")
			WebRequest.Option(6):=EnableRedirects
		if (Proxy<>"")  ;设置代理服务器。微软的代码 SetProxy() 是放在 Open() 之前的，所以我也放前面设置，以免无效
			WebRequest.SetProxy(2,Proxy,ProxyBypassList)
		WebRequest.Open("GET", URL, true)   ;true为异步获取，默认是false。龟速的根源！！！卡顿的根源！！！
		if (Cookie<>"") ;设置Cookie。SetRequestHeader() 必须 Open() 之后才有效
		{
			WebRequest.SetRequestHeader("Cookie","tuzi")    ;先设置一个cookie，防止出错，见官方文档
			WebRequest.SetRequestHeader("Cookie",Cookie)
		}
		if (Referer<>"")    ;设置Referer
			WebRequest.SetRequestHeader("Referer",Referer)
		if (UserAgent<>"")  ;设置User-Agent
			WebRequest.SetRequestHeader("User-Agent",UserAgent)
		WebRequest.Send()
		WebRequest.WaitForResponse(Timeout) ;WaitForResponse方法确保获取的是完整的响应
		if (Charset="") ;设置字符集
			return,RegExReplace(WebRequest.ResponseText(),"^\s+|\s+$")
		else
		{
			ADO:=ComObjCreate("adodb.stream")   ;使用 adodb.stream 编码返回值。参考 http://bbs.howtoadmin.com/ThRead-814-1-1.html
			ADO.Type:=1 ;以二进制方式操作
			ADO.Mode:=3 ;可同时进行读写
			ADO.Open()  ;开启物件
			ADO.Write(WebRequest.ResponseBody())    ;写入物件。注意 WebRequest.ResponseBody() 获取到的是无符号的bytes，通过 adodb.stream 转换成字符串string
			ADO.Position:=0 ;从头开始
			ADO.Type:=2 ;以文字模式操作
			ADO.Charset:=Charset    ;设定编码方式
			return,RegExReplace(ADO.ReadText(),"^\s+|\s+$")   ;将物件内的文字读出
		}
	}

}

;获取文件属性中的文件说明  ;具体参数看右击exe文件--详细信息--属性
GetFileInfo(FilePath){
	SplitPath,FilePath , FileName, DirPath,
	objFolder := ComObjCreate("Shell.Application").NameSpace(DirPath)
	objFolderItem := objFolder.ParseName(FileName)
	Loop 283
		if propertyitem :=objFolder.GetDetailsOf(objFolderItem, A_Index)   ;AutoHotkey Unicode 64-bit
			if (objFolder.GetDetailsOf(objFolder.Items, A_Index)="文件说明"||propertyitem~="i)\d+\-bit$")
				Return propertyitem
}

GetFileBits(FilePath){
	If not FilePath~="\.exe$" {
		FilePath:=RegExReplace(FilePath,"\\$")
		Loop, Files,%FilePath%\*.exe
			FilePath:=A_LoopFileFullPath
	}
	SplitPath,FilePath , FileName, DirPath,
	objFolder := ComObjCreate("Shell.Application").NameSpace(DirPath)
	objFolderItem := objFolder.ParseName(FileName)
	Loop 283
		if propertyitem :=objFolder.GetDetailsOf(objFolderItem, A_Index)   ;AutoHotkey Unicode 64-bit
			if (objFolder.GetDetailsOf(objFolder.Items, A_Index)="文件说明"||propertyitem~="i)\d+\-bit$")
				Return propertyitem
}

;~ 从数组中寻找是否存在某个value，aArr为数组，aStr为要查重的字符
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
;~ 返回数组中存在某个value的个数
Array_isInValueCount(aArr, aStr)
{
	count:=0
	for k,v in aArr
	{
		if (IsObject(v) && (aArr[k].count()>0))
		{
			if (Array_isInValue(aArr[k],aStr) = 1)
				count++
		}
		else if (!IsObject(v) && (v=aStr))
			count++
	}
	return count
}

;~ 从数组中判断指定key对应的value是否为空，aArr为数组，aStr为要判断非空的key
Array_ValueNotEmpty(aArr, aKey)
{
	for k,v in aArr
	{
		if (IsObject(v) && (aArr[k].count()>0))
		{
			if (Array_ValueNotEmpty(aArr[k],aKey) = 1&&v<>"")
				return 1
		}
		else if (!IsObject(v) && v<>"" && k =aKey)
			return 1
	}
}
;~ 在obj对象中根据次级key名获取并返回上级的的key名
Array_GetParentKey(aArr, aKey)
{
	for k,v in aArr
	{
		rKey :=k
		if (IsObject(v) && (aArr[k].count()>0))
		{
			if (Array_ValueNotEmpty(aArr[k],aKey) = 1)
				return rKey
		}else If (!IsObject(v) && (v=aKey))
			return rKey
	}
}

;~ 从数组中寻找是否存在某个key，aArr为obj数组对象，aStr为要查重的字符
Array_isInKey(aArr, aKey)
{
	for k,v in aArr
	{
		if (IsObject(v) && (aArr[k].count()>0))
		{
			if (Array_isInKey(aArr[k],aKey) = 1)
				return 1
		}
		else if (!IsObject(v) && (k=aKey))
			return 1
	}
	Return 0
}

StatusBarGetText(Part = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
{
	_v := ""
	StatusBarGetText, _v, %Part%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	return _v
}
Random(Min = "", Max = "")
{
	_v := ""
	Random, _v, %Min%, %Max%
	return _v
}
GuiControlGet(Subcommand = "", ControlID = "", Param4 = "")
{
	_v := ""
	GuiControlGet, _v, %Subcommand%, %ControlID%, %Param4%
	return _v
}
FormatTime(YYYYMMDDHH24MISS = "A_Now", Format = "yyyy-MM-d dddd HH:mm:ss")
{
	_v := ""
	FormatTime, _v, %YYYYMMDDHH24MISS%, %Format%
	return _v
}
FileRead(Filename)
{
	_v := ""
	FileRead, _v, %Filename%
	return _v
}
ControlGet(Cmd, Value = "", Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
{
	_v := ""
	ControlGet, _v, %Cmd%, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	return _v
}
ControlGetText(Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "")
{
	_v := ""
	ControlGetText, _v, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	return _v
}
IfIn(ByRef var, MatchList)
{
	If var in %MatchList%
		return true
}

GetAllFileSize(File,FileType:="exe",Units:="K"){
	If File~="\\\w+\.\w+$"{
		FileGetSize, OutputVar , %File%, %Units%
		return OutputVar
	}else{
		sizeobj:=[]
		loop,files,%File%\*.%FileType%
		{
			FileGetSize, OutputVar , %A_LoopFileFullPath%, %Units%
			sizeobj.Push([A_LoopFileFullPath,OutputVar])
		}
		return sizeobj
	}

}

IfNotIn(ByRef var, MatchList)
{
	If var not in %MatchList%
		return true
}
IfContains(ByRef var, MatchList)
{
	If var contains %MatchList%
		return true
}
IfNotContains(ByRef var, MatchList)
{
	If var not contains %MatchList%
		return true
}
IfIs(ByRef var, type)
{
	If var is %type%
		return true
}
IfIsNot(ByRef var, type)
{
	If var is not %type%
		return true
}

SetTextAndResize(controlHwnd, newText) {
	dc := DllCall("GetDC", "Ptr", controlHwnd)
	; 0x31 = WM_GETFONT
	SendMessage 0x31,,,, ahk_id %controlHwnd%
	hFont := ErrorLevel
	oldFont := 0
	if (hFont != "FAIL")
		oldFont := DllCall("SelectObject", "Ptr", dc, "Ptr", hFont)
	VarSetCapacity(rect, 16, 0)
	; 0x440 = DT_CALCRECT | DT_EXPANDTABS
	h := DllCall("DrawText", "Ptr", dc, "Ptr", &newText, "Int", -1, "Ptr", &rect, "UInt", 0x440)
	; width = rect.right - rect.left
	w := NumGet(rect, 8, "Int") - NumGet(rect, 0, "Int")
	if oldFont
		DllCall("SelectObject", "Ptr", dc, "Ptr", oldFont)
	DllCall("ReleaseDC", "Ptr", controlHwnd, "Ptr", dc)
	GuiControl,, %controlHwnd%, %newText%
	GuiControl Move, %controlHwnd%, % "h" h " w" w
}

;Print Objects 对象
PrintObjects(Arr, Option := "AutoSize x50 y50",LineNum:=15, GuiName := "PrintObjects", font:="98wb-0") {
	Gui, %GuiName%: Destroy
	dim := DllCall("oleaut32\SafeArrayGetDim", "ptr", ComObjValue(arr))
	If !dim {
		If (Arr.Length()&&Arr[1].Length()) {
			for index, obj in Arr {
				if (A_Index = 1) {
					for k, v in obj {
						Columns .= "|" k 
						cnt++
					}
					Gui, %GuiName%: font,s10, %font%
					Gui, %GuiName%: Margin, 10, 10
					Gui, %GuiName%: Add, ListView, R%LineNum%, % Columns
				}
				RowNum := A_Index
				Gui, %GuiName%: default
				Gui, %GuiName%: +AlwaysOnTop
				LV_Add("","Row" A_Index), LV_ModifyCol()
				for k, v in obj {
					LV_GetText(Header, 0, A_Index)
					if (k <> Header) {
						FoundHeader := False
						loop % LV_GetCount("Column") {
							LV_GetText(Header, 0, A_Index)
							if (k <> Header)
								continue
							else {
								FoundHeader := A_Index
								break
							}
						}
						if !(FoundHeader) {
							LV_InsertCol( cnt + 1, "", k), LV_ModifyCol()
							cnt++
							ColNum := "Col" cnt
						} else
							ColNum := "Col" FoundHeader
					} else
						ColNum := "Col" A_Index
					LV_Modify(RowNum, ColNum, (IsObject(v) ? "Object()" : v))
				}
			}
			loop % LV_GetCount("Column")
				LV_ModifyCol(A_Index, "AutoHdr")
			Gui, %GuiName%: Show,%Option%, % "共" Arr.Count() "行"
		}else If (Arr.Count()>0&&!Arr[1].Length()){
			Gui, %GuiName%: default
			Gui, %GuiName%: +AlwaysOnTop
			Gui, %GuiName%: font,s12, %font%
			Gui, %GuiName%: Margin, 5, 5
			Gui, %GuiName%:Add, TreeView, R%LineNum%
			Count_=0
			for section, element in arr
			{
				Count_++
				TVP%Count_% := TV_Add(element.Length()||element.Count()? section:section "：" element)
				for key, value in element
				{
					TVP%Count_%C%A_Index% := TV_Add(key "： " value , TVP%Count_%), TV_Modify(TVP%Count_%, "Expand")
				}
			}
			TV_Modify(TVP1, "Select")
			Gui, %GuiName%: Show,%Option%, % "「 Object对象显示 」"
		}
	}else{
		Gui, %GuiName%: default
		Gui, %GuiName%: +AlwaysOnTop
		Gui, %GuiName%: font,s12, %font%
		Gui, %GuiName%: Margin, 5, 5
		Gui, %GuiName%:Add, TreeView, R%LineNum%
		while A_Index<=dim {
			Index:=A_index
			TVP%Index% := TV_Add("第" Index "列")
			loop,% Arr.MaxIndex(Index)
			{
				TVP%Index%C%A_index% := TV_Add(arr[A_index,index], TVP%Index%)   ;, TV_Modify(TVP%Index%, "Expand")
			}
		}
		TV_Modify(TVP1, "Select")
		Gui, %GuiName%: Show,%Option%, % "「 Object对象显示 」"
	}
	WinGetTitle, _WinTitle, A
	hWnd := WinExist(_WinTitle)
	DllCall("PrivateExtractIcons", "str", "Shell32.Dll", "int", 24, "int", IconSize, "int", 32, "ptr*"
		, hIcon, "uint*", 0, "uint", 1, "uint", 0, "ptr")
	SendMessage, WM_SETICON:=0x80, ICON_SMALL2:=0, hIcon,, ahk_id %hWnd%
	SendMessage, WM_SETICON:=0x80, ICON_BIG:=1   , hIcon,, ahk_id %hWnd%
}

DateAdd(time)
{
	if (time = 0)
		return 0
	datetime := 19700101
	datetime += time, s
	FormatTime, OutputVar, datetime, yyyy-MM-dd HH:mm:ss
	return OutputVar
}

SInputBox(TipText:="", Default:="",Width:=300, InputBoxTitle:="InputBox"){
	static
	ButtonOK:=ButtonCancel:= false
	if !SInputBoxGui{
		Gui, SInputBox: +Owner +AlwaysOnTop -DPIScale
		Gui, SInputBox: add, Text, r1 w%Width%  , % TipText
		Gui, SInputBox: add, Edit, r10 w%Width% vSInputBox, % Default
		Gui, SInputBox: add, Button, w60 gSInputBoxOK , &确定
		Gui, SInputBox: add, Button, w60 x+10 gSInputBoxCancel, &取消
		SInputBoxGui := true
	}
	GuiControl,SInputBox:, SInputBox, % Default
	Gui, SInputBox: Show,AutoSize, % InputBoxTitle
	SendMessage, 0xB1, 0, -1, Edit1, A
	while !(ButtonOK||ButtonCancel)
		continue
	if ButtonCancel
		return
	Gui, SInputBox: Submit, NoHide
	Gui, SInputBox: Cancel
	return SInputBox

	SInputBoxOK:
		ButtonOK:= true
	return

	SInputBoxGuiEscape:
		SInputBoxCancel:
		ButtonCancel:= true
		Gui, SInputBox: Cancel
	return
}

;-----------------------------------------配色----------------------------------------------------------
/*!
	函数: Dlg_Color(ByRef r_Color, hOwner:=0, Palette*)---->显示用于选择颜色的标准窗口对话框。

	参数:
		r_Color - 初始颜色-->默认设置为黑色.
		hOwner - 对话框对象的窗口ID, 如果有的话默认为0, i.e. 没有对象. 如果指定的DlgX和DlgY被忽略.
		Palette -最多16个RGB颜色值的数组。这些将成为对话框中的初始自定义颜色。
	Remarks:
		对话框中的自定义颜色在调用时被标记。如果用户选择OK，则将加载调色板阵列（如果存在）使用对话框中的自定义颜色。
	Returns:
		如果用户选择“确定”，返回True。否则返回False
*/
Dlg_Color(ByRef r_Color, hOwner:=0, Palette*){
	global
	Static CHOOSECOLOR, A_CustomColors
	if !VarSetCapacity(A_CustomColors){
		VarSetCapacity(A_CustomColors,64,0)
		for Index, Value in Palette
			NumPut(Value, A_CustomColors, 4*(Index - 1), "UInt")
	}
	l_Color:=r_Color, l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)
	;-- 创建并填充CHOOSECOLOR结构
	lStructSize:=VarSetCapacity(CHOOSECOLOR,(A_PtrSize=8) ? 72:36,0)
	NumPut(lStructSize,CHOOSECOLOR,0,"UInt")            ;-- lStructSize
	NumPut(hOwner,CHOOSECOLOR,(A_PtrSize=8) ? 8:4,"Ptr")
	;-- hwndOwner
	NumPut(l_Color,CHOOSECOLOR,(A_PtrSize=8) ? 24:12,"UInt")
	;-- RGB结果
	NumPut(&A_CustomColors,CHOOSECOLOR,(A_PtrSize=8) ? 32:16,"Ptr")
	;-- lpCustColors
	NumPut(0x00000103,CHOOSECOLOR,(A_PtrSize=8) ? 40:20,"UInt")
	;-- Flags
	RC:=DllCall("comdlg32\ChooseColor" . (A_IsUnicode ? "W":"A"),"Ptr",&CHOOSECOLOR)
	;-- 按下“取消”按钮或关闭对话框
	if (RC=0)
		Return False
	;-- 收集所选颜色
	l_Color:=NumGet(CHOOSECOLOR,(A_PtrSize=8) ? 24:12,"UInt")
	;-- 转换为RGB
	l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)
	;-- 用选定的颜色更新
	r_Color:=Format("0x{:06X}",l_Color)
	loop 8
	{
		Row1 .=Format("0x{:06X}",((NumGet(A_CustomColors, 4*(A_Index - 1), "UInt")&0xFF)<<16)+(NumGet(A_CustomColors, 4*(A_Index - 1), "UInt")&0xFF00)+((NumGet(A_CustomColors, 4*(A_Index - 1), "UInt")>>16)&0xFF)) ","
		Row2 .=Format("0x{:06X}",((NumGet(A_CustomColors, 4*(A_Index+8 - 1), "UInt")&0xFF)<<16)+(NumGet(A_CustomColors, 4*(A_Index+8 - 1), "UInt")&0xFF00)+((NumGet(A_CustomColors, 4*(A_Index+8 - 1), "UInt")>>16)&0xFF)) ","
	}
	Color_Row2 :=WubiIni.CustomColors["Color_Row2"]:= RegExReplace(Row2,"\,$","")
	Color_Row1 :=WubiIni.CustomColors["Color_Row1"]:= RegExReplace(Row1,"\,$","")
	Row1:=Row2:=""
	Return True
}

;---------------------------------------------------------------------------------------------------
SetButtonColor(hwnd, Color, Margins:=5){
	VarSetCapacity(RECT, 16, 0), DllCall("User32.dll\GetClientRect", "Ptr", hwnd, "Ptr", &RECT)
	W := NumGet(RECT, 8, "Int") - (Margins * 2), H := NumGet(RECT, 12, "Int") - (Margins * 2)

	Color:=((Color&0xFF)<<16)+(((Color>>8)&0xFF)<<8)+((Color>>16)&0xFF)
	hbm:=CreateDIBSection(W, H), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	hBrush:=DllCall("CreateSolidBrush", "UInt", Color, "UPtr"), obh:=SelectObject(hdc, hBrush)
	DllCall("Rectangle", "UPtr", hdc, "Int", 0, "Int", 0, "Int", W, "Int", H), SelectObject(hdc, obm)
	BUTTON_IMAGELIST_ALIGN_CENTER := 4, BS_BITMAP := 0x0080, BCM_SETIMAGELIST := 0x1602, BITSPIXEL := 0xC
	BPP := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hdc, "Int", BITSPIXEL)
	HIL := DllCall("Comctl32.dll\ImageList_Create", "UInt", W, "UInt", H, "UInt", BPP, "Int", 6, "Int", 0, "Ptr")
	DllCall("Comctl32.dll\ImageList_Add", "Ptr", HIL, "Ptr", hbm, "Ptr", 0)
	; ; Create a BUTTON_IMAGELIST structure
	VarSetCapacity(BIL, 20 + A_PtrSize, 0), NumPut(HIL, BIL, 0, "Ptr")
	Numput(BUTTON_IMAGELIST_ALIGN_CENTER, BIL, A_PtrSize + 16, "UInt")
	; Hide buttons's caption
	; GuiControl, , %HWND% ; WinXP
	; GuiControl, +%BS_BITMAP%, %HWND%
	; Assign the ImageList to the button
	SendMessage, BCM_SETIMAGELIST, 0, 0, , ahk_id %HWND%
	SendMessage, BCM_SETIMAGELIST, 0, &BIL, , ahk_id %HWND%
	SelectObject(hdc, obh), DeleteObject(hbm), DeleteObject(hBrush), DeleteDC(hdc)
}


; ================================================================================?======================================
; Create images and assign them to be shown within pushbuttons
; ================================================================================?======================================
; Function: Create images and assign them to be shown within pushbuttons.
; AHK version: 1.1.05.05 (U32 / U64)
; Language: English
; Tested on: Win XPSP3, Win VistaSP2 (32 bit), Win 7 (64 bit)
; Version: 0.9.00.01/2011-04-02/just me
;
; How to use: 1. Create a push button with e.g. "Gui, Add, Button, vMyButton hwndHwndButton, Caption" using the
; hwnd option to get its HWND.
;
; 2. Call CreateImageButton passing up to three parameters:
; Mandatory:
; HWND - Button's HWND (Pointer)
; Options - 1-based array containing up to 6 option objects (Object)
; see below
; Optional:
; Margins - Distance between the bitmaps and the border in pixel (Integer)
; to keep parts of Windows' button animation visible
; Valid values: 0, 1, 2, 3, 4
; Default: 0
;
; The index of each option object determines the corresponding button state on which the bitmap
; will be shown. MSDN defines 6 states (http://msdn.microsoft.com/en-us/windows/bb775975):
; enum PUSHBUTTONSTATES {
; PBS_NORMAL = 1,
; PBS_HOT = 2,
; PBS_PRESSED = 3,
; PBS_DISABLED = 4,
; PBS_DEFAULTED = 5,
; PBS_STYLUSHOT = 6, <- used only on tablet computers
; };
; If you don't want the button to be "animated", just pass one option object with index 1.
;
; Each option object may contain the following key/value pairs:
; Mandatory:
; BC - Background Color(s):
; 6-digit RGB hex value ("RRGGBB") or HTML color name ("Red").
; Pass 2 pipe (|) separeted values for start and target colors of a gradient.
; If only one color is passed for 3D = 1 thru 3, black ("000000") will be used
; as default start color and the color value will be used as target color.
; In case of 3D = 9 BC must contain a picture's path or HBITMAP handle
; Optional:
; TC - Text Color:
; 6-digit RGB hex value ("RRGGBB") or HTML color name ("Red").
; Default: "000000" (black)
; 3D - 3D Effects:
; 0 = none (just colored)
; 1 = raised
; 2 = vertical "3D" gradient
; 3 = horizontal "3D" gradient
; 9 = background picture (BC contains the picture's path or HBITMAP handle)
; Default: 0
; G - Gamma Correction:
; 0 = no
; 1 = yes
; Default: 0
;
; Whenever the The button has a caption it is drawn above the bitmap or picture.
;
; Credits: THX tic for GDIP.AHK : http://www.autohotkey.com/forum/post-198949.html
; THX tkoi for ILBUTTON.AHK : http://www.autohotkey.com/forum/topic40468.html
; THX Lexikos for AHK_L
; ================================================================================?======================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ================================================================================?======================================
; ================================================================================?======================================
; FUNCTION CreateImageButton()
; ================================================================================?======================================
;~ 完整的函数:
;~ CreateImageButton(HWND, Options,Margins=0)

;~ 有三个需要输入的参数 :
;~ [必填]第一个是按钮的句柄值
;~ [必填]参数数组
;~ [可填]按钮的边界宽度 0 1 2 3 4 值越高边框越宽 不填的话默认为0

;~ 参数数组:

;~ 1 数组序号 如BT1Options[3]代表鼠标按住按钮时按钮的参数
;~ 1 普通状态下
;~ 2 鼠标悬停在按钮上 不按下
;~ 3 鼠标按住按钮
;~ 4 按钮在 Disable 状态下 按钮无效化
;~ 5 按钮在 Default 状态下 按钮默认
;~ 6 used only on tablet computers
;~ 其中数组的第一个必须有 也就是上边的BT1Options 后边的根据需要添加

;~ 2 BC是BackgroundColor的缩写 按钮颜色
;~ 可用： RBG色 如00FF00 或 HTML色 如"Red"
;~ "外围颜色|中心颜色"
;~ 也可以里外用一种颜色 如BC: "600000"

;~ 3 TC是Text Color的缩写 文字颜色
;~ 参照背景颜色BC

;~ 4 3D表示的是按钮的样式
;~ 0 普通
;~ 1 中间鼓起 如果BC只有一个参数，颜色向中心会过渡到黑色
;~ 2 垂直纹理
;~ 3 水平纹理
;~ 9 背景图片 要求BC必须包含位图句柄或图片路径
;~ 默认为 0

;~ 5 G代表Gamma Correction 图像灰度矫正
;~ 0 表示否
;~ 1 代表是
;~ 默认为 0
;~ 示例
;~ #include -填入路径-\CreateImageButton.ahk
;~ Gui, New
;~ Gui, font, s20, 方正兰亭黑_GBK
;~ Gui, Add, Button, w200 ,默认样式
;~ Gui, Add, Button, w200 hwndHBT1 ,新样式
;~ BT1Options:= [{BC: "99D1D3|00A6AD", TC: "Black", 3D: 1, G: 0}]
;~ BT1Options[2] := {BC: "008C5E|00AE72", TC: "000000", 3D: 0, G: 1}
;~ CreateImageButton(HBT1,BT1Options)
;~ Gui, Show
CreateImageButton(HWND, Options, Margins = 0) {
    ; HTML colors
    Static HTML := {BLACK: "000000", GRAY: "808080", SILVER: "C0C0C0", WHITE: "FFFFFF"
    , MAROON: "800000", PURPLE: "800080", FUCHSIA: "FF00FF", RED: "FF0000"
    , GREEN: "008000", OLIVE: "808000", YELLOW: "FFFF00", LIME: "00FF00"
	, NAVY: "000080", TEAL: "008080", AQUA: "00FFFF", BLUE: "0000FF"}

	; Windows constants
	Static BS_CHECKBOX := 0x2 , BS_RADIOBUTTON := 0x4
	, BS_GROUPBOX := 0x7 , BS_AUTORADIOBUTTON := 0x9
	, BS_LEFT := 0x100 , BS_RIGHT := 0x200
	, BS_CENTER := 0x300 , BS_TOP := 0x400
	, BS_BOTTOM := 0x800 , BS_VCENTER := 0xC00
	, BS_BITMAP := 0x0080
	, SA_LEFT := 0x0 , SA_CENTER := 0x1
	, SA_RIGHT := 0x2 , WM_GETFONT := 0x31
	, IMAGE_BITMAP := 0x0 , BITSPIXEL := 0xC
	, RCBUTTONS := BS_CHECKBOX | BS_RADIOBUTTON | BS_AUTORADIOBUTTON
	, BCM_SETIMAGELIST := 0x1602
	, BUTTON_IMAGELIST_ALIGN_LEFT := 0
	, BUTTON_IMAGELIST_ALIGN_RIGHT := 1
	, BUTTON_IMAGELIST_ALIGN_CENTER := 4
	; Options
	Static OptionKeys := ["TC", "BC", "3D", "G"]
	; Defaults
	Static Defaults := {TC: "000000", BC: "000000", 3D: 0, G: 0}
	; -------------------------------------------------------------------------------------------------------------------
	ErrorLevel := ""
	; -------------------------------------------------------------------------------------------------------------------
	; Check the availability of Gdiplus.dll
	GDIPDll := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "Ptr")
	VarSetCapacity(SI, 24, 0)
	NumPut(1, SI)
	DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", GDIPToken, "Ptr", &SI, "Ptr", 0)
	if (!GDIPToken) {
		ErrorLevel := "GDIPlus could not be started!`n`nImageButton won't work!"
		Return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Check HWND
	if !(DllCall("User32.dll\IsWindow", "Ptr", HWND)) {
		gosub, CreateImageButton_GDIPShutdown
		ErrorLevel := "Invalid parameter HWND!"
		Return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Check Options
	if !(IsObject(Options)) || (Options.MinIndex() = "") || (Options.MinIndex() > 1) || (Options.MaxIndex() > 6) {
		gosub, CreateImageButton_GDIPShutdown
		ErrorLevel := "Invalid parameter Options!"
		Return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Check Margins
	Margins := SubStr(Margins, 1, 1)
	if (Margins = "") || !(InStr("0123456789", Margins))
		Margins := 0
	; -------------------------------------------------------------------------------------------------------------------
	; Get and check control's class and styles
	WinGetClass, BtnClass, ahk_id %HWND%
	ControlGet, BtnStyle, Style, , , ahk_id %HWND%
	if (BtnClass != "Button") || ((BtnStyle & 0xF ^ BS_GROUPBOX) = 0) || ((BtnStyle & RCBUTTONS) > 1) {
		gosub, CreateImageButton_GDIPShutdown
		ErrorLevel := "You can use ImageButton only for PushButtons!"
		Return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Get the button's font
	GDIPFont := 0
	DC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")
	BPP := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", BITSPixel)
	HFONT := DllCall("User32.dll\SendMessage", "Ptr", HWND, "UInt", WM_GETFONT, "Ptr", 0, "Ptr", 0, "Ptr")
	DllCall("Gdi32.dll\SelectObject", "Ptr", DC, "Ptr", HFONT)
	DllCall("Gdiplus.dll\GdipCreateFontFromDC", "Ptr", DC, "PtrP", GDIPFont)
	DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", DC)
	if !(GDIPFont) {
		gosub, CreateImageButton_GDIPShutdown
		ErrorLevel := "Couldn't get button's font!"
		Return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Get the button's RECT
	VarSetCapacity(RECT, 16, 0)
	if !(DllCall("User32.dll\GetClientRect", "Ptr", HWND, "Ptr", &RECT)) {
		gosub, CreateImageButton_GDIPShutdown
		ErrorLevel := "Couldn't get button's rectangle!"
		Return False
	}
	W := NumGet(RECT, 8, "Int") - (Margins * 2)
	H := NumGet(RECT, 12, "Int") - (Margins * 2)
	; -------------------------------------------------------------------------------------------------------------------
	; Get the button's caption
	BtnCaption := ""
	Len := DllCall("User32.dll\GetWindowTextLength", "Ptr", HWND) + 1
	if (Len > 1) { ; Button has a caption
		VarSetCapacity(BtnCaption, Len * (A_IsUnicode ? 2 : 1), 0)
		if !(DllCall("User32.dll\GetWindowText", "Ptr", HWND, "Str", BtnCaption, "Int", Len)) {
			gosub, CreateImageButton_GDIPShutdown
			ErrorLevel := "Couldn't get button's caption!"
			Return False
		}
		VarSetCapacity(BtnCaption, -1)
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Create the BitMap(s)
	BitMaps := []
	while (A_Index <= Options.MaxIndex()) {
		if !(Options.HasKey(A_Index))
			continue
		Option := Options[A_Index]
		; Check mandatory keys
		if !(Option.HasKey("BC")) {
			gosub, CreateImageButton_FreeBitmaps
			gosub, CreateImageButton_GDIPShutdown
			ErrorLevel := "Missing option BC in Options[" . A_Index . "]!"
			Return False
		}
		; Check for defaults
		For Each, K In Defaults {
			if !(Option.HasKey(K)) || (Option[K] = "")
				Option[K] := Defaults[K]
		}
		; Check options
		BitMap := ""
		GC := SubStr(Option.G, 1, 1)
		if !InStr("01", GC)
			GC := Defaults.G
		3D := SubStr(Option.3D, 1, 1)
		if !InStr("01239", 3D)
			3D := Defaults.3D
		if (3D < 4) {
			BkgColor := Option.BC
			if InStr(BkgColor, "|") {
				StringSplit, BkgColor, BkgColor, |
			} else {
				BkgColor1 := Option.3D = 0 ? BkgColor : Defaults.BC
				BkgColor2 := BkgColor
			}
			if HTML.HasKey(BkgColor1)
				BkgColor1 := HTML[BkgColor1]
			if HTML.HasKey(BkgColor2)
				BkgColor2 := HTML[BkgColor2]
		} else {
			Image := Option.BC
		}
		TxtColor := Option.TC
		if HTML.HasKey(TxtColor)
			TxtColor := HTML[TxtColor]
		; ----------------------------------------------------------------------------------------------------------------
		; Create a GDI+ bitmap
		DllCall("Gdiplus.dll\GdipCreateBitmapFromScan0", "Int", W, "Int", H, "Int", 0
		, "UInt", 0x26200A, "Ptr", 0, "PtrP", PBITMAP)
		; Get the pointer to it's graphics
		DllCall("Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", PBITMAP, "PtrP", PGRAPHICS)
		; Set SmoothingMode to system default
		DllCall("Gdiplus.dll\GdipSetSmoothingMode", "Ptr", PGRAPHICS, "UInt", 0)
		if (3D < 4) { ; Create a BitMap
			; Create a PathGradientBrush
			VarSetCapacity(POINTS, 4 * 8, 0)
			NumPut(W - 1, POINTS, 8, "UInt"), NumPut(W - 1, POINTS, 16, "UInt")
			NumPut(H - 1, POINTS, 20, "UInt"), NumPut(H - 1, POINTS, 28, "UInt")
			DllCall("Gdiplus.dll\GdipCreatePathGradientI", "Ptr", &POINTS, "Int", 4, "Int", 0, "PtrP", PBRUSH)
			; Start and target colors
			Color1 := "0xFF" . BkgColor1
			Color2 := "0xFF" . BkgColor2
			; Set the PresetBlend
			VarSetCapacity(COLORS, 12, 0)
			NumPut(Color1, COLORS, 0, "UInt"), NumPut(Color2, COLORS, 4, "UInt")
			VarSetCapacity(RELINT, 12, 0)
			NumPut(0.00, RELINT, 0, "Float"), NumPut(1.00, RELINT, 4, "Float")
			DllCall("Gdiplus.dll\GdipSetPathGradientPresetBlend", "Ptr", PBRUSH, "Ptr", &COLORS, "Ptr", &RELINT, "Int", 2)
			; Set the FocusScales
			DH := H / 2
			XScale := (3D = 1 ? (W - DH) / W : 3D = 2 ? 1 : 0)
			YScale := (3D = 1 ? (H - DH) / H : 3D = 3 ? 1 : 0)
			DllCall("Gdiplus.dll\GdipSetPathGradientFocusScales", "Ptr", PBRUSH, "Float", XScale, "Float", YScale)
			; Set the GammaCorrection
			DllCall("Gdiplus.dll\GdipSetPathGradientGammaCorrection", "Ptr", PBRUSH, "Int", GC)
			; Fill button's rectangle
			DllCall("Gdiplus.dll\GdipFillRectangleI", "Ptr", PGRAPHICS, "Ptr", PBRUSH, "Int", 0, "Int", 0
			, "Int", W, "Int", H)
			; Free the brush
			DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
		} else { ; Create a bitmap from HBITMAP or file
			if (Image + 0)
				DllCall("Gdiplus.dll\GdipCreateBitmapFromHBITMAP", "Ptr", Image, "Ptr", 0, "PtrP", PBM)
			else
				DllCall("Gdiplus.dll\GdipCreateBitmapFromFile", "WStr", Image, "PtrP", PBM)
			; Draw the bitmap
			DllCall("Gdiplus.dll\GdipDrawImageRectI", "Ptr", PGRAPHICS, "Ptr", PBM, "Int", 0, "Int", 0
			, "Int", W, "Int", H)
			; Free the bitmap
			DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", PBM)
		}
		; ----------------------------------------------------------------------------------------------------------------
		; Draw the caption
		if (BtnCaption) {
			; Create a StringFormat object
			DllCall("Gdiplus.dll\GdipCreateStringFormat", "Int", 0x5404, "UInt", 0, "PtrP", HFORMAT)
				; Text color
			DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", "0xFF" . TxtColor, "PtrP", PBRUSH)
			; Horizontal alignment
			HALIGN := (BtnStyle & BS_CEnter) = BS_CEnter ? SA_CEnter
			: (BtnStyle & BS_CENTER) = BS_RIGHT ? SA_RIGHT
			: (BtnStyle & BS_CENTER) = BS_Left ? SA_LEFT
			: SA_CENTER
			DllCall("Gdiplus.dll\GdipSetStringFormatAlign", "Ptr", HFORMAT, "Int", HALIGN)
				; Vertical alignment
			VALIGN := (BtnStyle & BS_VCEnter) = BS_TOP ? 0
			: (BtnStyle & BS_VCENTER) = BS_BOTTOM ? 2
			: 1
			DllCall("Gdiplus.dll\GdipSetStringFormatLineAlign", "Ptr", HFORMAT, "Int", VALIGN)
				; Set render quality to system default
			DllCall("Gdiplus.dll\GdipSetTextRenderingHint", "Ptr", PGRAPHICS, "Int", 0)
			; Set the text's rectangle
			NumPut(0.0, RECT, 0, "Float")
			NumPut(0.0, RECT, 4, "Float")
			NumPut(W, RECT, 8, "Float")
			NumPut(H, RECT, 12, "Float")
			; Draw the text
			DllCall("Gdiplus.dll\GdipDrawString", "Ptr", PGRAPHICS, "WStr", BtnCaption, "Int", -1
			, "Ptr", GDIPFont, "Ptr", &RECT, "Ptr", HFORMAT, "Ptr", PBRUSH)
			}
		; Create a HBITMAP handle from the bitmap
		DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", PBITMAP, "PtrP", HBITMAP, "UInt", 0X00FFFFFF)
		; Free resources
		DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", PBITMAP)
		DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
		DllCall("Gdiplus.dll\GdipDeleteStringFormat", "Ptr", HFORMAT)
			DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", PGRAPHICS)
		BitMaps[A_Index] := HBITMAP
	}
	; Now free the font object
	DllCall("Gdiplus.dll\GdipDeleteFont", "Ptr", GDIPFont)
	; -------------------------------------------------------------------------------------------------------------------
	; Create the ImageList
	HIL := DllCall("Comctl32.dll\ImageList_Create", "UInt", W, "UInt", H, "UInt", BPP, "Int", 6, "Int", 0, "Ptr")
	loop, % (BitMaps.MaxIndex() > 1 ? 6 : 1) {
		HBITMAP := BitMaps.HasKey(A_Index) ? BitMaps[A_Index] : BitMaps[1]
		DllCall("Comctl32.dll\ImageList_Add", "Ptr", HIL, "Ptr", HBITMAP, "Ptr", 0)
	}
	; Create a BUTTON_IMAGELIST structure
	VarSetCapacity(BIL, 20 + A_PtrSize, 0)
	NumPut(HIL, BIL, 0, "Ptr")
	NumPut(BUTTON_IMAGELIST_ALIGN_CENTER, BIL, A_PtrSize + 16, "UInt")
	; Hide buttons's caption
	GuiControl, , %HWND% ; WinXP
	GuiControl, +%BS_BITMAP%, %HWND%
	; Assign the ImageList to the button
	SendMessage, BCM_SETIMAGELIST, 0, 0, , ahk_id %HWND%
	SendMessage, BCM_SETIMAGELIST, 0, &BIL, , ahk_id %HWND%
	; Free the bitmaps
	gosub, CreateImageButton_FreeBitmaps
	; -------------------------------------------------------------------------------------------------------------------
	; All done successfully
	gosub, CreateImageButton_GDIPShutdown
	Return True
	; -------------------------------------------------------------------------------------------------------------------
	; Free BitMaps
	CreateImageButton_FreeBitmaps:
		For I, HBITMAP In BitMaps {
			DllCall("Gdi32.dll\DeleteObject", "Ptr", HBITMAP)
		}
	Return
	; -------------------------------------------------------------------------------------------------------------------
	; Shutdown GDIPlus
	CreateImageButton_GDIPShutdown:
		DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", GDIPToken)
		DllCall("Kernel32.dll\FreeLibrary", "Ptr", GDIPDll)
	Return
}

;-------------------------公历转农历-公历日期「大写」-------------------------
/*
	<参数>
		Gregorian: 公历日期 格式 YYYYMMDD
	;;T=1时以立春计生肖年，否则以春节为准,适用范围：1900年~2100年农历数据
	<返回结果集>：
		农历中文日期+农历干支+农历标准数字格式+农历生肖的新旧标准标识+节气+闰月月份
		说明：闰月月份不存在则返回空，
		          农历生肖的新旧标准标识：
			Old--以立春为界
			New--以春节为界
*/
Date2LunarDate(Gregorian,T:=0) {
	If strlen(Gregorian)>4&&Mod(strlen(Gregorian),2) {
		If Gregorian~="0$"
			Gregorian:=strlen(Gregorian)=5?Gregorian 101:Gregorian 1
		else If Gregorian~="1$"
			Gregorian:=strlen(Gregorian)=5?Gregorian 001:Gregorian 0
	}
	;1899年~2100年农历数据
	;前三位，Hex，转Bin，表示当年月份，1为大月，0为小月	;第四位，Dec，表示闰月天数，1为大月30天，0为小月29天
	;第五位，Hex，转Dec，表示是否闰月，0为不闰，否则为闰月月份	;后两位，Hex，转Dec，表示当年新年公历日期，格式MMDD
	Isleap:=0, LunarData:=["AB500D2","4BD0883","4AE00DB","A5700D0","54D0581","D2600D8","D9500CC","655147D","56A00D5","9AD00CA","55D027A","4AE00D2"
		,"A5B0682","A4D00DA","D2500CE","D25157E","B5500D6","56A00CC","ADA027B","95B00D3","49717C9","49B00DC","A4B00D0","B4B0580"
		,"6A500D8","6D400CD","AB5147C","2B600D5","95700CA","52F027B","49700D2","6560682","D4A00D9","EA500CE","6A9157E","5AD00D6"
		,"2B600CC","86E137C","92E00D3","C8D1783","C9500DB","D4A00D0","D8A167F","B5500D7","56A00CD","A5B147D","25D00D5","92D00CA"
		,"D2B027A","A9500D2","B550781","6CA00D9","B5500CE","535157F","4DA00D6","A5B00CB","457037C","52B00D4","A9A0883","E9500DA"
		,"6AA00D0","AEA0680","AB500D7","4B600CD","AAE047D","A5700D5","52600CA","F260379","D9500D1","5B50782","56A00D9","96D00CE"
		,"4DD057F","4AD00D7","A4D00CB","D4D047B","D2500D3","D550883","B5400DA","B6A00CF","95A1680","95B00D8","49B00CD","A97047D"
		,"A4B00D5","B270ACA","6A500DC","6D400D1","AF40681","AB600D9","93700CE","4AF057F","49700D7","64B00CC","74A037B","EA500D2"
		,"6B50883","5AC00DB","AB600CF","96D0580","92E00D8","C9600CD","D95047C","D4A00D4","DA500C9","755027A","56A00D1","ABB0781"
		,"25D00DA","92D00CF","CAB057E","A9500D6","B4A00CB","BAA047B","AD500D2","55D0983","4BA00DB","A5B00D0","5171680","52B00D8"
		,"A9300CD","795047D","6AA00D4","AD500C9","5B5027A","4B600D2","96E0681","A4E00D9","D2600CE","EA6057E","D5300D5","5AA00CB"
		,"76A037B","96D00D3","4AB0B83","4AD00DB","A4D00D0","D0B1680","D2500D7","D5200CC","DD4057C","B5A00D4","56D00C9","55B027A"
		,"49B00D2","A570782","A4B00D9","AA500CE","B25157E","6D200D6","ADA00CA","4B6137B","93700D3","49F08C9","49700DB","64B00D0"
		,"68A1680","EA500D7","6AA00CC","A6C147C","AAE00D4","92E00CA","D2E0379","C9600D1","D550781","D4A00D9","DA400CD","5D5057E"
		,"56A00D6","A6C00CB","55D047B","52D00D3","A9B0883","A9500DB","B4A00CF","B6A067F","AD500D7","55A00CD","ABA047C","A5A00D4"
		,"52B00CA","B27037A","69300D1","7330781","6AA00D9","AD500CE","4B5157E","4B600D6","A5700CB","54E047C","D1600D2","E960882"
		,"D5200DA","DAA00CF","6AA167F","56D00D7","4AE00CD","A9D047D","A2D00D4","D1500C9","F250279","D5200D1"]

	;分解公历年月日
	Year:=SubStr(Gregorian,1,4), Month:=SubStr(Gregorian,5,2), Day:=SubStr(Gregorian,7,2)
	if (Year>2100 Or Year<1899)
		return,"无效日期"
	;获取两百年内的农历数据
	Pos:=Year-1900+2 
	Data0:=LunarData[Pos-1],Data1:=LunarData[Pos]
	;判断农历年份
	Analyze(Data1,MonthInfo,LeapInfo,Leap,Newyear)
	Date1:=Year Newyear, Date2:=Gregorian
	EnvSub,Date2,Date1,Days
	;msgbox % Date2 "-" Date1 "-" Days
	If Date2<0	;和当年农历新年相差的天数
	{
		Analyze(Data0,MonthInfo,LeapInfo,Leap,Newyear)
		Year-=1
		Date1:= Year Newyear, Date2:=Gregorian
		;;msgbox % Date1 "-" Date2 "-" Newyear
		EnvSub,Date2,%Date1%,Days
	}
	;计算农历日期
	Date2+=1
	LYear:=Year	;农历年份，就是上面计算后的值
	if Leap	;有闰月
		p1:=SubStr(MonthInfo,1,Leap) ,p2:=SubStr(MonthInfo,Leap+1), thisMonthInfo:=p1 . LeapInfo . p2
	Else
		thisMonthInfo:=MonthInfo
	;msgbox % MonthInfo "-" Date2 "-" p2
	loop,13
	{
		thisMonth:=SubStr(thisMonthInfo,A_index,1), thisDays:=29+thisMonth
		if (Date2>thisDays)
			Date2:=Date2-thisDays
		Else
		{
			if leap
			{
				If (leap>=A_index)
					LMonth:=A_index, Isleap:=0
				Else
					LMonth:=A_index-1, Isleap:=a_index-leap=1?1:0
			}Else
				LMonth:=A_index, Isleap:=0
			LDay:=Date2
			Break
		}
	}
	LDate:=LYear (strlen(LMonth)=1?0 LMonth:LMonth) (strlen(LDay)=1?0 LDay:LDay) 
	;;msgbox % LDate "-" thisMonth
	;转换成习惯性叫法
	Tiangan:=["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"], Dizhi=["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]
	Shengxiao:=["鼠","牛","虎","兔","龙","蛇","马","羊","猴","鸡","狗","猪"], yuefen:=["正月","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"]
	rizi:=["初一","初二","初三","初四","初五","初六","初七","初八","初九","初十","十一","十二","十三","十四","十五","十六","十七","十八","十九","二十","廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十"]
	;;纳音表
	nyb:=["甲子","乙丑","丙寅","丁卯","戊辰","己巳","庚午","辛未","壬申","癸酉","甲戌","乙亥"
		,"丙子","丁丑","戊寅","己卯","庚辰","辛巳","壬午","癸未","甲申","乙酉","丙戌","丁亥"
		,"戊子","己丑","庚寅","辛卯","壬辰","癸巳","甲午","乙未","丙申","丁酉","戊戌","己亥"
		,"庚子","辛丑","壬寅","癸卯","甲辰","乙巳","丙午","丁未","戊申","己酉","庚戌","辛亥"
		,"壬子","癸丑","甲寅","乙卯","丙辰","丁巳","戊午","己未","庚申","辛酉","壬戌","癸亥"]
	StratSj:=[1900,11]  ;以1900年1月1日的干支位置为基准
	If T
	{
		If (Month=2&&Day<GetLunarJq(Gregorian)[1]&&LMonth=1||Month=1&&LMonth=1)
			LYear:=LYear-1
		else If (Month=2&&Day>=GetLunarJq(Gregorian)[1]&&LMonth=12)
			LYear:=LYear+1
	}
	Order1:=Mod((LYear-4),10)+1, Order2:=Mod((LYear-4),12)+1
	LunarYear:=Tiangan[Order1] . Dizhi[Order2] . "(" . Shengxiao[Order2] . ")年", LunarMonth:=yuefen[LMonth], LDay:=rizi[LDay]
	LunarDate:=LunarYear (Isleap?"(闰)" LunarMonth:LunarMonth) LDay, JqDate:=GetLunarJq(Gregorian,1), JqDate_:=JqDate[1]=SubStr(Gregorian,7,2)?JqDate[2]:""
	;;msgbox % LunarDate JqDate[2] JqDate_
	DateVar:=Gregorian
	EnvSub, DateVar, 19000101, days
	DayPos:= Mod(DateVar+StratSj[2],60), MonthPos:=GetLunarJq(Gregorian,1)[3]
	flag:=GetLunarJq(SubStr(Gregorian,1,4) 02 SubStr(Gregorian,7,2)), last:=02 (strlen(flag[1])<2?0 flag[1]:flag[1])
	If T {
		If (SubStr(Gregorian,5,4)>=last)
			GzYear:=Tiangan[Order1] . Dizhi[Order2] "年"
		else
			Order1:=Mod(((SubStr(Gregorian,1,4)-1)-4),10)+1, Order2:=Mod(((SubStr(Gregorian,1,4)-1)-4),12)+1, GzYear:=Tiangan[Order1] . Dizhi[Order2] "年"
		If (Order1=1||Order1=6)
			monthArr:=[nyb[3],nyb[4],nyb[5],nyb[6],nyb[7],nyb[8],nyb[9],nyb[10],nyb[11],nyb[12],nyb[13],nyb[14]]
		else If (Order1=2||Order1=7)
			monthArr:=[nyb[15],nyb[16],nyb[17],nyb[18],nyb[19],nyb[20],nyb[21],nyb[22],nyb[23],nyb[24],nyb[25],nyb[26]]
		else If (Order1=3||Order1=8)
			monthArr:=[nyb[27],nyb[28],nyb[29],nyb[30],nyb[31],nyb[32],nyb[33],nyb[34],nyb[35],nyb[36],nyb[37],nyb[38]]
		else If (Order1=4||Order1=9)
			monthArr:=[nyb[39],nyb[40],nyb[41],nyb[42],nyb[43],nyb[44],nyb[45],nyb[46],nyb[47],nyb[48],nyb[49],nyb[50]]
		else If (Order1=5||Order1=10)
			monthArr:=[nyb[51],nyb[52],nyb[53],nyb[54],nyb[55],nyb[56],nyb[57],nyb[58],nyb[59],nyb[60],nyb[1],nyb[2]]
		GzMonth:=monthArr[MonthPos] "月", GzDays:=nyb[DayPos] "日"
	}else{
		GzYear:=SubStr(LunarDate,1,2) "年"
		If (SubStr(Gregorian,5,4)>=last) {
			If ((SubStr(Gregorian,1,4) 0101)>SubStr(LDate,1,8)) {
				Order1+=1
			}
		}else{
			;msgbox % Order1 "-" (SubStr(Gregorian,1,4) 0101) "-" SubStr(LDate,1,8)
			If ((SubStr(Gregorian,1,4) 0101)<=SubStr(LDate,1,8)) {
				Order1-=1
			}
		}
		If (Order1=1||Order1=6)
			monthArr:=[nyb[3],nyb[4],nyb[5],nyb[6],nyb[7],nyb[8],nyb[9],nyb[10],nyb[11],nyb[12],nyb[13],nyb[14]]
		else If (Order1=2||Order1=7)
			monthArr:=[nyb[15],nyb[16],nyb[17],nyb[18],nyb[19],nyb[20],nyb[21],nyb[22],nyb[23],nyb[24],nyb[25],nyb[26]]
		else If (Order1=3||Order1=8)
			monthArr:=[nyb[27],nyb[28],nyb[29],nyb[30],nyb[31],nyb[32],nyb[33],nyb[34],nyb[35],nyb[36],nyb[37],nyb[38]]
		else If (Order1=4||Order1=9)
			monthArr:=[nyb[39],nyb[40],nyb[41],nyb[42],nyb[43],nyb[44],nyb[45],nyb[46],nyb[47],nyb[48],nyb[49],nyb[50]]
		else If (Order1=5||Order1=10)
			monthArr:=[nyb[51],nyb[52],nyb[53],nyb[54],nyb[55],nyb[56],nyb[57],nyb[58],nyb[59],nyb[60],nyb[1],nyb[2]]

		GzMonth:=monthArr[MonthPos] "月", GzDays:=nyb[DayPos] "日"
	}
	If strlen(Gregorian)>9
	{
		If (SubStr(Gregorian,9,2)=24)
			return Date2LunarDate(SubStr(Gregorian,1,8) 00,T)
		sijian:=SubStr(Gregorian,9,2), sj:=Mod(sijian,2)?Floor((sijian+3)/2):Floor((sijian+2)/2)
		loop,10
			If (Tiangan[a_index]=SubStr(GzDays,1,1))
				sj_:=a_index>5?a_index-5:a_index
		GzSichen:=nyb[(sj_-1)*12+sj]
	}
	GzDate:=GzYear GzMonth GzDays (strlen(Gregorian)>9?GzSichen "时":"")
	;;msgbox % LunarDate "`n" GzDate Isleap
	return [LunarDate,strlen(GzDate)>8?GzDate:"",LDate,T?"Old":"New",JqDate_,leap]

}

GetLunarJq(date,s:=0){   ;s=1获取当前日期真实节气数据，s为空获取该月份第一个节气公历时间
	If (strlen(date)<8||date~="\.")
		return []
	year:=SubStr(date,1,4), month:=SubStr(date,5,2), D:=0.2422, Y:=SubStr(year,3,2), L:=month>2?Floor(SubStr(year,3,2)/4):Floor((SubStr(year,3,2)-1)/4)
	If (SubStr(date,1,6)>190002&&SubStr(date,1,6)<200001){
		C:=[[[6.11,"小寒",12,"xh"],[20.84,"大寒",12,"dh"]],[[4.6295,"立春",1,"lc"],[19.4599,"雨水",1,"ys"]],[[6.3826,"惊蛰",2,"jz"],[21.4155,"春分",2,"cf"]],[[5.59,"清明",3,"qm"],[20.888,"谷雨",3,"gy"]],[[6.318,"立夏",4,"lx"],[21.86,"小满",4,"xm"]],[[6.5,"芒种",5,"mz"],[22.2,"夏至",5,"xz"]],[[7.928,"小暑",6,"xs"],[23.65,"大暑",6,"ds"]],[[28.35,"立秋",7,"lq"],[23.95,"处暑",7,"cs"]],[[8.44,"白露",8,"bl"],[23.822,"秋分",8,"qf"]],[[9.098,"寒露",9,"hl"],[24.218,"霜降",9,"sj"]],[[8.218,"立冬",10,"ld"],[23.08,"小雪",10,"xx"]],[[7.9,"大雪",11,"dx"],[22.6,"冬至",11,"dz"]]]
		jq:=Floor(Y*D+C[month,1,1])-L, result:=[jq,C[month,1,2],C[month,1,3],C[month,1,4]]
		If SubStr(date,7,2)>=Floor(Y*D+C[month,2,1])-L
			result:=[Floor(Y*D+C[month,2,1])-L,C[month,2,2],C[month,2,3],C[month,2,4]]
		If (s&&SubStr(date,7,2)<jq&&SubStr(date,1,6)>190002)
			result:=[Floor(Y*D+C[(month=1?12:month-1),2,1])-L,C[(month=1?12:month-1),2,2],C[(month=1?12:month-1),2,3],C[(month=1?12:month-1),2,4]]
		for section,element in [[2084,"cf"],[1911,"lx"],[2008,"xm"],[1902,"mz"],[1928,"xz"],[1925,"xs"],[2016,"xs"],[1922,"ds"],[2002,"lq"],[1927,"bl"],[1942,"qf"],[2089,"sj"],[2089,"ld"],[1978,"xx"],[1954,"dx"],[1982,"xh"],[2000,"dh"],[2082,"dh"]]
			If (result[4]=element[2]&&year=element[1])
				result[1]:=result[1]+1
		for section,element in [[2026,"ys"],[1918,"dz"],[2021,"dz"],[2019,"xh"]]
			If (result[4]=element[2]&&year=element[1])
				result[1]:=result[1]-1
		return result
	}else if (SubStr(date,1,6)>200000&&SubStr(date,1,6)<209912){
		C:=[[[5.4055,"小寒",12,"xh"],[20.12,"大寒",12,"dh"]],[[3.87,"立春",1,"lc"],[18.73,"雨水",1,"ys"]],[[5.63,"惊蛰",2,"jz"],[20.646,"春分",2,"cf"]],[[4.81,"清明",3,"qm"],[20.1,"谷雨",3,"gy"]],[[5.52,"立夏",4,"lx"],[21.04,"小满",4,"xm"]],[[5.678,"芒种",5,"mz"],[21.37,"夏至",5,"xz"]],[[7.108,"小暑",6,"xs"],[22.83,"大暑",6,"ds"]],[[7.5,"立秋",7,"lq"],[23.13,"处暑",7,"cs"]],[[7.646,"白露",8,"bl"],[23.042,"秋分",8,"qf"]],[[8.318,"寒露",9,"hl"],[23.438,"霜降",9,"sj"]],[[7.438,"立冬",10,"ld"],[22.36,"小雪",10,"xx"]],[[7.18,"大雪",11,"dx"],[21.94,"冬至",11,"dz"]]]
		jq:=Floor(Y*D+C[month,1,1])-L, result:=[jq,C[month,1,2],C[month,1,3],C[month,1,4]]
		If SubStr(date,7,2)>=Floor(Y*D+C[month,2,1])-L
			result:=[Floor(Y*D+C[month,2,1])-L,C[month,2,2],C[month,2,3],C[month,2,4]]
		If (s&&SubStr(date,7,2)<jq&&SubStr(date,1,6)>200000)
			result:=[Floor(Y*D+C[(month=1?12:month-1),2,1])-L,C[(month=1?12:month-1),2,2],C[(month=1?12:month-1),2,3],C[(month=1?12:month-1),2,4]]
		for section,element in [[2084,"cf"],[1911,"lx"],[2008,"xm"],[1902,"mz"],[1928,"xz"],[1925,"xs"],[2016,"xs"],[1922,"ds"],[2002,"lq"],[1927,"bl"],[1942,"qf"],[2089,"sj"],[2089,"ld"],[1978,"xx"],[1954,"dx"],[1982,"xh"],[2000,"dh"],[2082,"dh"]]
			If (result[4]=element[2]&&year=element[1])
				result[1]:=result[1]+1
		for section,element in [[2026,"ys"],[1918,"dz"],[2021,"dz"],[2019,"xh"]]
			If (result[4]=element[2]&&year=element[1])
				result[1]:=result[1]-1
		return result
	}else{
		return []
	}
}

dateTotal(num){
	days:=[31,28,31,30,31,30,31,31,30,31,30,31]
	y:=SubStr(num,1,4),m:=SubStr(num,5,2),d:=SubStr(num,7,2)
	sum:= 0
	if(IsLeap(y))
		days[2]:= 29
	Loop,% m-1
		sum+=days[A_Index]
	Return sum+d-1
}

SetLunarTime(time=""){
	time:=time?time:A_Now
	If strlen(time)<10
		return time
	days:=[31,28,31,30,31,30,31,31,30,31,30,31]
	y:=SubStr(time,1,4),m:=SubStr(time,5,2),d:=SubStr(time,7,2),t:=SubStr(time,9,2)
	if(IsLeap(y))
		days[2]:= 29
	If (t=23) {
		If (d=days[m]) {
			d:=1,t:="00", y:=m=12?y+1:y, m:=m=12?1:m+1
		}else
			d:=d+1,t:="00"
	}
	m:=strlen(m)<2?0 m:m, t:=strlen(t)<2?0 t:t, d:=strlen(d)<2?0 d:d
	return y . m . d . t
}

FormatDate(SJ,s:=0, t:=0){   ;;s=1为格式化后时间格式，s=0为源格式；t=0为24小时制，t=0为12小时制
	global GzType
	Lunar:=Date2LunarDate(SubStr(A_Now,1,10),GzType), LunarYear:=SubStr(Lunar[1],1,2)
	RegExMatch(Lunar[1],"年.+月",date1), LunarMon:=substr(Date1,2,-1), RegExMatch(Lunar[1],"月.+",date2), LunarDay:=substr(Date2,2)
	FormatObj:={sj1:[["年"," A_YYYY "],["月"," A_MMM "], ["日"," A_DD "], ["全时"," A_Hour "], ["时"," A_Hour "], ["全点"," A_Hour "], ["点"," A_Hour "], ["分"," A_Min "] ,["毫秒"," A_MSec "], ["秒"," A_Sec "], ["周数"," A_YWeek "] , ["星期"," A_DDDD "] ,["周"," A_DDD "], ["公元","gg"]]
		, sj2:[["年","yyyy``年"],["ln",LunarYear "``年"],["月","MM``月"],["ly",LunarMon "``月"], ["lr",LunarDay],["日","d``日"],["时",t?"tthh时":"HH``时"], ["ls",SubStr(Time_GetShichen(A_Hour),1,1) "``时"], ["点",t?"tthh点":"HH``点"], ["分","mm``分"] 
		,["毫秒"," A_MSec "], ["秒","ss``秒"] , ["周数","第" SubStr(A_YWeek, 5) "週"], ["周","ddd"], ["星期","dddd"], ["公元","gg"], ["节气",Lunar[5]],["干支",Lunar[2]],["全时","HH"],["全点","HH"],["週","周"],["中文格式",formatChineseDate(A_Now)]]}
	For Section,element In FormatObj[s?"sj2":"sj1"]
	{
		If (SJ ~= element[1]&&not SJ ~="``" element[1]) {
			SJ:=RegExReplace(SJ,element[1],element[2])
		}
	}
	If !s
		SJ:=RegExReplace(SJ,"[^a-zA-Z\_]",A_space)
	else
		SJ:=RegExReplace(SJ,"``")
	return sj
}

;获取农历时辰
Time_GetShichen(time)
{
	shichen :=["子时(夜半｜三更)","丑时(鸡鸣｜四更)","丑时(鸡鸣｜四更)","寅时(平旦｜五更)","寅时(平旦|五更)","卯时(日出)","卯时(日出)","辰时(食时)","辰时(食时)","巳时(隅中)","巳时(隅中)","午时(日中)","午时(日中)","未时(日昳)","未时(日昳)","申时(哺时)","申时(哺时)","酉时(日入)","酉时(日入)","戌时(黄昏｜一更)","戌时(黄昏｜一更)","亥时(人定｜二更)","亥时(人定｜二更)","子时(夜半｜三更)"]
	time_count :=time+1
	Loop % shichen.MaxIndex()
	%A_Index% = %time_count%
	LShichen :=shichen[time_count]
	Return,LShichen
}

;-------------------------农历转公历-------------------------
/*
<参数>
Lunar:
农历日期
IsLeap:
是否闰月
如，某年闰7月，第一个7月不是闰月，第二个7月是闰月，IsLeap=1
当年没有闰月这个参数无效
<返回值>
公历日期(YYYYDDMM)
*/
Date_GetDate(Lunar,IsLeap=0)
{
	;分解农历年月日
	StringLeft,Year,Lunar,4
	StringMid,Month,Lunar,5,2
	StringRight,Day,Lunar,2
	if substr(Month,1,1)=0
		StringTrimLeft,month,month,1
	if (Year>2100 Or Year<1900 or Month>12 or Month<1 or Day>30 or Day<1)
	{
		errorinfo=无效日期
		return,errorinfo
	}

	;1899年~2100年农历数据
	;前三位，Hex，转Bin，表示当年月份，1为大月，0为小月
	;第四位，Dec，表示闰月天数，1为大月30天，0为小月29天
	;第五位，Hex，转Dec，表示是否闰月，0为不闰，否则为闰月月份
	;后两位，Hex，转Dec，表示当年新年公历日期，格式MMDD
	LunarData=
	(LTrim Join
	AB500D2,4BD0883,
	4AE00DB,A5700D0,54D0581,D2600D8,D9500CC,655147D,56A00D5,9AD00CA,55D027A,4AE00D2,
	A5B0682,A4D00DA,D2500CE,D25157E,B5500D6,56A00CC,ADA027B,95B00D3,49717C9,49B00DC,
	A4B00D0,B4B0580,6A500D8,6D400CD,AB5147C,2B600D5,95700CA,52F027B,49700D2,6560682,
	D4A00D9,EA500CE,6A9157E,5AD00D6,2B600CC,86E137C,92E00D3,C8D1783,C9500DB,D4A00D0,
	D8A167F,B5500D7,56A00CD,A5B147D,25D00D5,92D00CA,D2B027A,A9500D2,B550781,6CA00D9,
	B5500CE,535157F,4DA00D6,A5B00CB,457037C,52B00D4,A9A0883,E9500DA,6AA00D0,AEA0680,
	AB500D7,4B600CD,AAE047D,A5700D5,52600CA,F260379,D9500D1,5B50782,56A00D9,96D00CE,
	4DD057F,4AD00D7,A4D00CB,D4D047B,D2500D3,D550883,B5400DA,B6A00CF,95A1680,95B00D8,
	49B00CD,A97047D,A4B00D5,B270ACA,6A500DC,6D400D1,AF40681,AB600D9,93700CE,4AF057F,
	49700D7,64B00CC,74A037B,EA500D2,6B50883,5AC00DB,AB600CF,96D0580,92E00D8,C9600CD,
	D95047C,D4A00D4,DA500C9,755027A,56A00D1,ABB0781,25D00DA,92D00CF,CAB057E,A9500D6,
	B4A00CB,BAA047B,AD500D2,55D0983,4BA00DB,A5B00D0,5171680,52B00D8,A9300CD,795047D,
	6AA00D4,AD500C9,5B5027A,4B600D2,96E0681,A4E00D9,D2600CE,EA6057E,D5300D5,5AA00CB,
	76A037B,96D00D3,4AB0B83,4AD00DB,A4D00D0,D0B1680,D2500D7,D5200CC,DD4057C,B5A00D4,
	56D00C9,55B027A,49B00D2,A570782,A4B00D9,AA500CE,B25157E,6D200D6,ADA00CA,4B6137B,
	93700D3,49F08C9,49700DB,64B00D0,68A1680,EA500D7,6AA00CC,A6C147C,AAE00D4,92E00CA,
	D2E0379,C9600D1,D550781,D4A00D9,DA400CD,5D5057E,56A00D6,A6C00CB,55D047B,52D00D3,
	A9B0883,A9500DB,B4A00CF,B6A067F,AD500D7,55A00CD,ABA047C,A5A00D4,52B00CA,B27037A,
	69300D1,7330781,6AA00D9,AD500CE,4B5157E,4B600D6,A5700CB,54E047C,D1600D2,E960882,
	D5200DA,DAA00CF,6AA167F,56D00D7,4AE00CD,A9D047D,A2D00D4,D1500C9,F250279,D5200D1
	)

	;获取当年农历数据
	Pos:=(Year-1899)*8+1
	StringMid,Data,LunarData,%Pos%,7

	;判断公历日期
	Analyze(Data,MonthInfo,LeapInfo,Leap,Newyear)
	;计算到当天到当年农历新年的天数
	Sum=0
	if Leap			;有闰月
	{
		StringLeft,p1,MonthInfo,%Leap%
		StringTrimLeft,p2,MonthInfo,%Leap%
		thisMonthInfo:=p1 . LeapInfo . p2
		if (Leap!=Month and IsLeap=1)
		{
			errorinfo=该月不是闰月
			return,errorinfo
		}
		if (Month<=Leap and IsLeap=0)
		{
			loop,% Month-1
			{
				StringMid,thisMonth,thisMonthInfo,%A_index%,1
				Sum:=Sum+29+thisMonth
			}
		}
		Else
		{
			loop,% Month
			{
				StringMid,thisMonth,thisMonthInfo,%A_index%,1
				Sum:=Sum+29+thisMonth
			}
		}
	}
	Else
	{
		loop,% Month-1
		{
			thisMonthInfo:=MonthInfo
			StringMid,thisMonth,thisMonthInfo,%A_index%,1
			Sum:=Sum+29+thisMonth
		}
	}
	Sum:=Sum+Day-1

	GDate=%Year%%NewYear%
	GDate+=%Sum%,days
	StringTrimRight,Gdate,Gdate,6
	return,Gdate
}

;分析农历数据的函数 按上面所示规则分析
;4个回参分别对应四项
Analyze(Data,ByRef rtn1,ByRef rtn2,ByRef rtn3,ByRef rtn4)
{
	;rtn1
	StringLeft,Month,Data,3
	rtn1:=System("0x" . Month,"H","B")
	if Strlen(rtn1)<12
		rtn1:="0" . rtn1

	;rtn2
	StringMid,rtn2,Data,4,1

	;rtn3
	StringMid,leap,Data,5,1
	rtn3:=System("0x" . leap,"H","D")

	;rtn4
	StringRight,Newyear,Data,2
	rtn4:=System("0x" . newyear,"H","D")
	if strlen(rtn4)=3
		rtn4:="0" . rtn4
}

;-------------------------金額轉換--------------------------
Dot_To(num,st){
	;st:简繁状态0为简体1为繁体
	if num ~="^\d+\." {
		static Dot :=["角","分","厘","毫"]
		,num_t :=["壹","貳","叁","肆","伍","陆","柒","捌","玖"]
		,num_s :=["一","二","三","四","五","六","七","八","九"]
		if num~="^[^\d]+"
			Return
		arr:=StrSplit(num,"."), result1:=NumToC(arr[1],st) (st?"圆":"元")
		If num~="\d+\.$"
			return result1?result1 "整":""
		loop,% strlen(arr[2])>4?4:strlen(arr[2])
			s.=SubStr(arr[2],A_Index,1)>0?(st?num_t[SubStr(arr[2],A_Index,1)]:num_s[SubStr(arr[2],A_Index,1)]) Dot[A_Index]:st?"零":"〇"
		return result1&&s?result1 s:""
	}else{
		if num~="^\d+$" {
			result :=NumToC(num,st), result:=result?result (st?"圆整":"元整"):""
		}
	}
	return result
}
;------------------------数字转中文--------------------

NumToC(num,st){
	;;n--数字    st--简繁状态0为简体1为繁体
	if num~="^[^1-9]+$"||strlen(num)>16
		Return
	static m_s:=["","万","亿","万亿"],m_t:=["","萬","億","萬億"]
	len:=StrLen(num), result="", arr:=[], c:=Mod(len,4), l:=c?Ceil(len/4):Floor(len/4)
	If c
		arr.push(substr(num,1,c)),num:=substr(num,c+1)
	Loop, % c?l-1:l
		arr.push(substr(num,(A_Index-1)*4+1,4))
	Count:= objcount(arr)
	For key,value In arr
	{
		nt:=NumToChs(value,st)
		result.=(nt~="^(一十|壹拾)"?SubStr(nt,2):nt) . (st&&nt?m_t[Count]:!st&&nt?m_s[Count]:""),Count--
	}
	result:=RegExReplace(result,"[零〇]+(?=[十拾百佰千仟万萬亿億])|[零〇]+$")
	, result:=RegExReplace(result,"[零〇]{2,}",st?"零":"〇")
	return RegExReplace(result ,"[零〇]+$")
}

NumToChs(num,st){

	static t:=["壹","貳","叁","肆","伍","陆","柒","捌","玖"]
		,s:=["一","二","三","四","五","六","七","八","九"]
		,dw_s:=["","十","百","千","万","亿"]
		,dw_t:=["","拾","佰","仟","萬","億"]
	len:=Count:=StrLen(num)
	Loop, Parse,num
		r.=A_LoopField==0?st?"零":"〇":(st?t[A_LoopField]:s[A_LoopField]) (st?dw_t[Count]:dw_s[Count]), Count--
	Return r

}

;-------------------------取色值-------------------------
/*
;~ a=111
b=902030302010100000
;~ c=0XAD0
d:=system(B,"D","H")
c:=system(d,"h","d")
MsgBox,% d . "`n" . c  . "`n" .  system(b,"D","B")
*/

Bin(x)
{                ;dec-bin
	while x
	r:=1&x r,x>>=1
	return r
}
Dec(x)
{                ;bin-dec
	b:=StrLen(x),r:=0
	loop,parse,x
	r|=A_LoopField<<--b
	return r
}
Dec_Hex(x)                ;dec-hex
{
	SetFormat, IntegerFast, hex
	he := x
	he += 0
	he .= ""
	SetFormat, IntegerFast, d
	Return,he
}
Hex_Dec(x)
{
	SetFormat, IntegerFast, d
	de := x
	de := de + 0
	Return,de
}

system(x,InPutType="D",OutPutType="H")
{
	if InputType=B
	{
		IF OutPutType=D
		r:=Dec(x)
		Else IF OutPutType=H
		{
			x:=Dec(x)
			r:=Dec_Hex(x)
		}
	}
	Else If InputType=D
	{
		IF OutPutType=B
		r:=Bin(x)
		Else If OutPutType=H
		r:=Dec_Hex(x)
	}
	Else If InputType=H
	{
		IF OutPutType=B
		{
			x:=Hex_Dec(x)
			r:=Bin(x)
		}
		Else If OutPutType=D
		r:=Hex_Dec(x)
	}
	Return,r
}

;----------------------进制转换----------------------------------------------

;//二进制字符串转为十六进制字符串
bin2hex(s) {
;//对字符串规范化：前面加1并添0使长度为4的整数倍
	s:="1" s
	Loop, % Mod(4-Mod(StrLen(s),4),4)
	s:="0" s
	ss=
	Biao:={0:"0",1:"1",10:"2",11:"3",100:"4",101:"5"
	,110:"6",111:"7",1000:"8",1001:"9",1010:"A"
	,1011:"B",1100:"C",1101:"D",1110:"E",1111:"F"}
	Loop % StrLen(s)//4
	ss.=Biao[SubStr(s,(A_Index-1)*4+1,4)]
	Return, ss
}

;//十六进制字符串恢复为二进制字符串
hex2bin(s) {
	Biao:={0:"0000",1:"0001",2:"0010",3:"0011",4:"0100"
	,5:"0101",6:"0110",7:"0111",8:"1000",9:"1001",A:"1010"
	,B:"1011",C:"1100",D:"1101",E:"1110",F:"1111"}
	ss=
	Loop, Parse, s
	ss.=Biao[A_LoopField]
	ss:=SubStr(ss,InStr(ss,"1")+1)
	Return, ss
}

bin2ten(s){
	if not s ~="[0-9]"
		Return
	else
	{
		loop % Strlen(s){
			c :=SubStr(s,A_Index,1)*2**(Strlen(s)-A_Index)
			c_ +=c
		}
		Return c_
	}
}

;//10进制字符串转换为2、8、16进制字符串 16转10进制 十六进制字符串要加0x
ToBase(n,b){
	return (n < b ? "" : ToBase(n//b,b)) . ((d:=Mod(n,b)) < 10 ? d : Chr(d+55))
}

BaseToBase(chars){
	if not chars ~="[0-9a-f]"||chars ~="\."
		return "无效字符"
	else if not chars ~="[2-9a-z]"
		Return bin2ten(chars)  "『10进制』"
	else if (chars ~="[a-f]"&&chars ~="\d+")
		Return ToBase("0x"chars,10)  "『10进制』"
	else
		Return ToBase(chars,16)  "『16进制』"

}

RgbAndHex(chars){
	if chars ~="\,|\."{
		tarr:=[]
		tarr:=StrSplit(chars,[",", "."])
		;Rgb_:="0x" Format("{:x}{:X}{:X}`r`n", tarr[1],tarr[2],tarr[3])
		Rgb_ :="0x" (tarr[1]<16?("0" Format("{:x}",tarr[1])):Format("{:x}",tarr[1])) (tarr[2]<16?("0" Format("{:x}",tarr[2])):Format("{:x}",tarr[2])) (tarr[3]<16?("0" Format("{:x}",tarr[3])):Format("{:x}",tarr[3]))
		Rgb_:=(strlen(Rgb_)>10||strlen(Rgb_)<7)?"格式错误":Rgb_
	} else if chars ~="i)0x|#"{
		if chars ~="i)0x"&&strlen(chars)<>8||chars ~="#"&&strlen(chars)<>7
			RGB_ :="格式错误"
		else
		{
			R_ :=(chars ~="i)0x"?SubStr(chars, 1, 2):"0x") (chars ~="i)0x"?SubStr(chars, 3, 2):SubStr(chars, 2, 2))
			G_ :=(chars ~="i)0x"?SubStr(chars, 1, 2):"0x") (chars ~="i)0x"?SubStr(chars, 5, 2):SubStr(chars, 4, 2))
			B_ :=(chars ~="i)0x"?SubStr(chars, 1, 2):"0x") (chars ~="i)0x"?SubStr(chars, 7, 2):SubStr(chars, 6, 2))
			SetFormat, IntegerFast, D
			SetFormat, IntegerFast, D
			SetFormat, IntegerFast, D
			R_ += 0,G_ += 0,B_ += 0
			RGB_ = %R_%`,%G_%`,%B_%
		}
	}
	return Rgb_
}

;英文转小写 T首字母
StringLower(ByRef InputVar, T = "")
{
	StringLower, InputVar, InputVar, %T%
	return InputVar
}
 
;英文转大写 T首字母
StringUpper(ByRef InputVar, T = "")
{
	StringUpper, InputVar, InputVar, %T%
	return InputVar
}

;===================统计字符数=============
wStrLen(source)
{
	outStr:=""
	bLen := StrLen(source)
	wLen := 0
	i := 1    ; 字串指针
	loop
	{
		code1 := substr(source, i, 1)
		code2 := substr(source, i+1, 1)
		asc1 := asc(code1)
		asc2 := asc(code2)
		if (i+1>bLen)
		{
			if (i>bLen)
			{
				break
			}
			outStr .= "{ASC " . asc1 . "}" 
			wLen++
			break
		}
		if (asc1 >= 129 and asc1 <= 254)
		{
			if (asc2 >= 64 and asc2 <= 254)
			{
				asc1 <<= 8
				asc1 += asc2
				outStr .= "{ASC " . asc1 . "}" 
				wLen++
				i += 2
				continue
			}
		}
		outStr .= "{ASC " . asc1 . "}"
		wLen++
		i++
	}
	return wLen
}

Hex2Str(val, len, x:=false)
{
	SetFormat, IntegerFast, D
	VarSetCapacity(out, len*2, 32)
	DllCall("msvcrt\sprintf", "AStr", out, "AStr", "%0" len "I64X", "UInt64", val, "CDecl")
	Return x ? "0x" out : out
}

/*
 * 获取选中的文本
 */
getSelectText()
{
	ClipboardOld = %ClipboardAll%
	Clipboard =  ; 必须清空, 才能检测是否有效
	SendInput ^c
	ClipWait, 0
	if ErrorLevel  ; ClipWait 超时
	{
		;MsgBox, 262160,错误提示, % "没有选中文本或获取选中的文本失败，请选中文本后重新尝试！"
		return 0
	}
	selectedText = %Clipboard%
	Clipboard = %ClipboardOld%
	
	return %selectedText%
}

/*
 * 获取文件列表，以`n分割
 */
getFileList(pathPattern)
{
	fileList :=""
	Loop, %pathPattern%, 0, 1
		if not fileList
		{
			fileList = %A_LoopFileName%
		}else 
		{
			fileList = %fileList%`n%A_LoopFileName%
		}
	return fileList
}

/*
 * 获取文件夹列表，以`n分割
 */
getDirList(pathPattern)
{
	dirList :=""
	Loop, %pathPattern%, 2, 1
		if not dirList
		{
			dirList = %A_LoopFileName%
		}else
		{
			dirList = %dirList%`n%A_LoopFileName%
		}
		
	return dirList
}

/*
 * 根据文件或文件夹名称获取完整路径
 */
getPathByName(pathPattern)
{
	path :=""
	Loop, %pathPattern%, 1, 1
		path = %A_LoopFileFullPath%
	return path
}

/*
 * 粘贴给定的内容
 */
pasteText(content)
{
	ClipboardOld := ClipboardAll
	Clipboard := content
	SendInput ^v
	Clipboard := ClipboardOld
	return
}

;===================执行批获取================

cmdClipReturn(command){
	cmdInfo:=""
	Clip_Saved :=ClipboardAll
	ClipWait,0
	try{
		Clipboard:=""
		Run,% ComSpec " /C " command " | CLIP", , Hide
		ClipWait,2
		cmdInfo:=Clipboard
	}catch{}
	Clipboard :=Clip_Saved
	return cmdInfo
}

;====================本机字体获取===========
;返回a_FontList变量
EnumFontFamilies(lpelf,lpntm,FontType,lP)
{
	global a_FontList
	if (substr(StrGet(lpelf+28),1,1)<>"@")
		a_FontList .= StrGet(lpelf+28) . "|" 
		Return 1
}
DllCall("gdi32\EnumFontFamilies","uint",DllCall("GetDC","uint",0),"uint",0,"uint",RegisterCallback("EnumFontFamilies"),"uint",a_FontList:="")

;======================ToolTip样式========================
ToolTipStyle(hwnd:="",Options:=""){
	static bc:="", tc:="", htext:=0, hfont:=0
	If IsObject(Options){
		For key,value In Options
			%key%:=value
		If (Background)
			Background:="0x" Background, bc:=((Background&255)<<16)+(((Background>>8)&255)<<8)+(Background>>16)
		If (Text)
			Text:="0x" Text, tc:=((Text&255)<<16)+(((Text>>8)&255)<<8)+(Text>>16)
		If (Font||Size){
			If !htext {
				Gui _TTG: Add, Text, +hwndhtext
				Gui _TTG: +hwndhgui +0x40000000
			}
			Gui _TTG: Font, %Size%, %Font%
			GuiControl _TTG: Font, %htext%
			hfont:=DllCall("SendMessage", "Ptr", htext, "Uint", 0x31, "Ptr", 0, "Ptr", 0)
		}
	}
	If (hwnd&&(bc||tc||hfont)){
		DllCall("UxTheme.dll\SetWindowTheme", "ptr", hwnd, "Ptr", 0, "UintP", 0)
		If (bc)
			DllCall("SendMessage", "Ptr", hwnd, "Uint", 1043, "Ptr", bc, "Ptr", 0)
		If (tc)
			DllCall("SendMessage", "Ptr", hwnd, "Uint", 1044, "Ptr", tc, "Ptr", 0)
		If (hfont)
			DllCall("SendMessage", "Ptr", hwnd, "Uint", 0x30, "Ptr", hfont, "Ptr", 0)
	}
}

numTohz(num){
	num_switch:=[], result1:=Dot_To(num,0), result2:=Dot_To(num,1)
	If result1&&result2
		num_switch[1,1] :=result1,num_switch[2,1] := result2
	Lunar_Jq:=GetLunarJqDate(num)
	If Lunar_Jq
		num_switch.Push([Lunar_Jq])
	for section,element in Conv_LunarDate(num)
		If ObjLength(element)
			num_switch.Push(element)
	;PrintObjects(num_switch)
	return num_switch
}

Conv_LunarDate(date){
	global GzType
	if (not date~="\d+"||date=""||strlen(date)<8||date~="\.")
		return ["无效日期"]
	result:=[], ld:=Date_GetDate(SubStr(date,1,8)), ldp:=Date_GetDate(SubStr(date,1,8),1), LunarTg:=Date2LunarDate(date,GzType)
	LunarTg_1:=ld~="^\d+"?Date2LunarDate(ld SubStr(date,9,2),GzType):[], LunarTg_2:=ldp~="^\d+"&&ld<>ldp?Date2LunarDate(ldp SubStr(date,9,2),GzType):[] 
	If ObjLength(LunarTg) {
		result.Push([LunarTg[1] (LunarTg[5]?" - " LunarTg[5]:""),ObjLength(LunarTg)?"〔 公历转农历 〕":"",ObjLength(LunarTg)?"〔 公历转农历 〕":""])
		result.Push([LunarTg[2]?LunarTg[2]:"日期超限",ObjLength(LunarTg)&&strlen(LunarTg[2])>8?"〔 干支纪年 〕":"",ObjLength(LunarTg)&&strlen(LunarTg[2])>8?"〔 干支纪年 〕":""])
	}
	If ObjLength(LunarTg_1)
		result.Push([ formatChineseDate( ld ) jq,"〔 农历转公历① 〕","〔 农历转公历① 〕"]), result.Push([ LunarTg_1[2]?LunarTg_1[2]:"日期超限" ,strlen(LunarTg_1[2])>8?"〔 干支纪年① 〕":"",strlen(LunarTg_1[2])>8?"〔 干支纪年① 〕":""])
	if ObjLength(LunarTg_2)
		result.Push([ "" formatChineseDate( ldp) jq2,"〔 农历转公历(闰) 〕","〔 农历转公历(闰) 〕"]), result.Push([ LunarTg_2[2]?LunarTg_2[2]:"日期超限" ,strlen(LunarTg_2[2])>8?"〔 干支纪年(闰) 〕":"",strlen(LunarTg_2[2])>8?"〔 干支纪年(闰) 〕":""])
	Return result
}

GetLunarTg(date){
	global GzType
	if (not date~="\d+"||date=""||strlen(date)<8)
		return ["无效日期"]
	result:=[], tg1:=Date_GetDate(SubStr(date,1,8),1), tg2:=Date_GetDate(SubStr(date,1,8))
	If tg2~="^\d+"
		result.Push(Date2LunarDate( tg2 )[2] )
	if tg1~="^\d+"
		result.Push( "(闰)" Date2LunarDate( tg1 )[2] )
	Return result
}

GetLunarJqDate(date){
	If (strlen(date)<>6||not date~="^(19|20)[0-9]{2}[0-1][0-9]")
		return ""
	year:=SubStr(date,1,4), month:=RegExReplace(SubStr(date,5,2),"^0")
	If (strlen(date)=6&&ObjLength(jq1:=GetLunarJq(date 03))&&jq2:=GetLunarJq(date 28))
		jq:=jq1[2] A_space year "-" Month "-" jq1[1] "｜" jq2[2] A_space year "-" Month "-" jq2[1]
	return jq
}

Get_LunarDate(){
	global GzType
	sj:=[]
	FormatTime, MIVar, , H
	lunar :=Date2LunarDate(A_Now,GzType)
	lunar_time :=Time_GetShichen(MIVar)
	Lunar_jq:=GetLunarJq(A_Now,1), jq:=SubStr(A_Now,7,2)=Lunar_jq[1]?"-" Lunar_jq[2]
	for section,element in [[lunar[1] . lunar_time (lunar[5]?" - " lunar[5]:"")],[Lunar[2]]]
		sj.Push(element)
	Return sj
}

Get_Date(){
	sj:=[]
	StringRight, wk, A_YWeek, 2
	FormatTime, TimeVar, , tth时mm分ss秒
	FormatTime, RQVar, , yyyyMMdd
	FormatTime, RQVar1, , yyyy-MM-dd
	FormatTime, RQVar2, , yyyy/MM/dd
	FormatTime, DateVar, , ggyyyy年M月d日-dddd
	date=%DateVar%｜第%wk%周
	for section,element in [[formatChineseDate(RQVar)],[date],[RQVar1],[RQVar2],[Days_Count(RQVar)]]
		sj.Push(element)
	Return sj
}

formatChineseDate(num){
	if (not num~="\d"||strlen(num)<8)
		Return "无效日期"
	Arr:=["一","二","三","四","五","六","七","八","九","〇"]
	loop,4
		year.=Arr[substr(num,A_Index,1)>0?substr(num,A_Index,1):10]
	month:=(substr(num,5,1)=1?"十":substr(num,5,1)>1?Arr[substr(num,5,1)] "十":"") Arr[substr(num,6,1)]
	day:=(substr(num,7,1)=1?"十":substr(num,7,1)>1?Arr[substr(num,7,1)] "十":"") Arr[substr(num,8,1)]
	Return year&&month&&day?year "年" month "月" day "日":""
}

Get_Time(){
	sj:=[]
	StringRight, wk, A_YWeek, 2
	FormatTime, TimeVar1, , tth时mm分ss秒
	FormatTime, TimeVar2, , H:mm:ss
	FormatTime, TimeVar3, , yyyy/MM/dd H:mm:ss
	time=%TimeVar1%%A_MSec%"
	for section,element in [[TimeVar1],[TimeVar2],[TimeVar3],[time]]
		sj.Push(element)
	Return sj
}

IsLeap(year){
	if(((Mod(year,4)=0)&&(Mod(year, 100)!=0))||Mod(year, 400)=0)
		Return 1
	Else
		Return 0
}

Days_Count(num){
	days:=[0,31,28,31,30,31,30,31,31,30,31,30,31]
	y:=SubStr(num,1,4),m:=SubStr(num,5,2),d:=SubStr(num,7,2)
	sum:= 0 ; 计算天数
	if(IsLeap(y)) ;如果为闰年,2月有 29 天
		days[3]:= 29
	Loop,%m%
	{
		sum+=days[A_Index]
	}
	sum+= d-1
	Return y "年已过去" sum "天|剩余" (IsLeap(y)?366-sum:365-sum) "天"
}

; 获取光标坐标
GetCaretPos(Byacc:=1){
	Static init
	If (A_CaretX=""){
		Caretx:=Carety:=CaretH:=CaretW:=0
		If (Byacc){
			If (!init)
				init:=DllCall("LoadLibrary","Str","oleacc","Ptr")
			VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8
			, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
			, NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
			If (DllCall("oleacc\AccessibleObjectFromWindow", "Ptr",Hwnd:=WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0){
				Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
				Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
				, CaretX:=NumGet(x,0,"int"), CaretY:=NumGet(y,0,"int"), CaretH:=NumGet(h,0,"int")
			}
		}
		If (Caretx=0&&Carety=0){
			MouseGetPos, x, y
			Return {x:x,y:y,h:35,t:"Mouse",Hwnd:Hwnd}
		} Else
			Return {x:Caretx,y:Carety,h:Max(Careth,35),t:"Acc",Hwnd:Hwnd}
	} Else
		Return {x:A_CaretX,y:A_CaretY,h:35,t:"Caret",Hwnd:Hwnd}
}

TransGui(s1="", x=500, y=0, font_size="s36",textbold="bold",fontcolor="blue")
{
	static
	if (s1=""){
		last:=""
		Gui, TransTip: Destroy
		return
	}
	if (last != FontCodeColor "|" s1){
		last:=FontCodeColor "|" s1, last_xy:=""
		Gui, TransTip: Destroy
		Gui, TransTip: +AlwaysOnTop -Caption +ToolWindow +Hwndid +E0x20 +border
		Gui, TransTip: Margin, 2, 4
		Gui, TransTip: Color, EEAA99
		Gui, TransTip: Font, %font_size% %textbold%
		Gui, TransTip: Add, Text,, %s1%
		Gui, TransTip: Show, Hide, TransTip
		dhw:=A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinSet, TransColor, EEAA99 180, ahk_id %id%
		DetectHiddenWindows, %dhw%
	}
	Gui, TransTip: +AlwaysOnTop
	if (last_xy != x "|" y){
		last_xy:=x "|" y, x:=Round(x), y:=Round(y)
		Gui, TransTip: Show, NA x%x% y%y%
	}
}

GetColor(x,y){
	PixelGetColor, color, x, y, RGB
	StringRight color,color,10 ;
	return color
}

GetToolTipSize(HWND){
	if HWND
	{
		WinGetPos, X_, Y_, Width, Height, ahk_id %hwnd%
		return {x:X_,y:Y_,w:Width,h:Height}
	}
}

SwitchToEngIME(){
	; 下方代码可只保留一个
	SwitchIME(0x04090409) ; 英语(美国) 美式键盘
}
SwitchToChsIME(){
	;~ SwitchIME(0x08040804) ; 中文(中国) 简体中文-美式键盘
	PostMessage, 0x50, 0, 0x8040804, , A
	If !IME_Return_0E1C()
		SendInput, #{Space}
}

GET_IMESt(WinTitle=""){   ;返回0为英文键盘,1为中文状态
	ifEqual WinTitle,,  SetEnv,WinTitle,A
	WinGet,hWnd,ID,%WinTitle%
	DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hWnd, Uint)
	;Message : WM_IME_CONTROL  wParam:IMC_GETOPENSTATUS
	DetectSave := A_DetectHiddenWindows
	DetectHiddenWindows,ON
	SendMessage 0x283, 0x005,0,,ahk_id %DefaultIMEWnd%
	DetectHiddenWindows,%DetectSave%
	Return ErrorLevel
}


SwitchIME(dwLayout){
	HKL:=DllCall("LoadKeyboardLayout", Str, dwLayout, UInt, 1)
	ControlGetFocus, ctl, A
	SendMessage, 0x50, 0, HKL, %ctl%, A
}

IME_Return_0E1C(WinTitle="A"){			;借鉴了某日本人脚本中的获取输入法状态的内容,减少了不必要的切换,切换更流畅了
	;~ ifEqual WinTitle,,  SetEnv,WinTitle,A
	WinGet, hWnd, ID, %WinTitle%
	DefaultIMEWnd:=DllCall("imm32\ImmGetDefaultIMEWnd", Uint, hWnd, Uint)
	;Message : WM_IME_CONTROL  wParam:IMC_GETOPENSTATUS
	DetectSave:=A_DetectHiddenWindows
	DetectHiddenWindows, ON
	SendMessage 0x283, 0x005, 0, ,ahk_id %DefaultIMEWnd%
	DetectHiddenWindows, %DetectSave%
	Return ErrorLevel
}

DelRegKey(RootKey, SubKey)
{
	Loop, %RootKey%, %SubKey%
	{
		RegRead, DWORD, %RootKey%\%SubKey%, %A_LoopRegName%
		if (DWORD ~="00000409"){
			if (A_LoopRegName=1&&DWORD ~="00000409"){
				RegDelete, %RootKey%\%SubKey%, %A_LoopRegName%
				RegDelete, %RootKey%\%SubKey%, 00000804
				RegWrite, REG_SZ, %RootKey%\%SubKey%, 1, 00000804
				return 1
			} else {
				RegDelete, %RootKey%\%SubKey%, %A_LoopRegName%
				return 1
	}}}
}

GetKeyboardLayoutList(){
	Keyboards:=""
	Loop,HKEY_LOCAL_MACHINE,SYSTEM\CurrentControlSet\Control\Keyboard Layouts,1,1
	{
		if(A_LoopRegName = "Layout Text"&&A_LoopRegSubKey~="0804$"&&A_LoopRegType <>"key" ){
			RegRead, value
			Keyboards.=value "<IME>" "|"
		}
	}
	Loop,HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\CTF\TIP,1,1
	{
		if(A_LoopRegName = "Description"&&A_LoopRegSubKey~="00000804"&&A_LoopRegType<>"key" ){
			RegRead, value
			Keyboards.=value "<TSF>" "|"
		}
	}
	return "英文键盘<IME>|" Keyboards

}

IME_GetKeyboardLayoutList(){
	Keyboards:={}
	Loop,HKEY_LOCAL_MACHINE,SYSTEM\CurrentControlSet\Control\Keyboard Layouts,1,1
	{
		if(A_LoopRegName = "Layout Text"&&A_LoopRegSubKey~="0804$"&&A_LoopRegType <>"key" ){
			RegRead, value
			Keyboards[value "<IME>",1]:=value "<IME>", Keyboards[value "<IME>",2]:=A_LoopRegSubKey , Keyboards[value "<IME>",3]:=RegExReplace(A_LoopRegSubKey,".+\\")
		}
	}
	Loop,HKEY_LOCAL_MACHINE,SOFTWARE\Microsoft\CTF\TIP,1,1
	{
		if(A_LoopRegName = "Description"&&A_LoopRegSubKey~="00000804"&&A_LoopRegType<>"key" ){
			RegRead, value
			Keyboards[value "<TSF>",1]:=value "<TSF>", Keyboards[value "<TSF>",2]:=A_LoopRegSubKey , Keyboards[value "<TSF>",3]:=RegExReplace(A_LoopRegSubKey,".+\\")
		}
	}
	Keyboards["英文键盘<IME>",1]:="英文键盘<IME>", Keyboards["英文键盘<IME>",2]:="", Keyboards["英文键盘<IME>",3]:="04090409"
	return Keyboards
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

test_db(chars,DB){
	if (chars<>""){
		DB.Exec("DROP TABLE IF EXISTS test_db;")
		DB.Exec("BEGIN TRANSACTION;")
		DB.Exec("CREATE TABLE test_db ('aim_chars' TEXT,'A_Key' TEXT ,'B_Key' INTEGER);")
		DB.Exec("COMMIT TRANSACTION;VACUUM;")
		;写入词频
		if not chars~="\t[a-y]+\t[0-9]+"
			chars:=Transform_cp(chars)
		Loop, Parse, chars, `n, `r
		{
			count++
			If (A_LoopField = "")
				Continue
			tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
			Insert_ci .="('" tarr[1] "','" tarr[2] "','" tarr[3] "')" ","
		}
		if DB.Exec("INSERT INTO test_db VALUES" RegExReplace(Insert_ci,"\,$","") "")>0 {
			SQL := "SELECT aim_chars,A_Key,B_Key FROM test_db ORDER BY A_Key,B_Key DESC;"
			if DB.gettable(SQL,Result){
				Loop % Result.RowCount
				{
					Resoure_ .=Result.Rows[A_index,1] A_tab Result.Rows[A_index,2] A_tab Result.Rows[A_index,3] "`n"
				}
				DB.Exec("DROP TABLE IF EXISTS test_db;VACUUM;")
				Return Resoure_
			}
		}

	}

}

TranCiku(FilePath,outpath=""){
	If !FileExist(FilePath)
		return 0
	outpath:=outpath?outpath:FilePath
	FileRead,chars,%FilePath%
	FileName:=RegExReplace(outpath,"\.[a-zA-Z0-9]+$")
	If chars~="[^a-zA-Z0-9]\t[a-z]+" {
		consistent_all:={}
		TrayTip,,正在转换为单行多义。。。
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
		FileDelete,%FileName%_多义.txt
		FileAppend,%loopvalue%,%FileName%_多义.txt,utf-8
		consistent_all:={}, loopvalue:=chars:="", consistent_part:=[]
		return 1
	}else If chars~="[a-z]\s.+\s" {
		TrayTip,,正在转换为单行单义。。。
		Loop,parse,chars,`n,`r
		{
			If A_LoopField
			{
				consistent_part:=StrSplit(RegExReplace(A_LoopField,"\s+",A_space),A_space)
				loopvalue_:=consistent_part[1]
				For key,value in consistent_part
					If (key>1&&value)
						loopvalue.=value A_tab loopvalue_ "`r`n"
			}
		}
		FileDelete,%FileName%_单义.txt
		FileAppend,%loopvalue%,%FileName%_单义.txt,utf-8
		chars:=loopvalue:=loopvalue_:="", consistent_part:=[]
		return 1
	}else{
		return 0
	}
}

Transform_mb(chars){
	if chars~="\t[a-z]+"{
		Traytip,,正在转换。。。
		chars:=RegExReplace(test_db(chars,DB),A_Space "|\t\d+")
		loop,parse,chars, `n, `r
		{
			if A_LoopField
			{
				RegExMatch(A_LoopField, ".+(?=\t[a-z])", citiao)
				RegExMatch(A_LoopField, "(?<=\t)[a-z]+", bianma)
				bianma:=RegExReplace(bianma, "\s+|\t"), citiao:=RegExReplace(citiao, "`r`n$|^`r`n|`n$|^`n")
				if (bianma=bianma_){
					part_:= A_space citiao
				}else{
					part_:= bianma A_space citiao
				}
				all_citiao .= (part_~=bianma?"`r`n" :"") part_
				bianma_:=bianma
			}
		}
		citiao:=bianma:=citiao:=part_:=bianma_:=""
		Sort, all_citiao
		return RegExReplace(all_citiao,"^`r`n")
	}else if chars~="[a-z]+\s"{
		Traytip,,正在转换。。。
		chars:=RegExReplace(chars,A_Tab)
		CpCount:=0
		loop,parse,chars, `n, `r
		{
			if A_LoopField
			{
				CpCount++
				RegExMatch(A_LoopField, "(?<=[a-z]\s).+", citiao)
				RegExMatch(A_LoopField, "^[a-z]+(?=\s)", bianma)
				citiao:=Set_Frequency(bianma, RegExReplace(RegExReplace(citiao, "\s$|^\s"), "\s{2,}", A_Space),CpCount)
				all_citiao .=citiao " `r`n", citiao:=""
			}
		}
			return RegExReplace(all_citiao,A_Space)
	}else{
		Return ""
	}
}

;;单行多义格式转换为单行单义
TransformCiku(Chars){
	If (Chars="")
		return ""
	If Chars~="[a-z]\s.+\s.+" {
		Loop,parse,Chars,`n,`r
		{
			If A_LoopField
			{
				consistent_part:=StrSplit(RegExReplace(A_LoopField,"\s+",A_space),A_space)
				loopvalue_:=consistent_part[1]
				For key,value in consistent_part
					If (key>1&&value)
						loopvalue.=value A_tab loopvalue_ "`r`n"
			}
		}
		return Transform_cp(loopvalue)
	}else{
		return ""
	}
}

;;单行单义码表生成词频
Transform_cp(chars){
	CpCount:=0,arr:=[]
	totalCount:=CountLines(Chars), num:=Ceil(totalCount/100), count:=0
	Progress, M1 Y10 FM14 W350, 1/%totalCount%, 词频生成中..., 1`%
	loop,parse, chars, `n, `r
	{
		if A_LoopField
		{
			CpCount:=bianma<>bianma_?1:CpCount++, count++
			arr:=StrSplit(A_LoopField,"`t")
			citiao:=arr[1],bianma:=arr[2]
			cp :=citiao A_Tab bianma A_Tab (34526534-A_Index*CpCount-A_Index*24)
			cip .=cp "`r`n", cp:="", bianma_:=bianma
			If (Mod(count, num)=0) {
				tx :=Ceil(count/num)
				Progress, %tx% , %count%/%totalCount%`n, 词频生成中..., 已完成%tx%`%
			}
		}
	}
	Progress, off
	Return RegExReplace(cip,"^`r`n")
}

;导入单义码表加词频
Set_Frequency(code,chars,CpCount){
	if (chars=""||chars~="\t[a-z]+\d+$|\t[a-z]+$")
		return ""
	loop,parse, chars, %A_Space%
	{
		if A_LoopField
		{
			cp :=A_LoopField A_Tab code A_Tab (34526534-A_Index*CpCount-A_Index*24)
			cip .=cp "`r`n", cp:=""
		}
	}
	return RegExReplace(cip, "`r`n$")
}

; ==============Menu========================================================================================================

; Namespace:      Menu
; Function:       Some functions related to AHK menus.
; Tested with:    AHK 1.1.14.03
; Tested on:      Win 8.1 Pro (x64)
; Changelog:
;     1.0.00.00/2014-03-26/just me - initial release
; General function parameters (not mentioned in the parameter description of functions):
;     HMENU       -  Handle to a menu or a menu bar.
;     ItemPos     -  1-based position of the menu item in the menu.
;     ItemName    -  Name (text string) of the menu item.
;     HWND        -  Handle to the window the menu is / will be assigned to.
; Credits:
;     Lexikos for MI.ahk (www.autohotkey.com/board/topic/20253-menu-icons-v2/) adopted in Menu_GetMenuByName().
; ======================================================================================================================
; BarHiliteItem   Adds or removes highlighting from an item in a menu bar.
; Parameters:     Hilite   -  Highlight the menu item (True / False).
;                             Default: True.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_BarHiliteItem(HWND, ItemPos, Hilite := True) {
   ; http://msdn.microsoft.com/en-us/library/ms647986(v=vs.85).aspx
   If (HMENU := Menu_GetMenu(HWND)) {
      Flags := 0x0400 | (Hilite ? 0x80 : 0x00)
      Return DllCall("User32.dll\HiliteMenuItem", "Ptr", HWND, "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", Flags, "UInt")
   }
   Return False
}
; ======================================================================================================================
; BarRightJustify Right-justifies the menu item and any subsequent items in a menu bar.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_BarRightJustify(HWND, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms648001(v=vs.85).aspx
   Static MIIsize := (4 * 6) + (A_PtrSize * 6) + ((A_PtrSize - 4) * 2)
   If (HMENU := Menu_GetMenu(HWND)) {
      VarSetCapacity(MII, MIIsize, 0)              ; MENUITEMINFO structure
      NumPut(MIIsize, MII, 0, "UInt")              ; cbSize
      NumPut(0x0100, MII, 4, "UInt")               ; fMask: MIIM_FTYPE = 0x0100
      If DllCall("User32.dll\GetMenuItemInfo", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 1, "Ptr", &MII, "UInt") {
         NumPut(NumGet(MII, 8, "UInt") | 0x4000, MII, 8, "UInt") ; fType: MFT_RIGHTJUSTIFY = 0x4000
         RC := DllCall("User32.dll\SetMenuItemInfo", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 1, "Ptr", &MII, "UInt")
         DllCall("User32.dll\DrawMenuBar", "Ptr", HWND, "UInt")
         Return RC
      }
   }
   Return False
}
; ======================================================================================================================
; CheckRadioItem  Checks a specified menu item and makes it a radio item. At the same time, the function clears
;                 all other menu items in the associated group and clears the radio-item type flag for those items.
; Parameters:     First -  The 1-based position of the first menu item in the group.
;                          Default: 1 = first menu item.
;                 Last  -  The 1-based position of the last menu item in the group.
;                          Default: 0 = last menu item.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_CheckRadioItem(HMENU, ItemPos, First := 1, Last := 0) {
   ; http://msdn.microsoft.com/en-us/library/ms647621(v=vs.85).aspx
   If (Last < 1)
      Last := Menu_GetItemCount(HMENU)
   Return DllCall("User32.dll\CheckMenuRadioItem", "Ptr", HMENU, "UInt", First - 1, "UInt", Last - 1
                                                 , "UInt", ItemPos - 1, "UInt", 0x0400, "UInt")
}
; ======================================================================================================================
; GetItemCount    Determines the number of items in the specified menu.
; Return values:  If the function succeeds, the return value specifies the number of items in the menu.
;                 If the function fails, the return value is -1
; ======================================================================================================================
Menu_GetItemCount(HMENU) {
   ; http://msdn.microsoft.com/en-us/library/ms647978(v=vs.85).aspx
   Return DllCall("User32.dll\GetMenuItemCount", "Ptr", HMENU, "Int")
}
; ======================================================================================================================
; GetItemInfo     Retrieves information about a menu item.
; Return values:  If the function succeeds, the return value is an object containing the following keys:
;                       Type     -  The menu item type flags.
;                       State    -  The menu item state flags.
;                       ID       -  The application-defined value that identifies the menu item.
;                       HMENU    -  The handle to the submenu associated with the menu item, if exist.
;                       Name     -  The menu item text string , if any.
;                       HBITMAP  -  The handle to the bitmap to be displayed, if any.
;                 If the function fails, the return value is zero (False).
; ======================================================================================================================
Menu_GetItemInfo(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647980(v=vs.85).aspx
   Static MIIsize := (4 * 6) + (A_PtrSize * 6) + ((A_PtrSize - 4) * 2)
   Static MIIoffs := (A_PtrSize = 8) ? {Type: 8, State: 12, ID: 16, HMENU: 24, String: 56, cch: 64, HBITMAP: 72}
                                     : {Type: 8, State: 12, ID: 16, HMENU: 20, String: 36, cch: 40, HBITMAP: 44}
   VarSetCapacity(MII, MIIsize, 0)              ; MENUITEMINFO structure
   NumPut(MIIsize, MII, 0, "UInt")              ; cbSize
   NumPut(0x1EF, MII, 4, "UInt")                ; fMask
   VarSetCapacity(String, 1024, 0)
   NumPut(&String, MII, MIIoffs.String, "UPtr") ; dwTypeData
   NumPut(512, MII, MIIoffs.cch, "UInt")        ; cch
   If DllCall("User32.dll\GetMenuItemInfo", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 1, "Ptr", &MII, "UInt")
      Return {Type: NumGet(MII, MIIoffs.Type, "UInt")
            , State: NumGet(MII, MIIoffs.State, "UInt")
            , ID: NumGet(MII, MIIoffs.ID, "UInt")
            , HMENU: NumGet(MII, MIIoffs.HMENU, "UPtr")
            , Name: StrGet(&String, NumGet(MII, MIIoffs.cch, "UInt"))
            , HBITMAP: NumGet(MII, MIIoffs.HBITMAP, "UPtr")}
   Return False
}
; ======================================================================================================================
; GetItemPos      Retrieves the position of the menu item specified by its name in the menu.
; Return values:  If the function succeeds, the return value is the 1-based position of the menu item.
;                 If the function fails, the return value is zero (False).
; ======================================================================================================================
Menu_GetItemPos(HMENU, ItemName) {
   Loop, % Menu_GetItemCount(HMENU)
      If (ItemName = Menu_GetItemName(HMENU, A_Index))
         Return A_Index
   Return False
}
; ======================================================================================================================
; GetItemState    Retrieves the state flags associated with the specified menu item.
; Return values:  If the specified item does not exist, the return value is -1.
;                 If the menu item opens a submenu, the low-order byte of the return value contains the menu flags,
;                 and the high-order byte contains the number of items in the submenu.
;                 Otherwise, the return value is a mask (Bitwise OR) of the menu flags.
; ======================================================================================================================
Menu_GetItemState(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647982(v=vs.85).aspx
   Return DllCall("User32.dll\GetMenuState", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 0x0400, "UInt")
}
; ======================================================================================================================
; GetItemName     Retrieves the name (text string) of the specified menu item.
; Return values:  If the function succeeds, the return value is the text string of the specified menu item.
;                 Otherwise, the return value is an empty string.
; ======================================================================================================================
Menu_GetItemName(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647983(v=vs.85).aspx
   VarSetCapacity(Str, 1024, 0) ; should be sufficient
   If DllCall("User32.dll\GetMenuString", "Ptr", HMENU, "UInt", ItemPos - 1, "Str", Str, "Int", 512
                                        , "UInt", 0x0400, "Int")
      Return Str
   Return ""
}
; ======================================================================================================================
; GetMenu         Retrieves a handle to the menu assigned to the specified window.
; Return values:  The return value is a handle to the menu.
;                 If the specified window has no menu, the return value is NULL.
;                 If the window is a child window, the return value is undefined.
; ======================================================================================================================
Menu_GetMenu(HWND) {
   ; http://msdn.microsoft.com/en-us/library/ms647640(v=vs.85).aspx
   Return DllCall("User32.dll\GetMenu", "Ptr", HWND, "Ptr")
}
; ======================================================================================================================
; GetMenuByName   Retrieves a handle to the menu specified by its name.
; Return values:  If the function succeeds, the return value is a handle to the menu.
;                 Otherwise, the return value is zero (False).
; Remarks:        Based on MI.ahk by Lexikos -> http://www.autohotkey.com/board/topic/20253-menu-icons-v2/
; ======================================================================================================================
Menu_GetMenuByName(MenuName) {
   Static HMENU := 0
   If !(HMENU) {
      Menu, %A_ThisFunc%Menu, Add
      Menu, %A_ThisFunc%Menu, DeleteAll
      Gui, %A_ThisFunc%GUI:+HwndHGUI
      Gui, %A_ThisFunc%GUI:Menu, %A_ThisFunc%Menu
      HMENU := Menu_GetMenu(HGUI)
      Gui, %A_ThisFunc%GUI:Menu
      Gui, %A_ThisFunc%GUI:Destroy
   }
   If !(HMENU)
      Return 0
   Menu, %A_ThisFunc%Menu, Add, :%MenuName%
   HSUBM := Menu_GetSubMenu(HMENU, 1)
   Menu, %A_ThisFunc%Menu, Delete, :%MenuName%
   Return HSUBM
}
; ======================================================================================================================
; GetSubMenu      Retrieves a handle to the submenu activated by the specified menu item.
; Return values:  If the function succeeds, the return value is a handle to the submenu activated by the menu item.
;                 If the menu item does not activate a submenu, the return value is zero (False).
; ======================================================================================================================
Menu_GetSubMenu(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647984(v=vs.85).aspx
   Return DllCall("User32.dll\GetSubMenu", "Ptr", HMENU, "Int", ItemPos - 1, "Ptr")
}
; ======================================================================================================================
; IsItemChecked   Determines whether the specified menu item is checked.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_IsItemChecked(HMENU, ItemPos) {
   Return (Menu_GetItemState(HMENU, ItemPos) & 0x08) ; MF_CHECKED = 0x00000008
}
; ======================================================================================================================
; IsSeparator     Determines whether the specified menu item  is a separator.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_IsSeparator(HMENU, ItemPos) {
   Return (Menu_GetItemInfo(HMENU, ItemPos).Type & 0x0800) ; MFT_SEPARATOR = 0x00000800
}
; ======================================================================================================================
; IsSubmenu       Determines whether the specified menu item opens a submenu.
; Return values:  If the function succeeds, the return value is a handle to the submenu; otherwise, it is zero (False).
; ======================================================================================================================
Menu_IsSubmenu(HMENU, ItemPos) {
   Return Menu_GetItemInfo(HMENU, ItemPos).HMENU
}
; ======================================================================================================================
; RemoveCheckMarks Removes the space reserved for check marks from the specified menu.
; Parameters:     ApplyToSubMenus   -  Settings apply to the menu and all of its submenus (True / False).
;                                      Default: True.
; Return value:   Always True.
; ======================================================================================================================
Menu_RemoveCheckMarks(HMENU, ApplyToSubMenus := True) {
   ; http://msdn.microsoft.com/en-us/library/ff468864(v=vs.85).aspx
   Static MIsize := (4 * 4) + (A_PtrSize * 3)
   VarSetCapacity(MI, MIsize, 0)
   NumPut(MIsize, MI, 0, "UInt")
   NumPut(0x00000010, MI, 4, "UInt") ; MIM_STYLE = 0x00000010
   DllCall("User32.dll\GetMenuInfo", "Ptr", HMENU, "Ptr", &MI, "UInt")
   If (ApplyToSubMenus)
      NumPut(0x80000010, MI, 4, "UInt") ; MIM_APPLYTOSUBMENUS = 0x80000000 | MIM_STYLE = 0x00000010
   NumPut(NumGet(MI, 8, "UINT") | 0x80000000, MI, 8, "UInt") ; MNS_NOCHECK = 0x80000000
   DllCall("User32.dll\SetMenuInfo", "Ptr", HMENU, "Ptr", &MI, "UInt")
   Return True
}
; ======================================================================================================================
; ShowAligned     Displays a shortcut menu at the specified location using the specified alignment.
; Parameters:     X     -  The horizontal location of the shortcut menu, in screen coordinates.
;                 Y     -  The vertical location of the shortcut menu, in screen coordinates.
;                 Align -  Array containing one or a more of the keys defined in 'Alignment'.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_ShowAligned(HMENU, HWND, X, Y, XAlign, YAlign) {
   ; http://msdn.microsoft.com/en-us/library/ms648002(v=vs.85).aspx
   Static XA := {0: 0, 4: 4, 8: 8, LEFT: 0x00, CENTER: 0x04, RIGHT: 0x08}
   Static YA := {0: 0, 16: 16, 32: 32, TOP: 0x00, VCENTER: 0x10, BOTTOM: 0x20}
   If !XA.HasKey(XAlign) || !YA.HasKey(YAlign)
      Return False
   Flags := XA[XAlign] | YA[YAlign]
   Return DllCall("User32.dll\TrackPopupMenu", "Ptr", HMENU, "UInt", Flags, "Int", X, "Int", Y, "Int", 0, "Ptr", HWND
                                             , "Ptr", 0, "UInt")
}
; ======================================================================================================================


not_Edit_InFocus(){
	Global Edit_Mode
	ControlGetFocus theFocus, A ; 取得目前活動窗口 的焦點之控件标识符
	return  !(inStr(theFocus , "Edit") or  (theFocus = "Scintilla1")   ;把查到是文字編輯卻不含Edit名的theFucus加進來
	or (theFocus ="DirectUIHWND1") or  (Edit_Mode = 1))
}
 
IME_GET(WinTitle=""){
	ifEqual WinTitle,,  SetEnv,WinTitle,A
	WinGet,hWnd,ID,%WinTitle%
	DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hWnd, Uint)
	;Message : WM_IME_CONTROL  wParam:IMC_GETOPENSTATUS
	DetectSave := A_DetectHiddenWindows
	DetectHiddenWindows,ON
	SendMessage 0x283, 0x005,0,,ahk_id %DefaultIMEWnd%
	DetectHiddenWindows,%DetectSave%
	Return ErrorLevel
}



GdipText(str1, str2:="", x:="", y:="", Font:="Microsoft YaHei UI"){
	static init:=0, Hidefg:=0, DPI:=A_ScreenDPI/96, MonCount:=1, MonLeft, MonTop, MonRight, MonBottom, MonInfo
		, MinLeft:=DllCall("GetSystemMetrics", "Int", 76), MinTop:=DllCall("GetSystemMetrics", "Int", 77)
		, MaxRight:=DllCall("GetSystemMetrics", "Int", 78), MaxBottom:=DllCall("GetSystemMetrics", "Int", 79)
		, xoffset:=10, yoffset:=10, hoffset:=15	; 左边、上边、编码词条间距离增量
		, MinWidth:=A_ScreenWidth/7.68			; 最小宽度
	global pToken, @TSF, srf_for_select_Array, srf_for_select_for_tooltip, Caret, FontCodeColor, Gdip_Line, LineColor
		, FontColor, BgColor, BorderColor, FontSize, FontStyle, LineColor, Radius, Gdip_Radius,FocusCodeColor
	If (x="Shutdown"){
		If (init){
			init:=0
			Gui, TSF: Destroy
		}
		If (pToken)
			pToken:=Gdip_Shutdown(pToken)
		Return
	} Else If (!init){
		Gui, TSF: -Caption +E0x8080088 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +hwnd@TSF
		Gui, TSF: Show, NA
		If !pToken&&(!pToken:=Gdip_Startup()){
			MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
			ExitApp
		}
		SysGet, MonCount, MonitorCount
		SysGet, Mon, Monitor
		init:=1
	}
	If (str1 str2=""){
		; If (!Hidefg){
		; 	Hidefg:=1
		; 	Gui, TSF:Hide
		; }
		hbm := CreateDIBSection(1, 1), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
		UpdateLayeredWindow(@TSF, hdc, 0, 0, 1, 1), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
		lasth:=0, lastw:=0, MonInfo:=""
		Return
	} Else {
		If (x="")||(y="")
			Return
		If !pToken&&(!pToken:=Gdip_Startup()){
			MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
			ExitApp
		}
	}
	; 识别扩展屏坐标范围
	x:=(x<MinLeft?MinLeft:x>MaxRight?MaxRight:x), y:=(y<MinTop?MinTop:y>MaxBottom?MaxBottom:y)
	If (MonCount>1&&MonInfo=""){
		If (MonInfo:=MDMF_GetInfo(MDMF_FromPoint(x,y))){
			MonLeft:=MonInfo.Left, MonTop:=MonInfo.Top, MonRight:=MonInfo.Right, MonBottom:=MonInfo.Bottom
		} Else {
			SysGet, Mon, Monitor
		}
	}
	; 计算界面长宽像素
	hbm := CreateDIBSection(1, 1), hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm), G := Gdip_GraphicsFromHDC(hdc)
	CreateRectF(RC, 0, 0, MonRight-MonLeft-20, MonBottom-MonTop)
	hFamily := Gdip_FontFamilyCreate(Font), hFont := Gdip_FontCreate(hFamily, FontSize*DPI, FontStyle)
	hFormat := Gdip_StringFormatCreate(0x4000)
	ReturnRC:=StrSplit(Gdip_MeasureString(G, str1 "`n" (str2?str2:" "), hFont, hFormat, RC), "|")
	Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	Width:=ReturnRC[3]+xoffset*2+15, Height:=ReturnRC[4]+yoffset*2+hoffset

	; 画候选界面
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm), G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetSmoothingMode(G, 2), pBrush := Gdip_BrushCreateSolid("0x" SubStr("FF" BgColor, -7))
	; 背景色
	Gdip_FillRoundedRectangle(G, pBrush, 0, 0, Width-2, Height-2, Radius~="i)on"?Gdip_Radius:0)
	; 编码
	ReturnRC:=StrSplit(Gdip_TextToGraphics(G, str1 (str1?"":" "), "x" xoffset " y" yoffset " c" SubStr("ff" FontCodeColor, -7) " s" FontSize*DPI (FontStyle~="i)on"?"Bold":""), Font, Width, Height),"|")
	ReturnRC[2]+=ReturnRC[4]
	; 候选
	Gdip_TextToGraphics(G, str2, "x" ReturnRC[1] " y" ReturnRC[2]+hoffset " c" SubStr("ff" FontColor, -7) " s" FontSize*DPI (FontStyle~="i)on"?" Bold":""), Font, Width, Height)

	; 边框
	pPen := Gdip_CreatePen("0x" SubStr("FF" BorderColor, -7), 1), Gdip_DrawRoundedRectangle(G, pPen, 0, 0, Width-2, Height-2, Radius~="i)on"?Gdip_Radius:0),gPen := Gdip_CreatePen("0x" SubStr("FF" LineColor, -7), 1)
	; 分隔线
	Gdip_Line ~="i)on"?(Gdip_DrawLine(G, gPen, 1, ReturnRC[2], Width-3, ReturnRC[2]), Gdip_DeletePen(gPen)):""
	; 更新界面
	UpdateLayeredWindow(@TSF, hdc, tx:=Min(x, Max(MonLeft, MonRight-Width-2)), ty:=Min(y, Max(MonTop, MonBottom-Height)), Width, Height)
	Gdip_DeleteGraphics(G), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteBrush(pBrush)
	WinSet, AlwaysOnTop, On, ahk_id%@TSF%
	If (tx>MonLeft+2)
		Caret.X:=tx
}

Gdip_MeasureString2(pGraphics, sString, hFont, hFormat, ByRef RectF){
	Ptr := A_PtrSize ? "UPtr" : "UInt", VarSetCapacity(RC, 16)
	DllCall("gdiplus\GdipMeasureString", Ptr, pGraphics, Ptr, &sString, "int", -1, Ptr, hFont, Ptr, &RectF, Ptr, hFormat, Ptr, &RC, "uint*", Chars, "uint*", Lines)
	return &RC ? [NumGet(RC, 0, "float"), NumGet(RC, 4, "float"), NumGet(RC, 8, "float"), NumGet(RC, 12, "float")] : 0
}

FocusGdipGui(codetext, Textobj, x:=0, y:=0, Font:="Microsoft YaHei UI"){
	Critical
	static init:=0, DPI:=A_ScreenDPI/96, MonCount:=1, MonLeft, MonTop, MonRight, MonBottom
		, MinLeft:=DllCall("GetSystemMetrics", "Int", 76), MinTop:=DllCall("GetSystemMetrics", "Int", 77)
		, MaxRight:=DllCall("GetSystemMetrics", "Int", 78), MaxBottom:=DllCall("GetSystemMetrics", "Int", 79)
		, xoffset, yoffset, hoffset  ; 左边、上边、编码词条间距离增量
		, fontoffset
	global BgColor, FontColor, FontCodeColor, BorderColor, FocusBackColor, FocusColor, FontSize, FontStyle, Textdirection, TPosObj
		, srf_for_select_Array, localpos,@TSF, srf_for_select_obj, Radius, Gdip_Radius, Gdip_Line, LineColor, Cut_Mode, ListNum
		,FocusRadius,FocusCodeColor, srf_all_Input

	If !IsObject(Textobj){
		If (Textobj="init"){
			If !pToken&&(!pToken:=Gdip_Startup()){
				MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
				ExitApp
			}
			Gui, TSF: -Caption +E0x8080088 +AlwaysOnTop +LastFound +hwnd@TSF -DPIScale
			Gui, TSF: Show, NA
			SysGet, MonCount, MonitorCount
			SysGet, Mon, Monitor
		} Else If (Textobj="shutdown"){
			If (pToken)
				pToken:=Gdip_Shutdown(pToken)
			Gui, TSF:Destroy
		} Else If (Textobj=""){
			hbm := CreateDIBSection(1, 1), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
			UpdateLayeredWindow(@TSF, hdc, 0, 0, 1, 1), SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
			init:=0
		}
		Return
	} Else If (!init){
		If !pToken&&(!pToken:=Gdip_Startup()){
			MsgBox, 48, GDIPlus Error!, GDIPlus failed to start. Please ensure you have gdiplus on your system, 5
			ExitApp
		}
		xoffset:=FontSize*0.45, yoffset:=FontSize/2.5, hoffset:=FontSize/3.2, init:=1, fontoffset:=FontSize/16

	} Else{
		x:=(x<MinLeft?MinLeft:x>MaxRight?MaxRight:x), y:=(y<MinTop?MinTop:y>MaxBottom?MaxBottom:y)
	}
	hFamily := Gdip_FontFamilyCreate(Font), hFont := Gdip_FontCreate(hFamily, FontSize*DPI, FontStyle~="i)on"?1:0)
	hFormat := Gdip_StringFormatCreate(0x4000), Gdip_SetStringFormatAlign(hFormat, 0), pBrush := []
	For key,value in ["Bg","FontCode","Font","Focus","FocusBack","FocusCode"]
		If (!pBrush[%value%])
			pBrush[%value%] := Gdip_BrushCreateSolid("0x" (%value% := SubStr("FF" %value%Color, -7)))

	pPen_Border := Gdip_CreatePen("0x" SubStr("FF" BorderColor, -7), 1)
	pPen_Line := Gdip_CreatePen("0x" SubStr("FF" LineColor, -7), 1)
	w:=MonRight-MonLeft, h:=MonBottom-MonTop
	; 计算界面长宽像素
	hbm := CreateDIBSection(1, 1), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	CreateRectF(RC, 0, 0, w-30, h-30), TPosObj:=[]
	CodePos := Gdip_MeasureString2(G, codetext, hFont, hFormat, RC), CodePos[1]:=xoffset
	, CodePos[2]:=yoffset, mh:=CodePos[2]+CodePos[4], mw:=CodePos[3]
	If Textdirection~="i)vertical" {
		mh+=hoffset
		Loop % Textobj.Length()
			TPosObj[A_Index] := Gdip_MeasureString2(G, Textobj[A_Index], hFont, hFormat, RC), TPosObj[A_Index,2]:=mh+FontSize*0.45
			, mh += TPosObj[A_Index,4]+FontSize*0.65, mw:=Max(mw,TPosObj[A_Index,3]), TPosObj[A_Index,1]:=CodePos[1]
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index] := Gdip_MeasureString2(G, Textobj[0,A_Index], hFont, hFormat, RC), TPosObj[0,A_Index,2]:=mh
			, mh += TPosObj[0,A_Index,4]+FontSize*0.45, mw:=Max(mw,TPosObj[0,A_Index,3]), TPosObj[0,A_Index,1]:=CodePos[1]
		Loop % Textobj.Length()
			TPosObj[A_Index,3]:=mw
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index,3]:=mw
		mw+=srf_all_Input~="\d+"?(strlen(srf_all_Input)>3?xoffset*2+strlen(srf_all_Input):xoffset*3.1):2.6*xoffset, mh+=2*yoffset
	} Else {
		t:=xoffset, mh+=hoffset
		TPosObj[1] := Gdip_MeasureString2(G, Textobj[1], hFont, hFormat, RC), TPosObj[1,2]:=mh, TPosObj[1,1]:=t, t+=TPosObj[1,3]+hoffset
		Loop % (Textobj.Length()-1){
			TPosObj[A_Index+1] := Gdip_MeasureString2(G, Textobj[A_Index+1], hFont, hFormat, RC)
			If (ListNum>5&&FontSize>18&&Cut_Mode~="on"&&objLength(srf_for_select_Array)>5||srf_all_Input~="/\d+"&&Strlen(srf_all_Input)>5)
				mw:=Max(mw,t), TPosObj[A_Index+1,1]:=xoffset, mh+=TPosObj[A_Index,4]+FontSize*0.45, TPosObj[A_Index+1,2]:=mh, t:=xoffset+TPosObj[A_Index+1,3]+hoffset
			else
				TPosObj[A_Index+1,1]:=srf_all_Input~="\d+"?t+FontSize:t+FontSize*0.5, TPosObj[A_Index+1,2]:=TPosObj[A_Index,2], t+=TPosObj[A_Index+1,3]+hoffset
		}
		mw:=Max(mw,t)+(srf_all_Input~="\d+"?FontSize*2:ObjLength(Textobj)>1?FontSize*0.5:0)
		mh+=TPosObj[TPosObj.Length(),4]*1.35     ;焦点框错位改这里
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index] := Gdip_MeasureString2(G, Textobj[0,A_Index], hFont, hFormat, RC), TPosObj[0,A_Index,1]:=xoffset, TPosObj[0,A_Index,2]:=mh, mh += TPosObj[0,A_Index,4], mw:=Max(mw,TPosObj[0,A_Index,3])
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index,3]:=mw
		mw+=xoffset, mh+=yoffset
	}
	GM:=Gdip_MeasureString2(G, codetext, hFont, hFormat, RC)
	SelectObject(hdc, obm), DeleteObject(hbm), Gdip_DeleteGraphics(G),mh:=mh+FontSize*0.2, mw:=mw>GM[3]+FontSize*0.45?(objCount(Textobj)?mw-FontSize*0.36+(srf_all_Input~="\d"?(Strlen(codetext)>1?Strlen(codetext)*2:Strlen(codetext)*5):Strlen(codetext)):mw):objCount(Textobj)?GM[3]+FontSize*DPI:GM[3]+FontSize*0.5
	hbm := CreateDIBSection(mw, mh), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetTextRenderingHint(G, 4)
	; 背景色
	Gdip_FillRoundedRectangle(G, pBrush[Bg], 0, 0, mw-2, mh-2, Radius~="i)on"?Gdip_Radius:0)
	; 编码
	if (Gdip_Line ~="i)off")
		Gdip_FillRoundedRectangle(G, pBrush[FocusCode], objCount(Textobj)?FontSize*0.32:FontSize*0.18, FontSize/3, objCount(Textobj)?GM[3]+FontSize*0.2:GM[3], GM[4], FocusRadius*0.6)
	CreateRectF(RC, Textobj.length()>0?CodePos[1]:CodePos[1]-FontSize/4, CodePos[2]-FontSize*0.05, w-30, h-30), Gdip_DrawString(G, codetext, hFont, hFormat, pBrush[FontCode], RC)
	Loop % Textobj.Length()
		If (A_Index=localpos){
			Gdip_FillRoundedRectangle(G, pBrush[FocusBack], TPosObj[A_Index,1]-FontSize*0.1, TPosObj[A_Index,2], srf_all_Input~="\d"?(Textdirection="vertical"?mw-FontSize:TPosObj[A_Index,3]+FontSize*0.35):TPosObj[A_Index,3], TPosObj[A_Index,4]+FontSize*0.65, FocusRadius)  ;焦点背景圆弧
			, CreateRectF(RC, srf_all_Input~="\d"?TPosObj[A_Index,1]:TPosObj[A_Index,1]-FontSize*0.35, TPosObj[A_Index,2]+fontoffset+FontSize*0.45, w-30, h-30), Gdip_DrawString(G, Textobj[A_Index], hFont, hFormat, pBrush[Focus], RC)
		}Else
			CreateRectF(RC, srf_all_Input~="\d"?TPosObj[A_Index,1]:TPosObj[A_Index,1]-FontSize*0.35, TPosObj[A_Index,2]+fontoffset+FontSize*0.45, w-30, h-30), Gdip_DrawString(G, Textobj[A_Index], hFont, hFormat, pBrush[Font], RC)
	Loop % Textobj[0].Length()
		CreateRectF(RC, TPosObj[0,A_Index,1], TPosObj[0,A_Index,2], w-30, h-30), Gdip_DrawString(G, Textobj[0,A_Index], hFont, hFormat, pBrush[Font], RC)

	; 边框、分隔线
	Gdip_DrawRoundedRectangle(G, pPen_Border, 0, 0, mw-2, mh-2, Radius~="i)on"?Gdip_Radius:0)
	Gdip_Line ~="i)on"&&objCount(Textobj)?(Gdip_DrawLine(G, pPen_Line, xoffset, CodePos[4]+CodePos[2], mw-xoffset*DPI, CodePos[4]+CodePos[2]), Gdip_DeletePen(pPen_Line)):""
	UpdateLayeredWindow(@TSF, hdc, tx:=mw>MaxRight?0:(x+mw>MaxRight?MaxRight-mw:x), ty:=mh>MaxBottom?0:(y+mh>MaxBottom?y-mh-35:(x+mw>MaxRight?y-mh-35<0?y:y-mh-35:y)), mw, mh)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont), Gdip_DeleteFontFamily(hFamily)
	For key,value in pBrush
		Gdip_DeleteBrush(value)
	Gdip_DeletePen(pPen_Border)
	WinSet, AlwaysOnTop, On, ahk_id%@TSF%
}

TSFCheckClickPos(X,Y){
	global TPosObj, Caret, @TSF
	WinGetPos, FX, FY, Width, Height, ahk_id %@TSF%
	Loop % TPosObj.Length()
	{
		if (X>TPosObj[A_Index,1]+FX&&X<TPosObj[A_Index,1]+FX+TPosObj[A_Index,3]&&Y>TPosObj[A_Index,2]+FY&&Y<TPosObj[A_Index,2]+FY+TPosObj[A_Index,4])
			Return A_Index
	}
}

; 作者: tmplinshi   ;返回汉字的拼音首字母
zh2py(str)
{
	; 根据汉字区位表,(http://www.mytju.com/classcode/tools/QuWeiMa_FullList.asp)
	; 我们可以看到从16-55区之间是按拼音字母排序的,所以我们只需要判断某个汉字的区位码就可以得知它的拼音首字母.

	; 区位表第一部份,按拼音字母排序的.
	; 16区-55区
	/*
		'A'=>0xB0A1, 'B'=>0xB0C5, 'C'=>0xB2C1, 'D'=>0xB4EE, 'E'=>0xB6EA, 'F'=>0xB7A2, 'G'=>0xB8C1,'H'=>0xB9FE,
		'J'=>0xBBF7, 'K'=>0xBFA6, 'L'=>0xC0AC, 'M'=>0xC2E8, 'N'=>0xC4C3, 'O'=>0xC5B6, 'P'=>0xC5BE,'Q'=>0xC6DA,
		'R'=>0xC8BB, 'S'=>0xC8F6, 'T'=>0xCBFA, 'W'=>0xCDDA, 'X'=>0xCEF4, 'Y'=>0xD1B9, 'Z'=>0xD4D1
	*/
	static FirstTable  := [ 0xB0C5, 0xB2C1, 0xB4EE, 0xB6EA, 0xB7A2, 0xB8C1, 0xB9FE, 0xBBF7, 0xBFA6, 0xC0AC, 0xC2E8
				, 0xC4C3, 0xC5B6, 0xC5BE, 0xC6DA, 0xC8BB, 0xC8F6, 0xCBFA, 0xCDDA, 0xCEF4, 0xD1B9, 0xD4D1, 0xD7FA ]
	static FirstLetter := StrSplit("ABCDEFGHJKLMNOPQRSTWXYZ")
	; 区位表第二部份,不规则的,下面的字母是每个区里面对应字的拼音首字母.从网上查询整理出来的,可能会有部份错误.
	; 56区-87区
	static SecondTable := [ StrSplit("CJWGNSPGCGNEGYPBTYYZDXYKYGTZJNMJQMBSGZSCYJSYYFPGKBZGYDYWJKGKLJSWKPJQHYJWRDZLSYMRYPYWWCCKZNKYYG")
				, StrSplit("TTNGJEYKKZYTCJNMCYLQLYPYSFQRPZSLWBTGKJFYXJWZLTBNCXJJJJTXDTTSQZYCDXXHGCKBPHFFSSTYBGMXLPBYLLBHLX")
				, StrSplit("SMZMYJHSOJNGHDZQYKLGJHSGQZHXQGKXZZWYSCSCJXYEYXADZPMDSSMZJZQJYZCJJFWQJBDZBXGZNZCPWHWXHQKMWFBPBY")
				, StrSplit("DTJZZKXHYLYGXFPTYJYYZPSZLFCHMQSHGMXXSXJYQDCSBBQBEFSJYHWWGZKPYLQBGLDLCDTNMAYDDKSSNGYCSGXLYZAYPN")
				, StrSplit("PTSDKDYLHGYMYLCXPYCJNDQJWXQXFYYFJLEJPZRXCCQWQQSBZKYMGPLBMJRQCFLNYMYQMSQYRBCJTHZTQFRXQHXMQJCJLY")
				, StrSplit("QGJMSHZKBSWYEMYLTXFSYDXWLYCJQXSJNQBSCTYHBFTDCYZDJWYGHQFRXWCKQKXEBPTLPXJZSRMEBWHJLBJSLYYSMDXLCL")
				, StrSplit("QKXLHXJRZJMFQHXHWYWSBHTRXXGLHQHFNMGYKLDYXZPYLGGSMTCFBAJJZYLJTYANJGBJPLQGSZYQYAXBKYSECJSZNSLYZH")
				, StrSplit("ZXLZCGHPXZHZNYTDSBCJKDLZAYFFYDLEBBGQYZKXGLDNDNYSKJSHDLYXBCGHXYPKDJMMZNGMMCLGWZSZXZJFZNMLZZTHCS")
				, StrSplit("YDBDLLSCDDNLKJYKJSYCJLKWHQASDKNHCSGAGHDAASHTCPLCPQYBSZMPJLPCJOQLCDHJJYSPRCHNWJNLHLYYQYYWZPTCZG")
				, StrSplit("WWMZFFJQQQQYXACLBHKDJXDGMMYDJXZLLSYGXGKJRYWZWYCLZMSSJZLDBYDCFCXYHLXCHYZJQSQQAGMNYXPFRKSSBJLYXY")
				, StrSplit("SYGLNSCMHCWWMNZJJLXXHCHSYZSTTXRYCYXBYHCSMXJSZNPWGPXXTAYBGAJCXLYXDCCWZOCWKCCSBNHCPDYZNFCYYTYCKX")
				, StrSplit("KYBSQKKYTQQXFCMCHCYKELZQBSQYJQCCLMTHSYWHMKTLKJLYCXWHEQQHTQKZPQSQSCFYMMDMGBWHWLGSLLYSDLMLXPTHMJ")
				, StrSplit("HWLJZYHZJXKTXJLHXRSWLWZJCBXMHZQXSDZPSGFCSGLSXYMJSHXPJXWMYQKSMYPLRTHBXFTPMHYXLCHLHLZYLXGSSSSTCL")
				, StrSplit("SLDCLRPBHZHXYYFHBMGDMYCNQQWLQHJJCYWJZYEJJDHPBLQXTQKWHLCHQXAGTLXLJXMSLJHTZKZJECXJCJNMFBYCSFYWYB")
				, StrSplit("JZGNYSDZSQYRSLJPCLPWXSDWEJBJCBCNAYTWGMPAPCLYQPCLZXSBNMSGGFNZJJBZSFZYNTXHPLQKZCZWALSBCZJXSYZGWK")
				, StrSplit("YPSGXFZFCDKHJGXTLQFSGDSLQWZKXTMHSBGZMJZRGLYJBPMLMSXLZJQQHZYJCZYDJWFMJKLDDPMJEGXYHYLXHLQYQHKYCW")
				, StrSplit("CJMYYXNATJHYCCXZPCQLBZWWYTWBQCMLPMYRJCCCXFPZNZZLJPLXXYZTZLGDLTCKLYRZZGQTTJHHHJLJAXFGFJZSLCFDQZ")
				, StrSplit("LCLGJDJZSNZLLJPJQDCCLCJXMYZFTSXGCGSBRZXJQQCTZHGYQTJQQLZXJYLYLBCYAMCSTYLPDJBYREGKLZYZHLYSZQLZNW")
				, StrSplit("CZCLLWJQJJJKDGJZOLBBZPPGLGHTGZXYGHZMYCNQSYCYHBHGXKAMTXYXNBSKYZZGJZLQJTFCJXDYGJQJJPMGWGJJJPKQSB")
				, StrSplit("GBMMCJSSCLPQPDXCDYYKYPCJDDYYGYWRHJRTGZNYQLDKLJSZZGZQZJGDYKSHPZMTLCPWNJYFYZDJCNMWESCYGLBTZZGMSS")
				, StrSplit("LLYXYSXXBSJSBBSGGHFJLYPMZJNLYYWDQSHZXTYYWHMCYHYWDBXBTLMSYYYFSXJCBDXXLHJHFSSXZQHFZMZCZTQCXZXRTT")
				, StrSplit("DJHNRYZQQMTQDMMGNYDXMJGDXCDYZBFFALLZTDLTFXMXQZDNGWQDBDCZJDXBZGSQQDDJCMBKZFFXMKDMDSYYSZCMLJDSYN")
				, StrSplit("SPRSKMKMPCKLGTBQTFZSWTFGGLYPLLJZHGJJGYPZLTCSMCNBTJBQFKDHBYZGKPBBYMTDSSXTBNPDKLEYCJNYCDYKZTDHQH")
				, StrSplit("SYZSCTARLLTKZLGECLLKJLQJAQNBDKKGHPJTZQKSECSHALQFMMGJNLYJBBTMLYZXDXJPLDLPCQDHZYCBZSCZBZMSLJFLKR")
				, StrSplit("ZJSNFRGJHXPDHYJYBZGDLQCSEZGXLBLGYXTWMABCHECMWYJYZLLJJYHLGNDJLSLYGKDZPZXJYYZLWCXSZFGWYYDLYHCLJS")
				, StrSplit("CMBJHBLYZLYCBLYDPDQYSXQZBYTDKYXJYYCNRJMPDJGKLCLJBCTBJDDBBLBLCZQRPYXJCJLZCSHLTOLJNMDDDLNGKATHQH")
				, StrSplit("JHYKHEZNMSHRPHQQJCHGMFPRXHJGDYCHGHLYRZQLCYQJNZSQTKQJYMSZSWLCFQQQXYFGGYPTQWLMCRNFKKFSYYLQBMQAMM")
				, StrSplit("MYXCTPSHCPTXXZZSMPHPSHMCLMLDQFYQXSZYJDJJZZHQPDSZGLSTJBCKBXYQZJSGPSXQZQZRQTBDKYXZKHHGFLBCSMDLDG")
				, StrSplit("DZDBLZYYCXNNCSYBZBFGLZZXSWMSCCMQNJQSBDQSJTXXMBLTXZCLZSHZCXRQJGJYLXZFJPHYMZQQYDFQJJLZZNZJCDGZYG")
				, StrSplit("CTXMZYSCTLKPHTXHTLBJXJLXSCDQXCBBTJFQZFSLTJBTKQBXXJJLJCHCZDBZJDCZJDCPRNPQCJPFCZLCLZXZDMXMPHJSGZ")
				, StrSplit("GSZZQLYLWTJPFSYASMCJBTZYYCWMYTZSJJLJCQLWZMALBXYFBPNLSFHTGJWEJJXXGLLJSTGSHJQLZFKCGNNNSZFDEQFHBS")
				, StrSplit("AQTGYLBXMMYGSZLDYDQMJJRGBJTKGDHGKBLQKBDMBYLXWCXYTTYBKMRTJZXQJBHLMHMJJZMQASLDCYXYQDLQCAFYWYXQHZ") ]


	static nothing := VarSetCapacity(var, 2)
	; 如果不包含中文字符，则直接返回原字符
	if not RegExMatch(str,"[^x00-xff]")
		return str
	;if ( Asc(str) < 0x2E80 or Asc(str) > 0x9FFF )
	;	Return str
	Loop, Parse, str
	{
		StrPut(A_LoopField, &var, "CP936")
		H := NumGet(var, 0, "UChar")
		L := NumGet(var, 1, "UChar")
		; 字符集非法
		if (H < 0xB0 || L < 0xA1 || H > 0xF7 || L = 0xFF)
		{
			newStr .= A_LoopField
			Continue
		}
		if (H < 0xD8)//(H >= 0xB0 && H <=0xD7) ; 查询文字在一级汉字区(16-55)
		{
			W := (H << 8) | L
			For key, value in FirstTable
			{
				if (W < value)
				{
					newStr .= FirstLetter[key]
					Break
				}
			}
		}
		else ; if (H >= 0xD8 && H <= 0xF7) ; 查询中文在二级汉字区(56-87)
			newStr .= SecondTable[ H - 0xD8 + 1 ][ L - 0xA1 + 1 ]
	}
	Return newStr
}

; 功能: 中文转为拼音首字母，非中文保持不变
; 备注: 在 AutoHotkey Unicode版中运行
GetFirstChar(str){
	static nothing := VarSetCapacity(var, 2)
	static array   := [ [-20319,-20284,"A"], [-20283,-19776,"B"], [-19775,-19219,"C"], [-19218,-18711,"D"], [-18710,-18527,"E"], [-18526,-18240,"F"], [-18239,-17923,"G"], [-17922,-17418,"H"], [-17417,-16475,"J"], [-16474,-16213,"K"], [-16212,-15641,"L"], [-15640,-15166,"M"], [-15165,-14923,"N"], [-14922,-14915,"O"], [-14914,-14631,"P"], [-14630,-14150,"Q"], [-14149,-14091,"R"], [-14090,-13319,"S"], [-13318,-12839,"T"], [-12838,-12557,"W"], [-12556,-11848,"X"], [-11847,-11056,"Y"], [-11055,-10247,"Z"] ]
	
	; 如果不包含中文字符，则直接返回原字符
	if !RegExMatch(str, "[^\x{00}-\x{ff}]")
		Return str

	Loop, Parse, str
	{
		if ( Asc(A_LoopField) >= 0x2E80 and Asc(A_LoopField) <= 0x9FFF )
		{
			StrPut(A_LoopField, &var, "CP936")
			nGBKCode := (NumGet(var, 0, "UChar") << 8) + NumGet(var, 1, "UChar") - 65536

			For i, a in array
				if nGBKCode between % a.1 and % a.2
				{
					out .= a.3
					Break
				}
		}
		else
			out .= A_LoopField
	}

	Return out
}

;{{{; 来自万年书妖的Candy里的函数，用于转换为url编码
SksSub_UrlEncode(string, enc="UTF-8") {   ;url编码
	enc:=trim(enc)
	If (enc="")
		Return string
	If Strlen(String) > 200
		string := Substr(string,1,200)
	formatInteger := A_FormatInteger
	SetFormat, IntegerFast, H
	VarSetCapacity(buff, StrPut(string, enc))
	Loop % StrPut(string, &buff, enc) - 1
	{
		byte := NumGet(buff, A_Index-1, "UChar")
		encoded .= byte > 127 or byte <33 ? "%" Substr(byte, 3) : Chr(byte)
	}
	SetFormat, IntegerFast, %formatInteger%
	return encoded
}

; 正常字符转为Unicode编码
;可以識別雙字節
Char2Unicode(cnStr){
	OldFormat := A_FormatInteger, count:=0
	SetFormat, Integer, Hex
	Loop, % strlen(cnStr)
	{
		If (cnStr~=chr("0x" SubStr( Asc(SubStr(cnStr,A_index-count,2)), 3 )))
			FieldChar:= SubStr(cnStr,A_index-count,2),count+1
		else
			FieldChar:= SubStr(cnStr,A_index-count,1)
		out .= "0x" . SubStr( Asc(FieldChar), 3 ) "|"
	}
	SetFormat, Integer, %OldFormat%
	Return RegExReplace(out,"\|$")
}

;可以識別雙字節
Char2Unicode_2(cnStr){
	OldFormat := A_FormatInteger, count:=0
	SetFormat, Integer, Hex
	Loop, % strlen(cnStr)
	{
		If (cnStr~=chr("0x" SubStr( Asc(SubStr(cnStr,A_index-count,2)), 3 )))
			FieldChar:= SubStr(cnStr,A_index-count,2),count+1
		else
			FieldChar:= SubStr(cnStr,A_index-count,1)
		out .= "\u" . SubStr( Asc(FieldChar), 3 )
	}
	SetFormat, Integer, %OldFormat%
	Return out
}

/*
Char2Unicode_2(cnStr){
	OldFormat := A_FormatInteger
	SetFormat, Integer, Hex
	Loop, Parse, cnStr
		out .= "\u" . SubStr( Asc(A_LoopField), 3 )
	SetFormat, Integer, %OldFormat%
	Return out
}
*/
;==================================================

;note: a 'UTF-8 ini file' will need a comment as the first line
;e.g. ';my comment'
JEE_IniReadUtf8(vPath, vSection:="", vKey:="", vDefault:="")
{
	local vOutput
	vSection := JEE_StrTextToUtf8Bytes(vSection)
	vKey := JEE_StrTextToUtf8Bytes(vKey)
	IniRead, vOutput, % vPath, % vSection, % vKey, % vDefault
	if !ErrorLevel
		return JEE_StrUtf8BytesToText(vOutput)
}

;==================================================

JEE_IniWriteUtf8(vValue, vPath, vSection, vKey:="")
{
	vSection := JEE_StrTextToUtf8Bytes(vSection)
	vKey := JEE_StrTextToUtf8Bytes(vKey)
	vValue := JEE_StrTextToUtf8Bytes(vValue)
	IniWrite, % vValue, % vPath, % vSection, % vKey
	return !ErrorLevel
}

;==================================================

JEE_IniDeleteUtf8(vPath, vSection, vKey:="")
{
	vSection := JEE_StrTextToUtf8Bytes(vSection)
	vKey := JEE_StrTextToUtf8Bytes(vKey)
	IniDelete, % vPath, % vSection, % vKey
	return !ErrorLevel
}

;==================================================

JEE_StrUtf8BytesToText(vUtf8)
{
	if A_IsUnicode
	{
		VarSetCapacity(vUtf8X, StrPut(vUtf8, "CP0"))
		StrPut(vUtf8, &vUtf8X, "CP0")
		return StrGet(&vUtf8X, "UTF-8")
	}
	else
		return StrGet(&vUtf8, "UTF-8")
}

ConvertUtf8(string)
{
	var := "x"
	; Ensure capacity.
	len := StrPut(string, "UTF-8")    
	VarSetCapacity( var, len)
	; convert the string.
	StrPut(string, &var, len, "UTF-8")
	return StrGet(&var, len, "CP1252")        
}

StrPutVar(string, ByRef var, encoding)
{
	VarSetCapacity( var, StrPut(string, encoding) * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
	return StrPut(string, &var, encoding)
}
;==================================================

JEE_StrTextToUtf8Bytes(vText)
{
	VarSetCapacity(vUtf8, StrPut(vText, "UTF-8"))
	StrPut(vText, &vUtf8, "UTF-8")
	return StrGet(&vUtf8, "CP0")
}

; Unicode编码转正常字符
Unicode2Char(Unicode){
	Loop, Parse, Unicode, u, \
		retStr .= Chr("0x" . A_LoopField) ;为字符串添加16进制前缀。字符=Chr(编码)。
	return retStr
}

WindowProc(hwnd, uMsg, wParam, lParam)
{
	Critical
	global TextBackgroundColor, TipBackgroundBrush, WindowProcOld
	if (uMsg = 0x138 && lParam = A_EventInfo)  ; 0x138 为 WM_CTLCOLORSTATIC.
	{
		DllCall("SetBkColor", Ptr, wParam, UInt, TextBackgroundColor)
		return TipBackgroundBrush  ; 返回 HBRUSH 来通知操作系统我们改变了 HDC.
	}
	; 否则 (如果上面没有返回), 传递所有的未处理事件到原来的 WindowProc.
	return DllCall("CallWindowProc", Ptr, WindowProcOld, Ptr, hwnd, UInt, uMsg, Ptr, wParam, Ptr, lParam)
}

SetSystemCursor( Cursor = "", cx = 0, cy = 0 )
{
	BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init
	
	SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
	,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
	,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
	,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP
	
	If Cursor = ; empty, so create blank cursor 
	{
		VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
		BlankCursor = 1 ; flag for later
	}
	Else If SubStr( Cursor,1,4 ) = "IDC_" ; load system cursor
	{
		Loop, Parse, SystemCursors, `,
		{
			CursorName := SubStr( A_Loopfield, 6, 15 ) ; get the cursor name, no trailing space with substr
			CursorID := SubStr( A_Loopfield, 1, 5 ) ; get the cursor id
			SystemCursor = 1
			If ( CursorName = Cursor )
			{
				CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )	
				Break					
			}
		}	
		If CursorHandle = ; invalid cursor name given
		{
			Msgbox,, SetCursor, Error: Invalid cursor name
			CursorHandle = Error
		}
	}	
	Else If FileExist( Cursor )
	{
		SplitPath, Cursor,,, Ext ; auto-detect type
		If Ext = ico 
			uType := 0x1	
		Else If Ext in cur,ani
			uType := 0x2		
		Else ; invalid file ext
		{
			Msgbox,, SetCursor, Error: Invalid file type
			CursorHandle = Error
		}		
		FileCursor = 1
	}
	Else
	{	
		Msgbox,, SetCursor, Error: Invalid file path or cursor name
		CursorHandle = Error ; raise for later
	}
	If CursorHandle != Error 
	{
		Loop, Parse, SystemCursors, `,
		{
			If BlankCursor = 1 
			{
				Type = BlankCursor
				%Type%%A_Index% := DllCall( "CreateCursor"
				, Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
				CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
				DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
			}			
			Else If SystemCursor = 1
			{
				Type = SystemCursor
				CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )	
				%Type%%A_Index% := DllCall( "CopyImage"
				, Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )		
				CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
				DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
			}
			Else If FileCursor = 1
			{
				Type = FileCursor
				%Type%%A_Index% := DllCall( "LoadImageA"
				, UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 ) 
				DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )			
			}          
		}
	}	
}

RestoreCursors()
{
	SPI_SETCURSORS := 0x57
	DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
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

CheckWubiVersion(DB){
	WbType:={}
	for section,element in ["ci","zi","chaoji"]
	{
		for key,Value in {trff:"86",cffy:"98",tffy:"新世纪"}
		{
			DB.gettable("Select aim_chars From " element " where A_Key ='" key "';",result)
			If Array_isInValue(result.Rows,Chr(0x7279))
				WbType[element]:=Value
		}
	}
	return WbType
}

;1:elevated
;0:not elevated
;-1:error (probably elevated)
; From https://autohotkey.com/boards/viewtopic.php?p=197426#p197426
ProcessIsElevated(vPID)
{
	;PROCESS_QUERY_LIMITED_INFORMATION := 0x1000
	if !(hProc := DllCall("kernel32\OpenProcess", "UInt",0x1000, "Int",0, "UInt",vPID, "Ptr"))
		return -1
	;TOKEN_QUERY := 0x8
	hToken := 0
	if !(DllCall("advapi32\OpenProcessToken", "Ptr",hProc, "UInt",0x8, "Ptr*",hToken))
	{
		DllCall("kernel32\CloseHandle", "Ptr",hProc)
		return -1
	}
	;TokenElevation := 20
	vIsElevated := vSize := 0
	vRet := (DllCall("advapi32\GetTokenInformation", "Ptr",hToken, "Int",20, "UInt*",vIsElevated, "UInt",4, "UInt*",vSize))
	DllCall("kernel32\CloseHandle", "Ptr",hToken)
	DllCall("kernel32\CloseHandle", "Ptr",hProc)
	return vRet ? vIsElevated : -1
}

RegistryFile(flag:=""){
	;If (flag<>"AutohotkeyScript") {
		localPath:=RegExreplace(A_ahkpath,"\\","\\")
		Regtext =
		(
			Windows Registry Editor Version 5.00
			`n`[-HKEY_CLASSES_ROOT`\.ahk`]
			`[-HKEY_CLASSES_ROOT`\AhkScript`]
			`~
			`[HKEY_CLASSES_ROOT`\.ahk`]
			`@`=`"AhkScript`"
			`n`[HKEY_CLASSES_ROOT`\.Ahk`\ShellNew`]
			`"NullFile`"`=`"`"
			`"FileName`"`=`"AutoHotkey脚本.ahk`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`]
			`@`=`"AhkScript`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`\DefaultIcon`]
			`@`=`"`@`%SystemRoot`%`\`\system32`\`\shell32.dll,72`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`\Shell`]
			`@`=`"Open`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`\Shell`\Edit`]
			`@`=`"编辑脚本`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`\Shell`\Edit`\Command`]
			`@`=`"notepad.exe `%1`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`\Shell`\Open`]
			`@`=`"运行脚本`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`\Shell`\Open`\Command`]
			`@=`"`\`"%localPath%`\`" `\`"`%1`\`" `%`*`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`\Shell`\RunAs`]
			`"HasLUAShield`"`=`"`"
			`n`[HKEY_CLASSES_ROOT`\AhkScript`\Shell`\RunAs`\Command`]
			`@`=`"`\`"%localPath%`\`" `\`"`%1`\`" `%`*`"
		)
		FileDelete,Sync\ahk关联启动.Reg
		Regtext:=RegExreplace(Regtext, "\t")
		FileAppend ,%Regtext%,Sync\ahk关联启动.Reg,CP936
	;}
}

GetFontNamesFromFile(FontFilePath) {
	; www.microsoft.com/en-us/Typography/SpecificationsOverview.aspx
	; .otf -> www.microsoft.com/typography/otspec/otff.htm
	; Platform ID: 0: Apple Unicode, 1: Macintosh, 2: ISO, 3: Microsoft}
	; Name ID: 1: family name, 2: subfamily name (style), 4: full name}
	If !(Font := FileOpen(FontFilePath, "r")) {
		MSgBox, 16, %A_ThisFunc%, Error: %A_LastError%`n`nCould not open the file`n%FontFilePath%!
		Return ""
	}
	Font.Pos += 4
	NumTables := ReadUShortBE(Font)
	NameTableOffset := 0
	Font.Pos := 12 ; start of table entries
	NextTableEntry := Font.Pos
	Loop, %NumTables% {
		Font.Pos := NextTableEntry
		NextTableEntry += 16 ; size of a table entry
		Font.RawRead(TableName, 4)
		Name := StrGet(&TableName, 4, "CP0")
		If (Name <> "name")
			Continue
		Font.Pos += 4 ; skip the checkSum field
		NameTableOffset := ReadULongBE(Font)
	} Until (NameTableOffset <> 0)
	If (NameTableOffset = 0) { ; should not happen because the 'name' table is required
		MsgBox, 16, %A_ThisFunc%, Error:`n`nDidn't find the 'name' table entry!
		Return ""
	}
	Font.Pos := NameTableOffset
	If (ReadUShortBE(Font) <> 0) { ; format selector must be 0
		MsgBox, 16, %A_ThisFunc%, Error:`n`nInvalid 'name' table!
		Return ""
	}
	NumOfEntries := ReadUShortBE(Font)
	StorageOffset := ReadUShortBE(Font)
	Names := []
	LCSub := []
	LCFull := []
	LCID := 0
	SysLanguage := "0x" . A_Language
	NextTableEntry := Font.pos
	Loop, %NumOfEntries% {
		Font.Pos := NextTableEntry
		NextTableEntry += 12 ; length of a name table entry
		PlatformID := ReadUShortBE(Font)
		If (PlatformID <> 3)
			Continue
		EncodingID := ReadUShortBE(Font)
		LanguageID := ReadUShortBE(Font)
		NameID := ReadUShortBE(Font)
		If NameID In 1,2,4
		{
			StrLength := ReadUShortBE(Font)
			If (StrLength = 0)
				Continue
			StrOffset := ReadUShortBE(Font)
			Font.Pos := NameTableOffset + StorageOffset + StrOffset
			Name := ReadUTF16BE(Font, StrLength // 2)
			If (NameID = 1) && ((LanguageID = SysLanguage) || (LanguageID = 1033)) {
				LCID := LanguageID
				Names["Family"] := Name
			}
			Else If (NameID = 4)
				LCFull[LanguageID] := Name
			Else
				LCSub[LanguageID] := Name
		}
	}
	Font.Close()
	If (LCID) {
		If (Name := LCSub[SysLanguage])
			Names["Style"] := Name
		Else
			Names["Style"] := LCSub[LCID]
		If (Name := LCFull[SysLanguage])
			Names["FullName"] := Name
		Else
			Names["FullName"] := LCFull[LCID]
	}
	Return Names.HasKey("Family") ? Names : ""
}

; Auxiliary functions used because .ttf files are encoded in Motorola (big endian) format
ReadUShortBE(Handle) {
	Return (Handle.ReadUChar() << 8) | Handle.ReadUchar()
}

ReadULongBE(Handle) {
	Return (Handle.ReadUChar() << 24) | (Handle.ReadUChar() << 16) | (Handle.ReadUChar() << 8) | Handle.ReadUChar()
}

ReadUTF16BE(Handle, Characters) { ; Characters - the maximum number of characters to read
	Bytes := Characters * 2
	VarSetCapacity(UTF16, Bytes, 0)
	Addr := &UTF16
	MaxAddr := Addr + Bytes
	While (Addr < MaxAddr)
		Addr := NumPut(ReadUShortBE(Handle), Addr + 0, "UShort")
	Return StrGet(&UTF16, Characters, "UTF-16")
}

;载入字体
AddFontResource(FontPath){
	If FileExist(FontPath){
		DllCall("GDI32.DLL\AddFontResource", str, FontPath)
		PostMessage, 0x1D,,,, ahk_id 0xFFFF
		return 1
	}
}
;移除字体
RemoveFontResource(FontPath){
	DllCall("GDI32.DLL\RemoveFontResource", Str, FontPath)
	PostMessage, 0x1D,,,, ahk_id 0xFFFF
}

Encode(Str, Encoding, Separator = "")
{
	StrCap := StrPut(Str, Encoding)
	VarSetCapacity(ObjStr, StrCap)
	StrPut(Str, &ObjStr, Encoding)
	Loop, % StrCap - 1
	{
		ObjCodes .= Separator . SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
	}
	Return, ObjCodes
}

CountLines(file){ 
	If not file~="`n"
		FileRead, Text, %file%
	else
		Text:=file
	StringReplace, Text, Text, `n, `n, UseErrorLevel
	Text:=""
	Return ErrorLevel + 1
}

GetVersion(URL,Charset="",Timeout=-1)
{
	ComObjError(0)
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("GET", URL, true)
	WebRequest.Send()
	WebRequest.WaitForResponse(Timeout)
	if (Charset=""){
		RegExMatch(WebRequest.ResponseText(), "20[2-3][0-5][0-9]{6}", UpdateVersion)
		return,UpdateVersion
	}else{
		ADO:=ComObjCreate("adodb.stream"), ADO.Type:=1, ADO.Mode:=3
		ADO.Open(), ADO.Write(WebRequest.ResponseBody())
		ADO.Position:=0, ADO.Type:=2, ADO.Charset:=Charset
		RegExMatch(WebRequest.ResponseText(), "20[2-3][0-5][0-9]{6}", UpdateVersion)
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
			Run, "https://github.com/OnchiuLee/AHK-Input-method",, UseErrorLevel
			if (ErrorLevel = "ERROR") {
				Traytip,, 您的电脑未设定默认浏览器！,,3
			}
			TrayTip,,下载超时！,,1
			Return 0
		}
		If !WebRequest.ResponseBody() {
			Progress, Off
			Traytip,,下载失败！,,3
			Return 0
		}
		ADO:=ComObjCreate("adodb.stream"), ADO.Type:=1, ADO.Mode:=3, ADO.Open()
		Try ADO.Write(WebRequest.ResponseBody())
		Try ADO.SaveToFile(A_Desktop "\" FilePath,2)
		ADO.Close(), WebRequest:=ADO:=""
		Progress, Off
		TrayTip,下载成功,文件%FilePath%在电脑桌面请解压更新！,,1
		Return 1
	} Else{
		Progress, Off
		Traytip,,下载失败！,,3
		Return 0
	}
}

MoveProgress() {
	PostMessage, 0xA1, 2 
}

LV_SubitemHitTest(HLV) {
	; To run this with AHK_Basic change all DllCall types "Ptr" to "UInt", please.
	; HLV - ListView's HWND
	Static LVM_SUBITEMHITTEST := 0x1039
	VarSetCapacity(POINT, 8, 0)
	; Get the current cursor position in screen coordinates
	DllCall("User32.dll\GetCursorPos", "Ptr", &POINT)
	; Convert them to client coordinates related to the ListView
	DllCall("User32.dll\ScreenToClient", "Ptr", HLV, "Ptr", &POINT)
	; Create a LVHITTESTINFO structure (see below)
	VarSetCapacity(LVHITTESTINFO, 24, 0)
	; Store the relative mouse coordinates
	NumPut(NumGet(POINT, 0, "Int"), LVHITTESTINFO, 0, "Int")
	NumPut(NumGet(POINT, 4, "Int"), LVHITTESTINFO, 4, "Int")
	; Send a LVM_SUBITEMHITTEST to the ListView
	SendMessage, LVM_SUBITEMHITTEST, 0, &LVHITTESTINFO, , ahk_id %HLV%
	; If no item was found on this position, the return value is -1
	If (ErrorLevel = -1)
		Return 0
	; Get the corresponding subitem (column)
	Subitem := NumGet(LVHITTESTINFO, 16, "Int") + 1
	Return Subitem
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

;;source-解压目录压缩包,outdir-输出目录，为空则为当前目录,Path-7za.exe文件路径,password-解压密码
Un7Zip(source,outdir="",Path="Config\Tools\7za.exe",password=""){
	outdir:=outdir?outdir:A_ScriptDir "\"
	If !FileExist(Path)
		return 7z_error( "null" )
	password:=password?"-p" password:""
	Runwait, "%path%" x "%source%" -o"%outdir%" %password% -y ,,Hide UseErrorLevel
	return 7z_error(ErrorLevel )
}

;;PackName-压缩包名, Path-7za.exe文件路径 ,files-需要压缩的文件或文件集合，多文件以数组参数,password-压缩密码
7z_compress(PackName ,files="", Path="Config\Tools\7za.exe" ,password="") {
	If len:=objCount(arr:=files)
		loop,% len
			files.=A_Space """" arr[A_Index] """"
	if FileExist(PackName)
		FileDelete, %PackName%
	password:=password?"-p" password:""
	RunWait, %Path% a -t7z "%PackName%" %files% -r -mx9 -slp -m0=LZMA2 -ms=200m -mmt=8 -mhc -mf %password% r,,Hide UseErrorLevel
	return 7z_error(ErrorLevel)
}

7z_error(e) {
	if (e==1)
		MsgBox, 262160, 错误警告,  警告（非致命错误）。例如，某些文件正在被使用，因此无法进行压缩操作。
	else if (e==2)
		MsgBox, 262160, 错误警告,  致命错误！例如，压缩包/文件路径不存在。
	else if (e==7)
		MsgBox, 262160, 错误警告,  命令行错误！
	else if (e==8)
		MsgBox, 262160, 错误警告,  内存不足，无法进行操作！
	else if (e==255)
		MsgBox, 262160, 错误警告,  已停止进程！
	else if (e="null")
		MsgBox, 262160, 错误警告,  7za.exe文件不存在！
	return e
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

GetCharsSize(List, Font:="", FontSize:=10, Padding:=6)
{
	Loop, Parse, List, |
	{
		if Font
			Gui DropDownSize:Font, s%FontSize%, %Font%
		Gui DropDownSize:Add, Text, R1, %A_LoopField%
		GuiControlGet T, DropDownSize:Pos, Static1
		Gui DropDownSize:Destroy
		TW > X ? X := TW :
	}
	return "w" X + Padding
}

HexToRGB(Color, Mode="") ; Input: 6 characters HEX-color. Mode can be RGB, Message (R: x, G: y, B: z) or parse (R,G,B)
{
	; If df, d is *16 and f is *1. Thus, Rx = R*16 while Rn = R*1
	Rx := SubStr(Color, 1,1), Rn := SubStr(Color, 2,1)
	Gx := SubStr(Color, 3,1), Gn := SubStr(Color, 4,1)
	Bx := SubStr(Color, 5,1), Bn := SubStr(Color, 6,1)
	AllVars := "Rx|Rn|Gx|Gn|Bx|Bn"
	Loop, Parse, Allvars, | ; Add the Hex values (A - F)
	{
		StringReplace, %A_LoopField%, %A_LoopField%, a, 10
		StringReplace, %A_LoopField%, %A_LoopField%, b, 11
		StringReplace, %A_LoopField%, %A_LoopField%, c, 12
		StringReplace, %A_LoopField%, %A_LoopField%, d, 13
		StringReplace, %A_LoopField%, %A_LoopField%, e, 14
		StringReplace, %A_LoopField%, %A_LoopField%, f, 15
	}
	R := Rx*16+Rn, G := Gx*16+Gn, B := Bx*16+Bn
	If (Mode = "Message") ; Returns "R: 255 G: 255 B: 255"
		Out := "R:" . R . " G:" . G . " B:" . B
	else if (Mode = "Parse") ; Returns "255,255,255"
		Out := R . "," . G . "," . B
	else
		Out := R . G . B ; Returns 255255255
	return Out
}

GetEtymologyPhrase(DB){
	DB.gettable("SELECT * FROM EtymologyChr;",Result)
	startTime:= CheckTickCount(), totalCount:=Result.RowCount, num:=Ceil(totalCount/100)
	,resultObj:={}, Phrase:=[],count:=0
	Progress, M1 Y10 FM14 W350, 1/%totalCount%, 拆分码表处理中..., 1`%
	OnMessage(0x201, "MoveProgress")
	For section,element in Result.Rows
	{
		count++, count_1:=0
		Phrase:=RegExReplace(element[2],"\〔|\〕|\「|\」"), str1:=Phrase~=SubStr(Phrase,1,1)?SubStr(Phrase,1,1):(SubStr(Phrase,1,2), count_1++)
		str2:=count_1>0?(Phrase~=SubStr(Phrase,3,1)?SubStr(Phrase,3,1):SubStr(Phrase,3,2)):(Phrase~=SubStr(Phrase,2,1)?SubStr(Phrase,2,1):SubStr(Phrase,2,2))
		resultObj[element[1]]:=[Phrase,str1,str2]
		If (Mod(count, num)=0) {
			tx :=Ceil(count/num)
			Progress, %tx% , %count%/%totalCount%`n, 拆分码表处理中..., 已完成%tx%`%
		}
	}
	return resultObj
}

GetEnPhrase(DB){
	DB.gettable("SELECT * FROM EN_Chr;",Result)
	startTime:= CheckTickCount(), totalCount:=Result.RowCount
	, num:=Ceil(totalCount/100) ,resultObj:={}, count:=0
	Progress, M1 Y10 FM14 W350, 1/%totalCount%, 造词源表处理中..., 1`%
	OnMessage(0x201, "MoveProgress")
	For section,element in Result.Rows
	{
		count++
		resultObj[element[1]]:=[element[2],SubStr(element[2],1,1),SubStr(element[2],2,1)]
		If (Mod(count, num)=0) {
			tx :=Ceil(count/num)
			Progress, %tx% , %count%/%totalCount%`n, 造词源表处理中..., 已完成%tx%`%
		}
	}
	return resultObj
}

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

;;OnMessage(0x138, "WM_CTLCOLORSTATIC")
WM_CTLCOLORSTATIC(wParam) { ; WHITE text on blue background
	static Brush
	If !Brush {
		DllCall("SetTextColor", "UInt", wParam, "UInt", 0x00FFFF)
		DllCall("SetBkColor", "UInt", wParam, "UInt", 0x0078d7)
		Brush := DllCall("CreateSolidBrush", "UInt", 0x0000FF, "UPtr")
	}
	Return, Brush
}

CreateColoredBitmap(width, height, color) {
	hBitmap := CreateDIBSections(width, -height,, pBits)
	Loop % height {
		i := A_Index - 1
		Loop % width
			NumPut(color, pBits + width*4*i + (A_Index - 1)*4, "UInt")
	}
	Return hBitmap
}

CreateDIBSections(w, h, bpp := 32, ByRef ppvBits := 0)
{
	hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
	VarSetCapacity(bi, 40, 0)
	NumPut( 40, bi,  0, "UInt")
	NumPut(  w, bi,  4, "UInt")
	NumPut(  h, bi,  8, "UInt")
	NumPut(  1, bi, 12, "UShort")
	NumPut(  0, bi, 16, "UInt")
	NumPut(bpp, bi, 14, "UShort")
	hbm := DllCall("CreateDIBSection", "Ptr", hdc, "Ptr", &bi, "UInt", 0, "PtrP", ppvBits, "Ptr", 0, "UInt", 0, "Ptr")
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
	return hbm
}

;; 获取当前DPI和默认DPI(96)的比值，以便于某些UI程序调整位置、字体等
GetDpiScale()
{
	; 当前DPI
	RegRead, AppliedDPI, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI
	; 默认DPI
	RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels

	Return AppliedDPI/LogPixels
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 对array进行排序，采用插入排序法
; 要求array参数的值必须通过Array.Insert()插入
; 新建一个Array，最后再赋值给array参数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InsertionSort(ByRef array) {
	target := Array()
	count := 0
	for Index, Files in array
	{
		files%Index% := Files
		count += 1
	}
	j := 2
	while (j <= count)
	{
		key := files%j%
		i := j-1
	
		while (i >= 0 && key < files%i%)
		{
			k := i+1
			files%k% := files%i%
			i -= 1
		}
		k := i+1
		files%k% := key
		j += 1
	}
	Loop, %count%
	{
		target.Insert(files%A_Index%)
	}
	array := target
}

; 执行命令sCmd，并且把命令输出从stdout导入变量
; source: http://www.autohotkey.com/forum/viewtopic.php?p=509873#509873
StdoutToVar_CreateProcess(sCmd, bStream="", sDir="", sInput="")
{
	bStream=   ; not implemented
	sDir=      ; not implemented
	sInput=    ; not implemented
   
	DllCall("CreatePipe", "Ptr*", hStdInRd , "Ptr*", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "Ptr*", hStdOutRd, "Ptr*", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Ptr", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Ptr", hStdOutWr, "Uint", 1, "Uint", 1)
	; Fill a StartupInfo structure
	if A_PtrSize = 4	; We're on a 32-bit system.
	{
		VarSetCapacity(pi, 16, 0)
		sisize := VarSetCapacity(si, 68, 0)
		NumPut(sisize,    si,  0, "UInt")
		NumPut(0x100,     si, 44, "UInt")
		NumPut(hStdInRd , si, 56, "Ptr")	; stdin
		NumPut(hStdOutWr, si, 60, "Ptr")	; stdout
		NumPut(hStdOutWr, si, 64, "Ptr")	; stderr
	}
	else if A_PtrSize = 8	; We're on a 64-bit system.
	{
		VarSetCapacity(pi, 24, 0)
		sisize := VarSetCapacity(si, 96, 0)
		NumPut(sisize,    si,  0, "UInt")
		NumPut(0x100,     si, 60, "UInt")
		NumPut(hStdInRd , si, 80, "Ptr")	; stdin
		NumPut(hStdOutWr, si, 88, "Ptr")	; stdout
		NumPut(hStdOutWr, si, 96, "Ptr")	; stderr
	}
	DllCall("CreateProcess", "Uint", 0	 ; Application Name
		, "Ptr",  &sCmd	; Command Line
		, "Uint", 0	 ; Process Attributes
		, "Uint", 0	 ; Thread Attributes
		, "Int",  True	 ; Inherit Handles
		, "Uint", 0x08000000  ; Creation Flags (0x08000000 = Suppress console window)
		, "Uint", 0	; Environment
		, "Uint", 0	; Current Directory
		   , "Ptr", &si	; Startup Info
		   , "Ptr", &pi)	; Process Information
	DllCall("CloseHandle", "Ptr", NumGet(pi, 0))
	DllCall("CloseHandle", "Ptr", NumGet(pi, A_PtrSize))
	DllCall("CloseHandle", "Ptr", hStdOutWr)
	DllCall("CloseHandle", "Ptr", hStdInRd)
	DllCall("CloseHandle", "Ptr", hStdInWr)
	VarSetCapacity(sTemp, 4095)
	nSize := 0
	loop
	{
		result := DllCall("Kernel32.dll\ReadFile", "Uint", hStdOutRd, "Ptr", &sTemp, "Uint", 4095, "UintP", nSize, "Uint", 0)
		if (result = "0")
			break
		else
		sOutput := sOutput . StrGet(&sTemp, nSize, "CP850")
	}
	DllCall("CloseHandle", "Ptr", hStdOutRd)
	return, sOutput
}


GetTaskInfos() {
	objService := ComObjCreate("Schedule.Service")
	objService.Connect()
	rootFolder := objService.GetFolder("\")
	taskCollection := rootFolder.GetTasks(0)
	numberOfTasks := taskCollection.Count
	; ?RegistrationInfo.Author
	For registeredTask, state in taskCollection
	{
		if (registeredTask.state == 0)
			state:= "Unknown"
		else if (registeredTask.state == 1)
			state:= "Disabled"
		else if (registeredTask.state == 2)
			state:= "Queued"
		else if (registeredTask.state == 3)
			state:= "Ready"
		else if (registeredTask.state == 4)
			state:= "Running"
		tasklist .= registeredTask.Name "=" state "=" registeredTask.state "`n"
	}
	return tasklist
}

IsTaskRunning(name, path := "\") {
	service := ComObjCreate("Schedule.Service")
	service.Connect()
	for task in service.GetFolder(path).GetTasks(1)
		if (task.Name = name)
			return task.GetInstances(0).Count
}

GetCharsObj(str){
	CreatRule:=[[22],[23,32],[33,42,24,222],[223,232,322,34,43],[44,233,323,332,224,242,422,2222],[2223,2232,2322,3222,333,342,234,432,423,324,243]
		,[442,424,244,433,343,334,22222,2233,2323,2224,2242,2422,3232,3322,3223,4222]], result:=[]
	If objCount(lenObj:=strlen(str)>10?CreatRule[7]:strlen(str)>3?CreatRule[strlen(str)-3]:[]) {
		for key,value In lenObj
		{
			index:=1, chars:=[]
			loop,% objCount(n:=StrSplit(value))
				chars.push(substr(str,index,n[A_Index])),index+=n[A_Index]
			result.push(chars)
		}
	}
	Return result
}

DrawBackground(hBitmap, width, height) {
	static SRCCOPY := 0xCC0020
	hTmpDC := DllCall("CreateCompatibleDC", "Ptr", this.MDC, "Ptr")
	hTmpObj := DllCall("SelectObject", "Ptr", hTmpDC, "Ptr", hBitmap, "Ptr")
	DllCall("BitBlt", "Ptr", this.MDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hTmpDC, "Int", 0, "Int", 0, "UInt", SRCCOPY)
	DllCall("SelectObject", "Ptr", hTmpDC, "Ptr", hTmpObj, "Ptr")
	DllCall("DeleteDC", "Ptr", hTmpDC)
}

GetThemeColor(ThemeName){
	result:={}
	For section,element in Json_FileToObj("Config\Skins\" ThemeName ".json")
		For key,Value in element
			If (section="color_scheme")
				result[key]:=SubStr(Value,5,2) SubStr(Value,3,2) SubStr(Value,1,2)
	return result
}

formatHotkey(keys){
	If keys~="\^"
		keys:=RegExReplace(keys,"\^","Ctrl & ")
	If keys~="\+"
		keys:=RegExReplace(keys,"\+","Shift & ")
	If keys~="\!"
		keys:=RegExReplace(keys,"\!","Alt & ")
	If keys~="\#"
		keys:=RegExReplace(keys,"\#","Win & ")
	If keys~="\<"
		keys:=RegExReplace(keys,"\<","L")
	If keys~="\>"
		keys:=RegExReplace(keys,"\<","R")
	Return keys
}

formatHotkey_2(keys){
	If keys~="i)^LL|^RR"
		keys:=RegExReplace(keys,"i)^LL|^RR",keys~="i)^LL"?"L":"R")
	If keys~="i)LCtrl|LControl"&&keys~="\&"
		keys:=RegExReplace(keys,"i)LCtrl|LControl","<^")
	If keys~="i)RCtrl|RControl"&&keys~="\&"
		keys:=RegExReplace(keys,"i)RCtrl|RControl",">^")
	If keys~="i)Ctrl|Control"&&keys~="\&"
		keys:=RegExReplace(keys,"i)Ctrl|Control","^")
	If keys~="i)Shift"&&keys~="\&"
		keys:=RegExReplace(keys,"i)Shift","+")
	If keys~="i)LShift"&&keys~="\&"
		keys:=RegExReplace(keys,"i)LShift","<+")
	If keys~="i)RShift"&&keys~="\&"
		keys:=RegExReplace(keys,"i)RShift",">+")
	If keys~="i)Alt"&&keys~="\&"
		keys:=RegExReplace(keys,"i)Alt","!")
	If keys~="i)LWin"&&keys~="\&"
		keys:=RegExReplace(keys,"i)LWin","<#")
	If keys~="i)RWin"&&keys~="\&"
		keys:=RegExReplace(keys,"i)RWin",">#")
	If keys~="[\^\!\+\#]"
		keys:=RegExReplace(keys,"\&|\s")
	else If not keys~="[\^\!\+\#\s]"
		keys:=RegExReplace(keys,"\&"," & ")
	Return keys
}

HotkeyFunc(item1){
	global srf_all_Input
	return item1=3&&srf_all_Input||item1<>3?1:0
}

HotkeyRegister(){
	global Srf_Hotkey, ChoiceItems, ThisKeyObj, srf_all_input, rlk_switch, Suspend_switch, Addcode_switch,s2t_swtich ,cf_swtich ,Exit_switch
		, tip_hotkey, Addcode_hotkey, s2t_hotkey, cf_hotkey, Suspend_hotkey,Exit_hotkey
	Srf_Hotkey:=formatHotkey_2(Srf_Hotkey)
	Hotkey, LShift, SetHotkey,off
	Hotkey, RShift, SetHotkey,off
	Hotkey, LShift, SetChoiceCodeHotkey,off
	Hotkey, RShift, SetChoiceCodeHotkey,off
	If (Srf_Hotkey="Shift") {
		;;HotkeyStatus := Func("HotkeyFunc").Bind(ChoiceItems)
		;;hotkey,If,% HotkeyStatus
		ThisKeyObj:=["LShift","RShift"]
		Hotkey, LShift, SetHotkey,on
		Hotkey, RShift, SetHotkey,on
		;;hotkey,If
	}else If (Srf_Hotkey="LShift"){
		ThisKeyObj:=["LShift"]
		Hotkey, LShift, SetHotkey,on
		If (ChoiceItems=3)
			Hotkey, RShift, SetChoiceCodeHotkey,on
	}else If (Srf_Hotkey="RShift"){
		ThisKeyObj:=["RShift"]
		Hotkey, RShift, SetHotkey,on
		If (ChoiceItems=3)
			Hotkey, LShift, SetChoiceCodeHotkey,on
	}else{
		Hotkey, %Srf_Hotkey%, SetHotkey,on
		ThisKeyObj:=[]
	}

	if rlk_switch
		Hotkey, %tip_hotkey%, SetRlk,on
	else
		Hotkey, %tip_hotkey%, SetRlk,off

	if Suspend_switch
		Hotkey, %Suspend_hotkey%, SetSuspend,on
	else
		Hotkey, %Suspend_hotkey%, SetSuspend,off

	if Addcode_switch
		Hotkey, %AddCode_hotkey%, Batch_AddCode,on
	else
		Hotkey, %AddCode_hotkey%, Batch_AddCode,off

	if s2t_swtich
		Hotkey, %s2t_hotkey%, Trad_Mode,on
	else
		Hotkey, %s2t_hotkey%, Trad_Mode,off

	if cf_swtich
		Hotkey, %cf_hotkey%, Cut_Mode,on
	else
		Hotkey, %cf_hotkey%, Cut_Mode,off

	if Exit_switch
		Hotkey, %exit_hotkey%, OnExit,on
	else
		Hotkey, %exit_hotkey%, OnExit,off
}

;;--------------------------------------------
kbhk := 0, mhk := 0
KBCallback := RegisterCallback("KeyboardHookProc",,3)
MCallback := RegisterCallback("MouseHookProc",,3)

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

CaptainHook(enable := false) {
	global kbhk, mhk, KBCallback, MCallback
	static WH_KEYBOARD := 2, WH_MOUSE := 7
	if(enable) {
		dwThreadId := DllCall("GetCurrentThreadId")

		if(kbhk or mhk) ;remove any old hooks
			CaptainHook(false)

		kbhk := SetWindowsHookEx(WH_KEYBOARD, KBCallback, 0, dwThreadId)
		if(!kbhk)
			MsgBox,262160,错误 ,% "无法设置键盘钩子" . GetLastError()
		mhk := SetWindowsHookEx(WH_MOUSE, MCallback, 0, dwThreadId)
		if(!mhk)
			MsgBox,262160,错误 ,% "无法设置鼠标钩子" . GetLastError()
		;if(mhk and kbhk)
		;	CreateGUI()
	} else {
		if(kbhk) {
			UnhookWindowsHookEx(kbhk)
			kbhk := 0
		}

		if(mhk) {
			UnhookWindowsHookEx(mhk)
			mhk := 0
		}
	}
}

KeyboardHookProc(code, wParam, lParam) {
	global hWndgui98, Control0
	if(code == 0 or code == 3) {
		vk := wParam, sc := lParam, sc:=RegExreplace(Format("{:2X}", sc-1),"[0]{4}$"), vk:=Format("VK{:X}", vk)
		mainKeylist:={LWin:"VK5B", RWin:"VK5C", LShift:"VKA0", RShift:"VKA1", LControl:"VKA2", RControl:"VKA3", LCtrl:"VKA2", RCtrl:"VKA3", LAlt:"VKA4", RAlt:"VKA5",Shift:"VKA1"}
		sc:=sc~="^C"?"S" sc:"SC" sc, KeyName:=GetKeyName(Control0?vk:sc), vk:=mainKeylist[KeyName]&&!Control0?mainKeylist[KeyName]:vk
		, KeyName:=GetArrIndex(mainKeylist,vk)&&!Control0&&KeyName="Shift"?"RShift":KeyName, KeyCodeObj:={vk:vk,sc:sc, KeyName:KeyName}
		ControlGetFocus, Control, ahk_id %hWndgui98%
		GuiControlGet, Var1, 98:Name , %Control%
		If (Var1="sethotkey_1")
			GuiControl,98:,sethotkey_1,% KeyCodeObj.KeyName
		else If (Var1="sethotkey_3")
			GuiControl,98:,sethotkey_3,% KeyCodeObj.KeyName
	} else {
		return CallNextHookEx(0, code, wParam, lParam)
	}
}

MouseHookProc(code, wParam, lParam) {
	if(code == 0 or code == 3) {
		m_id := wParam
		mousehookstruct := lParam
		;;tooltip,% Format("VK{:X}", m_id)
	} else {
		return CallNextHookEx(0, code, wParam, lParam)
	}
}

GetTabItemCount(TabHwnd) {
	Return DllCall("SendMessage", "Ptr", TabHwnd, "UInt", 0x1304, "Ptr", 0, "Ptr", 0, "Int")
}

;;--------------------------------------------
;;WinSet,Redraw,,ahk_id%main%
;;tv:=new treeview(hwnd)
;;top:=TreeView.Add({Label:"Blue",Fore:0xff0000})
;;Tv.Add({Label:"Purple",Back:0xff00ff,parent:top,Option:"Vis"})
;;Tv.Add({Label:"Red",Fore:0x0000ff})
;;tv1.Remove(Test1)
;;WinSet,Redraw,,A
class TreeView{
	static list:=[]
	__New(hwnd){
		this.list[hwnd]:=this
		OnMessage(0x4e,"WM_NOTIFY")
		this.hwnd:=hwnd
	}
	add(info){
		Gui,TreeView,% this.hwnd
		hwnd:=TV_Add(info.Label,info.parent,info.option)
		if info.fore!=""
			this.control["|" hwnd,"fore"]:=info.fore
		if info.back!=""
			this.control["|" hwnd,"back"]:=info.back
		return hwnd
	}
	modify(info){
		this.control["|" info.hwnd,"fore"]:=info.fore
		this.control["|" info.hwnd,"back"]:=info.back
		WinSet,Redraw,,A
	}
	Remove(hwnd){
		this.control.Remove("|" hwnd)
	}
}
WM_NOTIFY(Param*){
	static list:=[],ll:=""
	control:=
	if (this:=treeview.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001&&info:=this.control["|" numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")]){ ;NM_CUSTOMDRAW && Control is in the list
			if info.fore!=""
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}
/*
;;lv1H := new ListView(LV1)
;;handle := lv1H.Add("","Main " . A_index, A_index * 4)
;;lv1H.Color(handle,0xff00ff,0x000000)
class ListView
{
	static list:=[]
	__New(hwnd)
	{
		this.list[hwnd]:=this			
		OnMessage(0x4e,"WM_NOTIFY")
		this.hwnd:=hwnd
		this.control:=[]
	}
	add(options,items*)
	{
		Gui,ListView,% this.hwnd
		for a,b in items{
			if A_Index=1
				item:=LV_Add(options,b)
			Else
				LV_Modify(item,"col" A_Index,b)
		}
		return item
	}
	clear(){
		this.control:=[]
	}
	getColor(item)
	{
		LV_GetText(text,item)
		return {"fore":this.Control[text].fore,"back":this.Control[text].back}
	}
	Color(item,byref fore:="",byref back:="")
	{
		LV_GetText(text,item)
		;msgbox [%item%]`n[%fore%]`n[%back%]
		if(fore!="")
		{
			this.Control[text,"fore"]:=fore
		}
		if(back!="")
		{
			this.Control[text,"back"]:=back
		}
	}
}


WM_NOTIFY(Param*)
{
	Critical
	control:=
	if (this:=ListView.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12)
	{
		
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
		{
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		}
		if (stage=0x10001) ;NM_CUSTOMDRAW && Control is in the list
		{ 
			index:=numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")
			LV_GetText(text,index+1)			
			info:=this.Control[text]
			if(info.fore!="")
			{					
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			}
			if(info.back!="")
			{
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
			}
		}
	}
	else if (this:=treeview.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12)
	{
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
		{
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		}
		if (stage=0x10001&&info:=this.control[numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")]) ;NM_CUSTOMDRAW && Control is in the list
		{
			if(info.fore!="")
			{
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			}
			if(info.back!="")
			{
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
			}
		}
	}	
}
*/