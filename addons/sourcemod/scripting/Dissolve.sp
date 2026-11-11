#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

#define PLUGIN_VERSION "2.1.4"

ConVar cvDelay = null;
ConVar cvType = null;

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

public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
  int userid = event.GetInt("userid");

  float delay = cvDelay.FloatValue;
  if (delay > 0.0)
    CreateTimer(delay, Timer_Dissolve, userid, TIMER_FLAG_NO_MAPCHANGE);
  else
    Dissolve(GetClientOfUserId(userid));

  return Plugin_Continue;
}

public Action Timer_Dissolve(Handle timer, any userid)
{
  Dissolve(GetClientOfUserId(userid));
  return Plugin_Stop;
}

void Dissolve(int client)
{
  if (!client || !IsClientInGame(client))
    return;

  int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
  if (ragdoll <= 0)
    return;

  char dname[32];
  char dtype[32];
  Format(dname, sizeof(dname), "dis_%d", client);
  Format(dtype, sizeof(dtype), "%d", cvType.IntValue);

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