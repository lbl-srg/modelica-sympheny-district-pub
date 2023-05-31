within District.BaseClasses.Validation;
model Electrical "Validation model for electrical system"
  extends Modelica.Icons.Example;
  constant Integer nBui = 3 "Number of building sites";

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

  District.BaseClasses.Electrical ele[nBui](
    eleLoaDat=eleLoaDat,
    A=APV,
    each fAct=fAct,
    each etaPV=etaPV,
    each eta_DCAC=eta_DCAC)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    filNam= ModelicaServices.ExternalReferences.loadResource("modelica://District/Resources/Data/CHE_ZH_Zurich.Affoltern.066640_TMYx.2007-2021.mos"),
      computeWetBulbTemperature=false) "Weather data reader"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant P_HVAC[nBui](each k=0)
    "HVAC electricity use"
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.Grid gri(
    f=50,
    V=500,
    phiSou=0) annotation (Placement(transformation(extent={{40,40},{60,60}})));
equation
  for i in 1:nBui loop
    connect(weaDat.weaBus, ele[i].weaBus) annotation (Line(
      points={{-40,0},{-10,0}},
      color={255,204,51},
      thickness=0.5));
  end for;
  connect(P_HVAC[:].y, ele[:].P_HVAC)
    annotation (Line(points={{-38,-30},{-20,-30},{-20,-6},{-12,-6}},
                                                            color={0,0,127}));
  connect(ele[1].terminal, gri.terminal)
    annotation (Line(points={{10.6,0},{50,0},{50,40}}, color={0,120,120}));
  connect(ele[2].terminal, gri.terminal)
    annotation (Line(points={{10.6,0},{50,0},{50,40}}, color={0,120,120}));
  connect(ele[3].terminal, gri.terminal)
    annotation (Line(points={{10.6,0},{50,0},{50,40}}, color={0,120,120}));
  annotation (experiment(
      StopTime=31536000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"));
end Electrical;
