function F = Fitness(boundaries, constraints, type, evalParameters)
%FITNESS boundaries are the lengths of the dielectric layers
% constraints are [exclusion zone 1; inclusion zone; exclusion zone 2]
% each zone is itself a 1x2 matrix, ie incl = [3000, 4000]
% type is 0 for short wavelength bandpass filter, 1 for long wavelength
% bandpass filter, and 2 for full stack
% for SWL, we ignore the second exclusion zone entirely
% for LWL, we ignore the first exclusion zone entirely
% for Full stack, we weight the whole range
% evalParameters is how to weight the inclusions, given as:
% [weightExclusion, weightInclusion, exclusionCutoff,
% inclusionCutoff, weightAvgExcl, weightAvgIncl];

%get the transmission coefficients
firstWL = constraints(1,1);
lastWL = constraints(3,2);
wls = linspace(firstWL, lastWL, 64); %using 2^n elements results in a memory management speedup
T = zeros(length(wls), 1);
parfor it = 1:length(T)
    T(it) = Coefficient(boundaries, wls(it));
end
%evaluate fitness
eIn = 0;
eOut = 0;
eTotal = 0;
iIn = 0;
iOut = 0;
iTotal = 0;
for it = 1:length(T)
    %see if we are in the first exclusion zone
    if wls(it) < constraints(1,2)
        %do we care about this? (LWP ignores)
        if type ~= 1
            if T(it) < evalParameters(3)
                eIn = eIn + 1;
            else
                eOut = eOut + 1;
            end
            eTotal = eTotal + T(it);
        end
    %see if we are in the inclusion zone
    elseif wls(it) < constraints(2,2)
        if T(it) > evalParameters(4)
            iIn = iIn + 1;
        else
            iOut = iOut + 1;
        end
        iTotal = iTotal + T(it);
    %have to be in the second exclusion zone
    else
        %do we care about this? (SWP ignores)
        if type ~= 0
            if T(it) < evalParameters(3)
                eIn = eIn + 1;
            else
                eOut = eOut + 1;
            end
            eTotal = eTotal + T(it);
        end
    end
end
totalExcl = eIn + eOut;
totalIncl = iIn + iOut;
%figure out our fitness based on what we got
F = iIn / totalIncl * evalParameters(2) + iTotal / totalIncl * evalParameters(6) + eIn / totalExcl * evalParameters(1) + (1 - (eTotal / totalExcl)) * evalParameters(5);
end

