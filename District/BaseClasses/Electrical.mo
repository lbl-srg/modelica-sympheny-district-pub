within District.BaseClasses;
model Electrical "Electrical system model"
  extends Modelica.Blocks.Icons.Block;

  parameter String eleLoaDat="" "Name of electrical load data file that has all loads except HVAC" annotation (
    Dialog(loadSelector(filter="Electrical load file (*.mos)",
                        caption="Select load file")));

  parameter Modelica.Units.SI.Area A
    "Gross PV surface area (including area not covered with active PV cells)";
  parameter Real fAct=0.9 "Fraction of surface area with active solar cells";
  parameter Real etaPV=0.20/0.9 "Module conversion efficiency from PV to AC connection";
  parameter Real eta_DCAC=0.9 "Efficiency of DC/AC conversion";

  Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather data"
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Blocks.Interfaces.RealInput P_HVAC "Power consumed by HVAC system"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}})));

  Modelica.Blocks.Interfaces.RealOutput E_PV(
    final unit="J",
    displayUnit="kWh")
    "PV energy"
    annotation (Placement(transformation(extent={{100,30},{120,50}})));

  Buildings.Electrical.AC.ThreePhasesBalanced.Interfaces.Terminal_n terminal
    "Electrical terminal"
    annotation (Placement(transformation(extent={{96,-10},{116,10}})));

  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.PVSimpleOriented pv(
    eta_DCAC=eta_DCAC,
    A=A,
    fAct=fAct,
    eta=etaPV,
    til=0.087266462599716,
    azi=0,
    V_nominal=400) "PV array"
    annotation (Placement(transformation(extent={{20,-10},{0,10}})));

  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive acLoad(mode=Buildings.Electrical.Types.Load.VariableZ_P_input,
      V_nominal=400)
    annotation (Placement(transformation(extent={{20,-70},{0,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiplyByParameter eleLoa(
    k=1000,
    y(final unit="W"))
    "Electrical load, output is in W"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));

  Modelica.Blocks.Continuous.Integrator EPV(
    y(final unit="J"))
    "PV harvested energy"
    annotation (Placement(transformation(extent={{60,30},{80,50}})));
protected
  Modelica.Blocks.Sources.Constant con30Min(final k=1800)
    "Constant used to shift weather data reader"
    annotation (Placement(transformation(extent={{-90,70},{-70,90}})));
  Buildings.Utilities.Time.ModelTime modTim "Model time"
    annotation (Placement(transformation(extent={{-90,40},{-70,60}})));
  Modelica.Blocks.Math.Add add30Min
    "Add 30 minutes to time to shift weather data reader"
    annotation (Placement(transformation(extent={{-40,70},{-20,90}})));
  Modelica.Blocks.Tables.CombiTable1Ds eleLoa_kWh(
    final tableOnFile=true,
    final tableName="eleLoa",
    final fileName=eleLoaDat,
    verboseRead=false,
    final smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative,
    final columns={2},
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic)
    "Electrical loads in kWh/h"
    annotation (Placement(transformation(extent={{-10,70},{10,90}})));

  Modelica.Blocks.Math.Add addBuiHVAC(k1=-1, k2=-1)
    "Adds building load and HVAC load"
    annotation (Placement(transformation(extent={{-40,-70},{-20,-50}})));
equation
  connect(EPV.u,pv. P) annotation (Line(points={{58,40},{-12,40},{-12,6},{-1,6},
          {-1,7}},
        color={0,0,127}));
  connect(pv.weaBus, weaBus) annotation (Line(
      points={{10,9},{10,32},{-94,32},{-94,0},{-100,0}},
      color={255,204,51},
      thickness=0.5));
  connect(acLoad.terminal, terminal) annotation (Line(points={{20,-60},{88,-60},
          {88,0},{106,0}}, color={0,120,120}));
  connect(con30Min.y, add30Min.u1) annotation (Line(points={{-69,80},{-54,80},{-54,
          86},{-42,86}}, color={0,0,127}));
  connect(modTim.y, add30Min.u2) annotation (Line(points={{-69,50},{-52,50},{-52,
          74},{-42,74}}, color={0,0,127}));
  connect(add30Min.y, eleLoa_kWh.u)
    annotation (Line(points={{-19,80},{-12,80}}, color={0,0,127}));
  connect(P_HVAC, addBuiHVAC.u2) annotation (Line(points={{-120,-60},{-92,-60},
          {-92,-66},{-42,-66}}, color={0,0,127}));
  connect(addBuiHVAC.y, acLoad.Pow)
    annotation (Line(points={{-19,-60},{0,-60}}, color={0,0,127}));
  connect(eleLoa_kWh.y[1], eleLoa.u)
    annotation (Line(points={{11,80},{18,80}}, color={0,0,127}));
  connect(eleLoa.y, addBuiHVAC.u1) annotation (Line(points={{42,80},{50,80},{50,
          64},{-40,64},{-40,26},{-86,26},{-86,-54},{-42,-54}}, color={0,0,127}));
  connect(pv.terminal, terminal)
    annotation (Line(points={{20,0},{106,0}}, color={0,120,120}));
  connect(EPV.y, E_PV)
    annotation (Line(points={{81,40},{110,40}}, color={0,0,127}));
  annotation (
  defaultComponentName="ele",
  Documentation(info="<html>
<p>
Electrical system model for the site served by the energy transfer station.
</p>
</html>", revisions="<html>
<ul>
<li>
May 25, 2023, by Michael Wetter:<br/>
First version.
</li>
</ul>
</html>"),
    Icon(graphics={              Line(
        points={{42,74},{-26,6},{34,6},{-48,-80},{-48,-80}},
        color={0,0,0},
        smooth=Smooth.None), Polygon(
        points={{-48,-80},{-32,-30},{2,-62},{-48,-80}},
        lineColor={0,0,0},
        smooth=Smooth.None,
        fillPattern=FillPattern.Solid,
        fillColor={0,0,0})}));
end Electrical;
