#!/usr/bin/env bash

exec ./lib/wait-for ${PRE_SIGNAL} -- ./start-all.sh