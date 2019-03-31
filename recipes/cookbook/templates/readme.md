# SIMNET '$$SIMNET_NAME'

This folder contains generated files for your simnet.

Typical workflow is to enter this folder via `./sv enter $$SIMNET_NAME` and then
 
* use `./dc` command to manage simnet cluster via docker compose (see [docker-compose.yml]()).
* use tools from [toolbox]() and [aliases]() (they should be on $PATH).

## An example simnet session

Go to simverse root directory. Please open two terminal windows: 

- The first one will be for logs and second one  
- The second one will be for interaction with running cluster

### In the first terminal session

1. Enter simnet via `./sv enter $$SIMNET_NAME`
2. Build simnet via `./dc build`
3. Launch simnet via `./dc up`

When you hit CTRL+C, docker will shutdown your simnet and you can rinse, repeat. See tips below in FAQ to learn more.  

### In the second terminal session

1. (assuming running simnet) 
2. Enter simnet via `./sv enter $$SIMNET_NAME`
3. you can control individual services via their names e.g. `alice getinfo` or 
   `prague getnetworkinfo` (see `aliases` dir). Also note that first lnd node has alias `lncli` and first btcd node 
   has alias `btcctl`.
4. you can also use convenience commands from `toolbox`, for example:
```
# assuming you have at least one btcd node and lnd nodes alice, bob and charlie (see the recipe 'b1l3.sh')
#
# let's follow the tutorial https://dev.lightning.community/tutorial/01-lncli

fund alice 10
fund bob 10
fund charlie 10

connect alice charlie
connect bob charlie

och alice charlie 0.11
och charlie bob 0.05

# wait for channel discovery to kick in (circa 20s)

pay alice bob 0.01
```

## FAQ

##### 1. How do I customize build/runtime parameters for docker containers?

> Via environmental variables. See `_defaults.sh`. We generated `.envrc` where you can persistently override those per-simnet.

#### 2. How do I rebuild everything from scratch?

> `./dc --no-cache build`

#### 3. How do I determine ports mapping to my host machine?

> `./dc ps` (assuming running simnet)

#### 3. I'd like to know IP addresses of individual machines in the simnet cluster. How?

> `list_docker_ips` please note that you should not use hard-coded IPs, instead use names docker assigned to individual machines
