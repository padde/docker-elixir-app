#!/bin/sh

release_ctl eval --mfa "Ecto.ReleaseTasks.Seed.run/1" --argv -- "$@"
