scriptname SS2_ScreenshotTool:Activators:Foundation extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

string sLogPrefix = "Activators:Foundation"

Function LogCount()
	Log("Foundation Count: "+questIndexer.SS2SST_Index_Foundations.GetSize())
EndFunction

Function SetSourceFormList()
	sourceFormList = questIndexer.SS2SST_Index_Foundations
EndFunction

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)

	int i = questMain.ItemsToCaptureFormList.GetSize() - 1
	while i >= 0 && bCaptureStage == 2
		Capture(questMain.ItemsToCaptureFormList.GetAt(i) as SimSettlementsV2:MiscObjects:Foundation)
		Log(i +" remaining")
		i -= 1
	endWhile

	questMain.FreezeState(false)
	bCaptureStage = 0

	Enable()

	Log("BatchCapture() complete")
EndFunction

Function Capture(SimSettlementsV2:MiscObjects:Foundation thisForm)
	CheckIndexing()

	if thisForm.Spawndata != none
		string sFormkey = GetFormKey(thisForm as Form)
		Log("Capturing Foundation: "+sFormkey, false)

		thisWorldObject.ObjectForm = GetWorldObjectForm(thisForm.Spawndata)

		ObjectReference refObj = WorkshopFramework:WSFW_API.CreateSettlementObject(thisWorldObject, refWorkshop)
		questMain.TakeScreenshot(sFormkey)
		WorkshopFramework:WSFW_API.RemoveSettlementObject(refObj)
		Utility.Wait(0.5)
	else
		Log("Foundation is missing Spawndata property: "+thisForm, false)
	endIf
EndFunction