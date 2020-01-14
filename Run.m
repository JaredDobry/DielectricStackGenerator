%Run.m
clear; close all;
mainFull = figure();
bFull = figure();
lowExclB = 4000; lowExclT = 4500; %constraint for exclusion below the bandpass
inclB = 5000; inclT = 6000; %constraint for inclusion in the bandpass
exclConstraint = .01; inclConstraint = .99; %constraints for quality of exclusion/inclusion
upExclB = 6500; upExclT = 7000; %constraint for exclusion above the bandpass
fitnessConstraint = 1;
%get the two solutions
SWPSolution = ShortWavePass(lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint);
LWPSolution = LongWavePass(lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint);
%concatenate the two solutions
FullSolution = SWPSolution;
FullSolution(end) = FullSolution(end) + LWPSolution(1);
FullSolution = [FullSolution LWPSolution(2:end)];
s = length(FullSolution);
sizeLowBound = s-3; sizeUpBound = s+3; %constraints for generating from
lengthLowBound = 40; lengthUpBound = 700;
num = 100; %population size
Population = GenerateFromSeed(FullSolution,sizeLowBound,sizeUpBound,lengthLowBound,lengthUpBound,num-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
done = false;
%Iterate until condition on fitness met
it = 1;
same = 0; best = 0; avg = 0;
oldBestFitness = 0;
while done == false
    newPopulationSubset = 0;
    if it ~= 1
        oldBestFitness = newBestFitness;
    end
    %Rank all members
    [Population, newBestFitness, avgFitness] = Rank(Population, lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint);
    if newBestFitness >= fitnessConstraint
        done = true;
        Solution = Population(end,:);
    elseif newBestFitness == oldBestFitness
        same = same + 1;
    else
        same = 0;
    end
    if same >= 500 %no real progress, end the sim
        Solution = Population(end,:);
        done = true;
    else
        for i = 1:(num/5) %replacing 20% of population
            if i == 1 %have 1 new member just be a mutation of the best member
                newMember = Population(end,:);
                newMember = Mutation(newMember, sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound);
            else
                %Selection of parents
                [parentA, parentB] = Selection(Population);
                %Generate Offspring
                newMember = Offspring(parentA, parentB);
                %Mutate Offspring
                newMember = Mutation(newMember, sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound);
            end
            s = length(newMember);
            newPopulationSubset(i,1:s) = newMember;
        end
    end
    %Replace unfit members
    Population = Replacement(Population, newPopulationSubset);
    
    %Progress and plotting
    disp(strcat('Iteration: ', num2str(it), ' Best fitness: ', num2str(newBestFitness*100), '%', ' Average fitness: ',num2str(avgFitness*100), '%',' Iterations with no change in best: ',num2str(same)));
    best(it) = newBestFitness;
    avg(it) = avgFitness;
    figure(mainFull);
    plot(best, 'r'); hold on;
    plot(avg, 'b'); 
    title('Full Dielectric');
    xlabel('Iteration'); ylabel('Fitness'); legend('Best', 'Average','Location','SouthEast');
    drawnow;
    figure(bFull);
    Fitness(nonzeros(Population(end,:))', lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint, true);
    it = it + 1;
end