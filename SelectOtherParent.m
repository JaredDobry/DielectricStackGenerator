function ind = SelectOtherParent(excl, maxInd)
%SELECTOTHERPARENT returns the index of the randomly selected other parent
chance = 4 / maxInd;
for it = 1:maxInd
    if rand() < chance
        if it == excl
            ind = SelectOtherParent(excl, maxInd);
        else
            ind = it;
            return;
        end
    end
end
ind = SelectOtherParent(excl, maxInd);
end

