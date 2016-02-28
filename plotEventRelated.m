function [] = plotEventRelated(allcfg, data)
% in case of timelocked data:
% channel: which channels, these will be averaged over
% trials: structure with the name and the idx of trials that will be
% separately plotted
%
% in case of frequency data:
% channel: which channels, these will be averaged over
% trials: structure with the name and the idx of trials, difference

% select the channels we need
cfg             = [];
cfg.channel     = allcfg.channel;
data            = ft_selectdata(cfg, data);

% make 4 lockings: ref, stim, resp, fb
locking(1).offset       = data.trialinfo(:, 2) - data.trialinfo(:, 1);
locking(1).prestim      = 0.1;
locking(1).poststim     = 0.8;
locking(1).name         = 'ref';

locking(2).offset       = data.trialinfo(:, 4) - data.trialinfo(:, 1);
locking(2).prestim      = 0.2;
locking(2).poststim     = 0.8;
locking(2).name         = 'stim';

locking(3).offset       = data.trialinfo(:, 7) - data.trialinfo(:, 1);
locking(3).prestim      = 0.1;
locking(3).poststim     = 1.5;
locking(3).name         = 'resp';

locking(4).offset       = data.trialinfo(:, 9) - data.trialinfo(:, 1);
locking(4).prestim      = 0.5;
locking(4).poststim     = 1.9;
locking(4).name         = 'feedback';

warning off;
for l = 1:length(locking),
    % redefine trials
    cfg                 = [];
    cfg.begsample       = round(locking(l).offset - locking(l).prestim * data.fsample); % take offset into account
    cfg.endsample       = round(locking(l).offset + locking(l).poststim * data.fsample);
    cfg.offset          = -locking(l).offset;
    ldata               = redefinetrial(cfg, data);
    
    cfg                 = [];
    cfg.keeptrials      = 'yes';
    lockdata{l}         = ft_timelockanalysis(cfg, ldata);
end

% append all into one timecourse
newlockdata = cat(2, squeeze(lockdata{1}.trial), squeeze(lockdata{2}.trial), ...
    squeeze(lockdata{3}.trial), squeeze(lockdata{4}.trial));

% make means and std per subset of trials
newtime = 1:size(newlockdata, 2);
newmean = []; newsem = []; newlegend = {};
for t = 1:length(allcfg.trials),
    newmean = [newmean ; mean(newlockdata(allcfg.trials(t).idx, :))];
    newsem = [newsem ; std(newlockdata(allcfg.trials(t).idx, :)) ...
        ./ sqrt(length(allcfg.trials(t).idx))];
    newlegend = [newlegend allcfg.trials(t).name];
end

% plot with shaded errorbars
boundedline(newtime, newmean, permute(newsem, [2 1 3]));
axis tight;
legend(newlegend, 'Location', 'SouthOutside'); legend boxoff;

% layout
tp = 0;
xticks = []; xlabels = {};
cumultime = 0; hold on;
ylims = get(gca, 'ylim');
for l = 1:length(locking),
    xticks = [xticks dsearchn(lockdata{l}.time', tp)+cumultime];
    plot([xticks(end) xticks(end)], ylims, 'k');
    cumultime = cumultime + length(lockdata{l}.time);
    plot([cumultime cumultime], ylims, 'w', 'linewidth', 3);
    xlabels = [xlabels locking(l).name];
end
set(gca, 'XTick', xticks, 'XTickLabel', xlabels, 'tickdir', 'out');

end

function data = redefinetrial(cfg, data)
disp('redefining trial');

Ntrial = length(data.trial);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select a latency window from each trial based on begin and/or end sample
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
begsample = cfg.begsample(:);
endsample = cfg.endsample(:);
if length(begsample)==1
    begsample = repmat(begsample, Ntrial, 1);
end
if length(endsample)==1
    endsample = repmat(endsample, Ntrial, 1);
end
for i=1:Ntrial
    data.trial{i} = data.trial{i}(:, begsample(i):endsample(i));
    data.time{i}  = data.time{i} (   begsample(i):endsample(i));
end

% also correct the sampleinfo
if isfield(data, 'sampleinfo')
    data.sampleinfo(:, 1) = data.sampleinfo(:, 1) + begsample - 1;
    data.sampleinfo(:, 2) = data.sampleinfo(:, 1) + endsample - begsample;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% shift the time axis from each trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
offset = cfg.offset(:);
if length(cfg.offset)==1
    offset = repmat(offset, Ntrial, 1);
end
for i=1:Ntrial
    data.time{i} = data.time{i} + offset(i)/data.fsample;
end

end