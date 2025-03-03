#!/bin/bash

print_highlighted() {
  local message="$1"
  local border="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "$border"
  echo -e "$message"
  echo "$border"
}
