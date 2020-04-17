This example shows how optimization can be combined with forecast data to operate an Energy Management System (EMS) for a microgrid.

Two styles of EMS are demonstrated in the "microgrid_WithESSOpt.slx" model:
    - Heuristic approach using State Machine Logic (Stateflow)
    - Optimization-based approach to minimize cost subject to operational constraints

The slides, "EMS_Optimization_Formulation.pdf", walk through the formulation of the optimization problem and the assumptions that were made.

To run this demo:
    1) Extract the files to a directory and navigate to that folder in MATLAB
    2) Open the "microgrid_WithESSOpt.slx" model. This model should automatically add the "Resources" folder to the path
    3) Run the model in either Heuristic or Optimization mode using the slider
    4) The MATLAB only folder shows the optimization routine with just MATLAB code (no physical model for verification)

Toolbox Requirements:
    - MATLAB
    - Optimization Toolbox
    - Simulink
    - Simscape
    - Simscape Electrical
    - Stateflow