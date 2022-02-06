Scriptname OSLAroused_MCM extends SKI_ConfigBase hidden

OSLAroused_Main Property Main Auto

OSLAroused_MCM Function Get() Global
	return Game.GetFormFromFile(0x806, "OSLAroused.esp") as OSLAroused_MCM
EndFunction

int CheckArousalKeyOid
int EnableStatBuffsOid
int EnableNudityCheckOid
int HourlyNudityArousalModOid

int StageChangeIncreasesArousalOid
int VictimGainsArousalOid

string[] ArousalModeNames
int Property ArousalModeOid Auto

; OStim Specific Settings
int Property RequireLowArousalToEndSceneOid Auto

;---- Puppet Properties ----
Actor Property PuppetActor Auto
int Property SetArousalOid Auto
int Property SetMultiplierOid Auto
int Property SetTimeRateOid Auto

float Property kDefaultArousalMultiplier = 1.0 AutoReadOnly

;------ Debug Properties -------
int DumpArousalData
int ClearSecondaryArousalData
int ClearAllArousalData

;------ Keywords -------
int ArmorListMenuOid
Armor SelectedArmor
string[] FoundArmorNames
int[] FoundArmorIds

int EroticArmorOid
Keyword Property EroticArmorKeyword Auto
bool EroticArmorState

int BikiniArmorOid
Keyword BikiniArmorKeyword
bool BikiniArmorState


int function GetVersion()
    return 1
endfunction

Event OnConfigInit()
    ModName = "OSLAroused"
    Pages = new String[5]
    Pages[0] = "General Settings"
    Pages[1] = "Status"
    Pages[2] = "Puppeteer"
    Pages[3] = "Keywords"
    Pages[4] = "Debug"

    ArousalModeNames = new string[2]
    ArousalModeNames[0] = "SexLab Aroused"
    ArousalModeNames[1] = "OAroused"

    PuppetActor = Game.GetPlayer()

	EroticArmorKeyword = Keyword.GetKeyword("EroticArmor")
	BikiniArmorKeyword = Keyword.GetKeyword("_SLS_BikiniArmor")
EndEvent

Event OnPageReset(string page)
    SetCursorFillMode(TOP_TO_BOTTOM)
    if(page == "" || page == "General Settings")
        MainLeftColumn()
        SetCursorPosition(1)
        MainRightColumn()
    elseif(page == "Status")
        StatusPage()
    elseif(page == "Puppeteer")
        PuppeteerPage()
    elseif(page == "Keywords")
        KeywordPage()
    elseif(page == "Debug")
        DebugPage()
    endif
EndEvent

function MainLeftColumn()
    CheckArousalKeyOid = AddKeyMapOption("Show Arousal Key", Main.GetShowArousalKeybind())
    EnableStatBuffsOid = AddToggleOption("Enable Arousal Stat (De)Buffs", Main.EnableArousalStatBuffs)
    ArousalModeOid = AddMenuOption("Arousal Mode", ArousalModeNames[Main.GetCurrentArousalMode()])

    AddHeaderOption("Scene Settings")
    StageChangeIncreasesArousalOid = AddToggleOption("Stage change Increases Arousal", Main.StageChangeIncreasesArousal)
    VictimGainsArousalOid = AddToggleOption("Victim Gains Arousal", Main.VictimGainsArousal)

endfunction

function MainRightColumn()
    AddHeaderOption("Nudity Settings")
    EnableNudityCheckOid = AddToggleOption("Player Nudity Increases Others Arousal", Main.GetEnableNudityIncreasesArousal())
    HourlyNudityArousalModOid = AddSliderOption("Hourly Arousal From Viewing Nude", Main.GetHourlyNudityArousalModifier(), "{1}")

    AddHeaderOption("OStim Settings")
    RequireLowArousalToEndSceneOid = AddToggleOption("Require Low Arousal To End Scene", Main.RequireLowArousalToEndScene)
endfunction

function StatusPage()
    if(PuppetActor == none)
        AddHeaderOption("No Target Selected")
        return
    endif
    AddHeaderOption(PuppetActor.GetLeveledActorBase().GetName())

    int currentArousalMode = Main.GetCurrentArousalMode()
    if(currentArousalMode == Main.kArousalMode_OAroused)
        AddTextOption("Current Arousal", OSLArousedNative.GetArousal(PuppetActor), OPTION_FLAG_DISABLED)
        AddTextOption("Arousal Multiplier", OSLArousedNative.GetArousalMultiplier(PuppetActor), OPTION_FLAG_DISABLED)
    elseif(currentArousalMode == Main.kArousalMode_SLAroused)
        float timeRate = OSLArousedNative.GetTimeRate(PuppetActor)
        float lastOrgasm = OSLArousedNative.GetDaysSinceLastOrgasm(PuppetActor)

        AddTextOption("Arousal = Exposure + Time Arousal", OSLArousedNative.GetArousal(PuppetActor), OPTION_FLAG_DISABLED)
        AddTextOption("Current Exposure", OSLArousedNative.GetExposure(PuppetActor), OPTION_FLAG_DISABLED)
        AddTextOption("Exposure Rate", OSLArousedNative.GetArousalMultiplier(PuppetActor), OPTION_FLAG_DISABLED)
        AddTextOption("Time Arousal = D x (Time Rate)", lastOrgasm * timeRate, OPTION_FLAG_DISABLED)
        AddTextOption("D = Days Since Last Orgasm", OSLArousedNative.GetDaysSinceLastOrgasm(PuppetActor), OPTION_FLAG_DISABLED)
        AddTextOption("Time Rate", timeRate, OPTION_FLAG_DISABLED)
    endif
endfunction

function PuppeteerPage()
    if(PuppetActor == none)
        AddHeaderOption("No Target Selected")
        return
    endif

    AddEmptyOption()
    AddHeaderOption(PuppetActor.GetLeveledActorBase().GetName())

    int currentArousalMode = Main.GetCurrentArousalMode()
    if(currentArousalMode == Main.kArousalMode_OAroused)
        float exposure = OSLArousedNative.GetExposure(PuppetActor)
        SetArousalOid = AddSliderOption("Arousal", exposure, "{0}")
    
        float exposureRate = OSLArousedNative.GetArousalMultiplier(PuppetActor)
        SetMultiplierOid = AddSliderOption("Arousal Multiplier", exposureRate, "{1}")
    elseif(currentArousalMode == Main.kArousalMode_SLAroused)
        float exposure = OSLArousedNative.GetExposure(PuppetActor)
        SetArousalOid = AddSliderOption("Exposure", exposure, "{0}")
    
        float exposureRate = OSLArousedNative.GetArousalMultiplier(PuppetActor)
        SetMultiplierOid = AddSliderOption("Exposure Rate", exposureRate, "{1}")
        
        float timeRate = OSLArousedNative.GetTimeRate(PuppetActor)
        SetTimeRateOid = AddSliderOption("Time Rate", timeRate, "{0}")
    endif
endfunction

function KeywordPage()
    AddHeaderOption("Keyword Management")
    ArmorListMenuOid = AddMenuOption("Click to Load Armor List", "")
    SetCursorPosition(1)
    EroticArmorOid = AddToggleOption("EroticArmor", false, OPTION_FLAG_DISABLED)
    BikiniArmorOid = AddToggleOption("SLS Bikini Armor", false, OPTION_FLAG_DISABLED)
endfunction

function DebugPage()
    AddHeaderOption("Native Data")
    DumpArousalData = AddTextOption("Dump Arousal Data", "RUN")
    ClearSecondaryArousalData = AddTextOption("Clear Secondary Arousal Data", "RUN")
    ClearAllArousalData = AddTextOption("Clear All Arousal Data", "RUN")
endfunction

event OnOptionSelect(int optionId)
    if(CurrentPage == "General Settings" || CurrentPage == "")
        if (optionId == EnableNudityCheckOid)
            bool newVal = !Main.GetEnableNudityIncreasesArousal()
            Main.SetPlayerNudityIncreasesArousal(newVal) 
            SetToggleOptionValue(EnableNudityCheckOid, newVal)
        elseif (optionId == EnableStatBuffsOid)
            Main.SetArousalEffectsEnabled(!Main.EnableArousalStatBuffs) 
            SetToggleOptionValue(EnableStatBuffsOid, Main.EnableArousalStatBuffs)
        elseif (optionId == RequireLowArousalToEndSceneOid)
            Main.RequireLowArousalToEndScene = !Main.RequireLowArousalToEndScene 
            SetToggleOptionValue(RequireLowArousalToEndSceneOid, Main.RequireLowArousalToEndScene)
        elseif (optionId == StageChangeIncreasesArousalOid)
            Main.StageChangeIncreasesArousal = !Main.StageChangeIncreasesArousal
            SetToggleOptionValue(StageChangeIncreasesArousalOid, Main.StageChangeIncreasesArousal)
        elseif (optionId == VictimGainsArousalOid)
            Main.VictimGainsArousal = !Main.VictimGainsArousal
            SetToggleOptionValue(VictimGainsArousalOid, Main.VictimGainsArousal)
        EndIf
    ElseIf (CurrentPage == "Keywords")
        if(optionId == EroticArmorOid)
            if(EroticArmorState)
                bool removeSuccess = OSLArousedNative.RemoveKeywordFromForm(SelectedArmor, EroticArmorKeyword)
                EroticArmorState = !removeSuccess ;if remove success fails, indicate keyword still on
            else
                bool updateSuccess = OSLArousedNative.AddKeywordToForm(SelectedArmor, EroticArmorKeyword)
                EroticArmorState = updateSuccess
            endif
            SetToggleOptionValue(EroticArmorOid, EroticArmorState)
        elseif(optionId == BikiniArmorOid)
            if(BikiniArmorState)
                bool removeSuccess = OSLArousedNative.RemoveKeywordFromForm(SelectedArmor, BikiniArmorKeyword)
                BikiniArmorState = !removeSuccess ;if remove success fails, indicate keyword still on
            else
                bool updateSuccess = OSLArousedNative.AddKeywordToForm(SelectedArmor, BikiniArmorKeyword)
                BikiniArmorState = updateSuccess
            endif
            SetToggleOptionValue(BikiniArmorOid, BikiniArmorState)
        endif
    ElseIf(CurrentPage == "Debug")
        if(optionId == DumpArousalData)
            OSLArousedNative.DumpArousalData()
        elseif(optionId == ClearSecondaryArousalData)
            if (ShowMessage("Are you sure you want to Clear Secondary NPC Arousal Data? This is non-reversible"))
                OSLArousedNative.ClearSecondaryArousalData()
            endif
        elseif(optionId == ClearAllArousalData)
            if (ShowMessage("Are you sure you want to Clear All Arousal Data? This is non-reversible"))
                OSLArousedNative.ClearAllArousalData()
            endif
        endif
    EndIf
endevent

Event OnOptionKeyMapChange(int optionId, int keyCode, string conflictControl, string conflictName)
    if(optionId == CheckArousalKeyOid)
        Main.SetShowArousalKeybind(keyCode)
        SetKeyMapOptionValue(CheckArousalKeyOid, keyCode)
    endif
EndEvent

event OnOptionHighlight(int optionId)
    if(CurrentPage == "General Settings" || CurrentPage == "")
        if(optionId == CheckArousalKeyOid)
            SetInfoText("Key To Show Arousal Bar")
        elseif(optionId == EnableNudityCheckOid)
            SetInfoText("If Enabled, Player Nudity will increase nearby NPC arrousal")
        elseif(optionId == HourlyNudityArousalModOid)
            SetInfoText("Arousal Gained per hour when observing a nude character.")
        elseif(optionId == EnableStatBuffsOid)
            SetInfoText("Will Enable Arousal based Stat Buffs")
        elseif(optionId == RequireLowArousalToEndSceneOid)
            SetInfoText("OStim Scene will not end until Participant arousal is low")
        elseif(optionId == ArousalModeOid)
            SetInfoText("SL Arousal emulates OG Sexlab Behavior. OArousal emulatues OArousal Behavior")
        elseif(optionId == StageChangeIncreasesArousalOid)
            SetInfoText("Changing Scene stage increases participant arousal")
        elseif(optionId == VictimGainsArousalOid)
            SetInfoText("Victim gains arousal in scenes")
        EndIf
    elseif(CurrentPage == "Debug")
        if(optionId == DumpArousalData)
            SetInfoText("Dump all stored arousal data to SKSE log file")
        elseif(optionId == ClearSecondaryArousalData)
            SetInfoText("Clear NPC Arousal data from Save (This Maintains Player/Unique Data)")
        elseif(optionId == ClearAllArousalData)
            SetInfoText("Clear All Arousal data from Save")
        endif
    EndIf
endevent

event OnOptionMenuOpen(int optionId)
    if(CurrentPage == "General Settings" || CurrentPage == "")
        if(optionId == ArousalModeOid)
            SetMenuDialogStartIndex(Main.GetCurrentArousalMode())
            SetMenuDialogDefaultIndex(0)
            SetMenuDialogOptions(ArousalModeNames)
        endif
    elseif (CurrentPage == "Keywords")
        if(optionId == ArmorListMenuOid)
            LoadArmorList()
        endif
    endif
endevent

event OnOptionMenuAccept(int optionId, int index)
    if(CurrentPage == "General Settings" || CurrentPage == "")
        if(optionId == ArousalModeOid)
            Main.SetCurrentArousalMode(index)
            SetMenuOptionValue(optionId, ArousalModeNames[index])
        endif
    ElseIf (CurrentPage == "Keywords")
        If (optionId == ArmorListMenuOid)
            SelectedArmor = Game.GetPlayer().GetNthForm(FoundArmorIds[index]) as Armor
            SetMenuOptionValue(optionId, FoundArmorNames[index])
            ArmorSelected()
        EndIf
    endif
endevent

event OnOptionSliderOpen(int option)
    if(CurrentPage == "" || CurrentPage == "General Settings")
        if(option == HourlyNudityArousalModOid)
            SetSliderDialogStartValue(Main.GetHourlyNudityArousalModifier())
            SetSliderDialogDefaultValue(20.0)
            SetSliderDialogRange(0, 50)
            SetSliderDialogInterval(0.1)
        endif
    elseif(CurrentPage == "Puppeteer")
        if(option == SetArousalOid)
            float arousal = 0
            if(Main.GetCurrentArousalMode() == Main.kArousalMode_SLAroused)
                arousal = OSLArousedNative.GetExposure(PuppetActor)
            else
                arousal = OSLArousedNative.GetArousal(PuppetActor)
            endif
            SetSliderDialogStartValue(arousal)
            SetSliderDialogDefaultValue(0)
            SetSliderDialogRange(0, 100)
            SetSliderDialogInterval(1)
        elseif (option == SetMultiplierOid)
            float mult = OSLArousedNative.GetArousalMultiplier(PuppetActor)
            SetSliderDialogStartValue(mult)
            SetSliderDialogDefaultValue(kDefaultArousalMultiplier)
            SetSliderDialogRange(0, 10.0)
            SetSliderDialogInterval(0.1)
        elseif (option == SetTimeRateOid)
            float timeRate = OSLArousedNative.GetTimeRate(PuppetActor)
            SetSliderDialogStartValue(timeRate)
            SetSliderDialogDefaultValue(10.0)
            SetSliderDialogRange(0, 100.0)
            SetSliderDialogInterval(1.0)
        endif
    endif
endevent

event OnOptionSliderAccept(int option, float value)
    if(CurrentPage == "" || CurrentPage == "General Settings")
        if(option == HourlyNudityArousalModOid)
            Main.SetHourlyNudityArousalModifier(value)
            SetSliderOptionValue(HourlyNudityArousalModOid, value, "{1}")
        endif
    elseif(currentPage == "Puppeteer")
        if(option == SetArousalOid)
            OSLArousedNative.SetArousal(PuppetActor, value)
            SetSliderOptionValue(SetArousalOid, value, "{0}")
        elseif(option == SetMultiplierOid)
            OSLArousedNative.SetArousalMultiplier(PuppetActor, value)
            SetSliderOptionValue(SetMultiplierOid, value, "{1}")
        elseif(option == SetTimeRateOid)
            OSLArousedNative.SetTimeRate(PuppetActor, value)
            SetSliderOptionValue(SetTimeRateOid, value, "{0}")
        endif
    endif
endevent

event OnOptionDefault(int option)
    if(CurrentPage == "" || CurrentPage == "General Settings")
        if(option == HourlyNudityArousalModOid)
            Main.SetHourlyNudityArousalModifier(20.0)
            SetSliderOptionValue(HourlyNudityArousalModOid, 20.0, "{1}")
        endif
    elseif(currentPage == "Puppeteer")
        if(option == SetArousalOid)
            OSLArousedNative.SetArousal(PuppetActor, 0)
            SetSliderOptionValue(SetArousalOid, 0, "{0}")
        elseif(option == SetMultiplierOid)
            OSLArousedNative.SetArousalMultiplier(PuppetActor, kDefaultArousalMultiplier)
            SetSliderOptionValue(SetMultiplierOid, kDefaultArousalMultiplier, "{1}")
        elseif(option == SetTimeRateOid)
            OSLArousedNative.SetTimeRate(PuppetActor, 10.0)
            SetSliderOptionValue(SetTimeRateOid, 10.0, "{0}")
        endif
    endif
endevent

event OnKeyDown(int keyCode)
    if(!Utility.IsInMenuMode() && keyCode == Main.GetShowArousalKeybind())
        Actor target = Game.GetCurrentCrosshairRef() as Actor
        if(target != none)
            PuppetActor = target
        Else
            PuppetActor = Game.GetPlayer()
        endif
    endif
endevent

;Based off code from MrowrPurr :)
function LoadArmorList()
    SelectedArmor = none
    Actor player = Game.GetPlayer()
    int numItems = player.GetNumItems()
    int index = 0
    FoundArmorNames = new string[128]
    FoundArmorIds = new int[128]
    int foundItemIndex = 0
    while(index < numItems && foundItemIndex < 128)
        Armor armorItem = player.GetNthForm(index) as Armor
        if(armorItem)
            Debug.Trace("Found: " + armorItem.GetName())
            FoundArmorNames[foundItemIndex] = armorItem.GetName()
            FoundArmorIds[foundItemIndex] = index
            foundItemIndex += 1
        endif
        index += 1
    endwhile

    FoundArmorNames = Utility.ResizeStringArray(FoundArmorNames, foundItemIndex)
    FoundArmorIds = Utility.ResizeIntArray(FoundArmorIds, foundItemIndex)
    SetMenuDialogOptions(FoundArmorNames)
endfunction

function ArmorSelected()
    if(!SelectedArmor)
        return
    endif
    
    if(EroticArmorKeyword)
        SetOptionFlags(EroticArmorOid, OPTION_FLAG_NONE)
        EroticArmorState = SelectedArmor.HasKeyword(EroticArmorKeyword)
        SetToggleOptionValue(EroticArmorOid, EroticArmorState)
    else
        SetToggleOptionValue(EroticArmorOid, false)
    endif

    if(BikiniArmorKeyword)
        SetOptionFlags(BikiniArmorOid, OPTION_FLAG_NONE)
        BikiniArmorState = SelectedArmor.HasKeyword(BikiniArmorKeyword)
        SetToggleOptionValue(BikiniArmorOid, BikiniArmorState)
    else
        SetToggleOptionValue(BikiniArmorOid, false)
    endif
endfunction


function Log(string msg) global
    Debug.Trace("---OSLAroused--- [MCM] " + msg)
endfunction
