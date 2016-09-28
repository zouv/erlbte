%% Author: zouv
%% Date: 2016-09-27
%% Doc: repeat until return success

-module(n_repeat_until_success).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-export([
		node_name/0,
		init/1,
		execute/3
	]).

node_name() ->
	"RepeatUntilSuccess".

init(_Parameters) ->
	{}.

execute(BteStatus, Node, IsFromStack) ->
	?BTE_DEBUG("~p execute: ~p~n", [?MODULE, {BteStatus#r_bte_status.status}]),
	if 
		IsFromStack ->
			if 
				BteStatus#r_bte_status.status == ?BTE_SUCCESS ->
					BteStatus;
				true ->
					execute1(BteStatus, Node)
			end;
		true ->
			execute1(BteStatus, Node)
	end.

execute1(BteStatus, Node) ->
	ChildId = Node#r_bte_node.child,
	BteStatus1 = bte_tick:push_stack(BteStatus, ChildId),
	BteStatus2 = bte_tick:execute(BteStatus1, ChildId),
	if 
		BteStatus2#r_bte_status.status /= ?BTE_RUNNING ->
			{BteStatus3, _} = bte_tick:pop_stack(BteStatus2),
			if 
				BteStatus3#r_bte_status.status /= ?BTE_SUCCESS ->
					BteStatus3#r_bte_status{status = ?BTE_RUNNING};
				true ->
					BteStatus3
			end;
		true ->
			BteStatus2
	end.
