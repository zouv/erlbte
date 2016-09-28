%% Author: zouv
%% Date: 2016-09-26
%% Doc: handle tick

-module(bte_tick).

-include("common.hrl").

-export([
		push_stack/2,
		pop_stack/1,
		execute/2,
		execute/3,
		get_node/2,
		update_node/2
	]).

push_stack(BteStatus, Id) ->
	BteStatus#r_bte_status{active_stack = [Id | BteStatus#r_bte_status.active_stack]}.

pop_stack(BteStatus) ->
	[Id | Left] = BteStatus#r_bte_status.active_stack,
	NewBteStatus = BteStatus#r_bte_status{active_stack = Left},
	{NewBteStatus, Id}.

get_node(BteStatus, Id) ->
	dict:fetch(Id, BteStatus#r_bte_status.nodes).

update_node(BteStatus, Node) ->
	NewNodes = dict:store(Node#r_bte_node.id, Node, BteStatus#r_bte_status.nodes),
	BteStatus#r_bte_status{nodes = NewNodes}.

execute(BteStatus, Id) ->
	execute(BteStatus, Id, false).

execute(BteStatus, Id, IsFromStack) ->
	Node = get_node(BteStatus, Id),
	Module = Node#r_bte_node.module,
	NewBteStatus = Module:execute(BteStatus, Node, IsFromStack),
	?BTE_DEBUG("> ~p execute: ~p~n", [?MODULE, {Node#r_bte_node.name, NewBteStatus#r_bte_status.status}]),
	NewBteStatus.
