Const PD_LightSystemVersion = 5.5

'==========================================================
'Light Control (Featuring the PD V5.5 Fading Light System)
'==========================================================
'
'----------------
'Revision History
'----------------
'
'
'V5.5
'- Added the 'CheckLight' function to the system.  This function allows you to easily check a given light's on or
'  off state in the array.  (e.g. If CheckLight(12) Then ...) would return a "1" if the light is on and a "0"
'  if it is off.  
'- Added the 'PopBFR' / 'RingFR' (Pop Bumper Fading Reel) handler to the system.  This handles an 8 frame pop bumper
'  reel that shows two ring states with 4 fading light states for each ring state (i.e. 4 fading light states with 
'  the ring up and 4 indentical fading light states with the ring down).
'
'V5.4
'- Added 'RadeWm' , 'RadeW', 'MRadeW' and "RLitW2" handlers (Reverse Fade Wall Handlers)
'  These are good for when you don't want any drop walls on the table when GI lights are on or something like that
'  An example would be the slingshot an because of overlapping drop walls.  With RadeW, the 
'  non-drop wall base light is ON instead of OFF (with FadeW) so all drop walls are dropped with lights on and thus
'  there is no conflict with the slingshot animation when the lights are on (which is more often than off).
'  In the case of MRadeW, only the secondary (typically GI) is reveresed so that all walls are down when at rest.
'  RLitW2 is a 2-state only wall handler for permanant non-fading reverse wall lights.
'
'V5.3
'- Increased Light Array Length to 200 (as it seems some systems like Taito use very high lamp numbers)
'
'V5.2
'- Added separate controls to assign and separately disable 3 sets of lights using "Fading", "FadingF" and "FadingG"
'  as the control variables and the sub-commands "SetLight", "SetLightF" and "SetLightG" to assign lights manually.
'  These are primarily meant to allow one to offer options to disable Lights, Flashers and GI Lights separately from
'  each other.
'- Added new "Overlapping Lights" handlers.  These are meant to deal with situations where more than one controlled
'  light is using the same lens or plastic cover as another light (such as a flasher bulb and a regular bulb sharing
'  the same light fixture in a VPM recreated table).  These automatically prioritize the first set of two sets of
'  given lights.  Using the separate control variables mentioned above, one can have one set fade and one not even.
'
'V5.1
'- Initial Version of this file.  
'
'V5.0(a-g)
'- First versions of this developing light system
'Versions prior to 5.0 were
'
'- All prior versions of the PD Fading Light system were not fully integrated (VBS call capable) 
'  distributed systems, but more loosely organized and/or included with various released tables.
'
'----------------------------
'Description and Instructions
'----------------------------
'
'       See the tutorial table (should be available at http://www.shivasite.com ) to see examples of how all the
'       lights work plus handy reference sheets and more.
'
'Note: The "UpdateLights()" Sub is the only USER defined part of the system
'      (other than the timer interval and fade variable)
'      The rest appends to the end of the script (or could be adapted to the VBS core)
'
'
'     
'How To Use:
'
'     -You will need to create a Timer on the table called either "LightControl" (for VPinmame tables) or
'      "LightControlO" (for original type tables).  45 is a good interval setting to start at.  You can either
'      change it directly on the timer or include a line in the script like:
'   
'      LightControl.Interval = 45
'                OR
'      LightControlO.Interval = 45
'
'      The interval controls the fading speed and how fast the lights are updated. "UseLights" should be turned off
'      in the script in VPM tables (referring to the regular VBS light system, if you're using it).  
'
'
'      Copy the CORE code marked below over to the table script OR set the table to load the
'      PD_LightSystem.vbs file (which must be in the same directory as the table)
'      using this sub-routine (adjust the 5.3 version in the future to whatever version of the system you're using) and
'      the call shown: 
'
'LoadPDLightSys "PD_LightSystem.vbs" , 5.3
'
'Sub LoadPDLightSys(VBSfile,VBSver)
'	On Error Resume Next
'	ExecuteGlobal GetTextFile(VBSfile)
'	If Err or PD_LightSystemVersion < VBSver Then MsgBox "Unable to open PD_LightSystem.vbs version " & VBSver & ". Ensure that it is in the same folder as this table and is the version indicated. " & vbNewLine & "Table Error:" & vbNewLine & Err.Description
'End Sub
'
'     - You use a handler call defined below in the core area to call your lights (e.g. "FadeL" for fading lights or
'       "aFadeL" for auto-label fading lights) and follow its format in the "UpdateLights" sub.  
'       Note that the auto-labeling calls shorten the amount of typing you'll need to do in the update sub
'       so that you simply type "aFadeL 11, Light11" to fade the Light11 set of light objects whereas using
'       the regular "FadeL" call will need: "FadeL 11, Light11a, Light11b, Light11, Light11off" to function.
'       The primary reason you would want to choose to NOT use auto-labeling is that it slows the light handling down
'       quite a bit.  Light handling is faster than standard VBS lights normally (with or without fade), but using 
'       auto-labeling slows it down well below standard light handling speeds.  Convenience comes at a price due to the
'       real-time processing needed to generate the extra object names automatically.  These "a" calls only apply to 
'       fading light and wall handlers.  The reel and 2-state handlers already only require 2 arguments per call.
'
'       The basic light format:
'
'        See the handler inputs for each system, but in general, you use the handler name, followed by a space, then
'        the light number from the pinball system in question, followed by another comma.  Next it's either the "ON"
'        state for the auto-label handlers, reel handlers and 2-state non-fading handlers 
'        *OR* "a,b,on,off" (for lights) OR "a,b,on" (for walls).
'  
'        Regardless of whether you use the auto-labeling or not, you'll need to have the objects in question on the table.
'        Auto-labeling only generates the long-form internally for you; it doesn't remove the need for the other objects.
'
'        Thus, regardless of whether you type "aFadeL 11,Light11" or "FadeL 11,Light11a,Light11b,Light11,Light11off" you'll
'        still need Light11, Light11a, Light11b and Light11off on the table
'        (where Light11off is the OFF color, Light11 is the ON color, Light11a is the dim color and Light11b is a step 
'         brighter than a but below the ON level).  
'         
'         Likewise for walls, the playfield is the OFF color and you'll need to
'         create additional playfields that are lit at varying levels to generate mapped walls for Light11, Light11a and 
'         Light11b (there is not light11off for walls as the playfield is the off state).  
'     
'         Reels contain the states in frames and should be generated in the following order: Off/On/DimA/DimB
'         Reel calls will work with only 2 frames as well as 4 frames. Just make sure your reels are set up propery.
' 
'         Non-Fade Handlers are to have permanant non-fading lights on the table (e.g. pop bumpers, led lights, etc.)
' 

'        Again, the primary object "ObjectName" (e.g. LightName) is the "FULL ON" state of the light or wall (or reel name).
'        Level A is the dimmest level of ON.  
'        Level B is the next brightest Level above A, but below the FULL ON state.         
'        Off (light objects only) is the light that defines the color for the "OFF" condition
'
'    - Thus if you wanted light 11 to fade using light objects in VP you would need to create 
'      Light11, Light11a, Light11b and Light11off in the table and set their colors to appropriate levels.
'      In the "UpdateLights()" sub, you'd call it with:
'      aFadeL 11, Light11   <= for auto-handling
'             or
'      FadeL 11, Light11a,Light11b,Light11,Light11off    <= for normal (fast) handling 
'
'    - Likewise, wall lights in VP would need walls for Light11, Light11a and Light11b (using 3 playfields
'      with appropriate lighting plus the regular playfield as the "OFF" state). 
'      [aFadeW, Light11] versus [FadeW, Light11a,Light11b,Light11] (minus the brackets)
'
'    - Reels would need 4 frames using the folowing sequential order (OFF, ON, Dim, Semi-Bright). [FadeR 11, Light11]
'
'    - There are handlers for 2-state lights and on/off only lights (such as pop bumpers or typical VP lights) as well.  
'    - Note also that more handlers for more situations could easily be created and added as more sub calls
'
'    - The 'Fading' variable controls whether lights will fade or just turn on and off.  You can call it from an option
'      menu or just use it in the script.  Note that with fading off it still uses the brighter "off" states for all lights.
'    - The Sub Call "AllLightsOff" will cause all lights to turn off momentarily.  It can be combined with disabling the
'      timer in the script (e.g. as a menu option) to turn off all lights until reeanbled.
'
'    Note that if you use "multiple lights" for one light number in a fade handler, you will need to use the
'    speical "m" version for all the calls except the last one in the series which should use the regular call to terminate
'    it. Otherwise, the lights won't operate correctly. This applies across object types.
'    For example, to call 4 lights using 3 different handlers here for light 11, it would look like this:
'        aFadeLm 11, Light11
'        aFadeLm 11, AltLight11
'        aFadeWm 11, WallLight11
'        FadeR  11, ReelLight11
'    Note that FadeR does not have the "m" in it as it's the last call in the series.  Again, if you only have one
'    light per light number, you don't need the the "m" calls.  The "m" calls are in both auto-label and normal calls.
'
'    To handle GI Lights or Flashers, you'll need to assign values to some unused positions in the lightnum array.
'    Included in the system is a sub call to make this very simple.  It's called "SetLight" and uses the format 
'    of "SetLight (light_number),(value)".
'
'    For example:  If you have have the SolCallBack below, you would assign it as follows:
'    (Note: that 100 is assumed to be an unused value; you would assign a different number above the normal light limit 
'     for that system.  Anything above 88 would be ok for Williams WCS system, for example.  It would have to be above
'     128 for Capcom, etc.  There are currently 150 spots in the array to choose from).
'     The solenoid number 28 is arbitrary (depends on system's flasher solenoid values)
'
'(Simple One Step Method)
'
'SolCallBack(28) = "SetLight 100,"
'
'    OR
'
'(Longform Method)
'
'SolCallBack(28) = "FlashX"
'
'Sub FlashX(enabled)
'	SetLight 100, enabled
'End Sub
'
'You would then use a handler such as FadeL for light number 100 as normal in the UpdateLights sub, depending
'on the type of light object used.  Here we assume regular lights faded with the FadeL call:
'(e.g.)
'
'FadeL 100, FlasherXa, FlasherXb, FlasherX, FlasherXoff
'
'GI lights using the system should be assigned and handled the same way.
'
'ORIGINAL TABLE ADDED NOTES:
'
'Note that on an original table you would use 1 for ON (or "true" or "lighton") and 0 for OFF (or "false" or "lightoff")
'instead of "enabled" to assign lamp values.  Remember, original tables use the "LightControlO" timer (O at the end),
'not the "LightControl" timer (no "O" and the end).
'
'IMPORTANT:
'----------
'If you want to use VP's Light Sequencer with an original table and still have fading lights in it, you will need to use
'the "SetLight" command provided here to assign the value of a control light to the array.  This means creating a set
'of lights that you will control directly in your script (as if they were regular lights), setting up the light sequencer
'and assigning those lights to the control array.  This should be done in the UpdateLights array prior to calling any
'fading light handlers (so the values are updated first).  The control lights should go below the lockbar area of the
'table so as not to be visible.  They should be regular light objects, regardless if the ones on the table are walls or
'reels.  I suggest labeling them with a "z" at the end.  
'
'Example:
'If you had Light10a,Light10b,Light10 and Light10off on the table as a fading light set, you would set the control 
'light below the lockbar area and label it Light10z.  To control that light, you just change it like a normal VP light
'(e.g. Light10z.state = 1 or Light10z.state = 0) (or use true / fase OR lighton / lightoff instead of 1 and 0).  
'In the UpdateLights sub, you would then do this (for a set of regular lights):
'
'Sub UpdateLights()
'SetLight 10, Light10z.state
'FadeL 10, Light10a,Light10b,Light10,Light10off
'End Sub
'
'Note that an example of this is techniuqe is also shown the LightTutorial table.
'

'------------------
'UPDATE LIGHTS Sub
'------------------
'This is the primary Sub you set up in the table to handle the lights.
 
'Sub UpdateLights()
'Light Control (Sub Calls to Fade Various Light Handler Sets defined below)
'(e.g.) 
'On Error Resume Next  ' Force lights to process even if there are labeling errors, etc.
rem aFadeL 11,Light11  '(Light)
rem aFadeW 12,Wall12   '(Wall)
rem FadeR 13,Reel13    '(Reel)
'etc.
'End Sub

'-------------------------------------------------------------------------------------------
'Core Found Below - Call the VBS file as indicated above; otherwise append to end of script
'-------------------------------------------------------------------------------------------


'===========================
'Core Light System (PD v5.5)
'===========================

'-------------------------------
'System Fading Control Variables
'-------------------------------
'
'These variables tell whether various fading handlers should process fades or non-fades.  Thus, they disable
'fading of lights.  

' - Variable "Fading" controls whether lights fade or not (can use from options menu or change in script)
'   This controls the automated VPM lights and the lights set manually with "SetLight".
Dim Fading    : Fading = True

' - Variable "FadingF" controls whether lights fade or not that are manually set with "SetLightF".  
'   This is meant to be used to allow separate fading control for flashers

Dim FadingF	  : FadingF = True

' - Variable "FadingG" controls whether lights fade or not that are manually set with "SetLightG".  
'   This is meant to be used to allow separate fading control for GI Lights.

Dim FadingG	  : FadingG = True


'System defines variables and assigns the changed light values to them, which is then turned over to Fader Control
Dim lightnum(201) : Dim Tset
'Initialize all possible light control variables (0 - 200) including extra spaces for flashers or GI control
On Error Resume Next
	For Tset = 0 To 200
		lightnum(Tset) = 0
	Next

'Assign All Lamp Functions to Variable Control List

'Note This Sub is for VPM tables and assigns lamp values automatically.  Originals should use the one marked
'     below instead.  Therefore only create the timer you need (either LightControl or LightControlO)
'
Sub LightControl_Timer()
	Dim ChgLamp, pointer, index, str, T
	  ChgLamp = Controller.ChangedLamps
	On Error Resume Next
 If Not IsEmpty(ChgLamp) Then
	If Fading = True Then 
		For T = 0 To UBound(ChgLamp)
			pointer = chgLamp(T, 0)
			index   = chgLamp(T, 1)
			lightnum(pointer) = index + 4
		Next
	Else
		For T = 0 To UBound(ChgLamp)
			pointer = chgLamp(T, 0)
			index   = chgLamp(T, 1)
			lightnum(pointer) = index
		Next
	End If
 End If
    UpdateLights
End Sub

'Note: This timer is for original tables.  Light states are assigned using the "SetLight" sub marked below this one.
'      It is also used to assign flasher or GI lights to unused light numbers and thus added to the fade system.

 Sub LightControlO_Timer()
	UpdateLights
 End Sub

'---------------------------
' Light Assignment Control 
'---------------------------
' - These calls allow easy assignments of values to the light array, useful for assigning Flashers or GI Lights or when
'   using the system with original tables to assign lamp states into the control array.  Fading or non-fading calls 
'   are then applied as normal in the UpdateLights sub.
' - There are 3 sets of calls, each with a different control variable.  This is mainly designed to allow a table
'   author to have separate "Disable Fading" options for Lights, Flashers and GI Lights.

'These "LightOn" and "LightOff" aliases can be used with the SetLight commands instead of true and false (or 1 & 0).
dim LightOn, LightOff : LightOn = 1 : LightOff = 0  ' Define aliases for on & off

'SetLight
'--------
'
'Manually set lights in original tables or set extra lights in VPM tables such as flashers or GI lights.
'The variable "Fading" controls whether these lights will fade or not.
Sub SetLight(lightnumber, value)
	If Fading = true then
		lightnum(lightnumber) = abs(value) + 4
	Else
		lightnum(lightnumber) = abs(value)
	End If
End Sub

'SetLightF
'---------
'
'Manually set lights in original tables or set extra lights in VPM tables such as flashers or GI lights.
'The variable "Fading" controls whether these lights will fade or not.
Sub SetLightF(lightnumber, value)
	If FadingF = true then
		lightnum(lightnumber) = abs(value) + 4
	Else
		lightnum(lightnumber) = abs(value)
	End If
End Sub

'SetLightG
'---------
'
'Manually set lights in original tables or set extra lights in VPM tables such as flashers or GI lights.
'The variable "Fading" controls whether these lights will fade or not.
Sub SetLightG(lightnumber, value)
	If FadingG = true then
		lightnum(lightnumber) = abs(value) + 4
	Else
		lightnum(lightnumber) = abs(value)
	End If
End Sub

'CheckLight
'----------
'
'This will check a light matrix state and report back whether it's ON or if it's OFF (off includes fading out)
'via a 1 or 0, which can then be used in comparison and/or/nand/nor/xor type statements

Function CheckLight(lightnumber)
	dim value
	If lightnum(lightnumber) = 9 or lightnum(lightnumber) = 7 or lightnum(lightnumber) = 5 or lightnum(lightnumber) = 1 Then
		value = 1
	Else
		value = 0
	End If
	CheckLight = value
	Exit Function
End Function


'*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
'Light Handler Code With Fade Control V5.3 by PD'
'*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
'
'These are the subroutine "Plugin" handlers for the UpdateLights sub.  They handle various types of lights and lighting
'conditions.  They are called from the "UpdateLights" sub-routine.  You should use the ones that match the type of light
'and lighting condition you are using.  More plugins can be added by a knowledgable user or for future updates.


'**********************
'Single Light Handlers
'**********************
'
'This set of handlers is for single (i.e. non-overlapping) lights.  There are handlers for Lights, Walls and Reels.
'Note the special handlers for when you have multiple lights for one control light value.

'----------------------------------------------------
'Adjustable Fading / Non-Fading Single Light Handlers
'----------------------------------------------------
'Set Fading = True for Fading (4-stage) operation or set Fading = False for Non-Fading (2-stage) operation.

'FadeLm
'------
'Fades Light Object based Lights When Multiple Lights are controlled by the Same Variable
'NOTE: The last light controlled by that variable must be called with the regular Sub handler 
'Example call: "FadeLm 1, light1a,light1b,light1,light1off"
Sub FadeLm(lightnumIn, stage1, stage2, stage3, off)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest ; off state is brighter off color 
	Select Case lightnum(lightnumIn)
		Case  5 : stage1.state = 0 : stage2.state = 0 : stage3.state = 0 : stage3.state = 1
		Case  4 : stage3.state = 0 : stage2.state = 0 : stage2.state = 1 
		Case  3 : stage2.state = 0 : stage1.state = 0 : stage1.state = 1 
		Case  2 : stage1.state = 0 : off.state = 0 : off.state = 1 
		Case  1 : off.state    = 0 : stage3.state = 1 
		Case  0 : stage3.state = 0 : off.state = 1 
	End Select
End Sub

'FadeL
'-----
'Fades Light Object based Lights 
'Example call: "FadeL 1, light1a,light1b,light1,light1off"
Sub FadeL(lightnumIn, stage1, stage2, stage3, off)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest ; off state is brighter off color
	Select Case lightnum(lightnumIn)
		Case  5 : stage1.state = 0 : stage2.state = 0 : stage3.state = 0 : stage3.state = 1 : lightnum(lightnumIn) = 7
		Case  4 : stage3.state = 0 : stage2.state = 0 : stage2.state = 1 : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  3 : stage2.state = 0 : stage1.state = 0 : stage1.state = 1 : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  2 : stage1.state = 0 : off.state = 0 : off.state = 1 : lightnum(lightnumIn) = 6
		Case  1 : off.state    = 0 : stage3.state = 1 : lightnum(lightnumIn) = 7
		Case  0 : stage3.state = 0 : off.state = 1 : lightnum(lightnumIn) = 6
	End Select
End Sub

'FadeWm
'------
'Fades Wall Based Lights When Multiple Lights are controlled by the Same Variable
'NOTE: The last light controlled by that variable must be called with the regular Sub handler 
'Example call: "FadeWm 1, light1a,light1b,light1"
'
'Note: the "off" condition should be provided by a non-dropping wall and the other stages should be set with their
'      top height just above that wall and their bottom height just below it and the wall set to drop.

Sub FadeWm(lightnumIn, stage1, stage2, stage3)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest
	Select Case lightnum(lightnumIn)
		Case  5 : stage1.IsDropped = True : stage2.IsDropped = True : stage3.IsDropped = False 
		Case  4 : stage3.IsDropped = True : stage2.IsDropped = False 
		Case  3 : stage2.IsDropped = True : stage1.IsDropped = False 
		Case  2 : stage1.IsDropped = True
		Case  1 : stage1.IsDropped = True : stage2.IsDropped = True : stage3.IsDropped = False
		Case  0 : stage1.IsDropped = True : stage2.IsDropped = True : stage3.IsDropped = True
	End Select
End Sub

'FadeW
'-----
'Fades Wall Based Lights
'Example call: "FadeW 1, light1a,light1b,light1"
'
'Note: the "off" condition should be provided by a non-dropping wall and the other stages should be set with their
'      top height just above that wall and their bottom height just below it and the wall set to drop.

Sub FadeW(lightnumIn, stage1, stage2, stage3)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest
	Select Case lightnum(lightnumIn)
		Case  5 : stage1.IsDropped = True : stage2.IsDropped = True : stage3.IsDropped = False : lightnum(lightnumIn) = 7
		Case  4 : stage3.IsDropped = True : stage2.IsDropped = False : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  3 : stage2.IsDropped = True : stage1.IsDropped = False : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  2 : stage1.IsDropped = True : lightnum(lightnumIn) = 6
		Case  1 : stage1.IsDropped = True : stage2.IsDropped = True : stage3.IsDropped = False : lightnum(lightnumIn) = 7
		Case  0 : stage1.IsDropped = True : stage2.IsDropped = True : stage3.IsDropped = True  : lightnum(lightnumIn) = 6
	End Select
End Sub


'RadeWm
'-----
'Reverse Fades Wall Based Lights When Multiple Lights are Controlled By The Same Variable
'NOTE: The last light controlled by that variable must be called with the regular Sub handler 
'
' -This is mostly useful to avoid having drop walls present when GI is on so slingshot animations appear, etc.
'  It essentially has an ON state as default mapping and shifts drop walls to fade to dark instead of dropping to bright
'
'Example call: "RadeWm 1, light1a,light1b,light1off"
'
'Note: the "off" condition (from previous FadeW call) here is really an "on" condition and
'      should be provided by a non-dropping wall and the other stages should be set with their
'      top height just above that wall and their bottom height just below it and the wall set to drop.

Sub RadeWm(lightnumIn, stage1, stage2, off)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; off is bulb off
	Select Case lightnum(lightnumIn)
		Case  5 : stage1.IsDropped = True : stage2.IsDropped = True : off.IsDropped = True 
		Case  4 : off.IsDropped    = True : stage2.IsDropped = False 
		Case  3 : stage2.IsDropped = True : stage1.IsDropped = False 
		Case  2 : stage1.IsDropped = True : off.IsDropped    = False 
		Case  1 : stage1.IsDropped = True : stage2.IsDropped = True : off.IsDropped = True   
		Case  0 : stage1.IsDropped = True : stage2.IsDropped = True : off.IsDropped = False  
	End Select
End Sub

'RadeW
'-----
'Reverse Fades Wall Based Lights 
' -This is mostly useful to avoid having drop walls present when GI is on so slingshot animations appear, etc.
'  It essentially has an ON state as default mapping and shifts drop walls to fade to dark instead of dropping to bright
'
'Example call: "RadeW 1, light1a,light1b,light1off"
'
'Note: the "off" condition (from previous FadeW call) here is really an "on" condition and
'      should be provided by a non-dropping wall and the other stages should be set with their
'      top height just above that wall and their bottom height just below it and the wall set to drop.

Sub RadeW(lightnumIn, stage1, stage2, off)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; off is bulb off
	Select Case lightnum(lightnumIn)
		Case  5 : stage1.IsDropped = True : stage2.IsDropped = True  : off.IsDropped = True : lightnum(lightnumIn) = 7
		Case  4 : off.IsDropped    = True : stage2.IsDropped = False : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  3 : stage2.IsDropped = True : stage1.IsDropped = False : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  2 : stage1.IsDropped = True : off.IsDropped    = False : lightnum(lightnumIn) = 6
		Case  1 : stage1.IsDropped = True : stage2.IsDropped = True  : off.IsDropped = True   : lightnum(lightnumIn) = 7
		Case  0 : stage1.IsDropped = True : stage2.IsDropped = True  : off.IsDropped = False  : lightnum(lightnumIn) = 6
	End Select
End Sub


'FadeRm
'------
'Fades Reel Based Lights When Multiple Lights are controlled by the Same Variable
'NOTE: The last light controlled by that variable must be called with the regular Sub handler 
'Example call: "FadeRm 1, light1"
'
'Reels should be contructed so that the frames within them are in the following order: off,bright,dim,medium
'Reels will fade if they contain and are set for 4 frames and will act as 2-state lights if they are set for 2 frames.
'They will also act as 2-state with the "fading" variable set to off.

Sub FadeRm(lightnumIn, reelname)
	'Note that reel construction order must be off, bright, stage1, stage2
	Select Case lightnum(lightnumIn)
		Case  5 : reelname.setvalue 1 
		Case  4 : reelname.setvalue 3  
		Case  3 : reelname.setvalue 2  
		Case  2 : reelname.setvalue 0 
		Case  1 : reelname.setvalue 1
		Case  0 : reelname.setvalue 0
	End Select
End Sub

'FadeR
'-----
'Fades Reel Based Lights
'Example call: "FadeR 1, light1"
'
'Reels should be contructed so that the frames within them are in the following order: off,bright,dim,medium
'Reels will fade if they contain and are set for 4 frames and will act as 2-state lights if they are set for 2 frames.
'They will also act as 2-state with the "fading" variable set to off.

Sub FadeR(lightnumIn, reelname)
	'Note that reel construction order must be off, bright, stage1, stage2
	Select Case lightnum(lightnumIn)
		Case  5 : reelname.setvalue 1 : lightnum(lightnumIn) = 7
		Case  4 : reelname.setvalue 3 : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  3 : reelname.setvalue 2 : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  2 : reelname.setvalue 0 : lightnum(lightnumIn) = 6
		Case  1 : reelname.setvalue 1 : lightnum(lightnumIn) = 7
		Case  0 : reelname.setvalue 0 : lightnum(lightnumIn) = 6
	End Select
End Sub

'PopBFR & RingFR
'---------------
'Handles Basic Pop Bumper Reel Based Lights With Moving Ring
'Example call: "PopBFR 114,RingState, Pop1"
'            : "RingFR 114,RingState, Pop1"
'
'Reels should be contructed so that the frames within them are in the following order:
' off,off_ring,bright,bright_ring,dim,dim_ring,medium,medium_ring
'Ringstate should be tied to the solenoid controlling whether the pop bumper is being fired or not
'
'PopBFR should appear in the UpdateLights set of calls while RingFR should appear in the solenoid callback for
'firing the ring.  Both should be used together in the same table to function correctly.
'
'An example VPM solenoid call might appear like this (where 114 is the light number for the jet bumper reel "L114"):
'-----------------------------------------------------------------------------------------
' SolCallback(10)		= "LeftJet"  			    		        ' Left Jet Bumper
' dim LRing,RRing : LRing = False : RRing = False
' Sub LeftJet(enabled)
'	If enabled Then
'		LRing = True
'		Playsound SfxJet
'		RingFR 114,LRing,L114 
'		vpmtimer.addTimer 100,"ResetLRing"
'	End If		
' End Sub
'
'Sub ResetLRing(aSw): LRing = False : RingFR 114,LRing,L114 : End Sub
'-----------------------------------------------------------------------------------------
'PopBFR 114, LRing, L114  ' <= This would go in the Update Lights Sub
'-----------------------------------------------------------------------------------------
'
'
'
'Reels will fade if they contain and are set for 8 frames and will act as 2-state lights if they are set for 4 frames.
'They will also act as 2-state with the "fading" variable set to off.

Sub PopBFR(lightnumIn, ringstate, reelname)
	If ringstate = True Then
	 Select Case lightnum(lightnumIn)
		Case  5 : reelname.setvalue 3 : lightnum(lightnumIn) = 9
		Case  4 : reelname.setvalue 7 : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  3 : reelname.setvalue 5 : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  2 : reelname.setvalue 1 : lightnum(lightnumIn) = 8
		Case  1 : reelname.setvalue 3 : lightnum(lightnumIn) = 7
		Case  0 : reelname.setvalue 1 : lightnum(lightnumIn) = 6
	 End Select
	Else
	 Select Case lightnum(lightnumIn)
		Case  5 : reelname.setvalue 2 : lightnum(lightnumIn) = 9
		Case  4 : reelname.setvalue 6 : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  3 : reelname.setvalue 4 : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  2 : reelname.setvalue 0 : lightnum(lightnumIn) = 8
		Case  1 : reelname.setvalue 2 : lightnum(lightnumIn) = 7
		Case  0 : reelname.setvalue 0 : lightnum(lightnumIn) = 6
	 End Select
	End If	
End Sub

Sub RingFR(lightnumIn, ringstate, reelname)
	If ringstate = True Then
 	 Select Case lightnum(lightnumIn)
		Case  9 : reelname.setvalue 3 
		Case  8 : reelname.setvalue 1 
		Case  7 : reelname.setvalue 3 
		Case  6 : reelname.setvalue 1
		Case  5 : reelname.setvalue 3 
		Case  4 : reelname.setvalue 7 
		Case  3 : reelname.setvalue 5 
		Case  2 : reelname.setvalue 1 
		Case  1 : reelname.setvalue 3 
		Case  0 : reelname.setvalue 1
	 End Select
	Else
 	 Select Case lightnum(lightnumIn)
		Case  9 : reelname.setvalue 2 
		Case  8 : reelname.setvalue 0 
		Case  7 : reelname.setvalue 2 
		Case  6 : reelname.setvalue 0
		Case  5 : reelname.setvalue 2 
		Case  4 : reelname.setvalue 6 
		Case  3 : reelname.setvalue 4 
		Case  2 : reelname.setvalue 0 
		Case  1 : reelname.setvalue 2 
		Case  0 : reelname.setvalue 0
	 End Select
	End If
End Sub



'------------------------------------------
'Permanant Non-Fading Single Light Handlers
'------------------------------------------
'
'These lights will not fade regardless of the status of the "Fading" variable.

'NFade
'-----
'Handles regular on/off lights or objects like Pop Bumpers or single lights (e.g.light1)
'Example call: "NFade 1, light1"
Sub NFade(lightnumIn,light)
	Select Case lightnum(lightnumIn)
		Case 5: light.state = 1
		Case 4: light.state = 0
		Case 1: light.state = 1
		Case 0: light.state = 0
	End Select
End Sub

'LitL2
'-----
'Handles permanant 2-state lights (uses 2-lamps, one for on and one for off) (e.g. light1 and light1off)
'Example call: "LitL2 1, light1, light1off"
Sub LitL2(lightnumIn, light, lightoff) 
	Select Case lightnum(lightnumIn)
		Case 5: lightoff.state = 0 : light.state    = 1
		Case 4: light.state    = 0 : lightoff.state = 1
		Case 1: lightoff.state = 0 : light.state    = 1
		Case 0: light.state    = 0 : lightoff.state = 1
	End Select
End Sub

'LitW2
'-----
'Handles 2-state (on/off only) Wall Based Lights
'Example call: "LitW2 1, light1"
'
'Note the off condition should be provided by including a non-dropping wall.  Stage3 should have its top height
'just above that wall and its bottom height just below it and the wall set to drop.
Sub LitW2(lightnumIn, stage3)
	Select Case lightnum(lightnumIn)
		Case 5: stage3.IsDropped = 0
		Case 4: stage3.IsDropped = 1
		Case 1: stage3.IsDropped = 0
		Case 0: stage3.IsDropped = 1
	End Select
End Sub

'RLitW2
'-----
'Handles 2-state (on/off only) Reversed Action Wall Based Lights
' - It's reverse action in that it is assumed the stationary wall (or playfield) is default ON instead of OFF
'   and the drop wall is then the OFF state.  This allows there to be no drop walls raised when lights are on,
'   which is useful for GI lights being on that might otherwise interefere with things like slingshot animation
'   due to there being overlapping drop walls on the playfield.  Since GI is usually ON, this prevents that condition
'   more often than not.  It's similar to the Fading "RadeW" handler.
'
'Example call: "RLitW2 1, light1off"
'
'Note the off condition should be provided by including a non-dropping wall.  Stage3 should have its top height
'just above that wall and its bottom height just below it and the wall set to drop.
Sub RLitW2(lightnumIn, off)
	Select Case lightnum(lightnumIn)
		Case 5: off.IsDropped = 1
		Case 4: off.IsDropped = 0
		Case 1: off.IsDropped = 1
		Case 0: off.IsDropped = 0
	End Select
End Sub


'**************************
'Overlapping Light Handlers
'**************************
'
'Note: These handlers are for overlapping lights (i.e. when two lights occupy the same cover (plastic or lens)
'      or when you have a light that should both flash an act as a GI light with varying brightness levels controlled
'      by two different control variables (such as a solenoid in a VPM table).
'      A good example would be a "light lens" on a table that contains both a flasher bulb and a regular (or GI) bulb.
'
'	There are currently no auto-label handlers for these calls since some may require changes to achieve different
'	effects.  For example, to combine a fading flasher with a non-fading GI Light using the MFadeL handler, you 
'   should make L2Stage1 and L2Stage2 the same as the shared off light value.  This will instantly darken that light
'   instead of fading it. The same can be applied to L1Stage1 and L1Stage2 for the reverse effect 
'   (i.e. a non-fading flasher, but fading GI) or both can be set that way to get overlapping non-fading lights.



'MFadeL
'------    
'Fades Multiple Overlapping Light Objects With Preferential Bias To One Light (e.g. Flashers over regular lights)
'The first set given is the preferred (i.e. brighter) set.
'Example call: "MFadeL 100, flasher2a, Flasher2b,Flasher2, 1, light1a,light1b,light1, light1off"
'               -Flasher set 2 controlled by 100 will show changes before light1 set controlled by 1
'Note that both sets will share a SINGLE common off color (create one light for both sets' off state).
'Notice the off state is the last argument (there is no off state listed for both sets as they share one off light)
'Care should be taken when selecting the colors for both sets
'
Sub MFadeL(lightnumIn1, L1stage1, L1stage2, L1stage3, lightnumIn2, L2stage1, L2stage2, L2stage3, off)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest ; off state is brighter off color
  If lightnum(lightnumIn1) = 6 or lightnum(lightnumIn1) = 0 Then 
	'Secondary Light Set only when primary set is OFF (case 6)
	Select Case lightnum(lightnumIn2)
		Case  5 : L2stage1.state = 0 : L2stage2.state = 0 : L2stage3.state = 0 : L2stage3.state = 1 : lightnum(lightnumIn2) = 7
		Case  4 : L2stage3.state = 0 : L2stage2.state = 0 : L2stage2.state = 1 : lightnum(lightnumIn2) = lightnum(lightnumIn2) - 1
		Case  3 : L2stage2.state = 0 : L2stage1.state = 0 : L2stage1.state = 1 : lightnum(lightnumIn2) = lightnum(lightnumIn2) - 1
		Case  2 : L2stage1.state = 0 : off.state = 0      : off.state = 1      : lightnum(lightnumIn2) = 6
		Case  1 : off.state      = 0 : L2stage3.state = 0 : L2stage3.state = 1 : lightnum(lightnumIn2) = -1
		Case  0 : L2stage3.state = 0 : off.state = 0 : off.state = 1 : lightnum(lightnumIn2) = -2
	End Select
   Else
		'Primary Set Otherwise
	Select Case lightnum(lightnumIn1)
		Case  5 : L1stage1.state = 0 : L1stage2.state = 0 : L1stage3.state = 0 : L1stage3.state = 1 : lightnum(lightnumIn1) = 7
		Case  4 : L1stage3.state = 0 : L1stage2.state = 0 : L1stage2.state = 1 : lightnum(lightnumIn1) = lightnum(lightnumIn1) - 1
		Case  3 : L1stage2.state = 0 : L1stage1.state = 0 : L1stage1.state = 1 : lightnum(lightnumIn1) = 6
		Case  2 : 'do nothing
		Case  1 : off.state      = 0 : L1stage3.state = 0 : L1stage3.state = 1 : lightnum(lightnumIn1) = 7
		Case  0 : 'do nothing
	End Select
	'Set secondary "Resume" states to either light up or stay off with the 1st set depending on their state when 1st set finishes
	Select Case lightnum(lightnumIn2)
		Case  7 : lightnum(lightnumIn2) = 5 ' Light Should Reset On When Primary Is Done So It's On Top
		Case  6 : lightnum(lightnumIn2) = 2 ' Light Off State Should Occur Next if Secondary is Off
		Case  5 : 'keep at 5 (Light On)
		Case  4 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  3 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  2 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  1 : 'keep at 1 (Light On)
		Case  0 : lightnum(lightnumIn2) = 0 ' Light Off (No Fade)
		Case -1 : lightnum(lightnumIn2) = 1 ' Light On  (No Fade)
		Case -2 : lightnum(lightnumIn2) = 0 ' Light Off (No Fade) 
	End Select
  End If
End Sub

'MFadeW
'------
'Fades Multiple Overlapping Wall Objects With Preferential Bias To One Light (e.g. Flashers over regular lights)
'The first set given is the preferred (i.e. brighter) set.
'
'Example call: "MFadeW 100, flasher2a, Flasher2b,Flasher2, 1, light1a,light1b,light1"
'               -Flasher set 2 controlled by 100 will show changes before light1 set controlled by 1
'Note that both sets will need to share a SINGLE common off state and that should be included on the table
'as a non-dropping wall mapped to show an off condition.
'

Sub MFadeW(lightnumIn1, L1stage1, L1stage2, L1stage3, lightnumIn2, L2stage1, L2stage2, L2stage3)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest ; off state is a non-dropping wall you should have present
  If lightnum(lightnumIn1) = 6 or lightnum(lightnumIn1) = 0 Then 
	'Secondary Light Set only when primary set is OFF (case 6)
	L1stage1.IsDropped = True : L1stage2.IsDropped = True : L1stage3.IsDropped = True ' Drop All Primary Stages
	Select Case lightnum(lightnumIn2)
		Case  5 : L2stage1.IsDropped = True : L2stage2.IsDropped = True  : L2stage3.IsDropped = False : lightnum(lightnumIn2) = 7
		Case  4 : L2stage3.IsDropped = True : L2stage2.IsDropped = False : lightnum(lightnumIn2) = lightnum(lightnumIn2) - 1
		Case  3 : L2stage2.IsDropped = True : L2stage1.IsDropped = False : lightnum(lightnumIn2) = lightnum(lightnumIn2) - 1
		Case  2 : L2stage1.IsDropped = True : lightnum(lightnumIn2) = 6
		Case  1 : L2stage1.IsDropped = True : L2stage2.IsDropped = True : L2stage3.IsDropped = False : lightnum(lightnumIn2) = -1
		Case  0 : L2stage1.IsDropped = True : L2stage2.IsDropped = True : L2stage3.IsDropped = True  : lightnum(lightnumIn2) = -2
	End Select
   Else
	'Primary Set Otherwise
	L2stage1.IsDropped = True : L2stage2.IsDropped = True : L2stage3.IsDropped = True ' Drop All Secondary Stages
	Select Case lightnum(lightnumIn1)
		Case  5 : L1stage1.IsDropped = True : L1stage2.IsDropped = True  : L1stage3.IsDropped = False : lightnum(lightnumIn1) = 7
		Case  4 : L1stage3.IsDropped = True : L1stage2.IsDropped = False : lightnum(lightnumIn1) = lightnum(lightnumIn1) - 1
		Case  3 : L1stage2.IsDropped = True : L1stage1.IsDropped = False : lightnum(lightnumIn1) = 6
		Case  2 : 'do nothing
		Case  1 : L1stage1.IsDropped = True : L1stage2.IsDropped = True : L1stage3.IsDropped = False : lightnum(lightnumIn1) = 7
		Case  0 : 'do nothing
	End Select
	'Set secondary "Resume" states to either light up or stay off with the 1st set depending on their state when 1st set finishes
	Select Case lightnum(lightnumIn2)
		Case  7 : lightnum(lightnumIn2) = 5 ' Light Should Reset On When Primary Is Done So It's On Top
		Case  6 : lightnum(lightnumIn2) = 2 ' Light Off State Should Occur Next if Secondary is Off
		Case  5 : 'keep at 5 (Light On)
		Case  4 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  3 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  2 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  1 : 'keep at 1 (Light On)
		Case  0 : lightnum(lightnumIn2) = 0 ' Light Off (No Fade)
		Case -1 : lightnum(lightnumIn2) = 1 ' Light On  (No Fade)
		Case -2 : lightnum(lightnumIn2) = 0 ' Light Off (No Fade) 
	End Select
  End If
End Sub

'MRadeW
'------
'Fades Multiple Overlapping Wall Objects With Preferential Bias To One Light and Reversed on Other (e.g. Flashers over regular lights)
'The first set given is the preferred (i.e. brighter) set. The reversed secondary allows all Drop walls to be dropped, so as to
'not interefere with other drop walls in the area while the system is at rest ON instead of OFF (i.e. GI Lights)
'
'Example call: "MRadeW 100, flasher2a, Flasher2b,Flasher2, 1, light1a,light1b,light1off"
'               -Flasher set 2 controlled by 100 will show changes before light1 set controlled by 1
'Note that both sets will need to share a SINGLE common off state and that should be included on the table
'as a non-dropping wall mapped to show an off condition.
'

Sub MRadeW(lightnumIn1, L1stage1, L1stage2, L1stage3, lightnumIn2, L2stage1, L2stage2, L2stage3)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest ; off state is a non-dropping wall you should have present
  If lightnum(lightnumIn1) = 6 or lightnum(lightnumIn1) = 0 Then 
	'Secondary Light Set only when primary set is OFF (case 6)
	L1stage1.IsDropped = True : L1stage2.IsDropped = True : L1stage3.IsDropped = True ' Drop All Primary Stages
	Select Case lightnum(lightnumIn2)
		Case  5 : L2stage1.IsDropped = True : L2stage2.IsDropped = True  : L2stage3.IsDropped = True : lightnum(lightnumIn2) = 7
		Case  4 : L2stage3.IsDropped = True : L2stage2.IsDropped = False : lightnum(lightnumIn2) = lightnum(lightnumIn2) - 1
		Case  3 : L2stage2.IsDropped = True : L2stage1.IsDropped = False : lightnum(lightnumIn2) = lightnum(lightnumIn2) - 1
		Case  2 : L2stage1.IsDropped = True : L2stage3.IsDropped = False : lightnum(lightnumIn2) = 6
		Case  1 : L2stage1.IsDropped = True : L2stage2.IsDropped = True : L2stage3.IsDropped = True : lightnum(lightnumIn2) = -1
		Case  0 : L2stage1.IsDropped = True : L2stage2.IsDropped = True : L2stage3.IsDropped = False: lightnum(lightnumIn2) = -2
	End Select
   Else
	'Primary Set Otherwise
	L2stage1.IsDropped = True : L2stage2.IsDropped = True : L2stage3.IsDropped = True ' Drop All Secondary Stages
	Select Case lightnum(lightnumIn1)
		Case  5 : L1stage1.IsDropped = True : L1stage2.IsDropped = True  : L1stage3.IsDropped = False : lightnum(lightnumIn1) = 7
		Case  4 : L1stage3.IsDropped = True : L1stage2.IsDropped = False : lightnum(lightnumIn1) = lightnum(lightnumIn1) - 1
		Case  3 : L1stage2.IsDropped = True : L1stage1.IsDropped = False : lightnum(lightnumIn1) = 6
		Case  2 : 'do nothing
		Case  1 : L1stage1.IsDropped = True : L1stage2.IsDropped = True : L1stage3.IsDropped = False : lightnum(lightnumIn1) = 7
		Case  0 : 'do nothing
	End Select
	'Set secondary "Resume" states to either light up or stay off with the 1st set depending on their state when 1st set finishes
	Select Case lightnum(lightnumIn2)
		Case  7 : lightnum(lightnumIn2) = 5 ' Light Should Reset On When Primary Is Done So It's On Top
		Case  6 : lightnum(lightnumIn2) = 2 ' Light Off State Should Occur Next if Secondary is Off
		Case  5 : 'keep at 5 (Light On)
		Case  4 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  3 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  2 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  1 : 'keep at 1 (Light On)
		Case  0 : lightnum(lightnumIn2) = 0 ' Light Off (No Fade)
		Case -1 : lightnum(lightnumIn2) = 1 ' Light On  (No Fade)
		Case -2 : lightnum(lightnumIn2) = 0 ' Light Off (No Fade) 
	End Select
  End If
End Sub


'MFadeR
'------
'Fades Multiple Overlapping Lights Where a REEL object is desired to show both lights.
'Preferential Bias is applied to the first light or "L1" (e.g. Flashers over regular lights)
'Note that only one reel is used to show both lights so all frames should be in that one reel for both lights.
'
'Overlapping Light Reels should be constructed in the following frame order for fading:
'  		 OFF, L1Bright, L2Bright, L1Dim, L1 Medium, L2Dim, L2Medium
' or	 OFF, L1Bright, L2Bright for non-fading.
'
'Example call: "MFadeR 100, 1, DualLightReel"
'               -FlasherReel frames controlled by 100 will show changes before LightReel frames set controlled by 1

Sub MFadeR(lightnumIn1, lightnumIn2, reelname)
  If lightnum(lightnumIn1) = 6 or lightnum(lightnumIn1) = 0 Then 
	'Secondary Light Set only when primary set is OFF (case 6)
	Select Case lightnum(lightnumIn2)
		Case  5 : reelname.setvalue 2 : lightnum(lightnumIn2) = 7
		Case  4 : reelname.setvalue 6 : lightnum(lightnumIn2) = lightnum(lightnumIn2) - 1
		Case  3 : reelname.setvalue 5 : lightnum(lightnumIn2) = lightnum(lightnumIn2) - 1
		Case  2 : reelname.setvalue 0 : lightnum(lightnumIn2) = 6
		Case  1 : reelname.setvalue 2 : lightnum(lightnumIn2) = -1
		Case  0 : reelname.setvalue 0 : lightnum(lightnumIn2) = -2
	End Select
   Else
	'Primary Set Otherwise
	Select Case lightnum(lightnumIn1)
		Case  5 : reelname.setvalue 1 : lightnum(lightnumIn1) = 7
		Case  4 : reelname.setvalue 4 : lightnum(lightnumIn1) = lightnum(lightnumIn1) - 1
		Case  3 : reelname.setvalue 3 : lightnum(lightnumIn1) = 6
		Case  2 : 'do nothing
		Case  1 : reelname.setvalue 1 : lightnum(lightnumIn1) = 7
		Case  0 : 'do nothing
	End Select
	'Set secondary "Resume" states to either light up or stay off with the 1st set depending on their state when 1st set finishes
	Select Case lightnum(lightnumIn2)
		Case  7 : lightnum(lightnumIn2) = 5 ' Light Should Reset On When Primary Is Done So It's On Top
		Case  6 : lightnum(lightnumIn2) = 2 ' Light Off State Should Occur Next if Secondary is Off
		Case  5 : 'keep at 5 (Light On)
		Case  4 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  3 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  2 : lightnum(lightnumIn2) = 2 ' Light Off Next
		Case  1 : 'keep at 1 (Light On)
		Case  0 : lightnum(lightnumIn2) = 0 ' Light Off (No Fade)
		Case -1 : lightnum(lightnumIn2) = 1 ' Light On  (No Fade)
		Case -2 : lightnum(lightnumIn2) = 0 ' Light Off (No Fade) 
	End Select
  End If
End Sub


'********************
'AUTO-LABEL HANDLERS
'********************
'NOTE: These take a big chunk of CPU time to process the labeling in real time, but they allow you to 
' just enter [lightnum,lightOnObject] instead of [lightnum, Lighta, Lightb, LightOn, LightOff] for the Fading
' single light handlers for Light and Wall objects.  Non-Fading and Reel handlers are already short form and therefore
' not included.
'
' Example: aFadeL 11,Light11
'                versus
'           FadeL 11,Light11a,Light11b,Light11,Light11off
'
'These ONLY apply to the Light and Wall Fade handlers.  The Reel handler is the same in both cases and suffers no
'significant CPU use regardless

'aFadeLm
'-------
'Fades Light Object based Lights When Multiple Lights are controlled by the Same Variable
'NOTE: The last light controlled by that variable must be called with the regular Sub handler 
'Example call: "aFadem 1, light1"
Sub aFadeLm(lightnumIn, stage3)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest ; off state is brighter off color 
	dim stage1on : stage1on = "" & stage3.name & "a.state = 1" : dim stage1off : stage1off = "" & stage3.name & "a.state = 0"
	dim stage2on : stage2on = "" & stage3.name & "b.state = 1" : dim stage2off : stage2off = "" & stage3.name & "b.state = 0"
	dim offstaton: offstaton= "" & stage3.name & "off.state=1" : dim offstatoff: offstatoff= "" & stage3.name & "off.state=0"

	Select Case lightnum(lightnumIn)
		Case  5 : ExecuteGlobal stage1off : ExecuteGlobal stage2off : stage3.state = 0 : stage3.state = 1
		Case  4 : stage3.state = 0 : ExecuteGlobal stage2off : ExecuteGlobal stage2on 
		Case  3 : ExecuteGlobal stage2off : ExecuteGlobal stage1off : ExecuteGlobal stage1on 
		Case  2 : ExecuteGlobal stage1off : ExecuteGlobal offstatoff : ExecuteGlobal offstaton 
		Case  1 : ExecuteGlobal offstatoff: stage3.state = 1 
		Case  0 : stage3.state = 0 : ExecuteGlobal offstaton 
	End Select
End Sub

'aFadeL
'------
'Fades Light Object based Lights 
'Example call: "aFade 1, light1"
Sub aFadeL(lightnumIn, stage3)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest ; off state is brighter off color
	dim stage1on : stage1on = "" & stage3.name & "a.state = 1" : dim stage1off : stage1off = "" & stage3.name & "a.state = 0"
	dim stage2on : stage2on = "" & stage3.name & "b.state = 1" : dim stage2off : stage2off = "" & stage3.name & "b.state = 0"
	dim offstaton: offstaton= "" & stage3.name & "off.state=1" : dim offstatoff: offstatoff= "" & stage3.name & "off.state=0"

	Select Case lightnum(lightnumIn)
		Case  5 : ExecuteGlobal stage1off : ExecuteGlobal stage2off : stage3.state = 0 : stage3.state = 1 : lightnum(lightnumIn) = 7
		Case  4 : stage3.state = 0 : ExecuteGlobal stage2off : ExecuteGlobal stage2on  : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  3 : ExecuteGlobal stage2off : ExecuteGlobal stage1off : ExecuteGlobal stage1on : lightnum(lightnumIn) = lightnum(lightnumIn) - 1 
		Case  2 : ExecuteGlobal stage1off : ExecuteGlobal offstatoff : ExecuteGlobal offstaton : lightnum(lightnumIn) = 6
		Case  1 : ExecuteGlobal offstatoff: stage3.state = 1 : lightnum(lightnumIn) = 7
		Case  0 : stage3.state = 0 : ExecuteGlobal offstaton : lightnum(lightnumIn) = 6
	End Select
End Sub

'aFadeWm
'-------
'Fades Wall Based Lights When Multiple Lights are controlled by the Same Variable
'NOTE: The last light controlled by that variable must be called with the regular Sub handler 
'Example call: "aFadeWm 1, light1"
'
'Note: the "off" condition should be provided by a non-dropping wall and the other stages should be set with their
'      top height just above that wall and their bottom height just below it and the wall set to drop.

Sub aFadeWm(lightnumIn, stage3)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest
	dim stage1on : stage1on = "" & stage3.name & "a.IsDropped = 1" : dim stage1off : stage1off = "" & stage3.name & "a.IsDropped = 0"
	dim stage2on : stage2on = "" & stage3.name & "b.IsDropped = 1" : dim stage2off : stage2off = "" & stage3.name & "b.IsDropped = 0"
	Select Case lightnum(lightnumIn)
		Case  5 : ExecuteGlobal stage1on  : ExecuteGlobal stage2on : stage3.IsDropped = False 
		Case  4 : stage3.IsDropped = True : ExecuteGlobal stage2off 
		Case  3 : ExecuteGlobal stage2on  : ExecuteGlobal stage1off 
		Case  2 : ExecuteGlobal stage1on
		Case  1 : ExecuteGlobal stage1on  : ExecuteGlobal stage2on : stage3.IsDropped = False
		Case  0 : ExecuteGlobal stage1on  : ExecuteGlobal stage2on : stage3.IsDropped = True
	End Select
End Sub

'aFadeW
'------
'Fades Wall Based Lights
'Example call: "aFadeW 1, light1"
'
'Note: the "off" condition should be provided by a non-dropping wall and the other stages should be set with their
'      top height just above that wall and their bottom height just below it and the wall set to drop.

Sub aFadeW(lightnumIn, stage3)
	'lightnum is the controlling light number ; stage 1 is dimmest, stage 2 is in-between ; stage 3 is brightest
	dim stage1on : stage1on = "" & stage3.name & "a.IsDropped = 1" : dim stage1off : stage1off = "" & stage3.name & "a.IsDropped = 0"
	dim stage2on : stage2on = "" & stage3.name & "b.IsDropped = 1" : dim stage2off : stage2off = "" & stage3.name & "b.IsDropped = 0"
	Select Case lightnum(lightnumIn)
		Case  5 : ExecuteGlobal stage1on  : ExecuteGlobal stage2on : stage3.IsDropped = False : lightnum(lightnumIn) = 7
		Case  4 : stage3.IsDropped = True : ExecuteGlobal stage2off : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  3 : ExecuteGlobal stage2on  : ExecuteGlobal stage1off : lightnum(lightnumIn) = lightnum(lightnumIn) - 1
		Case  2 : ExecuteGlobal stage1on  : lightnum(lightnumIn) = 6
		Case  1 : ExecuteGlobal stage1on  : ExecuteGlobal stage2on : stage3.IsDropped = False : lightnum(lightnumIn) = 7
		Case  0 : ExecuteGlobal stage1on  : ExecuteGlobal stage2on : stage3.IsDropped = True  : lightnum(lightnumIn) = 6
	End Select
End Sub

'Handles permanant 2-state lights (uses 2-lamps, one for on and one for off) (e.g. light1 and light1off)
'Example call: "aLitL2 1, light1"
Sub aLitL2(lightnumIn, light) 
	dim lightoff_on : lightoff_on = "" & light.name & "off.state = 1" : dim lightoff_off : lightoff_off = "" & light.name & "off.state = 0"
	Select Case lightnum(lightnumIn)
		Case 5: ExecuteGlobal lightoff_off : light.state = 1
		Case 4: light.state    = 0         : ExecuteGlobal lightoff_on
		Case 1: ExecuteGlobal lightoff_off : light.state    = 1
		Case 0: light.state    = 0         : ExecuteGlobal lightoff_on
	End Select
End Sub

'****************************
'Special Light Handling Cases
'****************************
'
'Calls here will do special things like turn off all lights with one command (only call currently)


'AllLightsOff
'------------
'
'This will turn all lights using the PD Light System OFF.
'
'Note: You should probably turn off the LightControl (or LightControlO) timer when calling this 
'      and turn it back on when you want to resume (useful when combined with a pop-up settings menu)

Sub AllLightsOff()
	'Set all Control Variables to 0 and call fade update 3 times to reset all lights to off
	On Error Resume Next
		For Tset = 0 To 200
			lightnum(Tset) = 0
		Next
	UpdateLights : UpdateLights : UpdateLights
End Sub
