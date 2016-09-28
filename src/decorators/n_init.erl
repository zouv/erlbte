%% Author: zouv
%% Date: 2016-09-27
%% Doc: 

-module(n_init).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-export([
		node_name/0,
		init/1,
		execute/3
	]).

-record(r_data, {
		is_init = false
	}).

node_name() ->
	"Init".

init(_Parameters) ->
	#r_data{}.

execute(BteStatus, Node, _IsFromStack) ->
	if 
		Node#r_bte_node.data#r_data.is_init ->
			BteStatus;
		true ->
			?BTE_DEBUG("~p execute: ~p~n", [?MODULE, {BteStatus#r_bte_status.status}]),
			ChildId = Node#r_bte_node.child,
			BteStatus1 = bte_tick:push_stack(BteStatus, ChildId),
			BteStatus2 = bte_tick:execute(BteStatus1, ChildId),
			if 
				BteStatus2#r_bte_status.status /= ?BTE_RUNNING ->
					{BteStatus3, _} = bte_tick:pop_stack(BteStatus2);
				true ->
					BteStatus3 = BteStatus2
			end,
			NewData = #r_data{is_init = true},
			NewNode = Node#r_bte_node{data = NewData},
			bte_tick:update_node(BteStatus3, NewNode)
	end.
