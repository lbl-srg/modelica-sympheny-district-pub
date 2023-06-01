#!/bin/bash
set -e
sha="ee358f37a66144a64650b9a0ff13e003136ca1fd"
rm -rf ${sha}.zip modelica-buildings-${sha}
rm -rf buildingspy-4.0.0.tar.gz buildingspy-4.0.0

wget https://github.com/lbl-srg/modelica-buildings/archive/${sha}.zip
unzip ${sha}.zip
rm -rf ${sha}.zip
mv modelica-buildings-${sha}/Buildings Buildings\ 9.1.1
rm -rf modelica-buildings-${sha}


wget https://simulationresearch.lbl.gov/modelica/releases/python/buildingspy-4.0.0.tar.gz
tar xzf buildingspy-4.0.0.tar.gz
rm -rf buildingspy-4.0.0.tar.gz
