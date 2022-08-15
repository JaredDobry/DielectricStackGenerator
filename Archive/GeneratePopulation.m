function population = GeneratePopulation(num, genParams)
%GENERATEPOPULATION Generates a population of individuals given params:
%genParams = [minLength, maxLength, minLayerLength, maxLayerLength]
%minLength = minimum length of the output matrix MUST BE EVEN
%maxLength = maximum length of the output matrix MUST BE EVEN
%minLayerLength = minimum width of individual layer
%maxLayerLength = maximum width of individual layer
    population = zeros(num, genParams(2));
    for it = 1:num
        %assign the population fields to the new individual
        indv = GenerateIndividual(genParams);
        for j = 2:length(indv)
            population(it,j) = indv(j);
        end
    end
end

