#!/bin/sh

release_ctl eval --mfa "Ecto.ReleaseTasks.Create.run/1" --argv -- "$@"
