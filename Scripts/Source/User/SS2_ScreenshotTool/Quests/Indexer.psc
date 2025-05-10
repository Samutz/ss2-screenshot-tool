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

Group PlotTypeKeywords
	Keyword Property SS2_PlotType_Agricultural Auto Const Mandatory
	Keyword Property SS2_PlotType_Commercial Auto Const Mandatory
	Keyword Property SS2_PlotType_Industrial Auto Const Mandatory
	Keyword Property SS2_PlotType_Martial Auto Const Mandatory
	Keyword Property SS2_PlotType_Municipal Auto Const Mandatory
	Keyword Property SS2_PlotType_Recreational Auto Const Mandatory
	Keyword Property SS2_PlotType_Residential Auto Const Mandatory
EndGroup

Group IndexFormLists
	FormList Property SS2SST_Index_Flags Auto Mandatory
	FormList Property SS2SST_Index_Foundations Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Agricultural_1x1 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Agricultural_2x2 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Agricultural_3x3 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Agricultural_Int Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Commercial_1x1 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Commercial_2x2 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Commercial_3x3 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Commercial_Int Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Industrial_1x1 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Industrial_2x2 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Industrial_3x3 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Industrial_Int Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Martial_1x1 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Martial_2x2 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Martial_3x3 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Martial_Int Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Municipal_1x1 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Municipal_2x2 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Municipal_3x3 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Municipal_Int Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Recreational_1x1 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Recreational_2x2 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Recreational_3x3 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Recreational_Int Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Residential_1x1 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Residential_2x2 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Residential_3x3 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Residential_Int Auto Mandatory
EndGroup

bool Property bIndexInProgress = false Auto Hidden

int Property iIndexedItemCount = 0 Auto Hidden

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
	IndexAddons(false)
EndFunction

Function Log(string sMessage)
	questMain.Log("[Indexer] "+sMessage)
EndFunction

;; --------------------------------------------------
;; Indexing Functions
;; --------------------------------------------------

Function IndexAddons(bool bForce)
	if iIndexedItemCount == 0 || bForce == true
		
		while !questMain.SS2Main.bAddonProcessingComplete
			Log("Waiting for SS2Main.bAddonProcessingComplete")
			Utility.Wait(1)
		endWhile

		Log("Starting Indexing")
		bIndexInProgress = true
		RevertAll()

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
	Log("Checking "+thisConfig.sAddonFilename)
	int i = thisConfig.MyItems.Length - 1
	while i >= 0
		IndexAddonItemList(thisConfig.MyItems[i])
		i -= 1
	endWhile
EndFunction

Function IndexAddonItemList(FormList thisList)
	if thisList.GetAt(0) != none	
		Log("List: "+thisList.GetAt(0))
	endIf
	int i = thisList.GetSize() - 1
	while i >= 0
		IndexAddonItem(thisList.GetAt(i))
		i -= 1
	endWhile
EndFunction

Function IndexAddonItem(Form thisItem)
	string sAddonFilename = System:Form.GetModName(thisItem)

	; unlockable flags
	if thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag && (thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag).FlagThemeDefinition != none
		IndexAddonItem((thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag).FlagThemeDefinition)
	; flags
	; several non-flag scripts extend from ThemeDefinition_Flags, so we need to filter them out
	elseif thisItem as SimSettlementsV2:Armors:ThemeDefinition_Flags && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_EmpireFlags) && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_Holiday) && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_DecorationSet)
		SimSettlementsV2:Armors:ThemeDefinition_Flags thisItem2 = thisItem as SimSettlementsV2:Armors:ThemeDefinition_Flags
		SS2SST_Index_Flags.AddForm(thisItem2)
		iIndexedItemCount += 1
		Log("Added Flag "+thisItem2+" from "+sAddonFilename)

	; unlockable buildingplan
	elseif thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan && (thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan).BuildingPlan != none
		IndexAddonItem((thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan).BuildingPlan)

	; buildingplan
	elseif thisItem as SimSettlementsV2:Weapons:BuildingPlan
		SimSettlementsV2:Weapons:BuildingPlan thisItem2 = thisItem as SimSettlementsV2:Weapons:BuildingPlan
		IndexBuildingPlan(thisItem2)
		if thisItem2 != none
			Log("Added BuildingPlan "+thisItem2+" from "+sAddonFilename)
		endIf

	; foundations
	elseif thisItem as SimSettlementsV2:MiscObjects:Foundation
		SimSettlementsV2:MiscObjects:Foundation thisItem2 = thisItem as SimSettlementsV2:MiscObjects:Foundation
		SS2SST_Index_Foundations.AddForm(thisItem2)
		iIndexedItemCount += 1
		Log("Added Foundation "+thisItem2+" from "+sAddonFilename)

	endIf
EndFunction

Function IndexBuildingPlan(SimSettlementsV2:Weapons:BuildingPlan thisItem)
	if thisItem.HasKeyWord(SS2_PlotType_Agricultural) && thisItem.HasKeyWord(SS2_PlotSize_1x1)
		SS2SST_Index_BuildingPlans_Agricultural_1x1.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Agricultural) && thisItem.HasKeyWord(SS2_PlotSize_2x2)
		SS2SST_Index_BuildingPlans_Agricultural_2x2.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Agricultural) && thisItem.HasKeyWord(SS2_PlotSize_3x3)
		SS2SST_Index_BuildingPlans_Agricultural_3x3.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Agricultural) && thisItem.HasKeyWord(SS2_PlotSize_Int)
		SS2SST_Index_BuildingPlans_Agricultural_Int.AddForm(thisItem)

	elseif thisItem.HasKeyWord(SS2_PlotType_Commercial) && thisItem.HasKeyWord(SS2_PlotSize_1x1)
		SS2SST_Index_BuildingPlans_Commercial_1x1.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Commercial) && thisItem.HasKeyWord(SS2_PlotSize_2x2)
		SS2SST_Index_BuildingPlans_Commercial_2x2.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Commercial) && thisItem.HasKeyWord(SS2_PlotSize_3x3)
		SS2SST_Index_BuildingPlans_Commercial_3x3.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Commercial) && thisItem.HasKeyWord(SS2_PlotSize_Int)
		SS2SST_Index_BuildingPlans_Commercial_Int.AddForm(thisItem)

	elseif thisItem.HasKeyWord(SS2_PlotType_Industrial) && thisItem.HasKeyWord(SS2_PlotSize_1x1)
		SS2SST_Index_BuildingPlans_Industrial_1x1.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Industrial) && thisItem.HasKeyWord(SS2_PlotSize_2x2)
		SS2SST_Index_BuildingPlans_Industrial_2x2.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Industrial) && thisItem.HasKeyWord(SS2_PlotSize_3x3)
		SS2SST_Index_BuildingPlans_Industrial_3x3.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Industrial) && thisItem.HasKeyWord(SS2_PlotSize_Int)
		SS2SST_Index_BuildingPlans_Industrial_Int.AddForm(thisItem)

	elseif thisItem.HasKeyWord(SS2_PlotType_Martial) && thisItem.HasKeyWord(SS2_PlotSize_1x1)
		SS2SST_Index_BuildingPlans_Martial_1x1.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Martial) && thisItem.HasKeyWord(SS2_PlotSize_2x2)
		SS2SST_Index_BuildingPlans_Martial_2x2.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Martial) && thisItem.HasKeyWord(SS2_PlotSize_3x3)
		SS2SST_Index_BuildingPlans_Martial_3x3.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Martial) && thisItem.HasKeyWord(SS2_PlotSize_Int)
		SS2SST_Index_BuildingPlans_Martial_Int.AddForm(thisItem)

	elseif thisItem.HasKeyWord(SS2_PlotType_Recreational) && thisItem.HasKeyWord(SS2_PlotSize_1x1)
		SS2SST_Index_BuildingPlans_Recreational_1x1.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Recreational) && thisItem.HasKeyWord(SS2_PlotSize_2x2)
		SS2SST_Index_BuildingPlans_Recreational_2x2.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Recreational) && thisItem.HasKeyWord(SS2_PlotSize_3x3)
		SS2SST_Index_BuildingPlans_Recreational_3x3.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Recreational) && thisItem.HasKeyWord(SS2_PlotSize_Int)
		SS2SST_Index_BuildingPlans_Recreational_Int.AddForm(thisItem)

	elseif thisItem.HasKeyWord(SS2_PlotType_Residential) && thisItem.HasKeyWord(SS2_PlotSize_1x1)
		SS2SST_Index_BuildingPlans_Residential_1x1.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Residential) && thisItem.HasKeyWord(SS2_PlotSize_2x2)
		SS2SST_Index_BuildingPlans_Residential_2x2.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Residential) && thisItem.HasKeyWord(SS2_PlotSize_3x3)
		SS2SST_Index_BuildingPlans_Residential_3x3.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotType_Residential) && thisItem.HasKeyWord(SS2_PlotSize_Int)
		SS2SST_Index_BuildingPlans_Residential_Int.AddForm(thisItem)

	endif
EndFunction

Function RevertAll()
	SS2SST_Index_Flags.Revert()
	SS2SST_Index_Foundations.Revert()
	SS2SST_Index_BuildingPlans_Agricultural_1x1.Revert()
	SS2SST_Index_BuildingPlans_Agricultural_2x2.Revert()
	SS2SST_Index_BuildingPlans_Agricultural_3x3.Revert()
	SS2SST_Index_BuildingPlans_Agricultural_Int.Revert()
	SS2SST_Index_BuildingPlans_Commercial_1x1.Revert()
	SS2SST_Index_BuildingPlans_Commercial_2x2.Revert()
	SS2SST_Index_BuildingPlans_Commercial_3x3.Revert()
	SS2SST_Index_BuildingPlans_Commercial_Int.Revert()
	SS2SST_Index_BuildingPlans_Industrial_1x1.Revert()
	SS2SST_Index_BuildingPlans_Industrial_2x2.Revert()
	SS2SST_Index_BuildingPlans_Industrial_3x3.Revert()
	SS2SST_Index_BuildingPlans_Industrial_Int.Revert()
	SS2SST_Index_BuildingPlans_Martial_1x1.Revert()
	SS2SST_Index_BuildingPlans_Martial_2x2.Revert()
	SS2SST_Index_BuildingPlans_Martial_3x3.Revert()
	SS2SST_Index_BuildingPlans_Martial_Int.Revert()
	SS2SST_Index_BuildingPlans_Municipal_1x1.Revert()
	SS2SST_Index_BuildingPlans_Municipal_2x2.Revert()
	SS2SST_Index_BuildingPlans_Municipal_3x3.Revert()
	SS2SST_Index_BuildingPlans_Municipal_Int.Revert()
	SS2SST_Index_BuildingPlans_Recreational_1x1.Revert()
	SS2SST_Index_BuildingPlans_Recreational_2x2.Revert()
	SS2SST_Index_BuildingPlans_Recreational_3x3.Revert()
	SS2SST_Index_BuildingPlans_Recreational_Int.Revert()
	SS2SST_Index_BuildingPlans_Residential_1x1.Revert()
	SS2SST_Index_BuildingPlans_Residential_2x2.Revert()
	SS2SST_Index_BuildingPlans_Residential_3x3.Revert()
	SS2SST_Index_BuildingPlans_Residential_Int.Revert()
EndFunction