%% Author: zouv
%% Date: 2016-09-26
%% Doc: Sequence Node

-module(n_sequence).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-record(r_data, {
		tick_index = 0
	}).

-export([
		node_name/0,
		init/1,
		execute/3
	]).

node_name() ->
	"Sequence".

init(_Parameters) ->
	#r_data{}.

execute(BteStatus, Node, IsFromStack) ->
	?BTE_DEBUG("~p execute: ~p~n", [?MODULE, {IsFromStack, BteStatus#r_bte_status.status, length(Node#r_bte_node.children)}]),
	if 
		IsFromStack ->
			if 
				BteStatus#r_bte_status.status == ?BTE_FAILURE ->
					BteStatus;
				true ->
					execute1(BteStatus, Node)
			end;
		true ->
			execute1(BteStatus, Node#r_bte_node{data = #r_data{}})
	end.

execute1(BteStatus, Node) ->
	execute2(Node#r_bte_node.children, BteStatus, 1, Node).

execute2([], BteStatus, _Index, _Node) ->
	BteStatus;
execute2([ChildId | LeftChildren], BteStatus, Index, Node) ->
	Data = Node#r_bte_node.data,
	TickIndex = Data#r_data.tick_index,
	?BTE_DEBUG("~p execute___2: ~p~n", [?MODULE, {TickIndex, Index, length(LeftChildren)}]),
	if  
		Index > TickIndex ->
			BteStatus1 = bte_tick:push_stack(BteStatus, ChildId),
			BteStatus2 = bte_tick:execute(BteStatus1, ChildId),
			if 
				BteStatus2#r_bte_status.status /= ?BTE_RUNNING ->
					{BteStatus3, _} = bte_tick:pop_stack(BteStatus2);
				true ->
					BteStatus3 = BteStatus2
			end,
			if 
				BteStatus3#r_bte_status.status == ?BTE_FAILURE ->
					NewData = Data#r_data{tick_index = 0},
					NewNode = Node#r_bte_node{data = NewData},
					bte_tick:update_node(BteStatus3, NewNode);
				BteStatus3#r_bte_status.status == ?BTE_RUNNING ->
					NewData = Data#r_data{tick_index = Index},
					NewNode = Node#r_bte_node{data = NewData},
					bte_tick:update_node(BteStatus3, NewNode);
				true ->
					execute2(LeftChildren, BteStatus3, Index + 1, Node)
			end;
		true ->
			execute2(LeftChildren, BteStatus, Index + 1, Node)
	end.
