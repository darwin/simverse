# SimVerse

This is a tool for lnd developers. It can generate local simnet clusters of requested size and shape. It uses docker-compose
to manage the cluster and provides a set of helper scripts for your convenience.   

Tested on macOS and ubuntu 18.10 only.

## Prerequisites:

On host machine you should have:

  * bash, git, jq
  * docker, docker-compose
  * (optional) direnv
  * (recommended) when under macOS, keep workspace on APFS-formatted filesystem to benefit from clonefile

## Quick start

In a terminal session:
```
> git clone --recursive https://github.com/darwin/simverse.git
> cd simverse
> ./sv create                                 # first time, it will ask to clone repos, answer yes
...
> ./sv enter
...
_workspace/default > cat readme.md
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

If you don't want to risk putting your machine on fire, here are some recordings:

##### Terminal #2

[![asciicast](https://asciinema.org/a/237989.svg)](https://asciinema.org/a/237989)

##### Terminal #1

[![asciicast](https://asciinema.org/a/237991.svg)](https://asciinema.org/a/237991)


## Roadmap

  * add support for bitcoind and other bitcoin implementations
  * add support for c-lightning and other implementations
  * support for generating blackbox test cases
  
## sv utility reference




`> ./sv help`
```
SimVerse v0.1.

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
    .envrc
    dc
    docker-compose.yml
    readme.md

Feel free to look around. You should refer to generated readme.md for detailed
description. Below we discuss only state management.


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

By default simnet is generated in a way that all nodes live inside docker containers
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

Workspace is a working folder where are your generated simnets are stored.
By default it is under `_workspace` but you can control it
via SIMVERSE_WORKSPACE environmental variable.

Each simnet has a name given to it during `./sv create [name]` call.
Workspace contains a folder for each simnet named after it.

You can enter simnet via `./sv enter [name]`.
```

`> ./sv help create`
```
Usage: ./sv create [-f] [name] [recipe]

Creates a new simnet with `name` (default) based on `recipe` (default).
On success, prints a path to generated simnet working folder in your workspace.

Flags:
  -f,--force    force creation by destroying previous simnet

Recipe is a name of a script in `recipes` folder. It specifies requested simnet
parameters and drives the generator.

Read more about recipes via `./sv help recipes`
```

`> ./sv help recipe`
```
About recipes

Simnets can have different sizes and shapes. They can be heavily parametrized.
Recipe is a script describing how to build a given simnet.

An example recipe:

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
That means you can do anything bash can do to tweak a given simnet.
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
