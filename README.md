# Mqtt ping utility

Mqtt-ping is a diagnostic utility to check the connection status between a host and the broker MQTT.

_Author:_ _[Díaz Devera Víctor Diex Gamar (Máster Vitronic)](https://www.linkedin.com/in/Master-Vitronic)_

[![Lua logo](./doc/powered-by-lua.gif)](http://www.lua.org/)

## Dependencies

* [luasocket](http://luaforge.net/projects/luasocket/)
* [luaposix](https://github.com/luaposix/luaposix)
* [lua-mosquitto](https://github.com/flukso/lua-mosquitto)
* [lua-cjson](https://www.kyne.com.au/~mark/software/lua-cjson.php)

## Installation

Clone this repository.

```
git clone https://gitlab.com/vitronic/mqtt-ping.git
```

## Usage

```
vitronic [~/Proyectos/Lua]$ cd mqtt-ping/
vitronic [~/Proyectos/Lua/mqtt-ping]$ chmod +x mqttping
vitronic [~/Proyectos/Lua/mqtt-ping]$ ./mqttping -c 5 broker.hivemq.com
Connected to broker.hivemq.com
Sending 5 requests to broker.hivemq.com
pong from broker.hivemq.com time=0.664 ms seq=1
pong from broker.hivemq.com time=0.471 ms seq=2
pong from broker.hivemq.com time=0.521 ms seq=3
pong from broker.hivemq.com time=0.467 ms seq=4
pong from broker.hivemq.com time=0.472 ms seq=5

--- broker.hivemq.com ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 7.811 ms
```

## TODO

- [] Statistics of the averages
- [] Making the luarocks package
- [] Suport to SSl/TLS

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## License
[MIT](https://choosealicense.com/licenses/mit/)