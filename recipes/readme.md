# Simnet recipes

Simnet recipe describes how a simnet should look like. You can pick one of existing recipes in this folder or create your own.

Please run `./simverse help recipes` to learn more:

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
Say, we stored the above recipe as `recipes/example.sh`.

By running `./sv create example mysn`, we create a new simnet named `mysn`
which has one btcd node and two lnd nodes, all with default settings.

Recipes are bash scripts executed as the last step in simnet creation.
That means you can do anything bash can do to tweak given simnet.
To make your life easier, we provide a simple library "cookbook" for building
simnet on step-by-step basis with sane defaults.

We are not going to document the cookbook here. Please refer to its sources.

Please look around in `recipes` folder and see how existing recipes are done.
```

## Naming conventions:

I adopted a simple naming convention: strings of letter-number to hint on network shape

  * `a` - [bitcoind](https://github.com/bitcoin/bitcoin)
  * `b` - [btcd](https://github.com/btcsuite/btcd)
  * `k` - [lightningd](https://github.com/ElementsProject/lightning)
  * `l` - [lnd](https://github.com/lightningnetwork/lnd)
  * `m` - [eclair](https://github.com/ACINQ/eclair)
  
So for example `b1l2` reads as "one master btcd node and two lnd nodes". 
You might want to specify arbitrary postfix if you want to distinguish more nuanced setups, e.g. `a1k1b1l2-routing-test`.