% Script calculates percetage of correct mds, suboptimal ds or incorrect ds
% found by algorithm run in function simulateDomset. 

% Graph is chosen from a set of n graphs in function chooseGraph. 
% Function simulateDomset runs n iterations of decisions on which node 
% becomes dominating set. Bees deciding in binary arenas simulated in 
% beeSimulation function within simulateDomset. Statistics calculated 
% on iter iterations. 

col = {[0 0.4470 0.7410];
[0.8500 0.3250 0.0980];
[0.9290 0.6940 0.1250]; 
[0.4940 0.1840 0.5560]; 
[0.4660 0.6740 0.1880];
[0 0.4470 0.7410]};

global casu_pos;
casu_pos = 4.5;

correct = 0;
incorrect = 0;
subopt = 0;
suboptStats = []; 

figure(1);
% iGraph = 6;
for iGraph = 2 : 2
    rho = 0.85;
    [N, mds] = chooseGraph(iGraph);
    n = 300;
    iter = 1;
    correct = 0;
    incorrect = 0;
    subopt = 0;
    
    plot(graph(N));
    title(num2str(iGraph))
        
for iRho = 0 : 0
    suboptStats = []; 
    for i = 1 : iter
        [vec, pStat] = arena2SimulateDraw(N,n,rho);

        [cor, sub, inc] = calculateStats(vec, N, mds);
        correct = correct + (cor > 0);
        subopt = subopt + (sub > 0);
        incorrect = incorrect + (inc > 0);
        if sub > 0
            suboptStats(subopt) = (sub - 1);
        end


        figure(3);
        n = length(vec);
        for c = 1 : length(N)
            subplot(length(N),1,c)
            scatter(linspace(1,n,n), vec(:,c), '.', 'markeredgecolor', col{c});
            axis([1, n, 26, 36])
        end
    end
    disp(strcat('graph: ', num2str(iGraph), ', rho = ', num2str(rho)));
    disp(strcat('cor:',num2str(correct),',so:',num2str(subopt),',inc:',num2str(incorrect)))
    disp(strcat('mean: ',num2str(mean(suboptStats)), ', var: ', num2str(var(suboptStats))))
    disp('--------------------------------')
%     subplot(3,1,1)
%     scatter(iRho, correct/iter);
%     axis([-1,11,0,1])
%     hold on
%     subplot(3,1,2)
%     scatter(iRho, subopt/iter);
%     axis([-1,11,0,1])
%     hold on
%     subplot(3,1,3)
%     scatter(iRho, incorrect/iter);
%     axis([-1,11,0,1])
%     hold on
end
end
% title(strcat('graph ',num2str(iGraph)));
% f = figure();
% plot(graph(N))

