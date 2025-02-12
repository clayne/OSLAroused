#include "PapyrusInterface.h"

#include "PersistedData.h"
#include "Managers/ArousalManager.h"
#include "Utilities/Utils.h"
#include <Settings.h>
#include <Integrations/DevicesIntegration.h>
#include "RuntimeEvents.h"

float PapyrusInterface::GetArousal(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return Arousal::GetArousal(actorRef);
}

std::vector<float> PapyrusInterface::GetArousalMultiple(RE::StaticFunctionTag*, RE::reference_array<RE::Actor*> actorRefs)
{
	std::vector<float> results;

	for (const auto actorRef : actorRefs) {
        if (!actorRef) {
            Utilities::logInvalidArgsVerbose(__FUNCTION__);
            results.push_back(0);
			continue;
        }
		results.push_back(Arousal::GetArousal(actorRef));
	}

	return results;
}

float PapyrusInterface::GetArousalNoSideEffects(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {  Utilities::logInvalidArgsVerbose(__FUNCTION__); return 0; }
	return Arousal::GetArousal(actorRef, false);
}

float PapyrusInterface::SetArousal(RE::StaticFunctionTag*, RE::Actor* actorRef, float value)
{
    if (!actorRef) {  Utilities::logInvalidArgsVerbose(__FUNCTION__); return 0; }
	return Arousal::SetArousal(actorRef, value);
}

void PapyrusInterface::SetArousalMultiple(RE::StaticFunctionTag*, RE::reference_array<RE::Actor*> actorRefs, float value)
{
	for (const auto actorRef : actorRefs) {
        if (!actorRef) { 
			Utilities::logInvalidArgsVerbose(__FUNCTION__); 
			continue;
		}
		Arousal::SetArousal(actorRef, value);
	}
}

float PapyrusInterface::ModifyArousal(RE::StaticFunctionTag*, RE::Actor* actorRef, float value)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return Arousal::ModifyArousal(actorRef, value);
}

void PapyrusInterface::ModifyArousalMultiple(RE::StaticFunctionTag*, RE::reference_array<RE::Actor*> actorRefs, float value)
{
	for (const auto actorRef : actorRefs) {
        if (!actorRef) {
            Utilities::logInvalidArgsVerbose(__FUNCTION__);
            continue;
        }
		Arousal::ModifyArousal(actorRef, value);
	}
}

float PapyrusInterface::GetArousalMultiplier(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }

	return ArousalManager::GetSingleton()->GetArousalSystem().GetArousalMultiplier(actorRef);
}

float PapyrusInterface::SetArousalMultiplier(RE::StaticFunctionTag*, RE::Actor* actorRef, float value)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	float newArousalMultiplier = ArousalManager::GetSingleton()->GetArousalSystem().SetArousalMultiplier(actorRef, value);
	Utilities::Factions::GetSingleton()->SetFactionRank(actorRef, FactionType::sla_ExposureRate, newArousalMultiplier);
	return newArousalMultiplier;
}

float PapyrusInterface::ModifyArousalMultiplier(RE::StaticFunctionTag*, RE::Actor* actorRef, float value)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return ArousalManager::GetSingleton()->GetArousalSystem().ModifyArousalMultiplier(actorRef, value);
}

float PapyrusInterface::GetArousalBaseline(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return ArousalManager::GetSingleton()->GetArousalSystem().GetBaselineArousal(actorRef);
}

float PapyrusInterface::GetLibido(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return ArousalManager::GetSingleton()->GetArousalSystem().GetLibido(actorRef);
}

float PapyrusInterface::SetLibido(RE::StaticFunctionTag*, RE::Actor* actorRef, float newVal)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return ArousalManager::GetSingleton()->GetArousalSystem().SetLibido(actorRef, newVal);
}

float PapyrusInterface::ModifyLibido(RE::StaticFunctionTag* base, RE::Actor* actorRef, float modVal)
{
	if (!actorRef) {
		Utilities::logInvalidArgsVerbose(__FUNCTION__);
		return 0;
	}
	
	return ArousalManager::GetSingleton()->GetArousalSystem().ModifyLibido(actorRef, modVal);
}

float PapyrusInterface::GetExposure(RE::StaticFunctionTag* base, RE::Actor* actorRef)
{
	if (!actorRef) {
		Utilities::logInvalidArgsVerbose(__FUNCTION__);
		return 0;
	}

	return ArousalManager::GetSingleton()->GetArousalSystem().GetExposure(actorRef);
}

float PapyrusInterface::GetDaysSinceLastOrgasm(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	float lastOrgasmTime = PersistedData::LastOrgasmTimeData::GetSingleton()->GetData(actorRef->formID, 0.f);
	if (lastOrgasmTime < 0) {
		lastOrgasmTime = 0;
	}

	return RE::Calendar::GetSingleton()->GetCurrentGameTime() - lastOrgasmTime;
}

bool PapyrusInterface::IsNaked(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return Utilities::Actor::IsNakedCached(actorRef);
}

bool PapyrusInterface::IsViewingNaked(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return Utilities::Actor::IsViewingNaked(actorRef);
}

bool PapyrusInterface::IsInScene(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return Utilities::Actor::IsParticipatingInScene(actorRef);
}

bool PapyrusInterface::IsViewingScene(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return Utilities::Actor::IsViewingScene(actorRef);
}

bool PapyrusInterface::IsWearingEroticArmor(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	if (!Utilities::Actor::IsNakedCached(actorRef)) {
		if (const auto eroticKeyword = Settings::GetSingleton()->GetEroticArmorKeyword()) {
			const auto wornKeywords = Utilities::Actor::GetWornArmorKeywords(actorRef);
			return wornKeywords.contains(eroticKeyword->formID);
		}
	}
	return false;
}

bool PapyrusInterface::IsActorExhibitionist(RE::StaticFunctionTag* base, RE::Actor* actorRef)
{
	if (!actorRef) {
		return false;
	}
	return PersistedData::IsActorExhibitionistData::GetSingleton()->GetData(actorRef->formID, false);
}

void PapyrusInterface::SetActorExhibitionist(RE::StaticFunctionTag* base, RE::Actor* actorRef, bool exhibitionist)
{
	if (!actorRef) {
		return;
	}
	PersistedData::IsActorExhibitionistData::GetSingleton()->SetData(actorRef->formID, exhibitionist);
	Utilities::Factions::GetSingleton()->SetFactionRank(actorRef, FactionType::sla_Exhibitionist, exhibitionist ? 0 : -2);
}

bool PapyrusInterface::IsActorArousalLocked(RE::StaticFunctionTag* base, RE::Actor* actorRef)
{
	if (!actorRef) {
		return true;
	}

	return PersistedData::IsArousalLockedData::GetSingleton()->GetData(actorRef->formID, false);
}

void PapyrusInterface::SetActorArousalLocked(RE::StaticFunctionTag* base, RE::Actor* actorRef, bool locked)
{
	if (!actorRef) {
		return;
	}
	PersistedData::IsArousalLockedData::GetSingleton()->SetData(actorRef->formID, locked);
	Utilities::Factions::GetSingleton()->SetFactionRank(actorRef, FactionType::sla_Arousal_Locked, locked ? 0 : -2);
}

float PapyrusInterface::GetActorTimeRate(RE::StaticFunctionTag* base, RE::Actor* actorRef)
{
	if (!actorRef) {
		return -2.0f;
	}
	auto arousalMode = ArousalManager::GetSingleton()->GetArousalSystem().GetMode();

	//OSL Mode just return a "sane" value (sla default)
	float timeRate = 10.f;

	//SLA mode libido = timerate
	if (arousalMode == IArousalSystem::ArousalMode::kSLA)
	{
		timeRate = ArousalManager::GetSingleton()->GetArousalSystem().GetLibido(actorRef);
	}

	Utilities::Factions::GetSingleton()->SetFactionRank(actorRef, FactionType::sla_TimeRate, timeRate);

	return timeRate;
}

float PapyrusInterface::SetActorTimeRate(RE::StaticFunctionTag* base, RE::Actor* actorRef, float timeRate)
{
	if (!actorRef) {
		return -2.0f;
	}
	auto arousalMode = ArousalManager::GetSingleton()->GetArousalSystem().GetMode();

	//SLA mode libido = timerate
	if (arousalMode == IArousalSystem::ArousalMode::kSLA)
	{
		return ArousalManager::GetSingleton()->GetArousalSystem().SetLibido(actorRef, timeRate);
	}

	//OSL Mode just return a "sane" value (sla default)
	return 10.0f;
}

float PapyrusInterface::ModifyActorTimeRate(RE::StaticFunctionTag* base, RE::Actor* actorRef, float timeRate)
{
	if (!actorRef) {
		return -2.0f;
	}

	auto arousalMode = ArousalManager::GetSingleton()->GetArousalSystem().GetMode();

	//SLA mode libido = timerate
	if (arousalMode == IArousalSystem::ArousalMode::kSLA)
	{
		return ArousalManager::GetSingleton()->GetArousalSystem().SetLibido(actorRef, timeRate);
	}

	//OSL Mode just return a "sane" value (sla default)
	return 10.0f;
}

float PapyrusInterface::WornDeviceBaselineGain(RE::StaticFunctionTag*, RE::Actor* actorRef)
{
    if (!actorRef) {
        Utilities::logInvalidArgsVerbose(__FUNCTION__);
        return 0;
    }
	return DevicesIntegration::GetSingleton()->GetArousalBaselineFromDevices(actorRef);
}


std::vector<RE::Actor*> PapyrusInterface::GetLastScannedActors(RE::StaticFunctionTag* base)
{
	std::vector<RE::Actor*> actors;
	for (const auto& actorHandle : WorldChecks::ArousalUpdateTicker::GetSingleton()->LastScannedActors)
	{
		if (auto actor = actorHandle.get())
		{
			actors.push_back(actor.get());
		}
	}
	return actors;
}

RE::Actor* PapyrusInterface::GetMostArousedActorInLocation(RE::StaticFunctionTag* base)
{
	return ActorStateManager::GetSingleton()->GetMostArousedActorInLocation();
}


bool PapyrusInterface::RegisterFunctions(RE::BSScript::IVirtualMachine* vm)
{
	vm->RegisterFunction("GetArousal", "OSLArousedNative", GetArousal);
	vm->RegisterFunction("GetArousalMultiple", "OSLArousedNative", GetArousalMultiple);
	vm->RegisterFunction("GetArousalNoSideEffects", "OSLArousedNative", GetArousalNoSideEffects);

	vm->RegisterFunction("SetArousal", "OSLArousedNative", SetArousal);
	vm->RegisterFunction("SetArousalMultiple", "OSLArousedNative", SetArousalMultiple);
	vm->RegisterFunction("ModifyArousal", "OSLArousedNative", ModifyArousal);
	vm->RegisterFunction("ModifyArousalMultiple", "OSLArousedNative", ModifyArousalMultiple);

	vm->RegisterFunction("GetArousalMultiplier", "OSLArousedNative", GetArousalMultiplier);
	vm->RegisterFunction("ModifyArousalMultiplier", "OSLArousedNative", ModifyArousalMultiplier);
	vm->RegisterFunction("SetArousalMultiplier", "OSLArousedNative", SetArousalMultiplier);

	vm->RegisterFunction("GetLibido", "OSLArousedNative", GetLibido);
	vm->RegisterFunction("SetLibido", "OSLArousedNative", SetLibido);
	vm->RegisterFunction("ModifyLibido", "OSLArousedNative", ModifyLibido);

	vm->RegisterFunction("GetArousalBaseline", "OSLArousedNative", GetArousalBaseline);

	vm->RegisterFunction("GetExposure", "OSLArousedNative", GetExposure);

	vm->RegisterFunction("IsActorArousalLocked", "OSLArousedNative", IsActorArousalLocked);
	vm->RegisterFunction("SetActorArousalLocked", "OSLArousedNative", SetActorArousalLocked);

	vm->RegisterFunction("IsActorExhibitionist", "OSLArousedNative", IsActorExhibitionist);
	vm->RegisterFunction("SetActorExhibitionist", "OSLArousedNative", SetActorExhibitionist);

	vm->RegisterFunction("GetActorTimeRate", "OSLArousedNative", GetActorTimeRate);
	vm->RegisterFunction("SetActorTimeRate", "OSLArousedNative", SetActorTimeRate);
	vm->RegisterFunction("ModifyActorTimeRate", "OSLArousedNative", ModifyActorTimeRate);

	vm->RegisterFunction("GetDaysSinceLastOrgasm", "OSLArousedNative", GetDaysSinceLastOrgasm);

	vm->RegisterFunction("GetLastScannedActors", "OSLArousedNative", GetLastScannedActors);
	vm->RegisterFunction("GetMostArousedActorInLocation", "OSLArousedNative", GetMostArousedActorInLocation);

	//Explainer
	vm->RegisterFunction("IsNaked", "OSLArousedNative", IsNaked);
	vm->RegisterFunction("IsViewingNaked", "OSLArousedNative", IsViewingNaked);
	vm->RegisterFunction("IsInScene", "OSLArousedNative", IsInScene);
	vm->RegisterFunction("IsViewingScene", "OSLArousedNative", IsViewingScene);
	vm->RegisterFunction("IsWearingEroticArmor", "OSLArousedNative", IsWearingEroticArmor);
	vm->RegisterFunction("WornDeviceBaselineGain", "OSLArousedNative", WornDeviceBaselineGain);

	return true;
}
