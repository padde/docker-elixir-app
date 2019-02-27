#!/bin/sh

release_ctl eval --mfa "Ecto.ReleaseTasks.Migrate.run/1" --argv -- "$@"
