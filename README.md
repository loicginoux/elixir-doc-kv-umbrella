# KvUmbrella

Distributed key-value store written in Elixir

following the official elixir tutorial Introduction to Mix.
https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html

Umbrella project with two apps:

- kv: Core Key-value store module.
- kv_server TCP Server for handling requests

Notes:
- A Registry to associate a bucket name to a pid number, KV.Registry
- Each bucket are handled in separate process via the KV.BucketSupervisor.
- Routing layer to distribute requests to different nodes via KV.Router

![image](https://github.com/loicginoux/elixir-doc-kv-umbrella/blob/master/observer_screenshot.png)


Run all tests: mix test

run node 1: `iex --sname bar -S mix`
run node 2: `iex --sname foo -S mix`

Use

```
> telnet 127.0.0.1 4040

CREATE shopping
OK

PUT shopping milk 1
OK

PUT shopping eggs 3
OK

GET shopping milk
1
OK

DELETE shopping eggs
OK
```