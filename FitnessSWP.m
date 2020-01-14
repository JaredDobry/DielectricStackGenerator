%FitnessSWP.m
function effectiveness = FitnessSWP(d, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint,plotMe);
d = [0 d];
z = cumsum(d); %calc where all the boundaries are
n = [1 repmat([2.2 4.2], 1, length(d))]; %barrier n's

N = 100; %Number of iterations to check over the wavelength range
L = linspace(inclB - 1,upExclT + 1,N);
ii = 1;
sumIncl = 0; sumUpExcl = 0;
numInclB = 0; numInclG = 0; 
numUpB = 0; numUpG = 0;
countIncl = 0;
countExcl = 0;
weightExcl = .1; weightIncl = .1; 
weightAvgIncl = .4; weightAvgExcl = .4;
T = zeros(1,N);
for l = L
    kL = n(1)*2*pi/l;
    k2 = kL;
    M = eye(2);
    for jj = 1:length(z)
        k1 = k2;
        k2 = n(jj +1)*2*pi/l;
        
        M11 = .5*(1+n(jj+1)/n(jj))*exp(1i*(k2-k1)*z(jj));
        M12 = .5*(1-n(jj+1)/n(jj))*exp(-1i*(k2+k1)*z(jj));
        M21 = .5*(1-n(jj+1)/n(jj))*exp(1i*(k2+k1)*z(jj));
        M22 = .5*(1+n(jj+1)/n(jj))*exp(-1i*(k2-k1)*z(jj));
        
        M = M*[M11 M12 ;
               M21 M22 ];
    end
    T(ii) = real(k2/kL*(1/M(1,1))'*(1/M(1,1)));
    if l >= inclB && l <= inclT
        countIncl = countIncl + 1;
        if T(ii) > inclConstraint
            numInclG = numInclG + 1;
            sumIncl = sumIncl + inclConstraint; %don't let higher values make up for lower ones
        else
            numInclB = numInclB + 1;
            sumIncl = sumIncl + T(ii);
        end
    elseif l >= upExclB && l <= upExclT
        countExcl = countExcl + 1;
        if T(ii) < exclConstraint
            numUpG = numUpG + 1;
            sumUpExcl = sumUpExcl + exclConstraint;
        else
            numUpB = numUpB + 1;
            sumUpExcl = sumUpExcl + T(ii);
        end
    end
    ii = ii + 1;
end
if plotMe
    plot(L,T);
    title('Short Wave Pass');
    xlabel('wavelength [nm]');
    ylabel('Transmission');
    drawnow;
end
avgExcl = sumUpExcl/countExcl;
eER = weightExcl*((numUpG)/(numUpG + numUpB));
eIR = weightIncl*(numInclG/(numInclG+numInclB));
eIAvg = weightAvgIncl*sumIncl/countIncl/inclConstraint;
eEAvg = weightAvgExcl*exclConstraint/avgExcl;
if eIAvg >= weightAvgIncl
    eIAvg = weightAvgIncl;
end
if eEAvg >= weightAvgExcl
    eEAvg = weightAvgExcl;
end
effectiveness = eER + eIR + eIAvg + eEAvg; 
end