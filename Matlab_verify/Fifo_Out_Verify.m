clc
clear
close all
%���Ե���N
N = 1024;
%����Ƶ��fs
fs = 200;

A = importdata('FIFO_out.txt');
sizeA = size(A);
plot(A)

%% �ֶθ�ֵ
nLayers = length(A)/512;
spec_res = zeros(nLayers,1024);
k = 0;
for i = 1:nLayers
    for j = 1:512
        k = k+1;
        spec_res(i,j) = A(k);
    end
end


%%
xaxis = 20*(1:1024)./1024; % Ƶ����
for i = 1:nLayers
    figure(i+1)
    plot(xaxis,spec_res(i,:));
end
TileWindows