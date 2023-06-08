#!/bin/bash
#######################################################
# Script that installs the Modelica Buildings Library
# and BuildingsPy versions that are used to run the
# experiments.
#######################################################
set -e
sha="444f378049ddc0cdc63f0978194a4786d139fdd0"
rm -rf ${sha}.zip modelica-buildings-${sha}
rm -rf buildingspy-4.0.0.tar.gz buildingspy-4.0.0

wget https://github.com/lbl-srg/modelica-buildings/archive/${sha}.zip
unzip ${sha}.zip
rm -rf ${sha}.zip
mv modelica-buildings-${sha}/Buildings Buildings\ 10.0.0
rm -rf modelica-buildings-${sha}


wget https://simulationresearch.lbl.gov/modelica/releases/python/buildingspy-4.0.0.tar.gz
tar xzf buildingspy-4.0.0.tar.gz
rm -rf buildingspy-4.0.0.tar.gz
