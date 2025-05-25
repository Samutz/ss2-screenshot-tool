scriptname SS2_ScreenshotTool:Quests:Main extends Quest

Group General
	SimSettlementsV2:Quests:SS2Main Property SS2Main Auto Const Mandatory
	SS2_ScreenshotTool:Quests:Indexer Property questIndexer Auto Const Mandatory
	ObjectReference Property ItemContainer Auto Mandatory
	FormList Property ItemsToCaptureFormList Auto Mandatory
	Message Property WarningMessage Auto Const Mandatory
	GlobalVariable property WarningMessageAcceptedGlobal Auto Mandatory
EndGroup

Group ScreenshotSettings
	Weather Property ClearWeather Auto Const Mandatory
	GlobalVariable Property GameHour Auto Mandatory
	float Property FreezeTime = 12.0 Auto Const
	float Property ImageWidth = 1920.0 Auto Const
	float Property ImageHeight = 1080.0 Auto Const
EndGroup

Actor refPlayer
string sLogName = "SS2_ScreenshotTool"

;; --------------------------------------------------
;; Setup
;; --------------------------------------------------

Event OnQuestInit()
	Debug.OpenUserLog(sLogName)
	Log("Main Quest Started")
	refPlayer = Game.GetPlayer()
	RegisterForRemoteEvent(refPlayer, "OnPlayerLoadGame")
	StartUp()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akActorRef)
	Debug.OpenUserLog(sLogName)
	StartUp()
EndEvent

Function StartUp()
	if WarningMessageAcceptedGlobal.GetValue() == 0.0
		int response = WarningMessage.Show()
		if response == 0
			WarningMessageAcceptedGlobal.SetValue(1)
		else
			Game.QuitToMainMenu()
		endif
	endIf
EndFunction

Function Log(string sMessage)
	Debug.TraceUser(sLogName, sMessage)
EndFunction

;; --------------------------------------------------
;; Screenshot Functions
;; --------------------------------------------------

Function FreezeState(bool freeze)
	; not sure if this actually works
	if freeze
		Debug.SetGodMode(true)
		Utility.SetINIBool("bDisableAllAI:General", true)
		GameHour.SetValue(FreezeTime)
		ClearWeather.ForceActive()
	else
		Debug.SetGodMode(false)
		Utility.SetINIBool("bDisableAllAI:General", false)
	endIf
EndFunction

Function TakeScreenshot(string name)
    GameHour.SetValue(FreezeTime)
    ClearWeather.ForceActive()
	Game.SetCharGenHUDMode(3)
    Utility.Wait(0.1)
    SUP_F4SE.CaptureScreenshotAlt(sLogName, name+".jpg", 0, ImageWidth, 0, ImageHeight, 0, 100)
    Utility.Wait(0.1)
	Game.SetCharGenHUDMode(0)
EndFunction