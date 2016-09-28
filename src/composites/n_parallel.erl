%% Author: zouv
%% Date: 2016-09-26
%% Doc: Parallel Node

-module(n_parallel).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-export([
		node_name/0,
		init/1,
		execute/3
	]).

-record(r_data, {
		tick_index = 0
	}).

node_name() ->
	"Parallel".

init(_Parameters) ->
	#r_data{}.

execute(BteStatus, _Node, _IsFromStack) ->
	BteStatus.
