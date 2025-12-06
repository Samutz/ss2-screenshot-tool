scriptname SS2_ScreenshotTool:Activators:FlagBannerTownStatic extends SS2_ScreenshotTool:Activators:Flag

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
	CaptureModel(thisForm.FlagBannerTownStatic)
EndFunction