/************************************************************************************************************
Function: MSOT_fnc_startCount

Description: Starts a defined Cound Down and create a Explosion at defined Position

             Client/Server

Parameters: [NUMBER,POSITION,EXPLOSIONTYPE,(Optional: End the Mission for all)]

            NUMBER         -      Seconds for Countdown
            POSITION       -      Position for the Explosion
            EXPLOSIONTYPE  -      Explosiontypes can be:
                                  "SMOKE","BOMB","MORTAR","GLAUNCHER","HELIBIG","HELISMALL"
            ENDMISSION     =      (Optional) BOOL Ends the mission after the counter has ended - Default: true

Important: to Cancel the Count Down - missionNamespace getVariable ["msot_run_countdown",false,true]; on Client or Server

Returns: Nothing

Examples:
           nul = [120,(getMarkerPos "Target"),"BOMB"] spawn MSOT_fnc_startCount;       ++    with MissionEnding Function
           nul = [120,(getMarkerPos "Target"),"BOMB",false] spawn MSOT_fnc_startCount; ++    without MissionEnding Function

Author: Fry
*************************************************************************************************************/



MSOT_fnc_startCount = {
If(isMultiplayer)then{If(hasInterface)exitWith{};};
private ["_expl_ammo","_sync_counter","_counter","_bombname"];
params ["_seconds","_expl_pos","_expl_type","_end_mission"];

If(isNil "_end_mission")then{_end_mission = true;};
_expl_ammo = switch(_expl_type)do
             {
               case "SMOKE":{"SmokeShellArty"};
               case "BOMB":{"BO_GBU12_LGB"};
               case "MORTAR":{"R_80mm_HE"};
               case "GLAUNCHER":{"R_60mm_HE"};
               case "HELIBIG":{"HelicopterExploBig"};
               case "HELISMALL":{"HelicopterExploSmall"};
               default {"SMOKE"};
             };

_sync_counter = 0;
_counter = (_seconds + 1);
[_counter] remoteExec ["MSOT_fnc_actionCount",([0,-2] select isDedicated),false];
sleep 0.3;
while{_counter > 0 && {missionNamespace getVariable ["msot_run_countdown",true]}}do
{
  if(_sync_counter == 0)then{missionNamespace setVariable ["msot_sync_time",_counter,true];_sync_counter = 5;};
  _counter = _counter - 1; _sync_counter = _sync_counter - 1;
  sleep 1;
};
If(_counter < 1 && {missionNamespace getVariable ["msot_run_countdown",true]})then
{
  missionNamespace setVariable ["msot_run_countdown",false,true];
  _bombname = createVehicle [_expl_ammo,_expl_pos,[],0,"NONE"];
  sleep 15;
  If(isMultiplayer && _end_mission)then{"EveryoneLost" call BIS_fnc_endMissionServer;};
};
 missionNamespace setVariable ["msot_run_countdown",true,true];
};



MSOT_fnc_actionCount = {
If(!hasInterface)exitWith{};
private ["_new_counter","_txt","_txt_minutes","_txt_seconds","_calc_time","_sec_calc"];
params ["_seconds"];

_new_counter = _seconds;
_txt = "";
_txt_minutes = "00:";
_txt_seconds = "00";
while{_new_counter > 0 && {missionNamespace getVariable ["msot_run_countdown",true]}}do
{
  If((missionNamespace getVariable ["msot_sync_time",_seconds]) < _new_counter)then
  {_new_counter = missionNamespace getVariable ["msot_sync_time",_seconds];};
  _new_counter = _new_counter - 1;
  If(_new_counter > 59)then
  {
    _calc_time = _new_counter / 60; _sec_calc = (_calc_time - (floor _calc_time));
    If((floor _calc_time) > 9)then{_txt_minutes = format["%1:",(floor _calc_time)];}else{_txt_minutes = format["0%1:",(floor _calc_time)];};
    If((_sec_calc * 60) > 10)then{_txt_seconds = format["%1",(round(_sec_calc * 60))];}else{_txt_seconds = format["0%1",(round(_sec_calc * 60))];};
  }else{
         _txt_minutes = "00:";
         If(_new_counter > 9)then{_txt_seconds = format["%1",_new_counter];}else{_txt_seconds = format["0%1",_new_counter];};
       };
  _txt = _txt_minutes + _txt_seconds;
  If(_new_counter >= 10)then
  {
    hintSilent composeText[parseText("<t font = 'RobotoCondensed' size='2' align='center'>" + "COUNT DOWN:" + "</t>"),lineBreak, parseText("<t size='4' color='#f000ff00' align='center'>" + format ["%1",_txt] + "</t>")];
  }else{
         hintSilent composeText[parseText("<t font = 'RobotoCondensed' size='2' align='center'>" + "COUNT DOWN:" + "</t>"),lineBreak, parseText("<t size='4' color='#f0ff0000' align='center'>" + format ["%1",_txt] + "</t>")];
       };
  sleep 0.97;
};
};
