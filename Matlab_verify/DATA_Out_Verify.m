clc
clear
close all

NFFT = 1024;
nRangeBin = 6;
nPointsPerBin = 250;
% 每脉冲数据点数 N
N = 512;
% 采样频率fs，MHz
fs = 400;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 处理 FPGA 的输入数据，作为参考结果

DIN = importdata('FIFOIN_DATA_out.txt');
sizeDIN = size(DIN);
plot(DIN)

data_in = reshape(DIN,nPointsPerBin,[]);
[~, nn] = size(data_in);
data = zeros(NFFT,nn);
data(1:nPointsPerBin,:) = data_in;      % 补零
spec_MATLAB = fft(data);

spec_MATLAB = spec_MATLAB(NFFT/2+1:end,:);      % 取后一半
spec_MATLAB = flipud(spec_MATLAB);              % 频谱翻转
spec_MATLAB = spec_MATLAB.*conj(spec_MATLAB);   % 求功率谱

nPulse = nn/nRangeBin;
for i = 1:(nPulse - 1)
    spec_MATLAB(:,1:nRangeBin) = spec_MATLAB(:,1:nRangeBin) + spec_MATLAB(:,nRangeBin+1:(i+1)*nRangeBin);
end

%%%%%%%%
% Overlap处理

data_in_ovlp = reshape(DIN,[],nPulse);
data_in_ovlp = reshape(data_in_ovlp(nPointsPerBin*2+nPointsPerBin/2+1:end-nPointsPerBin/2,:),nPointsPerBin,[]);
[~, nn] = size(data_in_ovlp);
data_ovlp = zeros(NFFT,nn);
data_ovlp(1:nPointsPerBin,:) = data_in_ovlp;
spec_MATLAB_ovlp = fft(data_ovlp);

spec_MATLAB_ovlp = spec_MATLAB_ovlp(NFFT/2+1:end,:);
spec_MATLAB_ovlp = flipud(spec_MATLAB_ovlp);
spec_MATLAB_ovlp = spec_MATLAB_ovlp.*conj(spec_MATLAB_ovlp);

nRB_ovlp = nn/nPulse;
for i = 1:(nPulse - 1)
    spec_MATLAB_ovlp(:,1:nRB_ovlp) = spec_MATLAB_ovlp(:,1:nRB_ovlp) + spec_MATLAB_ovlp(:,nRB_ovlp+1:(i+1)*nRB_ovlp);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 比对 FPGA 的处理结果

A = importdata('DATA_out.txt');
sizeA = size(A);
plot(A)

%% 分段赋值
nLayers = length(A)/N;
% spec_res = zeros(nLayers,1024);
% k = 0;
% for i = 1:nLayers
%     for j = 1:N
%         k = k+1;
%         spec_res(i,j) = A(k);
%     end
% end
spec_FPGA = reshape(A,512,[]);
spec_FPGA = flipud(spec_FPGA);

%%
xaxis = fs/2*(1:N)/N; % 频率轴
k = 1;
kk = 1;
for i = 1:nLayers
    figure(i+1)
    plot(xaxis,spec_FPGA(:,i));
    hold on;
    if(i<3 | mod(i,2) == 1)
        plot(xaxis,spec_MATLAB(:,k));
        legend("spec-FPGA","spec-Matlab-ch1");
        k = k + 1;
        %     plot(spec_res(:,i));
    else
        plot(xaxis,spec_MATLAB_ovlp(:,kk));
        legend("spec-FPGA","spec-Matlab-ch2");
        kk = kk +1;
    end
end
TileWindows
