clear all;
close all;
minWidth = 10;
maxWidth = 1000;
maxLength = 32;
popSize = 64;
genParams = [4, maxLength, minWidth, maxWidth];
constraints = [3000 4000; 4000 6000; 6000 7000];
%Generate a short wavelength bandpass filter
pop = GeneratePopulation(popSize, genParams);
evalParameters = [.4, .1, .1, .9, .4, .1];
mutateParams = [.4, .1, .5, minWidth, maxWidth, maxLength];
%lengthChance = chance to grow or shrink the array
%widthChance = chance to grow or shrink a single layers size
%widthPercent = The max % of the current layer size to grow or shrink
%newLayerMin = minimum width of individual layer
%newLayerMax = maximum width of individual layer
figure;
S = Evolution(pop, .90, 0, constraints, evalParameters, 0, mutateParams, genParams);
%Generate a long wavelength bandpass filter
figure;
L = Evolution(pop, .90, 1, constraints, evalParameters, 0, mutateParams, genParams);
%Concatenate the two and start the evolution off of that seed
figure;
Full = [S L];
evalParameters = [.25, .25, .05, .95, .25, .25];
maxLength = length(Full) + 20;
genParams = [4, maxLength, minWidth, maxWidth];
mutateParams = [.05, .1, .2, minWidth, maxWidth, maxLength];
pop = GeneratePopulation(popSize, genParams);
pop(1,:) = AddTrailingZeros(Full, maxLength);
final = Evolution(pop, .99, 2, constraints, evalParameters, 0, mutateParams, genParams);