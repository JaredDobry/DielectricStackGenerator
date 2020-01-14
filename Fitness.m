%Fitness.m
function effectiveness = Fitness(d, lowExclB, lowExclT, inclB, inclT, upExclB, upExclT, exclConstraint, inclConstraint,plotMe)
    d = [0 d];
    z = cumsum(d); %calc where all the boundaries are
    n = [1 repmat([2.2 4.2], 1, length(d))]; %barrier n's

    N = 200; %Number of iterations to check over the wavelength range
    L = linspace(lowExclB - 1,upExclT + 1,N);
    ii = 1;
    sumLowerExcl = 0; sumIncl = 0; sumUpExcl = 0;
    numLowB = 0; numInclB = 0; numUpB = 0;
    numLowG = 0; numInclG = 0; numUpG = 0;
    countIncl = 0; countExclUp = 0; countExclLow = 0;
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
        if l >= lowExclB && l <= lowExclT
            countExclLow = countExclLow + 1;
            sumLowerExcl = sumLowerExcl + T(ii);
            if T(ii) < exclConstraint
                numLowG = numLowG + 1;
            else
                numLowB = numLowB + 1;
            end
        elseif l >= inclB && l <= inclT
            countIncl = countIncl + 1;
            sumIncl = sumIncl + T(ii);
            if T(ii) > inclConstraint
                numInclG = numInclG + 1;
            else
                numInclB = numInclB + 1;
            end
        elseif l >= upExclB && l <= upExclT
            countExclUp = countExclUp + 1;
            sumUpExcl = sumUpExcl + T(ii);
            if T(ii) < exclConstraint
                numUpG = numUpG + 1;
            else
                numUpB = numUpB + 1;
            end
        end
        ii = ii + 1;
    end
    if plotMe
        plot(L,T,'k');
        xlabel('wavelength [nm]');
        ylabel('Transmission');
        line([inclB inclB], [0 1]); line([inclT inclT], [0 1]);
        line([lowExclT lowExclT], [0 1]); line([upExclB upExclB], [0 1]);
        drawnow;
    end
    avgExclLow = sumLowerExcl/countExclLow;
    avgExclUp = sumUpExcl/countExclUp;
    eEUR = weightExcl*((numLowG)/(numLowG + numLowB))/2;
    eELR = weightExcl*((numUpG)/(numUpG + numUpB))/2;
    eIR = weightIncl*(numInclG/(numInclG+numInclB));
    eIAvg = weightAvgIncl*sumIncl/countIncl/inclConstraint;
    eEUAvg = weightAvgExcl*exclConstraint/avgExclUp;
    eELAvg = weightAvgExcl*exclConstraint/avgExclLow;
    if eIAvg >= weightAvgIncl
        eIAvg = weightAvgIncl;
    end
    if eEUAvg >= weightAvgExcl/2
        eEUAvg = weightAvgExcl/2;
    end
    if eELAvg >= weightAvgExcl/2
        eELAvg = weightAvgExcl/2;
    end
    effectiveness = eEUR + eELR + eIR + eIAvg + eEUAvg + eELAvg;
end