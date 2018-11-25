; ===============================================================
; WinScript: a GUI to launch commands and batch files in Windows
;
; Version: 0.95
; Author: Leonardo Cocco
; Last Edit: 25/11/2018
; ===============================================================
; ---------------------------------------------------------------------------------------------
; Instructions:
; 1. Adapt .ini template with same name of script
; 2. [Global] section lists appearance parameters (see comments in ini file)
; 2. Each line of [Commands] section is command description (key) and a batch command (value)
; 3. command is interpolated with parameters (placeholders are '%n', substituted in order)
; 4. for debug: executed commands are printed on stdout (redirected to file toread it)
; ---------------------------------------------------------------------------------------------

#include <WindowsConstants.au3>
#include <StringConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>


Dim $cfg

AutoItSetOption("TrayIconHide", 1)
$cfg = ReadConfig()
Main($cfg)

Func ReadConfig()
	Local Const $RowHeight = 25
	Local Const $FontHeight = 8.5
	Local $objConfig
	Local $ExeName = ""
	Local $CfgFile = ""
	Local $pos = 0
	Local $cmds
	Local $idx
	Local $CommandList, $Commands
	
	$pos = StringInStr(@ScriptName, ".", 0, -1)
	If $pos > 0 Then
		$ExeName = StringLeft(@ScriptName, $pos-1)
	EndIf
	$CfgFile = $ExeName & ".ini"
	
	$objConfig = ObjCreate("Scripting.Dictionary")
	$objConfig.Add("Name", IniRead($CfgFile, "Global", "Name", "WinScript"))
	$objConfig.Add("Label", IniRead($CfgFile, "Global", "Label", "Parameters"))
	$objConfig.Add("Button", IniRead($CfgFile, "Global", "Button", "Execute"))
	$objConfig.Add("Width", Number(IniRead($CfgFile, "Global", "Width", "300")))
	$objConfig.Add("FontSize", $FontHeight * Number(IniRead($CfgFile, "Global", "FontSize", "100")) / 100)
	$objConfig.Add("RowHeight", $RowHeight * Number(IniRead($CfgFile, "Global", "FontSize", "100")) / 100)
	$objConfig.Add("TextboxRows", Number(IniRead($CfgFile, "Global", "TextboxRows", "1")))
	
	$CommandList = ""
	$Commands = ObjCreate("Scripting.Dictionary")
	$cmds = IniReadSection($CfgFile, "Commands")
	For $idx = 1 To $cmds[0][0]
		$CommandList = $CommandList & $cmds[$idx][0] & "|"
		$Commands.Add($cmds[$idx][0],$cmds[$idx][1])
	Next
	$objConfig.Add("CommandList", StringTrimRight($CommandList,1))
	$objConfig.Add("Commands", $Commands)
	
	Return $objConfig
EndFunc

Func Main($cfg)
	Local $GUIWidth = Number($cfg.Item("Width"))
	Local $RowHeight = $cfg.Item("RowHeight")
	Local $FontSize = $cfg.Item("FontSize")
	Local $TextboxRows = $cfg.Item("TextboxRows")
		
	Local $iMsg, $idLabel, $idListbox, $idButton, $idTextbox
	Local $cmds, $cmd
	Local $txt, $params, $cnt
	
	;Create window
	GUICreate($cfg.Item("Name"), $GUIWidth, 10+$RowHeight+10+$RowHeight+$RowHeight*$TextboxRows+10+$RowHeight+10)
	
	;Create a ListBox
	$idListbox = GUICtrlCreateCombo("", 10, 10, $GUIWidth-20, $RowHeight)
	GUICtrlSetFont($idListbox, $FontSize)
	$cmds = $cfg.Item("Commands")
	GUICtrlSetData($idListbox, $cfg.Item("CommandList"))
	
	;Create an edit box
	$idLabel = GUICtrlCreateLabel($cfg.Item("Label"), 10, 10+$RowHeight+10, $GUIWidth-20, $RowHeight)
	GUICtrlSetFont($idLabel, $FontSize)
	$idTextbox = GUICtrlCreateEdit("", 10, 10+$RowHeight+10+$RowHeight, $GUIWidth-20, $RowHeight*$TextboxRows, $ES_WANTRETURN + $ES_AUTOVSCROLL + $ES_AUTOHSCROLL) 
	GUICtrlSetFont($idTextbox, $FontSize)
	
	;Create a button
	$idButton = GUICtrlCreateButton($cfg.Item("Button"), 10+($GUIWidth-20)/3, 10+$RowHeight+10+$RowHeight+$RowHeight*$TextboxRows+10, ($GUIWidth-20)/3, $RowHeight)
	GUICtrlSetFont($idButton, $FontSize)
	
	;Show window/Make the window visible
	GUISetState(@SW_SHOW)

	While True
		;After every loop check if the user clicked something in the GUI window
		$iMsg = GUIGetMsg()
		
		Select
			;Check if user clicked on the close button
			Case $iMsg = $GUI_EVENT_CLOSE
				;Destroy the GUI including the controls
				GUIDelete()
				;Exit the script
				Exit
			
			Case $iMsg = $idButton
				;Read Parameters from Text Box
				$txt = GUICtrlRead($idTextbox)
				$params = StringSplit($txt, @CRLF, $STR_ENTIRESPLIT + $STR_NOCOUNT)
				
				;get Command associated to item selected in List Box
				$txt = GUICtrlRead($idListbox)
				$cmd = $cmds.Item($txt) ;with placeholders '%n'
				
				;Interpolate parameters
				$cmd = SetParameters($cmd, $params) ;substitute placeholders
				
				;Execute Command
				ConsoleWrite($cmd & @CRLF) ;for debug purposes
				Run($cmd, "", @SW_HIDE)
		EndSelect
	WEnd
EndFunc

Func SetParameters($command, $parameters)
	Local $idx
	
	For $idx = 0 to UBound($parameters, 1)-1
		$command = StringReplace($command, "%" & String($idx+1), $parameters[$idx], $STR_CASESENSE)
	Next
	
	Return $command
EndFunc
