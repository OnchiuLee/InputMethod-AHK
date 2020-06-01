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
Gregorian:
公历日期 格式 YYYYMMDD
<返回值>
农历日期 中文 天干地支属相
*/
Date_GetLunarDate(Gregorian)
{
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

	;分解公历年月日
	StringLeft,Year,Gregorian,4
	StringMid,Month,Gregorian,5,2
	StringMid,Day,Gregorian,7,2
	if (Year>2100 Or Year<1900)
	{
		errorinfo=无效日期
		return,errorinfo
	}

	;获取两百年内的农历数据
	Pos:=(Year-1900)*8+1 
	StringMid,Data0,LunarData,%Pos%,7
	Pos+=8
	StringMid,Data1,LunarData,%Pos%,7

	;判断农历年份
	Analyze(Data1,MonthInfo,LeapInfo,Leap,Newyear)
	Date1=%Year%%Newyear%
	Date2:=Gregorian
	EnvSub,Date2,%Date1%,Days
	If Date2<0					;和当年农历新年相差的天数
	{
		Analyze(Data0,MonthInfo,LeapInfo,Leap,Newyear)
		Year-=1
		Date1=%Year%%Newyear%
		Date2:=Gregorian
		EnvSub,Date2,%Date1%,Days
	}
	;计算农历日期
	Date2+=1
	LYear:=Year		;农历年份，就是上面计算后的值
	if Leap			;有闰月
	{
		StringLeft,p1,MonthInfo,%Leap%
		StringTrimLeft,p2,MonthInfo,%Leap%
		thisMonthInfo:=p1 . LeapInfo . p2
	}
	Else
		thisMonthInfo:=MonthInfo
	loop,13
	{
		StringMid,thisMonth,thisMonthInfo,%A_index%,1
		thisDays:=29+thisMonth
		if Date2>%thisDays%
			Date2:=Date2-thisDays
		Else
		{
			if leap
			{
				If leap>=%a_index%
					LMonth:=A_index
				Else
					LMonth:=A_index-1
			}
			Else
				LMonth:=A_index
			LDay:=Date2
			Break
		}
	}
	LDate=%LYear%年%LMonth%月%LDay%		;完成
;~ 	MsgBox,% LDate
	;转换成习惯性叫法
	Tiangan=甲,乙,丙,丁,戊,已,庚,辛,壬,癸
	Dizhi=子,丑,寅,卯,辰,巳,午,未,申,酉,戌,亥
	Shengxiao=鼠,牛,虎,兔,龙,蛇,马,羊,猴,鸡,狗,猪
	loop,Parse,Tiangan,`,
		Tiangan%a_index%:=A_LoopField
	loop,Parse,Dizhi,`,
		Dizhi%a_index%:=A_LoopField
	loop,Parse,Shengxiao,`,
		Shengxiao%a_index%:=A_LoopField
	Order1:=Mod((LYear-4),10)+1
	Order2:=Mod((LYear-4),12)+1
	LYear:=Tiangan%Order1% . Dizhi%Order2% . "(" . Shengxiao%Order2% . ")"

	yuefen=正,二,三,四,五,六,七,八,九,十,十一,腊
	loop,Parse,yuefen,`,
		yuefen%A_index%:=A_LoopField
	LMonth:=yuefen%LMonth%

	rizi=初一,初二,初三,初四,初五,初六,初七,初八,初九,初十,十一,十二,十三,十四,十五,十六,十七,十八,十九,二十,廿一,廿二,廿三,廿四,廿五,廿六,廿七,廿八,廿九,三十
	loop,Parse,rizi,`,
		rizi%A_index%:=A_LoopField
	LDay:=rizi%LDay%
	StringRight, wk, A_YWeek, 2
	LDate = %LYear%年农历%LMonth%月%LDay%
	Return,LDate
}

;获取农历时辰
Time_GetShichen(time)
{
	shichen :=["子时（夜半｜『三更』）","丑时（鸡鸣｜『四更』）","丑时（鸡鸣｜『四更』）","寅时（平旦｜『五更』）","寅时（平旦|『五更』）","卯时（日出）","卯时（日出）","辰时（食时）","辰时（食时）","巳时（隅中）","巳时（隅中）","午时（日中）","午时（日中）","未时（日昳）","未时（日昳）","申时（哺时）","申时（哺时）","酉时（日入）","酉时（日入）","戌时（黄昏｜『一更』）","戌时（黄昏｜『一更』）","亥时（人定｜『二更』）","亥时（人定｜『二更』）","子时（夜半｜『三更』）"]
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
Dot_To(Int,st){
	;Int:数字
	;st:简繁状态0为简体1为繁体
	if Int contains .
	{
		if RegExMatch(Int, "\.\d+\.|\.\.")>0
			Return "无效数字"
		static Dot :=["角","分","厘","毫"]
		,num_t :=["壹","貳","叁","肆","伍","陆","柒","捌","玖"]
		,num_s :=["一","二","三","四","五","六","七","八","九"]
		if Int~="[a-z]|\.$"
			Return "无效数字"
		Int_ :=RegExReplace(Int,"\..+","")
		Int :=RegExReplace(Int,".+\.","")
		Loop, Parse, Int
		{
			if A_loopfield ~="0"{
				if (A_index==4)
					continue
				else
					b :=(st=1?"零":"〇")
			}
			else if A_index>4
				continue
			else
				b :=(st=1?num_t[A_loopfield]:num_s[A_loopfield]) Dot[A_index]
			c .=b
		}
		if (not Int_ ~="[a-z]"&&Strlen(Int)<5)
			c_ :=(NumToC(Int_,st)?(NumToC(Int_,st) "元"):"") RegExReplace(RegExReplace(c,"[〇零]$"),"[〇零]{2,}",st=1?"零":"〇")
		else
			c_ :="无效数字"
	}else{
		if not Int~="[a-z]"
			c_ :=(NumToC(Int,st)?NumToC(Int,st):(st=1?"零":"〇")) (Strlen(Int)<17?"元整":"")
		else
			c_ :="无效数字"
	}
	return c_
}
;------------------------数字转中文--------------------
NumToC(n,st){
	;n:数字
	;st:简繁状态0为简体1为繁体
	n+=0
	if not n~="^[1-9]\d*$"
		Return
	static    o_t:=["壹","貳","叁","肆","伍","陆","柒","捌","玖"]
	,o:=["一","二","三","四","五","六","七","八","九"]
	,b:=["","十","百","千"]
	,b_t:=["","拾","佰","仟"]
	,m:=["","万","亿","兆"]
	,m_t:=["","萬","億","兆"]
	z:=false    ;之前位是否为0
	,l:=StrLen(n)+1
	,s:=Mod(l-1,4)+1
	,c:=""    ;保存结果
	Loop, Parse, n
	{
		if Mod(--l,4)=0
			s:=4
		if(A_LoopField=0){
			s--
			,z:=true
		}else if z{
			if (A_Index=3&&Strlen(n)=6||A_Index=3&&Strlen(n)=10||A_Index=3&&Strlen(n)=14)
				c.="" ,z:=false
			else
			{
				(st==1)?(c.="零"):(c.="〇"), z:=false
			}
		}
		else if Strlen(n)>16
			Return "位数超限"
		_:=Mod(l-1,4)+1
		,c.=(st==1?o_t[A_LoopField]:o[A_LoopField]) . (A_LoopField?(st==1?b_t[_]:b[_]):"") . ((!b[_] && s)?(st==1?m_t[(l+3)//4]:m[(l+3)//4]):"")
	}
	if c~="^一十$|^壹拾$"
		c:=SubStr(c,2)
	;if c~="[^零].[拾佰仟]$|[^〇].[十百千]$"
		;c:=SubStr(c,1,-1)
	return c
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

；==================简繁转换====================
;两个参数 一个是要转换的数据，一个是转换方式，如果只填一个 就是简转繁 第二个参数填1 就是繁转简
S2T(j,r:=""){
	static c:=S2T_()
	if r
		{
		for i,n in c
			if InStr(j,i)
				stringReplace,j,j,% i,% n,1
		}
	else
		{
		for i,n in c
			if InStr(j,n)
				stringReplace,j,j,% n,% i,1
		}
	Return j
}

;统计简繁字个数
ver_st(j,r:=""){
	static c:=S2T_()
	if r
		{
		for i,n in c
			if InStr(j,i)
				return 1 ;判断是简体  有参数1 此处说明是繁体
		}
	else
		{
		for i,n in c
			if InStr(j,n)
				return 0 ;判断是繁体  有参数1 此处说明是简体
		}
}

S2T_(){
	SetWorkingDir %A_ScriptDir%
	;FileRead,n,%A_ScriptDir%\script\zhengjian.txt   ;用简繁码表进行转换时 启用
	FileRead,n,%A_ScriptDir%\script\Trad.txt  ;统计繁体字个数用
	j:=[], n:=Trim(n)
	Loop,Parse,n,% A_Space
		j[SubStr(A_Loopfield,1,1)]:=SubStr(A_Loopfield,2)
	Return j
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

;===================执行批获取================

cmdClipReturn(command){
	cmdInfo:=""
	Clip_Saved :=ClipboardAll
	ClipWait,2
	try{
		Clipboard:=""
		Run,% ComSpec " /C " command " | CLIP", , Hide
		ClipWait,2
		cmdInfo:=Clipboard
	}catch{}
	Clipboard :=Clip_Saved
	return cmdInfo
}

Combin_Arr(code_arr,DB){
	arrs:=[],Index:=0
	loop % code_arr.Length()
	{
		if code_arr[a_index] {
			SQL :="SELECT aim_chars FROM zi WHERE A_Key = '" code_arr[a_index] "'",Index++
			If DB.GetTable(SQL, Result)
			{
				if (Result.Rows[1,1]<>""){
					loop, % Result.RowCount
					{
						arrs[Index,a_index]:=Result.Rows[a_index,1]
					}
				}
			}
		}
	}
	loop,% arrs[1].length()
	{
		if (arrs.length()=1)
			code_all.= arrs[1,A_index] "`n"
		loop,% arrs[2].length()
		{
			if (arrs.length()=2)
				code_all.= arrs[1,A_index] arrs[2,A_index] "`n"
			loop,% arrs[3].length()
			{
				if (arrs.length()=3)
					code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] "`n"
				loop,% arrs[4].length()
				{
					if (arrs.length()=4)
						code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] "`n"
					loop,% arrs[5].length()
					{
						if (arrs.length()=5)
							code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] arrs[5,A_index] "`n"
						loop,% arrs[6].length()
						{
							if (arrs.length()=6)
								code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] arrs[5,A_index] arrs[6,A_index] "`n"
							loop,% arrs[7].length()
							{
								if (arrs.length()=7)
									code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] arrs[5,A_index] arrs[6,A_index] arrs[7,A_index] "`n"
								loop,% arrs[8].length()
								{
									if (arrs.length()=8)
										code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] arrs[5,A_index] arrs[6,A_index] arrs[7,A_index] arrs[8,A_index] "`n"
									loop,% arrs[9].length()
									{
										if (arrs.length()=9)
											code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] arrs[5,A_index] arrs[6,A_index] arrs[7,A_index] arrs[8,A_index] arrs[9,A_index] "`n"
										loop,% arrs[10].length()
										{
											if (arrs.length()=10)
												code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] arrs[5,A_index] arrs[6,A_index] arrs[7,A_index] arrs[8,A_index] arrs[9,A_index] arrs[10,A_index] "`n"
											loop,% arrs[11].length()
											{
												if (arrs.length()=11)
													code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] arrs[5,A_index] arrs[6,A_index] arrs[7,A_index] arrs[8,A_index] arrs[9,A_index] arrs[10,A_index] arrs[11,A_index] "`n"
												loop,% arrs[12].length()
												{
													if (arrs.length()>=12)
														code_all.= arrs[1,A_index] arrs[2,A_index] arrs[3,A_index] arrs[4,A_index] arrs[5,A_index] arrs[6,A_index] arrs[7,A_index] arrs[8,A_index] arrs[9,A_index] arrs[10,A_index] arrs[11,A_index] arrs[12,A_index] "`n"
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return StrSplit(RegExReplace(code_all,"\n$"), "`n")
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

ListFonts(){
	VarSetCapacity(logfont, 128, 0), NumPut(1, logfont, 23, "UChar")
	obj := []
	DllCall("EnumFontFamiliesEx", "ptr", DllCall("GetDC", "ptr", 0), "ptr", &logfont, "ptr", RegisterCallback("EnumFontProc"), "ptr", &obj, "uint", 0)
	For font in obj
		If !InStr(font, "@")
			list .= "|" font
	Return LTrim(list,"|")
}
EnumFontProc(lpFont, tm, fontType, lParam){
	obj := Object(lParam)
	obj[StrGet(lpFont+28)] := 1
	Return 1
}

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

numTohz(num)
{
	num_switch:=[]
	num_switch[1,1] :=Dot_To(num,0),num_switch[2,1] := Dot_To(num,1),num_switch[3,1] := (num ~="[a-z\,\.]"?"无效日期":(Date_GetLunarDate(num) and strlen(num)>=10?(Date_GetLunarDate(SubStr(num,1,8)) . (Date_GetLunarDate(SubStr(num,1,8))<>"无效日期"?Time_GetShichen(SubStr(num,9,2)):"")):Date_GetLunarDate(num))), num_switch[4,1] :=Conv_LunarDate(num)
	return num_switch
}

Conv_LunarDate(num){
	lds:=Date_GetDate(SubStr(num,1,8),1), ldt:=Date_GetDate(SubStr(num,1,8),0), ld:=TransDate(ldt), ldp:=TransDate(lds)
	Return (ldt~="\d+"?"公元":"") ld (lds~="\d+"&&ld<>ldp?"/" . ldp:"")
}

Get_LunarDate(){
	sj:=[]
	FormatTime, MIVar, , H
	FormatTime, RQVar, , yyyyMMdd
	lunar :=Date_GetLunarDate(RQVar)
	lunar_time :=Time_GetShichen(MIVar)
	sj[1,1]:=lunar . lunar_time
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
	sj[5,1]:=Days_Count(RQVar)
	sj[2,1]:=date
	sj[3,1]:=RQVar1
	sj[4,1]:=RQVar2
	sj[1,1]:=TransDate(RQVar)
	Return sj
}

TransDate(chars){
	if (chars="")
		Return
	rq:={y:{1:"一", 2:"二", 3:"三", 4:"四", 5:"五", 6:"六", 7:"七", 8:"八", 9:"九", 0:"〇"}
		, m:{1:"一月", 2:"二月", 3:"三月", 4:"四月", 5:"五月", 6:"六月", 7:"七月", 8:"八月", 9:"九月", 10:"十月", 11:"十一月", 12:"十二月"}
		, d:{1:"一", 2:"二", 3:"三", 4:"四", 5:"五", 6:"六", 7:"七", 8:"八", 9:"九", 10:"十", 11:"十一", 12:"十二", 13:"十三", 14:"十四", 15:"十五", 16:"十六", 17:"十七"
		, 18:"十八", 19:"十九", 20:"二十",21:"二十一", 22:"二十二", 23:"二十三", 24:"二十四", 25:"二十五", 26:"二十六", 27:"二十七", 28:"二十八", 29:"二十九", 30:"三十", 31:"三十一"}}
	if (Strlen(chars)=8){
		loop, 4
		{
			yy .=rq.y[SubStr(chars,A_Index,1)]
			
		}
		Return yy "年" rq.m[SubStr(chars,5,2)] rq.d[SubStr(chars,7,2)] (SubStr(chars,7,2)<32&&SubStr(chars,7,2)>0?"日":"")
	}else{
		Return "无效数字"
	}
}

Get_Time(){
	sj:=[]
	StringRight, wk, A_YWeek, 2
	FormatTime, TimeVar1, , tth时mm分ss秒
	FormatTime, TimeVar2, , H:mm:ss
	FormatTime, TimeVar3, , yyyy/MM/dd H:mm:ss
	time=%TimeVar1%%A_MSec%"
	sj[1,1]:=TimeVar1,sj[2,1]:=TimeVar2,sj[3,1]:=TimeVar3,sj[4,1]:=time
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
	Return y "年已过了" sum "天|剩余" (IsLeap(y)?366-sum:365-sum) "天"
}

GetCaretPos(){
	Static init
	If (A_CaretX=""){
		Caretx:=Carety:=CaretH:=CaretW:=0
		If (!init)
			init:=DllCall("LoadLibrary","Str","oleacc","Ptr")
		VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8
		, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
		, NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
		if (DllCall("oleacc\AccessibleObjectFromWindow", "Ptr",WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0){
			Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
			Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
			, CaretX:=NumGet(x,0,"int"), CaretY:=NumGet(y,0,"int"), CaretH:=NumGet(h,0,"int")
		}
		If (Caretx=0&&Carety=0){
			MouseGetPos, x, y
			Return {x:x,y:y,h:35}
		} ELse
			Return {x:Caretx,y:Carety,h:Max(Careth,35)}
	} Else
		Return {x:A_CaretX,y:A_CaretY,h:35}
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

;导入单义码表加词频
Transform_cp(chars){
	Traytip,,正在转换。。。
	CpCount:=0
	loop,parse, chars, `n, `r
	{
		if A_LoopField
		{
			CpCount:=bianma<>bianma_?1:CpCount++
			RegExMatch(A_LoopField, "^.+(?=\t[a-z])", citiao)
			RegExMatch(A_LoopField, "(?<=.\t)[a-z]+$", bianma)
			cp :=citiao A_Tab bianma A_Tab (34526534-A_Index*CpCount-A_Index*24)
			cip .=cp "`r`n", cp:=""
		}
	}
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
		,FocusRadius,FocusCodeColor

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
			TPosObj[A_Index] := Gdip_MeasureString2(G, Textobj[A_Index], hFont, hFormat, RC), TPosObj[A_Index,2]:=mh
			, mh += TPosObj[A_Index,4]+FontSize*0.35, mw:=Max(mw,TPosObj[A_Index,3]), TPosObj[A_Index,1]:=CodePos[1]
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index] := Gdip_MeasureString2(G, Textobj[0,A_Index], hFont, hFormat, RC), TPosObj[0,A_Index,2]:=mh
			, mh += TPosObj[0,A_Index,4]+FontSize*0.35, mw:=Max(mw,TPosObj[0,A_Index,3]), TPosObj[0,A_Index,1]:=CodePos[1]
		Loop % Textobj.Length()
			TPosObj[A_Index,3]:=mw
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index,3]:=mw
		mw+=2*xoffset, mh+=yoffset
	} Else {
		t:=xoffset, mh+=hoffset
		TPosObj[1] := Gdip_MeasureString2(G, Textobj[1], hFont, hFormat, RC), TPosObj[1,2]:=mh, TPosObj[1,1]:=t, t+=TPosObj[1,3]+hoffset
		Loop % (Textobj.Length()-1){
			TPosObj[A_Index+1] := Gdip_MeasureString2(G, Textobj[A_Index+1], hFont, hFormat, RC)
			If (ListNum>5&&FontSize>18&&Cut_Mode~="on"&&srf_for_select_Array.Length()>5||codetext~="\/\d+"&&Strlen(codetext)>5)
				mw:=Max(mw,t), TPosObj[A_Index+1,1]:=xoffset, mh+=TPosObj[A_Index,4]+FontSize*0.35, TPosObj[A_Index+1,2]:=mh, t:=xoffset+TPosObj[A_Index+1,3]+hoffset
			else
				TPosObj[A_Index+1,1]:=t, TPosObj[A_Index+1,2]:=TPosObj[A_Index,2], t+=TPosObj[A_Index+1,3]+hoffset
		}
		mw:=Max(mw,t)
		mh+=TPosObj[TPosObj.Length(),4]
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index] := Gdip_MeasureString2(G, Textobj[0,A_Index], hFont, hFormat, RC), TPosObj[0,A_Index,1]:=xoffset, TPosObj[0,A_Index,2]:=mh, mh += TPosObj[0,A_Index,4], mw:=Max(mw,TPosObj[0,A_Index,3])	
		Loop % Textobj[0].Length()
			TPosObj[0,A_Index,3]:=mw-xoffset
		mw+=xoffset, mh+=yoffset
	}
	SelectObject(hdc, obm), DeleteObject(hbm), Gdip_DeleteGraphics(G),mh:=mh+FontSize*0.2, mw:=mw>Gdip_MeasureString2(G, codetext, hFont, hFormat, RC)[3]?(Textobj.length()>0?mw-FontSize*(Textdirection~="horizontal"?0.76:0.4)+(codetext~="\d"?(Strlen(codetext)>4?Strlen(codetext)*1.5:Strlen(codetext)*5):Strlen(codetext)):mw):Gdip_MeasureString2(G, codetext, hFont, hFormat, RC)[3]+FontSize
	hbm := CreateDIBSection(mw, mh), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetTextRenderingHint(G, 4)
	; 背景色
	Gdip_FillRoundedRectangle(G, pBrush[Bg], 0, 0, mw-2, mh-2, Radius~="i)on"?Gdip_Radius:0)
	; 编码
	if (Gdip_Line ~="i)off")
		Gdip_FillRoundedRectangle(G, pBrush[FocusCode], Textobj.length()>0?FontSize*0.3:FontSize*0.18, FontSize/5, Gdip_MeasureString2(G, codetext, hFont, hFormat, RC)[3]+(Textobj.Length()>0?Strlen(codetext):0), Gdip_MeasureString2(G, codetext, hFont, hFormat, RC)[4], FocusRadius*0.6)
	CreateRectF(RC, Textobj.length()>0?CodePos[1]:CodePos[1]-FontSize/4, CodePos[2]-FontSize*(codetext~="[a-z0-9]"?0.12:-0.1), w-30, h-30), Gdip_DrawString(G, codetext, hFont, hFormat, pBrush[FontCode], RC)
	Loop % Textobj.Length()
		If (A_Index=localpos){
			Gdip_FillRoundedRectangle(G, pBrush[FocusBack], TPosObj[A_Index,1]-FontSize*0.15, TPosObj[A_Index,2]-FontSize*0.1, codetext~="\d"?TPosObj[A_Index,3]+FontSize*0.4:TPosObj[A_Index,3]-FontSize*0.2, TPosObj[A_Index,4]+FontSize*0.38, FocusRadius)  ;焦点背景圆弧
			, CreateRectF(RC, codetext~="\d"?TPosObj[A_Index,1]:TPosObj[A_Index,1]-FontSize*0.48, TPosObj[A_Index,2]+fontoffset+FontSize*0.28, w-30, h-30), Gdip_DrawString(G, Textobj[A_Index], hFont, hFormat, pBrush[Focus], RC)
		}Else
			CreateRectF(RC, codetext~="\d"?TPosObj[A_Index,1]:TPosObj[A_Index,1]-FontSize*0.62, TPosObj[A_Index,2]+fontoffset+FontSize*0.28, w-30, h-30), Gdip_DrawString(G, Textobj[A_Index], hFont, hFormat, pBrush[Font], RC)
	Loop % Textobj[0].Length()
		CreateRectF(RC, TPosObj[0,A_Index,1], TPosObj[0,A_Index,2], w-30, h-30), Gdip_DrawString(G, Textobj[0,A_Index], hFont, hFormat, pBrush[Font], RC)

	; 边框、分隔线
	Gdip_DrawRoundedRectangle(G, pPen_Border, 0, 0, mw-2, mh-2, Radius~="i)on"?Gdip_Radius:0)
	Gdip_Line ~="i)on"?(Gdip_DrawLine(G, pPen_Line, xoffset, CodePos[4]+CodePos[2]-FontSize*0.1, mw-xoffset, CodePos[4]+CodePos[2]-FontSize*0.1), Gdip_DeletePen(pPen_Line)):""
	UpdateLayeredWindow(@TSF, hdc, tx:=mw>MaxRight?0:(x+mw>MaxRight?MaxRight-mw:x), ty:=mh>MaxBottom?0:(y+mh>MaxBottom?y-mh-35:(x+mw>MaxRight?y-mh-35:y)), mw, mh)
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