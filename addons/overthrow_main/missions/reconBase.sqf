params ["_jobid","_jobparams"];
_jobparams params ["_base","_markerPos"];

_params = [_base];
private _effect = "<t size='0.9'>Reward: $1,500 to player closest to base</t>";

//Build a mission description and title
private _description = format["Get information on the NATO forces and vehicles garrisoned at %1. A pair of Binoculars or Rangefinder may come in handy. Be careful not to get too close as NATO bases are restricted areas.<br/><br/>%2",_base,_effect];
private _title = format["Recon of %1",_base];

//The data below is what is returned to the gun dealer/faction rep, _markerPos is where to put the mission marker, the code in {} brackets is the actual mission code, only run if the player accepts
[
    [_title,_description],
    _markerPos,
    {
        //No setup required for this mission
    },
    {
        //Fail check...
        false
    },
    {
        //Success Check
        params ["_base"];
        private _spawnid = spawner getVariable [format["spawnid%1",_base],""];
        if(_spawnid isEqualTo "") exitWith {false}; //Base has not been spawned yet
        //Get groups in spawn
        _groups = spawner getVariable [_spawnid,[]];
        if(count _groups == 0) exitWith {false}; //Base is empty/not spawned atm

        _missedOne = false;
        {
            if ((typename _x isEqualTo "GROUP") && !isNull (leader _x)) then {
                if((vehicle leader _x) == leader _x) then {
                    if((resistance knowsAbout (leader _x)) < 1.4) then {_missedOne = true}; //does the resistance know about the leader of this group?
                }else{
                    _group = _x;
                    {
                        if((resistance knowsAbout (vehicle _x)) < 1.4) then {_missedOne = true}; //does the resistance know about this vehicle?
                    }foreach(units _group);
                };
            };
        }foreach(_groups);

        !_missedOne
    },
    {
        params ["_base","_wassuccess"];

        //If mission was a success
        if(_wassuccess) then {
            private _loc = server getVariable _base;
            private _players = [];
            {
                if(isPlayer _x && alive _x) then {
                    _players pushback _x;
                };
            }foreach(_loc nearEntities ["Man",OT_spawnDistance]);
            _players = _players apply {[_x distance _loc, _x]};
            _players sort true;

            [
                1500,
                format["Recon of %1 completed",_base]
            ] remoteExec ["OT_fnc_money",_players select 0,false];
        };
    },
    _params
];
