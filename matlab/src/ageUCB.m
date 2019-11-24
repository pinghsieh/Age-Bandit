function schedule_id = ageUCB(transmission_attempts, success, AoI)
     T = sum(transmission_attempts);
     UCB_index = success./transmission_attempts + power((1/AoI),1)*sqrt(2*log(T)./transmission_attempts);
     [val, schedule_id] = max(UCB_index);
end