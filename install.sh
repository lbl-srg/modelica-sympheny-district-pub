#!/bin/bash
set -e
rm -rf Buildings-v9.1.0.zip Buildings\ 9.1.0
rm -rf buildingspy-4.0.0.tar.gz buildingspy-4.0.0

wget https://github.com/lbl-srg/modelica-buildings/releases/download/v9.1.0/Buildings-v9.1.0.zip
unzip Buildings-v9.1.0.zip
rm -rf Buildings-v9.1.0.zip
export MODELICAPATH=`pwd`


wget https://simulationresearch.lbl.gov/modelica/releases/python/buildingspy-4.0.0.tar.gz
tar xzf buildingspy-4.0.0.tar.gz
rm -rf buildingspy-4.0.0.tar.gz
export PYTHONPATH=`pwd`/buildingspy-4.0.0:${PYTHONPATH}
