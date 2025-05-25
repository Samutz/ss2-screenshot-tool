scriptname SS2_ScreenshotTool:Activators:Base extends ObjectReference

;Import SUP_F4SE
;Import System:Form
;Import System:Strings
;Import GardenOfEden

import WorkshopFramework:Library:DataStructures
;import WorkshopDataScript

SS2_ScreenshotTool:Quests:Main Property questMain Auto Const Mandatory
SS2_ScreenshotTool:Quests:Indexer Property questIndexer Auto Const Mandatory

string sLogPrefix = "Base"
Actor Property refPlayer Auto Hidden
WorkshopScript Property refWorkshop Auto Hidden
WorldObject Property thisWorldObject Auto Hidden
int Property bCaptureStage = 0 Auto Hidden
; 0 = idle, 1 = pending, 2 = capturing
FormList Property sourceFormList Auto Hidden

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	refWorkshop = akReference as WorkshopScript
    SetWorldObject()
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	refWorkshop = akReference as WorkshopScript
    SetWorldObject()
EndEvent

Event OnActivate(ObjectReference akReference)
    if bCaptureStage == 2
        bCaptureStage = 0
	    ;Debug.Notification("Capture interrupted")
        Log("Capture interrupted")
    elseif bCaptureStage == 1
        bCaptureStage = 0
	    ;Debug.Notification("Capture canceled")
        Log("Capture canceled")
    else
		LogCount()
        ;bCaptureStage = 1
        ;Utility.Wait(10)
        ;if bCaptureStage == 1 ; incase canceled during wait
        ;    BatchCapture()
        ;endIf
		PrepContainer()
    endif
EndEvent

Function PrepContainer()
	CheckIndexing()

	questMain.ItemContainer.RemoveAllItems()
	questMain.ItemsToCaptureFormList.Revert()
	
	refPlayer = Game.GetPlayer()

	SetSourceFormList()
	
	int i = sourceFormList.GetSize() - 1
	while i >= 0
		questMain.ItemContainer.AddItem(sourceFormList.GetAt(i))
		AddInventoryEventFilter(sourceFormList.GetAt(i))
		i -= 1
	endWhile
	RegisterForRemoteEvent(questMain.ItemContainer, "OnItemRemoved")
	RegisterForMenuOpenCloseEvent("ContainerMenu")
	questMain.ItemContainer.Activate(refPlayer)
EndFunction

Event ObjectReference.OnItemRemoved(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	if akSender != questMain.ItemContainer || akDestContainer != refPlayer as ObjectReference
		return
	endIf
	questMain.ItemsToCaptureFormList.AddForm(akBaseItem)
	refPlayer.RemoveItem(akItemReference, 0, true)
EndEvent

Event OnMenuOpenCloseEvent(String asMenuName, bool abOpening)
    if asMenuName == "ContainerMenu" && !abOpening && questMain.ItemsToCaptureFormList.GetSize() > 0
		UnregisterForMenuOpenCloseEvent("ContainerMenu")
		UnregisterForRemoteEvent(questMain.ItemContainer, "OnItemRemoved")
        ;Debug.Notification("Capture will begin in 10 seconds")
        Log("Capture will begin in 10 seconds")
		bCaptureStage = 1
        Utility.Wait(10)
        if bCaptureStage == 1 ; incase canceled during wait
            BatchCapture()
        endIf
    endif
EndEvent

Function Log(string sMessage, bool bNotification = true)
	questMain.Log("[Activators:"+sLogPrefix+"] "+sMessage)
	if bNotification
		Debug.Notification(sMessage)
	endIf
EndFunction

Function CheckIndexing()
	if questMain.questIndexer.bIndexInProgress
		Debug.Notification("Indexing is still running")
		return
	endIf
EndFunction

Function SetWorldObject()
    thisWorldObject = new WorldObject
    thisWorldObject.fPosX = GetPositionX()
	thisWorldObject.fPosY = GetPositionY()
	thisWorldObject.fPosZ = GetPositionZ()
	thisWorldObject.fAngleX = GetAngleX()
	thisWorldObject.fAngleY = GetAngleY()
	thisWorldObject.fAngleZ = GetAngleZ()
	thisWorldObject.fScale = GetScale()
EndFunction

string Function GetFormKey(Form formObj)
	string hexID = GardenOfEden.GetHexFormID(formObj)
	if System:Strings.StartsWith(hexID, "FE")
		hexID = "000"+System:Strings.Substring(hexID, 5)
	else
		hexID = System:Strings.Substring(hexID, 2)
	endIf
	string modName = System:Form.GetModName(formObj)
	string result = hexID+"-"+modName
	return result
EndFunction

Form Function GetWorldObjectForm(WorldObject thisWorldObject2)
	Form thisForm = thisWorldObject2.ObjectForm
	if thisWorldObject2.iFormID > -1 && thisWorldObject2.sPluginName != ""
		thisForm = Game.GetFormFromFile(thisWorldObject2.iFormID, thisWorldObject2.sPluginName)
	endIf
	return thisForm
EndFunction

Function BatchCapture()
    ; stub
EndFunction

Function LogCount()
    ; stub
EndFunction

Function SetSourceFormList()
	; stub
EndFunction
