#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define PLUGIN_VERSION "2.0"

Handle cvDelay = INVALID_HANDLE;
Handle cvType = INVALID_HANDLE;

public Plugin myinfo =
{
  name = "Dissolve",
  author = "L. Duke, Doshik, maxime1907",
  description = "Dissolves dead bodies",
  version = PLUGIN_VERSION,
  url = "http://www.lduke.com/"
};

public void OnPluginStart() 
{ 
  HookEvent("player_death", PlayerDeath);

  CreateConVar("sm_dissolve_version", PLUGIN_VERSION, "Dissolve", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
  cvDelay = CreateConVar("sm_dissolve_delay", "2");
  cvType = CreateConVar("sm_dissolve_type", "0");

  AutoExecConfig(true);
}

public void OnEventShutdown()
{
  UnhookEvent("player_death", PlayerDeath);
}

public Action PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));

  float delay = GetConVarFloat(cvDelay);
  if (delay > 0.0)
    CreateTimer(delay, Dissolve, client); 
  else
    Dissolve(INVALID_HANDLE, client);

  return Plugin_Continue;
}

public Action Dissolve(Handle timer, any client)
{
  if (!IsValidEntity(client))
    return;

  int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
  if (ragdoll < 0)
    return;

  char dname[32];
  char dtype[32];
  Format(dname, sizeof(dname), "dis_%d", client);
  Format(dtype, sizeof(dtype), "%d", GetConVarInt(cvType));

  int ent = CreateEntityByName("env_entity_dissolver");
  if (ent > 0)
  {
    DispatchKeyValue(ragdoll, "targetname", dname);
    DispatchKeyValue(ent, "dissolvetype", dtype);
    DispatchKeyValue(ent, "target", dname);
    AcceptEntityInput(ent, "Dissolve");
    AcceptEntityInput(ent, "kill");
  } 
}