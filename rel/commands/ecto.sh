#!/bin/sh

release_ctl eval --mfa "Ecto.ReleaseTasks.run/1" --argv -- "$@"
