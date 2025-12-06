scriptname SS2_ScreenshotTool:Activators:Flag extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

string sLogPrefix = "Activators:Flag"

Function LogCount()
	Log("Flag Count: "+questIndexer.SS2SST_Index_Flags.GetSize())
EndFunction

Function SetSourceFormList()
	sourceFormList = questIndexer.SS2SST_Index_Flags
EndFunction

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)

	int i = questMain.ItemsToCaptureFormList.GetSize() - 1
	while i >= 0 && bCaptureStage == 2
		Capture(questMain.ItemsToCaptureFormList.GetAt(i) as SimSettlementsV2:Armors:ThemeDefinition_Flags)
		if i % 10 == 0 ; only do every 10 since notifications are slower than the time spent on each item
			Log(i +" remaining")
		endif
		i -= 1
	endWhile

	questMain.FreezeState(false)
	bCaptureStage = 0

	Enable()

	Log("BatchCapture() complete")
EndFunction

Function Capture(SimSettlementsV2:Armors:ThemeDefinition_Flags thisForm)
	CheckIndexing()
	
	;; capture shot for main record
	if thisForm.FlagWall != none
		string sFormkey = GetFormKey(thisForm as Form)
		Log("Capturing flag: "+sFormkey, false)

		thisWorldObject.ObjectForm = thisForm.FlagWall

		ObjectReference refObj = WorkshopFramework:WSFW_API.CreateSettlementObject(thisWorldObject, refWorkshop)
		questMain.TakeScreenshot(sFormkey)
		WorkshopFramework:WSFW_API.RemoveSettlementObject(refObj)
		Utility.Wait(0.5)
	else
		Log("Flag is missing FlagWall property: "+thisForm, false)
	endIf

	;; capture shot for model record
	CaptureModel(thisForm.FlagWall)
EndFunction

Function CaptureModel(Form flagModel)
	if flagModel != none
		string sFormkey = GetFormKey(flagModel)
		Log("Capturing flag: "+sFormkey, false)

		thisWorldObject.ObjectForm = flagModel

		ObjectReference refObj = WorkshopFramework:WSFW_API.CreateSettlementObject(thisWorldObject, refWorkshop)
		questMain.TakeScreenshot(sFormkey)
		WorkshopFramework:WSFW_API.RemoveSettlementObject(refObj)
		Utility.Wait(0.5)
	else
		Log("Flag is missing model property: "+flagModel, false)
	endIf
EndFunction