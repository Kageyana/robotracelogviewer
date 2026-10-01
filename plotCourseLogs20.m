function [courses, usedFiles] = plotCourseLogs20(rootDir, varargin)
% plotCourseLogs20
% 指定フォルダ内のログCSVから任意個数分のコースプロットを表示します。
% プロット列数は常に5列です。
%
% 使い方:
%   plotCourseLogs20("C:\logs")
%       -> フォルダ内の *.csv からログ番号を読み取り、番号が大きい順に最新20個を選択して表示
%
%   plotCourseLogs20("C:\logs", 'DisplayCount', 10)
%       -> 表示個数を10個に変更して表示（列数は常に5）
%
%   plotCourseLogs20("C:\logs", 'LogNumbers', 5001:5020)
%       -> 指定したログ番号.csv を表示
%
%   plotCourseLogs20("C:\logs", ...
%       'Rotate', 90, ...
%       'KGyro', 1.0, ...
%       'UseRadians', false, ...
%       'TimeVar', "time", ...
%       'AngularVelocityVar', "angularVelocity", ...
%       'VelocityVar', "velocity")
%
% 前提:
% - CSVファイル名は「ログ番号.csv」(例: 5001.csv)
% - ログ先頭に key=value 形式のヘッダ行があっても読み込めるようにしています
% - 時間, 角速度, 速度の列名は自動推定します
%
% 出力:
%   courses  : 各ログの timetable を格納した cell 配列
%   usedFiles: 実際に使用したCSVパスの string 配列

    p = inputParser;
    p.addRequired('rootDir', @(x) ischar(x) || isstring(x));

    p.addParameter('LogNumbers', [], @(x) isnumeric(x) || ischar(x) || isstring(x) || iscellstr(x));
    p.addParameter('Rotate', 0, @(x) isnumeric(x) && isscalar(x));
    p.addParameter('KGyro', 1, @(x) isnumeric(x) && isscalar(x));
    p.addParameter('UseRadians', false, @(x) islogical(x) || isnumeric(x));
    p.addParameter('TimeVar', "", @(x) ischar(x) || isstring(x) || (isnumeric(x) && isscalar(x)));
    p.addParameter('AngularVelocityVar', "", @(x) ischar(x) || isstring(x) || (isnumeric(x) && isscalar(x)));
    p.addParameter('VelocityVar', "", @(x) ischar(x) || isstring(x) || (isnumeric(x) && isscalar(x)));
    p.addParameter('FilePattern', "*.csv", @(x) ischar(x) || isstring(x));
    p.addParameter('DisplayCount', 20, @(x) isnumeric(x) && isscalar(x) && x >= 1);
    p.addParameter('FigureName', "Course Plot (20 logs)", @(x) ischar(x) || isstring(x));
    p.addParameter('ColormapName', "turbo", @(x) ischar(x) || isstring(x));

    p.parse(rootDir, varargin{:});
    opt = p.Results;
    rootDir = string(opt.rootDir);

    if ~isfolder(rootDir)
        error('指定フォルダが存在しません: %s', rootDir);
    end

    usedFiles = resolveTargetFiles(rootDir, opt.LogNumbers, opt.FilePattern, opt.DisplayCount);
    if isempty(usedFiles)
        error('対象となるCSVファイルが見つかりませんでした。');
    end

    nFiles = numel(usedFiles);
    nDisplay = max(1, round(opt.DisplayCount));
    courses = cell(1, nFiles);
    titles  = strings(1, nFiles);
    validIdx = false(1, nFiles);
    vMin = inf;
    vMax = -inf;

    for k = 1:nFiles
        filePath = usedFiles(k);
        [~, name, ~] = fileparts(filePath);
        titles(k) = string(name);

        try
            [T, headerInfo] = readLogTable(filePath); %#ok<ASGLU>

            time = pickColumn(T, opt.TimeVar, ...
                ["cntlog","time","Time","t","sec","seconds","timestamp"]);
            angVel = pickColumn(T, opt.AngularVelocityVar, ...
                ["gyroVal_Z","angularVelocity","AngularVelocity","gyroZ","gyro_z","wz","yawRate","omega","gyro"]);
            vel = pickColumn(T, opt.VelocityVar, ...
                ["encCurrentCorr_p","velocity","Velocity","speed","Speed","v"]);

            time = time / 1000;
            vel = vel / 54.324 * 1000;

            [time, angVel, vel] = sanitizeVectors(time, angVel, vel);

            degxy = cumtrapz(time, angVel .* opt.KGyro);
            degxy = degxy + opt.Rotate;

            if logical(opt.UseRadians)
                x = cumtrapz(time, vel .* sin(degxy));
                y = cumtrapz(time, vel .* cos(degxy));
            else
                x = cumtrapz(time, vel .* sind(degxy));
                y = cumtrapz(time, vel .* cosd(degxy));
            end

            courses{k} = timetable(seconds(time), x, y, vel, ...
                'VariableNames', {'x','y','velocity'});

            if ~isempty(vel)
                vMin = min(vMin, min(vel));
                vMax = max(vMax, max(vel));
            end
            validIdx(k) = true;

        catch ME
            warning('読み込み失敗: %s\n  %s', filePath, ME.message);
            courses{k} = timetable();
            validIdx(k) = false;
        end
    end

    if ~any(validIdx)
        error('すべてのファイルで読み込みに失敗しました。列名またはCSV形式を確認してください。');
    end

    if ~isfinite(vMin) || ~isfinite(vMax) || vMin == vMax
        vMin = 0;
        vMax = 1;
    end

    nCols = 10;
    nRows = ceil(nDisplay / nCols);

    fig = figure('Name', char(opt.FigureName), 'Color', 'w');
    tl = tiledlayout(fig, nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(tl, sprintf('%s  (%d/%d files)', char(opt.FigureName), min(nFiles, nDisplay), nFiles), 'Interpreter', 'none');

    for k = 1:nDisplay
        ax = nexttile(tl);
        if k > nFiles
            axis(ax, 'off');
            continue;
        end

        course = courses{k};
        if isempty(course) || height(course) == 0
            text(ax, 0.5, 0.5, sprintf('%s\n読み込み失敗', titles(k)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'Interpreter', 'none');
            axis(ax, 'off');
            continue;
        end

        scatter(ax, course.x, course.y, 8, course.velocity, 'filled');
        grid(ax, 'on');
        title(ax, char(titles(k)), 'Interpreter', 'none', 'FontSize', 10);
        xlabel(ax, 'x [mm]');
        ylabel(ax, 'y [mm]');
        daspect(ax, [1 1 1]);
        xlim(ax, [min(course.x)-100, max(course.x)+100]);
        ylim(ax, [min(course.y)-100, max(course.y)+100]);
        clim(ax, [vMin vMax]);
    end

    try
        colormap(fig, char(opt.ColormapName));
    catch
        colormap(fig, turbo);
    end

    cb = colorbar;
    cb.Layout.Tile = 'east';
    cb.Label.String = 'velocity [mm/s]';
end

function usedFiles = resolveTargetFiles(rootDir, logNumbers, filePattern, displayCount)
    if isempty(logNumbers)
        files = dir(fullfile(rootDir, char(filePattern)));
        if isempty(files)
            usedFiles = strings(0,1);
            return;
        end

        nums = nan(numel(files),1);
        paths = strings(numel(files),1);

        for i = 1:numel(files)
            paths(i) = string(fullfile(files(i).folder, files(i).name));
            [~, name, ~] = fileparts(files(i).name);

            token = regexp(name, '(\d+)', 'tokens', 'once');
            if ~isempty(token)
                nums(i) = str2double(token{1});
            end
        end

        valid = ~isnan(nums);
        if any(valid)
            nums = nums(valid);
            paths = paths(valid);
            [~, idx] = sort(nums, 'descend');  % 大きい番号を優先
            paths = paths(idx);
        else
            [~, idx] = sort(paths, 'descend');
            paths = paths(idx);
        end

        paths = paths(1:min(round(displayCount), numel(paths)));
        usedFiles = flipud(paths);  % 表示は昇順寄りにする
        return;
    end

    if ischar(logNumbers) || isstring(logNumbers)
        logNumbers = str2double(string(logNumbers));
    elseif iscell(logNumbers)
        logNumbers = str2double(string(logNumbers));
    end

    logNumbers = logNumbers(:);
    if isempty(logNumbers)
        usedFiles = strings(0,1);
        return;
    end

    if numel(logNumbers) > round(displayCount)
        logNumbers = logNumbers(1:round(displayCount));
    end

    usedFiles = strings(0,1);
    for i = 1:numel(logNumbers)
        fp = string(fullfile(rootDir, sprintf('%d.csv', logNumbers(i))));
        if isfile(fp)
            usedFiles(end+1,1) = fp; %#ok<AGROW>
        else
            warning('ファイルが存在しません: %s', fp);
        end
    end
end

function [T, headerInfo] = readLogTable(filePath)
    lines = splitlines(string(fileread(filePath)));
    headerInfo = struct();

    headerCount = 0;
    for i = 1:numel(lines)
        s = strtrim(lines(i));
        if s == ""
            headerCount = headerCount + 1;
            continue;
        end

        if contains(s, "=") && ~contains(s, ",") && ~contains(s, ";")
            parts = split(s, "=");
            if numel(parts) >= 2
                key = matlab.lang.makeValidName(strtrim(parts(1)));
                valStr = strtrim(join(parts(2:end), "="));
                valNum = str2double(valStr);
                if ~isnan(valNum)
                    headerInfo.(key) = valNum;
                else
                    headerInfo.(key) = char(valStr);
                end
            end
            headerCount = headerCount + 1;
        else
            break;
        end
    end

    contentLines = lines((headerCount+1):end);
    [headerLineRel, dataLineRel, delim, hasVariableNames] = detectCsvLayout(contentLines);

    headerLineAbs = headerCount + headerLineRel;
    dataLineAbs   = headerCount + dataLineRel;

    if hasVariableNames
        T = readtable(filePath, ...
            'Delimiter', delim, ...
            'NumHeaderLines', headerLineAbs-1, ...
            'VariableNamingRule', 'preserve', ...
            'TextType', 'string');
    else
        T = readtable(filePath, ...
            'Delimiter', delim, ...
            'NumHeaderLines', dataLineAbs-1, ...
            'ReadVariableNames', false, ...
            'VariableNamingRule', 'preserve', ...
            'TextType', 'string');
    end
end

function [headerLineRel, dataLineRel, delim, hasVariableNames] = detectCsvLayout(lines)
    headerLineRel = [];
    dataLineRel = [];
    delim = ",";
    hasVariableNames = true;

    n = numel(lines);
    for i = 1:n
        s = strtrim(lines(i));
        if s == ""
            continue;
        end

        delimNow = pickDelimiter(s);
        tokens = split(s, delimNow);

        if numel(tokens) < 3
            continue;
        end

        numericCount = countNumericTokens(tokens);

        if numericCount >= max(3, ceil(0.7 * numel(tokens)))
            headerLineRel = i;
            dataLineRel = i;
            delim = delimNow;
            hasVariableNames = false;
            return;
        end

        if i < n
            s2 = strtrim(lines(i+1));
            if s2 == ""
                continue;
            end

            delimNext = pickDelimiter(s2);
            if delimNext ~= delimNow
                continue;
            end

            tokens2 = split(s2, delimNow);
            if numel(tokens2) < 3
                continue;
            end

            numericCount2 = countNumericTokens(tokens2);
            if numericCount2 >= max(3, ceil(0.5 * numel(tokens2)))
                headerLineRel = i;
                dataLineRel = i + 1;
                delim = delimNow;
                hasVariableNames = true;
                return;
            end
        end
    end

    error('CSVの列ヘッダまたはデータ開始位置を判定できませんでした。');
end

function delim = pickDelimiter(lineStr)
    if count(lineStr, ";") > count(lineStr, ",")
        delim = ";";
    else
        delim = ",";
    end
end

function n = countNumericTokens(tokens)
    n = 0;
    for i = 1:numel(tokens)
        tk = erase(tokens(i), '"');
        tk = strtrim(tk);
        if tk == ""
            continue;
        end
        if ~isnan(str2double(tk))
            n = n + 1;
        end
    end
end

function col = pickColumn(T, preferred, candidates)
    names = string(T.Properties.VariableNames);

    if isnumeric(preferred) && isscalar(preferred)
        idx = preferred;
        if idx < 1 || idx > width(T)
            error('列番号 %d が範囲外です。', idx);
        end
        col = forceNumericColumn(T{:, idx});
        return;
    end

    preferred = string(preferred);
    if strlength(preferred) > 0
        idx = find(matchesNormalized(names, preferred), 1, 'first');
        if ~isempty(idx)
            col = forceNumericColumn(T{:, idx});
            return;
        end
    end

    for c = reshape(candidates, 1, [])
        idx = find(matchesNormalized(names, c), 1, 'first');
        if ~isempty(idx)
            col = forceNumericColumn(T{:, idx});
            return;
        end
    end

    error('必要な列が見つかりませんでした。候補: %s', strjoin(candidates, ', '));
end

function tf = matchesNormalized(names, target)
    namesN = normalizeName(names);
    targetN = normalizeName(string(target));
    tf = namesN == targetN;
end

function out = normalizeName(in)
    out = lower(string(in));
    out = replace(out, [" ","_","-",".","(",")","[","]"], "");
end

function x = forceNumericColumn(raw)
    if isnumeric(raw)
        x = double(raw);
        return;
    end

    if iscell(raw)
        try
            x = cellfun(@str2double, raw);
            return;
        catch
            x = nan(size(raw));
            for i = 1:numel(raw)
                x(i) = str2double(string(raw{i}));
            end
            return;
        end
    end

    x = str2double(string(raw));
end

function [time, angVel, vel] = sanitizeVectors(time, angVel, vel)
    time   = time(:);
    angVel = angVel(:);
    vel    = vel(:);

    n = min([numel(time), numel(angVel), numel(vel)]);
    time   = time(1:n);
    angVel = angVel(1:n);
    vel    = vel(1:n);

    valid = isfinite(time) & isfinite(angVel) & isfinite(vel);
    time   = time(valid);
    angVel = angVel(valid);
    vel    = vel(valid);

    if isempty(time)
        error('有効なデータ行がありません。');
    end

    if any(diff(time) < 0)
        [time, idx] = sort(time, 'ascend');
        angVel = angVel(idx);
        vel    = vel(idx);
    end
end
