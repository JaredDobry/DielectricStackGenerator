%Replacement.m
%Replaces the least fit members of the population with the new offspring
function Population = Replacement(Population, newMembers)
    l = size(newMembers,1);
    for i = 1:l
        Population(i,:) = 0;
        s = length(newMembers(i,:));
        Population(i,1:s) = newMembers(i,:);
    end
end