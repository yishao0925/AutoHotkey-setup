#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================================================
; 全域設定
; =========================================================
A_MenuMaskKey := "vkE8"

; =========================================================
; 解決 IME 緩衝區衝突的專用輸出函式 (雙重阻斷版)
; =========================================================
SendSafeKey(key) {
    ; 1. 阻斷按鍵前的狀態 (處理原本的 Shift 點擊)
    Send("{Blind}{vkE8}")
    
    ; 2. 讓 AHK 送出標準按鍵 (AHK 這裡會自動放開再按下 Shift)
    Send(key)
    
    ; 3. 阻斷按鍵後的狀態 (消除 AHK 自動還原 Shift 所造成的真空期)
    Send("{Blind}{vkE8}")
}

; 精準判斷：相容 Win10/Win11 新版微軟注音的中/英狀態
IsBopomofoChinese() {
    hwnd := WinActive("A")
    if !hwnd
        return false
    
    threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0)
    hkl := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
    if ((hkl & 0xFFFF) != 0x0404)
        return false
        
    imeHwnd := DllCall("Imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    if !imeHwnd
        return false

    convMode := DllCall("SendMessage", "Ptr", imeHwnd, "UInt", 0x0283, "Ptr", 0x0001, "Ptr", 0, "Ptr")
    return (convMode & 1) != 0
}

; =========================================================
; 全域符號映射 (JIS 轉 美規 ANSI 實體按鍵)
; =========================================================

; 1. P 右邊：印 @ (Shift+2) / `
$[::SendSafeKey("+2")
+$[::SendSafeKey("``")

; 2. @ 右邊：印 [ / { (Shift+[)
$]::SendSafeKey("[")
+$]::SendSafeKey("+[")

; 3. [ 右邊：印 ] / } (Shift+])
$sc02b::SendSafeKey("]")
+$sc02b::SendSafeKey("+]")

; 5. + 右邊：印 : (Shift+;) / * (Shift+8)
$'::SendSafeKey("+;")
+$'::SendSafeKey("+8")

; 6. 數字鍵 2：印 " (Shift+')
+$2::SendSafeKey("+'")

; 7. 數字鍵 6：印 & (Shift+7)
+$6::SendSafeKey("+7")

; 8. 數字鍵 7：印 ' 
+$7::SendSafeKey("'")

; 9. 數字鍵 8：印 ( (Shift+9)
+$8::SendSafeKey("+9")

; 10. 數字鍵 9：印 ) (Shift+0)
+$9::SendSafeKey("+0")

; 11. 數字鍵 0：印 0
+$0::SendSafeKey("0")

; 13. ? 鍵右邊那顆鍵 (sc073)：印 \ / _ (Shift+-)
$sc073::SendSafeKey("\")
+$sc073::SendSafeKey("+-")

; 14. = 右邊那顆鍵：印 ^ (Shift+6) / ~ (Shift+`)
$=::SendSafeKey("+6")
+$=::SendSafeKey("+``")

; 15. Backspace 左邊那顆 (sc07d)：印 ¥ / | (Shift+\)
$sc07d::SendSafeKey("{Text}¥") ; ⚠️ 詳見下方說明
+$sc07d::SendSafeKey("+\")


; =========================================================
; 條件映射：僅在「非注音【中文】模式」時生效
; =========================================================
#HotIf !IsBopomofoChinese()

; 12. 單按 - 鍵 / Shift + - 印 =
$-::SendSafeKey("-")
+$-::SendSafeKey("=")

; 16. 單按 ; 印 ; / Shift + ; 印 + (Shift+=)
$;::SendSafeKey(";")
+$;::SendSafeKey("+=")

#HotIf