%Mutation.m
%Function mutates a member of the population in the size of the vector or
%in the individual values at each index of the vector. Small chance! (5-10%)
function Member = Mutation(Member, sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound)
    %Check to mutate the size of the vector
    %Must change by multiple of 2, one Ze and one Ge
    r = rand();
    if r <= .05 %5 percent chance to mutate length
        r = randi([0 1]);
        if r == 0 %remove 2
            if length(Member) == 2 %Member died, replace with new randomly generated one
                Member = Generate(sizeLowBound, sizeUpBound, lengthLowBound, lengthUpBound, 1);
            else
                r = randi([1 (length(Member)-1)]); %find a spot to remove from
                Member(r) = []; %remove those two gene segments
                Member(r) = []; 
            end
        else %add 2
            r = randi([1 length(Member)]); %Where to put new segment
            a = rand()*(lengthUpBound - lengthLowBound) + lengthLowBound; %new lengths to put in
            b = rand()*(lengthUpBound - lengthLowBound) + lengthLowBound;
            if r == 1
                Member = [a b Member]; %inserting at beginning
            elseif r == length(Member)
                Member = [Member a b]; %inserting at end
            else
                Member = [Member(1:(r-1)) a b Member(r:end)]; %inserting in the vector somewhere
            end
        end
    end
    
    %Check to mutate lengths inside of the vector
    for i = 1:length(Member)
        r = rand();
        if r <= .1 %10 percent chance to change a length
            r = randi([0 1]);
            if r == 0 %subtract length
                r = rand()*Member(i)*.5; %max change of 50%
                if Member(i) - r > 0 %only subtract so long as we are above 0, no negative lengths!
                    Member(i) = Member(i) - r;
                end
            else %add length
                Member(i) = Member(i) + rand()*Member(i)*.5; %max change of 50%
            end
        end
    end
end