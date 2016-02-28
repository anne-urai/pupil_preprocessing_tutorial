function [trl, event] = my_trialfun(cfg)
% header and events are already in the asc structures
% see also
% http://www.fieldtriptoolbox.org/example/making_your_own_trialfun_for_conditional_trial_definition 
%
% Anne Urai, 2016

event   = cfg.event;
value   = {event(find(~cellfun(@isempty,strfind({event.value},'MSG')))).value};
sample  = [event(find(~cellfun(@isempty,strfind({event.value},'MSG')))).sample];

% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * cfg.fsample);
posttrig =  round(cfg.trialdef.post * cfg.fsample);

trl = [];
session = cfg.session;
for j = 1:length(value)-3, % loop through the trials and create the trial matrix on each trl
    
    % check that this is really a fixation trigger
    if (~isempty(strfind(value{j}, 'blinkbreak_end')) && ~isempty(strfind(value{j+2}, 'ref'))) || ...
            (~isempty(strfind(value{j+1}, 'fix')) && ~isempty(strfind(value{j+2}, 'ref'))),
        
        trlbegin = sample(j) + pretrig;
        offset   = pretrig;
        fixoffset = sample(j);
        
        % then find the trigger after that, corresponding to the reference
        if ~isempty(strfind(value{j+2}, 'ref')),
            refoffset = sample(j+2);
        else
            error('no refoffset sample found');
        end
        
        % find the trial nr and block nr, scan message
        scandat =  sscanf(value{j+2}, 'MSG %*f block%d_trial%d_ref_*');
        blockcnt = scandat(1); trlcnt = scandat(2);
        
        % stimulus start
        if ~isempty(strfind(value{j+4}, 'stim')),
            stimoffset = sample(j+4);
        else
            error('no stimoffset sample found');
        end
        % decode stimulus type
        stimtype =  sscanf(value{j+4}, 'MSG %*f block%*d_trial%*d_stim_inc%d');

        % response
        if ~isempty(strfind(value{j+5}, 'resp')),
            respoffset = sample(j+5);
        else
            error('no respoffset sample found');
        end
        
        % response identity and accuracy
        resp = sscanf(value{j+5}, 'MSG %*f block%*d_trial%*d_resp_key%d_correct%d');
            resptype = resp(1); respcorrect = resp(2);
        
        % feedback
        feedbackoffset = sample(j+6);
        
        % check feedback type
        if ~isempty(strfind(value{j+6}, 'feedback_correct1')), % correct
            feedbacktype = 1;
        elseif ~isempty(strfind(value{j+6}, 'feedback_correct0')), % error
            feedbacktype = 0;
        elseif ~isempty(strfind(value{j+6}, 'feedback_correctNaN')), % no response given
            warning('no response trial removed');
            continue; % skip this trial
        end
        assert(isequaln(respcorrect,feedbacktype), 'respcorrect and feedbacktype do not match');
        
        % fieldtrip allows variable trial length
        trlend = feedbackoffset + posttrig;
        
        % append all to mimic the MEG's trialinfo
        newtrl   = [trlbegin trlend offset ...
            fixoffset refoffset stimtype ...
            stimoffset resptype respcorrect respoffset feedbacktype feedbackoffset trlcnt blockcnt session];
        trl      = [trl; newtrl];
    end
    
end

end



