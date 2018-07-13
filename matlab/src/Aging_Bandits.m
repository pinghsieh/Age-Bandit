%% Simulation for Age-of-Information Bnadit
clear;
tic;

%Configuration
config.bernoulli_3arms_002;

%Genie Policy
[genie_node_probability,genie_node_index]=max(probability); 

%History
average_accumulated_regret=zeros(time_horizon+1,1);
    
for r=1:num_Runs
    %Scheduling Policy (epsilon greedy)
    policy_channel_estimate=ones(num_servers,1)/2;
    policy_transmission_attempts=2*ones(num_servers,1);
    policy_transmission_success=ones(num_servers,1);
    policy_decision_history=zeros(time_horizon,1);

    %Parameters
    genie_AoI=zeros(time_horizon+1,1);
    policy_AoI=zeros(time_horizon+1,1);
    source_AoI=zeros(time_horizon+1,1);
    regret=zeros(time_horizon+1,1);
    accumulated_regret=zeros(time_horizon+1,1);

for t=1:time_horizon
    %Outcomes of transmission over each channel
    transmission_outcomes = rand(1, num_servers) < probability;
    
    %Arrival of a fresh packet in the source
    arrival_this_slot=(rand<=arrival_probability);
    if arrival_this_slot==1
        source_AoI(t)=0;    
    end
    
    %Genie Policy
    if transmission_outcomes(genie_node_index) == 1
        genie_AoI(t+1)=source_AoI(t)+1; 
    else
        genie_AoI(t+1)=genie_AoI(t)+1;
    end
    
    %Scheduling Policy
    if rand<(epsilon_initial*epsilon_shrink)
        policy_node_index=ceil(rand*num_servers);
    else
        [value_estimate,policy_node_index]=max(policy_channel_estimate);
    end    
    
    %Transmission and updates
    policy_transmission_attempts(policy_node_index)=policy_transmission_attempts(policy_node_index)+1;    
    if transmission_outcomes(policy_node_index) == 1
        policy_transmission_success(policy_node_index)=policy_transmission_success(policy_node_index)+1;
        policy_AoI(t+1)=source_AoI(t)+1;
    else
        policy_AoI(t+1)=policy_AoI(t)+1;
    end    
    policy_channel_estimate(policy_node_index)=policy_transmission_success(policy_node_index)/policy_transmission_attempts(policy_node_index);
    policy_decision_history(t)=policy_node_index;

    %Age of information at the source
    source_AoI(t+1)=source_AoI(t)+1;
    
    %Regret
    regret(t+1)=policy_AoI(t)-genie_AoI(t);
    accumulated_regret(t+1) = accumulated_regret(t)+regret(t+1);
end
average_accumulated_regret = average_accumulated_regret + accumulated_regret;
end
average_accumulated_regret = average_accumulated_regret./num_Runs;

%{
figure(1)
plot(1:(time_horizon+1),genie_AoI)
hold on
plot(1:(time_horizon+1),policy_AoI)
plot(1:(time_horizon+1),source_AoI)
legend('Genie','Policy','Source')
hold off

figure(2)
plot(1:(time_horizon+1),genie_AoI-source_AoI)
hold on
plot(1:(time_horizon+1),policy_AoI-source_AoI)
legend('Genie','Policy')
hold off

figure(3)
plot(1:(time_horizon+1),regret)
legend('Regret')
%}

figure(4)
plot(1:(time_horizon+1),accumulated_regret)
legend('Accumulated Regret')

figure(5)
plot(1:(time_horizon+1),average_accumulated_regret)
legend('Average Accumulated Regret')

toc;
