scriptname SS2_ScreenshotTool:Activators:PlotBase extends SS2_ScreenshotTool:Activators:Flag

import WorkshopFramework:Library:DataStructures

Group PlotSizeKeywords
	Keyword Property SS2_PlotSize_1x1 Auto Const Mandatory
	Keyword Property SS2_PlotSize_2x2 Auto Const Mandatory
	Keyword Property SS2_PlotSize_3x3 Auto Const Mandatory
	Keyword Property SS2_PlotSize_Int Auto Const Mandatory
EndGroup

Group PlotTypeKeywords
	Keyword Property SS2_PlotType_Agricultural Auto Const Mandatory
	Keyword Property SS2_PlotType_Commercial Auto Const Mandatory
	Keyword Property SS2_PlotType_Industrial Auto Const Mandatory
	Keyword Property SS2_PlotType_Martial Auto Const Mandatory
	Keyword Property SS2_PlotType_Municipal Auto Const Mandatory
	Keyword Property SS2_PlotType_Recreational Auto Const Mandatory
	Keyword Property SS2_PlotType_Residential Auto Const Mandatory
EndGroup

Group PlotActivators
	Activator Property SS2_Plot_Agricultural_1x1 Auto Const Mandatory
	Activator Property SS2_Plot_Agricultural_2x2 Auto Const Mandatory
	Activator Property SS2_Plot_Agricultural_3x3 Auto Const Mandatory
	Activator Property SS2_Plot_Agricultural_Int Auto Const Mandatory
	Activator Property SS2_Plot_Commercial_1x1 Auto Const Mandatory
	Activator Property SS2_Plot_Commercial_2x2 Auto Const Mandatory
	Activator Property SS2_Plot_Commercial_3x3 Auto Const Mandatory
	Activator Property SS2_Plot_Commercial_Int Auto Const Mandatory
	Activator Property SS2_Plot_Industrial_1x1 Auto Const Mandatory
	Activator Property SS2_Plot_Industrial_2x2 Auto Const Mandatory
	Activator Property SS2_Plot_Industrial_3x3 Auto Const Mandatory
	Activator Property SS2_Plot_Industrial_Int Auto Const Mandatory
	Activator Property SS2_Plot_Martial_1x1 Auto Const Mandatory
	Activator Property SS2_Plot_Martial_2x2 Auto Const Mandatory
	Activator Property SS2_Plot_Martial_3x3 Auto Const Mandatory
	Activator Property SS2_Plot_Martial_Int Auto Const Mandatory
	Activator Property SS2_Plot_Municipal_1x1 Auto Const Mandatory
	Activator Property SS2_Plot_Municipal_2x2 Auto Const Mandatory
	Activator Property SS2_Plot_Municipal_3x3 Auto Const Mandatory
	Activator Property SS2_Plot_Municipal_Int Auto Const Mandatory
	Activator Property SS2_Plot_Recreational_1x1 Auto Const Mandatory
	Activator Property SS2_Plot_Recreational_2x2 Auto Const Mandatory
	Activator Property SS2_Plot_Recreational_3x3 Auto Const Mandatory
	Activator Property SS2_Plot_Recreational_Int Auto Const Mandatory
	Activator Property SS2_Plot_Residential_1x1 Auto Const Mandatory
	Activator Property SS2_Plot_Residential_2x2 Auto Const Mandatory
	Activator Property SS2_Plot_Residential_3x3 Auto Const Mandatory
	Activator Property SS2_Plot_Residential_Int Auto Const Mandatory
EndGroup

string sLogPrefix = "PlotBase"
;/
; iSize: 1 = 1x1, 2 = 2x2, 3 = 3x3, 4 = Int
Function CaptureBuildingPlans(int iSize, string sAddonFilename = "")
	CheckIndexing()
	Log("CaptureBuildingPlans("+iSize+","+sAddonFilename+") called")

	questMain.FreezeState(true)

	SimSettlementsV2:Weapons:BuildingPlan[] indexedPlans = none

	if sAddonFilename != "" ; plugin specified
		IndexedAddon thisIndexedAddon = questMain.questIndexer.GetIndexedAddon(sAddonFilename)
		if iSize == 1
			indexedPlans = thisIndexedAddon.BuildingPlans1x1
		elseif iSize == 2
			indexedPlans = thisIndexedAddon.BuildingPlans2x2
		elseif iSize == 3
			indexedPlans = thisIndexedAddon.BuildingPlans3x3
		elseif iSize == 4
			indexedPlans = thisIndexedAddon.BuildingPlansInt
		else
			Debug.MessageBox("Invalid size: "+iSize)
			return
		endif
		int i = indexedPlans.Length - 1
		while i >= 0
			CaptureBuildingPlan(indexedPlans[i])
			i -= 1
		endWhile
	else ; no plugin specified, do all indexed items
		int j = indexedAddons.Length - 1
		while j >= 0
			if iSize == 1
				indexedPlans = indexedAddons[j].BuildingPlans1x1
			elseif iSize == 2
				indexedPlans = indexedAddons[j].BuildingPlans2x2
			elseif iSize == 3
				indexedPlans = indexedAddons[j].BuildingPlans3x3
			elseif iSize == 4
				indexedPlans = indexedAddons[j].BuildingPlansInt
			else
				Debug.MessageBox("Invalid size: "+iSize)
				return
			endif
			int i = indexedPlans.Length - 1
			while i >= 0
				CaptureBuildingPlan(indexedPlans[i])
				i -= 1
			endWhile
			j -= 1
		endWhile
	endIf

	questMain.FreezeState(false)
	Log("CaptureBuildingPlans("+iSize+", "+sAddonFilename+") complete")
	Debug.MessageBox("CaptureBuildingPlans("+iSize+", "+sAddonFilename+") complete")
EndFunction

Form waitingBuildingLevelPlan

Function Capture(Form thisForm)
	CheckIndexing()

	if !(thisForm as SimSettlementsV2:Weapons:BuildingPlan)
		Log("Form "+thisForm+" is not BuildingPlan: ")
		return
	endif

	SimSettlementsV2:Weapons:BuildingPlan thisPlan = thisForm as SimSettlementsV2:Weapons:BuildingPlan
	string sFormkey = GetFormKey(thisPlan)

	WorldObject woPlot = GetBuildingPlanPlotActivator(thisPlan)
	if woPlot == none
		Log("BuildingPlan is missing keywords: "+ thisPlan)
		return
	endIf
	
	SimSettlementsV2:ObjectReferences:SimPlot refPlot = WorkshopFramework:WSFW_API.CreateSettlementObject(woPlot, refWorkshop) as SimSettlementsV2:ObjectReferences:SimPlot

	int i = thisPlan.LevelPlansList.GetSize() - 1
	while i >= 0
		SimSettlementsV2:Weapons:BuildingLevelPlan thisLevelPlan = thisPlan.LevelPlansList.GetAt(i) as SimSettlementsV2:Weapons:BuildingLevelPlan
		refPlot.ForcedPlan = thisLevelPlan
		while !refPlot.bPostInitializationStepsComplete
			Utility.Wait(1)
		endWhile
		RegisterForCustomEvent(refPlot, "PlotLevelChanged")
		waitingBuildingLevelPlan = thisLevelPlan as Form
		refPlot.ForcePlotLevel(thisLevelPlan.iRequiredLevel, -1)
		while waitingBuildingLevelPlan != none
			Utility.Wait(1)
		endWhile
		i -= 1
	endWhile

	WorkshopFramework:WSFW_API.RemoveSettlementObject(refPlot)
	Utility.Wait(1)
EndFunction

Event SimSettlementsV2:ObjectReferences:SimPlot.PlotLevelChanged(SimSettlementsV2:ObjectReferences:SimPlot akSender, Var[] akArgs)
	UnregisterForCustomEvent(akSender, "PlotLevelChanged")
	SimSettlementsV2:Weapons:BuildingLevelPlan thisLevelPlan = waitingBuildingLevelPlan as SimSettlementsV2:Weapons:BuildingLevelPlan
	Log("Capturing building level plan: "+GetFormKey(thisLevelPlan))
	questMain.TakeScreenshot(GetFormKey(thisLevelPlan))
	if thisLevelPlan.iRequiredLevel == ((thisLevelPlan.ParentBuildingPlan as Form) as SimSettlementsV2:Weapons:BuildingPlan).LevelPlansList.GetSize()
		Log("Capturing building plan: "+GetFormKey(thisLevelPlan.ParentBuildingPlan))
		questMain.TakeScreenshot(GetFormKey(thisLevelPlan.ParentBuildingPlan))
	endIf
	Utility.Wait(1)
	waitingBuildingLevelPlan = none
EndEvent

WorldObject Function GetBuildingPlanPlotActivator(SimSettlementsV2:Weapons:BuildingPlan thisPlan)
	WorldObject thisPosition = none
	if thisPlan.HasKeyWord(SS2_PlotType_Agricultural) && thisPlan.HasKeyWord(SS2_PlotSize_1x1)
		thisPosition = Plot1x1Position
		thisPosition.ObjectForm = SS2_Plot_Agricultural_1x1
	elseif thisPlan.HasKeyWord(SS2_PlotType_Agricultural) && thisPlan.HasKeyWord(SS2_PlotSize_2x2)
		thisPosition = Plot2x2Position
		thisPosition.ObjectForm = SS2_Plot_Agricultural_2x2
	elseif thisPlan.HasKeyWord(SS2_PlotType_Agricultural) && thisPlan.HasKeyWord(SS2_PlotSize_3x3)
		thisPosition = Plot3x3Position
		thisPosition.ObjectForm = SS2_Plot_Agricultural_3x3
	elseif thisPlan.HasKeyWord(SS2_PlotType_Agricultural) && thisPlan.HasKeyWord(SS2_PlotSize_Int)
		thisPosition = PlotIntPosition
		thisPosition.ObjectForm = SS2_Plot_Agricultural_Int

	elseif thisPlan.HasKeyWord(SS2_PlotType_Commercial) && thisPlan.HasKeyWord(SS2_PlotSize_1x1)
		thisPosition = Plot1x1Position
		thisPosition.ObjectForm = SS2_Plot_Commercial_1x1
	elseif thisPlan.HasKeyWord(SS2_PlotType_Commercial) && thisPlan.HasKeyWord(SS2_PlotSize_2x2)
		thisPosition = Plot2x2Position
		thisPosition.ObjectForm = SS2_Plot_Commercial_2x2
	elseif thisPlan.HasKeyWord(SS2_PlotType_Commercial) && thisPlan.HasKeyWord(SS2_PlotSize_3x3)
		thisPosition = Plot3x3Position
		thisPosition.ObjectForm = SS2_Plot_Commercial_3x3
	elseif thisPlan.HasKeyWord(SS2_PlotType_Commercial) && thisPlan.HasKeyWord(SS2_PlotSize_Int)
		thisPosition = PlotIntPosition
		thisPosition.ObjectForm = SS2_Plot_Commercial_Int

	elseif thisPlan.HasKeyWord(SS2_PlotType_Industrial) && thisPlan.HasKeyWord(SS2_PlotSize_1x1)
		thisPosition = Plot1x1Position
		thisPosition.ObjectForm = SS2_Plot_Industrial_1x1
	elseif thisPlan.HasKeyWord(SS2_PlotType_Industrial) && thisPlan.HasKeyWord(SS2_PlotSize_2x2)
		thisPosition = Plot2x2Position
		thisPosition.ObjectForm = SS2_Plot_Industrial_2x2
	elseif thisPlan.HasKeyWord(SS2_PlotType_Industrial) && thisPlan.HasKeyWord(SS2_PlotSize_3x3)
		thisPosition = Plot3x3Position
		thisPosition.ObjectForm = SS2_Plot_Industrial_3x3
	elseif thisPlan.HasKeyWord(SS2_PlotType_Industrial) && thisPlan.HasKeyWord(SS2_PlotSize_Int)
		thisPosition = PlotIntPosition
		thisPosition.ObjectForm = SS2_Plot_Industrial_Int

	elseif thisPlan.HasKeyWord(SS2_PlotType_Martial) && thisPlan.HasKeyWord(SS2_PlotSize_1x1)
		thisPosition = Plot1x1Position
		thisPosition.ObjectForm = SS2_Plot_Martial_1x1
	elseif thisPlan.HasKeyWord(SS2_PlotType_Martial) && thisPlan.HasKeyWord(SS2_PlotSize_2x2)
		thisPosition = Plot2x2Position
		thisPosition.ObjectForm = SS2_Plot_Martial_2x2
	elseif thisPlan.HasKeyWord(SS2_PlotType_Martial) && thisPlan.HasKeyWord(SS2_PlotSize_3x3)
		thisPosition = Plot3x3Position
		thisPosition.ObjectForm = SS2_Plot_Martial_3x3
	elseif thisPlan.HasKeyWord(SS2_PlotType_Martial) && thisPlan.HasKeyWord(SS2_PlotSize_Int)
		thisPosition = PlotIntPosition
		thisPosition.ObjectForm = SS2_Plot_Martial_Int
		
	elseif thisPlan.HasKeyWord(SS2_PlotType_Municipal) && thisPlan.HasKeyWord(SS2_PlotSize_1x1)
		thisPosition = Plot1x1Position
		thisPosition.ObjectForm = SS2_Plot_Municipal_1x1
	elseif thisPlan.HasKeyWord(SS2_PlotType_Municipal) && thisPlan.HasKeyWord(SS2_PlotSize_2x2)
		thisPosition = Plot2x2Position
		thisPosition.ObjectForm = SS2_Plot_Municipal_2x2
	elseif thisPlan.HasKeyWord(SS2_PlotType_Municipal) && thisPlan.HasKeyWord(SS2_PlotSize_3x3)
		thisPosition = Plot3x3Position
		thisPosition.ObjectForm = SS2_Plot_Municipal_3x3
	elseif thisPlan.HasKeyWord(SS2_PlotType_Municipal) && thisPlan.HasKeyWord(SS2_PlotSize_Int)
		thisPosition = PlotIntPosition
		thisPosition.ObjectForm = SS2_Plot_Municipal_Int
		
	elseif thisPlan.HasKeyWord(SS2_PlotType_Recreational) && thisPlan.HasKeyWord(SS2_PlotSize_1x1)
		thisPosition = Plot1x1Position
		thisPosition.ObjectForm = SS2_Plot_Recreational_1x1
	elseif thisPlan.HasKeyWord(SS2_PlotType_Recreational) && thisPlan.HasKeyWord(SS2_PlotSize_2x2)
		thisPosition = Plot2x2Position
		thisPosition.ObjectForm = SS2_Plot_Recreational_2x2
	elseif thisPlan.HasKeyWord(SS2_PlotType_Recreational) && thisPlan.HasKeyWord(SS2_PlotSize_3x3)
		thisPosition = Plot3x3Position
		thisPosition.ObjectForm = SS2_Plot_Recreational_3x3
	elseif thisPlan.HasKeyWord(SS2_PlotType_Recreational) && thisPlan.HasKeyWord(SS2_PlotSize_Int)
		thisPosition = PlotIntPosition
		thisPosition.ObjectForm = SS2_Plot_Recreational_Int

	elseif thisPlan.HasKeyWord(SS2_PlotType_Residential) && thisPlan.HasKeyWord(SS2_PlotSize_1x1)
		thisPosition = Plot1x1Position
		thisPosition.ObjectForm = SS2_Plot_Residential_1x1
	elseif thisPlan.HasKeyWord(SS2_PlotType_Residential) && thisPlan.HasKeyWord(SS2_PlotSize_2x2)
		thisPosition = Plot2x2Position
		thisPosition.ObjectForm = SS2_Plot_Residential_2x2
	elseif thisPlan.HasKeyWord(SS2_PlotType_Residential) && thisPlan.HasKeyWord(SS2_PlotSize_3x3)
		thisPosition = Plot3x3Position
		thisPosition.ObjectForm = SS2_Plot_Residential_3x3
	elseif thisPlan.HasKeyWord(SS2_PlotType_Residential) && thisPlan.HasKeyWord(SS2_PlotSize_Int)
		thisPosition = PlotIntPosition
		thisPosition.ObjectForm = SS2_Plot_Residential_Int

	endif
	return thisPosition
EndFunction
/;
