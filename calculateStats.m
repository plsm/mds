function [correct, subopt, incorrect] = calculateStats(vec, N, mds)   

    correct = 0;
    subopt = 0;
    incorrect = 0;
    
    result = vec(end,:) > 35;
    final = zeros(size(result));
    for iNode = 1 : length(result)
        if result(iNode)
            final(iNode) = 1;
            for iNeigh = 1 : length(result)
                if N(iNode,iNeigh)
                    final(iNeigh) = 1;
                end
            end
        end
    end
    
    if final == ones(size(final))
        if sum(result) == mds
            correct = sum(result) + 1;
        else
            if sum(result) > mds
                subopt = sum(result) + 1;
            else
                disp('Seems manual mds calculation went wrong');
            end
        end
    else
        incorrect = sum(result) + 1;
%         figure();
%         n = length(vec);
%         for c = 1 : length(N)
%             subplot(length(N),1,c)
%             scatter(linspace(1,n,n), vec(:,c), '.', 'markeredgecolor', col{c});
%             axis([1, n, 26, 36])
%         end
%         pause;
    end

end