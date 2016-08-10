% 用于生成正弦测试序列
% 输出到文件：二进制补码表示
clc
clear

%生成测试频谱
fs = 20;   % Hz 采样频率
f = 2;     % Hz 信号频率
N = 1024;  % FFT点数
Amp = 50   % 信号幅值
Total_Points = 4000;    % 生成数据的总点数
Bit_Width = 16;         % 生成数据的位宽

x = 0:1/fs:(Total_Points-1)/fs;
y = round( Amp*sin(2*pi*f*x) );

% 显示时域波形图
figure(1)
plot(x,y);
hold on;
xlabel('时间/s');
ylabel('信号幅度');
title('时域图')

% 计算FFT频谱
Y = fft(y);
mag = abs(Y);

%% 显示频域图形
f_index = (0:Total_Points-1)*fs/N;
[c1,c2] = max(mag);
figure(2)
plot(f_index,mag);

xlabel('频率/Hz');
ylabel('功率谱幅度');
title('频谱图')
grid on;

%% 转换为二进制补码形式
[BinNumber,n] = complement(y,Bit_Width);
if (n > Bit_Width)
    display('预设数据位数不足，二进制文件位数溢出');
end

%% 写入文件
fid = fopen('..\..\implementation\xilinx\sinewave.txt','wt');

for i = 1:Total_Points
    fprintf(fid,'%s\n',BinNumber(i,:));
end

fclose(fid);

