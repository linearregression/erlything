%% Copyright (c) 2013 Ulf Angermann
%% See MIT-LICENSE for licensing information.

%%% -------------------------------------------------------------------
%%% Author  : Ulf Angermann uaforum1@googlemail.com
%%% Description :
%%%
%%% Created :  
-module(window_door_driver).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([init/1]).
-export([handle_msg/3]).
%% --------------------------------------------------------------------
%% if you want to initialize during startup, you have to do it here
%% --------------------------------------------------------------------
init(Config) ->
	lager:info("window_door_driver:init('~p')", [Config]),	
	gpio:set_interrupt(proplists:get_value(pin, Config) , proplists:get_value(int_type, Config)).

handle_msg({gpio_interrupt, 0, Pin, Status}, Config, Modul_config) ->
	lager:info("Pin : ~p with Status : ~p ", [Pin, Status]),
	Msg = create_message(Status, sensor:get_id(Config)),
	sensor:send_message(Msg),
	lager:info("send message : ~p", [Msg]),
	Module_config_1 = lists:keyreplace(last_changed, 1, Modul_config, {last_changed, date:get_date_seconds()}),
	lists:keyreplace(driver, 1, Config, {driver, {?MODULE, handle_msg}, Module_config_1}).

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
create_message(Status, Id) ->
	sensor:create_message(node(), ?MODULE, Id, date:get_date_seconds(), Status).
%% --------------------------------------------------------------------
%%% Test functions
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
-endif.