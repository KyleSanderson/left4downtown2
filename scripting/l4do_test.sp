/* Plugin Template generated by Pawn Studio */

#include <sourcemod>
#include <sdktools>

//set to 1 to require left4downtown
//set to 0 to just work without it (eg check gameconf)
#define USE_NATIVES 1

#if USE_NATIVES
#include "left4downtown.inc"
#endif

#define TEST_DEBUG 1
#define TEST_DEBUG_LOG 1

new Handle:gConf;

public Plugin:myinfo = 
{
	name = "L4D2 Downtown Extension Test Plugin",
	author = "L4D2 Downtown Devs",
	description = "Ensures functions/offsets are valid and provides commands to test-call most natives directly",
	version = "0.5.2.3",
	url = "http://code.google.com/p/left4downtown2"
}

new Handle:cvarBlockTanks = INVALID_HANDLE;
new Handle:cvarBlockWitches = INVALID_HANDLE;
new Handle:cvarSetCampaignScores = INVALID_HANDLE;
new Handle:cvarFirstSurvivorLeftSafeArea = INVALID_HANDLE;
new Handle:cvarProhibitBosses = INVALID_HANDLE;
new Handle:cvarBlockRocks = INVALID_HANDLE;


#define GAMECONFIG_FILE "left4downtown.l4d2"

stock L4D_SetRoundEndTime(Float:endTime)
{
	static bool:init = false;
	static Handle:func = INVALID_HANDLE;
	
	if(!init)
	{
		new Handle:conf = LoadGameConfigFile(GAMECONFIG_FILE);
		if(conf == INVALID_HANDLE)
		{
			LogError("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
			DebugPrintToAll("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
		}
		
		StartPrepSDKCall(SDKCall_GameRules);
		new bool:readConf = PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTerrorGameRules_SetRoundEndTime");
		if(!readConf)
		{
			ThrowError("Failed to read function from game configuration file");
		}
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		func = EndPrepSDKCall();
		
		if(func == INVALID_HANDLE)
		{
			ThrowError("Failed to end prep sdk call");
		}
		
		init = true;
	}

	SDKCall(func, endTime);
	DebugPrintToAll("CTerrorGameRules::SetRoundTime(%f)", endTime);
}


stock L4D_ResetRoundNumber()
{
	static bool:init = false;
	static Handle:func = INVALID_HANDLE;
	
	if(!init)
	{
		new Handle:conf = LoadGameConfigFile(GAMECONFIG_FILE);
		if(conf == INVALID_HANDLE)
		{
			LogError("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
			DebugPrintToAll("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
		}
		
		StartPrepSDKCall(SDKCall_GameRules);
		new bool:readConf = PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTerrorGameRules_ResetRoundNumber");
		if(!readConf)
		{
			ThrowError("Failed to read function from game configuration file");
		}
		func = EndPrepSDKCall();
		
		if(func == INVALID_HANDLE)
		{
			ThrowError("Failed to end prep sdk call");
		}
		
		init = true;
	}

	SDKCall(func);
	DebugPrintToAll("CTerrorGameRules::ResetRoundNumber()");
}

public OnPluginStart()
{
	gConf = LoadGameConfigFile(GAMECONFIG_FILE);
	if(gConf == INVALID_HANDLE) 
	{
		DebugPrintToAll("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
	}
	
	SearchForOffset("TheDirector"); //fails on Linux
	SearchForOffset("TheZombieManager"); //fails on Linux
	SearchForOffset("HasConfigurableDifficultySetting"); //fails on Linux
	SearchForOffset("WeaponInfoDatabase"); //fails on Linux
	SearchForOffset("ValveRejectServerFullFirst");
	
	SearchForFunction("GetTeamScore");
	SearchForFunction("SetCampaignScores");
	SearchForFunction("ClearTeamScores");
	SearchForFunction("SetReservationCookie");
	SearchForFunction("TakeOverBot");
	SearchForFunction("SetHumanSpec");
	
	SearchForFunction("CDirectorScavengeMode_OnBeginRoundSetupTime");
	SearchForFunction("CTerrorGameRules_ResetRoundNumber");
	SearchForFunction("CTerrorGameRules_SetRoundEndTime");
	SearchForFunction("CDirector_AreWanderersAllowed");
	SearchForFunction("DirectorMusicBanks_OnRoundStart");
	
	
	SearchForFunction("TheDirector"); //fails on Windows
	SearchForFunction("RestartScenarioFromVote");
	
	SearchForFunction("SpawnTank");
	SearchForFunction("SpawnWitch");
	SearchForFunction("OnFirstSurvivorLeftSafeArea");
	SearchForFunction("CDirector_GetScriptValueInt");
	SearchForFunction("CDirector_IsFinaleEscapeInProgress");
	SearchForFunction("CTerrorPlayer_CanBecomeGhost");
	
	SearchForFunction("CTerrorPlayer_OnEnterGhostState");
	SearchForFunction("CDirector_IsFinale");
	
	SearchForFunction("TryOfferingTankBot");
	SearchForFunction("OnMobRushStart");
	SearchForFunction("Zombiemanager_SpawnITMob");
	SearchForFunction("Zombiemanager_SpawnMob");
	
	SearchForFunction("CTerrorPlayer_OnStaggered");
	SearchForFunction("CTerrorPlayer_OnShovedBySurvivor");
	SearchForFunction("CTerrorPlayer_GetCrouchTopSpeed");
	SearchForFunction("CTerrorPlayer_GetRunTopSpeed");
	SearchForFunction("CTerrorPlayer_GetWalkTopSpeed");
	SearchForFunction("HasConfigurableDifficulty"); // fails on windows
	SearchForFunction("DifficultyChanged");
	SearchForFunction("GetSurvivorSet");
	SearchForFunction("FastGetSurvivorSet");
	SearchForFunction("GetMissionVersusBossSpawning");
	SearchForFunction("CThrowActivate");
	SearchForFunction("StartMeleeSwing");
	SearchForFunction("ReadWeaponDataFromFileForSlot");
	
	/*
	* These searches will fail when slots are patched
	*/
	SearchForFunction("ConnectClientLobbyCheck");
	SearchForFunction("HumanPlayerLimitReached");
	SearchForFunction("GetMaxHumanPlayers");
	
	SearchForFunction("GetMasterServerPlayerCounts");

	//////

	RegConsoleCmd("sm_brst", Command_BeginRoundSetupTime);
	RegConsoleCmd("sm_rrn", Command_ResetRoundNumber);
	RegConsoleCmd("sm_sret", Command_SetRoundEndTime);
	RegConsoleCmd("sm_sig", Command_FindSig);
	
	RegConsoleCmd("sm_ir", Command_IsReserved);
	RegConsoleCmd("sm_rsfv", Command_RestartScenarioFromVote);
	RegConsoleCmd("sm_ur", Command_Unreserve);
	RegConsoleCmd("sm_horde", Command_Horde);
	RegConsoleCmd("sm_spawntime", Command_SpawnTimer);
	RegConsoleCmd("sm_l4d2timers", Command_L4D2Timers);
	
	RegConsoleCmd("sm_readweaponattr", Command_ReadWeaponAttributes);
	RegConsoleCmd("sm_setiweaponattr", Command_SetIntWeaponAttr);
	RegConsoleCmd("sm_setfweaponattr", Command_SetFloatWeaponAttr);
	
	RegConsoleCmd("sm_readmeleeattr", Command_ReadMeleeAttributes);
	RegConsoleCmd("sm_setimeleeattr", Command_SetIntMeleeAttr);
	RegConsoleCmd("sm_setfmeleeattr", Command_SetFloatMeleeAttr);
	RegConsoleCmd("sm_setbmeleeattr", Command_SetBoolMeleeAttr);
	
	RegConsoleCmd("sm_scores", Command_GetScores);
	RegConsoleCmd("sm_tankcnt", Command_GetTankCount);
	RegConsoleCmd("sm_flows", Command_GetTankFlows);
	

	cvarBlockRocks = CreateConVar("l4do_block_rocks", "0", "Disable CThrow::ActivateAbility", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	cvarBlockTanks = CreateConVar("l4do_block_tanks", "0", "Disable ZombieManager::SpawnTank", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	cvarBlockWitches = CreateConVar("l4do_block_witches", "0", "Disable ZombieManager::SpawnWitch", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	cvarSetCampaignScores = CreateConVar("l4do_set_campaign_scores", "0", "Override campaign score if non-0", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);

	cvarFirstSurvivorLeftSafeArea = CreateConVar("l4do_versus_round_started", "0", "Block versus round from starting if non-0", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	cvarProhibitBosses = CreateConVar("l4do_unprohibit_bosses", "0", "Override ProhibitBosses script key if non-0", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
}

public Action:Command_BeginRoundSetupTime(client, args)
{
	
	L4D_ScavengeBeginRoundSetupTime()
	
	return Plugin_Handled;
}


public Action:Command_ResetRoundNumber(client, args)
{
	
	L4D_ResetRoundNumber();
	
	return Plugin_Handled;
}



public Action:Command_SetRoundEndTime(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Error: Specify a round end time");
		return Plugin_Handled;
	}
	
	decl String:functionName[256];
	GetCmdArg(1, functionName, sizeof(functionName));
	new Float:time = StringToFloat(functionName);
	
	L4D_SetRoundEndTime(time);
	
	return Plugin_Handled;
}


public Action:Command_FindSig(client, args)
{
	/* 
	* DOES NOT ACTUALLY WORK :(
	* 
	*/
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Error: Specify a signature");
		return Plugin_Handled;
	}
	
	decl String:functionName[256];
	GetCmdArg(1, functionName, sizeof(functionName));
	new len = strlen(functionName);
	
	StartPrepSDKCall(SDKCall_Static);
	if(PrepSDKCall_SetSignature(SDKLibrary_Server, functionName, len)) {
		DebugPrintToAll("Signature '%s' initialized.", functionName);
	} else {
		DebugPrintToAll("Signature '%s' NOT FOUND.", functionName);
	}
	
	return Plugin_Handled;
}

public Action:L4D_OnSpawnTank(const Float:vector[3], const Float:qangle[3])
{
	DebugPrintToAll("OnSpawnTank(vector[%f,%f,%f], qangle[%f,%f,%f]", 
		vector[0], vector[1], vector[2], qangle[0], qangle[1], qangle[2]);
		
	if(GetConVarBool(cvarBlockTanks))
	{
		DebugPrintToAll("Blocking tank spawn...");
		return Plugin_Handled;
	}
	else
	{
		return Plugin_Continue;
	}
}

public Action:L4D_OnSpawnWitch(const Float:vector[3], const Float:qangle[3])
{
	DebugPrintToAll("OnSpawnWitch(vector[%f,%f,%f], qangle[%f,%f,%f])", 
		vector[0], vector[1], vector[2], qangle[0], qangle[1], qangle[2]);
		
	if(GetConVarBool(cvarBlockWitches))
	{
		DebugPrintToAll("Blocking witch spawn...");
		return Plugin_Handled;
	}
	else
	{
		return Plugin_Continue;
	}
}

public Action:L4D_OnClearTeamScores(bool:newCampaign)
{
	DebugPrintToAll("OnClearTeamScores(newCampaign=%d)", newCampaign); 
		
	return Plugin_Continue;
}

public Action:L4D_OnSetCampaignScores(&scoreA, &scoreB)
{
	DebugPrintToAll("SetCampaignScores(A=%d, B=%d", scoreA, scoreB); 
	
	if(GetConVarInt(cvarSetCampaignScores)) 
	{
		scoreA = GetConVarInt(cvarSetCampaignScores);
		DebugPrintToAll("Overrode with SetCampaignScores(A=%d, B=%d", scoreA, scoreB); 
	}
}

public Action:L4D_OnFirstSurvivorLeftSafeArea(client)
{
	DebugPrintToAll("OnFirstSurvivorLeftSafeArea(client=%d)", client); 
	
	if(GetConVarInt(cvarFirstSurvivorLeftSafeArea)) 
	{
		DebugPrintToAll("Blocking OnFirstSurvivorLeftSafeArea...");
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action:L4D_OnGetScriptValueInt(const String:key[], &retVal)
{
	//DebugPrintToAll("OnGetScriptValueInt(key=\"%s\",retVal=%d)", key, retVal); 
	
	if(GetConVarInt(cvarProhibitBosses) && StrEqual(key, "ProhibitBosses")) 
	{
		//DebugPrintToAll("Overriding OnGetScriptValueInt(ProhibitBosses)...");
		retVal = 0; //no, do not prohibit bosses thank you very much
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public L4D_OnEnterGhostState(client)
{
	DebugPrintToAll("L4D_OnEnterGhostState(client=%N)", client); 
}

public Action:L4D_OnTryOfferingTankBot(tank_index, &bool:enterStasis)
{
	DebugPrintToAll("L4D_OnTryOfferingTankBot() fired with tank %d and enterstasis %d", tank_index, enterStasis);
	return Plugin_Continue;
}

public Action:L4D_OnMobRushStart()
{
	DebugPrintToAll("L4D_OnMobRushStart() fired");
	return Plugin_Continue;
}

public Action:L4D_OnSpawnITMob(&amount)
{
	DebugPrintToAll("L4D_OnSpawnITMob(%d) fired", amount);
	return Plugin_Continue;
}

public Action:L4D_OnSpawnMob(&amount)
{
	DebugPrintToAll("L4D_OnSpawnMob(%d) fired", amount);
	return Plugin_Continue;
}

public Action:L4D_OnShovedBySurvivor(client, victim, const Float:vector[3])
{
	DebugPrintToAll("L4D_OnShovedBySurvivor() fired, victim %N", victim);
	
	if (client)
	{
		DebugPrintToAll("Shoving client: %N", client);
	}
	// return Plugin_Handled to completely stop melee effects on SI
	return Plugin_Continue;
}

// caution, those 3 are super spammy
public Action:L4D_OnGetCrouchTopSpeed(target, &Float:retVal)
{
	// DebugPrintToAll("OnOnGetCrouchTopSpeed(target=%N, retVal=%f)", target, retVal);
	return Plugin_Continue;
}

public Action:L4D_OnGetRunTopSpeed(target, &Float:retVal)
{
	// DebugPrintToAll("OnOnGetRunTopSpeed(target=%N, retVal=%f)", target, retVal);
	return Plugin_Continue;
}

public Action:L4D_OnGetWalkTopSpeed(target, &Float:retVal)
{
	// DebugPrintToAll("OnOnGetWalkTopSpeed(target=%N, retVal=%f)", target, retVal);
	return Plugin_Continue;
}

public Action:L4D_OnHasConfigurableDifficulty(&retVal)
{
	// 0 to disallow configuration, 1 to allow

	//DebugPrintToAll("OnGetDifficulty(retVal=%i)", retVal);
	
	//retVal = 1;
	//return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action:L4D_OnGetSurvivorSet(&retVal)
{
	// Which set of survivors should be used. 1=L4D1, 2=L4D2
	// Unfortunately has side effects. On L4D2 maps, Bot Character Icons and Score Names stay L4D2. Also, Zombie Skins appear bugged

	//DebugPrintToAll("OnGetSurvivorSet(retVal=%i)", retVal);
	//retVal = 1;
	//return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action:L4D_OnFastGetSurvivorSet(&retVal)
{
	// Which set of survivors should be used. 1=L4D1, 2=L4D2
	// Unfortunately has side effects. On L4D2 maps, Bot Character Icons and Score Names stay L4D2. Also, Zombie Skins appear bugged

	//DebugPrintToAll("OnFastGetSurvivorSet(retVal=%i)", retVal);
	//retVal = 1;
	//return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action:L4D_OnGetMissionVSBossSpawning(&Float:spawn_pos_min, &Float:spawn_pos_max, &Float:tank_chance, &Float:witch_chance)
{
	DebugPrintToAll("L4D_OnGetMissionVersusBossSpawning(%f, %f, %f, %f) fired", spawn_pos_min, spawn_pos_max, tank_chance, witch_chance);
	#if TEST_DEBUG_LOG
	LogMessage("L4D_OnGetMissionVersusBossSpawning(%f, %f, %f, %f) fired", spawn_pos_min, spawn_pos_max, tank_chance, witch_chance);
	#endif
	return Plugin_Continue;
}

public Action:L4D_OnCThrowActivate()
{
	DebugPrintToAll("L4D_OnCThrowActivate() fired");
	if(GetConVarBool(cvarBlockRocks))
	{
		DebugPrintToAll("Blocking!")
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:L4D_OnStartMeleeSwing(client, bool:boolean)
{
	DebugPrintToAll("L4D_OnStartMeleeSwing(client %i, boolean %i) fired", client, boolean);
	return Plugin_Continue;
}

public OnMapStart()
{
	//CreateTimer(0.1, Timer_GetCampaignScores, _);
}


public Action:Command_IsReserved(client, args)
{
#if USE_NATIVES
	//new bool:res = L4D_LobbyIsReserved();
	
	//DebugPrintToAll("Lobby is %s reserved...", res ? "" : "NOT");
#endif
	
	return Plugin_Handled;
}

public Action:Command_RestartScenarioFromVote(client, args)
{
#if USE_NATIVES
	decl String:currentmap[128];
	GetCurrentMap(currentmap, sizeof(currentmap));
	
	DebugPrintToAll("Restarting scenario from vote ...");
	L4D_RestartScenarioFromVote(currentmap);
#endif
	
	return Plugin_Handled;
}

public Action:Command_Unreserve(client, args)
{
#if USE_NATIVES
	DebugPrintToAll("Invoking L4D_LobbyUnreserve() ...");
	L4D_LobbyUnreserve();
#endif
	
	return Plugin_Handled;
}

public Action:Command_Horde(client, args)
{
#if USE_NATIVES
	new Float:hordetime = L4D2_CTimerGetRemainingTime(L4D2CT_MobSpawnTimer);
	new Float:hordeduration = L4D2_CTimerGetCountdownDuration(L4D2CT_MobSpawnTimer);
	DebugPrintToAll("Time remaining for next horde is: %f  Duration %f ", hordetime, hordeduration);
	ReplyToCommand(client, "Remaining: %f Duration: %f", hordetime, hordeduration);
#endif
}

public Action:Command_SpawnTimer(client, args)
{
#if USE_NATIVES
	new Float:SpawnTimer = L4D_GetPlayerSpawnTime(client);
	DebugPrintToAll("Spawn Timer for player %N: %f", client, SpawnTimer);
	ReplyToCommand(client, "Remaining: %f", SpawnTimer);
#endif
}

PrintL4D2CTimerJunk(client, const String:name[], L4D2CountdownTimer:timer)
{
	//DebugPrintToAll("%s - Remaining: %f Duration %f", name, L4D2CountdownTimerGetRemainingTime(timer), L4D2CountdownTimerGetCountdownDuration(timer));
	ReplyToCommand(client, "%s - Remaining: %f Duration %f", name, L4D2_CTimerGetRemainingTime(timer), L4D2_CTimerGetCountdownDuration(timer));
}

PrintL4D2ITimerJunk(client, const String:name[], L4D2IntervalTimer:timer)
{
	//DebugPrintToAll("%s - Elapsed: %f", name, L4D2IntervalTimerGetElapsedTime(timer));
	ReplyToCommand(client, "%s - Elapsed: %f", name, L4D2_ITimerGetElapsedTime(timer));
}

public Action:Command_L4D2Timers(client, args)
{
#if USE_NATIVES
	PrintL4D2CTimerJunk(client, "MobSpawnTimer", L4D2CT_MobSpawnTimer)
	PrintL4D2CTimerJunk(client, "SmokerSpawnTimer", L4D2CT_SmokerSpawnTimer);
	PrintL4D2CTimerJunk(client, "BoomerSpawnTimer", L4D2CT_BoomerSpawnTimer);
	PrintL4D2CTimerJunk(client, "HunterSpawnTimer", L4D2CT_HunterSpawnTimer);
	PrintL4D2CTimerJunk(client, "SpitterSpawnTimer", L4D2CT_SpitterSpawnTimer);
	PrintL4D2CTimerJunk(client, "JockeySpawnTimer", L4D2CT_JockeySpawnTimer);
	PrintL4D2CTimerJunk(client, "ChargerSpawnTimer", L4D2CT_ChargerSpawnTimer);
	PrintL4D2CTimerJunk(client, "VersusStartTimer", L4D2CT_VersusStartTimer);
	PrintL4D2CTimerJunk(client, "UpdateMarkersTimer", L4D2CT_UpdateMarkersTimer);
	PrintL4D2ITimerJunk(client, "SmokerDeathTimer", L4D2IT_SmokerDeathTimer);
	
	PrintL4D2ITimerJunk(client, "BoomerDeathTimer", L4D2IT_BoomerDeathTimer);
	PrintL4D2ITimerJunk(client, "HunterDeathTimer", L4D2IT_HunterDeathTimer);
	PrintL4D2ITimerJunk(client, "SpitterDeathTimer", L4D2IT_SpitterDeathTimer);
	PrintL4D2ITimerJunk(client, "JockeyDeathTimer", L4D2IT_JockeyDeathTimer);
	PrintL4D2ITimerJunk(client, "ChargerDeathTimer", L4D2IT_ChargerDeathTimer);
#endif
	return Plugin_Handled;
}

PrintL4D2IntWeaponAttrib(client, const String:weapon[], const String:name[], L4D2IntWeaponAttributes:attr)
{
	//DebugPrintToAll("%s = %f", name, L4D2_GetIntWeaponAttribute(weapon, attr));
	ReplyToCommand(client, "%s = %i", name, L4D2_GetIntWeaponAttribute(weapon, attr));
}

PrintL4D2FloatWeaponAttrib(client, const String:weapon[], const String:name[], L4D2FloatWeaponAttributes:attr)
{
	//DebugPrintToAll("%s = %f", name, L4D2_GetFloatWeaponAttribute(weapon, attr));
	ReplyToCommand(client, "%s = %f", name, L4D2_GetFloatWeaponAttribute(weapon, attr));
}

public Action:Command_ReadWeaponAttributes(client, args)
{
#if USE_NATIVES
	decl String:weapon[80];
	GetCmdArg(1, weapon, sizeof(weapon));
	
	ReplyToCommand(client, "Attributes for %s:", weapon);
	PrintL4D2IntWeaponAttrib(client, weapon, "Damage", L4D2IWA_Damage);
	PrintL4D2IntWeaponAttrib(client, weapon, "Bullets", L4D2IWA_Bullets);
	PrintL4D2IntWeaponAttrib(client, weapon, "ClipSize", L4D2IWA_ClipSize);
	PrintL4D2FloatWeaponAttrib(client, weapon, "MaxPlayerSpeed", L4D2FWA_MaxPlayerSpeed);
	PrintL4D2FloatWeaponAttrib(client, weapon, "SpreadPerShot", L4D2FWA_SpreadPerShot);
	PrintL4D2FloatWeaponAttrib(client, weapon, "MaxSpread", L4D2FWA_MaxSpread);
	PrintL4D2FloatWeaponAttrib(client, weapon, "SpreadDecay", L4D2FWA_SpreadDecay);
	PrintL4D2FloatWeaponAttrib(client, weapon, "MinDuckingSpread", L4D2FWA_MinDuckingSpread);
	PrintL4D2FloatWeaponAttrib(client, weapon, "MinStandingSpread", L4D2FWA_MinStandingSpread);
	PrintL4D2FloatWeaponAttrib(client, weapon, "MinInAirSpread", L4D2FWA_MinInAirSpread);
	PrintL4D2FloatWeaponAttrib(client, weapon, "MaxMovementSpread", L4D2FWA_MaxMovementSpread);
	PrintL4D2FloatWeaponAttrib(client, weapon, "PenetrationNumLayers", L4D2FWA_PenetrationNumLayers);
	PrintL4D2FloatWeaponAttrib(client, weapon, "PenetrationPower", L4D2FWA_PenetrationPower);
	PrintL4D2FloatWeaponAttrib(client, weapon, "PenetrationMaxDistance", L4D2FWA_PenetrationMaxDist);
	PrintL4D2FloatWeaponAttrib(client, weapon, "CharacterPenetrationMaxDistance", L4D2FWA_CharPenetrationMaxDist);
	PrintL4D2FloatWeaponAttrib(client, weapon, "Range", L4D2FWA_Range);
	PrintL4D2FloatWeaponAttrib(client, weapon, "RangeModifier", L4D2FWA_RangeModifier);
	PrintL4D2FloatWeaponAttrib(client, weapon, "CycleTime", L4D2FWA_CycleTime);
#endif
	return Plugin_Handled;
}

public Action:Command_SetIntWeaponAttr(client, args)
{
#if USE_NATIVES
	decl String:weapon[80], String:argbuf[32];
	GetCmdArg(1, weapon, sizeof(weapon));
	GetCmdArg(2, argbuf, sizeof(argbuf));
	new L4D2IntWeaponAttributes:attr = L4D2IntWeaponAttributes:StringToInt(argbuf);
	GetCmdArg(3, argbuf, sizeof(argbuf));
	new value = StringToInt(argbuf);
	ReplyToCommand(client, "%s: Attribute %d was %d", weapon, attr, L4D2_GetIntWeaponAttribute(weapon, attr));
	L4D2_SetIntWeaponAttribute(weapon, attr, value)
	ReplyToCommand(client, "%s: Attribute %d is now %d", weapon, attr, L4D2_GetIntWeaponAttribute(weapon, attr));
#endif
	return Plugin_Handled;
}

public Action:Command_SetFloatWeaponAttr(client, args)
{
#if USE_NATIVES
	decl String:weapon[80], String:argbuf[32];
	GetCmdArg(1, weapon, sizeof(weapon));
	GetCmdArg(2, argbuf, sizeof(argbuf));
	new L4D2FloatWeaponAttributes:attr = L4D2FloatWeaponAttributes:StringToInt(argbuf);
	GetCmdArg(3, argbuf, sizeof(argbuf));
	new Float:value = StringToFloat(argbuf);
	ReplyToCommand(client, "%s: Attribute %d was %f", weapon, attr, L4D2_GetFloatWeaponAttribute(weapon, attr));
	L4D2_SetFloatWeaponAttribute(weapon, attr, value);
	ReplyToCommand(client, "%s: Attribute %d is now %f", weapon, attr, L4D2_GetFloatWeaponAttribute(weapon, attr));
#endif
	return Plugin_Handled;
}



PrintL4D2IntMeleeAttrib(client, id, const String:name[], L4D2IntMeleeWeaponAttributes:attr)
{
	ReplyToCommand(client, "%s = %i", name, L4D2_GetIntMeleeAttribute(id, attr));
}

PrintL4D2FloatMeleeAttrib(client, id, const String:name[], L4D2FloatMeleeWeaponAttributes:attr)
{
	ReplyToCommand(client, "%s = %f", name, L4D2_GetFloatMeleeAttribute(id, attr));
}

PrintL4D2BoolMeleeAttrib(client, id, const String:name[], L4D2BoolMeleeWeaponAttributes:attr)
{
	ReplyToCommand(client, "%s = %b", name, L4D2_GetBoolMeleeAttribute(id, attr));
}

public Action:Command_ReadMeleeAttributes(client, args)
{
#if USE_NATIVES
	decl String:weapon[80];
	GetCmdArg(1, weapon, sizeof(weapon));
	new id = L4D2_GetMeleeWeaponIndex(weapon);
	if (id == -1)
	{
		ReplyToCommand(client, "%s not found in melee database", weapon);
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Attributes for %s:", weapon);
	
	PrintL4D2FloatMeleeAttrib(client, id, "Damage", L4D2FMWA_Damage);
	PrintL4D2FloatMeleeAttrib(client, id, "RefireDelay", L4D2FMWA_RefireDelay);
	PrintL4D2FloatMeleeAttrib(client, id, "WeaponIdleTime", L4D2FMWA_WeaponIdleTime);
	PrintL4D2IntMeleeAttrib(client, id, "DamageFlags", L4D2IMWA_DamageFlags);
	PrintL4D2IntMeleeAttrib(client, id, "RumbleEffect", L4D2IMWA_RumbleEffect);
	PrintL4D2BoolMeleeAttrib(client, id, "Decapitates", L4D2BMWA_Decapitates);
#endif
	return Plugin_Handled;
}

public Action:Command_SetIntMeleeAttr(client, args)
{
#if USE_NATIVES
	decl String:weapon[80], String:argbuf[32];
	GetCmdArg(1, weapon, sizeof(weapon));
	new id = L4D2_GetMeleeWeaponIndex(weapon);
	if (id == -1)
	{
		ReplyToCommand(client, "%s not found in melee database", weapon);
		return Plugin_Handled;
	}
	GetCmdArg(2, argbuf, sizeof(argbuf));
	new L4D2IntMeleeWeaponAttributes:attr = L4D2IntMeleeWeaponAttributes:StringToInt(argbuf);
	GetCmdArg(3, argbuf, sizeof(argbuf));
	new value = StringToInt(argbuf);
	ReplyToCommand(client, "%s: Attribute %d was %d", weapon, attr, L4D2_GetIntMeleeAttribute(id, attr));
	L4D2_SetIntMeleeAttribute(id, attr, value)
	ReplyToCommand(client, "%s: Attribute %d is now %d", weapon, attr, L4D2_GetIntMeleeAttribute(id, attr));
#endif
	return Plugin_Handled;
}

public Action:Command_SetFloatMeleeAttr(client, args)
{
#if USE_NATIVES
	decl String:weapon[80], String:argbuf[32];
	GetCmdArg(1, weapon, sizeof(weapon));
	new id = L4D2_GetMeleeWeaponIndex(weapon);
	if (id == -1)
	{
		ReplyToCommand(client, "%s not found in melee database", weapon);
		return Plugin_Handled;
	}
	GetCmdArg(2, argbuf, sizeof(argbuf));
	new L4D2FloatMeleeWeaponAttributes:attr = L4D2FloatMeleeWeaponAttributes:StringToInt(argbuf);
	GetCmdArg(3, argbuf, sizeof(argbuf));
	new Float:value = StringToFloat(argbuf);
	ReplyToCommand(client, "%s: Attribute %d was %f", weapon, attr, L4D2_GetFloatMeleeAttribute(id, attr));
	L4D2_SetFloatMeleeAttribute(id, attr, value);
	ReplyToCommand(client, "%s: Attribute %d is now %f", weapon, attr, L4D2_GetFloatMeleeAttribute(id, attr));
#endif
	return Plugin_Handled;
}

public Action:Command_SetBoolMeleeAttr(client, args)
{
#if USE_NATIVES
	decl String:weapon[80], String:argbuf[32];
	GetCmdArg(1, weapon, sizeof(weapon));
	new id = L4D2_GetMeleeWeaponIndex(weapon);
	if (id == -1)
	{
		ReplyToCommand(client, "%s not found in melee database", weapon);
		return Plugin_Handled;
	}
	GetCmdArg(2, argbuf, sizeof(argbuf));
	new L4D2BoolMeleeWeaponAttributes:attr = L4D2BoolMeleeWeaponAttributes:StringToInt(argbuf);
	GetCmdArg(3, argbuf, sizeof(argbuf));
	new value = StringToInt(argbuf);
	ReplyToCommand(client, "%s: Attribute %d was %d", weapon, attr, L4D2_GetBoolMeleeAttribute(id, attr));
	L4D2_SetBoolMeleeAttribute(id, attr, bool:value);
	ReplyToCommand(client, "%s: Attribute %d is now %d", weapon, attr, L4D2_GetBoolMeleeAttribute(id, attr));
#endif
	return Plugin_Handled;
}

public Action:Command_GetScores(client, args)
{
#if USE_NATIVES
	new scores[2];
	L4D2_GetVersusCampaignScores(scores);
	ReplyToCommand(client, "Score 0: %d Score 1: %d", scores[0], scores[1]);
#endif
	return Plugin_Handled;
}

public Action:Command_GetTankFlows(client, args)
{
#if USE_NATIVES
	new Float:flows[2];
	L4D2_GetVersusTankFlowPercent(flows);
	ReplyToCommand(client, "Flow 0: %f Flow 1: %f", flows[0], flows[1]);
#endif
	return Plugin_Handled;
}

public Action:Command_GetTankCount(client, args)
{
#if USE_NATIVES
	ReplyToCommand(client, "Tanks: %d", L4D2_GetTankCount());
#endif
	return Plugin_Handled;
}


SearchForFunction(const String:functionName[])
{
	StartPrepSDKCall(SDKCall_Static);
	if(PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, functionName)) {
		DebugPrintToAll("Function '%s' initialized.", functionName);
	} else {
		DebugPrintToAll("Function '%s' not found.", functionName);
	}
}


	
SearchForOffset(const String:offsetName[])
{
	new offset = GameConfGetOffset(gConf, offsetName);
	DebugPrintToAll("Offset for '%s' is %d", offsetName, offset);
}


DebugPrintToAll(const String:format[], any:...)
{
	#if TEST_DEBUG	|| TEST_DEBUG_LOG
	decl String:buffer[192];
	
	VFormat(buffer, sizeof(buffer), format, 2);
	
	#if TEST_DEBUG
	PrintToChatAll("[TEST-L4DO] %s", buffer);
	PrintToConsole(0, "[TEST-L4DO] %s", buffer);
	#endif
	
	LogMessage("%s", buffer);
	#else
	//suppress "format" never used warning
	if(format[0])
		return;
	else
		return;
	#endif
}