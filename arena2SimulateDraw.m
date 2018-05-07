function [vec, pInt] = arena2SimulateDraw(N,varargin)

%% initialize
global casu_pos
numvarargs = length(varargin);

if numvarargs > 3
    error('simulateDomset requires at most 3 optional inputs');
end

optargs = {200 1 0.5};
optargs(1:numvarargs) = varargin;
[n, rho, randomP] = optargs{:};

T = 28 * ones(size(N));
P = zeros(size(N));
pInt = P;

nBees = 10;
posD = randn(sum(sum(N))/2,nBees);
posA = randn(sum(sum(N))/2,nBees);
vel = randn(sum(sum(N))/2,nBees);

ctrl = zeros(length(N),1);
flag = ctrl;

heat = ctrl';
heat_float = ctrl';
cool = ctrl';
cool_float = ctrl';

stop_heat = 0.7;
start_heat = 0;
stop_cool = 0.5;
start_cool = 0.1;

draw = 1;

%% Prepare figure for bee simulation
if draw
    for ifig = 1 : sum(sum(N))/2
        f = figure(ifig);
        grid on
        axis([-10,10,-10,10])
        str = 't = 0';
        annotation('textbox',[0.7,0,1,0.9],'String',str,'FitBoxToText','on','Tag','time_tag');

        mTextBox1 = uicontrol('style','text','Tag','textbox1');
        mString1 = ['T = ', int2str(T(1))];
        set(mTextBox1,'String',mString1);
        mTextBoxPosition1 = get(mTextBox1,'Position');
        set(mTextBox1,'Position',[150,330,100,15]);

        mTextBox2 = uicontrol('style','text','Tag','textbox2');
        mString2 = ['T = ', int2str(T(2))];
        set(mTextBox2,'String',mString2);
        mTextBoxPosition2 = get(mTextBox2,'Position');
        set(mTextBox2,'Position',[350,330,100,15]);
    end
end
%% (n * k seconds)
for i = 1 : n
    iPair = 0;
    
    for iSmaller = 1 : length(N)
        for iLarger = iSmaller + 1 : length(N)
            if N(iSmaller,iLarger) == 1
                iPair = iPair + 1;
                Tsubarena = [T(iSmaller),T(iLarger)];
                %% move bees k times
                k = 10;
                for iTime = 1 : k
                    if draw
                        fi = figure(iPair);
                    end
                    [posD(iPair,:),posA(iPair,:),vel(iPair,:)] = beeSimulation...
                        (posD(iPair,:),...
                        posA(iPair,:),...
                        vel(iPair,:),...
                        Tsubarena, ...
                        draw);
                    %% update plot info
                    if draw
                        title(num2str(iPair));
                        delete(findall(fi,'Tag','time_tag'));
                        str = ['t = ',int2str(i*10+iTime)];
                        annotation('textbox',[0.7,0,1,0.9],'String',str,'FitBoxToText','on','Tag','time_tag');
                        mString1 = ['T = ', num2str(Tsubarena(1))];
                        m = findall(fi,'Tag','textbox1');
                        set(m,'String',mString1);
                        mString2 = ['T = ', num2str(Tsubarena(2))];
                        m = findall(fi,'Tag','textbox2');
                        set(m,'String',mString2);
                        axis([-10,10,-10,10])
                        pause(0.0001);
                        
                        if ~ishghandle(f)
                            close all
                            break
                        end
                    end
                    
                end
                P(iSmaller,iLarger) = ...
                    sum((posA(iPair,:).*cos(posD(iPair,:)) + casu_pos).^2 +...
                    (posA(iPair,:).*sin(posD(iPair,:))).^2 < 4) / nBees;
                P(iLarger,iSmaller) = ...
                    sum((posA(iPair,:).*cos(posD(iPair,:)) - casu_pos).^2 +...
                    (posA(iPair,:).*sin(posD(iPair,:))).^2 < 4) / nBees;
            end
        end
    end
    pInt = pInt + P;
    P;
    ctrl = (ctrl + (sum(pInt,2) > 4) & (sum(pInt,2) < 8)) .* (1-flag);
%     flag = (flag == zeros(size(flag))) & (ctrl == 10) | flag;
    flag = ((flag == 0) & (ctrl == 65)) | flag;
    
    % reduce rho down to 1 - exploration --> exploatation
%     rho = sqrt(rho); 

    arenaCnt = sum(N,2);
    for iNode = 1 : length(N)
        maxP(iNode) = max(P(iNode, N(iNode, :)==1));
        avgP(iNode) = mean(P(iNode, N(iNode, :)==1));
    end
%     maxP
%     avgP
%     maxP = max(P,2);
%     avgP = min(P,2);%sum(P,2)./arenaCnt;
    
    progress_smooth_heat = 1 - exp(0.17 * (1 - 1 / (1 - i / n)));
    progress_smooth_cool = 1 - exp(0.55 * (1 - 1 / (1 - i / n)));
    
    scaling_heat = (1-progress_smooth_heat) * start_heat + stop_heat * progress_smooth_heat;
    scaling_cool = (1-progress_smooth_cool) * start_cool + stop_cool * progress_smooth_cool;
    
    heat_float = heat_float * (1-rho) + (avgP > scaling_heat | ctrl') * rho;
    heat = heat_float > 0.5;
    
    cool_float = cool_float * (1-rho) + (maxP < scaling_cool .* (heat == 0)) * rho;
    cool = cool_float > 0.5;
%     figure(5)
%     for iCrt = 1 : 4
%         subplot(4,5,(iCrt-1)*5 + 1)
%         scatter(i,maxP(iCrt));
%         hold on
%         scatter(i,avgP(iCrt),'x');
%         subplot(4,5,(iCrt-1)*5 + 2)
%         scatter(i,ctrl(iCrt));
%         hold on
%         subplot(4,5,(iCrt-1)*5 + 3)
%         scatter(i,flag(iCrt));
%         hold on
%         subplot(4,5,(iCrt-1)*5 + 4)
%         scatter(i,heat_float(iCrt));
%         hold on
%         subplot(4,5,(iCrt-1)*5 + 5)
%         scatter(i,cool_float(iCrt));
%         hold on
%     end
        
%     heat = P > P';
%     cool = P < P';

%     heat = sum(heat')  % + ctrl;
%     cool = sum(cool')

    % if a vertex wins in all subarenas, it heats; if it loses in all of
    % the arenas, it cools. If sometimes wins, sometimes loses, it does
    % not change temperature.
    
% not working
%     T(:,1) = min(36, T(:,1) + 0.1 * heat .* (heat > cool));
%     T(:,1) = max(26, T(:,1) - 0.1 * cool .* (heat < cool));

% fine if P allowed larger than 1 (more than 100% bees :/)

    T(:,1) = min(36, T(:,1) + 0.1 * arenaCnt .* (heat') .* (sum(pInt,2) > 1));% - arenaCnt == zeros(size(heat))));
    T(:,1) = max(26, T(:,1) - 0.07 * (cool') .* (sum(pInt,2) > 1));% - arenaCnt == zeros(size(cool))));

% if one of the pair is cooling, the other heats a little - pairwise deltas
% - add up
    
%     T(:,1) = min(36, T(:,1) + 0.1 * (heat./arenaCnt >= 0.5 + zeros(size(heat))));
%     T(:,1) = max(26, T(:,1) - 0.05 * (cool./arenaCnt >= 0.5 + zeros(size(cool))));

    vec(i,:) = T(:,1);
    
    for c = 1 : length(N)
        T(c,:) = T(c,1);
    end
end

% col = {[0 0.4470 0.7410];
% [0.8500 0.3250 0.0980];
% [0.9290 0.6940 0.1250]; 
% [0.4940 0.1840 0.5560]; 
% [0.4660 0.6740 0.1880];
% [0 0.4470 0.7410]};
% 
% figure();
% for c = 1 : length(N)
%     subplot(length(N),1,c)
%     scatter(linspace(1,n,n), vec(:,c), '.', 'markeredgecolor', col{c});
%     axis([1, n, 26, 36])
% end
pInt = pInt / n;
% subplot(4,5,1);title('p');subplot(4,5,2); title('ctrl');subplot(4,5,3);title('flag');subplot(4,5,4);title('heat'); subplot(4,5,5);title('cool');
end