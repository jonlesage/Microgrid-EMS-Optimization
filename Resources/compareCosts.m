% mdl = 'microgrid_WithESSOpt';
mdl = bdroot;

% Heuristic-based EMS Control
in(1) = Simulink.SimulationInput(mdl);
in(1) = in(1).setBlockParameter([mdl ...
    '/Energy Management System/Energy Management Mode'],'Value','0');

% Optimization-based EMS Control
in(2) = Simulink.SimulationInput(mdl);
in(2) = in(2).setBlockParameter([mdl ...
    '/Energy Management System/Energy Management Mode'],'Value','1');

% No Battery Storage
in(3) = Simulink.SimulationInput(mdl);
in(3) = in(3).setBlockParameter([mdl ...
    '/Energy Management System/Energy Management Mode'],'Value','2');

% Perform Simulations
out = sim(in,'ShowProgress','off');

% Plot Results
subplot(2,1,1)
for i = 1:numel(in)
    plot(out(i).logsout{4}.Values.Time/3600,...
        out(i).logsout{4}.Values.Data,'LineWidth',2); hold on;
end
title('Cumulative Grid Cost ($)');
xlabel('Time (hours)'); ylabel('Rolling Cost ($)');
legend('Heuristic','Optimization','No Storage','Location','northwest'); 
grid on;

subplot(2,1,2)
for i = 1:numel(in)
    plot(out(i).logsout{2}.Values.Time/3600,...
        out(i).logsout{2}.Values.Data,'LineWidth',2); hold on;
end
title('Cumulative Grid Usage (kW-h)');
xlabel('Time (hours)'); ylabel('Grid Usage (kW-h)');
legend('Heuristic','Optimization','No Storage','Location','northwest');
grid on; hold off;

% Compare Final Cost
costHeuristic = out(1).logsout{4}.Values.Data(end);
costOpt = out(2).logsout{4}.Values.Data(end);
perDiff = (costOpt-costHeuristic)/costHeuristic;

disp(['Heuristic EMS Cost: $ ' num2str(costHeuristic)]);
disp(['Optimization EMS Cost: $ ' num2str(costOpt)]);
disp(['Difference (%) between Methods: ' num2str(perDiff*100) '%']);