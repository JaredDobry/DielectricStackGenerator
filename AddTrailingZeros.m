function out = AddTrailingZeros(in, num)
%ADDTRAILINGZEROS Appends trailing zeros to the vector
if length(in) == num
    out = in;
else
    out = zeros(num, 1);
    out(1:length(in)) = in;
end
end

