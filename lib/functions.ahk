; extra functions used in initranslator

;returns the nearest pos of that char present near that position
;nearestChratPos(str, pos, char, precision=20){

;	loop % Floor( Strlen(str)/precision )
;	{
;		p := Substr(str, pos-(A_index*precision), pos+(A_index*precision))
;		z := r := A_index*precision+1
;		loop, parse, p
;			if A_LoopField = %char%
;				if Abs(z-A_index) < r
;					r := Abs(z-A_index) , re := A_index , d := 1
;		if d
;			return pos-z+re
;	}
;	return 0
;}

IsLatestRelease(prog_ver, cur_ver, exclude_keys="beta|alpha") {

	if RegExMatch(prog_ver, "(" exclude_keys ")")
		return 1

	StringSplit, prog_ver_array, prog_ver,`.
	StringSplit, cur_ver_array, cur_ver  ,`.

	Loop % cur_ver_array0
		if !( prog_ver_array%A_index% >= cur_ver_array%A_index% )
			return 0
	return 1
}

Ini_read(section, key){
	Iniread, v, % CONFIGURATION_FILE,% section,% key, %A_space%
	if v = %A_temp%
		v := ""
	return v
}

getQuant(str, what){
	StringReplace, str, str,% what,% what, UseErrorLevel
	return ErrorLevel
}

Ini_write(section, key, value="", ifblank=true){
	;ifblank means if the key doesn't exist

	Iniread, v,% CONFIGURATION_FILE,% section,% key

	if ifblank && (v == "ERROR")
		IniWrite,% value,% CONFIGURATION_FILE,% section,% key
	if !ifblank
		IniWrite,% value,% CONFIGURATION_FILE,% section,% key
}