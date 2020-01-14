%Offspring.m
%Permutes in one chunk of parent 'genes' with another to create a new member
function newMember = Offspring(parentA, parentB)
    lengthA = length(parentA);
    lengthB = length(parentB);
    if lengthA > lengthB
        newMember = parentA;
        lowerBound = randi([1 lengthB]);
        upperBound = randi([lowerBound lengthB]);
        newMember(lowerBound:upperBound) = parentB(lowerBound:upperBound);
    else
        newMember = parentB;
        lowerBound = randi([1 lengthA]);
        upperBound = randi([lowerBound lengthA]);
        newMember(lowerBound:upperBound) = parentA(lowerBound:upperBound);
    end
end