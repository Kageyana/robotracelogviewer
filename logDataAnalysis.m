clc
clear all
% close all
%% パラメータ入力
filename = 'H:/299.csv';    % 読み込みファイル名

pulse = 60.074;	% 1mmのパルス
step = 2;      % プロットの間隔 
kg = 1.055;         % 補正係数
samplestep = 16;     % 平均値のサンプル数
direction = 0;  % 周回方向  0:時計回り 1:反時計回り
gyroLSB = 16;   % ジャイロセンサの変換係数
courseSize = [  -200    1000;
                -1000   1000];
%% ログ読み込み
log = readtable(filename);      % ログファイル読み込み
logsize = size(log);            % 行列数取得
pattern = log.patternTrace;     % パターン取得
gyroZ = -log.gyroVal_Z ./10;    % z軸角速度取得
Encoder = log.encCurrentN;      % 速度取得
EncoderTotal = log.encTotalN;   % 総距離取得
cntLog = log.cntlog;            % 時間取得
modeCurve = log.modeCurve;      % 直線モード
rawCurrentL = log.rawCurrentL;        % 左モータ電流値
rawCurrentR = log.rawCurrentR;        % 左モータ電流値
%% 電流値解析
rawCurrent = (rawCurrentL + rawCurrentR) /2;
rawCurrentRnomal = normalize(rawCurrentR);
% rawCurrent = movmean(-rawCurrent,samplestep);
% rawCurrentL = movmean(-rawCurrentL,samplestep);
% rawCurrentR = movmean(-rawCurrentR,samplestep);
% 
% rawCurrentnomal = rawCurrent ./ max(rawCurrent);
% rawCurrentLnomal = rawCurrentL ./ max(rawCurrentL);
% rawCurrentRnomal = rawCurrentR ./ max(rawCurrentR);

%% 速度解析
velocityLmean = movmean(log.encCurrentL,samplestep);
velocityRmean = movmean(log.encCurrentR,samplestep);

velocityLnomal = velocityLmean ./ max(velocityLmean);
velocityRnomal = velocityRmean ./ max(velocityRmean);

velocityL = log.encCurrentL;
velocityR = log.encCurrentR;
for c = 1:size(cntLog,1)
    if c > 30
        if rawCurrentL(c,1) - rawCurrentL(c-2,1) < 0 && velocityLnomal(c,1) - velocityLnomal(c-2,1) > 0
            velocityL(c,1) = velocityL(c-1,1);

        end
        if rawCurrentR(c,1) - rawCurrent(c-2,1) < 0 && velocityRnomal(c,1) - velocityRnomal(c-2,1) > 0
            velocityR(c,1) = velocityR(c-1,1);

        end
    end
    
end

Encodercal = (velocityL + velocityR)/2;
% Encoder = (velocityL + velocityR)/2;
velocitycal = Encodercal ./ pulse .* 1000;                  % 速度行列[mm/s]
%% 角速度解析
for c = 1:size(cntLog,1)
    if c > 2
        if abs(gyroZ(c,1)) < 250
%             gyroZ(c,1) = gyroZ(c-1,1);
        end
    end
end
%% コース座標計算
% 条件別行列を生成
xc = zeros(logsize(1,1),1);
yc = zeros(logsize(1,1),1);

% 座標算出
dt = ( cntLog(2,1) - cntLog(1,1) ) / 1000;      % サンプリング周期
cntLog = cntLog ./ 1000;                        % [ms]から[s]に変換
degxy = cumtrapz(cntLog, gyroZ .* kg);                % 角度行列[deg/s] 角速度を積算
velocity = Encoder ./ pulse .* 1000;                  % 速度行列[mm/s]
x = cumtrapz(cntLog, ( velocity .* sind(degxy) ));
y = cumtrapz(cntLog, ( velocity .* cosd(degxy) ));

% 角度補正係数の調整
% while 1
%     if abs(x(end,1) - x(end-20,1)) < 1
%         break;
%     else
%         kg = kg + 0.001;        % 角度補正係数
%         degxy = cumtrapz(cntLog, gyroZ .* kg);
%         x = cumtrapz(cntLog, ( velocity .* sind(degxy) ));
%         y = cumtrapz(cntLog, ( velocity .* cosd(degxy) ));
%     end
% end
txy = table(cntLog,x,y,velocity); % テーブル作成

% 条件別に座標を格納する
% 直線-カーブ変化点
% ischange(modeCurve)
% xc(time, 1) = x(time,1);   % x座標計算
% yc(time, 1) = y(time,1);   % y座標計算
%% 軌跡表示
% パターンごとにプロット
% colororder(newcolors)
subplot(3,2,[1 5]);
% scatter(xp,yp,'o','ButtonDownFcn',@(src,evnt)setXline(src,evnt,txy));
scatter(txy,'x','y','ColorVariable','velocity');
hold on
scatter(txy.x(ischange(modeCurve)),txy.y(ischange(modeCurve)),'ro','ButtonDownFcn',@(src,evnt)setXline(src,evnt,txy))
hold off
colorbar
% 軸設定
if direction == 0
    xlim([courseSize(1,1) courseSize(1,2)])
    ylim([courseSize(2,1) courseSize(2,2)])
else
    xlim([-courseSize(1,2) -courseSize(1,1)])
    ylim([-courseSize(2,2) -courseSize(2,1)])
end
xticks(-10000:100:10000)
yticks(-10000:100:10000)
xlabel("[mm]")
ylabel("[mm]")
grid on         % グリッド線表示
axis equal  % 縦横比を1:1にする

%% 電流表示
subplot(3,2,2);
plot(cntLog,rawCurrentRnomal)
hold on
plot(cntLog,velocityRnomal)
hold off
ylim([0 1.2])
% for c = 1:size(cntLog,1)
%     if c > 2
%         if rawCurrentLnomal(c,1) - rawCurrentLnomal(c-2,1) < 0 && velocityLnomal(c,1) - velocityLnomal(c-2,1) > 0
% %             xline(cntLog(c,1));
%         end
%     end
% end
% title("Motor average current")
% xlabel("time[s]")
% ylabel("current[mA]")
%% 速度表示
subplot(3,2,4);
plot(cntLog,[velocity velocitycal])
% title("Robot velocity")
% xlabel("time[s]")
% ylabel("velocity[mm/s]")
%% 角速度表示
subplot(3,2,6);
plot(cntLog,gyroZ)
% title("Robot angularvelocity")
% xlabel("time[s]")
% ylabel("angularvelocity[deg/s]")

yline(250)
yline(-250)
%% 関数
function setXline(src,~,varargin)
    % 静的変数 
    persistent xline_handle2 xline_handle4 xline_handle6;
    persistent beforeLine;
    
    % cell配列からデータを取り出す
    txy = varargin{1};
    X = txy.x;
    Y = txy.y;
    time = txy.cntLog;

    Cp = get(gca,'CurrentPoint');   % マウス座標を取得
    Xp = Cp(2,1);  % クリック位置のX座標
    Yp = Cp(2,2);  % クリック位置のY座標
    [dp,Ip] = min((X-Xp).^2+(Y-Yp).^2);     % クリック点に近い配列値のインデックス
    Xc = X(Ip);
%     Yc = Y(Ip);
    index = find(X==Xc(1,1));
    time(index,1);
    
    % 定数線
    delete(xline_handle2);
    delete(xline_handle4);
    delete(xline_handle6);
    if beforeLine == time(index,1)
        clear xline_handle2
        clear xline_handle4
        clear xline_handle6
        clear beforeLine
    else
        subplot(3,2,2);
        xline_handle2 = xline(time(index,1));
        subplot(3,2,4);
        xline_handle4 = xline(time(index,1));
        subplot(3,2,6);
        xline_handle6 = xline(time(index,1));
    end
    beforeLine = time(index,1);

end