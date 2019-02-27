#!/bin/sh

release_ctl eval --mfa "Ecto.ReleaseTasks.Rollback.run/1" --argv -- "$@"
