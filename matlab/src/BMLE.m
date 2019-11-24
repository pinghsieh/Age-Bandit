function [bmleArm, bmle_indices] = BMLE(bmleSs, bmleNs)

bmle_indices = zeros(1, length(bmleSs));
N = sum(bmleNs);
oN = power(log(N),2);

for i = 1 : length(bmleSs)
    if bmleSs(i) == 0
        index = (bmleSs(i) + oN) * log(bmleSs(i) + oN) ...
       + (bmleNs(i)) * log(bmleNs(i)) ...
       - (bmleNs(i) + oN) * log(bmleNs(i) + oN);
    else
        index = (bmleSs(i) + oN) * log(bmleSs(i) + oN) ...
       + (bmleNs(i)) * log(bmleNs(i)) ...
       - (bmleNs(i) + oN) * log(bmleNs(i) + oN) ...
       - bmleSs(i) * log(bmleSs(i));
    end  
    bmle_indices(i) = index;
end

[M,bmleArm] = max(bmle_indices);
end