--[[!
 @package   
 @filename  mqtt-ping.lua
 @version   1.0
 @autor     Máster Vitronic <mastervitronic@gmail.com>
 @date      24/02/2021 15:06:29 -04
 @licence   MIT licence
]]--

local M 	= {}
M.__index 	= M;

--@see http://luaforge.net/projects/luasocket/
local socket	= require('socket')
--@see https://github.com/luaposix/luaposix
local signal	= require("posix.signal")
--@see https://github.com/flukso/lua-mosquitto
local mqtt	= require('mosquitto')
--@see https://www.kyne.com.au/~mark/software/lua-cjson.php
local json	= require('cjson.safe')

local connected	= false
local response	= true
local tstart,elapsed,received = 0,0,0

---The constructor
function M.new(_, ...)
	args	    = ...
	if (not (type(args) == 'table')) then
		return false, 'Invalid arguments'
	end
	local self  	= setmetatable({}, {__index=M})
	self.broker 	= args.broker or 'localhost'
	self.cname  	= args.id     or 'pinger'
	self.port   	= args.port   or 1883
	self.qos	= args.qos    or 2
	self.username	= args.username or nil
	self.password	= args.password or nil
	self.interval	= tonumber(args.interval) or 1
	self.topic	= args.topic  or 'pingtest'
	self.keepalive	= args.keepalive  or 60
	self.client	= mqtt.new(self.cname,true)
	return self
end

---Routine to connect to broker
function M:connect()
	local conn,wait,msg,err_msg = false, 0, ''

	self.client.ON_MESSAGE = function ( mid, topic, message )
		local msg = json.decode(message)
		if ( type(msg) == 'table' ) then
			if not msg.mtime or msg.cname ~= self.cname then
				return
			end

			elapsed = (socket.gettime()-msg.mtime)
			local result="pong from %s time=%2.3f ms seq=%d\n"
			io.write(result:format(
				self.broker,elapsed,msg.seq
			))

			received = received+1
			response = true
		end
	end

	self.client.ON_CONNECT = function ()
		io.write(("Connected to %s\n"):format(self.broker))
		connected = true
	end

	if (self.username and self.password) then
		self.client:login_set(self.username, self.password)
	end

	err_msg = "Can't connect to broker %s retrying %d\n"
	repeat
		wait=wait+1
		conn=self.client:connect(
			self.broker,tonumber(self.port),
			tonumber(self.keepalive)
		)
		if not conn then
			io.write(err_msg:format(self.broker,wait))
		else
			self.client:subscribe(self.topic, self.qos)
			self.client:loop_start()
		end
		socket.sleep(0.30)
	until(conn or wait==4)

	err_msg = ("Wait for connect to broker %s\n"):format(
		self.broker
	)
	if not connected and conn then
		io.write(err_msg)
		wait = 0
		repeat
			wait=wait+1
			socket.sleep(0.30)
		until(connected or wait==10)
	end

	err_msg = ("Sorry, can't connect to broker %s\n"):format(
		self.broker
	)
	if not connected then
		io.write(err_msg)
		os.exit()
	end

	return self
end

-- Get the max and min for a table
--@see http://lua-users.org/wiki/SimpleStats
local function maxmin(data)
	local max, min = -math.huge, math.huge

	for _,value in pairs(data) do
		if type(value) == 'number' then
			max = math.max(max,value)
			min = math.min(min,value)
		end
	end

	return max, min
end

--- Get the mean value of a table
--@see http://lua-users.org/wiki/SimpleStats
local function mean(data)
	local count, sum = 0, 0

	for _,value in pairs(data) do
		if type(value) == 'number' then
			sum = sum + value
			count = count + 1
		end
	end

	return (sum/count)
end

---Calculates the pct of lost packets
local function pct_loss(send, rec)
	local send = send or 0
	local rec  = rec or 0
	return (((send-rec)/send)*100) or 0
end

---I collect the statistics and spit them out.
function M:get_statistics()
	local stdout = [[
--- %s ping statistics ---
%d packets transmitted, %d received, %d%% packet loss, time %2.3f ms
]]
	elapsed = (socket.gettime()-tstart)
	local statistics = (stdout):format(
		self.broker, transmitted or 0, received or 0,
		pct_loss(transmitted,received), elapsed
	)
	io.write("\n")
	io.write(statistics)
end

---I send requests to the broker
function M:ping(c)
	self.reply	= tonumber(c) or 4
	local payload	= {}

	if not connected then
		self:connect()
	end

	if (connected) then
		tstart  = socket.gettime()

		---I capture the CTL-C event
		signal.signal(signal.SIGINT, function(signum)
			if (connected) then
				self.client:disconnect()
				self:get_statistics()
			end
			os.exit(128 + signum)
		end)

		io.write(('Sending %d requests to %s\n'):format(
			self.reply,self.broker
		))

		for seq=1, self.reply, 1 do
			response        = false
			payload		= {
				cname	= self.cname,
				mtime   = socket.gettime(),
				seq	= seq
			}
			self.client:publish(
				self.topic,json.encode(payload),self.qos
			)

			local retries = 0
			repeat
				retries = retries+1
				socket.sleep(0.10)
			until(response or retries==10)
			transmitted   = seq
			socket.sleep(self.interval)
		end

		self.client:disconnect()
		self:get_statistics()
	end
end

return setmetatable(M, {__call = M.new})
