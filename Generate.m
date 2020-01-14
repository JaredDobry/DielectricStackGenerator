%Generate.m
%Generates a new population randomly given the constraints in the function
%sizeLowBound = Lower boundary on vector length
%sizeUpBound = Upper boundary on vector length
%lengthLowBound = Lower boundary on how wide this material portion is
%lengthUpBound = Upper boundary on how wide this material portion is
%num = Number of members to generate for the population
function Population = Generate(sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound, num)
    Population = spalloc(num,sizeUpBound,num*sizeUpBound);
    for i = 1:num
        size = randi([sizeLowBound sizeUpBound]);
        Member = zeros(1,size);
        for j = 1:size
            Member(1,j) = rand()*(lengthUpBound - lengthLowBound) + lengthLowBound;
        end
       % Member = sparse(Member);
        Population(i,1:size) = Member;
    end
end