% ���ڼ��㲹��
% ����x��ԭʼʮ�������飬�������Կ�
% ����N������Ķ����Ʋ�����Сλ�������λ�����������x��ȡֵ��Χ�Զ���չ
% ���ֵc��ת���õ��Ķ����Ʋ����ַ�������
% ���ֵn��ʵ������Ķ����Ʋ���λ��
function [c,n] = complement(x, N)
n = 8;
c = 0;
if(nargin == 2)
    n = max(n, N);      % n��С8λ
elseif((nargin == 0))
    return
end

% ȷ�������������
Max_x = max(x);
if(Max_x > 0)   % max(x) = 127, ��n = 8; max(x) = 128, ��n = 9
    n = max(n, ceil(log2(Max_x+1)) + 1);
end

% ȷ���������������������ڸ������Ը������д���
MIN_x = min(x);
if(MIN_x < 0)   % min(x) = -128, ��n = 8; min(x) = -129, ��n = 9
    n = max(n, ceil(log2(-MIN_x)) + 1);
    index = find(x < 0);
    x(index) = x(index) + 2^n;
end

c = dec2bin(x, n);

end