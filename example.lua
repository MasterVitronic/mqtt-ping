#!/usr/bin/env lua


local Obj = require ('mqtt-ping')

--broker	='broker.hivemq.com',
--broker	='broker.mqtt.cool',
--broker   	='13.126.72.131',
local opts = {
	broker	 ='ispcore20.com.ve',	--required
	id	 = 'pinger',		--optional default pinger
	port	 = 1883,		--optional default 1883
	topic    = 'pintest',		--optional default pintest
	interval = 1,			--optional default 1
	qos	 = 0			--optional default 2
}

Obj:new(opts):ping(20)
