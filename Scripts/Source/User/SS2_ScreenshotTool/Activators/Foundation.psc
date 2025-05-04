scriptname SS2_ScreenshotTool:Activators:Foundation extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

string sLogPrefix = "Activators:Foundation"

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)

	int j = questIndexer.indexedAddons.Length - 1
	while j >= 0 && bCaptureStage == 2
		int i = questIndexer.indexedAddons[j].Foundations.Length - 1
		while i >= 0 && bCaptureStage == 2
			Capture(questIndexer.indexedAddons[j].Foundations[i])
			i -= 1
		endWhile
		j -= 1
	endWhile

	questMain.FreezeState(false)
	bCaptureStage = 0

	Enable()

	Log("BatchCapture() complete")
	Debug.MessageBox("BatchCapture() complete")

EndFunction

Function Capture(SimSettlementsV2:MiscObjects:Foundation thisForm)
	CheckIndexing()

	if thisForm.Spawndata != none
		string sFormkey = GetFormKey(thisForm as Form)
		Log("Capturing Foundation: "+sFormkey)

		thisWorldObject.ObjectForm = GetWorldObjectForm(thisForm.Spawndata)

		ObjectReference refObj = WorkshopFramework:WSFW_API.CreateSettlementObject(thisWorldObject, refWorkshop)
		questMain.TakeScreenshot(sFormkey)
		WorkshopFramework:WSFW_API.RemoveSettlementObject(refObj)
		Utility.Wait(0.5)
	else
		Log("Foundation is missing Spawndata property: "+thisForm)
	endIf
EndFunction