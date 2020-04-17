load pvLoadPriceData.mat;
costDataOffset = costData + 5;

% Microgrid Settings
panelArea = 2500;   % Area of PV Array [m^2]
panelEff = 0.3;     % Efficiency of Array
loadBase = 350e3;   % Base Load of Microgrid [W]

BattCap = 2500;     % Energy Storage Rated Capacity [kWh]
batteryMinMax.Pmin = -400e3;    % Max Discharge Rate [W]
batteryMinMax.Pmax = 400e3;     % Max Charge Rate [W]

% Online optimization parameters
FinalWeight = 1;    % Final weight on energy storage
timeOptimize = 5;    % Time step for optimization [min]
timePred = 20;        % Predict ahead horizon [hours]

% Compute PV Array Power Output
cloudyPpv = panelArea*panelEff*cloudyDay;
clearPpv = panelArea*panelEff*clearDay;

% Select Load Profile
loadSelect = 3;
loadFluc = loadData(:,loadSelect);

% Battery SOC Energy constraints (keep between 20%-80% SOC)
battEnergy = 3.6e6*BattCap;
batteryMinMax.Emax = 0.8*battEnergy;
batteryMinMax.Emin = 0.2*battEnergy;

% Setup Optimization time vector
optTime = timeOptimize*60;
stepAdjust = (timeOptimize*60)/(time(2)-time(1));
N = numel(time(1:stepAdjust:end))-1;
tvec = (1:N)'*optTime;

% Horizon for "sliding" optimization
M = find(tvec > timePred*3600,1,'first');

numDays = 2; % Repeat data for end of day forcasts
loadSelect = 3;
clearPpvVec = panelArea*panelEff*repmat(clearDay(2:stepAdjust:end),numDays,1);
for loadSelect = 1:4
    loadDataOpt(:,loadSelect) = repmat(loadData(2:stepAdjust:end,loadSelect),numDays,1) + loadBase;
end
C = repmat(costData(2:stepAdjust:end),numDays,1);

CostMat = zeros(N,M);
PpvMat = zeros(N,M);
PloadMat = zeros(N,M);

% Construct forecast vectors for optimization (N x M) matrix
for i = 1:N
    CostMat(i,:) = C(i:i+M-1);
    PpvMat(i,:) = clearPpvVec(i:i+M-1);
    PloadMat(i,:) = loadDataOpt(i:i+M-1,loadSelect);
end

CostForecast.time = tvec;
CostForecast.signals.values = CostMat;
CostForecast.signals.dimensions = M;

PpvForecast.time = tvec;
PpvForecast.signals.values = PpvMat;
PpvForecast.signals.dimensions = M;

PloadForecast.time = tvec;
PloadForecast.signals.values = PloadMat;
PloadForecast.signals.dimensions = M;

%Clean up unneeded Variables
clear clearDay cloudyDay BattCap panelArea panelEff loadBase;
clear M N i loadSelect numDays stepAdjust timeOptimize;
clear CostMat PloadMat PpvMat clearPpvVec C;
clear batteryMinMax timePred tvec loadData loadDataOpt FinalWeight