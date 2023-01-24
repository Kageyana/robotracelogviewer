clc
clear all
% close all
%% パラメータ入力
filename = 'H:/243.csv';    % 読み込みファイル名

row = [ 2 8 4 5 1 ];       % 列数 pattern zg Encoder EncoderTotal logcnt
patternList = [ 11 19;            % 表示するパターン番号
       21 29;
       31 39;
       41 49;
       51 59;
       61 69;
       101 109];
 velocityList = [ 0 1;             % 表示する速度[m/s]
      1.1 2;
      2.1 3;
      3.1 3.2;
      3.3 3.4;
      3.5 3.6;
      3.7 4.5];
pulse = 60.074;	% 1mmのパルス
step = 10;      % プロットの間隔 
kg = 1.055;     % 補正係数
direction = 0;  % 周回方向  0:時計回り 1:反時計回り
gyroLSB = 16;


%% ログ読み込み
log = readmatrix(filename);    % ログファイル読み込み
logsize = size(log);            % 行列数取得
pattern = log(:,row(1,1));      % パターン取得
zg = log(:,row(1,2))./10;           % z軸角速度取得
Encoder = log(:,row(1,3));      % 速度取得
EncoderTotal = log(:,row(1,4)); % 総距離取得
logcnt = log(:,row(1,5));       % 時間取得

% 計算に使う行列を生成
t = 0:logsize-1;
degxy = zeros(logsize(1,1),1);
degz = zeros(logsize(1,1),1);
dl = zeros(logsize(1,1),1);
dlxy = zeros(logsize(1,1),1);
dlz = zeros(logsize(1,1),1);
velocity = zeros(logsize(1,1),1);
x = zeros(logsize(1,1),1);
y = zeros(logsize(1,1),1);
z = zeros(logsize(1,1),1);
% パターン別行列
xp = zeros(logsize(1,1),10);
yp = zeros(logsize(1,1),10);
xv = zeros(logsize(1,1),10);
yv = zeros(logsize(1,1),10);

% ログの取得周期を計算
dt = ( logcnt(2,1) - logcnt(1,1) )/ 1000;

for time = 2:logsize(1,1)
    % xy平面角度
    degxy(time, 1) = degxy(time-1,1) + ( -zg(time,1) * dt * kg);
    
%     if pattern(time, 1) > 70 && pattern(time, 1) < 80
%         degz(time,1) = degz(time-1,1) + ( xg(time,1) * dt );
%     else
%         degz(time,1) = 0;
%     end
    % 速度を計算
    velocity(time, 1) = Encoder(time,1) / pulse;
    % dt後の距離
    dl(time, 1) = ( EncoderTotal(time,1) - EncoderTotal(time-1,1) ) / pulse;
    dlxy(time, 1) = dl(time, 1)*cosd(degz(time, 1));

    x(time, 1) = x(time-1,1) + ( dl(time, 1) * sind( degxy(time, 1) ) );   % x座標計算
    y(time, 1) = y(time-1,1) + ( dl(time, 1) * cosd( degxy(time, 1) ) );   % y座標計算
    
    if rem(time,step) == 0
        for num = 1:7
            % パターン別に座標を格納する
            if pattern(time, 1) >= patternList(num,1) && pattern(time, 1) <= patternList(num,2)
                xp(time, num) = x(time,1);   % x座標計算
                yp(time, num) = y(time,1);   % y座標計算
            end
            % 速度別に座標を格納する
            if velocity(time, 1) > velocityList(num,1)-0.1 && velocity(time, 1) <= velocityList(num,2)
                xv(time, num) = x(time,1);   % x座標計算
                yv(time, num) = y(time,1);   % y座標計算
            end
        end
    end
end

%% 軌跡表示
% パターンごとにプロット
subplot(1,2,1);
plot(xp,yp,'o')
% if direction == 1
%     xlim([-7000 1000])
%     xticks(-7000:1000:1000)
%     ylim([-6000 6000])
%     yticks(-6000:1000:6000)
% else
%     xlim([-1000 7000])
%     xticks(-1000:1000:7000)
%     ylim([-6000 6000])
%     yticks(-6000:1000:6000)
% end
xlim([-200 1000])
xticks(-1000:100:1000)
ylim([-1000 1000])
yticks(-1000:100:1000)

grid on
daspect([1 1 1])    % 縦横比を1:1にする
% 凡例
legend('Location','eastoutside','FontSize',12)
legend(['pattern',num2str(patternList(1,1)),'～',num2str(patternList(1,2)),],['pattern',num2str(patternList(2,1)),'～',num2str(patternList(2,2)),],['pattern',num2str(patternList(3,1)),'～',num2str(patternList(3,2)),],['pattern',num2str(patternList(4,1)),'～',num2str(patternList(4,2)),],['pattern',num2str(patternList(5,1)),'～',num2str(patternList(5,2)),],['pattern',num2str(patternList(6,1)),'～',num2str(patternList(6,2)),],['pattern',num2str(patternList(7,1)),'～',num2str(patternList(7,2)),])


% 速度ごとにプロット
subplot(1,2,2);
plot(xv,yv,'o')
% if direction == 1
%     xlim([-1000 1000])
%     xticks(-1000:1000:1000)
%     ylim([-1000 1000])
%     yticks(-1000:1000:1000)
% else
%     xlim([-1000 1000])
%     xticks(-1000:1000:1000)
%     ylim([-1000 1000])
%     yticks(-1000:1000:1000)
% end
xlim([-200 1000])
xticks(-1000:100:1000)
ylim([-1000 1000])
yticks(-1000:100:1000)

grid on
daspect([1 1 1])    % 縦横比を1:1にする
% 凡例
legend('Location','eastoutside','FontSize',12)
legend([num2str(velocityList(1,1)),'～',num2str(velocityList(1,2)),'m/s'],[num2str(velocityList(2,1)),'～',num2str(velocityList(2,2)),'m/s'],[num2str(velocityList(3,1)),'～',num2str(velocityList(3,2)),'m/s'],[num2str(velocityList(4,1)),'～',num2str(velocityList(4,2)),'m/s'],[num2str(velocityList(5,1)),'～',num2str(velocityList(5,2)),'m/s'],[num2str(velocityList(6,1)),'～',num2str(velocityList(6,2)),'m/s'],[num2str(velocityList(7,1)),'～',num2str(velocityList(7,2)),'m/s'])

% plot(degz)