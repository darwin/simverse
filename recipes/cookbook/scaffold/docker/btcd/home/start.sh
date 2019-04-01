#!/usr/bin/env bash

PRE_SIGNAL=${PRE_SIGNAL:?required}

exec ./lib/wait-for ${PRE_SIGNAL} -- ./start-all.sh