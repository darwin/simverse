# Simverse

This is a tool for lnd developers. It can generate local simnet clusters of requested size and shape. It uses docker-compose
to manage the cluster and provides a set of helper scripts for your convenience.   

Tested on macOS and ubuntu 18.10 only.

## Prerequisites:

On host machine you should have:

  * bash, git, jq
  * docker, docker-compose
  
## Quick start

In a terminal session:
```
> git clone --recursive https://github.com/darwin/simverse.git
> cd simverse
> ./sv create                                 # first time, it will ask to clone repos, answer yes
...
> ./sv enter
...
_workspace/default > ./dc build
...
_workspace/default > ./dc up                  # this gives you a nice log for whole cluster
...
```

In a second terminal session:

```
> cd simverse
> ./sv enter
_workspace/default > btcd1 getinfo
...
_workspace/default > alice getinfo
...
_workspace/default > connect alice bob        # connect Alice's lnd node to Bob's
...
_workspace/default > fund alice 10            # fund Alice with 10 BTC
...
_workspace/default > oc alice bob 0.1         # open LN channel
...
_workspace/default > pay alice bob 0.01       # pay via LN
```

Here is the default recipe which was used for simnet generation (see `recipes/default.sh`):

```
. cookbook/cookbook.sh

prelude

add btcd

add lnd alice
add lnd bob
```

If you don't want to risk putting your machine on fire, here is a recording:

* note that we used pre-generated `./tmux` script to launch everything in one terminal window

[![asciicast](https://asciinema.org/a/238727.svg)](https://asciinema.org/a/238727)

## Generated simnet folder

A simnet folder contains generated files for your simnet based on a selected recipe.

Typical workflow is to create simnet and then enter it via `./sv enter [simnet_name]`, then you can
 
* use `./dc` command to manage simnet cluster via docker compose (see generated `docker-compose.yml`).
* use tools from [`toolbox`](toolbox) and (generated) `aliases` folders (they should be on $PATH).

## An example simnet session

___See 'quick start' section above.___ 

Go to simverse root directory. Please open two terminal windows: 

- The first one will be for logs  
- The second one will be for interaction with running cluster

### In the first terminal session

1. Enter simnet via `./sv enter default`
2. Build simnet via `./dc build`
3. Launch simnet via `./dc up`

When you hit CTRL+C, docker will shutdown your simnet and you can rinse, repeat. See tips below in FAQ to learn more.  

### In the second terminal session

1. (assuming running simnet) 
2. Enter simnet via `./sv enter default`
3. you can control individual services via their names e.g. `alice getinfo` or 
   `btcd1 getnetworkinfo` (see `aliases` dir). Also note that first lnd node has alias `lncli` and first btcd node 
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

oc alice charlie 0.1
oc charlie bob 0.05

# wait for channel discovery to kick in (circa 20s)

pay alice bob 0.01
```

Alternatively you can use our pre-generated `./tmux` script.

### Gotchas

  * If in troubles, please make sure you have the latest versions tools above, especially docker and docker-compose.
  * Simverse tries to enforce host's UID and GID as permissions for simnet user running the services like `lnd` or `btcd`.
    This is quite important for [comfortable access](https://dille.name/blog/2018/07/16/handling-file-permissions-when-writing-to-volumes-from-docker-containers/) 
    to simnet state folders from host machine under some systems. This can fail in case when your current UID(GID) on host is 
    already taken inside Alpine Linux container. In such cases the effective user in the container is disconnected from host 
    user and permissions on state folder might  be different. You might need root permission to remove them on host.
  
### macOS notes  
  
  * (recommended)keep workspace on APFS-formatted filesystem to benefit from clonefile
  
## FAQ

#### Is this secure?

> No. This is a developer setup and should be never used on a machine connected to open internet. 
> It is expected to be used developer machine on a local network behind NAT/firewall and should never contain sensitive info.
> Anyways whatever you do, you use it at your own risk. 

#### How do I customize build/runtime parameters for individual docker containers?

> By customizing your recipe before adding a node or globally via env variables. See [`_defaults.sh`](_defaults.sh).
> For example you can set different `DEFAULT_LND_REPO_PATH` before each `add lnd ...` command. This would tweak effective
config for following lnd nodes. Read the [`cookbook.sh`](recipes/cookbook/cookbook.sh) bash script for better understanding. 

#### How do I rebuild everything from scratch?

> `./dc --no-cache build`

#### How do I determine ports mapping to my host machine?

> `./dc ps` (assuming a running simnet)

#### I'd like to know IP addresses of individual machines in the simnet cluster. How?

> `list_docker_ips` please note that you should not use hard-coded IPs, instead use service names docker assigned to 
individual machines

#### Is it possible to launch multiple simnets in parallel?

> It is possible to create multiple simnets. But under normal circumstances you are expected to run only one simnet at a time. 
By default, all simnets use the same port mappings to the host machine, so you would not be able to launch them in parallel. 
But you can write a simple wrapper scripts which could modify all *_PORT_ON_HOST in _defaults.sh. You can allocate them so 
that they don't overlap for simnets you need to run in parallel. 

#### How can I inspect a running container in shell?

> `./dc exec <container> bash` or `./dc exec <container> fish` or `./dc exec <container> sh`
> 
> or `./dc exec <container> <one-off-cmd>` 

#### Is it possible to keep simverse workspace on my own path?

> Yes. Look for [`SIMVERSE_WORKSPACE`](_defaults.sh) env var.

#### Is it possible to keep projects' repos on my own path?

> Yes. Look for [`SIMVERSE_REPOS`](_defaults.sh) env var.

#### Where is a faucet?

> This is not a testnet with faucet so we have to mine coins ourselves. Look for [`BTCD_MINING_ADDR`](_defaults.sh) env var which contains
> pre-generated bitcoin address which will receive all mined coins. During btcd node initialization we import this address into 
> btcwallet under the 'imported' account (see [`setup-wallet.sh`](recipes/cookbook/scaffold/docker/btcd/home/setup-wallet.sh)). 
> This way `btcctl --wallet sendfrom imported ...` can be used to send funds to others in need.
>
> Please look at [`toolbox/fund`](toolbox/fund) script which can be used for convenient funding of lnd wallets. For example run `fund alice 10`
> to send 10 BTC to Alice's lnd node wallet. The script might decide to call [`toolbox/earn`](toolbox/earn) to mine enough coins and wait 
> for their maturity.

## Roadmap

  * add support for bitcoind and other bitcoin implementations
  * add support for c-lightning and other implementations
  * support for generating blackbox test cases
  
## sv utility reference



`> ./sv help`
```
Simverse v0.2.

A generator of simnet clusters for lnd and friends.

Usage: ./sv [command] [args...]

Commands:

  create    create a new simnet based on a recipe
  destroy   destroy existing named simnet
  list      list existing simnets
  enter     enter a named simnet
  state     perform state operations on a simnet
  repos     perform operations on code repositories
  help      this help page
  version   display version

Run `./sv help <command>` for specific usage.
Run `./sv help <topic>` to learn about general concepts.

Topics: simnet, recipes, workspace, toolbox, aliases.

Please visit 'https://github.com/darwin/simverse' for further info.
```

`> ./sv help simnet`
```
About simnets

Simnet is a cluster of bitcoin and lighting nodes talking to each other.
Simnets are used during development to test different scenarios/workflow
where multiple nodes are required.

Simnets can have different sizes and shapes. They can be heavily parametrized.

This tool aims to help with simnet creation and maintenance.

The goal is to:

  * easily generate a simnet based on given parameters
  * easily manage state of a simnet (e.g. for future replays)
  * somewhat isolate simnet from host machine (via docker)
  * provide cross-platform solution (macos, linux)

Typical simnet folder structure is:

  _workspace/[simnet_name]/
    _states/
      master/
        certs/
        lnd-data-alice/
        btcd-data-btcd1/
        ...
      ...
    _volumes -> _states/master
    aliases/
    docker/
    helpers/
    repos/
    toolbox/
    dc
    docker-compose.yml
    tmux

Feel free to look around. Below we discuss state management.

Simnet state

All docker containers have their state mapped to host machine into _volumes folder.
It contains btcd's data directories, lnd's data directories and similar.
When you stop docker containers and later run them again, the state will persist.

When you look at _volumes you realize that it is just a symlink somewhere into _states directory.
Typically pointing to 'master', which is the default state.

You can manage states via `./sv state ...`.
Those are just convenience commands to copy/switch _volumes symlink between states.

This is an advanced feature for people who want to snapshot a state for further rollbacks.
It can be also used for replays during automated testing.


A note on hybrid simnets

By default, simnet is generated in a way that all nodes live inside docker containers
managed by docker-compose. For convenience we map all relevant ports to host machine.
This allows running another node directly on host machine and interact with nodes in
the cluster inside docker.

This is expected workflow for someone who want to develop particular feature and
needs supporting simnet "in the background".


A note on debugging nodes inside docker

Currently all nodes run go-based software. We support go-delve debugger which is
prepared to be attached to go processes inside container and offer port mappings
to be controlled from host machine. Please see `attach_dlv` command inside the toolbox.
```

`> ./sv help workspace`
```
About workspace

Workspace is a working folder where your generated simnets get stored.
By default it is under `_workspace` but you can control it
via SIMVERSE_WORKSPACE environmental variable.

Each simnet has a name given to it during `./sv create [name]` call.
Workspace contains a folder for each simnet named after it.

You can enter your simnet via `./sv enter [name]`.
```

`> ./sv help create`
```
Usage: ./sv create [-f] [name] [recipe]

Creates a new simnet with `name` (default) based on `recipe` (default).
On success, prints a path to generated simnet working folder in your workspace.

Flags:
  -f,--force    force creation by destroying previous simnet

Recipe should be name of a script in `recipes` folder. It specifies requested simnet
parameters and drives the generator.

Read more about recipes via `./sv help recipes`
```

`> ./sv help recipe`
```
About recipes

Simnets can have different sizes and shapes. They can be heavily parametrized.
Recipe is a script describing how to build a given simnet.

An example of a simple recipe:

    . cookbook/cookbook.sh

    prelude

    add btcd btcd

    add lnd alice
    add lnd bob

Recipes are located under `recipes` folder.
Say, we store above recipe as `recipes/example.sh`.

By running `./sv create mysn example`, we create a new simnet named `mysn`
which has one btcd node and two lnd nodes, all with default settings.

Recipes are bash scripts executed as the last step in simnet creation.
That means you can do anything bash can do to tweak given simnet.
To make your life easier, we provide a simple library "cookbook" for building
simnet on step-by-step basis with sane defaults.

We are not going to document the cookbook here. Please refer to its sources.

Please look around in `recipes` folder and see how existing recipes are done.
```

`> ./sv help toolbox`
```
About toolbox

Toolbox is a set of convenience scripts for typical interaction with simnet.

When you enter a simnet via `./sv enter [name]`, toolbox folder is added to your PATH.

Explore `toolbox` folder for the details:

  attach_dlv
  balance
  connect
  earn
  fund
  invoice
  list_docker_ips
  oc
  pay
  pubkey

```

`> ./sv help aliases`
```
About aliases

Aliases are scripts generated depending on shape/parameters of your simnet.

When you enter a simnet via `./sv enter [name]`. Aliases folder is added to your PATH.

For example default simnet will generate following aliases for you:

  alice
  bob
  btcd
  btcctl -> btcd
  lncli -> alice

Aliases are convenience shortcuts to control tools for individual nodes (named by simnet recipe).

Additionally there will be generated `btcctl` symlink pointing to first btcd node. And `lncli`
symlink pointing to the first lnd node. This comes handy for asking general questions about networks
not specific to exact node.
```

`> ./sv help destroy`
```
Usage: ./sv destroy [name]

Deletes a simnet with `name` (default).
```

`> ./sv help enter`
```
Usage: ./sv enter [name]

Enters into a sub-shell with environment prepared for simnet with `name` (default).

You typically use this command to start working with a given simnet. In the sub-shell we:

  * switch working directory into simnet's folder
  * set PATH to additionally contain toolbox and aliases
```

`> ./sv help list`
```
Usage: ./sv list [filter]

Lists all available simnets by name. Optionally you can filter the list using a case-insensitive substring.

Run `./sv help simnet` to learn what is a simnet.
```

`> ./sv help state`
```
Usage: ./sv state [sub-command] ...

Manipulates simnet state.

Sub-commands:

  show     show currently selected state in a given simnet
  clone    clone existing state in a given simnet
  switch   switch selection to a named state in a given simnet
  list     list states for a given simnet
  rm       remove a named state in a given simnet

./sv state show [simnet_name]
./sv state clone [--force] [--switch] [simnet_name] <new_state_name> [old_state_name]
./sv state switch [simnet_name] [state_name]
./sv state list [simnet_name] [filter]
./sv state rm [simnet_name] <state_name>

Run `./sv help simnet` to learn about simnet states.
```

`> ./sv help repos`
```
Usage: ./sv repos [sub-command] ...

Manipulates code repositories.

Sub-commands:

  init     init default repos (git clone)
  update   update default repos (git pull)
  clone    clone existing repo under a new name
  list     list repos
  rm       remove repo(s)

./sv repos init [repo_name] [...]
./sv repos update [repo_name] [...]
./sv repos clone [--force] <repo_name> <new_repo_name>
./sv repos list [filter]
./sv repos rm [repo_name] [...]
```
