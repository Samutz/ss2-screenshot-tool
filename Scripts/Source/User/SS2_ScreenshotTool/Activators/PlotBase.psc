scriptname SS2_ScreenshotTool:Activators:PlotBase extends SS2_ScreenshotTool:Activators:Base

import WorkshopFramework:Library:DataStructures

Group PlotTypeKeywords
	Keyword Property SS2_PlotType_Agricultural Auto Const Mandatory
	Keyword Property SS2_PlotType_Commercial Auto Const Mandatory
	Keyword Property SS2_PlotType_Industrial Auto Const Mandatory
	Keyword Property SS2_PlotType_Martial Auto Const Mandatory
	Keyword Property SS2_PlotType_Municipal Auto Const Mandatory
	Keyword Property SS2_PlotType_Recreational Auto Const Mandatory
	Keyword Property SS2_PlotType_Residential Auto Const Mandatory
EndGroup

Group PlotTypeActivators
	WorldObject Property SS2_Plot_Agr_Activator Auto Const Mandatory
	WorldObject Property SS2_Plot_Com_Activator Auto Const Mandatory
	WorldObject Property SS2_Plot_Ind_Activator Auto Const Mandatory
	WorldObject Property SS2_Plot_Mar_Activator Auto Const Mandatory
	WorldObject Property SS2_Plot_Mun_Activator Auto Const Mandatory
	WorldObject Property SS2_Plot_Rec_Activator Auto Const Mandatory
	WorldObject Property SS2_Plot_Res_Activator Auto Const Mandatory
EndGroup

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
bool bMaxLevelPlan

Function Capture(SimSettlementsV2:Weapons:BuildingPlan thisPlan)
	CheckIndexing()

	if thisPlan.LevelPlansList != none
		
		string sFormkey = GetFormKey(thisPlan as Form)
		Log("Spawning Plan: "+sFormkey, false)

		WorldObject SS2_Plot_Activator = SS2_Plot_Agr_Activator

		if thisPlan.HasKeyWord(SS2_PlotType_Agricultural)
			SS2_Plot_Activator = SS2_Plot_Agr_Activator
		elseif thisPlan.HasKeyWord(SS2_PlotType_Commercial)
			SS2_Plot_Activator = SS2_Plot_Com_Activator
		elseif thisPlan.HasKeyWord(SS2_PlotType_Industrial)
			SS2_Plot_Activator = SS2_Plot_Ind_Activator
		elseif thisPlan.HasKeyWord(SS2_PlotType_Martial)
			SS2_Plot_Activator = SS2_Plot_Mar_Activator
		elseif thisPlan.HasKeyWord(SS2_PlotType_Municipal)
			SS2_Plot_Activator = SS2_Plot_Mun_Activator
		elseif thisPlan.HasKeyWord(SS2_PlotType_Recreational)
			SS2_Plot_Activator = SS2_Plot_Rec_Activator
		elseif thisPlan.HasKeyWord(SS2_PlotType_Residential)
			SS2_Plot_Activator = SS2_Plot_Res_Activator
		endIf

		SimSettlementsV2:ObjectReferences:SimPlot refPlot = WorkshopFramework:WSFW_API.CreateSettlementObject(SS2_Plot_Activator, refWorkshop, Self) as SimSettlementsV2:ObjectReferences:SimPlot

		while !refPlot.Is3DLoaded()
			Utility.Wait(1)
			;Log("refPlot: "+refPlot, false)
		endWhile

		int i = thisPlan.LevelPlansList.GetSize() - 1
		bMaxLevelPlan = true
		while i >= 0
			SimSettlementsV2:Weapons:BuildingLevelPlan thisLevelPlan = thisPlan.LevelPlansList.GetAt(i) as SimSettlementsV2:Weapons:BuildingLevelPlan
			if thisLevelPlan.iRequiredLevel > 0 && thisLevelPlan.iRequiredLevel < 4
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
				bMaxLevelPlan = false
			endIf
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
					if fTimer > 10
						Log(deleteMe[i] + " still not scrapped, moving")
						deleteMe[i].SetPosition(deleteMe[i].GetPositionX(), deleteMe[i].GetPositionY(), deleteMe[i].GetPositionZ()-1000)
						bSkip = true
					elseif fTimer > 7.5
						if fTimer == 7.5
							Log(deleteMe[i] + " still not scrapped, deleting")
						endif
						deleteMe[i].Delete()
					elseif fTimer > 5.0
						if fTimer == 5.0
							Log(deleteMe[i] + " still not scrapped, disabling")
						endif
						deleteMe[i].Disable(false)
					elseif fTimer > 2.5
						if fTimer == 2.5
							Log(deleteMe[i] + " still not scrapped, re-scrapping")
						endif
						refPlot.ScrapObject(deleteMe[i])
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
	if bMaxLevelPlan
		Log("Capturing building plan: "+GetFormKey(akSender.ParentBuildingPlan), false)
		questMain.TakeScreenshot(GetFormKey(akSender.ParentBuildingPlan))
	endIf

	;; capture as level plan
	Log("Capturing building level plan: "+GetFormKey(akSender.CurrentLevelPlan), false)
	questMain.TakeScreenshot(GetFormKey(akSender.CurrentLevelPlan))

	CleanStageItems(akSender)

	Utility.Wait(0.5)
	waitingBuildingLevelPlan = none
EndEvent