scriptname SS2_ScreenshotTool:Activators:Flag extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

string sLogPrefix = "Activators:Flag"

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)

	int i = questIndexer.SS2SST_Index_Flags.GetSize() - 1
	while i >= 0 && bCaptureStage == 2
		Capture(questIndexer.SS2SST_Index_Flags.GetAt(i) as SimSettlementsV2:Armors:ThemeDefinition_Flags)
		i -= 1
	endWhile

	questMain.FreezeState(false)
	bCaptureStage = 0

	Enable()

	Log("BatchCapture() complete")
	Debug.MessageBox("BatchCapture() complete")

EndFunction

Function Capture(SimSettlementsV2:Armors:ThemeDefinition_Flags thisForm)
	CheckIndexing()

	if thisForm.FlagWall != none
		string sFormkey = GetFormKey(thisForm as Form)
		Log("Capturing flag: "+sFormkey)

		thisWorldObject.ObjectForm = thisForm.FlagWall

		ObjectReference refObj = WorkshopFramework:WSFW_API.CreateSettlementObject(thisWorldObject, refWorkshop)
		questMain.TakeScreenshot(sFormkey)
		WorkshopFramework:WSFW_API.RemoveSettlementObject(refObj)
		Utility.Wait(0.5)
	else
		Log("Flag is missing FlagWall property: "+thisForm)
	endIf
EndFunction