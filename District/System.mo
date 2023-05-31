within District;
model System "System model"
  extends Buildings.Experimental.DHC.Examples.Combined.SeriesVariableFlow;

  ////////////////////////////////////////
  // Electricity data
  parameter String eleLoaDat[nBui]={
    ModelicaServices.ExternalReferences.loadResource("modelica://District/Resources/Data/Office_Electricity.mos"),
    ModelicaServices.ExternalReferences.loadResource("modelica://District/Resources/Data/Residential_Electricity.mos"),
    ModelicaServices.ExternalReferences.loadResource("modelica://District/Resources/Data/Hospital_Electricity.mos")}
    "File names with electrical loads as time series";

   parameter Real fAct=0.9 "Fraction of surface area with active solar cells";
   parameter Real etaPV=0.20/0.9 "Module conversion efficiency from PV to AC connection";
   parameter Real eta_DCAC=0.9 "Efficiency of DC/AC conversion";

   parameter Modelica.Units.SI.Power PPVPeak[nBui] = {100E3, 200E3, 1E6}
    "Peak PV power, at 917 W/m2 irradition";
   parameter Modelica.Units.SI.Area APV[nBui] = PPVPeak / 917 / etaPV / eta_DCAC / fAct
    "Gross PV surface area (including area not covered with active PV cells)";

  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.Grid gri(
    f=50,
    V=400,
    phiSou=0) "Grid connection"
              annotation (Placement(transformation(extent={{200,280},{220,300}})));
  BaseClasses.Electrical ele[nBui](
    final eleLoaDat=eleLoaDat,
    final A=APV,
    each final fAct=fAct,
    each final etaPV=etaPV,
    each final eta_DCAC=eta_DCAC) "Electrical models for each substation"
    annotation (Placement(transformation(extent={{100,300},{120,320}})));
 Buildings.Controls.OBC.CDL.Continuous.MultiSum PHVAC[nBui](
   each final nin=3) "HVAC electricity use"
    annotation (Placement(transformation(extent={{60,294},{80,314}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Sensors.GeneralizedSensor senGri
    "Sensor for grid connection"
    annotation (Placement(transformation(extent={{140,260},{160,280}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive acLoad(mode=
        Buildings.Electrical.Types.Load.VariableZ_P_input, V_nominal=400)
    annotation (Placement(transformation(extent={{120,260},{100,280}})));
 Buildings.Controls.OBC.CDL.Continuous.MultiSum P_nonETS(nin=3)
  "Power of HVAC equipment that is not in an ETS"
    annotation (Placement(transformation(extent={{60,260},{80,280}})));
  ////////////////////////////////////////
  // Weather data
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        ModelicaServices.ExternalReferences.loadResource("modelica://District/Resources/Data/CHE_ZH_Zurich.Affoltern.066640_TMYx.2007-2021.mos"),
      computeWetBulbTemperature=false) "Weather data reader"
    annotation (Placement(transformation(extent={{60,330},{80,350}})));


 Buildings.Controls.OBC.CDL.Continuous.MultiSum EPVTot(
   nin=3,
   y(final unit="J",
     displayUnit="kWh")) "Total PV energy"
    annotation (Placement(transformation(extent={{140,304},{160,324}})));
  Modelica.Blocks.Continuous.Integrator EBorFie(initType=Modelica.Blocks.Types.Init.InitialState)
    "Energy of borefield (relative to initial conditions)"
    annotation (Placement(transformation(extent={{220,-190},{240,-170}})));
equation
  for i in 1:nBui loop
  connect(PHVAC[i].u[1], bui[i].PPumETS) annotation (Line(points={{58,303.333},
            {20,303.333},{20,200},{6,200},{6,192},{7,192}},
                             color={0,0,127}));
  connect(PHVAC[i].u[2], bui[i].PHea) annotation (Line(points={{58,304},{20,304},
            {20,188},{12,188},{12,189}},
                              color={0,0,127}));
  connect(PHVAC[i].u[3], bui[i].PPum) annotation (Line(points={{58,304.667},{20,
            304.667},{20,184},{12,184},{12,183}},                color={0,0,127}));
  connect(ele[i].E_PV, EPVTot.u[i]) annotation (Line(points={{121,314},{138,314}},
                                color={0,0,127}));
  end for;
  connect(gri.terminal, senGri.terminal_p) annotation (Line(points={{210,280},{
          210,270},{160,270}},
                           color={0,120,120}));
  connect(PHVAC.y, ele.P_HVAC)
    annotation (Line(points={{82,304},{98,304}}, color={0,0,127}));
  connect(P_nonETS.u[1], pumDis.P) annotation (Line(points={{58,269.333},{48,
          269.333},{48,180},{112,180},{112,120},{140,120},{140,-80},{71,-80},{
          71,-71}},
        color={0,0,127}));
  connect(P_nonETS.u[2], pumSto.P) annotation (Line(points={{58,270},{48,270},{48,
          180},{112,180},{112,120},{140,120},{140,-140},{-160,-140},{-160,-70},{
          -169,-70},{-169,-71}},
        color={0,0,127}));
  connect(P_nonETS.u[3], pla.PPum) annotation (Line(points={{58,270.667},{48,
          270.667},{48,180},{112,180},{112,120},{140,120},{140,40},{-120,40},{
          -120,6},{-138,6},{-138,5.33333},{-138.667,5.33333}},
        color={0,0,127}));
  connect(acLoad.Pow, P_nonETS.y)
    annotation (Line(points={{100,270},{82,270}}, color={0,0,127}));
  connect(ele[1].terminal, senGri.terminal_n) annotation (Line(points={{120.6,310},
          {130,310},{130,270},{140,270}}, color={0,120,120}));
  connect(ele[2].terminal, senGri.terminal_n) annotation (Line(points={{120.6,310},
          {130,310},{130,270},{140,270}}, color={0,120,120}));
  connect(ele[3].terminal, senGri.terminal_n) annotation (Line(points={{120.6,310},
          {130,310},{130,270},{140,270}}, color={0,120,120}));
  connect(acLoad.terminal, senGri.terminal_n)
    annotation (Line(points={{120,270},{140,270}}, color={0,120,120}));
  connect(weaDat.weaBus, ele[1].weaBus) annotation (Line(
      points={{80,340},{94,340},{94,310},{100,310}},
      color={255,204,51},
      thickness=0.5));
  connect(weaDat.weaBus, ele[2].weaBus) annotation (Line(
      points={{80,340},{94,340},{94,310},{100,310}},
      color={255,204,51},
      thickness=0.5));
  connect(weaDat.weaBus, ele[3].weaBus) annotation (Line(
      points={{80,340},{94,340},{94,310},{100,310}},
      color={255,204,51},
      thickness=0.5));

  connect(borFie.Q_flow, EBorFie.u) annotation (Line(points={{-118,-84.4},{-110,
          -84.4},{-110,-180},{218,-180}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-360,-260},{360,360}})), Icon(
        coordinateSystem(extent={{-100,-100},{100,100}})),
    experiment(
      StopTime=31536000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Radau"));
end System;
