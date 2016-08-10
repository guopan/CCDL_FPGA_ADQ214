clc
clear
%测试点数N
N = 1024;
%采样频率fs
fs = 200;

fid1 = fopen('FFT_SPEC_out.txt','r');
formatSpec = '%d %d';
sizeA = [2 Inf];
A = fscanf(fid1,formatSpec,sizeA);
sizeA = size(A);
fclose(fid1);
figure(1);
for i = 1:floor(sizeA(2)/N)
    B = A(:,(i-1)*N+1:(i-1)*N+N);
    B = sortrows(B',1);
    plot(B(:,1),B(:,2)*i);
    hold on;
end
hold off;