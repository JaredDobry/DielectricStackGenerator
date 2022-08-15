function out = RemoveTrailingZeros(in)
%REMOVETRAILINGZEROS Removes the trailing zeros from an individual in the
%population
for it = length(in):-1:2
    if in(it) ~= 0
        out = in(1:it);
        return;
    end
end
end

