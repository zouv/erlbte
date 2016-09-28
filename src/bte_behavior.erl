%% Author: zouv
%% Date: 2016-09-26
%% Doc: main module

-module(bte_behavior).

-include("common.hrl").

-export([
		init/1,
		tick/1
	]).

init(BteConfigData) ->
	bte_util:init_rand_seed(),
	BteStatus = 
		#r_bte_status{
			root_id = BteConfigData#r_bte_config_data.root_id,
			nodes = dict:new()
		},
	CoreNodesModule = bte_node_behaviour:init_nodes_moudle(?MODULE),
	AllNodesModule = CoreNodesModule ++ BteConfigData#r_bte_config_data.custom_nodes_moudle,
	lists:foldl(fun(E, Acc) ->
		case lists:keyfind(E#r_bte_config_node.name, 1, AllNodesModule) of
			{ENodeName, EModule} ->
				EData = EModule:init(E#r_bte_config_node.parameters),
				ENode = 
					#r_bte_node{
						id = E#r_bte_config_node.id,
						name = ENodeName,
						child = E#r_bte_config_node.child,
						children = E#r_bte_config_node.children,
						module = EModule,
						data = EData
					},
				bte_tick:update_node(Acc, ENode);
			_ ->
				io:format("init behavior tree Error! undefined node info : ~p~n", [E]),
				Acc
		end
	end,
	BteStatus,
	BteConfigData#r_bte_config_data.nodes).

tick(BteStatus) ->
	?BTE_DEBUG("tick: ~p~n", [length(BteStatus#r_bte_status.active_stack)]),
	if 
		length(BteStatus#r_bte_status.active_stack) > 0 ->
			tick_handle_stack(BteStatus);
		true ->
			tick_handle(BteStatus#r_bte_status{status = undefined})
	end.

tick_handle_stack(BteStatus) ->
	if 
		length(BteStatus#r_bte_status.active_stack) > 0 ->
			{BteStatus1, NodeId} = bte_tick:pop_stack(BteStatus),
			BteStatus2 = bte_tick:push_stack(BteStatus1, NodeId),
			BteStatus3 = bte_tick:execute(BteStatus2, NodeId, true),
			if 
				BteStatus3#r_bte_status.status /= ?BTE_RUNNING ->
					{BteStatus4, _} = bte_tick:pop_stack(BteStatus3),
					tick_handle_stack(BteStatus4);
				true ->
					BteStatus3
			end;
		true ->
			BteStatus
	end.

tick_handle(BteStatus) ->
	BteStatus1 = bte_tick:push_stack(BteStatus, BteStatus#r_bte_status.root_id),
	BteStatus2 = bte_tick:execute(BteStatus1, BteStatus1#r_bte_status.root_id),
	if 
		BteStatus2#r_bte_status.status /= ?BTE_RUNNING ->
			{BteStatus3, _} = bte_tick:pop_stack(BteStatus2),
			BteStatus3;
		true ->
			BteStatus2
	end.
