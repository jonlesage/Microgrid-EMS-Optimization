% Load Power Data from Existing PV array
load pvLoadPriceData;

% Set up Optimization Parameters
numDays = 1;            % Number of consecutive days
FinalWeight = 1;      % Final weight on energy storage
timeOptimize = 5;       % Time step for optimization [min]

% Battery/PV parameters
panelArea = 2500;
panelEff = 0.3;

battEnergy = 2500*3.6e6;
Einit = 0.5*battEnergy;
batteryMinMax.Emax = 0.8*battEnergy;
batteryMinMax.Emin = 0.2*battEnergy;
batteryMinMax.Pmin = -400e3;
batteryMinMax.Pmax = 400e3;

% Rescale data to align with desired time steps
stepAdjust = (timeOptimize*60)/(time(2)-time(1));
cloudyPpv = panelArea*panelEff*repmat(cloudyDay(2:stepAdjust:end),numDays,1);
clearPpv = panelArea*panelEff*repmat(clearDay(2:stepAdjust:end),numDays,1);

% Adjust and Select Loading
loadSelect = 3;
loadBase = 350e3;
loadFluc = repmat(loadData(2:stepAdjust:end,loadSelect),numDays,1) + loadBase;

% Grid Price Values [$/kWh]
C = repmat(costData(2:stepAdjust:end),numDays,1);

% Select Desired Data for Optimization
Ppv = clearPpv;
% Ppv = cloudyPpv;
Pload = loadFluc;

% Setup Time Vectors
dt = timeOptimize*60;
N = numDays*(numel(time(1:stepAdjust:end))-1);
tvec = (1:N)'*dt;

% Optimize Grid Energy Usage
[Pgrid,Pbatt,Ebatt] = battSolarOptimize(N,dt,Ppv,Pload,Einit,C,FinalWeight,batteryMinMax);

% Plot Results
figure;
subplot(3,1,1);
thour = tvec/3600;
plot(thour,Ebatt/3.6e6); grid on;
xlabel('Time [hrs]'); ylabel('Battery Energy [kW-h]');

subplot(3,1,2);
plot(thour,C); grid on;
xlabel('Time [hrs]'); ylabel('Grid Price [$/kWh]');

subplot(3,1,3);
plot(thour,Ppv/1e3,thour,Pbatt/1e3,thour,Pgrid/1e3,thour,Pload/1e3);
grid on;
legend('PV','Battery','Grid','Load')
xlabel('Time [hrs]'); ylabel('Power [W]');

