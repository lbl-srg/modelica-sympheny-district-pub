#!/bin/bash
#######################################################
# Script that can be used to set environment variables.
# for Modelica and Python
#######################################################
set -e
export MODELICAPATH=`pwd`
export PYTHONPATH=`pwd`/buildingspy-4.0.0:${PYTHONPATH}
