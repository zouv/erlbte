%% Author: zouv
%% Date: 2016-09-26
%% Doc: Wait Action Node

-module(n_wait).
-behaviour(bte_node_behaviour).

-include("common.hrl").

-export([
		node_name/0,
		init/1,
		execute/3
	]).

node_name() ->
	"Wait".

init(_Parameters) ->
	{}.

%% only for test
execute(BteStatus, _Node, _IsFromStack) ->
	case util:rand(1, 3) of
		1 ->
			Status = ?BTE_SUCCESS;
		2 ->
			Status = ?BTE_FAILURE;
		_ ->
			Status = ?BTE_RUNNING
	end,
	BteStatus#r_bte_status{status = Status}.
	% BteStatus.
