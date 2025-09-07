scriptname SS2_ScreenshotTool:Activators:PlotBase extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

WorldObject Property SS2_Plot_Activator Auto Const Mandatory
FormList Property Index_FormList Auto Const Mandatory

string sLogPrefix = "Activators:PlotBase"

Function LogCount()
	Log("Plan Count: "+Index_FormList.GetSize())
EndFunction

Function SetSourceFormList()
	sourceFormList = Index_FormList
EndFunction

Function BatchCapture()
	CheckIndexing()

	Disable()

	bCaptureStage = 2

	Log("BatchCapture() called")

	questMain.FreezeState(true)

	int i = questMain.ItemsToCaptureFormList.GetSize() - 1
	while i >= 0 && bCaptureStage == 2
		Log((i+1)+" remaining")
		Capture(questMain.ItemsToCaptureFormList.GetAt(i) as SimSettlementsV2:Weapons:BuildingPlan)
		i -= 1
	endWhile

	questMain.FreezeState(false)
	bCaptureStage = 0

	Enable()

	Log("BatchCapture() complete")
	Debug.MessageBox("BatchCapture() complete")
EndFunction

Form waitingBuildingLevelPlan

Function Capture(SimSettlementsV2:Weapons:BuildingPlan thisPlan)
	CheckIndexing()

	if thisPlan.LevelPlansList != none
		
		string sFormkey = GetFormKey(thisPlan as Form)
		Log("Spawning Plan: "+sFormkey, false)

		SimSettlementsV2:ObjectReferences:SimPlot refPlot = WorkshopFramework:WSFW_API.CreateSettlementObject(SS2_Plot_Activator, refWorkshop, Self) as SimSettlementsV2:ObjectReferences:SimPlot

		while !refPlot.Is3DLoaded()
			Utility.Wait(1)
			;Log("refPlot: "+refPlot, false)
		endWhile

		;int i = thisPlan.LevelPlansList.GetSize() - 1
		int i = 2
		while i >= 0
			SimSettlementsV2:Weapons:BuildingLevelPlan thisLevelPlan = thisPlan.LevelPlansList.GetAt(i) as SimSettlementsV2:Weapons:BuildingLevelPlan
			refPlot.ForcedPlan = thisLevelPlan
			while !refPlot.bPostInitializationStepsComplete
				Utility.Wait(0.1)
			endWhile
			RegisterForCustomEvent(refPlot, "PlotLevelChanged")
			waitingBuildingLevelPlan = thisLevelPlan as Form
			refPlot.ForcePlotLevel(thisLevelPlan.iRequiredLevel, -1)
			while waitingBuildingLevelPlan != none
				Utility.Wait(0.1)
			endWhile
			i -= 1
		endWhile

		WorkshopFramework:WSFW_API.RemoveSettlementObject(refPlot)
		Utility.Wait(0.5)
	else
		Log("Plan is missing LevelPlansList property: "+thisPlan, false)
	endIf
EndFunction

Function CleanStageItems(SimSettlementsV2:ObjectReferences:SimPlot refPlot)
	Keyword[] linkKeywords = new Keyword[3]
	linkKeywords[0] = refPlot.StageItemLinkKeyword
	linkKeywords[1] = refPlot.StageModelLinkKeyword
	linkKeywords[2] = refPlot.AccessoryLinkKeyword
	;MultiStageItemKeyword
	;SecondaryAssignmentMarkerLinkKeyword
	;IndicatorLinkKeyword

	int i = 0
	ObjectReference[] deleteMe = none

	int j = linkKeywords.Length
	float fTimer = 0.0
	bool bSkip
	while j >= 0
		deleteMe = refPlot.kLinkedRefHolder.GetLinkedRefChildren(linkKeywords[j])

		i = deleteMe.Length
		while i >= 0
			if deleteMe[i] != none
				fTimer = 0.0
				bSkip = false
				refPlot.ScrapObject(deleteMe[i])
				while deleteMe[i].Is3DLoaded() && !bSkip
					Utility.Wait(0.1)
					fTimer += 0.1
					;Log("waiting for linked ref to scrap: "+deleteMe[i])
					if (fTimer >= 10.0)
						deleteMe[i].Disable(false)
						Log(deleteMe[i] + " not scrapped, disabling")
					endif
					if (fTimer >= 20.0)
						deleteMe[i].Delete()
						Log(deleteMe[i] + " not scrapped, deleting")
					endif
					if (fTimer >= 30.0)
						bSkip = true
						Log(deleteMe[i] + " not scrapped, skipping")
					endif
				endWhile
			endIf
			i -= 1
		endWhile
		j -= 1
	endWhile
EndFunction

Event SimSettlementsV2:ObjectReferences:SimPlot.PlotLevelChanged(SimSettlementsV2:ObjectReferences:SimPlot akSender, Var[] akArgs)
	UnregisterForCustomEvent(akSender, "PlotLevelChanged")
	SimSettlementsV2:Weapons:BuildingLevelPlan thisLevelPlan = waitingBuildingLevelPlan as SimSettlementsV2:Weapons:BuildingLevelPlan

	;; capture as parent plan
	if thisLevelPlan.iRequiredLevel == ((thisLevelPlan.ParentBuildingPlan as Form) as SimSettlementsV2:Weapons:BuildingPlan).LevelPlansList.GetSize()
		Log("Capturing building plan: "+GetFormKey(thisLevelPlan.ParentBuildingPlan), false)
		questMain.TakeScreenshot(GetFormKey(thisLevelPlan.ParentBuildingPlan))
	endIf

	;; capture as level plan
	Log("Capturing building level plan: "+GetFormKey(thisLevelPlan), false)
	questMain.TakeScreenshot(GetFormKey(thisLevelPlan))

	CleanStageItems(akSender)

	Utility.Wait(0.5)
	waitingBuildingLevelPlan = none
EndEvent