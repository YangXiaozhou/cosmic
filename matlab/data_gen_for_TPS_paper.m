%% simulation script to collect data for line outage detection

% set pmu locations,
% lines to be outed,
% and number of samples per line
out_line_loc = [0:21,23:36];
% out_line_loc = [0:10];
no_samples_per_line = 1;
no_of_simulations = 450;

% a dummy simulation to create "sim_results" table
% this case data will be deleted in later python script
sim_results = my_39_bus_system(1);
%%
% simulate PMU data based on 
% different lines to be outed
% and number of samples per outed line
for k = 1:no_of_simulations
    for i = 1:length(out_line_loc)
        for j = 1:no_samples_per_line

            sim_results = [sim_results;my_39_bus_system(out_line_loc(i))];

        end
    end
    writetable( sim_results,'../../Data_TPS_Paper/simulation_results_39bus_'+string(k+50)+'.csv');
    sim_results = my_39_bus_system(1);
end

