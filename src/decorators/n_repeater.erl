%% Author: zouv
%% Date: 2016-09-27
%% Doc: 

-module(n_repeater).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-export([
		node_name/0,
		init/1,
		execute/3
	]).

-record(r_data, {
		max_loop = 0,
		execute_times = 0
	}).

node_name() ->
	"Repeater".

init(Parameters) ->
 	MaxLoop = proplists:get_value("maxLoop", Parameters, 0),
	#r_data{max_loop = MaxLoop}.

execute(BteStatus, Node, _IsFromStack) ->
	execute1(BteStatus, Node).

execute1(BteStatus, Node) ->
	ExecuteTime = Node#r_bte_node.data#r_data.execute_times,
	if 
		ExecuteTime >= Node#r_bte_node.data#r_data.max_loop ->
			NewExecuteTime = 0,
			NewData = Node#r_bte_node.data#r_data{execute_times = NewExecuteTime},
			NewNode = Node#r_bte_node{data = NewData},
			bte_tick:update_node(BteStatus, NewNode);
		true ->
			?BTE_DEBUG("~p execute: ~p~n", [?MODULE, {ExecuteTime + 1, Node#r_bte_node.data#r_data.max_loop}]),
			ChildId = Node#r_bte_node.child,
			BteStatus1 = bte_tick:push_stack(BteStatus, ChildId),
			BteStatus2 = bte_tick:execute(BteStatus1, ChildId),
			NewExecuteTime = ExecuteTime + 1,
			NewData = Node#r_bte_node.data#r_data{execute_times = NewExecuteTime},
			NewNode = Node#r_bte_node{data = NewData},
			BteStatus3 = bte_tick:update_node(BteStatus2, NewNode),
			if 
				BteStatus3#r_bte_status.status /= ?BTE_RUNNING ->
					{BteStatus4, _} = bte_tick:pop_stack(BteStatus3),
					if 
						NewExecuteTime == Node#r_bte_node.data#r_data.max_loop ->
							BteStatus4;
						true ->
							BteStatus4#r_bte_status{status = ?BTE_RUNNING}
					end;
				true ->
					BteStatus3
			end
	end.
