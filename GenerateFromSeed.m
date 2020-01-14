%GenerateFromSeed.m
%Generates a new population randomly given the constraints in the function
%sizeLowBound = Lower boundary on vector length
%sizeUpBound = Upper boundary on vector length
%lengthLowBound = Lower boundary on how wide this material portion is
%lengthUpBound = Upper boundary on how wide this material portion is
%num = Number of members to generate for the population
function Population = GenerateFromSeed(seed, sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound, num)
    s = length(seed);
    Population = spalloc(num + 1,s,(num + 1)*s);
    Population(1,1:s) = seed;
    %Mutate the members a few times
    for i = 2:(num+1)
        Member = Mutation(seed, sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound);
        size = length(Member);
        Population(i,1:size) = Member;
    end
    for i = 1:3
        for j = 2:(num+1)
            Member = Mutation(Population(j,:), sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound);
            size = length(Member);
            Population(i,1:size) = Member;
        end
    end
end