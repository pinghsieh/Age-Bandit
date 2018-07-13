%% Configuration
% Basic
num_servers=3;
arrival_probability=0.2;
probability=[0.3,0.6,0.9];
time_horizon=30000;
num_Runs = 20;

% Epsilon-greedy
epsilon_initial=0.3;
alpha = -0.6;
epsilon_shrink=power(1:1:time_horizon, alpha);