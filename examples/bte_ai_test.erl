%% @author zouv
%% @doc testing bte ai

-module(bte_ai_test).

-include_lib("erlbte/include/common.hrl").

-export([
		test/1
	]).

% json file edit by "Behavior3JS Edotor"
% url: http://behavior3js.guineashots.com
test(FileName) ->
    case file:read_file("json/" ++ FileName) of
		{ok, EBinary} ->
			{ok, BteStatus} = bte_ai:init(EBinary),
			io:format("s1:~p~n", [BteStatus#r_bte_status.status]),
			BteStatus1 = bte_ai:tick(BteStatus),
			io:format("s2:~p~n", [BteStatus#r_bte_status.status]),
			% BteStatus2 = bte_ai:tick(BteStatus1),  % testing bte stack
			% BteStatus3 = bte_ai:tick(BteStatus2),
			% BteStatus4 = bte_ai:tick(BteStatus3),
			% BteStatus5 = bte_ai:tick(BteStatus4),
			ok;
		_ ->
			skip
	end.

