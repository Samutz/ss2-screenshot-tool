scriptname SS2_ScreenshotTool:Activators:Furniture extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

string sLogPrefix = "Activators:Furniture"

Function LogCount()
	Log("Furniture Count: "+questIndexer.SS2SST_Index_Furniture.GetSize())
EndFunction

Function SetSourceFormList()
	sourceFormList = questIndexer.SS2SST_Index_Furniture
EndFunction

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)

	int i = questMain.ItemsToCaptureFormList.GetSize() - 1
	while i >= 0 && bCaptureStage == 2
		Capture(questMain.ItemsToCaptureFormList.GetAt(i) as SimSettlementsV2:MiscObjects:FurnitureStoreItem)
		if i % 5 == 0 ; only do every 5 since notifications are slower than the time spent on each item
			Log(i +" remaining")
		endif
		i -= 1
	endWhile

	questMain.FreezeState(false)
	bCaptureStage = 0

	Enable()

	Log("BatchCapture() complete")
EndFunction

Function Capture(SimSettlementsV2:MiscObjects:FurnitureStoreItem thisForm)
	CheckIndexing()

	if thisForm.DisplayVersion != none
		string sFormkey = GetFormKey(thisForm as Form)
		Log("Capturing Furniture: "+sFormkey, false)

		thisWorldObject.ObjectForm = GetUniversalFormBaseForm(thisForm.DisplayVersion)

		ObjectReference refObj = WorkshopFramework:WSFW_API.CreateSettlementObject(thisWorldObject, refWorkshop)
		questMain.TakeScreenshot(sFormkey)
		WorkshopFramework:WSFW_API.RemoveSettlementObject(refObj)
		Utility.Wait(0.5)
	else
		Log("Furniture is missing DisplayVersion property: "+thisForm, false)
	endIf
EndFunction