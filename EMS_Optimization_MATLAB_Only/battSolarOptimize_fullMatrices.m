function [Pgrid,Pbatt,Ebatt] = battSolarOptimize(N,dt,Ppv,Pload,Einit,Cost,FinalWeight,batteryMinMax)
% battSolarOptimize - function to optimize usage of energy storage for a
% small-scale microgrid.
%
% [Pgrid,Pbatt,Ebatt] = battSolarOptimize(N,dt,Ppv,Pload,Einit,Cost,...
%                           FinalWeight,batteryMinMax)
% 
%   Inputs:
%       N       - Optimization step horizon, number of discrete steps
%       dt      - Time between optimization calls [s]
%       Ppv     - Vector of Current and Forecast PV Power [W]
%       Pload   - Vector of Current and Forecast Grid Load [W]
%       Einit   - Initial Battery Energy [J]
%       Cost    - Cost Vector of Current and Forecast Grid Price [$/kWh]
%       FinalWeight   - Tunable Weight for Final Energy storage
%       batteryMinMax - Structure of simplified battery properties
%
%   Outputs:
%       Pgrid   - Optimal vector of grid power usage [W]
%       Pbatt   - Optimized battery usage [W]
%       Ebatt   - Total battery energy over optimization horizon [J]
%

% Power offset - battery/grid make up the difference
d = Pload - Ppv;

% Sub-matrices for optimization constraints
eyeMat = eye(N);
zeroMat = zeros(N);

battPower = diag(ones(N-1,1),-1)*dt;
battEnergy = diag(-ones(N-1,1),-1) + eye(N);

% Generate the equivalent constraint matrices
Aeq = [eyeMat   eyeMat     zeroMat; 
       zeroMat  battPower   battEnergy];  
beq = [d; Einit; zeros(N-1,1)];

% Generate the objective function
f = [(Cost*dt)' zeros(1,N) zeros(1,N-1) -FinalWeight];

% Constraint equations
A = [zeroMat    eyeMat      zeroMat; 
     zeroMat    -eyeMat     zeroMat;
     zeroMat    zeroMat     eyeMat;
     zeroMat    zeroMat     -eyeMat];
b = [batteryMinMax.Pmax*ones(N,1);
    -batteryMinMax.Pmin*ones(N,1);
    batteryMinMax.Emax*ones(N,1);
    -batteryMinMax.Emin*ones(N,1)];

% Perform Linear programming optimization
options = optimset('Display','none');
xopt = linprog(f,A,b,Aeq,beq,[],[],[],options);

% Parse optmization results
if isempty(xopt)
    Pgrid = zeros(N,1);
    Pbatt = zeros(N,1);
    Ebatt = zeros(N,1);
else
    Pgrid = xopt(1:N);
    Pbatt = xopt(N+1:2*N);
    Ebatt = xopt(2*N+1:end);
end