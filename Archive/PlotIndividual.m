function PlotIndividual(boundaries, constraints, type)
%PLOTINDIVIDUAL plots the fitness of a single individual

%get the transmission coefficients
firstWL = constraints(1,1);
lastWL = constraints(3,2);
wls = linspace(firstWL, lastWL, 256); %using 2^n elements results in a memory management speedup
T = zeros(length(wls), 1);
for it = 1:length(T)
    T(it) = Coefficient(boundaries, wls(it));
end
plot(wls, T);
if type == 0
    title("Short wavelength band-pass filter generation");
elseif type == 1
    title("Long wavelength band-pass filter generation");
elseif type == 2
    title("Full dielectric band-pass filter generation");
end
drawnow;
end

