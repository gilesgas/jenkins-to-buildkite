#!/bin/bash
set -euo pipefail

npm -C app install
npm -C app test
npm -C run build