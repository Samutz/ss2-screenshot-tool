scriptname SS2_ScreenshotTool:Activators:ActorCityLeader extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

Furniture Property MannequinFurniture Auto Const Mandatory

string sLogPrefix = "Activators:ActorCityLeader"
ObjectReference forcedFurniture

Function LogCount()
	Log("NPC Count: "+questIndexer.SS2SST_Index_LeaderCards.GetSize())
EndFunction

Function SetSourceFormList()
	sourceFormList = questIndexer.SS2SST_Index_LeaderCards
EndFunction

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)
	
	forcedFurniture = PlaceAtMe(MannequinFurniture, 1, false, false, true)

	int i = sourceFormList.GetSize() - 1
	while i >= 0 && bCaptureStage == 2
		Capture(sourceFormList.GetAt(i) as SimSettlementsV2:Weapons:LeaderCard)
		if i % 10 == 0 ; only do every 10 since notifications are slower than the time spent on each item
			Log(i +" remaining")
		endif
		i -= 1
	endWhile

	forcedFurniture.Disable(false)
	forcedFurniture.Delete()

	questMain.FreezeState(false)
	bCaptureStage = 0

	Enable()

	Log("BatchCapture() complete")
EndFunction

Function Capture(SimSettlementsV2:Weapons:LeaderCard thisForm)
	CheckIndexing()
	string sFormkey = GetFormKey(thisForm as Form)
	CaptureModel(thisForm)
EndFunction

Function CaptureModel(SimSettlementsV2:Weapons:LeaderCard thisForm)
	Form ObjectForm = GetUniversalFormBaseForm(thisForm.ActorBaseForm)
	
	;; capture shot for main record
	if ObjectForm != none
		string sFormkey = GetFormKey(thisForm as Form)
		Log("Capturing NPC: "+sFormkey, false)

		Actor refObj = PlaceAtMe(ObjectForm, 1, false, true, true) as Actor
		refObj.Enable(false)

		while !refObj.Is3dLoaded()
			Utility.Wait(0.1)
		endwhile

		refObj.SnapIntoInteraction(forcedFurniture)
        refObj.SetRestrained(true)

		Utility.Wait(1) ;; sometimes they are still fading in at this point, and Enable(false) isn't working

		;refObj.SetHeadTracking(true)
        ;refObj.BlockActivation(true, false)
        ;refObj.SetGhost(true)

		questMain.TakeScreenshot(sFormkey)
		refObj.Disable(false)
		refObj.Delete()
	else
		Log("NPC is missing universal form: "+thisForm, false)
	endIf
EndFunction