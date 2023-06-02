#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import matplotlib
#matplotlib.use('Agg')
import matplotlib.pyplot as plt

import buildingspy

from buildingspy.simulate.Dymola import Simulator

def simulateCase(s):
    s.setStartTime(0)
    s.setStopTime(365*24*3600)
    s.setSolver("Radau")
    s.setTolerance(1E-6)
    s.deleteOutputFiles()
    s.simulate()

def printResults(mat_file):
    from buildingspy.io.outputfile import Reader
    import sys

    # Optionally, change fonts to use LaTeX fonts
    # from matplotlib import rc
    # rc('text', usetex=True)
    # rc('font', family='serif')

    # Read results
    ofr = Reader(mat_file, "dymola")
    (time, E_PV) = ofr.values('EPVTot.y')
    if (abs(max(time)-365*24*3600.) > 1):
        print(f"Error: Simulation did not run a full year, final time is {max(time)} s.")
        sys.exit(1)

    EHeaPum = ofr.max('EHeaPum.y')
    print(f"Total HP electricity: {EHeaPum/1000.0/3600:g} kWh (was in Sommer 0.69 GWh)")

    E_PVTot = ofr.max('EPVTot.y')
    P_PVTot = ofr.max('ele[1].pv.P') + ofr.max('ele[2].pv.P') + ofr.max('ele[3].pv.P')

    #print(ofr.varNames("EPV*"))
    print(f'Total PV energy: {E_PVTot:g} J, ({E_PVTot /1000.0 / 3600:g} kWh)')
    print(f'Total PV power:  {P_PVTot:g} W')

    # Heat pumps
    QConMaxOff = ofr.max('bui[1].ets.proHeaWat.heaPum.QCon_flow')
    QConMaxRes = ofr.max('bui[2].ets.proHeaWat.heaPum.QCon_flow')
    QConMaxHos = ofr.max('bui[3].ets.proHeaWat.heaPum.QCon_flow')
    print(f"Heat pump capacity (space heating only): {QConMaxOff:g}, {QConMaxRes:g}, {QConMaxHos:g} W (office, residential, hospital).")
    print(f"Heat pump capacity (space heating only): {QConMaxOff + QConMaxRes + QConMaxHos:g} W (total).")

    QSHWConMaxOff = ofr.max('bui[1].bui.QReqHotWat_flow')
    QSHWConMaxRes = ofr.max('bui[2].bui.QReqHotWat_flow')
    QSHWConMaxHos = ofr.max('bui[3].bui.QReqHotWat_flow')
    print(f"Heat pump capacity (service hot water only): {QSHWConMaxOff:g}, {QSHWConMaxRes:g}, {QSHWConMaxHos:g} W (office, residential, hospital).")
    print(f"Heat pump capacity (service hot water only): {QSHWConMaxOff + QSHWConMaxRes + QSHWConMaxHos:g} W (total).")

    QCooHexMaxOff = ofr.min('bui[1].ets.hexChi.Q2_flow')
    QCooHexMaxRes = ofr.min('bui[2].ets.hexChi.Q2_flow')
    QCooHexMaxHos = ofr.min('bui[3].ets.hexChi.Q2_flow')
    print(f"Cooling heat exchanger capacity: {QCooHexMaxOff:g}, {QCooHexMaxRes:g}, {QCooHexMaxHos:g} W (office, residential, hospital).")
    print(f"Cooling heat exchanger capacity: {QCooHexMaxOff + QCooHexMaxRes + QCooHexMaxHos:g} W (total).")

    # Borefield. This assumes the borefield to be balanced, which it roughly is.
    QBorFieMin = ofr.min('EBorFie.y')
    QBorFieMax = ofr.max('EBorFie.y')
    print(f"Borefield used capacity: {(QBorFieMax-QBorFieMin):g} J, ({(QBorFieMax-QBorFieMin) /1000.0 / 3600:g} kWh)")

    # Sewage plant
    QSew = ofr.max('pla.senDifEntFlo.dH_flow')
    print(f"Sewage heat, rejected from loop to sewage if positive: {QSew:g} W")

    # Heat pumps SPF
    EEleHeaPumHeaOff = ofr.integral('bui[1].ets.proHeaWat.heaPum.P')
    EEleHeaPumHeaRes = ofr.integral('bui[2].ets.proHeaWat.heaPum.P')
    EEleHeaPumHeaHos = ofr.integral('bui[3].ets.proHeaWat.heaPum.P')

    EEleHeaPumSHWOff = ofr.integral('bui[1].ets.proHotWat.heaPum.P')
    EEleHeaPumSHWRes = ofr.integral('bui[2].ets.proHotWat.heaPum.P')
    EEleHeaPumSHWHos = ofr.integral('bui[3].ets.proHotWat.heaPum.P')


    EEleHeaPum = EEleHeaPumHeaOff + EEleHeaPumHeaRes + EEleHeaPumHeaHos \
               + EEleHeaPumSHWOff + EEleHeaPumSHWRes + EEleHeaPumSHWHos # electrical energy of all heat pumps

    # Space heating load
    EHeaOff = ofr.integral('bui[1].bui.QReqHea_flow')
    EHeaRes = ofr.integral('bui[2].bui.QReqHea_flow')
    EHeaHos = ofr.integral('bui[3].bui.QReqHea_flow')

    # Service hot water load
    ESHWOff = ofr.integral('bui[1].bui.QReqHotWat_flow')
    ESHWRes = ofr.integral('bui[2].bui.QReqHotWat_flow')
    ESHWHos = ofr.integral('bui[3].bui.QReqHotWat_flow')

    SPFHea = (ESHWOff + ESHWRes + ESHWHos + EHeaOff + EHeaRes + EHeaHos)/EEleHeaPum

    print(f"SPF of heat pumps (space heating)    : {EHeaOff/EEleHeaPumHeaOff:g}, {EHeaRes/EEleHeaPumHeaRes:g}, {EHeaHos/EEleHeaPumHeaHos:g} (office, residential, hospital)")
    print(f"SPF of heat pumps (service hot water): {ESHWOff/EEleHeaPumSHWOff:g}, {ESHWRes/EEleHeaPumSHWRes:g}, {ESHWHos/EEleHeaPumSHWHos:g} (office, residential, hospital)")
    print(f"Seasonal performance factor of all heat pumps: {SPFHea:g}")

    # Constraint violation
    class bcolors:
        OKGREEN = '\033[92m'
        FAIL = '\033[91m'
        ENDC = '\033[0m'
    (time, conVio_t) = ofr.values('conVio.y')
    conVio = conVio_t[-1]
    col = bcolors.OKGREEN if conVio < 3E-3 else bcolors.FAIL

    #plt.plot(time, conVio_t)
    #plt.show()
    print(f"{col}Constraint violation {conVio:g}.{bcolors.ENDC}")

if __name__ == '__main__':

    model = "District.System"
    s = Simulator(model)

    simulateCase(s)
    printResults('System.mat')
