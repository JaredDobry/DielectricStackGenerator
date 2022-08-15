clear all;
close all;
tic
minWidth = 10;
maxWidth = 1000;
maxLength = 32;
popSize = 128;
genParams = [4, maxLength, minWidth, maxWidth];
constraints = [3000 4000; 4000 6000; 6000 7000];
%Generate a short wavelength bandpass filter
pop = GeneratePopulation(popSize, genParams);
evalParameters = [.2, .2, .1, .9, .3, .3];
% [weightExclusion, weightInclusion, exclusionCutoff,
% inclusionCutoff, weightAvgExcl, weightAvgIncl];
mutateParams = [.2, .2, .1, minWidth, maxWidth, maxLength];
figure;
S = Evolution(pop, .95, 0, constraints, evalParameters, 0, mutateParams, genParams);
%Generate a long wavelength bandpass filter
figure;
L = Evolution(pop, .95, 1, constraints, evalParameters, 0, mutateParams, genParams);
%Concatenate the two and start the evolution off of that seed
figure;
Full = [S(1:end-1), L(2:end)];
evalParameters = [.05, .05, .01, .99, .4, .5];
maxLength = length(Full) + 20;
genParams = [4, maxLength, minWidth, maxWidth];
mutateParams = [.05, .1, .1, minWidth, maxWidth, maxLength];
pop = GeneratePopulation(popSize, genParams);
pop(1,:) = AddTrailingZeros(Full, maxLength);
final = Evolution(pop, .97, 2, constraints, evalParameters, 0, mutateParams, genParams);
toc