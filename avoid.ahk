#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Client
global gOpenProcess := 10000    ;time in milliseconds for your PC to open Idle Champions
global gGetAddress := 5000      ;time in milliseconds after Idle Champions is opened for it to read moduel base address from memory

global g_avoid := [10, 35]
global g_jump := 4

;class and methods for parsing JSON (User details sent back from a server call)
#include JSON.ahk

;wrapper with memory reading functions sourced from: https://github.com/Kalamity/classMemory
#include classMemory.ahk

;Check if you have installed the class correctly.
if (_ClassMemory.__Class != "_ClassMemory")
{
    msgbox class memory not correctly installed. Or the (global class) variable "_ClassMemory" has been overwritten
    ExitApp
}

;pointer addresses and offsets
#include IC_MemoryFunctions.ahk

$VKC0::
Pause
gPrevLevelTime := A_TickCount
return


;Pass Object Mode Option in regex string
RegexMatchAll(h, n)
{
	r := []
	p := 1
	loop
	{
		if(!RegexMatch(h, n, m, p))
			break
		r.Push(m)
		p := m.Pos + m.Len
	}
	return r
}

;Untested may not work with IC
DirectedInputMod(m, k)
{
    hwnd := WinExist("ahk_exe IdleDragons.exe")
    ControlFocus,, ahk_id %hwnd%
	vkm := Format("0x{:X}", GetKeyVK(Trim(m, "{}")))
	vkk := Format("0x{:X}", GetKeyVK(Trim(k, "{}")))
	PostMessage, 0x0100, %vkm%, 0,, ahk_id %hwnd%
	Sleep, 10
	PostMessage, 0x0100, %vkk%, 0,, ahk_id %hwnd%
	Sleep, 10
	PostMessage, 0x0101, %vkk%, 0xC0000001,, ahk_id %hwnd%
	Sleep, 10
	PostMessage, 0x0101, %vkm%, 0xC0000001,, ahk_id %hwnd%
	Sleep, 10
}

DirectedInput(s) 
{
	hwnd := WinExist("ahk_exe IdleDragons.exe")
    ControlFocus,, ahk_id %hwnd%
	m := RegExMatchAll(s, "O)([^{]|{[^}]+})")
	for k, v in m
	{
		vk := GetKeyVK(Trim(v.Value(1), "{}"))
		if(vk)
		{
			vk := Format("0x{:X}", vk)
			PostMessage, 0x0100, %vk%, 0,, ahk_id %hwnd%
			Sleep, 10
			PostMessage, 0x0101, %vk%, 0xC0000001,, ahk_id %hwnd%
			Sleep, 10
		}
	}
}

SetFormation(lvl)
{
	mlvl := Mod(lvl, 50)
	for k, v in g_avoid
	{
		if(g_jump + mlvl == v OR g_jump + mlvl - 1 == v)
		{
			DirectedInput("e")
			return
		}
	}
	if(True)
	{
		jlvl := g_jump + mlvl
		if(Mod(jlvl, 5) == 0 OR Mod(jlvl - 1, 5) == 0)
		{
			DirectedInput("e")
			return
		}
	}
    DirectedInput("q")
}

XButton1::
OpenProcess()
ModuleBaseAddress()
loop
{
	lvl := ReadCurrentZone()
	SetFormation(lvl)
}
