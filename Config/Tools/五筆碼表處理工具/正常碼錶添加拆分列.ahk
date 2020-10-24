/*
	單義/多義碼表添加一列拆分顯示：
		首先選擇「單義/多義碼表」，再選擇拆分單字碼表作爲生成工具，支持單字節與雙字節字根混搭碼表，碼表格式建議「UTF-8 BOM 或 UTF-16LE BOM」
*/
#NoEnv
#NoTrayIcon
#SingleInstance, Force
#Include %A_ScriptDir%
SetWorkingDir %A_ScriptDir%

FileSelectFile, MaBiaoFile, 3, , 選擇單義/多義碼表, Text Documents (*.txt)
SplitPath, MaBiaoFile, , , , filename
SplitPath, MaBiaoFile, fileshortname
FileFoldPath:=RegExReplace(MaBiaoFile,fileshortname "$")
If (MaBiaoFile<> ""&&filename){
	startTime:= CheckTickCount()
	tarr:=tarr2:=[],count :=0
	GetFileFormat(MaBiaoFile,MaBiao,Encoding)
	If not Encoding~="UTF\-16BE\sBOM|UTF\-8\sBOM" {
		MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 4
		ExitApp
	}
	if MaBiao~="`n[a-z]\s.+\s.+"
		MaBiao:=TransformCiku(MaBiao)
	If MaBiao~="\t[a-z]+" {
		If objCount(EtymologyPhrase:=GetEtymologyPhrase()) {
			totalCount:=CountLines(MaBiao), num:=Ceil(totalCount/100)
			Progress, M1 Y10 FM14 W350, 1/%totalCount%, 碼錶處理中..., 1`%
			OnMessage(0x201, "MoveProgress")
			Loop,Parse,MaBiao,`n,`r
			{
				If (A_LoopField) {
					count++
					tarr:=StrSplit(A_LoopField,"`t")
					If (StrLen(tarr[1])=1)
						cf:=EtymologyPhrase[tarr[1],1]
					If (StrLen(tarr[1])=2)
						cf:=EtymologyPhrase[SubStr(tarr[1],1,1),2] EtymologyPhrase[SubStr(tarr[1],1,1),3] EtymologyPhrase[SubStr(tarr[1],2,1),2] EtymologyPhrase[SubStr(tarr[1],2,1),3]
					If (StrLen(tarr[1])=3)
						cf:=EtymologyPhrase[SubStr(tarr[1],1,1),2] EtymologyPhrase[SubStr(tarr[1],2,1),2] EtymologyPhrase[SubStr(tarr[1],3,1),2] EtymologyPhrase[SubStr(tarr[1],3,1),3]
					else If (StrLen(tarr[1])>3)
						cf:=EtymologyPhrase[SubStr(tarr[1],1,1),2] EtymologyPhrase[SubStr(tarr[1],2,1),2] EtymologyPhrase[SubStr(tarr[1],3,1),2] EtymologyPhrase[SubStr(tarr[1],0),2]

					result.=tarr[1] "`t" tarr[2] "`t" cf "`r`n", cf:=""
					If (Mod(count, num)=0) {
						tx :=Ceil(count/num)
						Progress, %tx% , %count%/%totalCount%`n, 碼錶處理中..., 已完成%tx%`%
					}
				}
			}
			If (result) {
				FileDelete,%FileFoldPath%%FileName%_New.txt
				FileAppend,%result%,%FileFoldPath%%FileName%_New.txt,utf-8
			}
		}else
			MsgBox, 262160, 错误提示, % EtymologyPhrase?EtymologyPhrase:"生成失敗！", 8
	}else
		MsgBox, 262160, 错误提示, 詞庫格式不支持！, 4
}
ExitApp

GetEtymologyPhrase(){
	FileSelectFile, MaBiaoFile, 3, , 导入拆分單字码表, Text Documents (*.txt)
	SplitPath, MaBiaoFile, , , , filename
	SplitPath, MaBiaoFile, fileshortname
	FileFoldPath:=RegExReplace(MaBiaoFile,fileshortname "$")
	If (MaBiaoFile<> ""&&filename){
		MsgBox, 262452, 提示, 是否分離拆分码表前兩位生成單義格式文件？`n词库格式须为「單字+tab+拆分」
		IfMsgBox, Yes
		{
			startTime:= CheckTickCount()
			TrayTip,, 码表处理中，请稍后...
			tarr:=tarr2:=[],count :=0, result:={}
			GetFileFormat(MaBiaoFile,MaBiao,Encoding)
			If not Encoding~="UTF\-16BE\sBOM|UTF\-8\sBOM" {
				Return (MaBiaoFile "文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM〕")
			}
			MaBiao:=RegExReplace(MaBiao,"\t\d+")
			If MaBiao~="\t"
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
						result[tarr[1]]:=[RegExReplace(tarr[2],"\〔|\〕|\「|\」"),str1,str2], str1:=str2:=""
						If (Mod(count, num)=0) {
							tx :=Ceil(count/num)
							Progress, %tx% , %count%/%totalCount%`n, 拆分码表处理中..., 已完成%tx%`%
						}
					}
				}
				Progress,off
				If objCount(result)
				{
					Return result, MaBiao:=""
				}else
					Return "生成失敗！" 
			}else
				Return "詞庫格式不支持"
		}
			Return ""
	}
}

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

;;码表单字去重保留全码
GetCikuFullcode(Chars){
	If (Chars="")
		return
	arr:={}, count:=0
	totalCount:=CountLines(Chars), num:=Ceil(totalCount/100)
	Progress, M1 Y10 FM14 W350, 1/%totalCount%, 码表单字去重保留全码处理中..., 1`%
	Loop, Parse, Chars, `n, `r
	{
		tarr:=StrSplit(A_LoopField,A_Tab,A_Tab)
		If (StrLen(tarr[1])=1){
			If (arr[tarr[1],1]&&StrLen(tarr[2])>StrLen(arr[tarr[1],1])||!arr[tarr[1],1])
				arr[tarr[1]]:=[tarr[2],SubStr(tarr[2],1,1),,SubStr(tarr[2],2,1)], count++
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