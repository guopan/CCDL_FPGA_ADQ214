% 用于计算补码
% 参数x：原始十进制数组，正负数皆可
% 参数N：输出的二进制补码最小位数，如果位数不够会根据x的取值范围自动扩展
% 输出值c：转换得到的二进制补码字符串数组
% 输出值n：实际输出的二进制补码位数
function [c,n] = complement(x, N)
n = 8;
c = 0;
if(nargin == 2)
    n = max(n, N);      % n最小8位
elseif((nargin == 0))
    return
end

% 确保正数不会溢出
Max_x = max(x);
if(Max_x > 0)   % max(x) = 127, 则n = 8; max(x) = 128, 则n = 9
    n = max(n, ceil(log2(Max_x+1)) + 1);
end

% 确保负数不会溢出，如果存在负数，对负数进行处理
MIN_x = min(x);
if(MIN_x < 0)   % min(x) = -128, 则n = 8; min(x) = -129, 则n = 9
    n = max(n, ceil(log2(-MIN_x)) + 1);
    index = find(x < 0);
    x(index) = x(index) + 2^n;
end

c = dec2bin(x, n);

end