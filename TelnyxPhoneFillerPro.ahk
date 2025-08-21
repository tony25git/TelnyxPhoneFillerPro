; =====================================================
; Telnyx Phone Filler Pro - AutoHotkey v2 Compatible
; Advanced Phone Number Automation Tool
; =====================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; Global variables
RawPhoneNumbers := []
FormattedPhoneNumbers := []
CurrentPhoneIndex := 1
SelectedFormat := "raw"
CustomFormats := Map()

; Initialize custom formats
CustomFormats["+1 Format"] := "+1XXXXXXXXXX"
CustomFormats["Dots Format"] := "XXX.XXX.XXXX"
CustomFormats["Parentheses"] := "(XXX) XXX-XXXX"
CustomFormats["International"] := "+1 XXX XXX XXXX"
CustomFormats["Range Extended"] := "XXX*XXX*XXXX*XXXX"
CustomFormats["LexSE Format"] := "XXX XXX XXXX XXXX"

; Global flag for LexSE consecutive number handling
skipNextPhone := false

; Create main GUI
MainGui := Gui("+Resize", "Telnyx Phone Filler Pro")

; Header
MainGui.Add("Text", "x10 y10 w400 Center", "Telnyx Phone Filler Pro")
MainGui.Add("Text", "x10 y35 w400 Center", "Advanced Phone Number Automation Tool")

; Recording Section
MainGui.Add("GroupBox", "x10 y60 w400 h140", "Recording Controls")
StartRecordBtn := MainGui.Add("Button", "x20 y80 w90 h25", "Start Record")
SimpleRecordBtn := MainGui.Add("Button", "x120 y80 w90 h25", "Simple Record")
ClearActionsBtn := MainGui.Add("Button", "x220 y80 w90 h25", "Clear Actions")
SaveActionsBtn := MainGui.Add("Button", "x320 y80 w80 h25", "Save Actions")
MainGui.Add("Text", "x20 y110", "Workflow Type:")
WorkflowSelect := MainGui.Add("DropDownList", "x20 y125 w200", ["Neustar", "Lex", "LexSE", "Verizon", "VFO", "Chrome"])
WorkflowSelect.Choose(1)  ; Default to Neustar
MainGui.Add("Text", "x20 y150 w120", "Recorded Actions:")
ActionCountText := MainGui.Add("Text", "x140 y150 w50", "0")
LoadActionsBtn := MainGui.Add("Button", "x220 y145 w90 h25", "Load Actions")
MainGui.Add("Text", "x20 y170 w360 c0x666666", "Instructions will appear here when recording starts")

; Phone Numbers Section
MainGui.Add("GroupBox", "x10 y210 w400 h120", "Phone Numbers")
MainGui.Add("Text", "x20 y230", "Phone Numbers (one per line):")
PhoneNumbersEdit := MainGui.Add("Edit", "x20 y250 w370 h60 VScroll")
LoadNumbersBtn := MainGui.Add("Button", "x20 y315 w80 h25", "Load Numbers")
LoadFromFileBtn := MainGui.Add("Button", "x110 y315 w100 h25", "Load from File")
PhoneCountText := MainGui.Add("Text", "x220 y318 w170", "No numbers loaded")

; Format Selection Section
MainGui.Add("GroupBox", "x10 y340 w400 h180", "Phone Number Formats")
FormatDashRadio := MainGui.Add("Radio", "x20 y360 w360 Checked", "888-888-8888 (single numbers with dashes)")
FormatDashRangeRadio := MainGui.Add("Radio", "x20 y380 w360", "888-888-8888-8888 (ranges: full first number + last 4 digits)")
FormatSpaceRadio := MainGui.Add("Radio", "x20 y400 w360", "888 888 8888 (single numbers with spaces)")
FormatSpaceRangeRadio := MainGui.Add("Radio", "x20 y420 w360", "888 888 8888 8888 (ranges: full first number + last 4 digits)")

MainGui.Add("Text", "x20 y450 w100", "Custom Format:")
CustomFormatSelect := MainGui.Add("DropDownList", "x20 y470 w200")
ManageCustomBtn := MainGui.Add("Button", "x230 y470 w70 h23", "Manage")
ApplyFormatBtn := MainGui.Add("Button", "x310 y470 w80 h23", "Apply Format")
CustomFormatPreview := MainGui.Add("Text", "x20 y500 w360", "Preview: Select a custom format to see preview")

; Playback Section
MainGui.Add("GroupBox", "x10 y530 w400 h100", "Playback Controls")
PlayActionsBtn := MainGui.Add("Button", "x20 y550 w90 h25", "Play Actions")
StopPlayBtn := MainGui.Add("Button", "x120 y550 w90 h25", "Stop Play")
PlaySingleBtn := MainGui.Add("Button", "x220 y550 w90 h25", "Play Single")
PausePlayBtn := MainGui.Add("Button", "x320 y550 w80 h25", "Pause")
MainGui.Add("Text", "x20 y580 w360 c0x008800", "✓ Background Mode: Always ON - Use mouse/keyboard freely")
SlowModeCheck := MainGui.Add("Checkbox", "x20 y600 w160", "Slow Mode (Java Apps)")
MainGui.Add("Text", "x20 y620 w360", "Automation runs in background without interrupting your work")

; Status Section
MainGui.Add("GroupBox", "x10 y660 w400 h80", "Status")
MainGui.Add("Text", "x20 y680", "Status:")
StatusText := MainGui.Add("Text", "x70 y680 w320", "Ready - Load numbers and record your workflow")
MainGui.Add("Text", "x20 y700", "Current Phone:")
CurrentPhoneText := MainGui.Add("Text", "x100 y700 w300", "None loaded")
MainGui.Add("Text", "x20 y720", "Progress:")
ProgressBar := MainGui.Add("Progress", "x80 y718 w120 h15")
ProgressText := MainGui.Add("Text", "x210 y720 w50", "0 / 0")
MainGui.Add("Text", "x270 y720", "Mouse:")
MousePosText := MainGui.Add("Text", "x310 y720 w90", "X:0 Y:0")

; Initialize Workflow Manager
WorkflowMgr := WorkflowManager()

; Update custom formats dropdown
UpdateCustomFormatsList()

; Event handlers
StartRecordBtn.OnEvent("Click", StartRecord)
SimpleRecordBtn.OnEvent("Click", StartSimpleRecord)
ClearActionsBtn.OnEvent("Click", ClearActions)
SaveActionsBtn.OnEvent("Click", SaveActions)
LoadActionsBtn.OnEvent("Click", LoadActions)
LoadNumbersBtn.OnEvent("Click", LoadNumbers)
LoadFromFileBtn.OnEvent("Click", LoadFromFile)
ApplyFormatBtn.OnEvent("Click", ApplyFormat)
PlayActionsBtn.OnEvent("Click", PlayActions)
StopPlayBtn.OnEvent("Click", StopPlay)
PlaySingleBtn.OnEvent("Click", PlaySingle)
PausePlayBtn.OnEvent("Click", PausePlay)
ManageCustomBtn.OnEvent("Click", ManageCustomFormats)
CustomFormatSelect.OnEvent("Change", UpdateCustomFormat)
WorkflowSelect.OnEvent("Change", ChangeWorkflow)
MainGui.OnEvent("Close", (*) => ExitApp())

; Show GUI
MainGui.Show("w420 h760")

; Start mouse position tracking
SetTimer(UpdateMousePosition, 100)

; Update mouse position display
UpdateMousePosition() {
    global MousePosText
    MouseGetPos(&x, &y)
    MousePosText.Text := "X:" . x . " Y:" . y
}

; =====================================================
; Background Automation Helper Functions
; =====================================================

; Send click to window without activating it
BackgroundClick(x, y, hwnd, button := "Left") {
    try {
        ; Convert screen coordinates to window-relative coordinates
        WinGetPos(&winX, &winY, , , hwnd)
        relX := x - winX
        relY := y - winY
        
        ; Try ControlClick first
        result := ControlClick("x" . relX . " y" . relY, hwnd, , button)
        if (result) {
            return true
        }
        
        ; If ControlClick fails, try PostMessage method
        if (button == "Left") {
            lParam := (relY << 16) | (relX & 0xFFFF)
            PostMessage(0x201, 1, lParam, , hwnd)  ; WM_LBUTTONDOWN
            Sleep(10)
            PostMessage(0x202, 0, lParam, , hwnd)  ; WM_LBUTTONUP
        } else if (button == "Right") {
            lParam := (relY << 16) | (relX & 0xFFFF)
            PostMessage(0x204, 2, lParam, , hwnd)  ; WM_RBUTTONDOWN
            Sleep(10)
            PostMessage(0x205, 0, lParam, , hwnd)  ; WM_RBUTTONUP
        }
        return true
    } catch {
        return false
    }
}

; Send text to window without activating it
BackgroundSendText(text, hwnd, ctrlName := "") {
    try {
        if (ctrlName != "") {
            ; Send to specific control
            ControlSetText(text, ctrlName, hwnd)
            return true
        } else {
            ; Try to find the focused control
            focusedControl := ControlGetFocus(hwnd)
            if (focusedControl != "") {
                ControlSetText(text, focusedControl, hwnd)
                return true
            }
            
            ; Fallback: send character by character using PostMessage
            for char in StrSplit(text) {
                charCode := Ord(char)
                PostMessage(0x102, charCode, 0, , hwnd)  ; WM_CHAR
                Sleep(5)
            }
            return true
        }
    } catch {
        return false
    }
}

; Send key combination to window without activating it
BackgroundSendKey(key, hwnd) {
    try {
        ; Handle special keys
        if (InStr(key, "^")) {  ; Ctrl key
            PostMessage(0x100, 0x11, 0, , hwnd)  ; WM_KEYDOWN for Ctrl
            Sleep(10)
            
            ; Extract the actual key after ^
            actualKey := StrReplace(key, "^", "")
            if (actualKey == "a") {
                PostMessage(0x100, 0x41, 0, , hwnd)  ; WM_KEYDOWN for 'A'
                Sleep(10)
                PostMessage(0x101, 0x41, 0, , hwnd)  ; WM_KEYUP for 'A'
            } else if (actualKey == "c") {
                PostMessage(0x100, 0x43, 0, , hwnd)  ; WM_KEYDOWN for 'C'
                Sleep(10)
                PostMessage(0x101, 0x43, 0, , hwnd)  ; WM_KEYUP for 'C'
            } else if (actualKey == "v") {
                PostMessage(0x100, 0x56, 0, , hwnd)  ; WM_KEYDOWN for 'V'
                Sleep(10)
                PostMessage(0x101, 0x56, 0, , hwnd)  ; WM_KEYUP for 'V'
            }
            
            PostMessage(0x101, 0x11, 0, , hwnd)  ; WM_KEYUP for Ctrl
        } else if (key == "{Tab}") {
            PostMessage(0x100, 0x09, 0, , hwnd)  ; WM_KEYDOWN for Tab
            Sleep(10)
            PostMessage(0x101, 0x09, 0, , hwnd)  ; WM_KEYUP for Tab
        } else {
            ; Regular key
            keyCode := Ord(StrUpper(key))
            PostMessage(0x100, keyCode, 0, , hwnd)  ; WM_KEYDOWN
            Sleep(10)
            PostMessage(0x101, keyCode, 0, , hwnd)  ; WM_KEYUP
        }
        return true
    } catch {
        return false
    }
}

; =====================================================
; Workflow System Classes
; =====================================================

; Base class for all workflows
class BaseWorkflow {
    name := ""
    actions := []
    currentActionIndex := 1
    isRecording := false
    isPlaying := false
    singlePlayMode := false
    phonePartCounter := 0
    targetWindow := ""
    backgroundMode := false
    slowMode := false
    
    ; Constructor
    __New(workflowName) {
        this.name := workflowName
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0
    }
    
    ; Abstract methods - each workflow must implement these
    StartRecording() {
        throw Error("StartRecording() must be implemented by workflow class")
    }
    
    StopRecording() {
        throw Error("StopRecording() must be implemented by workflow class")
    }
    
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        throw Error("ExecuteAction() must be implemented by workflow class")
    }
    
    GetRecordingInstructions() {
        throw Error("GetRecordingInstructions() must be implemented by workflow class")
    }
    
    ; Common methods all workflows can use
    RecordAction(actionData) {
        this.actions.Push(actionData)
        return this.actions.Length
    }
    
    ClearActions() {
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0
    }
    
    GetActionCount() {
        return this.actions.Length
    }
    
    ResetPlayback() {
        this.currentActionIndex := 1
        this.singlePlayMode := false
        this.isPlaying := false
    }
    
    SetPlaybackMode(isSingle := false) {
        this.singlePlayMode := isSingle
        this.currentActionIndex := 1
    }
    
    SetPlaybackSettings(background := true, slow := false, targetWin := "") {
        this.backgroundMode := true  ; Always true for background operation
        this.slowMode := slow
        this.targetWindow := targetWin
    }
    
    ; Save workflow to JSON
    SaveToFile(filePath) {
        try {
            ; Simple JSON format - just save as array
            jsonText := "["
            
            for i, action in this.actions {
                if (i > 1)
                    jsonText .= ","
                jsonText .= "`n  {`"Type`":`"" . action.Type . "`""
                if (action.HasProp("X"))
                    jsonText .= ",`"X`":" . action.X . ",`"Y`":" . action.Y
                if (action.HasProp("Window"))
                    jsonText .= ",`"Window`":`"" . action.Window . "`""
                if (action.HasProp("UsePhoneNumber"))
                    jsonText .= ",`"UsePhoneNumber`":true"
                if (action.HasProp("PhonePart"))
                    jsonText .= ",`"PhonePart`":" . action.PhonePart
                jsonText .= "}"
            }
            jsonText .= "`n]"
            
            ; Delete existing file if it exists
            if (FileExist(filePath))
                FileDelete(filePath)
            
            ; Write the file
            FileAppend(jsonText, filePath, "UTF-8")
            
            ; Verify the file was created
            if (FileExist(filePath))
                return true
            else
                return false
                
        } catch as err {
            ; Return the error for debugging
            throw err
        }
    }
    
    ; Load workflow from JSON
    LoadFromFile(filePath) {
        try {
            fileContent := FileRead(filePath)
            this.actions := []
            
            ; Simple JSON parsing for actions - original working method
            lines := StrSplit(fileContent, "`n")
            for line in lines {
                line := Trim(line)
                if (InStr(line, "`"Type`":")) {
                    action := {}
                    ; Extract Type
                    if (RegExMatch(line, "`"Type`":`"([^`"]+)`"", &match))
                        action.Type := match[1]
                    ; Extract X if present
                    if (RegExMatch(line, "`"X`":(\d+)", &match))
                        action.X := Integer(match[1])
                    ; Extract Y if present
                    if (RegExMatch(line, "`"Y`":(\d+)", &match))
                        action.Y := Integer(match[1])
                    ; Extract Window if present
                    if (RegExMatch(line, "`"Window`":`"([^`"]+)`"", &match))
                        action.Window := match[1]
                    ; Extract UsePhoneNumber if present
                    if (InStr(line, "`"UsePhoneNumber`":true"))
                        action.UsePhoneNumber := true
                    ; Extract PhonePart if present
                    if (RegExMatch(line, "`"PhonePart`":(\d+)", &match))
                        action.PhonePart := Integer(match[1])
                        
                    this.actions.Push(action)
                }
            }
            this.currentActionIndex := 1
            return true
        } catch {
            return false
        }
    }
}

; Edge/Java Workflow for TW.json and similar sites
; =====================================================
; 5 INDEPENDENT WORKFLOW CLASSES - EACH IS COMPLETELY SEPARATE
; =====================================================

class NeustarWorkflow extends BaseWorkflow {
    __New() {
        super.__New("Neustar (Edge)")
    }
    
    GetRecordingInstructions() {
        return "Recording TAB Navigation: TAB=navigate, Ctrl+V=phone parts (1st/2nd/3rd), V/D=dropdown, ESC=stop"
    }
    
    StartRecording() {
        this.isRecording := true
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0
        
        try {
            HotKey("~LButton", (*) => this.RecordClick(), "On")
            HotKey("~RButton", (*) => this.RecordRightClick(), "On") 
            HotKey("~Escape", (*) => this.StopRecording(), "On")
            HotKey("~^c", (*) => this.RecordCopy(), "On")
            HotKey("~Tab", (*) => this.RecordTabNavigation(), "On")
            HotKey("^v", (*) => this.RecordSequentialPhonePart(), "On")
            HotKey("v", (*) => this.RecordVKey(), "On")
            HotKey("d", (*) => this.RecordDKey(), "On")
            HotKey("~!Tab", (*) => this.RecordAltTab(), "On")
            return true
        } catch {
            this.isRecording := false
            return false
        }
    }
    
    StopRecording() {
        if (!this.isRecording)
            return
        this.isRecording := false
        
        try {
            ; Turn off ALL hotkeys that were registered for Neustar
            HotKey("~LButton", "Off")
            HotKey("~RButton", "Off")
            HotKey("~Escape", "Off") 
            HotKey("~^c", "Off")
            HotKey("^v", "Off")
            HotKey("~!Tab", "Off")
            HotKey("~Tab", "Off")
            HotKey("v", "Off")
            HotKey("d", "Off")
        } catch {
        }
    }
    
    ; Recording methods specific to Edge/Java workflow
    RecordClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Click", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordRightClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "RightClick", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordCopy() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Copy", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordTabNavigation() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "TabNavigate", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordSequentialPhonePart() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.phonePartCounter++
        if (this.phonePartCounter > 4) {  ; LexSE has 4 fields
            this.phonePartCounter := 1
        }
        
        this.RecordAction({Type: "SequentialPhonePart", Window: activeTitle, Time: A_TickCount, UsePhoneNumber: true, PhonePart: this.phonePartCounter})
        return
    }
    
    RecordVKey() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "VKey", Window: activeTitle, Time: A_TickCount})
        return
    }
    
    RecordDKey() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "DKey", Window: activeTitle, Time: A_TickCount})
        return
    }
    
    RecordAltTab() {
        if (!this.isRecording)
            return
        this.RecordAction({Type: "AltTab", Time: A_TickCount})
    }
    
    ; Execute action specific to Edge/Java workflow
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        ; Get window handle for background operation
        targetHwnd := ""
        if (this.targetWindow != "" && action.Type != "AltTab") {
            try {
                if (WinExist(this.targetWindow)) {
                    targetHwnd := WinGetID(this.targetWindow)
                    ; Only activate window if NOT in background mode
                    if (!this.backgroundMode) {
                        WinActivate(this.targetWindow)
                        Sleep(200)
                    }
                }
            } catch {
            }
        }
        
        if (action.Type == "Click") {
            ; DIRECT CLICK - no corrections
            statusTextControl.Text := "✓ Click executed"
            Click(action.X, action.Y)
            Sleep(500)
            
        } else if (action.Type == "RightClick") {
            if (this.backgroundMode && targetHwnd != "") {
                ; Background right-click
                if (BackgroundClick(action.X, action.Y, targetHwnd, "Right")) {
                    statusTextControl.Text := "✓ Background right-click"
                } else {
                    Click(action.X, action.Y, "Right")
                    statusTextControl.Text := "✓ Right-click executed"
                }
            } else {
                if (this.targetWindow == "") {
                    activatedWindow := ActivateCompatibleWindow(action.Window)
                    Sleep(300)
                } else {
                    actionDelay := this.backgroundMode ? 100 : 300
                    Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
                }
                Click(action.X, action.Y, "Right")
                statusTextControl.Text := "✓ Right-click executed"
            }
            Sleep(100)
            
        } else if (action.Type == "Copy") {
            if (this.backgroundMode && targetHwnd != "") {
                ; Background copy
                if (BackgroundSendKey("^c", targetHwnd)) {
                    statusTextControl.Text := "✓ Background Ctrl+C"
                } else {
                    Send("^c")
                    statusTextControl.Text := "Sent Ctrl+C"
                }
            } else {
                if (this.targetWindow == "") {
                    activatedWindow := ActivateCompatibleWindow(action.Window)
                    Sleep(300)
                } else {
                    actionDelay := this.backgroundMode ? 100 : 300
                    Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
                }
                Send("^c")
                statusTextControl.Text := "Sent Ctrl+C"
            }
            
        } else if (action.Type == "TabNavigate") {
            if (this.targetWindow == "") {
                activatedWindow := ActivateCompatibleWindow(action.Window)
                actionDelay := this.backgroundMode ? 100 : 300
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            } else {
                actionDelay := this.backgroundMode ? 100 : 300
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            }
            
            Send("{Tab}")
            Sleep(this.slowMode ? 200 : 100)
            statusTextControl.Text := "✓ TAB navigation"
            
        } else if (action.Type == "SequentialPhonePart") {
            if (this.targetWindow == "") {
                activatedWindow := ActivateCompatibleWindow(action.Window)
                actionDelay := this.backgroundMode ? 200 : 400
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            } else {
                actionDelay := this.backgroundMode ? 100 : 300
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            }
            
            ; Ensure field is properly selected and cleared
            Send("^a")
            Sleep(100)  ; Longer delay to ensure proper field selection
            
            if (action.HasProp("UsePhoneNumber") && action.HasProp("PhonePart")) {
                if (action.PhonePart == 0) {
                    ; FULL PHONE NUMBER PASTE
                    SendText(phoneNumber)
                    statusTextControl.Text := "✓ NEUSTAR Full Number: " . phoneNumber
                    Sleep(200)
                } else if (rawPhoneNumber != "") {
                    ; For Neustar: Use FULL formatted number when PhonePart == 1, ignore other parts
                    if (action.PhonePart == 1) {
                        ; NEUSTAR: Paste full formatted number for first field only
                        SendText(phoneNumber)
                        statusTextControl.Text := "✓ NEUSTAR Full Number: " . phoneNumber
                    } else if (action.PhonePart == 2) {
                        ; Skip part 2 for Neustar (no action needed)
                        statusTextControl.Text := "✓ Neustar Part 2: Skipped"
                    } else if (action.PhonePart == 3) {
                        ; Skip part 3 for Neustar (no action needed) 
                        statusTextControl.Text := "✓ Neustar Part 3: Skipped"
                    }
                    Sleep(this.slowMode ? 200 : 150)  ; Longer delay for accuracy
                }
            }
            
        } else if (action.Type == "VKey") {
            if (this.targetWindow == "") {
                activatedWindow := ActivateCompatibleWindow(action.Window)
                Sleep(this.slowMode ? 300 : 200)
            } else {
                Sleep(this.slowMode ? 200 : 100)
            }
            
            ; Send lowercase v specifically to avoid caps lock issues
            SendText("v")
            Sleep(this.slowMode ? 150 : 100)
            statusTextControl.Text := "✓ V key pressed"
            
        } else if (action.Type == "DKey") {
            if (this.targetWindow == "") {
                activatedWindow := ActivateCompatibleWindow(action.Window)
                Sleep(this.slowMode ? 300 : 200)
            } else {
                Sleep(this.slowMode ? 200 : 100)
            }
            
            ; Send lowercase d specifically to avoid caps lock issues
            SendText("d")
            Sleep(this.slowMode ? 150 : 100)
            statusTextControl.Text := "✓ D key pressed"
            
        } else if (action.Type == "AltTab") {
            Send("!{Tab}")
            Sleep(this.backgroundMode ? 300 : 500)
            statusTextControl.Text := "Switched windows (Alt+Tab)"
            
            if (this.targetWindow != "") {
                Sleep(this.backgroundMode ? 200 : 400)
                updatedWindow := FindCompatibleWindow(this.targetWindow)
                if (updatedWindow != "") {
                    this.targetWindow := updatedWindow
                    try {
                        WinActivate(this.targetWindow)
                    } catch {
                    }
                }
            }
        }
        
        ; Add delay between actions
        baseDelay := this.backgroundMode ? 300 : 600
        finalDelay := this.slowMode ? baseDelay * 1.5 : baseDelay
        Sleep(finalDelay)
    }
}

class LexWorkflow extends BaseWorkflow {
    __New() {
        super.__New("Lex (Java)")
    }
    
    GetRecordingInstructions() {
        return "Recording Lex Java: Alt+Tab=switch, Click=select V, TAB=navigate, Ctrl+V=phone parts, D=dropdown2, ESC=stop"
    }
    
    StartRecording() {
        this.isRecording := true
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0  ; Start at 0, will become 1 on first Ctrl+V
        
        try {
            HotKey("~LButton", (*) => this.RecordClick(), "On")
            HotKey("~RButton", (*) => this.RecordRightClick(), "On") 
            HotKey("~Escape", (*) => this.StopRecording(), "On")
            HotKey("~^c", (*) => this.RecordCopy(), "On")
            HotKey("~Tab", (*) => this.RecordTabNavigation(), "On")
            HotKey("^v", (*) => this.RecordSequentialPhonePart(), "On")
            HotKey("~v", (*) => this.RecordVKey(), "On")
            HotKey("~d", (*) => this.RecordDKey(), "On")
            HotKey("~!Tab", (*) => this.RecordAltTab(), "On")
            return true
        } catch {
            this.isRecording := false
            return false
        }
    }
    
    StopRecording() {
        if (!this.isRecording)
            return
        this.isRecording := false
        
        try {
            ; Turn off ALL hotkeys that were registered for Lex
            HotKey("~LButton", "Off")
            HotKey("~RButton", "Off")
            HotKey("~Escape", "Off") 
            HotKey("~^c", "Off")
            HotKey("^v", "Off")
            HotKey("~!Tab", "Off")
            HotKey("~Tab", "Off")
            HotKey("~v", "Off")
            HotKey("~d", "Off")
        } catch {
        }
    }
    
    RecordClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Click", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordSequentialPhonePart() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        ; Lex-specific: Increment counter BEFORE recording (0->1 for first field, etc.)
        this.phonePartCounter++
        if (this.phonePartCounter > 3) {  ; Lex workflow has exactly 3 fields
            this.phonePartCounter := 1
        }
        
        ; Store the action with the correct PhonePart for this field
        this.RecordAction({Type: "SequentialPhonePart", Window: activeTitle, Time: A_TickCount, UsePhoneNumber: true, PhonePart: this.phonePartCounter})
        return
    }
    
    RecordAltTab() {
        if (!this.isRecording)
            return
        this.RecordAction({Type: "AltTab", Time: A_TickCount})
    }
    
    RecordRightClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "RightClick", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordCopy() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Copy", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordTabNavigation() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "TabNavigate", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordVKey() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "VKey", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordDKey() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "DKey", Window: activeTitle, Time: A_TickCount})
    }
    
    
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        targetHwnd := ""
        if (this.targetWindow != "" && action.Type != "AltTab") {
            try {
                if (WinExist(this.targetWindow)) {
                    targetHwnd := WinGetID(this.targetWindow)
                    ; Window activation is handled at the start of each playback cycle
                }
            } catch {
            }
        }
        
        if (action.Type == "Click") {
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            Click(action.X, action.Y)
            Sleep(100)  ; Reduced for speed
            
        } else if (action.Type == "RightClick") {
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            Click(action.X, action.Y, "Right")
            Sleep(100)  ; Reduced for speed
            
        } else if (action.Type == "Copy") {
            Send("^c")
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            Sleep(100)  ; Reduced for speed
            
        } else if (action.Type == "TabNavigate") {
            Send("{Tab}")
            Sleep(this.slowMode ? 200 : 100)  ; Reduced for speed
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            
        } else if (action.Type == "VKey") {
            ; LEX V Key - Use Send for Java dropdown selection
            Send("v")
            Sleep(this.slowMode ? 200 : 100)
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            
        } else if (action.Type == "DKey") {
            ; LEX D Key - Use Send for Java dropdown selection
            Send("d")
            Sleep(this.slowMode ? 200 : 100)
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            
        } else if (action.Type == "SequentialPhonePart") {
            ; Increase delays for accuracy
            if (this.targetWindow == "") {
                actionDelay := this.backgroundMode ? 400 : 600
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            } else {
                actionDelay := this.backgroundMode ? 300 : 500
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            }
            
            ; Clear field first
            Send("^a")
            Sleep(100)
            
            if (action.HasProp("UsePhoneNumber") && action.HasProp("PhonePart")) {
                if (action.PhonePart == 0) {
                    ; Full phone number paste (not used in Lex)
                    SendText(phoneNumber)
                    ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
                    Sleep(300)
                } else if (rawPhoneNumber != "") {
                    ; For Lex: Split phone into 3 parts for 3 fields
                    cleanPhone := Format("{:010s}", rawPhoneNumber)
                    
                    phonePart := ""
                    
                    if (action.PhonePart == 1) {
                        ; First field: Area code (first 3 digits)
                        phonePart := SubStr(cleanPhone, 1, 3)
                    } else if (action.PhonePart == 2) {
                        ; Second field: Exchange (next 3 digits)
                        phonePart := SubStr(cleanPhone, 4, 3)
                    } else if (action.PhonePart == 3) {
                        ; Third field: Number (last 4 digits)
                        phonePart := SubStr(cleanPhone, 7, 4)
                    }
                    
                    if (phonePart != "") {
                        ; Clear any existing text and paste new part
                        Send("^a")
                        Sleep(100)
                        SendText(phonePart)
                        Sleep(100)  ; Reduced delay for field processing
                        ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
                    }
                    Sleep(this.slowMode ? 150 : 100)
                }
            } else {
                ; ERROR: Missing action properties - status update removed to prevent foreground activation
            }
            
        } else if (action.Type == "AltTab") {
            ; Skip Alt+Tab in background mode - it would bring window to foreground
            if (!this.backgroundMode) {
                Send("!{Tab}")
            }
            Sleep(500)
            ; ✓ LEX Alt+Tab executed - status update removed to prevent foreground activation
        }
        
        Sleep(this.slowMode ? 200 : 100)
    }
}


class LexSEWorkflow extends BaseWorkflow {
    __New() {
        super.__New("Lex SE (Java)")
    }
    
    GetRecordingInstructions() {
        return "Recording Lex SE Java: Alt+Tab=switch, Click=select V, TAB=navigate, Ctrl+V=phone parts (4 fields), D=dropdown2, ESC=stop"
    }
    
    StartRecording() {
        this.isRecording := true
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0  ; Start at 0, will become 1 on first Ctrl+V
        
        try {
            HotKey("~LButton", (*) => this.RecordClick(), "On")
            HotKey("~RButton", (*) => this.RecordRightClick(), "On") 
            HotKey("~Escape", (*) => this.StopRecording(), "On")
            HotKey("~^c", (*) => this.RecordCopy(), "On")
            HotKey("~Tab", (*) => this.RecordTabNavigation(), "On")
            HotKey("^v", (*) => this.RecordSequentialPhonePart(), "On")
            HotKey("~v", (*) => this.RecordVKey(), "On")
            HotKey("~d", (*) => this.RecordDKey(), "On")
            HotKey("~!Tab", (*) => this.RecordAltTab(), "On")
            return true
        } catch {
            this.isRecording := false
            return false
        }
    }
    
    StopRecording() {
        if (!this.isRecording)
            return
        this.isRecording := false
        
        try {
            ; Turn off ALL hotkeys that were registered for Lex SE
            HotKey("~LButton", "Off")
            HotKey("~RButton", "Off")
            HotKey("~Escape", "Off") 
            HotKey("~^c", "Off")
            HotKey("^v", "Off")
            HotKey("~!Tab", "Off")
            HotKey("~Tab", "Off")
            HotKey("~v", "Off")
            HotKey("~d", "Off")
        } catch {
        }
    }
    
    RecordClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Click", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordSequentialPhonePart() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        ; Increment counter BEFORE recording (0->1 for first field, etc.)
        this.phonePartCounter++
        if (this.phonePartCounter > 4) {  ; LexSE has 4 fields
            this.phonePartCounter := 1
        }
        
        ; Store the action with the correct PhonePart for this field
        this.RecordAction({Type: "SequentialPhonePart", Window: activeTitle, Time: A_TickCount, UsePhoneNumber: true, PhonePart: this.phonePartCounter})
        return
    }
    
    RecordAltTab() {
        if (!this.isRecording)
            return
        this.RecordAction({Type: "AltTab", Time: A_TickCount})
    }
    
    RecordRightClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "RightClick", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordCopy() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Copy", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordTabNavigation() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "TabNavigate", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordVKey() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "VKey", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordDKey() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "DKey", Window: activeTitle, Time: A_TickCount})
    }
    
    
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        targetHwnd := ""
        if (this.targetWindow != "" && action.Type != "AltTab") {
            try {
                if (WinExist(this.targetWindow)) {
                    targetHwnd := WinGetID(this.targetWindow)
                    ; Window activation is handled at the start of each playback cycle
                }
            } catch {
            }
        }
        
        if (action.Type == "Click") {
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            Click(action.X, action.Y)
            Sleep(100)  ; Reduced for speed
            
        } else if (action.Type == "RightClick") {
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            Click(action.X, action.Y, "Right")
            Sleep(100)  ; Reduced for speed
            
        } else if (action.Type == "Copy") {
            Send("^c")
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            Sleep(100)  ; Reduced for speed
            
        } else if (action.Type == "TabNavigate") {
            Send("{Tab}")
            Sleep(this.slowMode ? 200 : 100)  ; Reduced for speed
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            
        } else if (action.Type == "VKey") {
            ; LEXSE TEST V Key - Must use SendText for Java dropdowns
            SendText("v")
            Sleep(this.slowMode ? 300 : 200)
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            
        } else if (action.Type == "DKey") {
            ; LEXSE TEST D Key - Must use SendText for Java dropdowns
            SendText("d")
            Sleep(this.slowMode ? 300 : 200)
            ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
            
        } else if (action.Type == "SequentialPhonePart") {
            ; Increase delays for accuracy
            if (this.targetWindow == "") {
                actionDelay := this.backgroundMode ? 400 : 600
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            } else {
                actionDelay := this.backgroundMode ? 300 : 500
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            }
            
            ; Clear field first
            Send("^a")
            Sleep(100)
            
            if (action.HasProp("UsePhoneNumber") && action.HasProp("PhonePart")) {
                if (action.PhonePart == 0) {
                    ; Full phone number paste (not used in LexSE)
                    SendText(phoneNumber)
                    ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
                    Sleep(300)
                } else if (rawPhoneNumber != "") {
                    ; For LexSE: 4 field logic with consecutive number handling
                    phonePart := ""
                    
                    ; Check if this is a consecutive range (handles both dash and space formats)
                    isRange := InStr(phoneNumber, "-") || (StrLen(phoneNumber) > 14 && InStr(phoneNumber, " ") && RegExMatch(phoneNumber, "^\d{3}\s\d{3}\s\d{4}\s\d{4}$"))
                    
                    if (isRange) {
                        ; Consecutive numbers: 9876543210-9876543212 or 987 654 3210 3212
                        ; Field 1=987, field 2=654, field 3=3210, field 4=3212 (last 4 of end number)
                        firstNumber := ""
                        lastNumber := ""
                        
                        if (InStr(phoneNumber, "-")) {
                            ; Dash format: 9876543210-9876543212
                            parts := StrSplit(phoneNumber, "-")
                            firstNumber := parts[1]
                            lastNumber := parts[2]
                        } else {
                            ; Space format: 987 654 3210 3212
                            parts := StrSplit(phoneNumber, " ")
                            if (parts.Length >= 4) {
                                firstNumber := parts[1] . parts[2] . parts[3]
                                lastNumber := firstNumber
                                ; Replace last 4 digits with the 4th part
                                lastNumber := SubStr(firstNumber, 1, 6) . parts[4]
                            }
                        }
                        
                        cleanFirst := Format("{:010s}", firstNumber)
                        cleanLast := Format("{:010s}", lastNumber)
                        
                        if (action.PhonePart == 1) {
                            ; First field: Area code from first number (first 3 digits)
                            phonePart := SubStr(cleanFirst, 1, 3)
                        } else if (action.PhonePart == 2) {
                            ; Second field: Exchange from first number (next 3 digits)
                            phonePart := SubStr(cleanFirst, 4, 3)
                        } else if (action.PhonePart == 3) {
                            ; Third field: Last 4 digits of first number
                            phonePart := SubStr(cleanFirst, 7, 4)
                        } else if (action.PhonePart == 4) {
                            ; Fourth field: Last 4 digits of last number in range
                            phonePart := SubStr(cleanLast, 7, 4)
                        }
                    } else {
                        ; Non-consecutive numbers: 987 654 4330
                        ; Field 1=987, field 2=654, field 3=4330, field 4="" (empty)
                        ; Extract digits from formatted phone number instead of using rawPhoneNumber
                        phoneDigits := RegExReplace(phoneNumber, "[^0-9]", "")
                        cleanPhone := Format("{:010s}", phoneDigits)
                        
                        if (action.PhonePart == 1) {
                            ; First field: Area code (first 3 digits)
                            phonePart := SubStr(cleanPhone, 1, 3)
                        } else if (action.PhonePart == 2) {
                            ; Second field: Exchange (next 3 digits)
                            phonePart := SubStr(cleanPhone, 4, 3)
                        } else if (action.PhonePart == 3) {
                            ; Third field: Last 4 digits
                            phonePart := SubStr(cleanPhone, 7, 4)
                        } else if (action.PhonePart == 4) {
                            ; Fourth field: Empty for non-consecutive numbers
                            phonePart := ""
                        }
                    }
                    
                    ; Clear any existing text first (even for empty fields)
                    Send("^a")
                    Sleep(100)
                    
                    if (phonePart != "") {
                        ; Paste the phone part
                        SendText(phonePart)
                        Sleep(100)  ; Reduced delay for field processing
                    } else {
                        ; For empty field (4th field in non-consecutive), just clear it
                        Send("{Delete}")
                        Sleep(100)
                    }
                    ; NO STATUS UPDATES - THEY ACTIVATE FILLER APP
                    Sleep(this.slowMode ? 150 : 100)
                }
            } else {
                ; ERROR: Missing action properties - status update removed to prevent foreground activation
            }
            
        } else if (action.Type == "AltTab") {
            ; Skip Alt+Tab in background mode - it would bring window to foreground
            if (!this.backgroundMode) {
                Send("!{Tab}")
            }
            Sleep(500)
            ; ✓ LEXSE TEST Alt+Tab executed - status update removed to prevent foreground activation
        }
        
        Sleep(this.slowMode ? 200 : 100)
    }
}

class VerizonWorkflow extends BaseWorkflow {
    __New() {
        super.__New("Verizon")
        this.phonePartCounter := 0  ; Track current phone field (1-4)
        this.rowCounter := 0        ; Track row numbers (001, 002, 003...)
        this.rowOffset := 0         ; Y-axis offset for multi-cycle progression
        this.rowHeight := 34        ; Pixels between each row (measured exactly from 5-row screenshot)
        this.firstRowY := 0         ; Y position of first row (for calibration)
    }
    
    GetRecordingInstructions() {
        return "Recording Verizon: Click=record, TAB=navigate, Shift+R=row number, C/L=dropdown, Ctrl+V=phone fields (4 total), Shift+F=calibrate rows, ESC=stop"
    }
    
    ; Calibration mode - press F1 to measure row distances
    CalibrateRows() {
        MsgBox("Calibration Mode: Create 4-5 rows, then click on Row 1 field, Row 2 field, Row 3 field, Row 4 field, then +Add button. Press any key when ready.")
        positions := []
        Loop 5 {
            MsgBox("Click on position " . A_Index . " (Row " . A_Index . " or +Add button)")
            KeyWait("LButton", "D")
            MouseGetPos(&x, &y)
            positions.Push({x: x, y: y})
            MsgBox("Position " . A_Index . ": X=" . x . ", Y=" . y)
        }
        
        ; Calculate distances
        row1Y := positions[1].y
        row2Y := positions[2].y  
        row3Y := positions[3].y
        row4Y := positions[4].y
        addButtonY := positions[5].y
        
        MsgBox("Row Distances:`nRow 1: " . row1Y . "`nRow 2: " . row2Y . " (+" . (row2Y-row1Y) . "px)`nRow 3: " . row3Y . " (+" . (row3Y-row1Y) . "px)`nRow 4: " . row4Y . " (+" . (row4Y-row1Y) . "px)`n+Add Button: " . addButtonY)
    }
    
    StartRecording() {
        this.isRecording := true
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0  ; Start at 0, will become 1 on first Ctrl+V
        
        try {
            HotKey("~LButton", (*) => this.RecordClick(), "On")
            HotKey("~Escape", (*) => this.StopRecording(), "On")
            HotKey("~Tab", (*) => this.RecordTab(), "On")
            HotKey("+r", (*) => this.RecordRowNumber(), "On")
            HotKey("~c", (*) => this.RecordCKey(), "On")
            HotKey("~l", (*) => this.RecordLKey(), "On")
            HotKey("^v", (*) => this.RecordPhonePart(), "On")
            HotKey("+f", (*) => this.CalibrateRows(), "On")
            return true
        } catch {
            this.isRecording := false
            return false
        }
    }
    
    StopRecording() {
        if (!this.isRecording)
            return
        this.isRecording := false
        
        ; Recording complete
        
        try {
            HotKey("~LButton", "Off")
            HotKey("~Escape", "Off")
            HotKey("~Tab", "Off")
            HotKey("+r", "Off")
            HotKey("~c", "Off")
            HotKey("~l", "Off")
            HotKey("^v", "Off")
            HotKey("+f", "Off")
        } catch {
        }
    }
    
    RecordClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "Click", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordTab() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "Tab", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordRowNumber() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "RowNumber", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordCKey() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "KeyPress", Key: "c", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordLKey() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "KeyPress", Key: "l", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordPhonePart() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        ; Increment counter for next field (1-4)
        this.phonePartCounter++
        if (this.phonePartCounter > 4) {
            this.phonePartCounter := 1  ; Reset to field 1 after field 4
        }
        
        ; Recording phone part
        
        this.RecordAction({Type: "SequentialPhonePart", PhonePart: this.phonePartCounter, Window: activeTitle, UsePhoneNumber: true, Time: A_TickCount})
    }
    
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        ; Track phone field count to know when to skip tabs
        static phoneFieldCount := 0
        static lastWasPhonePart := false
        static cycleCount := 0
        static firstClickY := 0
        
        if (action.Type == "Click") {
            ; Reset counters on click (new sequence)
            phoneFieldCount := 0
            lastWasPhonePart := false
            
            ; Check if this is an +Add button click (it should not have row offset applied)
            if (action.HasProp("IsAddButton") && action.IsAddButton) {
                ; +Add button position based on exact calibration measurements:
                ; 1 row: Y=284, 2 rows: Y=330 (+46), 3 rows: Y=374 (+90), 4 rows: Y=420 (+136), 5 rows: Y=464 (+180)
                addButtonOffset := 0
                if (this.rowOffset == 0) {
                    addButtonOffset := 0      ; 1 row: original position
                } else if (this.rowOffset == 45) {
                    addButtonOffset := 46     ; 2 rows: +46px
                } else if (this.rowOffset == 92) {
                    addButtonOffset := 90     ; 3 rows: +90px
                } else if (this.rowOffset == 137) {
                    addButtonOffset := 136    ; 4 rows: +136px
                } else if (this.rowOffset == 183) {
                    addButtonOffset := 180    ; 5 rows: +180px
                } else {
                    addButtonOffset := this.rowOffset - 3  ; 6+ rows: approximate
                }
                
                adjustedAddButtonY := action.Y + addButtonOffset
                Click(action.X, adjustedAddButtonY)
                Sleep(800)  ; Wait longer for new row to be fully rendered
                statusTextControl.Text := "✓ Verizon +Add button clicked (offset: " . addButtonOffset . "px) - new row created"
            } else {
                ; Store first click Y position for reference
                if (this.rowOffset == 0 && firstClickY == 0) {
                    firstClickY := action.Y
                }
                
                ; Apply row offset for regular clicks (fields within the row)
                adjustedY := action.Y + this.rowOffset
                Click(action.X, adjustedY)
                Sleep(200)
                statusTextControl.Text := "✓ Verizon Click executed (row offset: " . this.rowOffset . ")"
            }
            
        } else if (action.Type == "Tab") {
            ; Only skip Tab if:
            ; 1. Last action was a phone part AND
            ; 2. We haven't done all 4 phone fields yet
            if (lastWasPhonePart && phoneFieldCount < 4) {
                ; Tab skipped between phone fields (auto-advance)
                statusTextControl.Text := "⏭️ Tab skipped (auto-advance)"
            } else {
                ; Send Tab for navigation to dropdown or other fields
                ; Sending Tab (after field 4 or non-phone)
                Send("{Tab}")
                Sleep(200)
                statusTextControl.Text := "✓ Verizon Tab sent"
            }
            lastWasPhonePart := false  ; Reset after handling Tab
            
        } else if (action.Type == "RowNumber") {
            lastWasPhonePart := false  ; Reset flag
            
            ; Click on the field first if coordinates are available
            if (action.HasProp("X") && action.HasProp("Y")) {
                adjustedY := action.Y + this.rowOffset
                Click(action.X, adjustedY)
                Sleep(100)
            }
            
            ; Increment row counter and format as 001, 002, 003...
            this.rowCounter++
            rowNumber := Format("{:03d}", this.rowCounter)
            
            ; Clear field and paste row number
            Send("^a")
            Sleep(50)
            SendText(rowNumber)
            Sleep(200)
            statusTextControl.Text := "✓ Verizon Row: " . rowNumber
            
        } else if (action.Type == "KeyPress") {
            lastWasPhonePart := false  ; Reset flag
            
            if (action.HasProp("Key")) {
                Send(action.Key)
                Sleep(200)
                statusTextControl.Text := "✓ Verizon Key: " . action.Key
            }
            
        } else if (action.Type == "SequentialPhonePart") {
            ; Track that we're processing a phone part
            phoneFieldCount++
            lastWasPhonePart := true
            
            ; Clear field first
            Send("^a")
            Sleep(50)
            
            if (action.HasProp("UsePhoneNumber") && action.HasProp("PhonePart")) {
                if (rawPhoneNumber != "") {
                    ; Use the exact same logic as LexSE - 4 field logic with consecutive number handling
                    phonePart := ""
                    
                    ; Check if this is a consecutive range (handles both dash and space formats)
                    isRange := InStr(phoneNumber, "-") || (StrLen(phoneNumber) > 14 && InStr(phoneNumber, " ") && RegExMatch(phoneNumber, "^\d{3}\s\d{3}\s\d{4}\s\d{4}$"))
                    
                    if (isRange) {
                        ; Consecutive numbers: 9876543210-9876543212 or 987 654 3210 3212
                        ; Field 1=987, field 2=654, field 3=3210, field 4=3212 (last 4 of end number)
                        firstNumber := ""
                        lastNumber := ""
                        
                        if (InStr(phoneNumber, "-")) {
                            ; Dash format: 9876543210-9876543212
                            parts := StrSplit(phoneNumber, "-")
                            firstNumber := parts[1]
                            lastNumber := parts[2]
                        } else {
                            ; Space format: 987 654 3210 3212
                            parts := StrSplit(phoneNumber, " ")
                            if (parts.Length >= 4) {
                                firstNumber := parts[1] . parts[2] . parts[3]
                                lastNumber := firstNumber
                                ; Replace last 4 digits with the 4th part
                                lastNumber := SubStr(firstNumber, 1, 6) . parts[4]
                            }
                        }
                        
                        cleanFirst := Format("{:010s}", firstNumber)
                        cleanLast := Format("{:010s}", lastNumber)
                        
                        if (action.PhonePart == 1) {
                            ; First field: Area code from first number (first 3 digits)
                            phonePart := SubStr(cleanFirst, 1, 3)
                        } else if (action.PhonePart == 2) {
                            ; Second field: Exchange from first number (next 3 digits)
                            phonePart := SubStr(cleanFirst, 4, 3)
                        } else if (action.PhonePart == 3) {
                            ; Third field: Last 4 digits of first number
                            phonePart := SubStr(cleanFirst, 7, 4)
                        } else if (action.PhonePart == 4) {
                            ; Fourth field: Last 4 digits of last number in range
                            phonePart := SubStr(cleanLast, 7, 4)
                        }
                    } else {
                        ; Non-consecutive numbers: 987 654 4330
                        ; Field 1=987, field 2=654, field 3=4330, field 4="" (empty)
                        ; Extract digits from formatted phone number instead of using rawPhoneNumber
                        phoneDigits := RegExReplace(phoneNumber, "[^0-9]", "")
                        cleanPhone := Format("{:010s}", phoneDigits)
                        
                        if (action.PhonePart == 1) {
                            ; First field: Area code (first 3 digits)
                            phonePart := SubStr(cleanPhone, 1, 3)
                        } else if (action.PhonePart == 2) {
                            ; Second field: Exchange (next 3 digits)
                            phonePart := SubStr(cleanPhone, 4, 3)
                        } else if (action.PhonePart == 3) {
                            ; Third field: Last 4 digits
                            phonePart := SubStr(cleanPhone, 7, 4)
                        } else if (action.PhonePart == 4) {
                            ; Fourth field: Empty for non-consecutive numbers
                            phonePart := ""
                        }
                    }
                    
                    ; DEBUG: Show calculated result (removed timer to prevent interference)
                    ; ToolTip("CALCULATED: Field " . action.PhonePart . " = '" . phonePart . "'", 300, 340)
                    ; SetTimer(() => ToolTip(), 5000)  ; REMOVED: This timer was interfering with field 2
                    
                    if (phonePart != "") {
                        ; Paste the phone part
                        SendText(phonePart)
                        Sleep(150)
                        statusTextControl.Text := "✓ Verizon Phone" . action.PhonePart . ": " . phonePart
                    } else {
                        ; For empty field (4th field in non-consecutive), just clear it
                        Send("{Delete}")
                        Sleep(150)
                        statusTextControl.Text := "✓ Verizon Phone" . action.PhonePart . ": empty"
                    }
                }
            }
        }
        
        ; Track last action type for debugging
        lastActionType := action.Type
        Sleep(100)  ; Normal speed playback
    }
    
    
    ; Reset row counter when starting new recording
    ResetRowCounter() {
        this.rowCounter := 0
        this.rowOffset := 0  ; Reset to first row position
    }
    
    ; For multi-cycle support
    StartNewCycle() {
        ; Row counter continues incrementing across cycles (001, 002, 003...)
        ; Phone part counter resets for each cycle
        this.phonePartCounter := 0
        
        ; Exact spacing based on calibration measurements:
        ; Row 1: Y=245 (offset=0), Row 2: Y=290 (+45), Row 3: Y=337 (+92), Row 4: Y=382 (+137), Row 5: Y=428 (+183)
        if (this.rowOffset == 0) {
            this.rowOffset := 45  ; Row 2: +45px
        } else if (this.rowOffset == 45) {
            this.rowOffset := 92  ; Row 3: +92px total
        } else if (this.rowOffset == 92) {
            this.rowOffset := 137  ; Row 4: +137px total
        } else if (this.rowOffset == 137) {
            this.rowOffset := 183  ; Row 5: +183px total
        } else {
            this.rowOffset += 46  ; Row 6+: continue with 46px increments
        }
    }
}

; VerizonLSIWorkflow class removed due to unresolvable field navigation issues

class VFOWorkflow extends BaseWorkflow {
    __New() {
        super.__New("VFO (Chrome)")
    }
    
    GetRecordingInstructions() {
        return "Recording VFO Chrome: Click=record, Ctrl+V=phone paste, ESC=stop"
    }
    
    StartRecording() {
        this.isRecording := true
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0
        
        try {
            HotKey("~LButton", (*) => this.RecordClick(), "On")
            HotKey("~Escape", (*) => this.StopRecording(), "On")
            HotKey("^v", (*) => this.RecordSequentialPhonePart(), "On")
            HotKey("~!Tab", (*) => this.RecordAltTab(), "On")
            return true
        } catch {
            this.isRecording := false
            return false
        }
    }
    
    StopRecording() {
        if (!this.isRecording)
            return
        this.isRecording := false
        
        try {
            HotKey("~LButton", "Off")
            HotKey("~Escape", "Off")
            HotKey("^v", "Off")
            HotKey("~!Tab", "Off")
        } catch {
        }
    }
    
    RecordClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Click", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordSequentialPhonePart() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.phonePartCounter++
        if (this.phonePartCounter > 4) {  ; LexSE has 4 fields
            this.phonePartCounter := 1
        }
        
        this.RecordAction({Type: "SequentialPhonePart", Window: activeTitle, Time: A_TickCount, UsePhoneNumber: true, PhonePart: this.phonePartCounter})
        return
    }
    
    RecordAltTab() {
        if (!this.isRecording)
            return
        this.RecordAction({Type: "AltTab", Time: A_TickCount})
    }
    
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        if (action.Type == "Click") {
            statusTextControl.Text := "✓ Click executed"
            Click(action.X, action.Y)
            Sleep(500)
            
        } else if (action.Type == "SequentialPhonePart") {
            actionDelay := this.backgroundMode ? 200 : 400
            Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            
            Send("^a")
            Sleep(50)
            
            if (action.HasProp("UsePhoneNumber") && action.HasProp("PhonePart")) {
                if (action.PhonePart == 0) {
                    Send("^a")
                    Sleep(100)
                    SendText(phoneNumber)
                    statusTextControl.Text := "DIRECT PASTE: " . phoneNumber . " (Raw: " . rawPhoneNumber . ")"
                    Sleep(200)
                } else if (rawPhoneNumber != "") {
                    ; For VFO: Use FULL formatted number when PhonePart == 1, ignore other parts
                    if (action.PhonePart == 1) {
                        SendText(phoneNumber)
                        statusTextControl.Text := "✓ VFO Full Number: " . phoneNumber
                    } else if (action.PhonePart == 2) {
                        statusTextControl.Text := "✓ VFO Part 2: Skipped"
                    } else if (action.PhonePart == 3) {
                        statusTextControl.Text := "✓ VFO Part 3: Skipped"
                    }
                    Sleep(this.slowMode ? 150 : 100)
                }
            }
            
        } else if (action.Type == "AltTab") {
            Send("!{Tab}")
            Sleep(500)
            statusTextControl.Text := "✓ Alt+Tab executed"
        }
        
        Sleep(this.slowMode ? 200 : 100)
    }
}

class ChromeWorkflow extends BaseWorkflow {
    __New() {
        super.__New("Chrome (Simple)")
    }
    
    GetRecordingInstructions() {
        return "Recording Chrome Simple: Click=record, Ctrl+V=phone paste, ESC=stop"
    }
    
    StartRecording() {
        this.isRecording := true
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0
        
        try {
            HotKey("~LButton", (*) => this.RecordClick(), "On")
            HotKey("~Escape", (*) => this.StopRecording(), "On")
            HotKey("^v", (*) => this.RecordSequentialPhonePart(), "On")
            HotKey("~!Tab", (*) => this.RecordAltTab(), "On")
            return true
        } catch {
            this.isRecording := false
            return false
        }
    }
    
    StopRecording() {
        if (!this.isRecording)
            return
        this.isRecording := false
        
        try {
            HotKey("~LButton", "Off")
            HotKey("~Escape", "Off")
            HotKey("^v", "Off")
            HotKey("~!Tab", "Off")
        } catch {
        }
    }
    
    RecordClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Click", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordSequentialPhonePart() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.phonePartCounter++
        if (this.phonePartCounter > 4) {  ; LexSE has 4 fields
            this.phonePartCounter := 1
        }
        
        this.RecordAction({Type: "SequentialPhonePart", Window: activeTitle, Time: A_TickCount, UsePhoneNumber: true, PhonePart: this.phonePartCounter})
        return
    }
    
    RecordAltTab() {
        if (!this.isRecording)
            return
        this.RecordAction({Type: "AltTab", Time: A_TickCount})
    }
    
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        if (action.Type == "Click") {
            statusTextControl.Text := "✓ Click executed"
            Click(action.X, action.Y)
            Sleep(500)
            
        } else if (action.Type == "SequentialPhonePart") {
            actionDelay := this.backgroundMode ? 200 : 400
            Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            
            Send("^a")
            Sleep(50)
            
            if (action.HasProp("UsePhoneNumber") && action.HasProp("PhonePart")) {
                if (action.PhonePart == 0) {
                    Send("^a")
                    Sleep(100)
                    SendText(phoneNumber)
                    statusTextControl.Text := "DIRECT PASTE: " . phoneNumber . " (Raw: " . rawPhoneNumber . ")"
                    Sleep(200)
                } else if (rawPhoneNumber != "") {
                    ; For Chrome Simple: Use FULL formatted number when PhonePart == 1, ignore other parts
                    if (action.PhonePart == 1) {
                        SendText(phoneNumber)
                        statusTextControl.Text := "✓ CHROME Full Number: " . phoneNumber
                    } else if (action.PhonePart == 2) {
                        statusTextControl.Text := "✓ Chrome Part 2: Skipped"
                    } else if (action.PhonePart == 3) {
                        statusTextControl.Text := "✓ Chrome Part 3: Skipped"
                    }
                    Sleep(this.slowMode ? 150 : 100)
                }
            }
            
        } else if (action.Type == "AltTab") {
            Send("!{Tab}")
            Sleep(500)
            statusTextControl.Text := "✓ Alt+Tab executed"
        }
        
        Sleep(this.slowMode ? 200 : 100)
    }
}

; Chrome LSR Workflow for LSR sites
class ChromeLSRWorkflow extends BaseWorkflow {
    
    __New() {
        super.__New("Chrome LSR Sites")
    }
    
    GetRecordingInstructions() {
        return "Recording Chrome mode... (Shift+R=row field, Ctrl+V=phone parts, ESC=stop)"
    }
    
    StartRecording() {
        this.isRecording := true
        this.actions := []
        this.currentActionIndex := 1
        this.phonePartCounter := 0
        
        try {
            HotKey("~LButton", (*) => this.RecordClick(), "On")
            HotKey("~RButton", (*) => this.RecordRightClick(), "On") 
            HotKey("~Escape", (*) => this.StopRecording(), "On")
            HotKey("~^c", (*) => this.RecordCopy(), "On")
            HotKey("+r", (*) => this.RecordChromeRowField(), "On")
            HotKey("^v", (*) => this.RecordChromePhonePart(), "On")
            HotKey("~!Tab", (*) => this.RecordAltTab(), "On")
            return true
        } catch {
            this.isRecording := false
            return false
        }
    }
    
    StopRecording() {
        if (!this.isRecording)
            return
        this.isRecording := false
        
        try {
            HotKey("~LButton", "Off")
            HotKey("~RButton", "Off")
            HotKey("~Escape", "Off") 
            HotKey("~^c", "Off")
            HotKey("+r", "Off")
            HotKey("^v", "Off")
            HotKey("~!Tab", "Off")
        } catch {
        }
    }
    
    ; Recording methods specific to Chrome LSR workflow
    RecordClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Click", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordRightClick() {
        if (!this.isRecording)
            return
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "RightClick", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
    }
    
    RecordCopy() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        this.RecordAction({Type: "Copy", Window: activeTitle, Time: A_TickCount})
    }
    
    RecordChromeRowField() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
            MouseGetPos(&x, &y)
        } catch {
            activeTitle := "Unknown Window"
            MouseGetPos(&x, &y)
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "ChromeRowField", X: x, Y: y, Window: activeTitle, Time: A_TickCount})
        return
    }
    
    RecordChromePhonePart() {
        if (!this.isRecording)
            return
        try {
            activeTitle := WinGetTitle("A")
            MouseGetPos(&x, &y)
        } catch {
            activeTitle := "Unknown Window"
            MouseGetPos(&x, &y)
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        this.RecordAction({Type: "ChromePhonePart", X: x, Y: y, Window: activeTitle, Time: A_TickCount, UsePhoneNumber: true})
    }
    
    RecordAltTab() {
        if (!this.isRecording)
            return
        this.RecordAction({Type: "AltTab", Time: A_TickCount})
    }
    
    ; Execute action specific to Chrome LSR workflow
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        ; Get window handle for background operation
        targetHwnd := ""
        if (this.targetWindow != "" && action.Type != "AltTab") {
            try {
                if (WinExist(this.targetWindow)) {
                    targetHwnd := WinGetID(this.targetWindow)
                    ; Only activate window if NOT in background mode
                    if (!this.backgroundMode) {
                        WinActivate(this.targetWindow)
                        Sleep(200)
                    }
                }
            } catch {
            }
        }
        
        if (action.Type == "Click") {
            ; DIRECT CLICK - no corrections
            statusTextControl.Text := "✓ Click executed"
            Click(action.X, action.Y)
            Sleep(500)
            
        } else if (action.Type == "RightClick") {
            if (this.backgroundMode && targetHwnd != "") {
                ; Background right-click
                if (BackgroundClick(action.X, action.Y, targetHwnd, "Right")) {
                    statusTextControl.Text := "✓ Background right-click"
                } else {
                    Click(action.X, action.Y, "Right")
                    statusTextControl.Text := "✓ Right-click executed"
                }
            } else {
                if (this.targetWindow == "") {
                    activatedWindow := ActivateCompatibleWindow(action.Window)
                    Sleep(300)
                } else {
                    actionDelay := this.backgroundMode ? 100 : 300
                    Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
                }
                Click(action.X, action.Y, "Right")
                statusTextControl.Text := "✓ Right-click executed"
            }
            Sleep(100)
            
        } else if (action.Type == "Copy") {
            if (this.backgroundMode && targetHwnd != "") {
                ; Background copy
                if (BackgroundSendKey("^c", targetHwnd)) {
                    statusTextControl.Text := "✓ Background Ctrl+C"
                } else {
                    Send("^c")
                    statusTextControl.Text := "Sent Ctrl+C"
                }
            } else {
                if (this.targetWindow == "") {
                    activatedWindow := ActivateCompatibleWindow(action.Window)
                    Sleep(300)
                } else {
                    actionDelay := this.backgroundMode ? 100 : 300
                    Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
                }
                Send("^c")
                statusTextControl.Text := "Sent Ctrl+C"
            }
            
        } else if (action.Type == "ChromeRowField") {
            if (this.targetWindow == "") {
                activatedWindow := ActivateCompatibleWindow(action.Window)
                Sleep(300)
            } else {
                actionDelay := this.backgroundMode ? 100 : 300
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            }
            Click(action.X, action.Y)
            Sleep(100)
            statusTextControl.Text := "Chrome Row field at " . action.X . "," . action.Y
            
        } else if (action.Type == "ChromePhonePart") {
            if (this.targetWindow == "") {
                activatedWindow := ActivateCompatibleWindow(action.Window)
                Sleep(300)
            } else {
                actionDelay := this.backgroundMode ? 100 : 300
                Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
            }
            Click(action.X, action.Y)
            Sleep(50)
            
            if (action.HasProp("UsePhoneNumber") && phoneNumber != "") {
                Send("^a")
                Sleep(50)
                SendText(phoneNumber)
                Sleep(100)
                statusTextControl.Text := "✓ Pasted formatted phone: " . phoneNumber
            }
            
        } else if (action.Type == "AltTab") {
            Send("!{Tab}")
            Sleep(this.backgroundMode ? 300 : 500)
            statusTextControl.Text := "Switched windows (Alt+Tab)"
            
            if (this.targetWindow != "") {
                Sleep(this.backgroundMode ? 200 : 400)
                updatedWindow := FindCompatibleWindow(this.targetWindow)
                if (updatedWindow != "") {
                    this.targetWindow := updatedWindow
                    try {
                        WinActivate(this.targetWindow)
                    } catch {
                    }
                }
            }
        }
        
        ; Add delay between actions
        baseDelay := this.backgroundMode ? 300 : 600
        finalDelay := this.slowMode ? baseDelay * 1.5 : baseDelay
        Sleep(finalDelay)
    }
}

; Smart Image Recognition Workflow - Enterprise-grade element detection
class ImageRecognitionWorkflow extends BaseWorkflow {
    
    imageFolder := ""
    elementCounter := 0
    currentWorkflowName := ""
    
    __New() {
        super.__New("Smart Image Recognition")
        this.imageFolder := A_WorkingDir . "\Workflow Images"
    }
    
    GetRecordingInstructions() {
        return "Smart Recording: Shift+P=phone fields, Shift+A=other actions, regular clicks=buttons, ESC=stop"
    }
    
    StartRecording() {
        this.isRecording := true
        this.actions := []
        this.currentActionIndex := 1
        this.elementCounter := 0
        
        ; Create unique folder for this recording session
        timestamp := A_Now
        this.currentWorkflowName := "Workflow_" . timestamp
        workflowFolder := this.imageFolder . "\" . this.currentWorkflowName
        
        try {
            DirCreate(workflowFolder)
            
            HotKey("~LButton", (*) => this.RecordSmartClick(), "On")
            HotKey("~RButton", (*) => this.RecordRightClick(), "On")
            HotKey("~Escape", (*) => this.StopRecording(), "On")
            HotKey("+p", (*) => this.RecordPhoneField(), "On")
            HotKey("+a", (*) => this.CaptureElement(), "On")
            HotKey("~!Tab", (*) => this.RecordAltTab(), "On")
            return true
        } catch as err {
            this.isRecording := false
            return false
        }
    }
    
    StopRecording() {
        if (!this.isRecording)
            return
        this.isRecording := false
        
        try {
            HotKey("~LButton", "Off")
            HotKey("~RButton", "Off")
            HotKey("~Escape", "Off")
            HotKey("+p", "Off")
            HotKey("+a", "Off")
            HotKey("~!Tab", "Off")
        } catch {
        }
    }
    
    ; Smart click recording with image capture
    RecordSmartClick() {
        if (!this.isRecording)
            return
            
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        ; Capture element image
        elementInfo := this.CaptureElementImage(x, y, "click")
        if (elementInfo) {
            this.RecordAction({
                Type: "SmartClick",
                ElementImage: elementInfo.imagePath,
                ElementDescription: elementInfo.description,
                OriginalX: x,
                OriginalY: y,
                Window: activeTitle,
                Time: A_TickCount
            })
        }
    }
    
    ; Record right click with image
    RecordRightClick() {
        if (!this.isRecording)
            return
            
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        elementInfo := this.CaptureElementImage(x, y, "rightclick")
        if (elementInfo) {
            this.RecordAction({
                Type: "SmartRightClick",
                ElementImage: elementInfo.imagePath,
                ElementDescription: elementInfo.description,
                OriginalX: x,
                OriginalY: y,
                Window: activeTitle,
                Time: A_TickCount
            })
        }
    }
    
    ; Record phone field with image and special handling
    RecordPhoneField() {
        if (!this.isRecording)
            return
            
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        elementInfo := this.CaptureElementImage(x, y, "phonefield")
        if (elementInfo) {
            this.RecordAction({
                Type: "SmartPhoneField",
                ElementImage: elementInfo.imagePath,
                ElementDescription: elementInfo.description,
                OriginalX: x,
                OriginalY: y,
                Window: activeTitle,
                UsePhoneNumber: true,
                Time: A_TickCount
            })
        }
        return ; Block the original Ctrl+P
    }
    
    ; Manual element capture
    CaptureElement() {
        if (!this.isRecording)
            return
            
        MouseGetPos(&x, &y)
        try {
            activeTitle := WinGetTitle("A")
        } catch {
            activeTitle := "Unknown Window"
        }
        
        if (InStr(activeTitle, "Telnyx Phone Filler Pro")) {
            return
        }
        
        elementInfo := this.CaptureElementImage(x, y, "element")
        if (elementInfo) {
            this.RecordAction({
                Type: "SmartElement",
                ElementImage: elementInfo.imagePath,
                ElementDescription: elementInfo.description,
                OriginalX: x,
                OriginalY: y,
                Window: activeTitle,
                Time: A_TickCount
            })
        }
        return ; Block the original Shift+I
    }
    
    RecordAltTab() {
        if (!this.isRecording)
            return
        this.RecordAction({Type: "AltTab", Time: A_TickCount})
    }
    
    ; Capture element image around mouse position
    CaptureElementImage(centerX, centerY, elementType) {
        this.elementCounter++
        
        ; Define capture area (adjust size based on element type)
        captureSize := 100 ; Base size
        if (elementType == "phonefield")
            captureSize := 150
        else if (elementType == "click")
            captureSize := 80
            
        ; Calculate capture bounds
        left := centerX - (captureSize // 2)
        top := centerY - (captureSize // 2)
        right := left + captureSize
        bottom := top + captureSize
        
        ; Ensure bounds are within screen
        left := Max(0, left)
        top := Max(0, top)
        right := Min(A_ScreenWidth, right)
        bottom := Min(A_ScreenHeight, bottom)
        
        ; Create filename
        filename := this.currentWorkflowName . "_element_" . this.elementCounter . "_" . elementType . ".png"
        imagePath := this.imageFolder . "\" . this.currentWorkflowName . "\" . filename
        
        ; Capture screenshot of element
        if (this.CaptureScreenRegion(left, top, right - left, bottom - top, imagePath)) {
            ; Create description
            description := elementType . " at (" . centerX . "," . centerY . ")"
            
            return {
                imagePath: imagePath,
                description: description,
                captureArea: {x: left, y: top, width: right - left, height: bottom - top}
            }
        }
        
        return false
    }
    
    ; Capture screen region to file
    CaptureScreenRegion(x, y, width, height, filepath) {
        ; Use PowerShell screenshot method for reliable capture
        try {
            psCommand := 'Add-Type -AssemblyName System.Windows.Forms, System.Drawing; '
            psCommand .= '$bitmap = New-Object System.Drawing.Bitmap(' . width . ', ' . height . '); '
            psCommand .= '$graphics = [System.Drawing.Graphics]::FromImage($bitmap); '
            psCommand .= '$graphics.CopyFromScreen(' . x . ', ' . y . ', 0, 0, $bitmap.Size); '
            psCommand .= '$bitmap.Save("' . StrReplace(filepath, "\", "\\") . '", [System.Drawing.Imaging.ImageFormat]::Png); '
            psCommand .= '$graphics.Dispose(); $bitmap.Dispose();'
            
            RunWait('powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "' . psCommand . '"', , "Hide")
            return FileExist(filepath) ? true : false
        } catch as err {
            ; If PowerShell fails, try simpler screenshot method
            try {
                ; Create directory if it doesn't exist
                dirPath := SubStr(filepath, 1, InStr(filepath, "\", , -1) - 1)
                if (!DirExist(dirPath)) {
                    DirCreate(dirPath)
                }
                
                ; Use AutoHotkey's built-in screenshot capability (if available)
                ; Note: This captures the entire screen, not just a region
                Send("#{PrintScreen}")  ; Windows + PrintScreen saves to Pictures\Screenshots
                Sleep(500)
                return false  ; Can't guarantee the exact file location with this method
            } catch {
                return false
            }
        }
    }
    
    ; Execute smart actions using image recognition
    ExecuteAction(action, phoneNumber, rawPhoneNumber, statusTextControl) {
        ; Add delay before action
        actionDelay := this.backgroundMode ? 200 : 400
        Sleep(this.slowMode ? actionDelay * 1.5 : actionDelay)
        
        if (action.Type == "SmartClick") {
            foundLocation := this.FindElementByImage(action.ElementImage)
            if (foundLocation) {
                Click(foundLocation.x, foundLocation.y)
                Sleep(100)
                statusTextControl.Text := "✓ Smart Click: " . action.ElementDescription . " found at (" . foundLocation.x . "," . foundLocation.y . ")"
            } else {
                ; Fallback to original coordinates
                Click(action.OriginalX, action.OriginalY)
                statusTextControl.Text := "⚠ Fallback Click: " . action.ElementDescription . " at original position"
            }
            
        } else if (action.Type == "SmartRightClick") {
            foundLocation := this.FindElementByImage(action.ElementImage)
            if (foundLocation) {
                Click(foundLocation.x, foundLocation.y, "Right")
                Sleep(100)
                statusTextControl.Text := "✓ Smart Right-Click: " . action.ElementDescription
            } else {
                Click(action.OriginalX, action.OriginalY, "Right")
                statusTextControl.Text := "⚠ Fallback Right-Click: " . action.ElementDescription
            }
            
        } else if (action.Type == "SmartPhoneField") {
            foundLocation := this.FindElementByImage(action.ElementImage)
            if (foundLocation) {
                Click(foundLocation.x, foundLocation.y)
                Sleep(100)
                
                if (action.HasProp("UsePhoneNumber") && phoneNumber != "") {
                    Send("^a")
                    Sleep(50)
                    SendText(phoneNumber)
                    Sleep(100)
                    statusTextControl.Text := "✓ Smart Phone Field: " . phoneNumber . " entered successfully"
                }
            } else {
                ; Fallback
                Click(action.OriginalX, action.OriginalY)
                if (action.HasProp("UsePhoneNumber") && phoneNumber != "") {
                    Send("^a")
                    Sleep(50)
                    SendText(phoneNumber)
                    statusTextControl.Text := "⚠ Fallback Phone Field: " . phoneNumber
                }
            }
            
        } else if (action.Type == "SmartElement") {
            foundLocation := this.FindElementByImage(action.ElementImage)
            if (foundLocation) {
                Click(foundLocation.x, foundLocation.y)
                Sleep(100)
                statusTextControl.Text := "✓ Smart Element: " . action.ElementDescription
            } else {
                Click(action.OriginalX, action.OriginalY)
                statusTextControl.Text := "⚠ Fallback Element: " . action.ElementDescription
            }
            
        } else if (action.Type == "AltTab") {
            Send("!{Tab}")
            Sleep(this.backgroundMode ? 300 : 500)
            statusTextControl.Text := "Window switched (Alt+Tab)"
        }
        
        ; Add delay between actions
        baseDelay := this.backgroundMode ? 300 : 600
        finalDelay := this.slowMode ? baseDelay * 1.5 : baseDelay
        Sleep(finalDelay)
    }
    
    ; Find element on screen using image recognition
    FindElementByImage(imagePath) {
        if (!FileExist(imagePath)) {
            return false
        }
        
        try {
            ; Use ImageSearch to find the element
            ; Search with some tolerance for slight variations
            foundX := 0
            foundY := 0
            
            ; Try with different variation levels (0-255, where 0 is exact match)
            variations := [0, 10, 20, 30, 50]
            
            for variation in variations {
                try {
                    ; ImageSearch with variation tolerance
                    if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*" . variation . " " . imagePath)) {
                        ; Return center point of found element
                        return {x: foundX, y: foundY}
                    }
                } catch {
                    continue
                }
            }
        } catch as err {
            ; If ImageSearch fails completely, try alternative method
            return this.FindElementByImageAlternative(imagePath)
        }
        
        return false
    }
    
    ; Alternative image search method - fallback to stored coordinates
    FindElementByImageAlternative(imagePath) {
        ; Since AutoHotkey's ImageSearch may not always work reliably,
        ; we provide a fallback mechanism that uses the original coordinates
        ; This ensures the workflow can still function even if image recognition fails
        return false  ; Will trigger fallback to original coordinates in ExecuteAction
    }
}

; Workflow Manager - coordinates all workflows
class WorkflowManager {
    activeWorkflow := ""
    workflows := Map()
    
    __New() {
        ; Initialize 7 independent workflow types - EACH IS COMPLETELY SEPARATE
        this.workflows["Neustar"] := NeustarWorkflow()    ; Edge - WORKING LOGIC - DO NOT MODIFY
        this.workflows["Lex"] := LexWorkflow()            ; Java W-MW-SW - WORKING LOGIC - DO NOT MODIFY
        this.workflows["LexSE"] := LexSEWorkflow()        ; Java SE - New workflow with improved logic
        this.workflows["Verizon"] := VerizonWorkflow()    ; Working Verizon implementation
        this.workflows["VFO"] := VFOWorkflow()            ; Chrome - Copy of Neustar for now
        this.workflows["Chrome"] := ChromeWorkflow()      ; Chrome - Copy of Neustar for now
        this.activeWorkflow := this.workflows["Neustar"]  ; Default to Neustar
    }
    
    SetActiveWorkflow(workflowName) {
        if (this.workflows.Has(workflowName)) {
            ; Stop current workflow if recording
            if (this.activeWorkflow.isRecording) {
                this.activeWorkflow.StopRecording()
            }
            this.activeWorkflow := this.workflows[workflowName]
            return true
        }
        return false
    }
    
    GetActiveWorkflow() {
        return this.activeWorkflow
    }
    
    GetWorkflowNames() {
        names := []
        for name in this.workflows {
            names.Push(name)
        }
        return names
    }
    
    StartRecording() {
        if (this.activeWorkflow) {
            return this.activeWorkflow.StartRecording()
        }
        return false
    }
    
    StopRecording() {
        if (this.activeWorkflow) {
            this.activeWorkflow.StopRecording()
        }
    }
    
    GetRecordingInstructions() {
        if (this.activeWorkflow) {
            return this.activeWorkflow.GetRecordingInstructions()
        }
        return "No active workflow"
    }
    
    GetActionCount() {
        if (this.activeWorkflow) {
            return this.activeWorkflow.GetActionCount()
        }
        return 0
    }
    
    ClearActions() {
        if (this.activeWorkflow) {
            this.activeWorkflow.ClearActions()
        }
    }
    
    SaveActions(filePath) {
        if (this.activeWorkflow) {
            return this.activeWorkflow.SaveToFile(filePath)
        }
        return false
    }
    
    LoadActions(filePath) {
        if (this.activeWorkflow) {
            return this.activeWorkflow.LoadFromFile(filePath)
        }
        return false
    }
}

; =====================================================
; Phone Formatting Functions  
; =====================================================

ExtractNumbers(text) {
    numbers := []
    for line in StrSplit(text, "`n", "`r") {
        line := Trim(line)
        if (line == "")
            continue
        ; Remove all non-digit characters
        cleanNum := RegExReplace(line, "[^0-9]", "")
        if (StrLen(cleanNum) >= 10) {
            ; Get rightmost 10 digits - FIXED: use correct substring
            if (StrLen(cleanNum) == 10) {
                rightmost10 := cleanNum
            } else {
                rightmost10 := SubStr(cleanNum, StrLen(cleanNum) - 9)
            }
            numbers.Push(rightmost10)
        }
    }
    return numbers
}

FindConsecutiveRanges(numbers) {
    if (numbers.Length == 0)
        return []
    
    ; Convert to integers and sort
    numInts := []
    for num in numbers {
        numInts.Push(Integer(num))
    }
    
    ; Sort array
    numInts := BubbleSort(numInts)
    
    ranges := []
    start := numInts[1]
    end := numInts[1]
    
    Loop numInts.Length - 1 {
        i := A_Index + 1
        if (numInts[i] == end + 1) {
            ; Consecutive number found
            end := numInts[i]
        } else {
            ; End of consecutive sequence
            if (start == end) {
                ; Single number
                ranges.Push(Format("{:010d}", start))
            } else {
                ; Range  
                ranges.Push(Format("{:010d}", start) . "-" . Format("{:010d}", end))
            }
            start := end := numInts[i]
        }
    }
    
    ; Add the last range/number
    if (start == end) {
        ranges.Push(Format("{:010d}", start))
    } else {
        ranges.Push(Format("{:010d}", start) . "-" . Format("{:010d}", end))
    }
    
    return ranges
}

BubbleSort(arr) {
    n := arr.Length
    Loop n - 1 {
        i := A_Index
        Loop n - i {
            j := A_Index
            if (arr[j] > arr[j + 1]) {
                temp := arr[j]
                arr[j] := arr[j + 1]
                arr[j + 1] := temp
            }
        }
    }
    return arr
}

ApplyCustomFormat(phoneNumber, pattern, isRangeEnd := false) {
    xCount := 0
    for char in StrSplit(pattern) {
        if (char == "X")
            xCount++
    }
    
    ; If pattern has exactly 10 X's, use all 10 digits
    if (xCount == 10) {
        result := ""
        digitIndex := 1
        
        for char in StrSplit(pattern) {
            if (char == "X" && digitIndex <= StrLen(phoneNumber)) {
                result .= SubStr(phoneNumber, digitIndex, 1)
                digitIndex++
            } else if (char != "X") {
                result .= char
            }
        }
        return result
    }
    
    ; For patterns with more than 10 X's, handle range formatting
    if (xCount > 10) {
        return ApplyAdvancedFormat(phoneNumber, pattern, isRangeEnd)
    }
    
    return phoneNumber ; Fallback
}

ApplyAdvancedFormat(phoneNumber, pattern, isRangeEnd := false) {
    if (!isRangeEnd) {
        ; For individual numbers or range start: use first 10 X's
        result := pattern
        digitIndex := 1
        
        for char in StrSplit(pattern) {
            if (char == "X" && digitIndex <= 10 && digitIndex <= StrLen(phoneNumber)) {
                result := StrReplace(result, "X", SubStr(phoneNumber, digitIndex, 1), , 1)
                digitIndex++
            }
        }
        
        ; Remove remaining X's
        result := StrReplace(result, "X", "")
        return result
    } else {
        ; For range end: use last 4 digits
        endDigits := SubStr(phoneNumber, -3)
        return endDigits
    }
}

FormatPhoneNumbers() {
    global RawPhoneNumbers, FormattedPhoneNumbers, CurrentPhoneIndex, StatusText, CurrentPhoneText, ProgressText
    global FormatDashRadio, FormatDashRangeRadio, FormatSpaceRadio, FormatSpaceRangeRadio, CustomFormatSelect, CustomFormats
    
    if (RawPhoneNumbers.Length == 0) {
        StatusText.Text := "No phone numbers to format"
        return
    }
    
    ; Determine selected format
    selectedFormat := ""
    if (FormatDashRadio.Value)
        selectedFormat := "dash"
    else if (FormatDashRangeRadio.Value)
        selectedFormat := "dashrange"
    else if (FormatSpaceRadio.Value)
        selectedFormat := "space"
    else if (FormatSpaceRangeRadio.Value)
        selectedFormat := "spacerange"
    else
        selectedFormat := "custom"
    
    ; Get ranges for formatting - but treat as individual numbers for single formats
    FormattedPhoneNumbers := []
    
    ; DEBUG: Log raw numbers
    debugRawNumbers := ""
    for i, num in RawPhoneNumbers {
        debugRawNumbers .= i . ":" . num . " "
    }
    ; StatusText.Text := "DEBUG Raw: " . debugRawNumbers
    
    
    if (selectedFormat == "dash" || selectedFormat == "space") {
        ; For single number formats, don't use ranges - format each number individually
        for rawNum in RawPhoneNumbers {
            paddedNum := Format("{:010s}", rawNum)
            if (selectedFormat == "dash") {
                formatted := SubStr(paddedNum, 1, 3) . "-" . SubStr(paddedNum, 4, 3) . "-" . SubStr(paddedNum, 7, 4)
            } else {
                formatted := SubStr(paddedNum, 1, 3) . " " . SubStr(paddedNum, 4, 3) . " " . SubStr(paddedNum, 7, 4)
            }
            FormattedPhoneNumbers.Push(formatted)
        }
    } else {
        ; For range formats, use consecutive range detection
        ranges := FindConsecutiveRanges(RawPhoneNumbers)
        
        ; DEBUG: Log ranges  
        debugRanges := ""
        for i, range in ranges {
            debugRanges .= i . ":" . range . " "
        }
        ; StatusText.Text := "DEBUG Ranges: " . debugRanges
        for range in ranges {
            if (selectedFormat == "dashrange") {
                ; NEUSTAR FORMAT: Non-consecutive as 888-888-8888, consecutive as 888-888-8888-8889
                if (InStr(range, "-")) {
                    ; Consecutive range: format as 888-888-8888-8889
                    parts := StrSplit(range, "-")
                    startFormatted := SubStr(parts[1], 1, 3) . "-" . SubStr(parts[1], 4, 3) . "-" . SubStr(parts[1], 7, 4)
                    endLastFour := SubStr(parts[2], 7, 4)
                    FormattedPhoneNumbers.Push(startFormatted . "-" . endLastFour)
                } else {
                    ; Single number: format as 888-888-8888 (no range suffix)
                    formatted := SubStr(range, 1, 3) . "-" . SubStr(range, 4, 3) . "-" . SubStr(range, 7, 4)
                    FormattedPhoneNumbers.Push(formatted)
                }
            } else if (selectedFormat == "spacerange") {
                ; Format as 888 888 8888 8888 (ranges: full first + last 4)
                if (InStr(range, "-")) {
                    parts := StrSplit(range, "-")
                    ; Ensure both parts are properly padded to 10 digits
                    firstPart := Format("{:010s}", parts[1])
                    secondPart := Format("{:010s}", parts[2])
                    startFormatted := SubStr(firstPart, 1, 3) . " " . SubStr(firstPart, 4, 3) . " " . SubStr(firstPart, 7, 4)
                    endLastFour := SubStr(secondPart, 7, 4)
                    FormattedPhoneNumbers.Push(startFormatted . " " . endLastFour)
                } else {
                    formatted := SubStr(range, 1, 3) . " " . SubStr(range, 4, 3) . " " . SubStr(range, 7, 4)
                    FormattedPhoneNumbers.Push(formatted)
                }
            } else if (selectedFormat == "custom") {
                ; Apply custom format
                customFormatName := CustomFormatSelect.Text
                if (CustomFormats.Has(customFormatName)) {
                    pattern := CustomFormats[customFormatName]
                    if (InStr(range, "-")) {
                        parts := StrSplit(range, "-")
                        startFormatted := ApplyCustomFormat(parts[1], pattern, false)
                        endFormatted := ApplyCustomFormat(parts[2], pattern, true)
                        FormattedPhoneNumbers.Push(startFormatted . "-" . endFormatted)
                    } else {
                        formatted := ApplyCustomFormat(range, pattern, false)
                        FormattedPhoneNumbers.Push(formatted)
                    }
                }
            }
        }
    }
    
    ; DEBUG: Log final formatted numbers
    ; debugFormatted := ""
    ; for i, formatted in FormattedPhoneNumbers {
    ;     debugFormatted .= "Row " . i . ": " . formatted . "`n"
    ; }
    ; MsgBox("DEBUG Final Formatted Numbers:`n`n" . debugFormatted)
    ; StatusText.Text := "DEBUG completed - check message box"
    
    CurrentPhoneIndex := 1
    if (FormattedPhoneNumbers.Length > 0) {
        StatusText.Text := "Formatted " . FormattedPhoneNumbers.Length . " phone numbers"
        CurrentPhoneText.Text := CurrentPhoneIndex . "/" . FormattedPhoneNumbers.Length . ": " . FormattedPhoneNumbers[1]
        ProgressText.Text := CurrentPhoneIndex . " / " . FormattedPhoneNumbers.Length
    }
}

; =====================================================
; New Workflow-based Functions
; =====================================================

; Change active workflow
ChangeWorkflow(*) {
    global WorkflowMgr, WorkflowSelect, StatusText
    selectedIndex := WorkflowSelect.Value
    
    if (selectedIndex == 1) {
        WorkflowMgr.SetActiveWorkflow("Neustar")
        ; StatusText.Text := "Switched to Neustar (Edge) - WORKING LOGIC PRESERVED"
    } else if (selectedIndex == 2) {
        WorkflowMgr.SetActiveWorkflow("Lex")  
        ; StatusText.Text := "Switched to Lex W-MW-SW (Java) - WORKING LOGIC PRESERVED"
    } else if (selectedIndex == 3) {
        WorkflowMgr.SetActiveWorkflow("LexSE")
        ; StatusText.Text := "Switched to Lex SE (Java) - Improved logic"
    } else if (selectedIndex == 4) {
        WorkflowMgr.SetActiveWorkflow("Verizon")
        ; StatusText.Text := "Switched to Verizon (Chrome) - Full number paste"
    } else if (selectedIndex == 5) {
        WorkflowMgr.SetActiveWorkflow("VFO")
        ; StatusText.Text := "Switched to VFO (Chrome) - Full number paste"
    } else if (selectedIndex == 6) {
        WorkflowMgr.SetActiveWorkflow("Chrome")
        ; StatusText.Text := "Switched to Chrome (Simple) - Full number paste"
    }
}

StartRecord(*) {
    global WorkflowMgr, StatusText, ActionCountText
    
    ; Check if we're currently playing
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    if (activeWorkflow.isPlaying) {
        StatusText.Text := "Cannot record while playing"
        return
    }
    
    ; Start recording with the active workflow
    if (WorkflowMgr.StartRecording()) {
        StatusText.Text := WorkflowMgr.GetRecordingInstructions()
        ActionCountText.Text := "0"
    } else {
        StatusText.Text := "Error: Failed to start recording"
    }
}

; Global variables for simple recorder
SimpleRecorderActive := false
SimpleRecorderActions := []

StartSimpleRecord(*) {
    global SimpleRecorderActive, SimpleRecorderActions, StatusText, ActionCountText
    
    if (SimpleRecorderActive) {
        StatusText.Text := "Simple recorder already active"
        return
    }
    
    ; Clear previous actions
    SimpleRecorderActions := []
    SimpleRecorderActive := true
    
    ; Set up hotkeys
    HotKey("^1", (*) => RecordPhoneField(), "On")
    HotKey("^2", (*) => RecordAddButton(), "On") 
    HotKey("^3", (*) => RecordRegularClick(), "On")
    HotKey("Escape", (*) => StopSimpleRecord(), "On")
    
    StatusText.Text := "Simple Recorder: Ctrl+1=Phone Field, Ctrl+2=Add Button, Ctrl+3=Click, ESC=Stop"
    ActionCountText.Text := "0"
}

; Record phone field location
RecordPhoneField() {
    global SimpleRecorderActive, SimpleRecorderActions, StatusText, ActionCountText
    if (!SimpleRecorderActive) 
        return
    
    MouseGetPos(&x, &y)
    winTitle := WinGetTitle("A")
    
    ; Add click action first
    SimpleRecorderActions.Push({
        Type: "Click", 
        X: x, 
        Y: y, 
        Window: winTitle
    })
    
    ; Add phone paste action
    SimpleRecorderActions.Push({
        Type: "SequentialPhonePart",
        UsePhoneNumber: true,
        PhonePart: 0,
        Window: winTitle
    })
    
    StatusText.Text := "Phone field recorded at (" . x . "," . y . ") - Continue or ESC to finish"
    ActionCountText.Text := SimpleRecorderActions.Length
}

; Record add button location  
RecordAddButton() {
    global SimpleRecorderActive, SimpleRecorderActions, StatusText, ActionCountText
    if (!SimpleRecorderActive) 
        return
    
    MouseGetPos(&x, &y)
    winTitle := WinGetTitle("A")
    
    SimpleRecorderActions.Push({
        Type: "Click",
        X: x, 
        Y: y,
        Window: winTitle
    })
    
    StatusText.Text := "Add button recorded at (" . x . "," . y . ") - Continue or ESC to finish"
    ActionCountText.Text := SimpleRecorderActions.Length
}

; Record regular click location
RecordRegularClick() {
    global SimpleRecorderActive, SimpleRecorderActions, StatusText, ActionCountText
    if (!SimpleRecorderActive) 
        return
    
    MouseGetPos(&x, &y)
    winTitle := WinGetTitle("A")
    
    SimpleRecorderActions.Push({
        Type: "Click",
        X: x,
        Y: y, 
        Window: winTitle
    })
    
    StatusText.Text := "Click recorded at (" . x . "," . y . ") - Continue or ESC to finish"
    ActionCountText.Text := SimpleRecorderActions.Length
}

; Stop simple recording
StopSimpleRecord() {
    global SimpleRecorderActive, SimpleRecorderActions, WorkflowMgr, StatusText, ActionCountText
    
    if (!SimpleRecorderActive) 
        return
    
    ; Turn off hotkeys
    HotKey("^1", "Off")
    HotKey("^2", "Off")
    HotKey("^3", "Off")
    HotKey("Escape", "Off")
    
    SimpleRecorderActive := false
    
    ; Load actions into active workflow
    if (SimpleRecorderActions.Length > 0) {
        activeWorkflow := WorkflowMgr.GetActiveWorkflow()
        activeWorkflow.actions := SimpleRecorderActions
        activeWorkflow.currentActionIndex := 1
        
        StatusText.Text := "Simple recording complete: " . SimpleRecorderActions.Length . " actions recorded"
        ActionCountText.Text := SimpleRecorderActions.Length
    } else {
        StatusText.Text := "No actions recorded"
        ActionCountText.Text := "0"
    }
}

StopRecord(*) {
    global WorkflowMgr, StatusText, ActionCountText
    
    WorkflowMgr.StopRecording()
    actionCount := WorkflowMgr.GetActionCount()
    StatusText.Text := "Recording stopped. " . actionCount . " actions recorded."
    ActionCountText.Text := actionCount
}

ClearActions(*) {
    global WorkflowMgr, StatusText, ActionCountText
    
    WorkflowMgr.ClearActions()
    StatusText.Text := "Actions cleared"
    ActionCountText.Text := "0"
}

SaveActions(*) {
    global WorkflowMgr, StatusText
    
    actionCount := WorkflowMgr.GetActionCount()
    if (actionCount == 0) {
        StatusText.Text := "No actions to save"
        return
    }
    
    StatusText.Text := "Saving " . actionCount . " actions..."
    
    ; Get current workflow name for default filename
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    workflowName := activeWorkflow.name
    ; Replace spaces with underscores for filename
    workflowFileName := StrReplace(workflowName, " ", "_")
    defaultFileName := workflowFileName . "_Actions.json"
    
    saveFile := FileSelect("S", defaultFileName, "Save Actions", "JSON Files (*.json)")
    if (saveFile != "") {
        try {
            result := WorkflowMgr.SaveActions(saveFile)
            if (result) {
                StatusText.Text := "✓ Saved " . actionCount . " actions to file"
            } else {
                StatusText.Text := "❌ Save failed - check file permissions"
            }
        } catch as err {
            StatusText.Text := "❌ Save error: " . err.Message
        }
    } else {
        StatusText.Text := "Save cancelled"
    }
}

LoadActions(*) {
    global WorkflowMgr, StatusText, ActionCountText, RawPhoneNumbers
    
    ; Stop any ongoing playback first
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    if (activeWorkflow.isPlaying) {
        activeWorkflow.isPlaying := false
        activeWorkflow.singlePlayMode := false
        ; Stop all timers
        SetTimer((*) => PlayNextAction(), 0)
        SetTimer((*) => PlayNextActionForMulti(), 0)
        SetTimer((*) => ExecuteMultiPlaySequence(), 0)
    }
    
    loadFile := FileSelect(3, , "Load Actions", "JSON Files (*.json)")
    if (loadFile != "") {
        try {
            if (WorkflowMgr.LoadActions(loadFile)) {
                actionCount := WorkflowMgr.GetActionCount()
                ActionCountText.Text := actionCount
                
                ; Auto-detect workflow type based on filename
                fileName := ""
                if (InStr(loadFile, "\")) {
                    parts := StrSplit(loadFile, "\")
                    fileName := parts[parts.Length]
                } else {
                    fileName := loadFile
                }
            
            ; Auto-detect workflow type and set appropriate workflow
            if (InStr(fileName, "Neustar") || InStr(fileName, "NEUSTAR")) {
                WorkflowMgr.SetActiveWorkflow("Neustar")
                WorkflowSelect.Choose(1)
                ; StatusText.Text := "Loaded Neustar workflow: " . actionCount . " actions"
            } else if (InStr(fileName, "LexSE") || InStr(fileName, "LEXSE") || InStr(fileName, "Lex_SE") || InStr(fileName, "LEX_SE")) {
                WorkflowMgr.SetActiveWorkflow("LexSE")
                WorkflowSelect.Choose(3)
                ; StatusText.Text := "Loaded Lex SE workflow: " . actionCount . " actions"
            } else if (InStr(fileName, "Lex") || InStr(fileName, "LEX")) {
                WorkflowMgr.SetActiveWorkflow("Lex")
                WorkflowSelect.Choose(2)
                ; StatusText.Text := "Loaded Lex W-MW-SW workflow: " . actionCount . " actions"
            } else if (InStr(fileName, "Verizon") || InStr(fileName, "VERIZON")) {
                WorkflowMgr.SetActiveWorkflow("Verizon")
                WorkflowSelect.Choose(4)
                ; StatusText.Text := "Loaded Verizon workflow: " . actionCount . " actions"
            } else if (InStr(fileName, "VFO") || InStr(fileName, "vfo")) {
                WorkflowMgr.SetActiveWorkflow("VFO")
                WorkflowSelect.Choose(5)
                ; StatusText.Text := "Loaded VFO workflow: " . actionCount . " actions"
            } else if (InStr(fileName, "Chrome") || InStr(fileName, "CHROME")) {
                WorkflowMgr.SetActiveWorkflow("Chrome")
                WorkflowSelect.Choose(6)
                ; StatusText.Text := "Loaded Chrome workflow: " . actionCount . " actions"
            } else {
                ; StatusText.Text := "Loaded " . actionCount . " actions from " . fileName
            }
            
                ; Auto-reformat existing phone numbers if we have them
                if (RawPhoneNumbers.Length > 0) {
                    FormatPhoneNumbers()
                    StatusText.Text := StatusText.Text . " - Numbers reformatted"
                }
            } else {
                StatusText.Text := "❌ Failed to load actions - file may be corrupted"
            }
        } catch as err {
            StatusText.Text := "❌ Load error: " . err.Message
            ActionCountText.Text := "0"
        }
    }
}

; Workflow-based playback functions
PlayActions(*) {
    global WorkflowMgr, FormattedPhoneNumbers, RawPhoneNumbers, CurrentPhoneIndex, StatusText, ProgressText, ProgressBar, CurrentPhoneText
    global SlowModeCheck, skipNextPhone
    static isMultiPlaying := false
    
    ; Reset the consecutive skip flag at start of play actions
    skipNextPhone := false
    
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    
    ; Reset row counter for workflows at start of multi-play
    if (activeWorkflow.HasProp("ResetRowCounter")) {
        activeWorkflow.ResetRowCounter()
    }
    
    if (activeWorkflow.isRecording) {
        ; StatusText.Text := "Cannot play while recording"
        return
    }
    if (activeWorkflow.GetActionCount() == 0) {
        ; StatusText.Text := "No actions recorded - record workflow first"
        return
    }
    if (FormattedPhoneNumbers.Length == 0) {
        ; StatusText.Text := "No formatted phone numbers - load and format numbers first"
        return
    }
    
    
    ; Validate workflow before playing  
    validationResult := ValidateWorkflow(activeWorkflow)
    if (!validationResult) {
        result := MsgBox("Workflow validation failed. Continue anyway?", "Workflow Validation", 4)
        if (result != "Yes") {
            ; StatusText.Text := "Playback cancelled by user"
            return
        }
    }
    
    ; EXACT SAME SETUP AS PLAYSINGLE - NO DIFFERENCES AT ALL
    activeWorkflow.isPlaying := true
    activeWorkflow.SetPlaybackMode(false)  ; Multi-play mode (ONLY difference from PlaySingle)
    activeWorkflow.SetPlaybackSettings(true, SlowModeCheck.Value, "")  ; Background always true
    
    ; Find target window - EXACT SAME AS PLAYSINGLE
    if (activeWorkflow.actions.Length > 0) {
        for action in activeWorkflow.actions {
            if (action.HasProp("Window") && action.Window != "" && !InStr(action.Window, "Telnyx Phone Filler")) {
                compatibleWindow := FindCompatibleWindow(action.Window)
                if (compatibleWindow != "") {
                    activeWorkflow.SetPlaybackSettings(true, SlowModeCheck.Value, compatibleWindow)  ; Background always true
                    break
                }
            }
        }
    }
    
    ; Reset to first phone if needed
    if (CurrentPhoneIndex > FormattedPhoneNumbers.Length) {
        CurrentPhoneIndex := 1
    }
    
    totalPhones := FormattedPhoneNumbers.Length
    ; GUI updates removed to prevent foreground activation
    ; CurrentPhoneText.Text := CurrentPhoneIndex . "/" . totalPhones . ": " . FormattedPhoneNumbers[CurrentPhoneIndex]
    ; ProgressText.Text := CurrentPhoneIndex . " / " . totalPhones
    ; StatusText.Text := "🎯 Starting multi-phone playback for " . totalPhones . " numbers..."
    ; ProgressBar.Value := 0
    
    ; EXACT SAME AS PLAYSINGLE - just with multi-play mode
    activeWorkflow.currentActionIndex := 1
    
    ; Activate target window ONCE at the start - SAME AS PLAYSINGLE
    if (activeWorkflow.targetWindow != "" && WinExist(activeWorkflow.targetWindow)) {
        WinActivate(activeWorkflow.targetWindow)
        Sleep(50)  ; Quick window activation
    }
    
    Sleep(100)  ; Minimal initial delay  
    SetTimer((*) => PlayNextAction(), 250)  ; USE EXACT SAME TIMER AS PLAYSINGLE
}

ExecuteMultiPlaySequence() {
    global WorkflowMgr, FormattedPhoneNumbers, CurrentPhoneIndex, StatusText, ProgressText, ProgressBar, CurrentPhoneText
    static isMultiPlaying := false
    
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    
    ; Check if user stopped or we're done
    if (!activeWorkflow.isPlaying || CurrentPhoneIndex > FormattedPhoneNumbers.Length) {
        SetTimer((*) => ExecuteMultiPlaySequence(), 0)
        isMultiPlaying := false
        
        if (CurrentPhoneIndex > FormattedPhoneNumbers.Length) {
            ; Completed all phones - GUI updates removed to prevent foreground activation
            ; ProgressBar.Value := 100
            ; StatusText.Text := "✓ All " . FormattedPhoneNumbers.Length . " phone numbers processed!"
            CurrentPhoneIndex := 1
            ; CurrentPhoneText.Text := CurrentPhoneIndex . "/" . FormattedPhoneNumbers.Length . ": " . FormattedPhoneNumbers[1]
            ; ProgressText.Text := CurrentPhoneIndex . " / " . FormattedPhoneNumbers.Length
        } else {
            ; StatusText.Text := "⏹️ Multi-playback stopped by user"
        }
        return
    }
    
    ; Update progress display - GUI updates removed to prevent foreground activation
    ; CurrentPhoneText.Text := CurrentPhoneIndex . "/" . FormattedPhoneNumbers.Length . ": " . FormattedPhoneNumbers[CurrentPhoneIndex]
    ; ProgressText.Text := CurrentPhoneIndex . " / " . FormattedPhoneNumbers.Length
    ; progress := Round((CurrentPhoneIndex - 1) / FormattedPhoneNumbers.Length * 100)
    ; ProgressBar.Value := progress
    ; StatusText.Text := "🎯 Processing phone " . CurrentPhoneIndex . " of " . FormattedPhoneNumbers.Length . ": " . FormattedPhoneNumbers[CurrentPhoneIndex]
    
    ; Stop the multi-sequence timer
    SetTimer((*) => ExecuteMultiPlaySequence(), 0)
    
    ; Execute one PlaySingle cycle - this calls the exact same logic that works perfectly
    ExecutePlaySingleCycle()
}

ExecutePlaySingleCycle() {
    global WorkflowMgr, FormattedPhoneNumbers, RawPhoneNumbers, CurrentPhoneIndex, StatusText, SlowModeCheck
    
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    
    ; Use exact same setup as PlaySingle
    activeWorkflow.SetPlaybackMode(true)  ; Single play mode - EXACTLY like working PlaySingle
    activeWorkflow.SetPlaybackSettings(true, SlowModeCheck.Value, "")  ; Background always true
    
    ; Find target window for background operation - EXACTLY like PlaySingle
    if (activeWorkflow.actions.Length > 0) {
        for action in activeWorkflow.actions {
            if (action.HasProp("Window") && action.Window != "" && !InStr(action.Window, "Telnyx Phone Filler")) {
                compatibleWindow := FindCompatibleWindow(action.Window)
                if (compatibleWindow != "") {
                    activeWorkflow.SetPlaybackSettings(true, SlowModeCheck.Value, compatibleWindow)  ; Background always true
                    break
                }
            }
        }
    }
    
    ; Set the currentActionIndex to 1 for this phone - EXACTLY like PlaySingle
    activeWorkflow.currentActionIndex := 1
    
    ; Start the PlayNextAction timer - EXACTLY like PlaySingle
    Sleep(500)  ; Same initial delay as PlaySingle
    SetTimer((*) => PlayNextActionForMulti(), 250)  ; Same timer interval as PlaySingle
}

PlayNextActionForMulti() {
    global WorkflowMgr, CurrentPhoneIndex, FormattedPhoneNumbers, RawPhoneNumbers, StatusText
    
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    
    ; Check if this single cycle is complete
    if (activeWorkflow.currentActionIndex > activeWorkflow.actions.Length) {
        ; This phone is done, move to next
        CurrentPhoneIndex++
        
        ; Check if we're done with all phones
        if (CurrentPhoneIndex > FormattedPhoneNumbers.Length) {
            ; All done, stop the timer
            SetTimer((*) => PlayNextActionForMulti(), 0)
            activeWorkflow.isPlaying := false
            CurrentPhoneIndex := 1
            return
        }
        
        ; Brief pause between phones
        Sleep(500)
        
        ; Additional delay for LexSE Java app loading
        if (activeWorkflow.workflowName == "Lex SE (Java)") {
            Sleep(1000)  ; Extra 1 second for Java app page loading
        }
        
        ; Reset action index for next phone and continue WITHOUT resetting workflow state
        activeWorkflow.currentActionIndex := 1
        
        ; Activate target window ONCE for the new cycle
        if (activeWorkflow.targetWindow != "" && WinExist(activeWorkflow.targetWindow)) {
            WinActivate(activeWorkflow.targetWindow)
            Sleep(200)  ; Give window time to activate
        }
        
        ; Continue with same timer - don't call ExecuteMultiPlaySequence
        return
    }
    
    ; Execute the action - EXACTLY the same as regular PlayNextAction
    try {
        action := activeWorkflow.actions[activeWorkflow.currentActionIndex]
        activeWorkflow.currentActionIndex++
        
        ; Get current phone number data
        phoneNumber := ""
        rawPhoneNumber := ""
        if (CurrentPhoneIndex <= FormattedPhoneNumbers.Length) {
            phoneNumber := FormattedPhoneNumbers[CurrentPhoneIndex]
            if (CurrentPhoneIndex <= RawPhoneNumbers.Length) {
                rawPhoneNumber := RawPhoneNumbers[CurrentPhoneIndex]
            }
        }
        
        ; Execute using the same method as working PlaySingle
        activeWorkflow.ExecuteAction(action, phoneNumber, rawPhoneNumber, StatusText)
        
    } catch as err {
        ; StatusText.Text := "Error in multi-play: " . err.Message - status update removed
        ; Continue despite error
    }
}

PlaySingle(*) {
    global WorkflowMgr, FormattedPhoneNumbers, RawPhoneNumbers, CurrentPhoneIndex, StatusText
    global SlowModeCheck
    
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    if (activeWorkflow.isRecording) {
        ; StatusText.Text := "Cannot play while recording"
        return
    }
    if (activeWorkflow.GetActionCount() == 0) {
        ; StatusText.Text := "No actions recorded"
        return
    }
    if (FormattedPhoneNumbers.Length == 0) {
        ; StatusText.Text := "No formatted phone numbers loaded"
        return
    }
    
    ; Set up workflow for single playback (background mode always ON)
    activeWorkflow.isPlaying := true
    activeWorkflow.SetPlaybackMode(true)  ; Single play mode
    activeWorkflow.SetPlaybackSettings(true, SlowModeCheck.Value, "")  ; Background always true
    
    ; Find target window for background operation
    if (activeWorkflow.actions.Length > 0) {
        for action in activeWorkflow.actions {
            if (action.HasProp("Window") && action.Window != "" && !InStr(action.Window, "Telnyx Phone Filler")) {
                compatibleWindow := FindCompatibleWindow(action.Window)
                if (compatibleWindow != "") {
                    activeWorkflow.SetPlaybackSettings(true, SlowModeCheck.Value, compatibleWindow)  ; Background always true
                    break
                }
            }
        }
    }
    
    ; StatusText.Text := "🎯 Background: Playing single - " . FormattedPhoneNumbers[CurrentPhoneIndex]
    
    ; Activate target window ONCE at the start of PlaySingle
    if (activeWorkflow.targetWindow != "" && WinExist(activeWorkflow.targetWindow)) {
        WinActivate(activeWorkflow.targetWindow)
        Sleep(50)  ; Quick window activation
    }
    
    ; Reset action index for PlaySingle
    activeWorkflow.currentActionIndex := 1
    
    ; Start single playback with minimal delay
    Sleep(100)  ; Minimal initial delay
    SetTimer((*) => PlayNextAction(), 250)  ; Increased timer interval for reliability
}

StopPlay(*) {
    global WorkflowMgr, StatusText
    
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    activeWorkflow.isPlaying := false
    activeWorkflow.singlePlayMode := false
    
    ; Stop ALL possible timers completely
    SetTimer((*) => PlayNextAction(), 0)
    SetTimer((*) => PlayNextActionForMulti(), 0)
    SetTimer((*) => ExecuteMultiPlaySequence(), 0)
    SetTimer((*) => ExecutePlaySingleCycle(), 0)
    
    StatusText.Text := "⏹️ Playback stopped by user"
}

PausePlay(*) {
    global WorkflowMgr, StatusText, FormattedPhoneNumbers
    
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    if (activeWorkflow.isPlaying) {
        activeWorkflow.isPlaying := false
        SetTimer((*) => PlayNextAction(), 0)
        StatusText.Text := "Playback paused - click 'Play Actions' to resume"
    } else if (activeWorkflow.GetActionCount() > 0 && FormattedPhoneNumbers.Length > 0) {
        activeWorkflow.isPlaying := true
        SetTimer((*) => PlayNextAction(), 100)
        StatusText.Text := "Playback resumed..."
    }
}

; Main playback execution function
PlayNextAction() {
    global WorkflowMgr, CurrentPhoneIndex, FormattedPhoneNumbers, RawPhoneNumbers, ProgressBar, ProgressText, CurrentPhoneText, StatusText
    static isExecuting := false  ; Prevent overlapping executions
    
    ; Skip if already executing an action
    if (isExecuting) {
        return
    }
    
    try {
        activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    } catch as err {
        ; StatusText.Text := "Error: Unable to get active workflow"
        SetTimer((*) => PlayNextAction(), 0)
        return
    }
    
    if (!activeWorkflow.isPlaying || activeWorkflow.currentActionIndex > activeWorkflow.actions.Length) {
        ; Finished all actions for current phone number
        if (activeWorkflow.isPlaying) { ; Only advance if we weren't stopped
            if (activeWorkflow.singlePlayMode) {
                ; Single play mode - stop after one phone number
                activeWorkflow.isPlaying := false
                activeWorkflow.singlePlayMode := false
                SetTimer((*) => PlayNextAction(), 0)
                ; StatusText.Text := "✓ Single playback completed: " . FormattedPhoneNumbers[CurrentPhoneIndex]
                return
            } else {
                ; Multi-play mode - Continue with next phone number
                CurrentPhoneIndex++
                
                ; Check if this phone was already used as consecutive in LexSE
                global skipNextPhone
                if (skipNextPhone && activeWorkflow.name != "Lex SE (Java)") {
                    ; Skip this phone as it was already used as consecutive
                    ; BUT NOT for LexSE - it handles its own logic
                    skipNextPhone := false
                    ; Only increment if we won't exceed the bounds
                    if (CurrentPhoneIndex < FormattedPhoneNumbers.Length) {
                        CurrentPhoneIndex++
                    }
                } else if (activeWorkflow.name == "Lex SE (Java)") {
                    ; Reset skipNextPhone for LexSE to ensure clean processing
                    skipNextPhone := false
                }
                
                ; LEXSE SPECIFIC FIX: Ensure LexSE continues processing all numbers without artificial limits
                if (activeWorkflow.name == "Lex SE (Java)") {
                    ; Force continuation for LexSE workflow - no cycle limits
                    ; This ensures LexSE processes ALL phone numbers like other workflows
                }
                
                if (CurrentPhoneIndex <= FormattedPhoneNumbers.Length) {
                    ; Start over with next phone number
                    activeWorkflow.currentActionIndex := 1
                    
                    ; For workflows that support cycles, increment cycle number for new row
                    if (activeWorkflow.HasProp("StartNewCycle")) {
                        activeWorkflow.StartNewCycle()
                    }
                    
                    ; Wait between phones and activate window for new cycle
                    Sleep(1000)  ; Longer pause to allow page to stabilize after new row creation
                    if (activeWorkflow.targetWindow != "" && WinExist(activeWorkflow.targetWindow)) {
                        WinActivate(activeWorkflow.targetWindow)
                        Sleep(50)  ; Quick window activation
                    }
                    
                    return
                } else {
                    ; All phone numbers processed
                    activeWorkflow.isPlaying := false
                    SetTimer((*) => PlayNextAction(), 0)
                    ; StatusText.Text := "✓ All phones processed!"
                    ; ProgressBar.Value := 100
                    CurrentPhoneIndex := 1
                    ; GUI updates removed to prevent Filler activation
                    ; if (FormattedPhoneNumbers.Length > 0) {
                    ;     CurrentPhoneText.Text := CurrentPhoneIndex . "/" . FormattedPhoneNumbers.Length . ": " . FormattedPhoneNumbers[1]
                    ;     ProgressText.Text := CurrentPhoneIndex . " / " . FormattedPhoneNumbers.Length
                    ; }
                    return
                }
            }
        } else {
            SetTimer((*) => PlayNextAction(), 0)
            return
        }
    }
    
    ; Execute the current action
    if (activeWorkflow.currentActionIndex > activeWorkflow.actions.Length) {
        ; StatusText.Text := "Error: Action index out of bounds"
        activeWorkflow.isPlaying := false
        SetTimer((*) => PlayNextAction(), 0)
        return
    }
    
    ; Set executing flag
    isExecuting := true
    
    action := activeWorkflow.actions[activeWorkflow.currentActionIndex]
    
    ; Get the current action
    
    activeWorkflow.currentActionIndex++
    
    ; Debug: Check if action is valid
    if (!IsObject(action)) {
        ; StatusText.Text := "Error: Action is not an object at index " . (activeWorkflow.currentActionIndex - 1)
        isExecuting := false
        return
    }
    
    ; Get current phone number data
    phoneNumber := ""
    rawPhoneNumber := ""
    if (CurrentPhoneIndex <= FormattedPhoneNumbers.Length) {
        phoneNumber := FormattedPhoneNumbers[CurrentPhoneIndex]
    }
    if (CurrentPhoneIndex <= RawPhoneNumbers.Length) {
        rawPhoneNumber := RawPhoneNumbers[CurrentPhoneIndex]
    }
    
    ; Execute the action using the workflow's specific execution logic
    try {
        ; Check if action has required properties
        if (!action.HasProp("Type")) {
            ; StatusText.Text := "Error: Action missing Type property"
            return
        }
        
        ; StatusText.Text := "Executing " . action.Type . " at (" . (action.HasProp("X") ? action.X : "N/A") . "," . (action.HasProp("Y") ? action.Y : "N/A") . ")"
        
        activeWorkflow.ExecuteAction(action, phoneNumber, rawPhoneNumber, StatusText)
        ; Add small buffer delay between actions for stability
        Sleep(150)
    } catch as err {
        actionType := action.HasProp("Type") ? action.Type : "Unknown"
        StatusText.Text := "Error executing " . actionType . ": " . err.Message
        ; Continue with next action despite error
    } finally {
        ; Always clear executing flag
        isExecuting := false
    }
}

; =====================================================
; Workflow Validation Functions
; =====================================================

ValidateWorkflow(workflow) {
    global StatusText
    
    ; Validate that workflow has necessary components
    if (!workflow || workflow.actions.Length == 0) {
        return false
    }
    
    ; Check for phone number actions in the workflow
    hasPhoneAction := false
    for action in workflow.actions {
        if (action.HasProp("UsePhoneNumber") && action.UsePhoneNumber) {
            hasPhoneAction := true
            break
        }
    }
    
    ; Warn if no phone actions found
    if (!hasPhoneAction) {
        StatusText.Text := "Warning: No phone number fields detected in workflow"
    }
    
    ; Check if target windows exist (for non-Alt+Tab actions)
    windowsFound := true
    for action in workflow.actions {
        if (action.HasProp("Window") && action.Window != "" && action.Type != "AltTab") {
            if (!FindCompatibleWindow(action.Window)) {
                windowsFound := false
                StatusText.Text := "Warning: Target window not found: " . action.Window
                break
            }
        }
    }
    
    return windowsFound
}

; =====================================================
; Window Detection Helper Functions
; =====================================================

FindCompatibleWindow(originalTitle) {
    ; Try exact match first
    if (WinExist(originalTitle)) {
        return originalTitle
    }
    
    ; Extract key identifiers from original title with priority scoring
    browserKeywords := []
    contentKeywords := []
    
    ; Browser identification (highest priority)
    if (InStr(originalTitle, "Microsoft") && InStr(originalTitle, "Edge")) {
        browserKeywords.Push("Microsoft")
        browserKeywords.Push("Edge")
    } else if (InStr(originalTitle, "Edge")) {
        browserKeywords.Push("Edge")
    }
    
    if (InStr(originalTitle, "Chrome")) {
        browserKeywords.Push("Chrome")
    }
    
    ; Content identification (secondary priority)
    if (InStr(originalTitle, "LSR")) {
        contentKeywords.Push("LSR")
    }
    if (InStr(originalTitle, "Order")) {
        contentKeywords.Push("Order")
    }
    if (InStr(originalTitle, "Number Port")) {
        contentKeywords.Push("Port")
    }
    
    ; Try to find window with similar characteristics
    bestMatch := ""
    bestScore := 0
    
    windowList := WinGetList()
    for windowID in windowList {
        try {
            windowTitle := WinGetTitle(windowID)
            if (windowTitle == "" || InStr(windowTitle, "Telnyx Phone Filler")) {
                continue
            }
            
            ; Calculate match score
            score := 0
            
            ; Browser keywords are worth more points
            for keyword in browserKeywords {
                if (InStr(windowTitle, keyword)) {
                    score += 3  ; Browser match is worth 3 points
                }
            }
            
            ; Content keywords are worth less but still valuable
            for keyword in contentKeywords {
                if (InStr(windowTitle, keyword)) {
                    score += 1  ; Content match is worth 1 point
                }
            }
            
            ; Update best match if this is better
            if (score > bestScore) {
                bestScore := score
                bestMatch := windowTitle
            }
        } catch {
            ; Skip windows we can't access
            continue
        }
    }
    
    ; Return best match if we found any browser match (score >= 3)
    ; Or if we have some content matches (score >= 2) 
    if (bestScore >= 3 || (bestScore >= 2 && contentKeywords.Length > 0)) {
        return bestMatch
    }
    
    ; Fallback: try to find any Edge or Chrome window as last resort
    for windowID in windowList {
        try {
            windowTitle := WinGetTitle(windowID)
            if (windowTitle == "" || InStr(windowTitle, "Telnyx Phone Filler")) {
                continue
            }
            
            ; Look for any browser window
            if (browserKeywords.Length > 0) {
                if ((InStr(originalTitle, "Edge") && InStr(windowTitle, "Edge")) || 
                    (InStr(originalTitle, "Chrome") && InStr(windowTitle, "Chrome"))) {
                    return windowTitle
                }
            }
        } catch {
            continue
        }
    }
    
    ; No compatible window found
    return ""
}

ActivateCompatibleWindow(originalTitle) {
    compatibleTitle := FindCompatibleWindow(originalTitle)
    if (compatibleTitle != "") {
        try {
            WinActivate(compatibleTitle)
            return compatibleTitle
        } catch {
            return ""
        }
    }
    return ""
}

; =====================================================
; Playback Functions
; =====================================================

LoadNumbers(*) {
    global PhoneNumbersEdit, RawPhoneNumbers, PhoneCountText, StatusText
    phoneText := PhoneNumbersEdit.Text
    RawPhoneNumbers := ExtractNumbers(phoneText)
    if (RawPhoneNumbers.Length > 0) {
        PhoneCountText.Text := "Loaded " . RawPhoneNumbers.Length . " phone numbers"
        FormatPhoneNumbers()
    } else {
        PhoneCountText.Text := "No valid numbers found"
        StatusText.Text := "No valid phone numbers found (need 10+ digits)"
    }
}

LoadFromFile(*) {
    global PhoneNumbersEdit, RawPhoneNumbers, PhoneCountText
    selectedFile := FileSelect(3, , "Select phone numbers file", "Text Files (*.txt)")
    if (selectedFile != "") {
        fileContent := FileRead(selectedFile)
        PhoneNumbersEdit.Text := fileContent
        RawPhoneNumbers := ExtractNumbers(fileContent)
        if (RawPhoneNumbers.Length > 0) {
            PhoneCountText.Text := "Loaded " . RawPhoneNumbers.Length . " from file"
            FormatPhoneNumbers()
        }
    }
}

ApplyFormat(*) {
    global
    FormatPhoneNumbers()
}

; =====================================================
; Custom Format Management Functions
; =====================================================

UpdateCustomFormatsList() {
    global CustomFormatSelect, CustomFormats
    formatArray := []
    for name in CustomFormats {
        formatArray.Push(name)
    }
    
    CustomFormatSelect.Delete()
    for name in formatArray {
        CustomFormatSelect.Add([name])
    }
}

UpdateCustomFormat(*) {
    global CustomFormatSelect, CustomFormats, CustomFormatPreview
    customFormatName := CustomFormatSelect.Text
    if (CustomFormats.Has(customFormatName)) {
        pattern := CustomFormats[customFormatName]
        ; Show preview
        preview := StrReplace(pattern, "X", "8")
        CustomFormatPreview.Text := "Preview: " . preview
    }
}

ManageCustomFormats(*) {
    global CustomFormats, CustomFormatSelect
    
    ; Create custom formats management GUI
    CustomGui := Gui(, "Manage Custom Formats")
    CustomGui.Add("Text", "x10 y10 w300", "Manage Custom Phone Number Formats")
    CustomGui.Add("Text", "x10 y35 w300", "Use X for digits. Examples: +1XXXXXXXXXX, XXX*XXX*XXXX")
    
    CustomGui.Add("Text", "x10 y60", "Format Name:")
    CustomFormatNameEdit := CustomGui.Add("Edit", "x10 y80 w200")
    CustomGui.Add("Text", "x10 y110", "Format Pattern:")
    CustomFormatPatternEdit := CustomGui.Add("Edit", "x10 y130 w200")
    AddCustomFormatBtn := CustomGui.Add("Button", "x220 y130 w80 h23", "Add Format")
    
    CustomGui.Add("Text", "x10 y165", "Existing Formats:")
    CustomFormatsList := CustomGui.Add("ListBox", "x10 y185 w200 h100")
    EditCustomFormatBtn := CustomGui.Add("Button", "x220 y185 w80 h23", "Edit")
    DeleteCustomFormatBtn := CustomGui.Add("Button", "x220 y215 w80 h23", "Delete")
    
    ; Event handlers
    AddCustomFormatBtn.OnEvent("Click", (*) => AddCustomFormatAction())
    EditCustomFormatBtn.OnEvent("Click", (*) => EditCustomFormatAction())
    DeleteCustomFormatBtn.OnEvent("Click", (*) => DeleteCustomFormatAction())
    CustomFormatsList.OnEvent("Change", (*) => SelectCustomFormatAction())
    CustomGui.OnEvent("Close", (*) => CustomGui.Close())
    
    ; Local functions for custom format management
    AddCustomFormatAction() {
        name := CustomFormatNameEdit.Text
        pattern := CustomFormatPatternEdit.Text
        
        if (name != "" && pattern != "") {
            ; Validate pattern has at least 10 X's
            xCount := 0
            for char in StrSplit(pattern) {
                if (char == "X")
                    xCount++
            }
            if (xCount < 10) {
                MsgBox("Pattern must contain at least 10 X's for phone numbers", "Invalid Pattern", 48)
                return
            }
            
            CustomFormats[name] := pattern
            UpdateCustomFormatsListLocal()
            UpdateCustomFormatsList()
            CustomFormatNameEdit.Text := ""
            CustomFormatPatternEdit.Text := ""
        }
    }
    
    SelectCustomFormatAction() {
        ; Handle selection changes
    }
    
    EditCustomFormatAction() {
        selectedText := CustomFormatsList.Text
        if (selectedText != "") {
            CustomFormatNameEdit.Text := selectedText
            if (CustomFormats.Has(selectedText)) {
                pattern := CustomFormats[selectedText]
                CustomFormatPatternEdit.Text := pattern
            }
        }
    }
    
    DeleteCustomFormatAction() {
        selectedText := CustomFormatsList.Text
        if (selectedText != "") {
            result := MsgBox("Delete format `"" . selectedText . "`"?", "Confirm Delete", 4)
            if (result == "Yes") {
                CustomFormats.Delete(selectedText)
                UpdateCustomFormatsListLocal()
                UpdateCustomFormatsList()
            }
        }
    }
    
    UpdateCustomFormatsListLocal() {
        formatArray := []
        for name in CustomFormats {
            formatArray.Push(name)
        }
        CustomFormatsList.Delete()
        for name in formatArray {
            CustomFormatsList.Add([name])
        }
    }
    
    UpdateCustomFormatsListLocal()
    CustomGui.Show("w320 h320")
}

; Emergency stop with ESC during playback
~Escape:: {
    global WorkflowMgr, StatusText
    activeWorkflow := WorkflowMgr.GetActiveWorkflow()
    if (activeWorkflow.isPlaying) {
        activeWorkflow.isPlaying := false
        activeWorkflow.singlePlayMode := false
        ; Stop ALL possible timers completely - SAME AS STOPPLAY
        SetTimer((*) => PlayNextAction(), 0)
        SetTimer((*) => PlayNextActionForMulti(), 0)
        SetTimer((*) => ExecuteMultiPlaySequence(), 0)
        SetTimer((*) => ExecutePlaySingleCycle(), 0)
        StatusText.Text := "⏹️ Playback stopped by user (ESC pressed)"
    }
}
