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
		TrayTip,, 置顶失败，不符合条件！

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
		TrayTip,, 置顶失败，不符合条件！
}

;简体转繁体
set_trad_mode(Arrs){
	global DB
	If (Arrs.Length()<1)
		Return []
	else
	{
		ResultAll:=[]
		for k,v in Arrs
		{
			for Index,value in v
			{
				If (Index=1) {
					If (strlen(Arrs[k,Index])=1){
						DB.gettable("SELECT A_Key FROM s2t WHERE aim_chars = '" Arrs[k,1] "'", Result)
							if (Result.Rows[1,1]<>"") {
								for key,values in StrSplit(Result.Rows[1,1],A_space)
									ResultAll.push([values,split_wubizg(values),get_en_code(values)])
								
							}else
								ResultAll.push(Arrs[k])
					}else{
						_str:=longStr:=""
						loop,% strlen(Arrs[k,Index])
						{
							DB.gettable("SELECT A_Key FROM s2t WHERE aim_chars = '" SubStr(Arrs[k,Index],a_index,1) "'", Result)
							if (Result.Rows[1,1]<>"") {
								_str :=Result.Rows[1,1]
							}else
								_str :=SubStr(Arrs[k,Index],a_index,1)
							longStr.=_str
						}
						ResultAll.push([longStr,split_wubizg(longStr),get_en_code(longStr)])
					}
				}
			}
		}
		Return ResultAll
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

;造词结果保存
Save_word(chars){
	global
	If (chars="")
		Return []
	else
	{
		chars :=RegExReplace(RegExReplace(chars,"(`n){2,}","`n"),"^\s+|\s+$")
		count_1 :=0
		loop,parse,chars,`n
		{
			if A_LoopField ~="="
			{
				RegExMatch(A_LoopField, ".+(?=\=)", Chars_L)
				RegExMatch(A_LoopField, "(?<=\=).+", Chars_R)
				if (strlen(Chars_L)<5&&strlen(Chars_L)>1)
				{
					if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
						DB.gettable("SELECT D_Key,C_Key FROM ci WHERE A_Key = '" Chars_L "' ORDER BY A_Key,D_Key DESC", Result)
					else
						DB.gettable("SELECT B_Key,C_Key FROM ci WHERE A_Key = '" Chars_L "' ORDER BY A_Key,B_Key DESC", Result)
					frist_ci:= Result.RowCount>1?(Result.Rows[2,1]+2):Result.RowCount=1?(Result.Rows[1,1]-2):"64526534", CharsCF:=split_wubizg(Chars_R)
					SQL =INSERT INTO ci(aim_chars,A_Key,B_Key,D_Key,E_Key,F_Key) SELECT '%Chars_R%', '%Chars_L%', '%frist_ci%', '%frist_ci%', '%CharsCF%', '%Chars_L%' WHERE NOT EXISTS(SELECT 1 FROM ci WHERE aim_chars = '%Chars_R%' AND A_Key = '%Chars_L%');
					if DB.Exec(SQL)>0 
						count_1++
					else
						Traytip,,保存失败!
				}
			}else if A_LoopField ~="^.+\t[a-y]+"{
				RegExMatch(A_LoopField, ".+(?=\t)", Chars_L)
				RegExMatch(A_LoopField, "(?<=\t).+", Chars_R)
				if (strlen(Chars_R)<5&&strlen(Chars_R)>1)
				{
					if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
						DB.gettable("SELECT D_Key,C_Key FROM ci WHERE A_Key = '" Chars_R "' ORDER BY A_Key,D_Key DESC", Result)
					else
						DB.gettable("SELECT B_Key,C_Key FROM ci WHERE A_Key = '" Chars_R "' ORDER BY A_Key,B_Key DESC", Result)
					frist_ci:= Result.RowCount>1?(Result.Rows[2,1]+2):Result.RowCount=1?(Result.Rows[1,1]-2):"64526534", CharsCF:=split_wubizg(Chars_L)
					SQL =INSERT INTO ci(aim_chars,A_Key,B_Key,D_Key,E_Key,F_Key) SELECT '%Chars_L%', '%Chars_R%', '%frist_ci%', '%frist_ci%', '%CharsCF%', '%Chars_R%' WHERE NOT EXISTS(SELECT 1 FROM ci WHERE aim_chars = '%Chars_L%' AND A_Key = '%Chars_R%');
					if DB.Exec(SQL)>0 
						count_1++
					else
						Traytip,,保存失败!
				}
			}else if not A_LoopField ~="^[a-y0-9]|\t|\s+"{
				mb_code :=get_en_code(A_LoopField)
				If mb_code
				{
					if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci")
						DB.gettable("SELECT D_Key,C_Key FROM ci WHERE A_Key = '" mb_code "' ORDER BY A_Key,D_Key DESC", Result)
					else
						DB.gettable("SELECT B_Key,C_Key FROM ci WHERE A_Key = '" mb_code "' ORDER BY A_Key,B_Key DESC", Result)
					frist_ci:= Result.RowCount>1?(Result.Rows[2,1]+2):Result.RowCount=1?(Result.Rows[1,1]-1):"64526534", CharsCF:=split_wubizg(A_LoopField)
					SQL =INSERT INTO ci(aim_chars,A_Key,B_Key,D_Key,E_Key,F_Key) SELECT '%A_LoopField%', '%mb_code%', '%frist_ci%', '%frist_ci%', '%CharsCF%', '%mb_code%' WHERE NOT EXISTS(SELECT 1 FROM ci WHERE aim_chars = '%A_LoopField%' AND A_Key = '%mb_code%');
					if DB.Exec(SQL)>0 
						count_1++
					else
						Traytip,,保存失败!
				}
			}
		}
		Return count_1
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

;词条提取
get_word(input, cikuname){
	global Frequency, Prompt_Word, Trad_Mode, PromptChar, srf_all_Input, lianx
	If (input="")
		Return []
	If (cikuname~="chaoji|zi|ci|labal|zg")
	{
		lianx :="", flag:=0
		if input ~="^z"
		{
			lianx :="on"
			SQL :="SELECT aim_chars,C_Key,D_Key FROM pinyin WHERE REPLACE(A_key,' ','') ='" RegExReplace(input,"^z|'","") "' ORDER BY B_Key DESC;"
			If DB.GetTable(SQL, Result)
				Return Result.Rows
		}else if input ~="^[a-y]+"{
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
					GetValues:=[]
					For Section, element In Result.Rows
					{
						for key,value In element
						{
							if (key=1) {
								if !Array_isInValue(GetValues, value)
									GetValues[Section,1]:=value
							}else if (key>1&&GetValues[Section].Length()>0)
								GetValues[Section].push(key=3?(strlen(input)<>strlen(value)&&PromptChar&&flag||strlen(input)<>strlen(value)&&Prompt_Word~="i)on"&&flag?RegExReplace(value,"^" input,"~"):""):value)
						}
					}
				}else{
					lianx :="on", GetValues:=[], Result.Rows:=set_trad_mode(Result.Rows)
					For Section, element In Result.Rows
					{
						for key,value In element
						{
							If (key=1) {
								if (!Array_isInValue(GetValues, value)&&value)
									GetValues[Section,1]:=value
							}else if (key>1&&GetValues[Section].Length()>0&&value){
								GetValues[Section].push( key=3?(strlen(input)<>strlen(value)&&PromptChar||strlen(input)<>strlen(value)&&Prompt_Word~="i)on"?RegExReplace(value,"^" input,"~"):""):value)
							}
						}
					}
				}
			;if strlen(input)>1
			;	msgbox % PrintArr(GetValues)
			}
			Return GetValues
		}
	}
}

;选词
srf_select(list_num){
	global
	local selectvalue, Result, Index, yhnum, tt, Match, lastvalue
	If (list_num>ListNum)||(list_num=0)
		Return
	selectvalue:=srf_for_select_Array[list_num+ListNum*waitnum,1],CharsCount:=CharsCount+strlen(selectvalue)   ; ClipSaved := ClipboardAll
	if selectvalue~="\#\〔"
	{
		Gosub % RegExReplace(selectvalue,"\#\〔.+","")
	}else{
		if Initial_Mode ~="on"
		{
			Clipboard := selectvalue        ;Clipboard := StringUpper(selectvalue, "T")
			send ^v
			updateRecent(selectvalue)    ;写入历史记录
			if srf_all_Input~="^\``[a-z]"{
				Save_word(selectvalue)
			}
		}
		else
		{
			SendInput % selectvalue
			;SendInput % StringUpper(selectvalue, "T")
			updateRecent(selectvalue)    ;写入历史记录
			if srf_all_Input~="^\``[a-z]"{
				Save_word(selectvalue)
			}
	}}
	if (Frequency&&Prompt_Word~="off"&&Trad_Mode~="off"&&Wubi_Schema~="i)ci"&&list_num>1&&srf_all_Input~="^[a-y]+"&&srf_for_select_Array.Length()>1){
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
	srf_for_select_Array :=select_arr:=select_value_arr:=add_Array:=add_Result:=[], select_sym:=PosLimit:=0, srf_for_select_for_tooltip :=Result_arr:=Select_result:=selectallvalue:="",code_status:=localpos:=select_pos:=1
	;Clipboard :=ClipSaved
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
	global
	If (input="")
		Return []
	SQL :="SELECT A_key FROM symbols WHERE aim_chars ='" input "'"
	DB.GetTable(SQL_, Result_label)
	If DB.GetTable(SQL, Result)
		Result_label:=prompt_label(input)
		if Result.Rows[1,1]&&Result_label[1,1]{
			Result_:=Result.Rows[1,1]
			loop % Result_label.Length(){
				if Result_label[a_index,1]~="i)^A\_"{
					sj :=Result_label[a_index,1]
					loop,parse,sj,%A_space%
					{
						if not A_LoopField~="[a-z\_]"
							sj_:=A_LoopField
						else
							sj_:=%A_LoopField%
						_sj .=sj_
					}
					Result.Rows[a_index,1]:=_sj Result_label[a_index,2]
					_sj:=sj_:=
				}
				else
					Result.Rows[a_index,1]:=Result_label[a_index,1] Result_label[a_index,2]
			}
			loop,parse,Result_,`,
					Result.Rows[Result_label.Length()+a_index,1]:=A_LoopField
		}
		else if !Result.Rows[1,1]&&Result_label[1,1]{
			loop % Result_label.Length(){
				if Result_label[a_index,1]~="i)^A\_"{
					sj :=Result_label[a_index,1]
					loop,parse,sj,%A_space%
					{
						if not A_LoopField~="[a-z\_]"
							sj_:=A_LoopField
						else
							sj_:=%A_LoopField%
						_sj .=sj_
					}
					Result.Rows[a_index,1]:=_sj Result_label[a_index,2]
					_sj:=sj_:=
				}
				else
					Result.Rows[a_index,1]:=Result_label[a_index,1] Result_label[a_index,2]
			}
		}
		else if Result.Rows[1,1]&&!Result_label[1,1]{
			Result_:=Result.Rows[1,1]
			loop,parse,Result_,`,
				Result.Rows[a_index,1]:=A_LoopField
		}
		else
		{
			if strlen(input)>1&&srf_all_Input~="[a-zA-Z]"{
				if srf_all_Input~="i)zzsj|zzrq|zznl"{
					Result.Rows:=srf_all_Input~="i)zznl"?Get_LunarDate():(srf_all_Input~="i)zzrq"?Get_Date():Get_Time())
				}else{
					Result.Rows[1,1]:=RegExReplace(input,"^/","")
					Result.Rows[2,1]:=StringUpper(RegExReplace(input,"^/",""),"T")
					Result.Rows[3,1]:=StringUpper(RegExReplace(input,"^/",""))
				}
			}else if strlen(input)>1&&srf_all_Input~="[0-9]+"{
				Result.Rows:=numTohz(RegExReplace(input,"^/",""))
			}
		}
	Return Result.Rows
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
	DB.GetTable(SQL,Result)
	If !Result.rowCount {
		if cikuName~="i)ci"
			SQL:="ALTER TABLE " cikuName " ADD COLUMN E_Key TEXT;ALTER TABLE " cikuName " ADD COLUMN F_Key TEXT;"
		else
			SQL:="ALTER TABLE " cikuName " ADD COLUMN C_Key TEXT;ALTER TABLE " cikuName " ADD COLUMN D_Key TEXT;"
		If DB.Exec(SQL)>0 {
			DB.GetTable("select * from " cikuName ";",Results)
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
				AlterCharsAll.=AlterChars
			}
			DB.Exec("delete from " cikuname ";")
			if DB.Exec("INSERT INTO " cikuname " VALUES " RegExReplace(AlterCharsAll,"\,$") "")>0 {
				Traytip,,导入完成！
			}
			AlterCharsAll:=""
			Return 1
		}
	}
}
