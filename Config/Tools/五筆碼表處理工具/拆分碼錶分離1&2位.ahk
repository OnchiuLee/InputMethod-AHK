/*
	僅支持单行單义，分離拆分單字碼錶前兩位並導出，支持單字節與雙字節字根混搭碼表，碼表格式建議「UTF-8 BOM 或 UTF-16LE BOM」
	支持格式：
		詞條+tab+拆分+編碼----------->詞條+tab+編碼首位編碼+tab+拆分第二位編碼
		詞條+tab+拆分----------->詞條+tab+拆分首位字根+tab+拆分第二位字根
*/
#NoEnv
#NoTrayIcon
#SingleInstance, Force
#Include %A_ScriptDir%
SetWorkingDir %A_ScriptDir%

FileSelectFile, MaBiaoFile, 3, , 导入拆分單字码表, Text Documents (*.txt)
SplitPath, MaBiaoFile, , , , filename
SplitPath, MaBiaoFile, fileshortname
FileFoldPath:=RegExReplace(MaBiaoFile,fileshortname "$")
If (MaBiaoFile<> ""&&filename){
	MsgBox, 262452, 提示, 是否分離拆分码表前兩位生成單義格式文件？`n词库格式须为「單字+tab+拆分」或「單字+拆分+編碼」
	IfMsgBox, Yes
	{
		startTime:= CheckTickCount()
		TrayTip,, 码表处理中，请稍后...
		tarr:=tarr2:=[],count :=0
		GetFileFormat(MaBiaoFile,MaBiao,Encoding)
		If not Encoding~="UTF\-16BE\sBOM|UTF\-8\sBOM" {
			MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 10
			ExitApp
		}
		MaBiao:=RegExReplace(MaBiao,"\t\d+")
		If MaBiao~="\n.+\t.+"
		{
			totalCount:=CountLines(MaBiao), num:=Ceil(totalCount/100)
			Progress, M1 Y10 FM14 W350, 1/%totalCount%, 拆分码表处理中..., 1`%
			OnMessage(0x201, "MoveProgress")
			Loop,Parse,MaBiao,`n,`r
			{
				If (A_LoopField) {
					count++, count_1:=0
					tarr:= StrSplit(A_LoopField,A_Tab), tarr2:=StrSplit(Char2Unicode(RegExReplace(tarr[2],"\〔|\〕|\「|\」")),"|"), tarr3:=StrSplit(Char2Unicode(tarr[3]),"|")
					str1:=tarr[2]~=chr(tarr2[1])?chr(tarr2[1]):(chr(tarr2[1]) chr(tarr2[2]), count_1++)
					str2:=count_1>0?(tarr[2]~=chr(tarr2[3])?chr(tarr2[3]):chr(tarr2[3]) chr(tarr2[4])):(tarr[2]~=chr(tarr2[2])?chr(tarr2[2]):chr(tarr2[2]) chr(tarr2[3]))
					InsertArr1.=tarr[1] "`t" str1 "`t" str2 "`r`n"
					If (objLength(tarr)>2&&tarr[3]~="\t[a-z]")
						InsertArr2.=tarr[1] "`t" Chr(tarr3[1]) "`t" Chr(tarr3[2]) "`r`n"
					If (Mod(count, num)=0) {
						tx :=Ceil(count/num)
						Progress, %tx% , %count%/%totalCount%`n, 拆分码表处理中..., 已完成%tx%`%
					}
				}
			}
			Progress,off
			If InsertArr1
			{
				FileDelete,%FileFoldPath%EtymologyPhrase.txt
				FileAppend,% RegExReplace(InsertArr1,"^\n|\n$"),%FileFoldPath%EtymologyPhrase.txt,UTF-8
				If (MaBiao~="\t[a-z]") {
					FileDelete,%FileFoldPath%EtymologyBianma.txt
					FileAppend,% RegExReplace(InsertArr2,"^\n|\n$"),%FileFoldPath%EtymologyBianma.txt,UTF-8
				}
				timecount:= CheckTickCount(startTime)
				Progress, M ZH-1 ZW-1 Y100 FM12 C0 FM14 WS700 ,, 写入%count%行！完成用时 %timecount%！, 完成提示
				Sleep 8000
				Progress,off
				MaBiao:=Insert_ci:="",tarr:=tarr2:=[], mbObj:={}
			}else
				MsgBox, 262160, 错误提示, 處理失敗！, 5
		}else{
			MsgBox, 262160, 错误提示, 格式不对！, 5
			ExitApp
		}
	}
}
ExitApp

MoveProgress() {
	PostMessage, 0xA1, 2 
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