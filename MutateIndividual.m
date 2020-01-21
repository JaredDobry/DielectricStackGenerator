function out = MutateIndividual(in, params)
%MUTATEINDIVIDUAL mutates an individual and returns a new array with the
%lengths given params:
%params = [lengthChance, widthChance, widthPercent, newLayerMin, newLayerMax, maxLength]
%lengthChance = chance to grow or shrink the array
%widthChance = chance to grow or shrink a single layers size
%widthPercent = The max % of the current layer size to grow or shrink
%newLayerMin = minimum width of individual layer
%newLayerMax = maximum width of individual layer
%maxLength = maximum length of the array

%roll first to grow or shrink
if rand() < params(1)
    %roll to grow or shrink
    if rand() < .5 %shrink
        out = zeros(length(in) - 2, 1);
    else %grow
        if length(in) < params(6)
            out = zeros(length(in) + 2, 1);
        else
            out = zeros(length(in), 1);
        end
    end
else
    out = zeros(length(in), 1);
end

layerConst = params(5) - params(4);
for it = 1:length(out)
    %Are we in bounds of the old indv?
    if it > length(in) %generate a new layer
        out(it) = rand() * layerConst + params(4);
    else %in bounds, copy and roll to mutate
        if rand() < params(2) %mutate
            if rand() < .5 %shrink
                out(it) = in(it) - rand() * params(3) * in(it);
            else %grow
                out(it) = in(it) + rand() * params(3) * in(it);
            end
        else %no mutation, just copy the old value
            out(it) = in(it);
        end
    end
end
end

