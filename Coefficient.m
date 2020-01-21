function T = Coefficient(boundaries, wavelength)
%COEFFICIENT returns the transmittance coefficient of the wavelength on
%the dielectric specified by the boundaries
%note: boundaries MUST be of even length
%assert(mod(length(boundaries),2) == 0);
z = cumsum(boundaries);
n = [1 repmat([2.2 4.2], 1, length(z) / 2)];
%assert(length(n) == length(z) + 1);
M = eye(2);
kL = n(1) * 2.0 * pi / wavelength;
k2 = kL;
for it = 1:length(z)
    k1 = k2;
    k2 = n(it + 1) * 2.0 * pi / wavelength;
    
    M11 = .5  * (1 + n(it + 1) / n(it)) * exp(1i * (k2 - k1) * z(it));
    M12 = .5  * (1 - n(it + 1) / n(it)) * exp(-1i * (k2 + k1) * z(it));
    M21 = .5  * (1 - n(it + 1) / n(it)) * exp(1i * (k2 + k1) * z(it));
    M22 = .5  * (1 + n(it + 1) / n(it)) * exp(-1i * (k2 - k1) * z(it));
    
    M = M * [M11 M12;
             M21 M22];
end
T = real(k2 / kL * (1 / M(1,1))' * (1 / M(1,1)));
end

