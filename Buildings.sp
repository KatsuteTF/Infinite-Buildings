// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>

public Plugin myinfo = {
    name        = "Infinite Buildings",
    author      = "Katsute",
    description = "Infinite buildings",
    version     = "1.0",
    url         = "https://github.com/KatsuteTF/Infinite-Buildings"
}

public OnPluginStart() {
    AddCommandListener(OnBuild, "build");
    HookEvent("player_builtobject", OnBuilt);
}

public void OnClientPutInServer(int client){
    SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitch);
}

public Action OnBuild(const int client, const char[] cmd, args){
    if(TF2_GetPlayerClass(client) == TFClass_Engineer){
        SetDisposableClient(client, true);
        CreateTimer(0.1, OnBuildDeferred, client);
    }
    return Plugin_Continue;
}

public Action OnBuildDeferred(const Event event, const int client){ // revert if not enough metal to build any
	if(IsClientInGame(client))
		OnWeaponSwitch(client, GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"));
	return Plugin_Continue;
}

public void OnBuilt(const Event event, const char[] name, const bool dontBroadcast){
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if(TF2_GetPlayerClass(client) == TFClass_Engineer)
        SetDisposableClient(client, false);
}

public Action OnWeaponSwitch(const int client, const int slot){
    if(IsClientInGame(client))
        if(TF2_GetPlayerClass(client) == TFClass_Engineer){
            if((slot == GetPlayerWeaponSlot(client, 0) || slot == GetPlayerWeaponSlot(client, 1) || slot == GetPlayerWeaponSlot(client, 2) || slot == GetPlayerWeaponSlot(client, 3) || slot == GetPlayerWeaponSlot(client, 4)))
                SetDisposableClient(client, slot == GetPlayerWeaponSlot(client, 3)); // PDA
        }else
            SetDisposableClient(client, false);
    return Plugin_Continue;
}

public void SetDisposableClient(const int client, const bool disposable){
    int ent = -1;
    while((ent = FindEntityByClassname(ent, "obj_sentrygun")) != -1)
        if(GetEntPropEnt(ent, Prop_Send, "m_hBuilder") == client)
            SetDisposable(ent, disposable);
    while((ent = FindEntityByClassname(ent, "obj_dispenser")) != -1)
        if(GetEntPropEnt(ent, Prop_Send, "m_hBuilder") == client)
            SetDisposable(ent, disposable);
    while((ent = FindEntityByClassname(ent, "obj_teleporter")) != -1)
        if(GetEntPropEnt(ent, Prop_Send, "m_hBuilder") == client)
            SetDisposable(ent, disposable);
}

public void SetDisposable(const int ent, const bool disposable){
    char name[20];
    GetEntityClassname(ent, name, 20);

    if(disposable)
        SetEntProp(ent, Prop_Send, "m_iObjectType", TFObject_Sapper);
    else if(strcmp(name, "obj_sentrygun") == 0)
        SetEntProp(ent, Prop_Send, "m_iObjectType", TFObject_Sentry);
    else if(strcmp(name, "obj_dispenser") == 0)
        SetEntProp(ent, Prop_Send, "m_iObjectType", TFObject_Dispenser);
    else if(strcmp(name, "obj_teleporter") == 0)
        SetEntProp(ent, Prop_Send, "m_iObjectType", TFObject_Teleporter);
}