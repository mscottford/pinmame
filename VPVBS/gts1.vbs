'Added in VBS v3.27
'Gottlieb System 1
'Dip menu Written by Inkochnito

'Last Updated in VBS v3.17

Option Explicit
LoadCore
Private Sub LoadCore
	On Error Resume Next
	If VPBuildVersion < 0 Or Err Then
		Dim fso : Set fso = CreateObject("Scripting.FileSystemObject") : Err.Clear
		ExecuteGlobal fso.OpenTextFile("core.vbs", 1).ReadAll    : If Err Then MsgBox "Can't open ""core.vbs""" : Exit Sub
		ExecuteGlobal fso.OpenTextFile("VPMKeys.vbs", 1).ReadAll : If Err Then MsgBox "Can't open ""vpmkeys.vbs""" : Exit Sub
	Else
		ExecuteGlobal GetTextFile("core.vbs")    : If Err Then MsgBox "Can't open ""core.vbs"""    : Exit Sub
		ExecuteGlobal GetTextFile("VPMKeys.vbs") : If Err Then MsgBox "Can't open ""vpmkeys.vbs""" : Exit Sub
	End If
End Sub

'-------------------------
' GTS1 Data
'-------------------------
Const swTest        = 00
Const swCoin1       = 01
Const swCoin2       = 02
Const swStartButton = 03
Const swTilt        = 04
Const swSlamTilt    = 76

Const swLRFlip      = 82
Const swLLFlip      = 84

' Help window
vpmSystemHelp = "Gottlieb System 1 keys" & vbNewLine &_
  vpmKeyName(keyInsertCoin1)  & vbTab & "Insert Coin #1" & vbNewLine &_
  vpmKeyName(keyInsertCoin2)  & vbTab & "Insert Coin #2" & vbNewLine &_
  vpmKeyName(keySelfTest)     & vbTab & "Test"           & vbNewLine &_
  vpmKeyName(keySlamDoorHit)  & vbTab & "Slam Tilt"

' Dip Switch / Options Menu
Private Sub GTS1ShowDips
	If Not IsObject(vpmDips) Then ' First time
		Set vpmDips = New cvpmDips

	With vpmDips
		.AddForm 700,400,"System 1 - DIP switches"
		.AddFrame 205,0,190,"Maximum credits",&H00030000,Array("5 credits",0,"8 credits",&H00020000,"10 credits",&H00010000,"15 credits",&H00030000)'dip 17&18
		.AddFrame 0,0,190,"Coin chute control",&H00040000,Array("seperate",0,"same",&H00040000)'dip 19
		.AddFrame 0,46,190,"Game mode",&H00000400,Array("extra ball",0,"replay",&H00000400)'dip 11
		.AddFrame 0,92,190,"High game to date awards",&H00200000,Array("no award",0,"3 replays",&H00200000)'dip 22
		.AddFrame 0,138,190,"Balls per game",&H00000100,Array("5 balls",0,"3 balls",&H00000100)'dip 9
		.AddFrame 0,184,190,"Tilt effect",&H00000800,Array("game over",0,"ball in play only",&H00000800)'dip 12
		.AddChk 205,80,190,Array("Match feature",&H00000200)'dip 10
		.AddChk 205,95,190,Array("Credits displayed",&H00001000)'dip 13
		.AddChk 205,110,190,Array("Play credit button tune",&H00002000)'dip 14
		.AddChk 205,125,190,Array("Play tones when scoring",&H00080000)'dip 20
		.AddChk 205,140,190,Array("Play coin switch tune",&H00400000)'dip 23
		.AddChk 205,155,190,Array("High game to date displayed",&H00100000)'dip 21
		.AddLabel 50,240,300,20,"After hitting OK, press F3 to reset game with new settings."
		.ViewDips
	End With
	End If
End Sub
Set vpmShowDips = GetRef("GTS1ShowDips")
Private vpmDips

' Keyboard handlers
Function vpmKeyDown(ByVal keycode)
	On Error Resume Next
	vpmKeyDown = True ' assume we handle the key
	With Controller
		If keycode = RightFlipperKey Then .Switch(swLRFlip) = True
		If keycode = LeftFlipperKey  Then .Switch(swLLFlip) = True
		Select Case keycode
			Case keyInsertCoin1  vpmTimer.AddTimer 750,"vpmTimer.PulseSw swCoin1'" : Playsound SCoin
			Case keyInsertCoin2  vpmTimer.AddTimer 750,"vpmTimer.PulseSw swCoin2'" : Playsound SCoin
			Case StartGameKey    .Switch(swStartButton) = True
			Case keySelfTest     .Switch(swTest)        = True
			Case keySlamDoorHit  .Switch(swSlamTilt)    = True
			Case keyBangBack     vpmNudge.DoNudge   0,6
			Case LeftTiltKey     vpmNudge.DoNudge  75,2
			Case RightTiltKey    vpmNudge.DoNudge 285,2
			Case CenterTiltKey   vpmNudge.DoNudge   0,2
			Case Else            vpmKeyDown = False
		End Select
	End With
	On Error Goto 0
End Function

Function vpmKeyUp(ByVal keycode)
	On Error Resume Next
	vpmKeyUp = True ' assume we handle the key
	With Controller
		If keycode = RightFlipperKey Then .Switch(swLRFlip) = False
		If keycode = LeftFlipperKey  Then .Switch(swLLFlip) = False
		Select Case keycode
			Case StartGameKey    .Switch(swStartButton) = False
			Case keySelfTest     .Switch(swTest)        = False
			Case keySlamDoorHit  .Switch(swSlamTilt)    = False
			Case keyShowOpts     .Pause = True : .ShowOptsDialog GetPlayerHWnd : .Pause = False
			Case keyShowKeys     .Pause = True : vpmShowHelp : .Pause = False
			Case keyShowDips     If IsObject(vpmShowDips) Then .Pause = True : vpmShowDips : .Pause = False
			Case keyAddBall      .Pause = True : vpmAddBall  : .Pause = False
			Case keyReset        .Stop : BeginModal : .Run : vpmTimer.Reset : EndModal
			Case keyFrame        .LockDisplay = Not .LockDisplay
			Case keyDoubleSize   .DoubleSize  = Not .DoubleSize
			Case Else            vpmKeyUp = False
		End Select
	End With
	On Error Goto 0
End Function




