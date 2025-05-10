scriptname SS2_ScreenshotTool:Quests:Indexer extends Quest

import WorkshopFramework:Library:DataStructures

Group General
    SS2_ScreenshotTool:Quests:Main Property questMain Auto Const Mandatory
EndGroup

Group PlotSizeKeywords
	Keyword Property SS2_PlotSize_1x1 Auto Const Mandatory
	Keyword Property SS2_PlotSize_2x2 Auto Const Mandatory
	Keyword Property SS2_PlotSize_3x3 Auto Const Mandatory
	Keyword Property SS2_PlotSize_Int Auto Const Mandatory
EndGroup

bool Property bIndexInProgress = false Auto Hidden

IndexedAddon[] Property indexedAddons Auto Hidden

Struct IndexedAddon
	string sAddonFilename
	SimSettlementsV2:Armors:ThemeDefinition_Flags[] Flags
	SimSettlementsV2:Weapons:BuildingPlan[] BuildingPlans1x1
	SimSettlementsV2:Weapons:BuildingPlan[] BuildingPlans2x2
	SimSettlementsV2:Weapons:BuildingPlan[] BuildingPlans3x3
	SimSettlementsV2:Weapons:BuildingPlan[] BuildingPlansInt
	SimSettlementsV2:MiscObjects:Foundation[] Foundations
EndStruct

Actor refPlayer

;; --------------------------------------------------
;; Setup
;; --------------------------------------------------

Event OnQuestInit()
	Log("Indexer Quest Started")
	refPlayer = Game.GetPlayer()
	RegisterForRemoteEvent(refPlayer, "OnPlayerLoadGame")
	StartUp()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akActorRef)
	StartUp()
EndEvent

Function StartUp()
	while !questMain.SS2Main.bAddonProcessingComplete
		Log("Waiting for SS2Main.bAddonProcessingComplete")
		Utility.Wait(1)
	endWhile
	IndexAddons(false)
EndFunction

Function Log(string sMessage)
	questMain.Log("[Indexer] "+sMessage)
EndFunction

;; --------------------------------------------------
;; Indexing Functions
;; --------------------------------------------------

Function IndexAddons(bool bForce)
	if indexedAddons == none || indexedAddons.Length == 0 || bForce == true
		Log("Starting Indexing")
		bIndexInProgress = true
		indexedAddons = new IndexedAddon[0]

		int i = questMain.SS2Main.RegisteredAddonPacks.GetCount() - 1
		while i >= 0
			SimSettlementsV2:ObjectReferences:RegisteredAddonPack thisRegistration = questMain.SS2Main.RegisteredAddonPacks.GetAt(i) as SimSettlementsV2:ObjectReferences:RegisteredAddonPack
			if thisRegistration && thisRegistration.GetAddonPackConfig() != none
				IndexAddonConfig(thisRegistration.GetAddonPackConfig())
				i -= 1
			endIf
		endWhile

		bIndexInProgress = false
		Log("Finished Indexing")
		Debug.MessageBox("Finished Indexing")
	else
		Log("Index already populated")
		Debug.MessageBox("Index already populated")
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
	string sAddonFilename = System:Form.GetModName(thisItem)
	IndexedAddon thisIndexedAddon = GetIndexedAddon(sAddonFilename)

	; unlockable flags
	if thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag && (thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag).FlagThemeDefinition != none
		IndexAddonItem((thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag).FlagThemeDefinition)
	
	; flags
	; several non-flag scripts extend from ThemeDefinition_Flags, so we need to filter them out
	elseif thisItem as SimSettlementsV2:Armors:ThemeDefinition_Flags && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_EmpireFlags) && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_Holiday) && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_DecorationSet)
		SimSettlementsV2:Armors:ThemeDefinition_Flags thisItem2 = thisItem as SimSettlementsV2:Armors:ThemeDefinition_Flags
		thisIndexedAddon.Flags.Add(thisItem2)
		Log("Added Flag "+thisItem2+" to "+sAddonFilename+"'s index")

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
			Log("Added BuildingPlan "+thisItem2+" to "+sAddonFilename+"'s index")
		endIf

	; foundations
	elseif thisItem as SimSettlementsV2:MiscObjects:Foundation
		SimSettlementsV2:MiscObjects:Foundation thisItem2 = thisItem as SimSettlementsV2:MiscObjects:Foundation
		thisIndexedAddon.Foundations.Add(thisItem2)
		Log("Added Foundation "+thisItem2+" to "+sAddonFilename+"'s index")

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
		thisIndexedAddon.Foundations = new SimSettlementsV2:MiscObjects:Foundation[0]
		indexedAddons.Add(thisIndexedAddon)
		Log("Added Addon "+sAddonFilename+" to index")
	else
		thisIndexedAddon = indexedAddons[index]
	endIf
	return thisIndexedAddon
EndFunction