scriptname SS2_ScreenshotTool:Activators:PowerPole extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

string sLogPrefix = "Activators:PowerPole"

Function LogCount()
	Log("PowerPole Count: "+questIndexer.SS2SST_Index_PowerPoles.GetSize())
EndFunction

Function SetSourceFormList()
	sourceFormList = questIndexer.SS2SST_Index_PowerPoles
EndFunction

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)

	int i = questMain.ItemsToCaptureFormList.GetSize() - 1
	while i >= 0 && bCaptureStage == 2
		Capture(questMain.ItemsToCaptureFormList.GetAt(i) as SimSettlementsV2:MiscObjects:PowerPole)
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

Function Capture(SimSettlementsV2:MiscObjects:PowerPole thisForm)
	CheckIndexing()

	if thisForm.Spawndata != none
		string sFormkey = GetFormKey(thisForm as Form)
		Log("Capturing PowerPole: "+sFormkey, false)

		thisWorldObject.ObjectForm = GetWorldObjectForm(thisForm.Spawndata)

		ObjectReference refObj = WorkshopFramework:WSFW_API.CreateSettlementObject(thisWorldObject, refWorkshop)
		questMain.TakeScreenshot(sFormkey)
		WorkshopFramework:WSFW_API.RemoveSettlementObject(refObj)
		Utility.Wait(0.5)
	else
		Log("PowerPole is missing Spawndata property: "+thisForm, false)
	endIf
EndFunction