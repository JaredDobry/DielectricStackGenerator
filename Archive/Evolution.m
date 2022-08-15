function out = Evolution(population, fitnessRequired, type, constraints, evalParameters, lastFitness, mutateParams, genParams)
%STEPEVALUATION Does the evolution algorithm and returns the final
%individual who passes the required fitness. plots whenever the fitness
%increases
%tic
Fs = zeros(size(population,1), 2);
parfor it = 1:length(Fs)
    Fs(it, :) = [Fitness(population(it,:), constraints, type, evalParameters), it];
end
%sort the individuals by fitness, worst -> best
[~,idx] = sort(Fs(:,1)); % sort just the first column
sortedF = flipud(Fs(idx,:));   % sort the whole matrix using the sort indices
%stats:
%disp("Best indv: " + string(sortedF(1,1)));
%see if we should plot
if sortedF(1,1) > lastFitness
    PlotIndividual(population(sortedF(1,2), :), constraints, type);
end
if sortedF(1,1) >= fitnessRequired %finish req
    out = population(sortedF(1,2), :);
    return;
end

%now we need to reproduce and mutate. We will kill off the population that
%is in the bottom half. Every member of the population gets to reproduce
%once, but the second partner will be weighted to favor the better fitness
%individuals, while still random enough to give some variance.
numToKeep = size(Fs,1) / 2;
for it = 1:numToKeep
    %chance to create a new individual rather than reproduce
    if rand() < .1
        new = GenerateIndividual(genParams);
    else
        p1Index = sortedF(it, 2);
        p2Index = sortedF(SelectOtherParent(it, numToKeep), 2); %select a random other parent
        p1 = RemoveTrailingZeros(population(p1Index, :));
        p2 = RemoveTrailingZeros(population(p2Index, :));
        new = Reproduce(p1, p2);
    end
    mut = MutateIndividual(new, mutateParams);
    toReplaceInd = sortedF(size(sortedF,1) - (it - 1), 2);
    population(toReplaceInd,:) = AddTrailingZeros(mut, size(population,2));
end

%modify parameters for the recursion call
granularity = 1 - sortedF(1,1); %distance away from perfect fitness
%evalParameters = [.5, .5, .1, .9];
lastFitness = sortedF(1,1);
newMutateParams = [.4 * granularity, .05 * granularity + .05, .4 * granularity + .1, mutateParams(4), mutateParams(5), mutateParams(6)];
%toc
% recurse
out = Evolution(population, fitnessRequired, type, constraints, evalParameters, lastFitness, newMutateParams, genParams);

end

