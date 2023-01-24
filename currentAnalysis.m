clc
clear all
% close all
%% パラメータ入力
filename = 'H:/249.csv';    % 読み込みファイル名

%% ログ読み取り
log = readmatrix(filename);    % ログファイル読み込み
logsize = size(log);            % 行列数取得
pattern = log(:,2);      % パターン取得
zg = log(:,8)./10;       % z軸角速度取得
zAngle = log(:,9)./10;       % z軸角速度取得
Encoder = log(:,4);      % 速度取得
EncoderTotal = log(:,5); % 総距離取得
logcnt = log(:,1);       % 時間取得
rawCurrentL = log(:,10);  % 左モータ電流値
rawCurrentR = log(:,11);  % 左モータ電流値

rawCurrent = (rawCurrentL + rawCurrentR) /2;

rawCurrent = movmean(-rawCurrent,10);
rawCurrentL = movmean(-rawCurrentL,10);
rawCurrentR = movmean(-rawCurrentR,10);

%% プロット
subplot(2,1,1);
plot(logcnt,rawCurrent)

subplot(2,1,2);
plot(logcnt,Encoder)