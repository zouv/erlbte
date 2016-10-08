
# erlbte
Behavior Tree for erlang

## examples
![exp1](https://raw.githubusercontent.com/zouv/erlbte/master/examples/json/test3.png)

## testing
###### examples/bte_ai_test.erl
```javascript
test(FileName) ->
  case file:read_file("json/" ++ FileName) of
    {ok, EBinary} ->
      {ok, BteStatus} = bte_ai:init(EBinary),
      io:format("s1:~p~n", [BteStatus#r_bte_status.status]),	
      BteStatus1 = bte_ai:tick(BteStatus),
      io:format("s2:~p~n", [BteStatus1#r_bte_status.status]),
      ok;
    _ ->
	  skip
  end.
```
* how to test
    * bte_ai_test:test("test2.json").

