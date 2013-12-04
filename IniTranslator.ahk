/*
	IniTranslator

	Copyright 2013 Avi Aryan

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

;@Ahk2Exe-SetName IniTranslator
;@Ahk2Exe-SetDescription IniTranslator
;@Ahk2Exe-SetVersion 0.0.0.1
;@Ahk2Exe-SetCopyright Avi Aryan
;@Ahk2Exe-SetOrigFilename IniTranslator.exe

SetBatchLines, -1
FileEncoding, UTF-8
#NoEnv
ListLines, Off

global PROGNAME := "Ini Translator"
global CONFIGURATION_FILE := "iniTranslator.ini"
global version := "0.0.0.1"
global ini_RootDir, translateAPI, ini_removeampersand, ini_wf, ini_hf

init()
iniT_gui()
return


iniT_gui(){
	global selfile, sellangs, ignorew, savefile, btn_translate

	Gui, IniT:new
	Gui, Margin, 7, 7

	width := Floor( A_ScreenWidth / 1.6 ) * ini_wf		;auto width and height
	height := Floor( A_Screenheight / 3.8 ) * ini_hf

	Gui, Add, GroupBox, % "w" width " h60 section", % "Choose Ini File"
	Gui, Add, Edit, % "xp+10 yp+20 w" width-150 " vselfile"
	Gui, Add, Button, % "x" width-80 " yp w70 gIniTbuttonOpen Default", % "Br&owse"

	;20 margin between group boxes
	Gui, Add, GroupBox, % "x7 h" height " ys+80 section w" width/3, % "Languages to Translate"
	Gui, Add, Text, % "xp+10 yp+20", % "Use Ctrl and Shift to multi-select." "`n"
	Gui, Add, ListBox, % "xp y+10 w" width/3 - 25 " h" height-70 " vsellangs +Multi", % getLangcode()

	Gui, Add, GroupBox, % "x" width/3+25 " h" height " ys w" width*0.66-10 " section", % "Keywords to preserve"
	Gui, Add, Text, % "xp+10 yp+20", % "List here all the keywords or phrases that you dont want to be translated.`nfor eg -> Settings Window"
	Gui, Add, Edit, % "xp y+10 w" width*0.66-30 " h" height-70 " +multi vignorew",

	Gui, Add, GroupBox, % "ys+" height+20 " x7 h90 section w" width, % "Save As"
	Gui, Add, Text, % "xp+10 yp+20", % "For multiple selections, you can use a variable such as *lang* to substitute translated language at that place.`n"
		. "For eg > D:\MyProject\language\*lang*.ini"
	Gui, Add, Edit, % "xp y+10 w" width-150 " vsavefile",
	Gui, Add, Button, % "x" width-80 " yp w70 gIniTbuttonSave", % "Brow&se"

	;30 y-axis margin
	Gui, Font, s10
	Gui, Add, Button, % "x7 ys+130 vbtn_translate gIniTbuttontranslate", % "&Translate"
	Gui, Font, s9
	Gui, Add, Button, % "x" width-80 " yp w87 gExit", % "&Exit" 		;80+7 for margin
	Gui, Add, Statusbar,

	Gui, IniT:Show, , % PROGNAME

	SB_SetText("Initializing.... Please wait")
	GuiControl,, btn_translate, % "Wait.."
	translateAPI := new GoogleTranslate()
	GuiControl,, btn_translate, % "&Translate"

	SB_SetText("Load a file in Ini format")
	return

IniTbuttonOpen:
	FileSelectFile, selfile,, %ini_RootDir%, % "Select file in Ini format to translate"
	if selfile
	{
		ini_RootDir := Substr(selfile, 1, Instr(selfile, "\", 0, 0)-1)
		GuiControl,, selfile, % selfile
		GuiControl, +Default, % "Brow&se"
	}
	return

IniTbuttonSave:
	FileSelectFile, savefile, S16, %ini_Rootdir%, % "Save translated file as"
	if savefile
	{
		ini_RootDir := Substr(savefile, 1, Instr(savefile, "\", 0, 0)-1)
		GuiControl,, savefile, % savefile
		GuiControl, +Default, % "&Translate"
	}
	return

IniTbuttontranslate:
	Gui, iniT:submit, nohide

	if !selfile
		return SB_SetText("Nothing to translate")
	if !sellangs
		return SB_SetText("No language selected")

	keylines := {} , thefile := {}
	text2translate := ""

	SB_SetText("Initialising")
	;form translation file
	loop, read, % selfile
	{
		thefile.Insert(A_LoopReadLine)
		if RegExMatch( Trim(A_LoopReadLine) ";" , "[;\[]" ) = 1 		;intentionally added ; to make blank lines ignored
			continue
		else
			keylines[A_index] := 1 , text2translate .= Substr( A_LoopReadLine, Instr(A_loopreadline, "=")+1 ) "`n"
	}
	;replace ignorew
	loop, parse, ignorew, `n
		StringReplace, text2translate, text2translate, % A_LoopReadLine, % A_LoopReadLine "0dttft2", All 			; dont translate this f text

	if ini_removeampersand
		text2translate := RegExReplace(text2translate, "i)&[a-z0-9]", "")

	nooflangs := getQuant(sellangs, "|") + 1
	if !savefile
		savefile := ini_Rootdir "\*lang*.ini"

	;translate
	loop, parse, sellangs, |
	{
		tosavetext := "" , translatedobj := {} , count := 0

		SB_SetText("Translating " A_index " (" A_LoopField  ") of " nooflangs)

		translatedtext := TranslateAPI.translate( text2translate , A_LoopField )

		StringReplace, translatedtext, translatedtext, 0dttft2,, All 	; fix ignore words

		loop, parse, translatedtext, `n
			translatedobj.Insert(A_LoopField)

		SB_SetText("Saving " A_index " (" A_LoopField  ") of " nooflangs)
		; build translated file

		for k,v in thefile
		{
			if keylines[k] != ""
				count+=1 , tosavetext .= Substr(v, 1, Instr(v, "=")) translatedobj[count] "`r`n" 		;using `r`n to avoid issues wwith notepad
			else
				tosavetext .= v "`r`n"
		}

		;saving file
		StringReplace, x_savefile, savefile, *lang*, % A_LoopField, All
		FileDelete, % x_savefile
		FileAppend, % tosavetext, % x_savefile
	}
	SB_SetText("Completed")
	return

IniTGuiClose:
	translateAPI.o := ""
	Exitapp
	return

}


about:
	MsgBox, 64, % PROGNAME,% PROGNAME " v" version " beta`ncreated by Avi Aryan"
	return

reload:
	reload

updates:
	Msgbox, Not ready
	return

help:
	Msgbox, Feature coming soon.
	return

Exit:
	IniWrite, % ini_RootDir, % CONFIGURATION_FILE, Main, rootdir
	Exitapp
	return



init(){

	ini_write("Main", "rootdir", blank)
	ini_write("Main", "remove_ampersand", 1)
	ini_write("Main", "w_intofactor", 1)
	ini_write("Main", "h_intofactor", 1)
	ini_write("System", "version", version, 0)

	ini_Rootdir := Ini_read("Main", "rootdir")
	ini_removeampersand := Ini_read("Main", "remove_ampersand")
	ini_wf := Ini_read("Main", "w_intofactor")
	ini_hf := Ini_read("Main", "h_intofactor")

	Menu, Tray, NoStandard
	if !A_isCompiled
		Menu, Tray, Icon, icons\icon.ico

	Menu, Tray, Add, % "About" " " PROGNAME, about
	Menu, Tray, Tip, % PROGNAME
	Menu, Tray, Add
	Menu, Tray, Add, % "Check for Updates", updates
	Menu, Tray, Add, % "Help", help
	Menu, Tray, Add
	Menu, Tray, Add, % "Restart", reload
	Menu, Tray, Add, % "Exit", exit
	Menu, Tray, Default, % "About" " " PROGNAME
}

#include %A_ScriptDir%/lib/gtranslate.ahk
#include %A_ScriptDir%/lib/functions.ahk