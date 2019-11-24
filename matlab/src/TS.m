function tsArm = TS(tsSs, tsNs)

indices = zeros(1,length(tsSs));
alpha = 1;
beta = 1;
tsFs = tsNs - tsSs;
for i = 1 : length(tsSs)
    indices(i) = betarnd(alpha + tsSs(i), beta + tsFs(i));
end

[M,tsArm] = max(indices);
end