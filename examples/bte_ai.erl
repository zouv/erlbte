%% @author zouv
%% @doc use bte for ai

-module(bte_ai).

-include_lib("erlbte/include/common.hrl").

-export([
		init/1,
		tick/1
	]).

init(Data) ->
	{ok, Json, _} = rfc4627:decode(Data), % depend on rfc4627_jsonrpc
	RootId = get_field_string(Json, "root"),
	{ok, NodesJson} = rfc4627:get_field(Json, "nodes"),
	NodeList = init_nodes([RootId], NodesJson, []),
	CustomNodesModule = bte_node_behaviour:init_nodes_moudle(?MODULE), % load self-defined bte node
	BteConfigData = 
		#r_bte_config_data{
			root_id = RootId,
			nodes = NodeList,
			custom_nodes_moudle = CustomNodesModule
		},
	BteStatus = bte_behavior:init(BteConfigData),
	{ok, BteStatus}.

init_nodes([], _NodesJson, NodeList) ->
	NodeList;
init_nodes([Id | LeftIdList], NodesJson, NodeList) ->
	{ok, NodeJson} = rfc4627:get_field(NodesJson, Id),
	Name = get_field_string(NodeJson, "name"),
	{ok, Parameters} = rfc4627:get_field(NodeJson, "parameters"),
	ChildId = binary_to_list(rfc4627:get_field(NodeJson, "child", <<>>)),
	Children = lists:map(fun(E) -> binary_to_list(E) end, rfc4627:get_field(NodeJson, "children", [])),
	BteNode = 
		#r_bte_config_node{
			id = Id,
			name = Name,
			parameters = get_all(Parameters),
			child = ChildId,
			children = Children
		},
	NewNodeList = [BteNode | NodeList],
	if 
		ChildId /= "" ->
			init_nodes([ChildId | LeftIdList], NodesJson, NewNodeList);
		Children /= [] ->
			init_nodes(Children ++ LeftIdList, NodesJson, NewNodeList);
		true ->
			init_nodes(LeftIdList, NodesJson, NewNodeList)
	end.

get_field_string(Json, Key) ->
	{ok, Value} = rfc4627:get_field(Json, Key),
	binary_to_list(Value).

get_all(Parameters) ->
	{obj, PrapList} = Parameters,
	lists:map(fun({EKey, EValue}) ->
		if 
			is_binary(EValue) ->
				ENewValue = binary_to_list(EValue);
			true ->
				ENewValue = EValue
		end,
		{EKey, ENewValue}
	end,
	PrapList).

tick(BteStatus) ->
	bte_behavior:tick(BteStatus).

