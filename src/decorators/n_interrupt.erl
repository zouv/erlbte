%% Author: zouv
%% Date: 2016-09-27
%% Doc: 

-module(n_interrupt).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-export([
		node_name/0,
		init/1,
		execute/3
	]).

node_name() ->
	"Interrupt".

init(_Parameters) ->
	{}.

execute(BteStatus, _Node, _IsFromStack) ->
	BteStatus.
