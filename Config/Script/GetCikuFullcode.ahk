/*
	支持单行多义与单行多义码表，自动过滤保留全码单字整理并生成txt文件。
*/
#NoEnv
#NoTrayIcon
#SingleInstance, Force
#Include %A_ScriptDir%
SetWorkingDir %A_ScriptDir%

FileSelectFile, MaBiaoFile, 3, , 导入适用于造词的源码表, Text Documents (*.txt)
SplitPath, MaBiaoFile, , , , filename
SplitPath, MaBiaoFile, fileshortname
FileFoldPath:=RegExReplace(MaBiaoFile,fileshortname "$")
If (MaBiaoFile<> ""&&filename){
	MsgBox, 262452, 提示, 是否对码表去重处理以生成无重复的全码txt单字码表？`n词库格式须为「单行单义/单行多义」
	IfMsgBox, Yes
	{
		startTime:= CheckTickCount()
		TrayTip,, 码表处理中，请稍后...
		tarr:=tarr2:=[],count :=0
		GetFileFormat(MaBiaoFile,MaBiao,Encoding)
		If (Encoding="UTF-16BE BOM") {
			MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 10
			ExitApp
		}
		MaBiao:=RegExReplace(MaBiao,"\t\d+")
		if MaBiao~="`n[a-z]\s.+\s.+"
			MaBiao:=TransformCiku(MaBiao)
		If MaBiao~="\n.+\t[a-z]+"
		{
			totalCount:=objCount(mbObj:=RemovalCode(MaBiao)), num:=Ceil(totalCount/100)
			Progress, M1 Y10 FM14 W350, 1/%totalCount%, 码表处理中..., 1`%
			OnMessage(0x201, "MoveProgress")
			for section,element in mbObj
			{
				tarr.= section A_Tab element "`r`n"
				tarr2.= section A_Tab SubStr(element,1,1) A_Tab SubStr(element,2,1) "`r`n" ,count++
				If (Mod(count, num)=0) {
					tx :=Ceil(count/num)
					Progress, %tx% , %count%/%totalCount%`n, 码表处理中..., 已完成%tx%`%
				}
			}
			Progress,off
			If tarr2&&tarr
			{
				MsgBox, 262452, 写入提示, 码表处理完成是否生成文件？
				IfMsgBox, Yes
				{
					FileDelete,%FileFoldPath%MakePhrase.txt
					FileAppend,% RegExReplace(tarr2,"^\n|\n$"),%FileFoldPath%MakePhrase.txt,UTF-8
					FileDelete,%FileFoldPath%EN_Chr.txt
					FileAppend,% RegExReplace(tarr,"^\n|\n$"),%FileFoldPath%EN_Chr.txt,UTF-8
					timecount:= CheckTickCount(startTime)
					Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 写入%count%行！完成用时 %timecount%！, 完成提示
					Sleep 8000
					Progress,off
				}
				MaBiao:=Insert_ci:="",tarr:=tarr2:=[], mbObj:={}
			}else
				MsgBox, 262160, 错误提示, 格式不对！, 5
		}else
			MsgBox, 262160, 格式错误, 码表格式非「单行单义/单行多义」，导入失败！, 10
	}
}
ExitApp

;;单行多义格式转换为单行单义
TransformCiku(Chars){
	If (Chars="")
		return ""
	If Chars~="[a-z]\s.+\s.+" {
		Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 单行多义格式转换为单行单义中。。。！, 转换提示
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
		Progress,off
		return loopvalue
	}else{
		return ""
	}
}

MoveProgress() {
	PostMessage, 0xA1, 2 
}

;;码表单字去重保留全码
RemovalCode(Chars){
	If (Chars="")
		return
	arr:={}, count:=0
	totalCount:=CountLines(Chars), num:=Ceil(totalCount/100)
	Progress, M1 Y10 FM14 W350, 1/%totalCount%, 码表单字去重保留全码处理中..., 1`%
	Loop, Parse, Chars, `n, `r
	{
		tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
		If (StrLen(tarr[1])=1){
			If (arr[tarr[1]]&&StrLen(tarr[2])>StrLen(arr[tarr[1]])||!arr[tarr[1]])
				arr[tarr[1]]:=tarr[2], count++
			else
				Continue
			If (Mod(count, num)=0) {
				tx :=Ceil(count/num)
				Progress, %tx% , %count%/%totalCount%`n, 码表单字去重保留全码处理中..., 已完成%tx%`%
			}
		}
	}
	Progress,off
	return arr
}

;;统计行数
CountLines(file){ 
	If not file~="`n"
		FileRead, Text, %file%
	else
		Text:=file
	StringReplace, Text, Text, `n, `n, UseErrorLevel
	Text:=""
	Return ErrorLevel + 1
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
