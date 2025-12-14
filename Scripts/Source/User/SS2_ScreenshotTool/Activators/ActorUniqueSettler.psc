scriptname SS2_ScreenshotTool:Activators:ActorUniqueSettler extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

Furniture Property MannequinFurniture Auto Const Mandatory

string sLogPrefix = "Activators:ActorUniqueSettler"
ObjectReference forcedFurniture

Function LogCount()
	Log("NPC Count: "+questIndexer.SS2SST_Index_UniqueSettlers.GetSize())
EndFunction

Function SetSourceFormList()
	sourceFormList = questIndexer.SS2SST_Index_UniqueSettlers
EndFunction

Event OnActivate(ObjectReference akReference)
    if bCaptureStage == 2
        bCaptureStage = 0
        Log("Capture interrupted")
    elseif bCaptureStage == 1
        bCaptureStage = 0
        Log("Capture canceled")
    else
		LogCount()
		Log("Capturing "+sourceFormList.GetSize()+" items. Starting in 5 seconds.")
		bCaptureStage = 1
		Utility.Wait(5)
		SetSourceFormList()
		BatchCapture()
    endif
EndEvent

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)
	
	forcedFurniture = PlaceAtMe(MannequinFurniture, 1, false, false, true)

	int i = sourceFormList.GetSize() - 1
	while i >= 0 && bCaptureStage == 2
		Capture(sourceFormList.GetAt(i) as SimSettlementsV2:MiscObjects:UnlockableCharacter)
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

Function Capture(SimSettlementsV2:MiscObjects:UnlockableCharacter thisForm)
	CheckIndexing()
	string sFormkey = GetFormKey(thisForm as Form)
	CaptureModel(thisForm)
EndFunction

Function CaptureModel(SimSettlementsV2:MiscObjects:UnlockableCharacter thisForm)
	Form ObjectForm = GetUniversalFormBaseForm(thisForm.CharacterForm)
	
	;; capture shot for main record
	if ObjectForm != none
		string sFormkey = GetFormKey(thisForm as Form)
		Log("Capturing NPC: "+sFormkey, false)

		Actor refObj = PlaceAtMe(ObjectForm, 1, false, true, true) as Actor
		refObj.Enable(false)

		while !refObj.Is3dLoaded()
			Utility.Wait(0.1)
		endwhile

		refObj.StartCombat(Game.GetPlayer(), true)
		refObj.SnapIntoInteraction(forcedFurniture)
        refObj.SetRestrained(true)

		Utility.Wait(1) ;; sometimes they are still fading in at this point, and Enable(false) isn't working

		questMain.TakeScreenshot(sFormkey)
		refObj.Disable(false)
		refObj.Delete()
	else
		Log("NPC is missing universal form: "+thisForm, false)
	endIf
EndFunction