%% simulation script to collect data for line outage localization
% for the case of 39-bus system
% it takes ~13 secs to simulate one line outage
% for a 10-second simulation

% set pmu locations,
% lines to be outed,
% and number of samples per line
pmu_loc = [23, 26, 39];
% out_line_loc = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34];
out_line_loc = [0,1,2];
no_samples_per_line = 20;

% a dummy simulation to create "sim_results" table
% this case data will be deleted in later python script
sim_results = my_power_network(0);

% simulate PMU data based on 
% different lines to be outed
% and number of samples per outed line
for i = 1:length(out_line_loc)
    for j = 1:no_samples_per_line
        
        line_to_be_outed = out_line_loc(i);
        sim_results = [sim_results;my_power_network(line_to_be_outed)];
        
    end
end

writetable( sim_results,'../../Line_Outage_Localization/simulation_results.csv')

%% record simulation results

% create column names for the combined results
for i=1:length(out_line_loc)
    for j = 1:no_samples_per_line
        for k = 1:length(pmu_loc)
             name = 'pmu_'+string(pmu_loc(k))+'_theta_'+'line'+string(out_line_loc(i))+'_sam'+string(j)
        end
    end
end