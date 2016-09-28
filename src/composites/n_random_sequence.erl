%% Author: zouv
%% Date: 2016-09-26
%% Doc: Random Sequence Node

-module(n_random_sequence).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-record(r_data, {
		tick_children = []
	}).

-export([
		node_name/0,
		init/1,
		execute/3
	]).

node_name() ->
	"RandomSequence".

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
			execute1(BteStatus, Node#r_bte_node{data = #r_data{tick_children = Node#r_bte_node.children}})
	end.

execute1(BteStatus, Node) ->
	Children = Node#r_bte_node.data#r_data.tick_children,
	if 
		length(Children) > 0 ->
			ChildId = lists:nth(bte_util:rand(1, length(Children)), Children),
			?BTE_DEBUG("~p execute___1: ~p~n", [?MODULE, {length(Children) - 1}]),
			BteStatus1 = bte_tick:push_stack(BteStatus, ChildId),
			BteStatus2 = bte_tick:execute(BteStatus1, ChildId),
			if 
				BteStatus2#r_bte_status.status /= ?BTE_RUNNING ->
					{BteStatus3, _} = bte_tick:pop_stack(BteStatus2);
				true ->
					BteStatus3 = BteStatus2
			end,
			LeftChildren = lists:delete(ChildId, Children),
			Data = Node#r_bte_node.data,
			if 
				BteStatus3#r_bte_status.status == ?BTE_FAILURE ->
					NewData = Data#r_data{tick_children = Node#r_bte_node.children},
					NewNode = Node#r_bte_node{data = NewData},
					bte_tick:update_node(BteStatus3, NewNode);
				BteStatus3#r_bte_status.status == ?BTE_RUNNING ->
					NewData = Data#r_data{tick_children = LeftChildren},
					NewNode = Node#r_bte_node{data = NewData},
					bte_tick:update_node(BteStatus3, NewNode);
				true ->
					NewData = Data#r_data{tick_children = LeftChildren},
					NewNode = Node#r_bte_node{data = NewData},
					execute1(BteStatus3, NewNode)
			end;
		true ->
			BteStatus
	end.
