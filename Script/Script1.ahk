ReadInis:
	FilePathAll:=FileLisst2:=""
	Loop,% AHKIni["FilePath"].length()
		FilePathAll.=AHKIni["FilePath",A_Index] "`n"
	FileLisst2:=""
	Loop,% AHKIni["FileLists"].length()
	{
		If AHKIni["FileLists",A_Index] {
			If FileExist(AHKIni["FileLists",A_Index])
				FileLisst2.=AHKIni["FileLists",A_Index] "|"
			else
				AHKIni.RemoveKey("FileLists", A_Index)
		}
	}
	AHKIni.Save()
return

TRAY_Menu:
	Menu, TRAY, NoStandard
	Menu, TRAY, DeleteAll
	Menu, Tray, Add, 文件选取,SelectFilePath
	Menu, Tray, Add,
	Menu, Tray, Add, 设置页面, GuiFileShow
	Menu, Tray, Add,
	;Menu, Tray, Add,执行, SendFile
	;Menu, Tray, Add,
	Menu, Tray, Add,重载, OnReload
	Menu, Tray, Add,
	Menu, Tray, Add,退出, OnExit
	Menu, Tray, Default,设置页面
	Menu, Tray, Click, 2
	Tip:= "「 发送助手 」"
	Menu,Tray,Tip,%Tip%
return

OnReload:
	reload
return

OnExit:
	ExitApp
return

GuiFileShow:
	Gui, 99:Destroy
	Gui, 99:Default
	Gui, 99: +AlwaysOnTop
	Gui, 99:Add, button, vSelectMore gSelectMore,多选
	Gui, 99:Add, button,x+5 vDelFilePath gDelFilePath,删除
	GuiControl, 99:Disable, DelFilePath
	Gui, 99:Add, button,x+5 vReloadFilePath gReloadFilePath,刷新
	Gui, 99:Add, button,x+5 vGetFilePath gGetFilePath,文件选取
	Gui, 99:Add, text,xm y+10,发送热键：
	Gui, 99:Add, Hotkey,x+5 yp-4 vSendHotkey gSendHotkey,% RunHotkey
	Gui, 99:Font
	Gui, 99:Font, s10 bold
	Gui, 99:Add, text,xm vTextInfo1,〔 多选批量/单选/双击添加至发送列表，文件拖拽至此窗口批量添加〕`n文件列表记录
	Gui, 99:Font
	Gui, 99:Add, ListView,xm w420 r15 Grid AltSubmit ReadOnly NoSortHdr NoSort -WantF2 -Multi 0x8 LV0x40 -LV0x10 gMyFileList vMyFileList hwndFileLV, 编号|文件路径|存在
	Loop, Parse, FilePathAll, `n, `r
		If A_LoopField
			LV_Add("",A_Index, A_LoopField,(FileExist(A_LoopField)?"√":"×")), LV_ModifyCol()
	LV_ModifyCol(1,"50 Integer center")
	LV_ModifyCol(2,"300 left")
	LV_ModifyCol(3,"50 left")
	GuiControlGet, ListVar, Pos , MyFileList
	GuiControlGet, ListVar1, Pos , TextInfo1
	FileLisst:=""
	Loop,Parse,FileLisst2,|
		FileLisst.=RegExReplace(A_LoopField,".+\\") "|"
	x_:=ListVarX+450+15,__:=ListVarH*0.6
	Gui, 99:Add, button,x+10 y%__% vAddFilePath gAddFilePath,添加 -->>
	Gui, 99:Add, button,xp y+30 vRMFilePath gRMFilePath,删除 <<--
	Gui, 99:Add, button,xp y+30 vClearFilePath gClearFilePath,清除全部<<--
	y__:=ListVar1Y,_i_:=ListVar1Y+ListVar1H/2
	Gui, 99:Font
	Gui, 99:Font, s10 bold
	Gui, 99:Add, text,x+10 y%_i_% ,文件待发送列表
	Gui, 99:Font
	Gui, 99:Add, ListBox, h%ListVarH% w%ListVarH% gFilePathList vFilePathList,% FileLisst
	Gui, 99:show,AutoSize,「文件列表」
	CheckedStatus:=0
return

99GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y){
	global AHKIni
	If (GuiHwnd&&IsRightClick&&EventInfo){
		LV_GetText(posInfo, A_EventInfo,2)
		Menu, RKeyMenu, Add, 添加至列表,AddPath
		Menu, RKeyMenu, Add, 删除,DelItems
		Menu, RKeyMenu, show
		GuiControl, Focus, ahk_id %GuiHwnd%
	}
	DelItems:
		if (posInfo&&A_ThisMenuItem~="删除"&&A_EventInfo) {
			AHKIni.RemoveKey("FilePath", A_EventInfo)
			LV_Delete(A_EventInfo)
		}
	return

	AddPath:
		If (posInfo&&A_ThisMenuItem~="添加") {
			AHKIni["FileLists",AHKIni["FileLists"].length()+1]:=posInfo,AHKIni.Save()
			GuiControl,99:,FilePathList,% RegExReplace(posInfo,".+\\")
		}
	return
}

SendHotkey:
	if SendHotkey
		Hotkey, %RunHotkey%, SendFile,off
	RunHotkey:=AHKIni.Hotkeys["RunHotkey"]:=SendHotkey?SendHotkey:"!d", AHKIni.save()
	Hotkey, %RunHotkey%, SendFile,on
return

ReloadFilePath:
	Gosub ReadInis
	LV_Delete(),FileLisst:=""
	Loop, Parse, FilePathAll, `n, `r
		If A_LoopField
			LV_Add("",A_Index, A_LoopField,(FileExist(A_LoopField)?"√":"×"))
	Loop,Parse,FileLisst2,|
		FileLisst.= "|" RegExReplace(A_LoopField,".+\\")
	If FileLisst
		GuiControl,99:,FilePathList, % FileLisst
return

SelectMore:
	if !CheckedStatus {
		GuiControl +Checked, MyFileList
		CheckedStatus:=1
	}else{
		GuiControl -Checked, MyFileList
		GuiControl, 99:Disable, DelFilePath
		CheckedStatus:=0
	}
return

RMFilePath:
	If FilePathList
		for k,v in AHKIni["FileLists"]
			if AHKIni["FileLists",A_Index]~=FilePathList "$"
				AHKIni.RemoveKey("FileLists", A_Index), AHKIni.Save()
	Gosub ReadInis
	FileLisst:=""
	Loop,Parse,FileLisst2,|
		FileLisst.= "|" RegExReplace(A_LoopField,".+\\")
	If FileLisst
		GuiControl,99:,FilePathList, % FileLisst
return

FilePathList:
	GuiControlGet, FilePathList ,, FilePathList, ListBox
return

AddFilePath:
	Checkflag:=0
	If OENVar
		loop, % LV_GetCount()+1
			if LV_GetNext( A_Index-1, "Checked" )
				Checkflag:=1, break
	If (OENVar&&Checkflag) {
		AddItems()
	}else{
		If FileExist(posInfo) {
			AHKIni["FileLists",AHKIni["FileLists"].length()+1]:=posInfo,AHKIni.Save()
			GuiControl,99:,FilePathList,% RegExReplace(posInfo,".+\\")
		}else
			TrayTip,,文件不存在
	}
	Gosub ReadInis
return

ClearFilePath:
	AHKIni["FileLists"]:=[],AHKIni.Save()
	If !AHKIni["FileLists"].length()
		GuiControl,99:,FilePathList, |
	Gosub ReadInis
return

GetFilePath:
	Gui,99:hide
	Gosub SelectedFiles
	Gosub ReadInis
	Gui,99:Show
return

SelectFilePath:
	Gosub SelectedFiles
	Gosub ReadInis
return

MyFileList:
	GuiControlGet, OENVar, Enabled , DelFilePath
	If CheckedStatus {
		loop, % LV_GetCount()+1
		{
			if LV_GetNext( A_Index-1, "Checked" ){
				GuiControl, 99:Enable, DelFilePath
				break
			}else{
				GuiControl, 99:Disable, DelFilePath
				break
			}
		}
	}
	if (A_GuiEvent = "Normal"){
		LV_GetText(posInfo, A_EventInfo,2)
		If A_EventInfo {
			ToolTip % posInfo
			SetTimer,RemoveToolTip,1500
		}
	}else if (A_GuiEvent = "DoubleClick"){
		LV_GetText(posInfo, A_EventInfo,2)
		If A_EventInfo
			Gosub AddFilePath
	}

return

99GuiDropFiles:
	Loop, Parse, A_GuiEvent, `n, `r
	{
		If (A_LoopField&&IsFile(A_LoopField))
			AHKIni["FilePath",AHKIni["FilePath"].length()+1]:=A_LoopField,AHKIni.Save(), LV_Add("",LV_GetCount()+1,A_LoopField,"√")
	}
	Gosub ReadInis
return

IsFile(FolderPath){
	global AHKIni
	FolderPath:=FolderPath "\*.*"
	flag:=1
	Loop, Files, %FolderPath%,R
	{
		flag:=0
		If A_LoopFileLongPath {
			AHKIni["FilePath",AHKIni["FilePath"].length()+1]:=A_LoopFileLongPath,AHKIni.Save(), LV_Add("",LV_GetCount()+1,A_LoopFileLongPath,"√")
		}
	}
	return flag
}

DelFilePath:
	ClearItems()
	Gosub ReadInis
return

ClearItems(deb =""){
	global AHKIni
	Loop % (LV_GetCount(),a:=1)
	{	if ( LV_GetNext( 0, "Checked" ) = a )
		{	if ( !deb ){
				LV_GetText(LVar_, a , 1),LV_GetText(LVar, a , 3)
				AHKIni.RemoveKey("FilePath", a)
				LV_Delete( a )
			}
		}else
			++a
	}
	AHKIni.Save()
}

AddItems(){
	global AHKIni
	Index:=0
	Loop % (LV_GetCount(),a:="")
	{
		Gui +LastFound
		SendMessage, 4140, A_Index - 1, 0xF000, SysListView321
		IsChecked := (ErrorLevel >> 12) - 1  ; 如果 RowNumber 为选中的则设置 IsChecked 为真, 否则为假.
		If IsChecked {
			LV_GetText(LVar_, A_Index , 2)
			If FileExist(LVar_) {
				AHKIni["FileLists",AHKIni["FileLists"].length()+1]:=LVar_, LV_Modify(A_Index, "-Check -Select -Focus"), result.= RegExReplace(LVar_,".+\\") "|"
			}else
				a.=LVar_ "`n"
		}
	}
	If (result){
		Index:=1, AHKIni.Save()
		GuiControl,99:,FilePathList, % result
	}
	If a
		TrayTip,,文件↓↓↓【`n%a%路径无效！】
	return Index
}

99GuiClose:
99GuiEscape:
	Gui, 99:Destroy
	AHKIni.Save()
Return

SendFile:
	Gosub ReadInis
	Loop,Parse,FileLisst2,|
	{
		If A_LoopField {
			WinClip.SetFiles(A_LoopField)   ;载入文件的路径
			fileslist := WinClip.GetFiles()
			WinClip.Paste()
			send, {Enter down}{Enter up}
		}
	}
return

SelectedFiles:    ;Alt+z打开文件选取窗口
	FileSelectFile, SelectedFile, M3, , 选择你需要发送的文件以添加至列表, Text Documents (*.txt; *.doc;*.docx;*.xls:*.xlsx;*.png;*.jpg;*.ahk)
	if (SelectedFile) {
		If SelectedFile~="\n" {
			FolderTittle:=""
			Loop, parse, SelectedFile, `n, `r
			{
				if (A_Index = 1)
					FolderTittle:=A_LoopField
				else
					AHKIni["FilePath",AHKIni["FilePath"].length()+1]:=FolderTittle "\" A_LoopField,AHKIni.Save(), LV_Add("",LV_GetCount()+1,FolderTittle "\" A_LoopField,"√")
			}
		}else{
			AHKIni["FilePath",AHKIni["FilePath"].length()+1]:=SelectedFile,AHKIni.Save(), LV_Add("",LV_GetCount()+1,SelectedFile,"√")
		}
		TrayTip,,选取成功！
	}
return

SaveFile:
	Loop,Parse,FilePathAll,`n,`r
		If A_LoopField
			AHKIni["FilePath",A_Index]:=A_LoopField, AHKIni.Save()
	Loop,Parse,FileLisst2,|
		If A_LoopField
			AHKIni["FileLists",A_Index]:=A_LoopField, AHKIni.Save()
return

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
return