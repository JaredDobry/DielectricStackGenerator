%Rank.m
%Performs fitness test on the population and sorts them worst to best
function [sortedPopulation, bestFitness, avgFitness] = Rank(Population, lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint)
    %Get fitness for each population member
    parfor i = 1:size(Population,1)
        F(i,:) = [Fitness(nonzeros(Population(i,:))', lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint, false) i];
    end
    %Sort the population
    it = 1;
    newF = zeros(size(F,1),2);
    while size(F,1) ~= 0
        index = 0;
        max = -1;
        for i = 1:size(F,1)
            if F(i,1) > max
                max = F(i,1);
                index = i;
            end
        end
        newF(it,:) = F(index,:);
        F(index,:) = [];
        it = it + 1;
    end
    F = flipud(newF);
    bestFitness = F(end,1); %grab best fitness measure
    avgFitness = sum(F(1:end,1))/size(Population,1);
    %Debugging
    %disp(strcat('best: ',num2str(bestFitness),' second: ', num2str(F(end-1,1)),' third: ',num2str(F(end-2,1))));
    %Place the population members into their sorted configuration
    it = 1;
    while size(F,1) ~= 0
        sortedPopulation(it,:) = Population(F(1,2),:);
        F(1,:) = [];
        it = it + 1;
    end
    %this line is to debug in benchmarking
    %Fitness(nonzeros(Population(end,:))', lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint, true);
end
    