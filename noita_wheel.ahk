; [slagrasta] Adapted from "JoysticMouse.ahk"
; Using a Joystick as a Mouse
; https://www.autohotkey.com

; Decrease the following value to require less joystick displacement-from-center
; to start moving the mouse.  However, you may need to calibrate your joystick
; -- ensuring it's properly centered -- to avoid cursor drift. A perfectly tight
; and centered joystick could use a value of 1:
JoyThreshold = 3

; If your joystick has a POV control, you can use it as a mouse wheel.  The
; following value is the number of milliseconds between turns of the wheel.
; Decrease it to have the wheel turn faster:
WheelDelay = 250

; If your system has more than one joystick, increase this value to use a joystick
; other than the first:
JoystickNumber = 1
JoystickPrefix = %JoystickNumber%Joy

; Noita-specific settings

; Mappings
; pedals all start at 100 and full-press is 0
; steering starts at 50, full left is 0 and full right is 100
controlSteerAxis = %JoystickPrefix%X
controlGasAxis = %JoystickPrefix%Z
controlBrakeAxis = %JoystickPrefix%R
controlClutchAxis = %JoystickPrefix%U
; POV is shifter dpad

; TODO: read these presses in the overlay and report current mode
controlRedButton1 = %JoystickPrefix%1
controlRedButton2 = %JoystickPrefix%2
controlRedButton3 = %JoystickPrefix%3
controlRedButton4 = %JoystickPrefix%4

controlRightPaddle = %JoystickPrefix%5
controlLeftPaddle = %JoystickPrefix%6

controlWheelButtonTopRight = %JoystickPrefix%7
controlWheelButtonTopLeft = %JoystickPrefix%8
controlWheelButtonMiddleRight = %JoystickPrefix%20
controlWheelButtonMiddleLeft = %JoystickPrefix%21
controlWheelButtonBottomRight = %JoystickPrefix%22
controlWheelButtonBottomLeft = %JoystickPrefix%23

controlGear1 = %JoystickPrefix%9
controlGear2 = %JoystickPrefix%10
controlGear3 = %JoystickPrefix%11
controlGear4 = %JoystickPrefix%12
controlGear5 = %JoystickPrefix%13
controlGear6 = %JoystickPrefix%14
controlGearReverse = %JoystickPrefix%15

controlShifterCrossTop = %JoystickPrefix%16
controlShifterCrossLeft = %JoystickPrefix%17
controlShifterCrossRight = %JoystickPrefix%19
controlShifterCrossBottom = %JoystickPrefix%18

; ControlModes (0=generic, 1=gameplay, 2=wandswap, 3=ambitious wand edit
global ControlMode := 0
global_selectControlModeGeneric = %controlRedButton4%
global_selectControlModeGameplay = %controlRedButton1%
global_selectControlModeWandSwap = %controlRedButton2%
global_selectControlModeWandEdit = %controlRedButton3%

gameplay_aimAxis = %controlSteerAxis%
gameplay_leftClickButton = %controlRightPaddle%
gameplay_rightClickButton = %controlWheelButtonTopLeft%
gameplay_walkRightAxis = %controlGasAxis%
gameplay_walkLeftAxis = %controlClutchAxis%
gameplay_levitateButton = %controlLeftPaddle%
gameplay_useButton = %controlWheelButtonTopRight%
gameplay_inventoryButton = %controlWheelButtonMiddleRight%
gameplay_meleeButton = %controlWheelButtonBottomRight%
gameplay_swimDownButton = %controlWheelButtonBottomLeft%

; We default to tool 1 if nothng else is selected
gameplay_selectTool2 = %controlGear1%
gameplay_selectTool3 = %controlGear2%
gameplay_selectTool4 = %controlGear3%
gameplay_selectTool5 = %controlGear4%
gameplay_selectTool6 = %controlGear5%
gameplay_selectTool7 = %controlGear6%
gameplay_selectTool8 = %controlGearReverse%

wandEdit_leftClick = %controlLeftPaddle%

; END OF CONFIG SECTION -- Don't change anything below this point unless you want
; to alter the basic nature of the script.

; Best-Guess state vars
activeToolSlot = 1 ; 1-based to keep mappings simpler
isLeftClickHeld := false
isRightClickHeld := false
isWalkLeftHeld := false
isWalkRightHeld := false

#SingleInstance

Hotkey, %global_selectControlModeGeneric%, SetControlMode_Generic
Hotkey, %global_selectControlModeGameplay%, SetControlMode_Gameplay
Hotkey, %global_selectControlModeWandSwap%, SetControlMode_WandSwap
Hotkey, %global_selectControlModeWandEdit%, SetControlMode_WandEdit

;Hotkey, %JoystickPrefix%6, LeftPaddlePressed
;Hotkey, %JoystickPrefix%5, RightPaddlePressed

Hotkey, %gameplay_useButton%, PressUseButton

; Hotkey state management functions
IsInGameplayMode := Func("IsInGameplayMode_")
IsInGameplayMode_()
{
	return ControlMode == 1
}

IsInWandSwapMode := Func("IsInWandSwapMode_")
IsInWandSwapMode_()
{
	return ControlMode == 2
}

IsInWandEditMode := Func("IsInWandEditMode_")
IsInWandEditMode_()
{
	return ControlMode == 3
}


; Levitation
DoLevitate()
{
	Send {Numpad8 down}
	SetTimer, %A_ThisFunc%_released, -10
}

DoLevitate_released()
{
	if(!GetKeyState(A_ThisHotkey))
		Send {Numpad8 up}
	else
		SetTimer, %A_ThisFunc%, -10
}

Hotkey, If, % IsInGameplayMode
Hotkey, %gameplay_levitateButton%, DoLevitate
Hotkey, If

; Swim Down
DoSwimDown()
{
	Send {Numpad5 down}
	SetTimer, %A_ThisFunc%_released, -10
}

DoSwimDown_released()
{
	if(!GetKeyState(A_ThisHotkey))
		Send {Numpad5 up}
	else
		SetTimer, %A_ThisFunc%, -10
}

Hotkey, If, % IsInGameplayMode
Hotkey, %gameplay_swimDownButton%, DoSwimDown
Hotkey, If

; Assorted other gameplay buttons
ToggleInventory()
{
	Send {Tab}
}

DoMelee()
{
	Send {Space}
}

Hotkey, If, % IsInGameplayMode
Hotkey, %gameplay_inventoryButton%, ToggleInventory
Hotkey, %gameplay_meleeButton%, DoMelee
Hotkey, If

; Shifter mappings
Hotkey, If, % IsInWandSwapMode
Hotkey, %controlShifterCrossTop%, ShifterCrossTopPressed
Hotkey, %controlShifterCrossLeft%, ShifterCrossLeftPressed
Hotkey, %controlShifterCrossRight%, ShifterCrossRightPressed
Hotkey, %controlShifterCrossBottom%, ShifterCrossBottomPressed
Hotkey, If

; Ambitious Wand Editing

; 		constants
global wandEditSpellWidth = 60 ; amount to move laterally to the next spell, it's a guess RN
global wandEditInventoryBaseline := [ 600, 88 ]
global wandEditFirstWandBaseline := [ 110, 280 ]
global wandEditNextWandOffset = 180

; 		state vars
global wandEditHoveredWandIndex = 0 ; index 0 is inventory, wands are 1-4
global wandEditHoveredSpellIndex = 0 ; probably limit this to spell inv size

;		action functions
WandEditCursorUp()
{
	if (wandEditHoveredWandIndex > 0)
		wandEditHoveredWandIndex--
		
	wandEditHoveredSpellIndex = 0
	WandEditUpdateWandHover()
}

WandEditCursorDown()
{
	if (wandEditHoveredWandIndex < 4)
		wandEditHoveredWandIndex++

	wandEditHoveredSpellIndex = 0
	WandEditUpdateWandHover()
}

WandEditCursorRight()
{
	;wandEditHoveredSpellIndex++
	MouseGetPos, x, y
	x += wandEditSpellWidth
	DllCall("SetCursorPos", "int", x, "int", y)
}

WandEditCursorLeft()
{
	;wandEditHoveredSpellIndex--
	MouseGetPos, x, y
	x -= wandEditSpellWidth
	DllCall("SetCursorPos", "int", x, "int", y)
}

WandEditUpdateSpellHover()
{
	x += wandEditSpellWidth
}

WandEditUpdateWandHover()
{
	x := (wandEditHoveredWandIndex == 0) ? wandEditInventoryBaseline[1] : wandEditFirstWandBaseline[1]
	
	y := (wandEditHoveredWandIndex == 0) ? wandEditInventoryBaseline[2] : wandEditFirstWandBaseline[2] + ((wandEditHoveredWandIndex - 1) * wandEditNextWandOffset)
	
	DllCall("SetCursorPos", "int", x, "int", y)
}

; NOTE: This pattern worked well with buttons but not with click for some reason
WandEditMouse()
{
	Click, Down
	SetTimer, %A_ThisFunc%_released, -10
}

WandEditMouse_released()
{
	if(!GetKeyState(A_ThisHotkey))
		Click, Up
	else
		SetTimer, %A_ThisFunc%, -10
}

;		mappings
Hotkey, If, % IsInWandEditMode
Hotkey, %controlShifterCrossTop%, WandEditCursorUp
Hotkey, %controlShifterCrossLeft%, WandEditCursorLeft
Hotkey, %controlShifterCrossRight%, WandEditCursorRight
Hotkey, %controlShifterCrossBottom%, WandEditCursorDown
;Hotkey, %wandEdit_leftClick%, WandEditMouse
Hotkey, If

GetKeyState, JoyInfo, %JoystickNumber%JoyInfo
IfInString, JoyInfo, P  ; Joystick has POV control, so use it as a mouse wheel.
	SetTimer, MouseWheel, %WheelDelay%


Loop
{
	Sleep, 10
	
	ForceQuit := GetKeyState("F12")
	if (ForceQuit)
		ExitApp

	if (ControlMode == 0)
	{
		MouseGetPos, x, y
		ToolTip %x% %y%
		continue
	}
	
	if (ControlMode == 3)
	{
		GetKeyState, lClick, %wandEdit_leftClick%	
		if (lClick == "D" && !isLeftClickHeld)
		{
			Click, Down
			isLeftClickHeld := true
		}
		else if(lClick == "U" && isLeftClickHeld)
		{
			Click, Up
			isLeftClickHeld := false
		}
	}
	
	GetKeyState, walkRightAxis, %gameplay_walkRightAxis%
	if (walkRightAxis < (100-JoyThreshold))	
	{
		if (!isWalkRightHeld)
			Send {Numpad6 down}
		isWalkRightHeld := true
	}
	else
	{
		if (isWalkRightHeld)
			Send {Numpad6 up}
		isWalkRightHeld := false
	}
		
	GetKeyState, walkLeftAxis, %gameplay_walkLeftAxis%
	if (walkLeftAxis < (100-JoyThreshold))
	{
		if (!isWalkLeftHeld)
			Send {Numpad4 down}
		isWalkLeftHeld := true
	}
	else
	{
		if (isWalkLeftHeld)
			Send {Numpad4 up}
		isWalkLeftHeld := false
	}

	if (ControlMode == 1)
	{
		GetKeyState, joystickName, %JoystickNumber%JoyName
		ToolTip %joystickName%

		SetFormat, float, 3.2
		GetKeyState, aimAxis, %gameplay_aimAxis%
		radians := (aimAxis/100.0) * (3.14 * 2) + (3.14/2)
		magnitude = 400
		x := Cos(radians) * magnitude
		y := Sin(radians) * magnitude
		;ToolTip, %x% %y% %radians
		screenMouseX := (A_ScreenWidth / 2) + x
		screenMouseY := (A_ScreenHeight / 2) + y
		DllCall("SetCursorPos", "int", screenMouseX, "int", screenMouseY)
			
		GetKeyState, lClick, %gameplay_leftClickButton%	
		if (lClick == "D" && !isLeftClickHeld)
		{
			Click, Down
			isLeftClickHeld := true
		}
		else if(lClick == "U" && isLeftClickHeld)
		{
			Click, Up
			isLeftClickHeld := false
		}
			
		GetKeyState, rClick, %gameplay_rightClickButton%
		if (rClick == "D" && !isRightClickHeld)
		{
			Click, Down Right
			isRightClickHeld := true
		}
		else if (rClick == "U" && isRightClickHeld)
		{
			Click, Up Right
			isRightClickHeld := false
		}
			
		desiredActiveToolSlot = 1
		GetKeyState, gear1Selected, %gameplay_selectTool2%
		if (gear1Selected == "D")
			desiredActiveToolSlot = 2
		GetKeyState, gear2Selected, %gameplay_selectTool3%
		if (gear2Selected == "D")
			desiredActiveToolSlot = 3
		GetKeyState, gear3Selected, %gameplay_selectTool4%
		if (gear3Selected == "D")
			desiredActiveToolSlot = 4
		GetKeyState, gear4Selected, %gameplay_selectTool5%
		if (gear4Selected == "D")
			desiredActiveToolSlot = 5
		GetKeyState, gear5Selected, %gameplay_selectTool6%
		if (gear5Selected == "D")
			desiredActiveToolSlot = 6
		GetKeyState, gear6Selected, %gameplay_selectTool7%
		if (gear6Selected == "D")
			desiredActiveToolSlot = 7
		GetKeyState, gearReverseSelected, %gameplay_selectTool8%
		if (gearReverseSelected == "D")
			desiredActiveToolSlot = 8
		
		if (desiredActiveToolSlot != activeToolSlot)
		{
			Send %desiredActiveToolSlot%
			activeToolSlot := desiredActiveToolSlot
		}

		
		GetKeyState, useButtonPressed, %gameplay_useButton%
		if (useButtonPressed == "D")
		continue
	}
}

return  ; End of auto-execute section.

; The subroutines below do not use KeyWait because that would sometimes trap the
; WatchJoystick quasi-thread beneath the wait-for-button-up thread, which would
; effectively prevent mouse-dragging with the joystick.
SetControlMode_Generic:
	ControlMode = 0
	return

SetControlMode_Gameplay:
	ControlMode = 1
	return

SetControlMode_WandSwap:
	ControlMode = 2
	return

SetControlMode_WandEdit:
	ControlMode = 3
	return
	
PressUseButton:
	if (ControlMode == 1 || ControlMode == 2)
		Send {NumpadAdd}
	return

ShifterCrossTopPressed:
	if (ControlMode == 2)
		Send 1
	return

ShifterCrossLeftPressed:
	if (ControlMode == 2)
		Send 2
	return

ShifterCrossRightPressed:
	if (ControlMode == 2)
		Send 3
	return

ShifterCrossBottomPressed:
	if (ControlMode == 2)
		Send 4
	return

ATan2(x,y) ; returns angle in degrees
{
	pi := 3.141592
	atanResult := ATan(y/x) * (180.0/pi)
	if (x < 0)
		atanResult += 180.0
	else if (y < 0)
		atanResult += 270.0
	
	return atanResult
}

MouseWheel:
GetKeyState, JoyPOV, %JoystickNumber%JoyPOV
if JoyPOV = -1  ; No angle.
	return
if (JoyPOV > 31500 or JoyPOV < 4500)  ; Forward
	Send {WheelUp}
else if JoyPOV between 13500 and 22500  ; Back
	Send {WheelDown}
return
