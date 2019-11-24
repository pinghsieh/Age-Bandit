%% Bandit Simulation for Multi-Path AoI 
clear;
tic;

% Make a new folder for saving figures and results
current_time = datestr(datetime('now'),'YYYYmmDD_HH-MM-SS');
savepath = strcat('../figures/', current_time);
[status,msg] = mkdir(savepath);

%Configuration
config.bernoulli_5arms_001;

% Create a readme
fileID = fopen(strcat(savepath, '/readme.txt'),'w');
fprintf(fileID,'bmle_type = %s\n', 'logt^2');
fprintf(fileID,'time_horizon = %d\n', time_horizon);
fprintf(fileID,'num_Runs = %d\n', num_Runs);
fprintf(fileID,'num_servers = %d\n', num_servers);
for i=1:length(success_probability)
    fprintf(fileID,'success_probability(%d) = %f\n', i, success_probability(i));
end

%Genie Policy
[genie_node_probability,genie_schedule_index]=max(success_probability); 

%History
UCB_average_accumulated_regret=zeros(time_horizon+1,1);
ageUCB_average_accumulated_regret=zeros(time_horizon+1,1);
BMLE_average_accumulated_regret=zeros(time_horizon+1,1);
TS_average_accumulated_regret=zeros(time_horizon+1,1);


for r=1:num_Runs
    fprintf('Round %d begins ...\n', r);
    % Packet arrival times
    %packet_arrival_times = cumsum(1 + geornd(arrival_probability,1,time_horizon));
    
    % Counters for Scheduling Policies
    UCB_transmission_attempts=ones(num_servers,1);
    UCB_transmission_success=zeros(num_servers,1);
    UCB_decision_history=zeros(time_horizon,1);
    UCB_accumulated_regret=zeros(time_horizon+1,1);    

    ageUCB_transmission_attempts=ones(num_servers,1);
    ageUCB_transmission_success=zeros(num_servers,1);
    ageUCB_decision_history=zeros(time_horizon,1);
    ageUCB_accumulated_regret=zeros(time_horizon+1,1);   
    
    BMLE_transmission_attempts=ones(num_servers,1);
    BMLE_transmission_success=zeros(num_servers,1);
    BMLE_decision_history=zeros(time_horizon,1);
    BMLE_accumulated_regret=zeros(time_horizon+1,1);   
 
    TS_transmission_attempts=ones(num_servers,1);
    TS_transmission_success=zeros(num_servers,1);
    TS_decision_history=zeros(time_horizon,1);
    TS_accumulated_regret=zeros(time_horizon+1,1);  
    
    %Parameters
    genie_AoI=zeros(time_horizon+1,1);
    UCB_AoI=ones(time_horizon+1,1);
    UCB_regret=zeros(time_horizon+1,1);
    ageUCB_AoI=ones(time_horizon+1,1);
    ageUCB_regret=zeros(time_horizon+1,1);    
    BMLE_AoI=ones(time_horizon+1,1);
    BMLE_regret=zeros(time_horizon+1,1);
    TS_AoI=ones(time_horizon+1,1);
    TS_regret=zeros(time_horizon+1,1);   
    
for t=1:time_horizon
    %Outcomes of transmission over each channel
    transmission_outcomes = rand(num_servers,1) < success_probability;
    
    %Genie Policy: Always choose the channel with the highest p
    if transmission_outcomes(genie_schedule_index) == 1
        genie_AoI(t+1)=1; 
    else
        genie_AoI(t+1)=genie_AoI(t)+1;
    end  
    
    % Scheduling Policy: UCB
    UCB_schedule_index = UCB(UCB_transmission_attempts, UCB_transmission_success);
    
    % Scheduling Policy: age-aware UCB
    ageUCB_schedule_index = ageUCB(ageUCB_transmission_attempts, ageUCB_transmission_success, ageUCB_AoI(t));
    
    % Scheduling Policy: BMLE
    BMLE_schedule_index = BMLE(BMLE_transmission_success, BMLE_transmission_attempts);

    % Scheduling Policy: TS
    TS_schedule_index = TS(TS_transmission_success, TS_transmission_attempts);
    
    %Transmission and updates of UCB
    UCB_transmission_attempts(UCB_schedule_index) = UCB_transmission_attempts(UCB_schedule_index)+1;    
    if transmission_outcomes(UCB_schedule_index) == 1
        UCB_transmission_success(UCB_schedule_index) = UCB_transmission_success(UCB_schedule_index)+1;
        UCB_AoI(t+1) = 1;
    else
        UCB_AoI(t+1) = UCB_AoI(t)+1;
    end    
    UCB_decision_history(t)=UCB_schedule_index;
    
    %Transmission and updates of ageUCB   
    ageUCB_transmission_attempts(ageUCB_schedule_index) = ageUCB_transmission_attempts(ageUCB_schedule_index)+1;    
    if transmission_outcomes(ageUCB_schedule_index) == 1
        ageUCB_transmission_success(ageUCB_schedule_index) = ageUCB_transmission_success(ageUCB_schedule_index)+1;
        ageUCB_AoI(t+1) = 1;
    else
        ageUCB_AoI(t+1) = ageUCB_AoI(t)+1;
    end    
    ageUCB_decision_history(t)=ageUCB_schedule_index;
    
    %Transmission and updates of BMLE
    BMLE_transmission_attempts(BMLE_schedule_index) = BMLE_transmission_attempts(BMLE_schedule_index)+1;    
    if transmission_outcomes(BMLE_schedule_index) == 1
        BMLE_transmission_success(BMLE_schedule_index) = BMLE_transmission_success(BMLE_schedule_index)+1;
        BMLE_AoI(t+1) = 1;
    else
        BMLE_AoI(t+1) = BMLE_AoI(t)+1;
    end    
    BMLE_decision_history(t)=BMLE_schedule_index;

    %Transmission and updates of TS
    TS_transmission_attempts(TS_schedule_index) = TS_transmission_attempts(TS_schedule_index)+1;    
    if transmission_outcomes(TS_schedule_index) == 1
        TS_transmission_success(TS_schedule_index) = TS_transmission_success(TS_schedule_index)+1;
        TS_AoI(t+1) = 1;
    else
        TS_AoI(t+1) = TS_AoI(t)+1;
    end    
    TS_decision_history(t)=TS_schedule_index;
    
    %Regret
    UCB_regret(t+1)=UCB_AoI(t)-genie_AoI(t);
    UCB_accumulated_regret(t+1) = UCB_accumulated_regret(t)+UCB_regret(t+1);
    ageUCB_regret(t+1)=ageUCB_AoI(t)-genie_AoI(t);
    ageUCB_accumulated_regret(t+1) = ageUCB_accumulated_regret(t)+ageUCB_regret(t+1);    
    BMLE_regret(t+1)=BMLE_AoI(t)-genie_AoI(t);
    BMLE_accumulated_regret(t+1) = BMLE_accumulated_regret(t)+BMLE_regret(t+1);   
    TS_regret(t+1)=TS_AoI(t)-genie_AoI(t);
    TS_accumulated_regret(t+1) = TS_accumulated_regret(t)+TS_regret(t+1);       
end
UCB_average_accumulated_regret = UCB_average_accumulated_regret + UCB_accumulated_regret;
ageUCB_average_accumulated_regret = ageUCB_average_accumulated_regret + ageUCB_accumulated_regret;
BMLE_average_accumulated_regret = BMLE_average_accumulated_regret + BMLE_accumulated_regret;
TS_average_accumulated_regret = TS_average_accumulated_regret + TS_accumulated_regret;
end
UCB_average_accumulated_regret = UCB_average_accumulated_regret./num_Runs;
ageUCB_average_accumulated_regret = ageUCB_average_accumulated_regret./num_Runs;
BMLE_average_accumulated_regret = BMLE_average_accumulated_regret./num_Runs;
TS_average_accumulated_regret = TS_average_accumulated_regret./num_Runs;

figure;
hold on
plot(1:(time_horizon+1),UCB_average_accumulated_regret, '-b')
plot(1:(time_horizon+1),ageUCB_average_accumulated_regret, '-g')
plot(1:(time_horizon+1),BMLE_average_accumulated_regret, '-m')
plot(1:(time_horizon+1),TS_average_accumulated_regret, '-r')
legend('Average Accumulated Regret')

%figure;
%plot(log(1:(time_horizon+1)),UCB_average_accumulated_regret)
%legend('Average Accumulated Regret (log x-axis)')

save(strcat(savepath, '/', 'workspace.mat'));
toc;
