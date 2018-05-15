function [vec, pInt, airPump] = simulateDomsetAirflowBees (N, varargin)

casu_pos = 4.5;
numvarargs = length(varargin);

if numvarargs > 3
    error('simulateDomset requires at most 2 optional inputs');
end

optargs = {200 1 30};
optargs(1:numvarargs) = varargin;
[n, rho, criticalTemp] = optargs{:};

k = 50;
T = 28 * ones(size(N));
air = zeros (size (N));
pBuff = zeros([size(N), k]);
P = zeros(size(N));
pInt = P;

nBees = 10;
posD = randn(sum(sum(N))/2,nBees);
posA = randn(sum(sum(N))/2,nBees);
vel = randn(sum(sum(N))/2,nBees);

ctrl = zeros(length(N),1);

heat = ctrl';
heat_float = ctrl';
cool = ctrl';
cool_float = ctrl';

stop_heat = 0.7;
start_heat = 0.1;
stop_cool = 0.5;
start_cool = 0.2;

airPump = zeros (n, sum (sum (N)));

for i = 1 : n
    iPair = 0;
    
    for iSmaller = 1 : length(N)
        for iLarger = iSmaller + 1 : length(N)
            if N(iSmaller,iLarger) == 1
                iPair = iPair + 1;
                Tsubarena = [T(iSmaller),T(iLarger)];
                %% AirSubArena = [air(iSmaller, iLarger), air(iLarger, iSmaller)];
                AirSubArena = [air(iSmaller), air(iLarger)];
                %% move bees k times
                for iTime = 1 : k
                    [posD(iPair,:),posA(iPair,:),vel(iPair,:)] = airflowBeeSimulation...
                        (posD(iPair,:),...
                        posA(iPair,:),...
                        vel(iPair,:),...
                        Tsubarena, ...
                        AirSubArena);
                    pBuff(iSmaller, iLarger, iTime) = ...
                        sum((posA(iPair,:).*cos(posD(iPair,:)) + casu_pos).^2 +...
                        (posA(iPair,:).*sin(posD(iPair,:))).^2 < 4) / nBees;
                    pBuff(iLarger, iSmaller, iTime) = ...
                        sum((posA(iPair,:).*cos(posD(iPair,:)) - casu_pos).^2 +...
                        (posA(iPair,:).*sin(posD(iPair,:))).^2 < 4) / nBees;
                end
                P(iSmaller, iLarger) = mean(pBuff(iSmaller, iLarger, :), 3);
                P(iLarger, iSmaller) = mean(pBuff(iLarger, iSmaller, :), 3);
                air(iSmaller, iLarger) = and (T (iSmaller) > criticalTemp, T (iLarger) > criticalTemp);
                air(iLarger, iSmaller) = air(iSmaller, iLarger);
                airPump(i, iPair * 2 - 1) = air(iSmaller, iLarger);
                airPump(i, iPair * 2) = air(iLarger, iSmaller);
            end
        end
    end
    pInt = pInt + P;
%     P
    ctrl = ctrl + ((sum(pInt,2) > 2) & (ctrl < 10));
    
    arenaCnt = sum(N,2);
    for iNode = 1 : length(N)
        maxP(iNode) = max(P(iNode, N(iNode, :)==1));
        avgP(iNode) = mean(P(iNode, N(iNode, :)==1));
    end
    
    if 3 * i / n >= 1
      progress_smooth_heat = 1;
    else
      progress_smooth_heat = 1 - exp(0.17 * (1 - 1 / (1 - min(1, 3 * i / n ))));
    end
    if 2 * i / n >= 1
      progress_smooth_cool = 1;
    else
      progress_smooth_cool = 1 - exp(0.85 * (1 - 1 / (1 - min(1, 2 * i / n))));
    end
    
    scaling_heat = (1-progress_smooth_heat) * start_heat + stop_heat * progress_smooth_heat;
    scaling_cool = (1-progress_smooth_cool) * start_cool + stop_cool * progress_smooth_cool;

    cool_float = cool_float * (1-rho) + (maxP < scaling_cool .* (ctrl > 0)') * rho;
    cool = cool_float > 0.5;
    
    heat_float = heat_float * (1-rho) + ((avgP > scaling_heat) .* ...
        (ctrl > 0)' & (cool == 0)) * rho;
    heat = heat_float > 0.5;

    T(:,1) = min(36, T(:,1) + min(0.5, 0.05 * arenaCnt .* (heat')));
    T(:,1) = max(26, T(:,1) - 0.03 * (cool'));% - arenaCnt == zeros(size(cool))));

    vec(i,:) = T(:,1);
    
    for c = 1 : length(N)
        T(c,:) = T(c,1);
    end
    air(:, 1) = max (air, [], 2);
end

pInt = pInt / n;

end
