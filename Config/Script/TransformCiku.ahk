/*
      ;;单行多义/单行单义码表互转
*/
#NoTrayIcon
#SingleInstance, Force

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
ExitApp

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

TranCiku(FilePath,outpath=""){
	If !FileExist(FilePath)
		return 0
	outpath:=outpath?outpath:FilePath
	GetFileFormat(FilePath,chars,Encoding)
	If (Encoding="UTF-16BE BOM") {
		MsgBox, 262160, 错误提示, 文件编码格式非〔UTF-8 BOM 或 UTF-16LE BOM 或 CP936〕！, 10
		Return
	}
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
						loopvalue.=loopvalue_ A_tab value "`r`n"
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

CheckTickCount(TC:=0){
	if !TC {
		DllCall("QueryPerformanceFrequency", "Int64*", freq), DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
		Return {CB:CounterBefore,Perf:freq}
	}Else{
		DllCall("QueryPerformanceCounter", "Int64*", CounterAfter), t:=(CounterAfter-TC.CB)/TC.Perf
		TickCount:=t<1?t*1000 "毫秒":(t>60?Floor(t/60) "分" mod(t,60):t "秒")
		Return TickCount
	}
}
