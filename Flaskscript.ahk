#Requires AutoHotkey v2.0
#SingleInstance Force

; ================= PATH CONFIGURATION =================
global LogPath := "C:\Program Files (x86)\Steam\steamapps\common\Path of Exile\logs\Client.txt"
global IniFile := A_ScriptDir "\poe_flask_settings.ini"
; ======================================================

global MacroEnabled := false
global InCombatZone := false
global LastFileSize := 0
global CurrentFlaskIndex := 1

global FlaskActive := [1, 1, 1, 1, 1]
global FlaskKeys   := ["1", "2", "3", "4", "5"]
global FlaskSec    := ["4.5", "4.5", "4.5", "4.5", "4.5"]
global FlaskMode   := ["Chain", "Chain", "Chain", "Chain", "Chain"]
global FlaskTimers := []
global cbControls  := []
global keyControls := []
global edControls  := []
global ddControls  := []

global SafeZones := [
    "Hideout", "Versteck",
    "Lioneye's Watch", "Löwenauges Wacht",
    "The Forest Encampment", "Das Waldlager",
    "The Sarn Encampment", "Das Lager von Sarn",
    "Highgate", "Hohe Pforte",
    "Overseer's Tower", "Turm des Aufsehers",
    "The Bridge Encampment", "Das Brückenlager",
    "Oriath Docks", "Docks von Oriath",
    "Oriath", "Karui Shores", "Karui-Ufer",
    "Kingsmarch", "The Rogue Harbour", "Der Räuberhafen",
    "Menagerie", "Mine Encampment", "Das Minenlager",
    "Aspirants' Plaza", "Platz der Aspiranten",
    "The Halls of the Dead", "Hallen der Toten",
    "Tane's Laboratory", "Tanes Laboratorium"
]

Loop 5 {
    i := A_Index
    FlaskActive[i] := IniRead(IniFile, "Flasks", "Active" i, 1)
    FlaskKeys[i]   := IniRead(IniFile, "Flasks", "Key" i, String(i))
    FlaskSec[i]    := IniRead(IniFile, "Flasks", "Sec" i, "4.5")
    FlaskMode[i]   := IniRead(IniFile, "Flasks", "Mode" i, "Chain")
    FlaskTimers.Push(PressSoloFlask.Bind(i))
}

MyGui := Gui("+AlwaysOnTop", "Path of Exile - Flask Manager")
MyGui.BackColor := "141210"
MyGui.SetFont("s9 cE0D0C0", "Georgia")

MyGui.Add("Text", "x15 y15 w330 cD0A060", "Active | Key | Interval (Sec.) | Mode:")

Loop 5 {
    i := A_Index
    yPos := 42 + (i - 1) * 35
    
    cb  := MyGui.Add("CheckBox", "x15 y" yPos " w60 cE0D0C0 Checked" FlaskActive[i], "Slot " i)
    edK := MyGui.Add("Edit", "x80 y" (yPos - 3) " w30 Center Background221F1B cFFFFFF", FlaskKeys[i])
    edS := MyGui.Add("Edit", "x118 y" (yPos - 3) " w50 Background221F1B cFFFFFF", FlaskSec[i])
    MyGui.Add("Text", "x172 y" yPos " cA09070", "Sec.")
    
    dd  := MyGui.Add("DropDownList", "x215 y" (yPos - 3) " w105 Background221F1B cE0D0C0", ["Chain", "Solo Timer"])
    dd.Choose(FlaskMode[i] == "Solo Timer" ? 2 : 1)
    
    cbControls.Push(cb)
    keyControls.Push(edK)
    edControls.Push(edS)
    ddControls.Push(dd)
}

BtnSave := MyGui.Add("Button", "x15 y225 w300 h32", "Save & Apply")
BtnSave.OnEvent("Click", SaveSettings)

MyGui.Add("Text", "x15 y268 w300 h1 0x10")

StatusText := MyGui.Add("Text", "x15 y278 w310 cFF4444", "Macro Status: OFF (F4)")
ZoneText   := MyGui.Add("Text", "x15 y300 w310 cA09070", "Zone: Waiting for change...")

MyGui.Add("Text", "x15 y325 w310 c706050", "F4 = Start/Stop | F5 = Show/Hide UI")

MyGui.SetFont("s7 c504840", "Georgia")
MyGui.Add("Text", "x215 y342 w105 Right", "made by Trashbit")

MyGui.Show("w335 h365")

if FileExist(LogPath) {
    FileObj := FileOpen(LogPath, "r")
    LastFileSize := FileObj.Length
    FileObj.Close()
} else {
    MsgBox("Client.txt could not be found!`nPlease check the 'LogPath' variable at the top of the script:`n" LogPath, "Path Error", "Icon!")
}

SetTimer(CheckZoneChange, 500)

F4:: {
    global MacroEnabled
    MacroEnabled := !MacroEnabled
    UpdateMacroState()
}

F5:: {
    if WinExist("ahk_id " MyGui.Hwnd)
        MyGui.Hide()
    else
        MyGui.Show()
}

SaveSettings(*) {
    global FlaskActive, FlaskKeys, FlaskSec, FlaskMode, cbControls, keyControls, edControls, ddControls, IniFile, MacroEnabled
    
    Loop 5 {
        i := A_Index
        FlaskActive[i] := cbControls[i].Value
        
        kVal := Trim(keyControls[i].Value)
        if (kVal == "")
            kVal := String(i)
        FlaskKeys[i] := kVal
        keyControls[i].Value := kVal
        
        rawVal := StrReplace(edControls[i].Value, ",", ".")
        if !IsNumber(rawVal) || (Float(rawVal) <= 0.1)
            rawVal := "4.0"
            
        FlaskSec[i] := rawVal
        edControls[i].Value := rawVal
        
        FlaskMode[i] := ddControls[i].Text
            
        IniWrite(FlaskActive[i], IniFile, "Flasks", "Active" i)
        IniWrite(FlaskKeys[i], IniFile, "Flasks", "Key" i)
        IniWrite(FlaskSec[i], IniFile, "Flasks", "Sec" i)
        IniWrite(FlaskMode[i], IniFile, "Flasks", "Mode" i)
    }
    
    if (MacroEnabled)
        UpdateMacroState()
        
    ToolTip("Settings saved successfully!")
    SetTimer(() => ToolTip(), -1500)
}

UpdateMacroState() {
    global MacroEnabled, StatusText, CurrentFlaskIndex, FlaskTimers, FlaskActive, FlaskMode, FlaskSec
    
    SetTimer(ProcessFlaskSequence, 0)
    Loop 5 {
        SetTimer(FlaskTimers[A_Index], 0)
    }
    
    if (MacroEnabled) {
        StatusText.Value := "Macro Status: ACTIVE (F4)"
        StatusText.Opt("c55FF55")
        
        CurrentFlaskIndex := 1
        SetTimer(ProcessFlaskSequence, -100)
        
        Loop 5 {
            i := A_Index
            if (FlaskActive[i] && FlaskMode[i] == "Solo Timer") {
                SetTimer(FlaskTimers[i], -Random(200, 800))
            }
        }
    } else {
        StatusText.Value := "Macro Status: OFF (F4)"
        StatusText.Opt("cFF4444")
    }
}

ProcessFlaskSequence() {
    global MacroEnabled, InCombatZone, FlaskActive, FlaskKeys, FlaskSec, FlaskMode, CurrentFlaskIndex
    
    if (!MacroEnabled)
        return
        
    startIndex := CurrentFlaskIndex
    foundIndex := 0
    
    Loop 5 {
        checkIdx := Mod(startIndex + A_Index - 2, 5) + 1
        if (FlaskActive[checkIdx] && FlaskMode[checkIdx] == "Chain") {
            foundIndex := checkIdx
            CurrentFlaskIndex := Mod(checkIdx, 5) + 1
            break
        }
    }
    
    if (!foundIndex) {
        SetTimer(ProcessFlaskSequence, -1000)
        return
    }
    
    if WinActive("ahk_class POEWindowClass") && InCombatZone {
        key := FlaskKeys[foundIndex]
        SendInput("{" key "}")
    }
    
    waitSec := Float(FlaskSec[foundIndex])
    waitMs := Round(waitSec * 1000)
    
    SetTimer(ProcessFlaskSequence, -waitMs)
}

PressSoloFlask(flaskIndex) {
    global MacroEnabled, InCombatZone, FlaskActive, FlaskKeys, FlaskSec, FlaskMode, FlaskTimers
    
    if (!MacroEnabled || !FlaskActive[flaskIndex] || FlaskMode[flaskIndex] != "Solo Timer")
        return
        
    if WinActive("ahk_class POEWindowClass") && InCombatZone {
        key := FlaskKeys[flaskIndex]
        SendInput("{" key "}")
    }
    
    baseMs := Round(Float(FlaskSec[flaskIndex]) * 1000)
    nextRun := Max(300, baseMs + Random(-80, 80))
    
    SetTimer(FlaskTimers[flaskIndex], -nextRun)
}

CheckZoneChange() {
    global LogPath, LastFileSize, InCombatZone, SafeZones, ZoneText
    if !FileExist(LogPath)
        return

    try {
        FileObj := FileOpen(LogPath, "r", "UTF-8")
        CurrentSize := FileObj.Length
        
        if (CurrentSize > LastFileSize) {
            FileObj.Seek(LastFileSize)
            NewLines := FileObj.Read()
            
            Loop Parse, NewLines, "`n", "`r" {
                Line := A_LoopField
                
                if (InStr(Line, "You have entered") || InStr(Line, "Ihr habt")) {
                    IsSafe := false
                    
                    for _, SafeName in SafeZones {
                        if InStr(Line, SafeName) {
                            IsSafe := true
                            break
                        }
                    }
                    
                    InCombatZone := !IsSafe
                    if (InCombatZone) {
                        ZoneText.Value := "Zone: Combat Area (Active)"
                        ZoneText.Opt("c55FF55")
                    } else {
                        ZoneText.Value := "Zone: Safe / Town (Paused)"
                        ZoneText.Opt("c70B0FF")
                    }
                }
            }
            LastFileSize := CurrentSize
        }
        FileObj.Close()
    }
}
