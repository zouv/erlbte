%% Author: zouv
%% Date: 2016-09-27
%% Doc: ever return failure

-module(n_return_failure).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-export([
		node_name/0,
		init/1,
		execute/3
	]).

node_name() ->
	"ReturnFailure".

init(_Parameters) ->
	{}.

execute(BteStatus, Node, IsFromStack) ->
	if 
		IsFromStack ->
			BteStatus#r_bte_status{status = ?BTE_FAILURE};
		true ->
			execute1(BteStatus, Node)
	end.

execute1(BteStatus, Node) ->
	ChildId = Node#r_bte_node.child,
	?BTE_DEBUG("~p execute: ~p~n", [?MODULE, {BteStatus#r_bte_status.status}]),
	BteStatus1 = bte_tick:push_stack(BteStatus, ChildId),
	BteStatus2 = bte_tick:execute(BteStatus1, ChildId),
	if 
		BteStatus2#r_bte_status.status /= ?BTE_RUNNING ->
			{BteStatus3, _} = bte_tick:pop_stack(BteStatus2),
			BteStatus3#r_bte_status{status = ?BTE_FAILURE};
		true ->
			BteStatus2
	end.
