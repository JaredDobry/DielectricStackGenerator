function boundaries = GenerateIndividual(genParams)
%GENERATEINDIVIDUAL Creates a single individual given parameters:
%genParams = [minLength, maxLength, minLayerLength, maxLayerLength]
%minLength = minimum length of the output matrix MUST BE EVEN
%maxLength = maximum length of the output matrix MUST BE EVEN
%minLayerLength = minimum width of individual layer
%maxLayerLength = maximum width of individual layer
%assert(mod(genParams(1), 2) == 0);
%assert(mod(genParams(1), 2) == 0);
r = randi([genParams(1), genParams(2)]); %# of layers to make
if mod(r,2) ~= 0 %make it even if it came out odd
    r = r + 1;
end
boundaries = zeros(r, 1);
layerConst = genParams(4) - genParams(3); %this is done for efficiency
for it = 2:length(boundaries) %first element is always 0
    r = rand();
    boundaries(it) = r * layerConst + genParams(3);
end
end

