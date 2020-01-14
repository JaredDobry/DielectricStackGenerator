%Selection.m
%Selects parents, via ranking selection weight
%Low rank is worse, worst population member gets rank 1, so they get
%1 ranking ticket for odds of selection
%Method needs the population to be sorted by rank, 1 at the first row
%index, so the worst member comes first in the sort
function [parentA, parentB] = Selection(Population)
    s = size(Population,1); %How many members
    chance = 10/s;
    used = s;
    %Select parentA
    for i = 1:s
        r = rand();
        if r <= chance
            parentA = Population(s-i+1,:); %grab member
            used = i;
            break;
        end
        if i == s
            parentA = Population(1,:);
        end
    end
    for i = 1:s
        r = rand();
        if r <= chance && used ~= i
            parentB = Population(s-i+1,:); %grab member
            %Debugging
            %disp(strcat('P1: ',num2str(used),' P2: ',num2str(i)));
            break;
        end
        if i == s
            parentB = Population(1,:);
        end
    end
end