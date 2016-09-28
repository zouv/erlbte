%% Author: zouv
%% Date: 2016-09-26
%% Doc: bte node config behaviour

-module(bte_node_behaviour).

-export([
		behaviour_info/1,
		init_nodes_moudle/1
	]).

%% define behaviour function
behaviour_info(callbacks) ->
	[
	 {node_name, 0},
	 {init, 1},
	 {execute, 3}
	];
behaviour_info(_Other) ->
    undefined.

%% init
init_nodes_moudle(Module) ->
	Path = filename:dirname(code:which(Module)),
	ModuleList = get_all_behaviour_mod(Path, ?MODULE),
	lists:map(fun(EModule) ->
		{EModule:node_name(), EModule}
	end,
	ModuleList).

%% find behavior module
get_all_behaviour_mod(Path, Behaviour) ->
	lists:filter(fun(Mod)-> check_mod_behaviour(Mod, Behaviour) end, get_path_module(Path)).

check_mod_behaviour(Mod, CheckBehav) ->
	check_mod_behaviour1(Mod:module_info('attributes'), CheckBehav).

check_mod_behaviour1([], _CheckBehav)-> false;
check_mod_behaviour1([{'behaviour', Behaviours} | L], CheckBehav)->
	case lists:member(CheckBehav, Behaviours) of
		true ->
			true;
		_ ->
			check_mod_behaviour1(L, CheckBehav)
	end;
check_mod_behaviour1([_ | L], CheckBehav) ->
	check_mod_behaviour1(L, CheckBehav).

get_path_module(Path) ->
	{ok, ALLFiles} = file:list_dir(Path),
	lists:foldl(fun(EFileName, AccModules)->
					case get_path_module1(EFileName) of
						[] ->
							AccModules;
						ENewModule ->
							[ENewModule | AccModules]
					end
				end,
				[],
				ALLFiles).

get_path_module1(FileName)->
	case string:right(FileName, 5) of
		".beam"->
			erlang:list_to_atom(string:substr(FileName, 1, string:len(FileName) - 5));
		_->
			[]
	end.
