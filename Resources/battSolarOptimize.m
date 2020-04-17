function [Pgrid,Pbatt,Ebatt] = battSolarOptimize(N,dt,Ppv,Pload,Einit,Cost,FinalWeight,batteryMinMax)

% Minimize the cost of power from the grid while meeting load with power 
% from PV, battery and grid 

prob = optimproblem;

% Decision variables
PgridV = optimvar('PgridV',N);
PbattV = optimvar('PbattV',N,'LowerBound',batteryMinMax.Pmin,'UpperBound',batteryMinMax.Pmax);
EbattV = optimvar('EbattV',N,'LowerBound',batteryMinMax.Emin,'UpperBound',batteryMinMax.Emax);

% Minimize cost of electricity from the grid
prob.ObjectiveSense = 'minimize';
prob.Objective = dt*Cost'*PgridV - FinalWeight*EbattV(N);

% Power input/output to battery
prob.Constraints.energyBalance = optimconstr(N);
prob.Constraints.energyBalance(1) = EbattV(1) == Einit;
prob.Constraints.energyBalance(2:N) = EbattV(2:N) == EbattV(1:N-1) - PbattV(1:N-1)*dt;

% Satisfy power load with power from PV, grid and battery
prob.Constraints.loadBalance = Ppv + PgridV + PbattV == Pload;

% Solve the linear program
options = optimoptions(prob.optimoptions,'Display','none');
[values,~,exitflag] = solve(prob,'Options',options);

% Parse optmization results
if exitflag <= 0
    Pgrid = zeros(N,1);
    Pbatt = zeros(N,1);
    Ebatt = zeros(N,1);
else
    Pgrid = values.PgridV;
    Pbatt = values.PbattV;
    Ebatt = values.EbattV;
end