scriptname SS2_ScreenshotTool:Activators:Base extends ObjectReference

Import SUP_F4SE
Import System:Form
Import System:Strings
Import GardenOfEden

import WorkshopFramework:Library:DataStructures
import WorkshopDataScript

SS2_ScreenshotTool:Quests:Main Property questMain Auto Const Mandatory
SS2_ScreenshotTool:Quests:Indexer Property questIndexer Auto Const Mandatory

string sLogPrefix = "Base"
WorkshopScript Property refWorkshop Auto Hidden
WorldObject Property thisWorldObject Auto Hidden
int Property bCaptureStage = 0 Auto Hidden
; 0 = idle, 1 = pending, 2 = capturing

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
	    Debug.Notification("Capture interrupted")
        Log("Capture interrupted")
    elseif bCaptureStage == 1
        bCaptureStage = 0
	    Debug.Notification("Capture canceled")
        Log("Capture canceled")
    else
        Debug.Notification("Capture will begin in 10 seconds")
        Log("Capture will begin in 10 seconds")
        bCaptureStage = 1
        Utility.Wait(10)
        if bCaptureStage == 1 ; incase canceled during wait
            BatchCapture()
        endIf
    endif
EndEvent

Function Log(string sMessage)
	questMain.Log("[Activators:"+sLogPrefix+"] "+sMessage)
EndFunction

Function CheckIndexing()
	if questMain.questIndexer.bIndexInProgress
		Debug.MessageBox("Indexing is still running")
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