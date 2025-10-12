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

Group IndexFormLists
	FormList Property SS2SST_Index_Flags Auto Mandatory
	FormList Property SS2SST_Index_Foundations Auto Mandatory
	FormList Property SS2SST_Index_PowerPoles Auto Mandatory
	FormList Property SS2SST_Index_Furniture Auto Mandatory
	FormList Property SS2SST_Index_UniqueSettlers Auto Mandatory
	FormList Property SS2SST_Index_Pets Auto Mandatory
EndGroup

Group IndexFormListsBuildingPlans
	FormList Property SS2SST_Index_BuildingPlans_Agricultural_1x1 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Agricultural_2x2 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Agricultural_3x3 Auto Mandatory
	FormList Property SS2SST_Index_BuildingPlans_Agricultural_Int Auto Mandatory
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

Function ReIndex()
	IndexAddons(true)
EndFunction

Function IndexAddons(bool bForce)
	if iIndexedItemCount == 0 || bForce == true
		
		int j = 0
		while !questMain.SS2Main.bAddonProcessingComplete
			if j % 5 == 0
				Log("Waiting for SS2Main.bAddonProcessingComplete")
			endIf
			Utility.Wait(1)
			j += 1
		endWhile

		Log("Starting Indexing")
		bIndexInProgress = true
		RevertAll()

		int i = questMain.SS2Main.RegisteredAddonPacks.GetCount() - 1
		while i >= 0
			Log(i+" remaining configs")
			SimSettlementsV2:ObjectReferences:RegisteredAddonPack thisRegistration = questMain.SS2Main.RegisteredAddonPacks.GetAt(i) as SimSettlementsV2:ObjectReferences:RegisteredAddonPack
			if thisRegistration && thisRegistration.GetAddonPackConfig() != none
				IndexAddonConfig(thisRegistration.GetAddonPackConfig())
			else
				Log(thisRegistration + " is missing config an issue")
			endIf
			i -= 1
		endWhile

		bIndexInProgress = false
		Log("Finished Indexing")
		Debug.MessageBox("Finished Indexing")
	else
		Log("Index already populated")
		Debug.Notification("Index already populated")
	endIf
EndFunction

Function IndexAddonConfig(SimSettlementsV2:MiscObjects:AddonPackConfiguration thisConfig)
	Log("AddonConfig: "+thisConfig)
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
	Log("FormList: "+thisList)
	if thisList.GetAt(0) == none
		return
	endIf
	Log("FLID Keyword: "+thisList.GetAt(0))
	int i = thisList.GetSize() - 1
	while i >= 0
		IndexAddonItem(thisList.GetAt(i))
		i -= 1
	endWhile
EndFunction

Function IndexAddonItem(Form thisItem)
	string sAddonFilename = System:Form.GetModName(thisItem)
	;Log("Processing "+thisItem+" from "+sAddonFilename)

	; unlockable flags
	if thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag && (thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag).FlagThemeDefinition != none
		IndexAddonItem((thisItem as SimSettlementsV2:MiscObjects:UnlockableFlag).FlagThemeDefinition)
	
	; flags
	; several non-flag scripts extend from ThemeDefinition_Flags, so we need to filter them out
	elseif thisItem as SimSettlementsV2:Armors:ThemeDefinition_Flags && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_EmpireFlags) && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_Holiday) && !(thisItem as SimSettlementsV2:Armors:ThemeDefinition_DecorationSet)
		SS2SST_Index_Flags.AddForm(thisItem)
		iIndexedItemCount += 1
		Log("Added Flag "+thisItem+" from "+sAddonFilename)

	; unlockable buildingplans
	elseif thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan && (thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan).BuildingPlan != none
		IndexAddonItem((thisItem as SimSettlementsV2:MiscObjects:UnlockableBuildingPlan).BuildingPlan)

	; settler discovery items
	elseif thisItem as simsettlementsv2:miscobjects:settlerlocationdiscovery && (thisItem as simsettlementsv2:miscobjects:settlerlocationdiscovery).RegisterForms != none
		int i = (thisItem as simsettlementsv2:miscobjects:settlerlocationdiscovery).RegisterForms.Length
		while i >= 0
			IndexAddonItem((thisItem as simsettlementsv2:miscobjects:settlerlocationdiscovery).RegisterForms[i].FormToInject)
			i -= 1
		endWhile

	; buildingplans
	elseif thisItem as SimSettlementsV2:Weapons:BuildingPlan
		IndexBuildingPlan(thisItem as SimSettlementsV2:Weapons:BuildingPlan)
		if thisItem != none
			Log("Added BuildingPlan "+thisItem+" from "+sAddonFilename)
		endIf

	; foundations
	elseif thisItem as SimSettlementsV2:MiscObjects:Foundation
		SS2SST_Index_Foundations.AddForm(thisItem)
		iIndexedItemCount += 1
		Log("Added Foundation "+thisItem+" from "+sAddonFilename)
	
	; powerpoles
	;elseif thisItem as SimSettlementsV2:MiscObjects:PowerPole
	;	SS2SST_Index_PowerPoles.AddForm(thisItem)
	;	iIndexedItemCount += 1
	;	Log("Added PowerPole "+thisItem+" from "+sAddonFilename)

	; furniture
	;elseif thisItem as SimSettlementsV2:MiscObjects:FurnitureStoreItem
	;	SS2SST_Index_Furniture.AddForm(thisItem)
	;	iIndexedItemCount += 1
	;	Log("Added Furniture "+thisItem+" from "+sAddonFilename)

	; unique settlers
	;elseif thisItem as SimSettlementsV2:MiscObjects:UnlockableCharacter
	;	SS2SST_Index_UniqueSettlers.AddForm(thisItem)
	;	iIndexedItemCount += 1
	;	Log("Added Unqiue Settler "+thisItem+" from "+sAddonFilename)

	; pets
	;elseif thisItem as SimSettlementsV2:MiscObjects:PetStoreCreatureItem
	;	SS2SST_Index_Pets.AddForm(thisItem)
	;	iIndexedItemCount += 1
	;	Log("Added Pet "+thisItem+" from "+sAddonFilename)
	

	endIf
EndFunction

Function IndexBuildingPlan(SimSettlementsV2:Weapons:BuildingPlan thisItem)
	if thisItem.HasKeyWord(SS2_PlotSize_1x1)
		SS2SST_Index_BuildingPlans_Agricultural_1x1.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotSize_2x2)
		SS2SST_Index_BuildingPlans_Agricultural_2x2.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotSize_3x3)
		SS2SST_Index_BuildingPlans_Agricultural_3x3.AddForm(thisItem)
	elseif thisItem.HasKeyWord(SS2_PlotSize_Int)
		SS2SST_Index_BuildingPlans_Agricultural_Int.AddForm(thisItem)
	endif
EndFunction

Function RevertAll()
	SS2SST_Index_Flags.Revert()
	SS2SST_Index_Foundations.Revert()
	SS2SST_Index_PowerPoles.Revert()
	SS2SST_Index_Furniture.Revert()
	SS2SST_Index_UniqueSettlers.Revert()
	SS2SST_Index_Pets.Revert()
	SS2SST_Index_BuildingPlans_Agricultural_1x1.Revert()
	SS2SST_Index_BuildingPlans_Agricultural_2x2.Revert()
	SS2SST_Index_BuildingPlans_Agricultural_3x3.Revert()
	SS2SST_Index_BuildingPlans_Agricultural_Int.Revert()
EndFunction