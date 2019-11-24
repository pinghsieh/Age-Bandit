function schedule_id = UCB(transmission_attempts, success)
     T = sum(transmission_attempts);
     UCB_index = success./transmission_attempts + sqrt(2*log(T)./transmission_attempts);
     [val, schedule_id] = max(UCB_index);
end