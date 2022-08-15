function new = Reproduce(p1, p2)
%REPRODUCE reproduces the 2 parents by a process of random "gene selection"
if length(p1) > length(p2)
    new = zeros(length(p1), 1);
    possibleGeneSize = floor(length(p1) / 2);
else %assume p2 is >= p1
    new = zeros(length(p2), 1);
    possibleGeneSize = floor(length(p2) / 2);
end
if mod(possibleGeneSize, 2) ~= 0
    possibleGeneSize = possibleGeneSize + 1;
end
it = 1;
while new(end) == 0
    %roll for a gene size
    geneSize = randi([2, possibleGeneSize]);
    if mod(geneSize, 2) ~= 0 %make sure its div by 2
        geneSize = geneSize + 1;
    end
    %roll for a parent to pick from
    if rand() < .5 %p1
        if it + geneSize > length(p1) %gene is too big, see what to do
            if length(p1) > length(p2)
                new(it:end) = p1(it:end);
            else
                new(it:end) = p2(it:end);
            end
        else
            new(it:it + geneSize) = p1(it: it + geneSize);
            it = it + geneSize + 1;
        end
    else %p2
        if it + geneSize > length(p2) %gene is too big, take from bigger 
            if length(p1) > length(p2)
                new(it:end) = p1(it:end);
            else
                new(it:end) = p2(it:end);
            end
        else
            new(it:it + geneSize) = p2(it: it + geneSize);
            it = it + geneSize + 1;
        end
    end
end
end

