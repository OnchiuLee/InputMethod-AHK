;词条拆分字根生成
split_wubizg(input){
	global DB
	If (input="")
		Return []
	else
	{
		if (strlen(input)=1)
		{
			If DB.gettable("SELECT A_Key FROM EtymologyChr WHERE aim_chars = '" input "'", Result){
				Result_ := Result.Rows[1,1]
			}
			Return RegExReplace(Result_,"\〔|\〕","")
		} else if (strlen(input)=2) {
			loop % 2
			{
				If DB.gettable("SELECT A_Key,B_Key FROM EtymologyPhrase WHERE aim_chars = '" SubStr(input,a_index,1) "'", Result){
					Result_part :=Result.Rows[1,1] . Result.Rows[1,2]
				}
				Result_ .=Result_part
			}
			Return Result_
		} else if (strlen(input)=3) {
			loop % 3
			{
				If DB.gettable("SELECT A_Key,B_Key FROM EtymologyPhrase WHERE aim_chars = '" SubStr(input,a_index,1) "'", Result){
					if a_index=3
						Result_part := Result.Rows[1,1] . Result.Rows[1,2]
					else
						Result_part := Result.Rows[1,1]
				}
				Result_ .=Result_part
			}
			Return Result_
		} else if (strlen(input)>3){
			loop % 4
			{
				if a_index=4
					SQL_chars :=SubStr(input,0,1)
				else
					SQL_chars :=SubStr(input,a_index,1)
				If DB.gettable("SELECT A_Key,B_Key FROM EtymologyPhrase WHERE aim_chars = '" SQL_chars "'", Result){
					Result_part := Result.Rows[1,1]
				}
				Result_ .=Result_part
			}
			Return Result_
		}
	}
}

;快捷置顶
set_top(list_num){
	global
	local selectvalue, Result
	If (list_num>ListNum)||(list_num=0)
		Return
	selectvalue:=srf_for_select_Array[list_num+ListNum*waitnum,1]
	selectvalue :=RegExReplace(selectvalue,"\#\〔.+","")
	if (lianx<>"on"&&Wubi_Schema ~="i)ci")
	{
		if (srf_for_select_Array.Length()>0){
			if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
				SQL:="UPDATE ci SET D_Key =(SELECT D_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[1,1] "')+20 WHERE aim_chars ='" selectvalue "';"
			else
				SQL:="UPDATE ci SET B_Key =(SELECT B_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[1,1] "')+20 WHERE aim_chars ='" selectvalue "';"
			if DB.Exec(SQL)>0 {
				Gosub srf_tooltip_fanye
				;TrayTip,, 置顶成功！置顶词条为「%srf_all_Input%-%selectvalue%」
			}else
				Traytip,,置顶失败!
		}
	}
	else
		TrayTip,, 置顶失败，不符合条件！
}

;候选前移一位
set_add(list_num){
	global
	local selectvalue, Result
	If (list_num>ListNum)||(list_num=0)
		Return
	selectvalue:=srf_for_select_Array[list_num+ListNum*waitnum,1]
	if (lianx<>"on"&&Wubi_Schema ~="i)ci"&&srf_all_Input~="^[a-y]+") {
		if (srf_for_select_Array.Length()>0){
			if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
				SQL:="UPDATE ci SET D_Key =(SELECT D_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[(list_num+ListNum*waitnum)-1,1] "')+1 WHERE aim_chars ='" selectvalue "';"
			else
				SQL:="UPDATE ci SET B_Key =(SELECT B_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[(list_num+ListNum*waitnum)-1,1] "')+1 WHERE aim_chars ='" selectvalue "';"
			if (DB.Exec(SQL)>0) {
				Gosub srf_tooltip_fanye
			}else
				Traytip,,调整失败!
		}
	}
	else
		TrayTip,, 调整失败，不符合条件！

}

;候选后移一位
set_next(list_num){
	global
	local selectvalue, Result
	If (list_num>ListNum)||(list_num=0)
		Return
	selectvalue:=srf_for_select_Array[list_num+ListNum*waitnum,1]
	if (lianx<>"on"&&Wubi_Schema ~="i)ci"&&srf_all_Input~="^[a-y]+")
	{
		if (srf_for_select_Array.Length()>0){
			if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
				SQL:="UPDATE ci SET D_Key =(SELECT D_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[(list_num+ListNum*waitnum)+1,1] "')-3 WHERE aim_chars ='" selectvalue "';"
			else
				SQL:="UPDATE ci SET B_Key =(SELECT B_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[(list_num+ListNum*waitnum)+1,1] "')-3 WHERE aim_chars ='" selectvalue "';"
			if DB.Exec(SQL)>0 {
				Gosub srf_tooltip_fanye
			}else
				Traytip,,调整失败!
		}
	}
	else
		TrayTip,, 调整失败，不符合条件！
}

;简体转繁体
set_trad_mode(Arrs){
	global DB
	If (Arrs.Length()<1)
		Return []
	else
	{
		ResultAll:=[]
		;PrintObjects(Arrs)
		for section,element in Arrs
			for key,value in Simp2Trad(element[1])
				ResultAll.push([value,split_wubizg(value),get_en_code(value)])
		Return ResultAll
	}
}

Simp2Trad(chars){
	global DB
	DB.gettable("SELECT A_Key FROM s2t WHERE aim_chars = '" chars "'", Result)
	If InStr(Result.Rows[1,1],A_space)
		Return StrSplit(Result.Rows[1,1],A_space)
	else If (Result.Rows[1,1]<>""){
		Return [Result.Rows[1,1]]
	}else{
		If !SubStr(chars,1,1)
			Return [chars]
		else{
			t_:=""
			loop,% strlen(chars)
			{
				DB.gettable("SELECT A_Key FROM s2t WHERE aim_chars = '" SubStr(chars,a_index,1) "'", Result)
					t_.=Result.Rows[1,1]?StrSplit(Result.Rows[1,1],A_space)[1]:SubStr(chars,a_index,1)
				
			}
			Return [t_]
		}
	}
}

/*
;自造词条编码生成
get_en_code(chars){
	global DB
	If (chars="")
		Return []
	else
	{
		if (strlen(chars)=1)
		{
			If DB.gettable("SELECT A_Key FROM EN_Chr WHERE aim_chars = '" chars "'", Result){
				Result_ := Result.Rows[1,1]
			}
			Return Result_
		}
		else if (strlen(chars)=2)
		{
			loop % 2
			{
				If DB.gettable("SELECT A_Key FROM EN_Chr WHERE aim_chars= '" SubStr(chars,a_index,1) "'", Result){
					Result_part := SubStr(Result.Rows[1,1],1,2)
				}
				Result_ .=Result_part
			}
			Return Result_
		}
		else if (strlen(chars)=3)
		{
			loop % 3
			{
				If DB.gettable("SELECT A_Key FROM EN_Chr WHERE aim_chars = '" SubStr(chars,a_index,1) "'", Result){
					If a_index=3
						Result_part := SubStr(Result.Rows[1,1],1,2)
					else
						Result_part := SubStr(Result.Rows[1,1],1,1)
				}
				Result_ .=Result_part
			}
			Return Result_
		}
		else if (strlen(chars)>3)
		{
			loop % 4
			{
				if a_index=4
					SQL_chars :=SubStr(chars,0,1)
				else
					SQL_chars :=SubStr(chars,a_index,1)
				If DB.gettable("SELECT A_Key FROM EN_Chr WHERE aim_chars = '" SQL_chars "'", Result){
					Result_part := SubStr(Result.Rows[1,1],1,1)
				}
				Result_ .=Result_part
			}
			Return Result_
		}
		else
		{
			Return chars
		}
	}
}
*/

;自造词条编码生成
get_en_code(chars){
	global DB, Wubi_Schema
	If (chars="")
		Return []
	else
	{
		If Wubi_Schema~="i)chaoji" {
			if (StrLen(chars)>1)
				DB.gettable("SELECT A_Key FROM chaoji WHERE aim_chars = '" chars "';", Result)
			else
				DB.gettable("SELECT A_Key FROM EN_Chr WHERE aim_chars = '" chars "';", Result)
			if (Result.Rows[1,1]<>"")
				Result_ := Result.Rows[1,1]
		}else{
			Loop,% StrLen(chars)
			{
				If DB.gettable("SELECT A_Key FROM EN_Chr WHERE aim_chars = '" SubStr(chars,a_index,1) "'", Result){
					if (strlen(chars)=1){
						Result_part := Result.Rows[1,1]
					}else{
					if (strlen(chars)=2)
							Result_part := SubStr(Result.Rows[1,1],1,2)
						else if (strlen(chars)=3){
							If (A_Index=3)
								Result_part := SubStr(Result.Rows[1,1],1,2)
							else
								Result_part := SubStr(Result.Rows[1,1],1,1)
						}if (strlen(chars)>3){
							If (A_Index<4||A_Index=strlen(chars))
								Result_part := SubStr(Result.Rows[1,1],1,1)
						}
					}
				}
				Result_ .=Result_part, Result_part:=""
			}
		}
		Return Result_
	}
}

Get_Phrase(bianma,citiao){
	global DB, Frequency, Prompt_Word, Trad_Mode
	If not bianma~="[a-z]+"
		Return 0
	if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
		DB.gettable("SELECT D_Key,C_Key,aim_chars FROM ci WHERE A_Key = '" bianma "' ORDER BY A_Key,D_Key DESC", Result)
	else
		DB.gettable("SELECT B_Key,C_Key,aim_chars FROM ci WHERE A_Key = '" bianma "' ORDER BY A_Key,B_Key DESC", Result)
	for section,element in Result.Rows
		If (element[3]=citiao)
			flag:=1
	cp:=Result.RowCount>2&&!flag?(Result.Rows[3,1]+2):Result.RowCount=2&&!flag?(Result.Rows[2,1]-2):Result.RowCount=1&&!flag?(Result.Rows[1,1]-2):!Result.RowCount&&!flag?64526534:0
	Return cp?cp:0
}

;造词结果保存
Save_word(chars){
	global Wubi_Schema, Frequency, Prompt_Word, Trad_Mode
	If (chars="")
		Return ["格式不对！"]
	else
	{
		If Chars~="\n" {
			startTime:= CheckTickCount()
			tarr:=[],count :=counts:=0
			totalCount:=CountLines(MaBiao), num:=totalCount>100?Ceil(totalCount/100):totalCount>50?Ceil(totalCount/10):Ceil(totalCount/5)
			Progress, M1 Y10 FM14 W350, 1/%totalCount%, 词条处理中..., 1`%
			Loop, Parse, Chars, `n, `r
			{
				If (A_LoopField = "")
					Continue
				If A_LoopField~="^[^\w]+$" {    ;纯词条
					citiao:=A_LoopField, bianma:=get_en_code(citiao), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
				}else If A_LoopField~="^.+\t[a-z]+$" {   ;单行单义无词频
					citiao:=RegExReplace(A_LoopField,"\t.+"), bianma:=RegExReplace(A_LoopField,".+\t"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
				}else If A_LoopField~="^[a-z]+\=.+" {    ;编码=词条
					citiao:=RegExReplace(A_LoopField,"^[a-z]+\="), bianma:=RegExReplace(A_LoopField,"(?<=[a-z])\=.+"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
				}else If A_LoopField~="^.+\t[a-z]+\t\d+" {   ;单行单义带词频
					citiao:=RegExReplace(A_LoopField,"\t([a-z]+)\t\d+$"), bianma:=RegExReplace(A_LoopField,citiao "\t|\t\d+$"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
				}
				If cipin 
					Insert_ci .="('" citiao "','" bianma "','" cipin "','" cipin "','" caifen "','" get_en_code(citiao) "')" ",", count++
				If (Mod(counts, num)=0) {
					tx :=Ceil(count/num)
					Progress, %tx% , %count%/%totalCount%`n, %tip%词库处理中..., 已完成%tx%`%
				}
			}
			Progress,off
		}else{
			count :=counts:=0
			If Chars~="^[^\w]+$" {    ;纯词条
				citiao:=Chars, bianma:=get_en_code(citiao), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
			}else If Chars~="^.+\t[a-z]+$" {   ;单行单义无词频
				citiao:=RegExReplace(Chars,"\t.+"), bianma:=RegExReplace(Chars,".+\t"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
			}else If Chars~="^[a-z]+\=.+" {    ;编码=词条
				citiao:=RegExReplace(Chars,"^[a-z]+\="), bianma:=RegExReplace(Chars,"(?<=[a-z])\=.+"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
			}else If Chars~="^.+\t[a-z]+\t\d+" {   ;单行单义带词频
				citiao:=RegExReplace(Chars,"\t([a-z]+)\t\d+$"), bianma:=RegExReplace(Chars,citiao "\t|\t\d+$"), caifen:=split_wubizg(citiao), cipin:=Get_Phrase(bianma,citiao), counts++
			}
			If cipin 
				Insert_ci .="('" citiao "','" bianma "','" cipin "','" cipin "','" caifen "','" get_en_code(citiao) "')" ",", count++
		}
		If Insert_ci
		{
			if DB.Exec("INSERT INTO ci(aim_chars,A_Key,B_Key,D_Key,E_Key,F_Key) VALUES " RegExReplace(Insert_ci,"\,$","") ";")>0
			{
				MaBiao:=Insert_ci:="", tarr:=[]
				Return [count,count<>counts?counts-count:0,CheckTickCount(startTime)]
			}else{
				MaBiao:=Insert_ci:="", tarr:=[]
				return ["格式不对！"]
			}
		}else{
			Chars:=Insert_ci:="", tarr:=[]
			 Return ["词条已存在，无需重复导入！"]
		}
	}
}

;「`」引导精准造词
format_word(input){
	global srf_bianma,code_status,select_arr,select_pos,selectallvalue,add_Result,add_Array
	If (input="")
		Return []
	if code_status&&!InStr(input,"``") {
		SQL :="SELECT aim_chars FROM ci WHERE A_Key = '" RegExReplace(input,"^" srf_bianma[srf_bianma.Length()]) "' AND Length(aim_chars)=1;" 
		If DB.GetTable(SQL, Result)
		{
			if (Result.Rows[1,1]<>""){
				Return Result.Rows
			}else if (Result.Rows[1,1]=""&&select_arr[1]<>""){
				Result.Rows.InsertAt(1, select_arr)
				Return Result.Rows
			}
		}
	}else if (select_arr[1]=""&&InStr(input,"``")){
		Split_l:=[]
		Split_code:=StrSplit(RegExReplace(input,"^``"), "``")
		Split_l:= Combin_Arr(Split_code,DB)
		SQL :="SELECT aim_chars FROM ci WHERE A_Key = '" Split_code[select_pos] "' AND Length(aim_chars)=1;"
		If DB.GetTable(SQL, Result)
		{
			if (Result.Rows[1,1]<>""){
				if (select_pos=1){
					Result.Rows.InsertAt(1, [Split_l[select_pos]])
					Result.Rows[1,2]:="☯",Result.Rows[1,3]:="☯"
				}else{
					Result.Rows.InsertAt(1, add_Array)
				}
			}else if (Result.Rows[1,1]=""&&add_Result[1]<>""){
				Result.Rows.InsertAt(1, add_Array)
			}
			Return Result.Rows
		}
	}
}

format_word_2(input){
	If (input="")
		Return []
	if (InStr(input,"``")){
		Split_l:=Result:=[], Split_code:=StrSplit(RegExReplace(input,"^``"), "``")
		Split_l:= Combin_Arr(Split_code,DB)
		;PrintObjects(Split_l)
		For key,value In Split_l
			Result.InsertAt(key, [value])
		Return Result
	}
}

;精准造词首位匹配组合
Combin_Arr(code_arr,DB){
	if !arrs.Length() {
		arrs:=[],TolValue:="",index:=0
		loop % code_arr.Length()
		{
			if code_arr[a_index] {
				If DB.GetTable("SELECT aim_chars FROM zi WHERE A_Key = '" code_arr[a_index] "'", Result)
				{
					if (Result.Rows[1,1]<>""){
						Index++
						loop, % Result.RowCount
						{
							arrs[Index,a_index]:=Result.Rows[a_index,1]
		}}}}}
	}
	;PrintObjects(arrs)
	For section,element In arrs
	{
		If (section=1)
			Result_:=element
		else
			Result_:=Array_total(Result_,element)
	}
	Return Result_
}

Array_total(r,s){
	If (!IsObject(r)||!IsObject(s))
		Return []
	Result:=[]
	for key,value in r 
		loop,% s.Length()
			Result.push(value s[a_index])
	;;PrintObjects(Result)
	Return Result
}

;精准造词选词
Select_add(list_num){
	global ListNum,srf_for_select_Array,waitnum,Select_result,select_value_arr
		,code_status,select_arr,srf_all_Input,srf_bianma,srfCounts,select_pos
		,selectallvalue,add_Result,add_Array
	If (list_num>ListNum)||(list_num=0)
		Return
	selectvalue:=srf_for_select_Array[list_num+ListNum*waitnum,1]
	if !InStr(RegExReplace(srf_all_Input,"^``"),"``"){
		code_status:=0, srfCounts++
		srf_bianma.push(RegExReplace(srf_all_Input,"^``"))
		Select_result .=select_value_arr[srfCounts]:=selectvalue
		if (!code_status){
			select_arr[1]:=Select_result, select_arr[2]:="☯", select_arr[3]:="☯", code_status:=1
			if (srf_for_select_Array[1]<>select_arr&&select_arr[1]<>""){
				srf_for_select_Array:=[],srf_for_select_Array.InsertAt(1, select_arr)
			}
			Gosub srf_tooltip_cut
		}
	}else{
		selectallvalue.=add_Result[select_pos]:=selectvalue,select_pos++
		add_Array[1]:=selectallvalue,add_Array[2]:="☯",add_Array[3]:="☯"
		srf_for_select_Array.InsertAt(1, add_Array)
		Gosub srf_tooltip_fanye
	}
}

;英文输入模式提词
Get_EnWord(input){
	If (input="")
		Return []
	SQL :="SELECT aim_chars FROM encode WHERE aim_chars LIKE '" input "%' ORDER BY A_Key DESC;"
	If DB.GetTable(SQL, Result){
		if !Result.Rows[1,1]
			Result.Rows[1,1]:=input,Result.Rows[2,1]:=StringUpper(input),Result.Rows[3,1]:=StringUpper(input,"T")
		Return Result.Rows
	}
}

get_Longword(input){
	global srf_all_Input, Wubi_Schema, Cut_Mode,DB
	If (input="")
		Return []
	If Cut_Mode~="on"
		SQL :="SELECT B_Key,Author,C_Key FROM TangSongPoetics WHERE A_Key LIKE '" input "%' ORDER BY A_Key ASC;"
	else
		SQL :="SELECT B_Key,C_Key,Author FROM TangSongPoetics WHERE A_Key LIKE '" input "%' ORDER BY A_Key ASC;"
	If DB.GetTable(SQL, Result){
		if Result.Rows[1,1] {
			loop,% Result.RowCount
				Result.Rows[a_index,Cut_Mode~="on"?2:3]:="〔 " Result.Rows[a_index,Cut_Mode~="on"?2:3] " 〕"
			Return Result.Rows
		}
	}
}

;词条提取
get_word(input, cikuname){
	global Frequency, Prompt_Word, Trad_Mode, PromptChar, srf_all_Input, lianx, CharFliter, zkey_mode
	If (input="")
		Return []
	If (cikuname~="chaoji|zi|ci|label|zg")
	{
		lianx :="", flag:=0
		if (srf_all_Input ~="z")
		{
			lianx :="on"
			if (srf_all_Input~="i)^z"&&!zkey_mode) {
				SQL :="SELECT aim_chars,C_Key,D_Key FROM pinyin WHERE REPLACE(A_key,' ','') ='" RegExReplace(input,"^z|'","") "' " (cikuname~="zi|chaoji"?"AND length(aim_chars)=1":"") " ORDER BY B_Key DESC;"
				If DB.GetTable(SQL, Result)
					Return Result.Rows
			}else if (srf_all_Input ~="^[a-y]+z$|^[a-y]+z[a-z]+$|^z[a-y]+$|^z[a-y]+z[a-y]+|^[a-y]+z[a-z]+z$|^z[a-y]+z$"&&zkey_mode){
				If cikuname~="i)ci"
					SQL :="SELECT aim_chars,E_Key,F_Key FROM ci WHERE A_Key LIKE '" RegExReplace(srf_all_Input,"z","_") "' ORDER BY A_Key,D_Key DESC;"   ;Length(aim_chars),
				else If cikuname~="i)chaoji|zi"
					SQL :="SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key LIKE '" RegExReplace(srf_all_Input,"z","_") "' ORDER BY A_Key,B_Key DESC;"
				else
					SQL :="SELECT aim_chars FROM " cikuname " WHERE A_Key LIKE '" RegExReplace(srf_all_Input,"z","_") "';"
				If DB.GetTable(SQL, Result)
					Return Result.Rows
			}
		}else if srf_all_Input ~="^[a-y]+"{
			if cikuname~="i)ci"{
				if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"){
					flag:=1
					if (PromptChar&&StrLen(input)<4)
						SQL :="SELECT aim_chars,E_Key,F_Key FROM(SELECT aim_chars,E_Key,F_Key FROM ci WHERE A_Key ='" input "' AND D_Key >0 ORDER BY A_Key,D_Key DESC) UNION ALL SELECT aim_chars,E_Key,F_Key FROM(SELECT aim_chars,E_Key,F_Key FROM ci WHERE A_Key LIKE'" input "_' AND D_Key >0 ORDER BY A_Key,D_Key DESC);"
					else
						SQL :="select aim_chars,E_Key,F_Key from ci WHERE A_Key ='" input "' AND D_Key >0 ORDER BY A_Key,D_Key DESC;"
				}else{
					if (PromptChar&&StrLen(input)<4)
						flag:=1, SQL :="SELECT aim_chars,E_Key,F_Key FROM(SELECT aim_chars,E_Key,F_Key FROM ci WHERE A_Key ='" input "' AND B_Key >0 ORDER BY A_Key,B_Key DESC) UNION ALL SELECT aim_chars,E_Key,F_Key FROM(SELECT aim_chars,E_Key,F_Key FROM ci WHERE A_Key LIKE'" input "_' AND B_Key >0 ORDER BY A_Key,B_Key DESC);"
					else
						SQL :="select aim_chars,E_Key,F_Key from ci WHERE A_Key ='" input "' AND B_Key >0 ORDER BY A_Key,B_Key DESC;"
				}
			}else{
				if cikuname~="i)zi"{
					if (PromptChar&&StrLen(input)<4)
						flag:=1, SQL :="SELECT aim_chars,C_Key,D_Key FROM(SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key = '" input "' " (CharFliter?"AND aim_chars=(SELECT Chars FROM GBChars WHERE chars=aim_chars)":"") " ORDER BY A_Key,B_Key DESC) UNION ALL SELECT aim_chars,C_Key,D_Key FROM(SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key LIKE '" input "_' " (CharFliter?"AND aim_chars=(SELECT Chars FROM GBChars WHERE chars=aim_chars)":"") " ORDER BY A_Key,B_Key DESC);"
					else
						SQL :="SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key = '" input "' " (CharFliter?"AND aim_chars=(SELECT Chars FROM GBChars WHERE chars=aim_chars)":"") " ORDER BY A_Key,B_Key DESC;"
				}else{
					if (PromptChar&&StrLen(input)<4)
					{
						flag:=1
						if cikuname~="i)zg"
							SQL :="SELECT aim_chars FROM " cikuname " WHERE A_Key = '" input "';"
						else
							SQL :="SELECT aim_chars,C_Key,D_Key FROM(SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key = '" input "' ORDER BY A_Key,B_Key DESC) UNION ALL SELECT aim_chars,C_Key,D_Key FROM(SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key LIKE'" input "_' ORDER BY A_Key,B_Key DESC);"
					}else{
						if cikuname~="i)zg"
							SQL :="SELECT aim_chars FROM " cikuname " WHERE A_Key = '" input "'" (not cikuname~="i)zg"?"ORDER BY A_Key,B_Key DESC":"") ";"
						else
							SQL :="SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key = '" input "'" (not cikuname~="i)zg"?"ORDER BY A_Key,B_Key DESC":"") ";"
					}
				}
			}
			If DB.GetTable(SQL, Result)
			{
				if (Result.Rows[1,1]=""&&strlen(input)>1&&Prompt_Word ~="on"&&not cikuname~="i)zg"&&!PromptChar||Result.Rows[1,1]=""&&strlen(input)<4&&Prompt_Word ~="on"&&not cikuname~="i)zg"&&!PromptChar)
				{
					DB.GetTable("SELECT ", Result)
					lianx :="on", flag:=1
					If cikuname~="i)ci"
						SQL :="SELECT aim_chars,E_Key,F_Key FROM(SELECT aim_chars,E_Key,F_Key FROM ci WHERE A_Key ='" input "' AND B_Key >0 ORDER BY A_Key,B_Key DESC) UNION ALL SELECT aim_chars,E_Key,F_Key FROM(SELECT aim_chars,E_Key,F_Key FROM ci WHERE A_Key LIKE'" input "_' AND B_Key >0 ORDER BY A_Key,B_Key DESC);"
					else If cikuname~="i)zi"
						SQL :="SELECT aim_chars,C_Key,D_Key FROM(SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key = '" input "' " (CharFliter?"AND aim_chars=(SELECT Chars FROM GBChars WHERE chars=aim_chars)":"") " ORDER BY A_Key,B_Key DESC) UNION ALL SELECT aim_chars,C_Key,D_Key FROM(SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key LIKE '" input "_' " (CharFliter?"AND aim_chars=(SELECT Chars FROM GBChars WHERE chars=aim_chars)":"") " ORDER BY A_Key,B_Key DESC);"
					else If cikuname~="i)chaoji"
						SQL :="SELECT aim_chars,C_Key,D_Key FROM(SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key = '" input "' ORDER BY A_Key,B_Key DESC) UNION ALL SELECT aim_chars,C_Key,D_Key FROM(SELECT aim_chars,C_Key,D_Key FROM " cikuname " WHERE A_Key LIKE'" input "_' ORDER BY A_Key,B_Key DESC);"
					else
						SQL :="SELECT aim_chars FROM " cikuname " WHERE A_Key = '" input "'" (not cikuname~="i)zg"?"ORDER BY A_Key,B_Key DESC":"") ";"
					DB.GetTable(SQL, Result)
				}
				if Trad_Mode~="off" {
					GetValues:=Result.Rows
					For Section, element In GetValues
					{
						index:=a_index, GetValues[section,3]:=(PromptChar&&flag||Prompt_Word~="i)on"&&flag)?(StrLen(input)<4&&input<>GetValues[section,3]?RegExReplace(GetValues[section,3],"^" input,"~"):""):""
						loop,% GetValues.Length()-index
						{
							If (GetValues[a_index+index,1]=GetValues[section,1])
								GetValues.RemoveAt(a_index+index)
							else
								GetValues[a_index+index,3]:=(PromptChar&&flag||Prompt_Word~="i)on"&&flag)?(StrLen(input)<4&&input<>GetValues[a_index+index,3]?RegExReplace(GetValues[a_index+index,3],"^" input,"~"):""):""
						}
					}
				;PrintObjects(GetValues)
				}else{
					lianx :="on"
					If not input~="z" {
						GetValues:=set_trad_mode(Result.Rows)
						For Section, element In GetValues
						{
							index:=a_index, GetValues[section,3]:=(PromptChar&&flag||Prompt_Word~="i)on"&&flag)?(StrLen(input)<4&&input<>GetValues[section,3]?RegExReplace(GetValues[section,3],"^" input,"~"):""):""
							loop,% GetValues.Length()-index
							{
								If (GetValues[a_index+index,1]=GetValues[section,1])
									GetValues.RemoveAt(a_index+index)
								else
									GetValues[a_index+index,3]:=(PromptChar&&flag||Prompt_Word~="i)on"&&flag)?(StrLen(input)<4&&input<>GetValues[a_index+index,3]?RegExReplace(GetValues[a_index+index,3],"^" input,"~"):""):""
							}
						}
					}else
						GetValues:=Result.Rows
				}
			;if strlen(input)>1
			;	PrintObjects(GetValues)
			}
			Return GetValues
		}
	}
}

TranSelectvalue(chars){
	if chars~="i)\\n"
		chars:=RegExReplace(chars,"\\n","`r`n")
	if chars~="i)\\t"
		chars:=RegExReplace(chars,"\\t","`t")
	if chars~="i)\\s"
		chars:=RegExReplace(chars,"\\s",A_space)
	Return chars
}

SwitchingScheme(n,Char){
	global WubiIni, srf_all_input, Wubi_Schema, srf_for_select_Array,localpos, Initial_Mode, EN_Mode
	flag:=0, n:=localpos>1&&n==1?localpos:n
	If srf_all_input~="\/sc$" {
		Wubi_Schema:=WubiIni.Settings["Wubi_Schema"] :=srf_for_select_Array[n,4]~="i)zi|ci|zg|chaoji"?srf_for_select_Array[n,4]:Wubi_Schema, flag:=1, WubiIni.save()
		EN_Mode:=WubiIni.Settings["EN_Mode"] :=srf_for_select_Array[n,4]~="i)en"?!EN_Mode:srf_for_select_Array[n,4]~="i)zi|ci|zg|chaoji"?0:EN_Mode
		if Wubi_Schema~="i)zi|zg"
			Gosub Disable_Tray
		else
			Gosub Enable_Tray
		Gosub SwitchSC
	}else If srf_all_input~="\/sp$" {
		Initial_Mode:=WubiIni.Settings["Initial_Mode"] :=srf_for_select_Array[n,4], flag:=1, WubiIni.save()
		Gosub SwitchSC
	}else if (IsLabel(Char)&&srf_all_Input~="^\/[a-z]+"){
			Gosub % Char
			flag:=1
	}
	Return flag
}

UpperScreenMode(TEXT){
	global srf_all_Input, Initial_Mode
	If (Initial_Mode ~="on"||srf_all_input~="^\/[a-z]+z$"&&strlen(srf_all_Input)>3)
	{
		WinClip.Snap( ClipSaved ), WinClip.Clear()
		WinClip.SetText( TEXT ), WinClip.Paste()
		WinClip.Restore( ClipSaved )
	}else
		SendInput % TEXT
	If srf_all_input~="^[a-y]+"
		updateRecent(TEXT)    ;写入历史记录
	if srf_all_Input~="^\``[a-y]+|^[a-y]{1,4}\``.+"
		Save_word(TEXT)
}

;选词
srf_select(list_num,thishotkey:=""){
	global
	local selectvalue, Result, Index, yhnum, tt, Match, lastvalue
	If (list_num>ListNum||list_num=0||list_num>srf_for_select_Array.Length())
		Return
	list_num:= localpos>1&&ToolTipStyle~="i)gdip"&&FocusStyle&&thishotkey~="i)space"?localpos:list_num
	selectvalue:=labelObj.Length()&&IsLabel(labelObj[list_num])?labelObj[list_num]:srf_for_select_Array[list_num+ListNum*waitnum,(srf_all_input~="^\/[a-z]+z$"&&strlen(srf_all_Input)>3?(Cut_Mode~="on"?3:2):1)]
	If SwitchingScheme(list_num,selectvalue) {
		Gosub srf_value_off
		Return
	}
	If (selectvalue~="\\n|\\t"&&srf_all_input~="^\/[a-z]+z$"&&strlen(srf_all_Input)>2&&!IsLabel(selectvalue), selectvalue_:="") {
		selectvalue_:= TranSelectvalue(selectvalue), selectvalue:=srf_for_select_Array[list_num+ListNum*waitnum,1] "`r`n" srf_for_select_Array[list_num+ListNum*waitnum,Cut_Mode~="on"?2:3] "`r`n" selectvalue_
	}
	UpperScreenMode(selectvalue)
	if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci"&&list_num>1&&srf_all_Input~="^[a-y]+$"&&srf_for_select_Array.Length()>1&&!EN_Mode){
		if (Frequency_obj[selectvalue,1]&&Frequency_obj[selectvalue,2]=srf_all_Input) {
			Frequency_obj[selectvalue,1]:=Frequency_obj[selectvalue,1]+1
			if (Frequency_obj[selectvalue,1]>Freq_Count) {
				Frequency_obj[selectvalue,1]:=0
			}else if (Frequency_obj[selectvalue,1]=Freq_Count){
				if DB.Exec("UPDATE ci SET D_Key =(SELECT D_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[1,1] "')+2 WHERE aim_chars ='" selectvalue "' AND A_Key ='" srf_all_Input "';")>0
					Frequency_obj[selectvalue,1]:=0
			}else{
				If list_num>2
					DB.Exec("UPDATE ci SET D_Key =(SELECT D_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[list_num-1+ListNum*waitnum,1] "')+2 WHERE aim_chars ='" selectvalue "' AND A_Key ='" srf_all_Input "';")
			}
			Json_ObjToFile(Frequency_Obj, A_ScriptDir "\Config\Script\wubi98_ci.json", "UTF-8")
		}else{
			Frequency_obj[selectvalue,1]:=1, Frequency_obj[selectvalue,2]:=srf_all_Input
			If list_num>2
				DB.Exec("UPDATE ci SET D_Key =(SELECT D_Key FROM ci WHERE aim_chars ='" srf_for_select_Array[list_num-1+ListNum*waitnum,1] "')+2 WHERE aim_chars ='" selectvalue "' AND A_Key ='" srf_all_Input "';")
			Json_ObjToFile(Frequency_Obj, A_ScriptDir "\Config\Script\wubi98_ci.json", "UTF-8")
		}
	}
	Gosub srf_value_off
}


;快捷删词
Delete_Word(list_num){
	global
	local selectvalue, Result, Index, yhnum, tt, Match
	If (list_num>ListNum)||(list_num=0)
		Return
	selectvalue:=srf_for_select_Array[list_num+ListNum*waitnum,1]
	selectvalue :=RegExReplace(selectvalue,"\#\〔.+","")
	if (lianx<>"on"&&Wubi_Schema ~="i)ci"){
		DB.gettable("SELECT B_Key,C_Key FROM ci WHERE aim_chars ='" selectvalue "'",Results)
		if (Results.Rows[1,1]>0&&Results.Rows[1,2]="")
			SQL:="delete FROM ci WHERE aim_chars ='" selectvalue "';"
		else if (Results.Rows[1,1]<>""&&Results.Rows[1,2]<>""){
			if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
				SQL :="UPDATE ci SET D_Key ='0' WHERE aim_chars ='" selectvalue "';"
			else
				SQL :="UPDATE ci SET B_Key ='0' WHERE aim_chars ='" selectvalue "';"
		}
		if srf_all_Input ~="[a-y]"&&lianx<>"on"&&Wubi_Schema ~="i)ci"{
			if DB.Exec(SQL)>0 {
				Gosub srf_tooltip_fanye
				;TrayTip,, 「%selectvalue%-%srf_all_Input%」删除成功
			}else
				TrayTip,, 条件不成立，删除失败！
		}
		else
			TrayTip,, 条件不成立，删除失败！
	}
}

;划词反查词条读音提取
get_single_py(chars){
	global
	If (chars="")
		Return []
	else if (chars ~="\d+|[a-z]+")
		Return []
	else
	{
		SQL_ :="SELECT * FROM PY WHERE aim_chars = '" chars "'"
		if DB.gettable(SQL_,Result){
			if Result.Rows[1,3]&&Result.Rows[1,4]
				Return Result.Rows[1,3] " • " Result.Rows[1,4]
			else If Result.Rows[1,3]&&!Result.Rows[1,4]
				Return Result.Rows[1,3]
		}
	}
}

;划词反查处理
Tip_rvlk(chars){
	global DB, Wubi_Schema
	rev_code :=RegExReplace(chars, "\d+|[a-zA-Z]{1,}|\s+|`n|\~|~[a-zA-Z]+", "")
	loop % wStrLen(rev_code)
	{
		If Wubi_Schema~="i)chaoji" {
			if !(GeteEnCode:=get_en_code(_code:=SubStr(rev_code, A_index, 2)))
				GeteEnCode:=get_en_code(_code:=SubStr(rev_code, A_index, 1))
			bianma:=get_single_py(_code)
			DB.GetTable("SELECT A_Key FROM EtymologyChr WHERE aim_chars = '" _code "'", Result)
			If (Result.Rows[1,1]<>""||GeteEnCode||bianma)
				rvlk_ :=_code . (Result.Rows[1,1]<>""?Result.Rows[1,1]:"") . "( " . GeteEnCode . (bianma?" ※ " . bianma:"") " )"
			if rvlk_
				rvlk_all .= rvlk_ . "`n", rvlk_:=""
		}else{
			SQL :="SELECT A_Key FROM EtymologyChr WHERE aim_chars = '" SubStr(rev_code, A_index, 1) "'" 
			If DB.GetTable(SQL, Result)
			{
				if Result.Rows[1,1]
					rvlk_ :=SubStr(rev_code, A_index, 1) . Result.Rows[1,1] . "( " . get_en_code(SubStr(rev_code, A_index, 1)) . " ※ " . get_single_py(SubStr(rev_code, A_index, 1)) " )"
				if rvlk_
					rvlk_all .= rvlk_ . "`n", rvlk_:=""
			}
		}
	}
	return rvlk_all
}

cut_word(chars_1,chars_2){
	global
	chars_1 :=RegExReplace(chars_1,"`n","")
	chars_2 :=RegExReplace(chars_2,"`n","")
	if strlen(chars_1)=1
	{
		Return chars_2
	}
	else if strlen(chars_1)=2
	{
		loop % strlen(chars_1)
		{
			Result_1 .= "※" . SubStr(RegExReplace(chars_2,"〔|\〕|\※|\s+|`n",""),1,4)
		}
		Result :=chars_1 . "〔" . Result_1 . "※〕"
		Return Result
	}
	else if strlen(chars_1)=3
	{
		loop % strlen(chars_1)
		{
			if a_index =3
				Result_2 .=SubStr(RegExReplace(chars_2,"〔|\〕|\※|\s+|`n",""),1,4)
			else
				Result_2 .=SubStr(RegExReplace(chars_2,"〔|\〕|\※|\s+|`n",""),1,2)
			Result_1 .= "※" . Result_2
		}
		Result :=chars_1 . "〔" . Result_1 . "※〕"
		Return Result
	}
	else if strlen(chars_1)>3
	{
		loop 4
		{
			if a_index =4
				Result_2 .=SubStr(RegExReplace(chars_2,"〔|\〕|\※|\s+|`n",""),0,2)
			else
				Result_2 .=SubStr(RegExReplace(chars_2,"〔|\〕|\※|\s+|`n",""),1,2)
			Result_1 .= "※" . Result_2
		}
		Result :=chars_1 . "〔" . Result_1 . "※〕"
		Return Result
	}
}

;英文词提取
prompt_enword(input){
	global
	If (input="")
		Return []
	SQL :="SELECT aim_chars FROM encode WHERE aim_chars LIKE '" input "%' ORDER BY A_Key DESC;"
	If DB.GetTable(SQL, Result){
		if !Result.Rows[1,1]
			Result.Rows[1,1]:=input,Result.Rows[2,1]:=StringUpper(input),Result.Rows[3,1]:=StringUpper(input,"T")
		Return Result.Rows
	}
}

;~键反查读音
prompt_pinyin(input){
	global DB, Wubi_Schema
	If (input="")
		Return []
	input:=RegExReplace(input,"~","")
	If Wubi_Schema~="i)ci"
		SQL:="select aim_chars from ci WHERE A_Key ='" input "' AND Length(aim_chars)=1 ORDER BY A_Key,B_Key DESC;"
	else If Wubi_Schema~="i)zi"
		SQL:="select aim_chars from zi WHERE A_Key ='" input "' ORDER BY A_Key,B_Key DESC;"
	else If Wubi_Schema~="i)chaoji"
		SQL:="select aim_chars from chaoji WHERE A_Key ='" input "' ORDER BY A_Key,B_Key DESC;"
	DB.GetTable(SQL, Result)
	prompt_result:=Result.Rows
	prompt_all:=[],count:=0
	if prompt_result[1,1]{
		loop % prompt_result.Length()
		{
			result_:=prompt_result[a_index,1]
			if (get_single_py(result_)){
				count++
				prompt_all[count,1]:=result_, prompt_all[count,2]:="〔 " get_single_py(result_) " 〕", prompt_all[count,3]:="〔 "get_single_py(result_) " 〕"
		}}
		Return prompt_all
	}
}

;标签提取
prompt_label(input){
	global DB
	If (input="")
		Return []
	SQL :="SELECT C_key,D_Key FROM label WHERE B_Key ='" RegExReplace(input,"/","") "'"
	If DB.GetTable(SQL, Result){
		if Result.Rows[1,1]
			Return Result.Rows
	}
}

;特殊符号提取
prompt_symbols(input){
	global DB, Cut_Mode, srf_all_Input, labelObj, Wubi_Schema, Initial_Mode, EN_Mode
	If (input="")
		Return []
	ResultAll:=[]
	DB.GetTable("SELECT A_Key FROM symbols WHERE aim_chars ='" input "'", Result_symbols), DB.GetTable("SELECT C_Key,D_Key FROM label WHERE B_Key ='" SubStr(input,2) "'", Result_label)
	If Result_symbols.RowCount>0
	{
		symbolsObj:=StrSplit(Result_symbols.Rows[1,1],",")
		for key,value in symbolsObj
			If value
				ResultAll.push([value])
		If Result_label.RowCount>0
			for section,element in Result_label.Rows
				if IsLabel(element[1])
					ResultAll.InsertAt(section,[RegExReplace(element[2],"\〔|\〕|\#")]), labelObj[section]:=element[1]
	}else{
		If Result_label.RowCount>0
		{
			for section,element in Result_label.Rows
				if IsLabel(element[1])
					ResultAll.push([RegExReplace(element[2],"\〔|\〕|\#")]), labelObj[section]:=element[1]
		}
		If (input~="^\/[0-9]{2,}"&&SubStr(input,2)>10) {
			If ResultAll.Length()>0
				for section,element in numTohz(RegExReplace(input,"^/",""))
					ResultAll.push(element)
			else
				ResultAll:=numTohz(RegExReplace(input,"^/",""))
		}
		scObject:={zznl:Get_LunarDate()
			,zzsj:Get_Time(),zzrq:Get_Date()
			,sc:[["含词",Wubi_Schema~="i)ci"&&!EN_Mode?"☯":"",Wubi_Schema~="i)ci"&&!EN_Mode?"☯":"","ci"],["单字",Wubi_Schema~="i)zi"&&!EN_Mode?"☯":"",Wubi_Schema~="i)zi"&&!EN_Mode?"☯":"","zi"],["超集",Wubi_Schema~="i)chaoji"&&!EN_Mode?"☯":"",Wubi_Schema~="i)chaoji"&&!EN_Mode?"☯":"","chaoji"],["英文",EN_Mode?"☯":"",EN_Mode?"☯":"","en"],["字根",Wubi_Schema~="i)zg"&&!EN_Mode?"☯":"",Wubi_Schema~="i)zg"&&!EN_Mode?"☯":"","zg"]]
			,sp:[["剪切板上屏",Initial_Mode~="i)on"?"☯":"",Initial_Mode~="i)on"?"☯":"","on"],["发送上屏",Initial_Mode~="i)off"?"☯":"",Initial_Mode~="i)off"?"☯":"","off"]]}
		For section,element in scObject
			If (section=SubStr(input,2)) {
				for key,value in element
					ResultAll.InsertAt(key,value)
			}
	}
	
	Return ResultAll
}

;模糊词提取
get_prompt_word(input, cikuname){
	global
	If (input="")
		Return []
	if strlen(input)>1&&strlen(input)<4
		SQL :="SELECT aim_chars FROM " cikuname " WHERE A_key LIKE '" input "_' ORDER by B_Key ASC"
	else
		SQL :="SELECT aim_chars FROM " cikuname " WHERE A_key = '" input "'"
	If DB.GetTable(SQL, Result)
	{
		loop, % Result.RowCount
		{
			Result.Rows[a_index,2]:=Prompt_Word~="on"?split_wubizg(Result.Rows[a_index,1]):RegExReplace(get_en_code(Result.Rows[a_index,1]),input)
		}
	}
	Return Result.Rows
}

;创建表
Create_Ci(DB,Name)
{
	global Wubi_Schema
	If !Name
		Return
	SQL:="DROP TABLE IF EXISTS " Wubi_Schema ";"
	DB.Exec(SQL)
	DB.Exec("BEGIN TRANSACTION;")
	if Wubi_Schema~="i)ci"
		_SQL := "CREATE TABLE ci ('aim_chars' TEXT,'A_Key' TEXT ,'B_Key' INTEGER,'C_Key' INTEGER,'D_Key' INTEGER,'E_Key' TEXT,'F_Key' TEXT);"
	else{
		If not Wubi_Schema~="i)zg"
			_SQL := "CREATE TABLE " Wubi_Schema " ('aim_chars' TEXT,'A_Key' TEXT ,'B_Key' INTEGER,'C_Key' TEXT,'D_Key' TEXT);"
		else
			_SQL := "CREATE TABLE " Wubi_Schema " ('aim_chars' TEXT,'A_Key' TEXT );"
	}
	DB.Exec(_SQL)
	DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_" Wubi_Schema "' ON '" Wubi_Schema "' ('A_Key');")
	DB.Exec("COMMIT TRANSACTION;VACUUM;")
}

;创建label表
Create_label(DB,Name){
	global
	If !Name
		Return
	DB.Exec("DROP TABLE IF EXISTS label;")
	DB.Exec("BEGIN TRANSACTION;")
	_SQL = CREATE TABLE label ("A_Key" INTEGER PRIMARY KEY AUTOINCREMENT,"B_Key" TEXT,"C_Key" TEXT,"D_Key" TEXT);
	DB.Exec(_SQL)
	DB.Exec("COMMIT TRANSACTION;VACUUM;")
}

;创建拼音表
Create_pinyin(DB){
	global
	DB.Exec("DROP TABLE IF EXISTS PY;")
	DB.Exec("BEGIN TRANSACTION;")
	_SQL = CREATE TABLE PY ("list" INTEGER PRIMARY KEY AUTOINCREMENT,"aim_chars" TEXT,"A_Key" TEXT,"B_Key" TEXT);
	DB.Exec(_SQL)
	DB.Exec("CREATE INDEX IF NOT EXISTS 'main'.'sy_PY' ON 'PY' ('aim_chars');")
	DB.Exec("COMMIT TRANSACTION;VACUUM;")
}

;创建encode&&symbols表
Create_En(DB,Name){
	global
	If !Name
		Return
	bd~="i)En"?(DB.Exec("DROP TABLE IF EXISTS encode;")):(DB.Exec("DROP TABLE IF EXISTS symbols;"))
	DB.Exec("BEGIN TRANSACTION;")
	If bd~="i)En"
		_SQL = CREATE TABLE encode ("aim_chars" TEXT,"A_Key" INTEGER);CREATE INDEX IF NOT EXISTS 'main'.'sy_encode' ON 'encode' ('aim_chars');
	else
		_SQL = CREATE TABLE symbols ("aim_chars" TEXT,"A_Key" TEXT);CREATE INDEX IF NOT EXISTS 'main'.'sy_symbols' ON 'symbols' ('aim_chars');
	DB.Exec(_SQL)
	
	DB.Exec("COMMIT TRANSACTION;VACUUM;")
}

CheckDB(DB,cikuName){
	if cikuName~="i)ci"
		SQL:="select * from sqlite_master where name='" cikuName "' and sql like '%E_Key%';"
	else
		SQL:="select * from sqlite_master where name='" cikuName "' and sql like '%C_Key%';"
	DB.GetTable(SQL,Result), count:=0
	If !Result.rowCount {
		if cikuName~="i)ci"
			SQL:="ALTER TABLE " cikuName " ADD COLUMN E_Key TEXT;ALTER TABLE " cikuName " ADD COLUMN F_Key TEXT;"
		else
			SQL:="ALTER TABLE " cikuName " ADD COLUMN C_Key TEXT;ALTER TABLE " cikuName " ADD COLUMN D_Key TEXT;"
		If DB.Exec(SQL)>0 {
			DB.GetTable("select * from " cikuName ";",Results), totalCount:=Results.RowCount, num:=Ceil(totalCount/100)
			tip:=cikuName~="i)ci"?"【含词】":cikuName~="i)zi"?"【单字】":"【超集】"
			Progress, M1 FM14 W350, 1/%totalCount%, %tip%词库整理中..., 已完成1`%
			For Section,element In Results.Rows
			{
				For key,value In element
				{
					if (key=1) {
						if cikuName~="i)ci"
							AlterChars:="('" value "','" Results.Rows[Section,2] "','" Results.Rows[Section,3] "','" Results.Rows[Section,4] "','" Results.Rows[Section,5] "','" split_wubizg(value) "','" get_en_code(value) "')" ","
						else
							AlterChars:="('" value "','" Results.Rows[Section,2] "','" Results.Rows[Section,3] "','" split_wubizg(value) "','" get_en_code(value) "')" "," 
					}
				}
				count++
				AlterCharsAll.=AlterChars
				If (Mod(count, num)=0) {
					tx :=Ceil(count/num)
					Progress, %tx% , %count%/%totalCount%`n, %tip%词库整理中..., 已完成%tx%`%
				}
			}
			DB.Exec("delete from " cikuname ";")
			if DB.Exec("INSERT INTO " cikuname " VALUES " RegExReplace(AlterCharsAll,"\,$") ";VACUUM")>0 {
				Traytip,,%tip%词库整理完成！
			}
			Progress,off
			AlterCharsAll:=""
			Return 1
		}
	}
}

CheckLabel(DB,labelArr){
	for key,value In labelArr
	{
		DB.GetTable("select B_Key from label_init where C_Key='" value[2] "';",Result)
		If !Result.RowCount
			DB.Exec("INSERT INTO label_init (B_Key,C_Key,D_Key) VALUES('" value[1] "','" value[2] "','#〔" value[3] "〕');INSERT INTO label (B_Key,C_Key,D_Key) VALUES('" value[1] "','" value[2] "','#〔" value[3] "〕');")
	}
}
