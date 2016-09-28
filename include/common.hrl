
-define(BTE_SUCCESS, 	<<"SUCCESS">>).
-define(BTE_FAILURE, 	<<"FAILURE">>).
-define(BTE_RUNNING, 	<<"RUNNING">>).
-define(BTE_ERROR, 		<<"ERROR">>).

%% debug print
% -define(BTE_DEBUG, true). 	% comment this line to shield debug print
-ifdef(BTE_DEBUG).
-define(BTE_DEBUG(S), io:format("[bte_debug] " ++ S)).
-define(BTE_DEBUG(F, A), io:format("[bte_debug] " ++ F, A)).
-else.
-define(BTE_DEBUG(S), skip).
-define(BTE_DEBUG(F, A), skip).
-endif.

%% for init config
-record(r_bte_config_data, {
		root_id = "",
		nodes = [],
		custom_nodes_moudle = []
	}).

-record(r_bte_config_node, {
		id = "",
		name = "",
		parameters = [],
		child = "",
		children = []
	}).

%% for execute
-record(r_bte_status, {
		root_id = "",
		nodes = [],
		status = undefined,
		active_stack = []
	}).

-record(r_bte_node, {
		id = "",
		name = "",
		child = "",
		children = [],
		module = undefined,
		data = []
	}).
