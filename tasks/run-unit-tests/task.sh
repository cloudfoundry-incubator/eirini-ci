#!/bin/bash

set -e

# shellcheck disable=SC2034
GOPATH=$(readlink -f eirini-source)

readonly WORKSPACE="$(readlink -f eirini-source)/src/code.cloudfoundry.org/eirini"
"$WORKSPACE"/scripts/run_unit_tests.sh
