%% Author: zouv
%% Date: 2016-09-26
%% Doc: tools

-module(bte_util).

-export([
		init_rand_seed/0,
		rand/2
	]).

init_rand_seed() ->
    random:seed(erlang:now()).

rand(Min, Max) when Min == Max ->
	Min;
rand(Min, Max) when Min >= Max ->
	rand(Max, Min);
rand(Min, Max) ->
	Min1 = Min - 1,
	random:uniform(Max - Min1) + Min1.
