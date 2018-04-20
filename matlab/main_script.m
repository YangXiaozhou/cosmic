%% simulation script to collect data for line outage localization

% set pmu locations,
% lines to be outed,
% and number of samples per line
pmu_loc = [23, 26, 39];
out_line_loc = [4, 14];
no_samples_per_line = 5;

sim_results = my_power_network();

for i = 1:length(out_line_loc)
    for j = 1:no_samples_per_line
        
        sim_results = [sim_results;my_power_network(pmu_loc)];
        
    end
end

writetable( sim_results,'../../Line_Outage_Localization/simulation_results.csv')

%% record simulation results

% create column names for the combined results
% for i=1:length(out_line_loc)
%     for j = 1:no_samples_per_line
%         for k = 1:length(pmu_loc)
%              name = 'pmu_'+string(pmu_loc(k))+'_theta_'+'line'+string(out_line_loc(i))+'_sam'+string(j)
%         end
%     end
% end