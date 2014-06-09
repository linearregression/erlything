%% Copyright (c) 2013 Ulf Angermann
%% See MIT-LICENSE for licensing information.

%%% -------------------------------------------------------------------
%%% Author  : Ulf Angermann uaforum1@googlemail.com
%%% Description :
%%%
%%% Created :  
-module(cron_driver).

-include("../include/horst.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([init/1, stop/1, handle_msg/3]).
-export([send_message/1]).
init(Config) ->
    MD = config:get_module_config(Config), 
	lager:info("cron_driver:init('~p')", [MD]),
	Crontab = proplists:get_value(crontab, MD, []), 
    case application:start(erlcron) of
        ok -> start_jobs(Crontab),
        	  ok;
        {error, {already_started, erlcron}} ->
            ok
    end,
    {ok, Config}.
    
stop(Config) ->
	lager:info("stopping Module : ~p ", [?MODULE]),
	Crontab = proplists:get_value(crontab, Config, []), 
	stop_jobs(Crontab),
	application:stop(erlcron),
    {ok, Config}.

handle_msg([Node ,Sensor, Id, Time, {once, {Hour, Minutes, pm}}], Config, Module_config) ->
    Config;	 

handle_msg([Node ,Sensor, Id, Time, {once, Seconds}], Config, Module_config) ->
    Config;  

handle_msg([Node ,Sensor, Id, Time, {{daily, {every, {Seconds, sec}, {between, {From_hour, pm}, {To_hour, To_minutes, pm}}}}}], Config, Module_config) ->
    Config;  

handle_msg([Node ,Sensor, Id, Time, {daily, {Hour, Minutes, pm}}], Config, Module_config) ->
    Config;  

handle_msg(Message, Config, Module_config) ->
    lager:warning("cron_driver can't handle any message"),
    Config.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

%% This function will be used, when a cron job fires.
%% {daily,{every,{10,sec},{between,{6,am},{6,0,pm}}}},{cron_driver,send_message,["Test Message"]}}]}
%% TODO: How can i get the config from the cron_driver?
send_message(Message) ->
    lager:info("cron_driver will send the following message : ~p", [Message]),
    Config = [],
    ?SEND(Message).

start_jobs(Crontab) ->
	[erlcron:cron(Job) || Job <- Crontab].

stop_jobs(Crontab) ->
	[erlcron:cancel(Job) || Job <- Crontab].


%% --------------------------------------------------------------------
%%% Test functions
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).    
-endif.
