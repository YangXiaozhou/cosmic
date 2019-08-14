%% simulation script to collect data for line outage localization

% set pmu locations,
% lines to be outed,
% and number of samples per line
out_line_loc = [0:21,23:36];
% out_line_loc = [0:9];
% no_samples_per_line = 1;

% a dummy simulation to create "sim_results" table
% this case data will be deleted in later python script
sim_results = my_39_bus_system(1);
%%
% simulate PMU data based on 
% different lines to be outed
% and number of samples per outed line
for i = 1:length(out_line_loc)
    for j = 1:no_samples_per_line
        
        sim_results = [sim_results;my_39_bus_system(out_line_loc(i))];
    
    end
end

writetable( sim_results,'../../Line_Outage_Localization/simulation_results_39bus-xxxxxx.csv')

%% record simulation results

% create column names for the combined results
% for i=1:length(out_line_loc)
%     for j = 1:no_samples_per_line
%         for k = 1:length(pmu_loc)
%             name = 'pmu_'+string(pmu_loc(k))+'_theta_'+'line'+string(out_line_loc(i))+'_sam'+string(j);
%         end
%     end
% end
