#!/bin/bash

function jarls {
  jar tvf ${1}
}

function tarls {
  tar tvzf ${1} | tarcolor
}