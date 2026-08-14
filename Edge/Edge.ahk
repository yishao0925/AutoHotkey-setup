#Requires AutoHotkey v2.0
; 引入 UIAutomation 函式庫 (請確保 UIA.ahk 和 UIA_Browser.ahk 在同一個資料夾)
#Include UIA.ahk
#Include UIA_Browser.ahk

#HotIf WinActive("ahk_exe msedge.exe")

; 批次建立 Ctrl + 1~5 以及 Ctrl + Shift + 1~5 (相對切換)
Loop 5 {
    Hotkey "^" A_Index, MoveTabsForward
    Hotkey "^+" A_Index, MoveTabsBackward
}

; 絕對跳轉：Ctrl + 0 切換到第一頁，Ctrl + 9 切換到最後一頁
^0::JumpToTab(1)
^9::JumpToTab("last")

; 新增：Ctrl + Shift + H 導至首頁 (對應 Edge 原生的 Alt + Home)
^+h::Send("!{Home}")

#HotIf

; ========== 以下為相對切換邏輯 (下 n 頁 / 上 n 頁) ==========

MoveTabsForward(ThisHotkey) {
    n := Integer(SubStr(ThisHotkey, -1))
    SwitchTabs(n)
}

MoveTabsBackward(ThisHotkey) {
    n := Integer(SubStr(ThisHotkey, -1))
    SwitchTabs(-n) 
}

SwitchTabs(offset) {
    try {
        cUIA := UIA_Browser("A")
        tabs := cUIA.GetTabs()
        total := tabs.Length
        
        if (total == 0)
            return

        currentIndex := 1
        for index, tab in tabs {
            if (tab.SelectionItemIsSelected) {
                currentIndex := index
                break
            }
        }
        
        targetIndex := currentIndex + offset
        
        ; 邊界卡死限制
        if (targetIndex > total)
            targetIndex := total
        if (targetIndex < 1)
            targetIndex := 1
            
        if (targetIndex != currentIndex)
            tabs[targetIndex].Click()
            
    } catch Error as err {
        ToolTip "UIAutomation 讀取稍慢，請重試"
        SetTimer () => ToolTip(), -2000
    }
}

; ========== 以下為絕對跳轉邏輯 (第一頁 / 最後一頁) ==========

JumpToTab(target) {
    try {
        cUIA := UIA_Browser("A")
        tabs := cUIA.GetTabs()
        total := tabs.Length
        
        if (total == 0)
            return
        
        ; 判斷是要去第一頁還是最後一頁
        targetIndex := (target == "last") ? total : target
            
        tabs[targetIndex].Click()
            
    } catch Error as err {
        ToolTip "UIAutomation 讀取稍慢，請重試"
        SetTimer () => ToolTip(), -2000
    }
}