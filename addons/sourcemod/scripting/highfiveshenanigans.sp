/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod High Five Shenanigans Plugin
 * Bunch of random out comes for a high-five event including:
 - "the Quarnozian High-Five of Death"
 - Turning oponent to gold
 - Teleporting to limbo on Eyeaduct
 - Teleporting to skybox
 - 
 * 
 *
 * =============================================================================
 *
 */

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <smlib>
#include <sdktools>

#pragma semicolon 1
#define PL_VERSION "1.02"

#define H5_RANDOM 0
#define H5_DISSOLVE 1
#define H5_DECAP 2
#define H5_STATUE 3
#define H5_FLYING 4

public Plugin:myinfo =
{
    name = "High Five Shenanigans",
	version = PL_VERSION,
    author = "Billehs",
    description = "Who knows what will happen when you high-five me",
    url = "https://github.com/CrimsonTautology/sm_highfive_shenanigans"
};

new Handle:g_Enabled;
new Handle:g_CustomType;

public OnPluginStart(){
    CreateConVar("sm_highfive_shenanigans_version", PL_VERSION, "[TF2] High Five Shenanigans", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
    g_CustomType = CreateConVar("sm_highfive_type", "0", "[HIGH5] What type of highfive death you want.", FCVAR_PLUGIN);
    g_Enabled = CreateConVar("sm_highfive_enabled", "1", "[HIGH5] Do you want high fives of death?", FCVAR_PLUGIN, true, 0.0, true, 1.0);

    HookEvent("player_highfive_success", Event_HighFiveSuccess);
}

//Triggers the moment a highfive is accepted
public Action:Event_HighFiveSuccess(Handle:event, const String:name[], bool:dontBroadcast){
    //Bail if plugin is not enabled
    if(!GetConVarBool(g_Enabled)){
        return Plugin_Continue;
    }

    new initiator = EntIndexToEntRef(GetEventInt(event, "initiator_entindex"));
    new partner = EntIndexToEntRef(GetEventInt(event, "partner_entindex"));

    //Create a pack to send info to our death timer
    new Handle:pack = CreateDataPack();
    CreateTimer(1.9, HighFiveOfDeath, pack);
    WritePackCell(pack, initiator);
    WritePackCell(pack, partner);

    return Plugin_Continue;
}

//A timer to trigger the "Quarnozian High-Five of Death"
public Action:HighFiveOfDeath(Handle:timer, Handle:pack){
    new attacker, victim, deathType;


    if(GetConVarInt(g_CustomType) == H5_RANDOM){
        //If random, set the type based on the hour so simmilar deaths occur together
        deathType = (GetTime() / 3600) % 5;
    }else{
        deathType = GetConVarInt(g_CustomType);
    }

    //Reset the pack to read it then read the attacker and victim
    ResetPack(pack);
    attacker = EntRefToEntIndex(ReadPackCell(pack));
    victim = EntRefToEntIndex(ReadPackCell(pack));

    if(deathType == H5_DISSOLVE){
        DissolveEffect(victim);
    }else if(deathType == H5_STATUE){
        StatueEffect(victim);
    }else if(deathType == H5_DECAP){
        DecapEffect(victim);
    }else if(deathType == H5_FLYING){
        PushPlayer(victim, attacker);
    }else {
        ForcePlayerSuicide(victim);
    }

    CloseHandle(pack);
}



//Turn the victim into a custom ragdoll type
RagdollEffect(victim, type){
    //Make sure this makes sense in the first place
    if(victim>0 && IsValidEdict(victim) && IsClientInGame(victim) && IsPlayerAlive(victim)) {
        //Kill player, dispose of their ragdoll
        ForcePlayerSuicide(victim);
        new ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");

        if(ragdoll < 0){
            PrintToServer("[HIGH5] Could not get player's ragdoll");
        }
        SetEntProp(ragdoll, Prop_Send, "m_iDamageCustom", type);
    }

}

//Have attacker push a victim
PushPlayer(victim, attacker){
    new Float:vector[3];

    new Float:attackerOrigin[3];
    new Float:victimOrigin[3];

    GetClientAbsOrigin(attacker, attackerOrigin);
    GetClientAbsOrigin(victim, victimOrigin);

    MakeVectorFromPoints(attackerOrigin, victimOrigin, vector);

    NormalizeVector(vector, vector);
    ScaleVector(vector, 4000.0);
    vector[2] = 900.0;

    TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vector);
    CreateTimer(0.01, DelayKill, victim);
}

//Used to delay a kill so a ragdoll will have proper effects
public Action:DelayKill(Handle:timer, any:client){
    ForcePlayerSuicide(client);
}
//Kill victim and dissolve their ragdoll
DissolveEffect(victim){
    RagdollEffect(victim, TF_CUSTOM_PLASMA);
}

//Kill and turn into a statue
StatueEffect(victim){
    RagdollEffect(victim, TF_CUSTOM_GOLD_WRENCH);
}
//Kill and decapitate
DecapEffect(victim){
    RagdollEffect(victim, TF_CUSTOM_DECAPITATION);
}


//Nice melons, high-five?
