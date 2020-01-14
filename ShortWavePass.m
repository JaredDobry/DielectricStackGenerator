%ShortWavePass.m
function SWPSolution = ShortWavePass(lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint)
main = figure();
b = figure();
%Initial conditions
sizeLowBound = 11; sizeUpBound = 23; %Must be odd
lengthLowBound = 40; lengthUpBound = 700;
num = 100; %must be divisible by 5 to replace 20% of population
fitnessConstraint = 1;
%Generate starting population
Population = Generate(sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound, num);
done = false;
%Iterate until condition on fitness met
it = 1;
same = 0;
oldBestFitness = 0;
while done == false
    newPopulationSubset = 0;
    if it ~= 1
        oldBestFitness = newBestFitness;
    end
    %Rank all members
    [Population, newBestFitness, avgFitness] = RankSWP(Population, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint);
    if newBestFitness >= fitnessConstraint
        done = true;
        SWPSolution = Population(end,:);
    elseif newBestFitness == oldBestFitness
        same = same + 1;
    else
        same = 0;
    end
    if same >= 70 %no real progress, end the sim
        if newBestFitness >= .85
            SWPSolution = Population(end,:);
            done = true;
        else
            %reset cause the solution got stuck in a maxim
            Population = Generate(sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound, num);
        end
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
    
    disp(strcat('Iteration: ', num2str(it), ' Best fitness: ', num2str(newBestFitness*100), '%', ' Average fitness: ',num2str(avgFitness*100), '%',' Iterations with no change in best: ',num2str(same)));
    best(it) = newBestFitness;
    avg(it) = avgFitness;
    figure(main);
    plot(best, 'r'); hold on;
    plot(avg, 'b'); 
    title('Short Wave Pass');
    xlabel('Iteration'); ylabel('Fitness'); legend('Best', 'Average','Location','SouthEast');
    drawnow;
    figure(b);
    Fitness(nonzeros(Population(end,:))', lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint, true);
    it = it + 1;
end
end