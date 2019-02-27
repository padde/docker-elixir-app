#!/bin/sh

trap 'exit' INT; $HOME/bin/$APP_NAME $@
