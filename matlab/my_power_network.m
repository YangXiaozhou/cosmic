function [sim_results] = my_power_network(line_to_be_outed) 
% usage: [sim_results] = my_power_network(pmu_loc, line_to_be_outed)
% simulate my defined power network for one instance
% inputs:
%  ps           - powersystem structure. see psconstants.
%  event        - a matrix defining the exogenous events to simulate. see psconstants.
%  outfilename  - the name for the output file
%  opt          - an option structure. see psoptions.
% outputs:
%  outputs.         - a structure of output data, including the following:
%    .success       - a bool flag indicating whether we were able to simulate to the end.
%    .t_simulated   - vector of time periods in the final results.
%    .outfilename   - the name of the file where the results are stored.
%    .demand_lost   - the amount of demand that was shed during the simulation.
%    .computer_time - the amount of wall-clock time required to perform this simulation
%    .endo_events   - matrix that logs endogenous events during the simulation.
%  ps               - the powersystem structure at the end of the simulation.

%% simulate 39-bus case
clearvars -except line_to_be_outed;
close all; clc; C = psconstants;

% do not touch path if we are deploying code
if ~(ismcc || isdeployed)
    addpath('../data');
    addpath('../numerics');
end

% simulation time
t_max = 10;

% select data case to simulate
ps = updateps(case39_ps);
ps = unify_generators(ps); 
ps.branch(:,C.br.tap)       = 1;

% configure load profiles
ps.shunt(:,C.sh.factor)     = 1;
ps.shunt(:,C.sh.status)     = 1;
ps.shunt(:,C.sh.frac_S)     = 1;
ps.shunt(:,C.sh.frac_E)     = 0;
ps.shunt(:,C.sh.frac_Z)     = 0;
ps.shunt(:,C.sh.gamma)      = 0.08;

% to differentiate the line MVA ratings
rateB_rateA                     = ps.branch(:,C.br.rateB)./ps.branch(:,C.br.rateA);
rateC_rateA                     = ps.branch(:,C.br.rateC)./ps.branch(:,C.br.rateA);
ps.branch(rateB_rateA==1,C.br.rateB)    = 1.1 * ps.branch(rateB_rateA==1,C.br.rateA);
ps.branch(rateC_rateA==1,C.br.rateC)    = 1.5 * ps.branch(rateC_rateA==1,C.br.rateA);

% set some options
opt = psoptions;
opt.sim.integration_scheme = 1;
opt.sim.dt_default = 1/10;
opt.nr.use_fsolve = true;
% opt.pf.linesearch = 'cubic_spline';
opt.verbose = true;
opt.sim.gen_control = 1;        % 0 = generator without exciter and governor, 1 = generator with exciter and governor
opt.sim.angle_ref = 0;          % 0 = delta_sys, 1 = center of inertia---delta_coi
                                % Center of inertia doesn't work when having islanding
opt.sim.COI_weight = 0;         % 1 = machine inertia, 0 = machine MVA base(Powerworld)
opt.sim.uvls_tdelay_ini = t_max;  % t_max sec delay for uvls relay.
opt.sim.ufls_tdelay_ini = t_max;  % t_max sec delay for ufls relay.
opt.sim.dist_tdelay_ini = t_max;  % t_max sec delay for dist relay.
opt.sim.temp_tdelay_ini = t_max;    % t_max sec delay for temp relay.
% Don't forget to change this value (opt.sim.time_delay_ini) in solve_dae.m

% initialize the case
ps = newpf(ps,opt);
[ps.Ybus,ps.Yf,ps.Yt] = getYbus(ps,false);
ps = update_load_freq_source(ps);
% build the machine variables
[ps.mac,ps.exc,ps.gov] 		= get_mac_state(ps,'salient');
% initialize relays
ps.relay                    = get_relays(ps,'all',opt);

% initialize global variables
global t_delay t_prev_check dist2threshold state_a 
n    = size(ps.bus,1);
ng   = size(ps.mac,1);
m    = size(ps.branch,1);
n_sh = size(ps.shunt,1);
ix   = get_indices(n,ng,m,n_sh,opt);
t_delay = inf(size(ps.relay,1),1);
t_delay([ix.re.uvls])= opt.sim.uvls_tdelay_ini;
t_delay([ix.re.ufls])= opt.sim.ufls_tdelay_ini;
t_delay([ix.re.dist])= opt.sim.dist_tdelay_ini;
t_delay([ix.re.temp])= opt.sim.temp_tdelay_ini;
t_prev_check = nan(size(ps.relay,1),1);
dist2threshold = inf(size(ix.re.oc,2)*2,1);
state_a = zeros(size(ix.re.oc,2)*2,1);

%% build an event matrix
event = zeros(3,C.ev.cols);
% start
event(1,[C.ev.time C.ev.type]) = [0 C.ev.start];
% trip a branch
if line_to_be_outed == 0  % there is no line outage
    event(2,[C.ev.time C.ev.type]) = [t_max C.ev.finish];
else
    event(2,[C.ev.time C.ev.type]) = [3 C.ev.trip_branch];
    event(2,C.ev.branch_loc) = line_to_be_outed;
    event(3,[C.ev.time C.ev.type]) = [t_max C.ev.finish];
end
% set the end time

%% run the simulation
[outputs,ps] = simgrid(ps,event,'sim_case39',opt);

% print the results
fname = outputs.outfilename;
[t,delta,omega,Pm,Eap,Vmag,theta,E1,Efd,P3,Temperature] = read_outfile(fname,ps,opt);
omega_0 = 2*pi*ps.frequency;
omega_pu = omega / omega_0;

sim_results = table(t, theta);

% % plot some variables
% figure(1); clf; hold on; 
% nl = size(theta,2); colorset = varycolor(nl);
% % set(gca,'ColorOrder',colorset,'FontSize',18,'Xlim',[0 50],'Ylim',[-0.2 0.5]);
% plot(t,theta);
% ylabel('\theta','FontSize',18);
% xlabel('time (sec.)','FontSize',18);
% 
% 
% figure(2); clf; hold on; 
% nl = size(Vmag,2); colorset = varycolor(nl);
% % set(gca,'ColorOrder',colorset,'FontSize',18,'Xlim',[0 50],'Ylim',[0.88 1.08]);
% plot(t,Vmag);
% ylabel('|V|','FontSize',18);
% xlabel('time (sec.)','FontSize',18);