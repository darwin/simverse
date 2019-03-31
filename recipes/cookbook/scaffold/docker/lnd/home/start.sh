#!/usr/bin/env bash

exec ./lib/wait-for ${PRE_SIGNAL} -- ./lnd.sh