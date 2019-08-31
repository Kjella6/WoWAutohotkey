#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; World of Warcraft anti disconnect script
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Written by Kjella
; Date: 31. August 2019
; Version: 1.2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Shortcuts
;
;   Toggle Auto Detect Queue Pop
;   Shift + CTRL + F10
;       Tired of having to wait in front of your computer for the queue to pop?
;       This function automatically detects when the queue wait is over
;       (Aka when the client is in the character select screen)
;       It then logs in to your character by pressing enter before it ends
;       It can even send a message to your Discord channel of choice - see below
;       
;       NOTE: This function assumes that you are in a server queue already
;       NOTE: wow.png must be included and stored in the same folder as the script
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Get window ID for World of Warcraft and make it global
WinGet, wowid, ID, World of Warcraft
Global wowid

; Discord Message - Replace 0 with 1 here if you would like to recieve a message to a discord channel when your queue pops
EnableDiscordMessage := 0

; Type in your Discord API token if you enable DiscordMessage (How to get a webhook for Discord: https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks )
DiscordWebhook := "https://INSERT_WEBHOOK_URL_HERE"
Global DiscordWebhook

; Type in the message you would like to send to Discord
DiscordMessageContent := "Your World of Warcraft queue just popped!"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SendDiscordMessage(DiscordMessage) {
    ; A simple HTTP POST request sending the message contents to the defined Webhook URL

    Text := StrReplace(StrReplace(DiscordMessage, "\", "\\"), """", "\""")
    Http := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
    Http.Open("POST", DiscordWebhook, False)
    Http.SetRequestHeader("Content-Type", "application/json")
    Http.Send("{""content"": """ Text """}")
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SHORTCUTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Shift + CTRL + F10
$^+F10::
    EnableAutodetectQueuePop := !EnableAutodetectQueuePop
    SetTimer, AutodetectQueuePop, -1
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AutodetectQueuePop:
    ; 2 second sleep so the user has time to release shortcut keys before progressing
    Sleep 2000

    MsgBox Auto detect queue pop enabled

    ; While loop keeps script running
    while (EnableAutodetectQueuePop) {
        ; Get World of Warcraft window location and size
        WinGetPos, xPos, yPos, WinWidth, WinHeight, ahk_id %wowid%

        CoordMode, Pixel, Screen
        endxPos := xPos + WinWidth
        endyPos := yPos + WinHeight

        ; Search for the image specified below
        ImageSearch, x, y, %xPos%, %yPos%, %endxPos%, %endyPos%, .\wow.png

        if (ErrorLevel = 2) {
            MsgBox AutodetectQueuePop failed miserably. For some reason it is unable to search the WoW window for character select screen
        }
        else if (ErrorLevel = 1) {
            ; Image was not found, assuming that client is still in queue. Sleep for 60 seconds before checking again
            Sleep 60000
        }
        else {
            ; Image was found. Client is currently at the character select screen.
            ; Sending message to Discord if user has elected to do so
            If (EnableDiscordMessage) {
                SendDiscordMessage(DiscordMessageContent)
            }

            ;Sleep for 20 minutes, since you have a 30 minute window before you're disconnected
            ;This essentially prolongs the time required before you're DCd to 1 hour 20 minutes (20 min sleep + 30 min AFK + 30 min on char select)
;            Sleep 1200000

            ; Press enter to enter the world
;            ControlSend,, {Enter}, ahk_id %wowid%

            ; Disable AutodetectQueuePop so it doesn't keep running in the background
            EnableAutodetectQueuePop := !EnableAutodetectQueuePop
        }
    }
Return ; End AutodetectQueuePop
