scriptname SS2_ScreenshotTool:QuestScript extends Quest

Import SUP_F4SE
Import System:Form
Import System:Strings
Import GardenOfEden

import WorkshopFramework:Library:DataStructures
import WorkshopDataScript

Group General
	SimSettlementsV2:Quests:SS2Main Property SS2Main Auto Const Mandatory
	WorkshopScript Property refWorkshop Auto Const Mandatory
EndGroup

Group ScreenshotSettings
	Weather Property ClearWeather Auto Const Mandatory
	GlobalVariable Property GameHour Auto Mandatory
	float Property FreezeTime = 12.0 Auto Const
	float Property ImageWidth = 1920.0 Auto Const
	float Property ImageHeight = 1080.0 Auto Const
EndGroup

Group ObjectPositioning
	WorldObject Property FlagPosition Auto Const Mandatory
	WorldObject Property Plot1x1Position Auto Const Mandatory
	WorldObject Property Plot2x2Position Auto Const Mandatory
	WorldObject Property Plot3x3Position Auto Const Mandatory
	WorldObject Property PlotIntPosition Auto Const Mandatory
EndGroup

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

Actor refPlayer
string sLogName = "SS2_ScreenshotTool"
bool bIndexInProgress = false

IndexedAddon[] indexedAddons

Struct IndexedAddon
	string sAddonFilename
	SimSettlementsV2:Armors:ThemeDefinition_Flags[] Flags
	SimSettlementsV2:Weapons:BuildingPlan[] BuildingPlans1x1
	SimSettlementsV2:Weapons:BuildingPlan[] BuildingPlans2x2
	SimSettlementsV2:Weapons:BuildingPlan[] BuildingPlans3x3
	SimSettlementsV2:Weapons:BuildingPlan[] BuildingPlansInt
EndStruct

;; --------------------------------------------------
;; Setup
;; --------------------------------------------------

Event OnQuestInit()
	Debug.OpenUserLog(sLogName)
	Debug.TraceUser(sLogName, "Quest Started")
	refPlayer = Game.GetPlayer()
	RegisterForRemoteEvent(refPlayer, "OnPlayerLoadGame")
	StartUp()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akActorRef)
	Debug.OpenUserLog(sLogName)
	StartUp()
EndEvent

Function StartUp()
	while !SS2Main.bAddonProcessingComplete
		Debug.TraceUser(sLogName, "Waiting for SS2Main.bAddonProcessingComplete")
		Utility.Wait(1)
	endWhile
	IndexAddons(false)
EndFunction

;; --------------------------------------------------
;; Indexing Functions
;; --------------------------------------------------

Function IndexAddons(bool bForce)
	if indexedAddons == none || indexedAddons.Length == 0 || bForce == true
		Debug.TraceUser(sLogName, "Starting Indexing")
		bIndexInProgress = true
		indexedAddons = new IndexedAddon[0]

		int i = SS2Main.RegisteredAddonPacks.GetCount() - 1
		while i >= 0
			SimSettlementsV2:ObjectReferences:RegisteredAddonPack thisRegistration = SS2Main.RegisteredAddonPacks.GetAt(i) as SimSettlementsV2:ObjectReferences:RegisteredAddonPack
			if thisRegistration && thisRegistration.GetAddonPackConfig() != none
				IndexAddonConfig(thisRegistration.GetAddonPackConfig())
				i -= 1
			endIf
		endWhile

		bIndexInProgress = false
		Debug.TraceUser(sLogName, "Finished Indexing")
	else
		Debug.TraceUser(sLogName, "Index already populated")
	endIf
EndFunction

Function IndexAddonConfig(SimSettlementsV2:MiscObjects:AddonPackConfiguration thisConfig)
	if thisConfig.MyItems == none || thisConfig.sAddonFilename == ""
		return
	endIf
	int i = thisConfig.MyItems.Length - 1
	while i >= 0
		IndexAddonItemList(thisConfig.MyItems[i])
		i -= 1
	endWhile
EndFunction

Function IndexAddonItemList(FormList thisList)
	int i = thisList.GetSize() - 1
	while i >= 0
		IndexAddonItem(thisList.GetAt(i))
		i -= 1
	endWhile
EndFunction

Function IndexAddonItem(Form thisItem)
	string sAddonFilename = GetModName(thisItem)
	IndexedAddon thisIndexedAddon = GetIndexedAddon(sAddonFilename)

	; unlockable flags
	if thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag && (thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag).FlagThemeDefinition != none
		IndexAddonItem((thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag).FlagThemeDefinition)
	
	; flags
	; several non-flag scripts extend from ThemeDefinition_Flags, so we need to filter them out
	elseif thisItem as SimSettlementsV2:Armors:ThemeDefinition_Flags && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_EmpireFlags) && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_Holiday) && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_DecorationSet)
		SimSettlementsV2:Armors:ThemeDefinition_Flags thisItem2 = thisItem as SimSettlementsV2:Armors:ThemeDefinition_Flags
		thisIndexedAddon.Flags.Add(thisItem2)
		Debug.TraceUser(sLogName, "Added Flag "+thisItem2+" to "+sAddonFilename+"'s index")

	; unlockable buildingplan
	elseif thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan && (thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan).BuildingPlan != none
		IndexAddonItem((thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan).BuildingPlan)

	; buildingplan
	elseif thisItem as SimSettlementsV2:Weapons:BuildingPlan
		SimSettlementsV2:Weapons:BuildingPlan thisItem2 = thisItem as SimSettlementsV2:Weapons:BuildingPlan
		if thisItem2.HasKeyword(SS2_PlotSize_1x1)
			thisIndexedAddon.BuildingPlans1x1.Add(thisItem2)
		elseif thisItem2.HasKeyword(SS2_PlotSize_2x2)
			thisIndexedAddon.BuildingPlans2x2.Add(thisItem2)
		elseif thisItem2.HasKeyword(SS2_PlotSize_3x3)
			thisIndexedAddon.BuildingPlans3x3.Add(thisItem2)
		elseif thisItem2.HasKeyword(SS2_PlotSize_Int)
			thisIndexedAddon.BuildingPlansInt.Add(thisItem2)
		else
			thisItem2 = none
		endif
		if thisItem2 != none
			Debug.TraceUser(sLogName, "Added BuildingPlan "+thisItem2+" to "+sAddonFilename+"'s index")
		endIf
	endIf
EndFunction

IndexedAddon Function GetIndexedAddon(string sAddonFilename)
	IndexedAddon thisIndexedAddon = new IndexedAddon
	int index = indexedAddons.FindStruct("sAddonFilename", sAddonFilename)
	if index < 0
		thisIndexedAddon = new IndexedAddon
		thisIndexedAddon.sAddonFilename = sAddonFilename
		thisIndexedAddon.Flags = new SimSettlementsV2:Armors:ThemeDefinition_Flags[0]
		thisIndexedAddon.BuildingPlans1x1 = new SimSettlementsV2:Weapons:BuildingPlan[0]
		thisIndexedAddon.BuildingPlans2x2 = new SimSettlementsV2:Weapons:BuildingPlan[0]
		thisIndexedAddon.BuildingPlans3x3 = new SimSettlementsV2:Weapons:BuildingPlan[0]
		thisIndexedAddon.BuildingPlansInt = new SimSettlementsV2:Weapons:BuildingPlan[0]
		indexedAddons.Add(thisIndexedAddon)
		Debug.TraceUser(sLogName, "Added Addon "+sAddonFilename+" to index")
	else
		thisIndexedAddon = indexedAddons[index]
	endIf
	return thisIndexedAddon
EndFunction

;; --------------------------------------------------
;; Capture Functions
;; --------------------------------------------------

;; Flags

Function CaptureFlags(string sAddonFilename = "")
	if bIndexInProgress
		Debug.MessageBox("Indexing is still running")
		return
	endIf

	Debug.TraceUser(sLogName, "CaptureFlags("+sAddonFilename+") called")

	FreezeState(true)

	if sAddonFilename != "" ; plugin specified
		IndexedAddon thisIndexedAddon = GetIndexedAddon(sAddonFilename)
		int i = thisIndexedAddon.Flags.Length - 1
		while i >= 0
			CaptureFlag(thisIndexedAddon.Flags[i])
			i -= 1
		endWhile
	else ; no plugin specified, do all indexed flags
		int j = indexedAddons.Length - 1
		while j >= 0
			int i = indexedAddons[j].Flags.Length - 1
			while i >= 0
				CaptureFlag(indexedAddons[j].Flags[i])
				i -= 1
			endWhile
			j -= 1
		endWhile
	endIf

	FreezeState(false)
	Debug.TraceUser(sLogName, "CaptureFlags("+sAddonFilename+") complete")
	Debug.MessageBox("CaptureFlags("+sAddonFilename+") complete")
EndFunction

Function CaptureFlag(SimSettlementsV2:Armors:ThemeDefinition_Flags thisForm)
	if bIndexInProgress
		Debug.MessageBox("Indexing is still running")
		return
	endIf

	if thisForm.FlagWall != none
		string sFormkey = GetFormKey(thisForm)
		Debug.TraceUser(sLogName, "Capturing flag: "+sFormkey)

		WorldObject thisPosition = FlagPosition
		thisPosition.ObjectForm = thisForm.FlagWall

		ObjectReference refFlag = WorkshopFramework:WSFW_API.CreateSettlementObject(thisPosition, refWorkshop)
		TakeScreenshot(sFormkey)
		WorkshopFramework:WSFW_API.RemoveSettlementObject(refFlag)
		Utility.Wait(1)
	else
		Debug.TraceUser(sLogName, "Flag is missing FlagWall property: "+thisForm)
	endIf
EndFunction

;; Building Plans

; iSize: 1 = 1x1, 2 = 2x2, 3 = 3x3, 4 = Int
Function CaptureBuildingPlans(int iSize, string sAddonFilename = "")
	if bIndexInProgress
		Debug.MessageBox("Indexing is still running")
		return
	endIf
	Debug.TraceUser(sLogName, "CaptureBuildingPlans("+iSize+","+sAddonFilename+") called")

	FreezeState(true)

	SimSettlementsV2:Weapons:BuildingPlan[] indexedPlans = none

	if sAddonFilename != "" ; plugin specified
		IndexedAddon thisIndexedAddon = GetIndexedAddon(sAddonFilename)
		if iSize == 1
			indexedPlans = thisIndexedAddon.BuildingPlans1x1
		elseif iSize == 2
			indexedPlans = thisIndexedAddon.BuildingPlans2x2
		elseif iSize == 2
			indexedPlans = thisIndexedAddon.BuildingPlans3x3
		elseif iSize == 2
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
	else ; no plugin specified, do all indexed flags
		int j = indexedAddons.Length - 1
		while j >= 0
			if iSize == 1
				indexedPlans = indexedAddons[j].BuildingPlans1x1
			elseif iSize == 2
				indexedPlans = indexedAddons[j].BuildingPlans2x2
			elseif iSize == 2
				indexedPlans = indexedAddons[j].BuildingPlans3x3
			elseif iSize == 2
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

	FreezeState(false)
	Debug.TraceUser(sLogName, "CaptureBuildingPlans("+iSize+", "+sAddonFilename+") complete")
	Debug.MessageBox("CaptureBuildingPlans("+iSize+", "+sAddonFilename+") complete")
EndFunction

Form waitingBuildingLevelPlan

Function CaptureBuildingPlan(Form thisForm)
	if bIndexInProgress
		Debug.MessageBox("Indexing is still running")
		return
	endIf

	if !(thisForm as SimSettlementsV2:Weapons:BuildingPlan)
		Debug.TraceUser(sLogName, "Form "+thisForm+" is not BuildingPlan: ")
		return
	endif

	SimSettlementsV2:Weapons:BuildingPlan thisPlan = thisForm as SimSettlementsV2:Weapons:BuildingPlan
	string sFormkey = GetFormKey(thisPlan)

	WorldObject woPlot = GetBuildingPlanPlotActivator(thisPlan)
	if woPlot == none
		Debug.TraceUser(sLogName, "BuildingPlan is missing keywords: "+ thisPlan)
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
	Debug.TraceUser(sLogName, "Capturing building level plan: "+GetFormKey(thisLevelPlan))
	TakeScreenshot(GetFormKey(thisLevelPlan))
	if thisLevelPlan.iRequiredLevel == ((thisLevelPlan.ParentBuildingPlan as Form) as SimSettlementsV2:Weapons:BuildingPlan).LevelPlansList.GetSize()
		Debug.TraceUser(sLogName, "Capturing building plan: "+GetFormKey(thisLevelPlan.ParentBuildingPlan))
		TakeScreenshot(GetFormKey(thisLevelPlan.ParentBuildingPlan))
	endIf
	Utility.Wait(1)
	waitingBuildingLevelPlan = none
EndEvent


;; --------------------------------------------------
;; Screenshot Functions
;; --------------------------------------------------

Function FreezeState(bool freeze)
	; not sure if this actually works
	if freeze
		Debug.SetGodMode(true)
		Utility.SetINIBool("bDisableAllAI:General", true)
		GameHour.SetValue(FreezeTime)
		ClearWeather.ForceActive()
	else
		Debug.SetGodMode(false)
		Utility.SetINIBool("bDisableAllAI:General", false)
	endIf
EndFunction

Function TakeScreenshot(string name)
    GameHour.SetValue(FreezeTime)
    ClearWeather.ForceActive()
    Utility.Wait(0.1)
    CaptureScreenshotAlt(sLogName, name+".jpg", 0, ImageWidth, 0, ImageHeight, 0, 100)
EndFunction

;; --------------------------------------------------
;; Miscellaneous Functions
;; --------------------------------------------------

string Function GetObjRefFormKey(ObjectReference objRef)
	return GetFormKey(objRef.GetBaseObject())
EndFunction

string Function GetFormKey(Form formObj)
	string hexID = GetHexFormID(formObj)
	if StartsWith(hexID, "FE")
		hexID = "000"+Substring(hexID, 5)
	else
		hexID = Substring(hexID, 2)
	endIf
	string modName = GetModName(formObj)
	string result = hexID+"-"+modName
	return result
EndFunction

; there HAS to be a better way to do this...
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