% �����������Ҳ�������
% ������ļ��������Ʋ����ʾ
clc
clear

%���ɲ���Ƶ��
fs = 20;   % Hz ����Ƶ��
f = 2;     % Hz �ź�Ƶ��
N = 1024;  % FFT����
Amp = 50   % �źŷ�ֵ
Total_Points = 4000;    % �������ݵ��ܵ���
Bit_Width = 16;         % �������ݵ�λ��

x = 0:1/fs:(Total_Points-1)/fs;
y = round( Amp*sin(2*pi*f*x) );

% ��ʾʱ����ͼ
figure(1)
plot(x,y);
hold on;
xlabel('ʱ��/s');
ylabel('�źŷ���');
title('ʱ��ͼ')

% ����FFTƵ��
Y = fft(y);
mag = abs(Y);

%% ��ʾƵ��ͼ��
f_index = (0:Total_Points-1)*fs/N;
[c1,c2] = max(mag);
figure(2)
plot(f_index,mag);

xlabel('Ƶ��/Hz');
ylabel('�����׷���');
title('Ƶ��ͼ')
grid on;

%% ת��Ϊ�����Ʋ�����ʽ
[BinNumber,n] = complement(y,Bit_Width);
if (n > Bit_Width)
    display('Ԥ������λ�����㣬�������ļ�λ�����');
end

%% д���ļ�
fid = fopen('..\..\implementation\xilinx\sinewave.txt','wt');

for i = 1:Total_Points
    fprintf(fid,'%s\n',BinNumber(i,:));
end

fclose(fid);

