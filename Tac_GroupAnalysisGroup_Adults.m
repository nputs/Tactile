
%==============================================
%===============PART I========================
%==============================================

close all
clear

cd C:\Users\Nick\Documents\MATLAB\CM4\Data\HealthyAdults\
%cd C:\Users\Nick\Documents\MATLAB\ASD_Study\

%list participant "names" and "Dates on which tested" in this format. This
%may be tedious, but for the rest it should be fairly automatic
1: 2205RE2?*
2: 30052NP*
3: 14061406ME*
4: 15061506GC*
5: 20062006 RB*
6: 2904JY*
7: 30053 MB*
8: 2604 9/8/1990 TK*
9: TEST-2708 9/27/1979 AH*
10: test1234 - 11/15/1991 CN*


11: 2505 (EW) DP
12: 3004 BD (RE2)


%healthies
Participants = {'2604-0001','2904-0001', '3004-0002','2205-0001', '2505-0001', '3005-0002', '3005-0003', 'TEST-1234', '1406-1406', '1506-1506', 'TEST-2708',...
    '7133-0001', '7133-0002', '7133-0003'};%, '3005-0003'};
Dates = {'4-27-2012','4-30-2012', '4-30-2012', '5-22-2012', '5-25-2012', '5-30-2012', '5-30-2012', '6-8-2012', '6-14-2012','6-15-2012', '8-27-2012',...
    '10-9-2012', '10-9-2012', '10-18-2012'};
Grouped = '_GR1';


%Should be the same for all participants
FileList = {'801', '800', '100', '713', '100', '103', '109', '220', '200', '301', '300'};
%Should make this automatic at some point, but this can wait. For now we're
%using the same battery for all subjects

%801 = Simple reaction time
%800 = Choice reaction time
%100 = Static Detection threshold (same folder as amplitude discrimination
%713 = Dynamic Detection threshold
%100 = Amplitude discrimination (no adaptation)
%103 = Amplitude discrimination with dual site adaptation
%109 = Amplitude discrimination with single site adaptation
%220 = Sequential frequency discrimination
%200 = Simultaneous frequency discrimination
%300 = Temporal Order judgement - simple
%301 = Temporal Order judgement - carrier


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% %-------------------select subsection of kids based on study------------
% %
% %CTRL_WDK
% l = 1;
% for k = 1:length(Participants)
%    if sum(Study{k} == 'CTRL-WDK') == 8
%        ParticipantSelect{l} = Participants{k};
%        DatesSelect{l} = Dates{k};
%        l = l + 1;
%        Grouped = '_ctrlWDK';
%        TOJ = 1; %also do TOJ measurements
%    end
%
% end
%
% Participants = ParticipantSelect;
% Dates=DatesSelect;
%
% %ASD WDK
% l = 1;
% for k = 1:length(Participants)
%    if sum(Study{k} == 'HFA-WDK') == 7
%        ParticipantSelect{l} = Participants{k};
%        DatesSelect{l} = Dates{k};
%        l = l + 1;
%        Grouped = '_HFAWDK';
%        TOJ = 1; %also do TOJ measurements
%    end
%
% end
%
% Participants = ParticipantSelect;
% Dates=DatesSelect;



%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%-------------------------START PROGRAM; DO NOT CHANGE---------------------
NParticipants = length(Participants);
NFileList = length(FileList);

for i = 1 : length(Participants)

    %cd into each participants folder
    Participant = Participants{i};
    Date = Dates{i};

    eval(['cd ' Participant]);
    eval(['cd ' Date]);

    %Now iterate through all the different tasks the
    %subjects are performing
    for j = 1:length(FileList)
        File = FileList{j};


        %to be able to cd into the right directory, the filename has to be present... if not
        %present, what to do? We make sure we create it. Probably not the
        %tidiest solution,but it works.
        if(exist(File,'dir') ~= 7)
            eval(['mkdir ' File]);
        end

        eval(['cd ' File]);



        if strcmp(File, '801') == 1 %First in filelist; see above for 
            %descriptions of the tasks.
            %Simple reaction time task

            %First analyse raw data and come up with some measures
            A = dir('2*_1.txt');
            if isempty(A) == 1
                %if non-existent
                RTS = NaN;
                RTS_values = NaN;
                eval(['RTSGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['RTSGroup' Grouped '.meanTag(i) = NaN;']);
                eval(['RTSGroup' Grouped '.Var(i) = NaN;']);

            else

                %if this datafile is present
                filename = A.name;
                RTS = TacAnalysis(filename);
                RTS.name = 'RTS';

                %plot(RTS.data(:,1), '-ro')
                %we need to get rid of two fastest and lowest values, then mean
                %five
                MaxDat = max(RTS.data(:,4)); FiltData = RTS.data(RTS.data(:,4)~=MaxDat);
                MaxDat = max(FiltData); FiltData = FiltData(FiltData~=MaxDat);
                MinDat = min(FiltData); FiltData = FiltData(FiltData~=MinDat);
                MinDat = min(FiltData); FiltData = FiltData(FiltData~=MinDat);
                FiltData = sort(FiltData); %sort data first
                FiltData = FiltData((((length(FiltData))/2)-3):(((length(FiltData))/2)+3));%middle six trials
                %For now, just averaging the remainder of the trials, but perhaps in
                %future we should do sorting on this data and taking the average of
                %the middle five (As Jameson suggests). We do six now

                RTS.MeanRT = mean(FiltData);
                %RTS.VarRT = std(RTS.data(:,4)); %this would be variability across all trials (not middle 5)
                RTS.VarRT = std(FiltData); %this would be variability across middle 5

                %Get values from tag-file
                B = dir('1*_1.txt');
                filename = B.name;
                RTS_values = TacAnalysisText(filename);

                %Now for this data there much more to analyse, but start creating a
                %group-structure
                eval(['RTSGroup' Grouped '.meanCalc(i) = RTS.MeanRT;']);
                eval(['RTSGroup' Grouped '.meanTag(i) = RTS_values.Threshold;']);
                eval(['RTSGroup' Grouped '.Var(i) = RTS.VarRT;']);

                %assuming all participants do this task, get this information from
                %this file. 
                eval(['BirthdayList' Grouped '{i} = RTS_values.Birthdate;']);
                eval(['GenderList' Grouped '{i} = RTS_values.Gender;']);
                eval(['Handedness' Grouped '{i} = RTS_values.Handedness;']);
                
                cd ..

            end
        elseif strcmp(File, '800') == 1 %Second in filelist;
            %description of the task
            %RT choice
            %
            %
            A = dir('2*_1.txt');

            if isempty(A) == 1
                %if non-existent
                eval(['RTCGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['RTCGroup' Grouped '.meanTag(i) = NaN;']);
                eval(['RTCGroup' Grouped '.Var(i) = NaN;']);
                eval(['RTCGroup' Grouped '.DP_1(i) = NaN;']);
                RTC = NaN;
                RTC_values = NaN;
            else
                filename = A.name;
                RTC = TacAnalysis(filename);
                RTC.name = 'RTC';

                %NP 4-6-2012. Forgot to get rid of incorrect trials
                RTC_sorted = RTC.data(:,4);
                RTC_sorted = RTC_sorted(RTC.data(:,2) == 1); %only take trials that were correct

                %plot(RTS.data(:,1), '-ro')
                %we need to get rid of two fastest and lowest values
                MaxDat = max(RTC_sorted); FiltData = RTC_sorted(RTC_sorted~=MaxDat);
                MaxDat = max(FiltData); FiltData = FiltData(FiltData~=MaxDat);
                MinDat = min(FiltData); FiltData = FiltData(FiltData~=MinDat);
                MinDat = min(FiltData); FiltData = FiltData(FiltData~=MinDat);
                FiltData = sort(FiltData); %sort data first
                FiltData = FiltData((((length(FiltData))/2)-3):(((length(FiltData))/2)+3));%middle six trials
                %For now, just averaging the remainder of the trials, but perhaps in
                %future we should do sorting on this data and taking the average of
                %the middle five (As Jameson suggests).
                RTC.MeanRT = mean(FiltData);
                RTC.VarRT = std(FiltData);

                %---------------------------------------------
                %Start separating the answer-interval info into separate vectors
                Answer  = RTC.data(:,2); %correct
                Response = RTC.data(:,3); %response
                %from this data we can easily determine whether target was in
                %first or second interval
                Interval = [];
                for u = 1:length(Answer)
                    if (Answer(u) == 1) & (Response(u) == 1)
                        Interval(u) = 1;
                    elseif (Answer(u) == 1) & (Response(u) == 2)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 1)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 2)
                        Interval(u) = 1;
                    end
                end

                %interval 1 d'
                %going to calculate TP/FP/TN & FN for interval 1
                %TP = trials in which target is interval 1; choice is interval 1
                %FP = trials in which target is interval 2; choice is interval 1
                %TN = trials in which target is interval 2; choice is interval 2
                %FN = trials in which target is interval 1; choice is interval 2
                TP_1 = (sum(Answer == 1 & Interval' == 1));
                FP_1 = (sum(Answer == 0 & Interval' == 2));
                TN_1 = (sum(Answer == 1 & Interval' == 2));
                FN_1 = (sum(Answer == 0 & Interval' == 1));

                %TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                %FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                pHit_1 = TP_1/(TP_1+FN_1);
                if pHit_1 == 1
                    pHit_1 = 0.99;
                end
                pFalse_1 = FP_1/(FP_1+TN_1);
                if pFalse_1 == 0
                    pFalse_1 = 0.01;
                end
                zHit_1 = norminv(pHit_1) ;
                zFA_1 = norminv(pFalse_1) ;
                %d' = Z(hit rate) - Z(false alarm rate),
                RTC.dPrime_1 = zHit_1 - zFA_1 ;

                %-------------------------------------------------------------

                %Get values from tag-file
                B = dir('1*_1.txt');
                filename = B.name;
                RTC_values = TacAnalysisText(filename);

                %Now for this data there much more to analyse, but start creating a
                %group-structure
                eval(['RTCGroup' Grouped '.meanCalc(i) = RTC.MeanRT;']);
                eval(['RTCGroup' Grouped '.meanTag(i) = RTC_values.Threshold;']);
                eval(['RTCGroup' Grouped '.Var(i) = RTC.VarRT;']);
                eval(['RTCGroup' Grouped '.DP_1(i) = RTC.dPrime_1;']);
                
                cd ..

            end
        elseif strcmp(File, '100') == 1 %Second in filelist;
            %description of the task
            %Static detection threshold task
            %
            %
            A = dir('2*_1.txt');

            if isempty(A) == 1 %if not presnt
                eval(['SDTGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['SDTGroup' Grouped '.meanTag(i) = NaN;']);
                eval(['SDTGroup' Grouped '.DP_1(i) = NaN;']);
                SDT = NaN;
                SDT_values = NaN;
            
            else
                filename = A.name;

                SDT = TacAnalysis(filename);
                SDT.name = 'SDT';

                %plot(RTS.data(:,1), '-ro')
                %take the average of the final 5 values in this task
                SDTL = length(SDT.data(:,1));
                SDT.MeanDT = mean((SDT.data(SDTL-4:SDTL,1)));

                h = figure(1);
                set(h, 'Position', [200 30 500 1100]);
                subplot(6,1,1)
                plot(SDT.data(:,1), 'ro-')
                xlabel('Number of trials')
                ylabel('DL (mn)')
                %                title('Detection Threshold - Static');
                minlimit = ylim; minlimit = minlimit(1); %find minimum on graph
                text(0.5,2, 'DT-Static');

                %Percentage correct here is important, because 100% means
                %ceiling. We "want" about 75% correct I guess. So we can get
                %this from getting d'
                %Start separating the answer-interval info into separate vectors

                %Issue here with NaN
                Answer  = SDT.data((1:(SDTL-1)),4); %correct
                Response = SDT.data((1:(SDTL-1)),2); %response
                %from this data we can easily determine whether target was in
                %first or second interval
                Interval = [];
                for u = 1:length(Answer)
                    if (Answer(u) == 1) & (Response(u) == 1)
                        Interval(u) = 1;
                    elseif (Answer(u) == 1) & (Response(u) == 2)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 1)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 2)
                        Interval(u) = 1;
                    end
                end

                %interval 1 d'
                %going to calculate TP/FP/TN & FN for interval 1
                %TP = trials in which target is interval 1; choice is interval 1
                %FP = trials in which target is interval 2; choice is interval 1
                %TN = trials in which target is interval 2; choice is interval 2
                %FN = trials in which target is interval 1; choice is interval 2
                TP_1 = (sum(Answer == 1 & Interval' == 1));
                FP_1 = (sum(Answer == 0 & Interval' == 2));
                TN_1 = (sum(Answer == 1 & Interval' == 2));
                FN_1 = (sum(Answer == 0 & Interval' == 1));

                %TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                %FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                pHit_1 = TP_1/(TP_1+FN_1);
                if pHit_1 == 1
                    pHit_1 = 0.99;
                end
                pFalse_1 = FP_1/(FP_1+TN_1);
                if pFalse_1 == 0
                    pFalse_1 = 0.01;
                end

                zHit_1 = norminv(pHit_1) ;
                zFA_1 = norminv(pFalse_1) ;
                %d' = Z(hit rate) - Z(false alarm rate),
                SDT.dPrime_1 = zHit_1 - zFA_1 ;

                %-------------------------------------------------------------

                %Get values from tag-file
                B = dir('1*_1.txt');
                filename = B.name;
                SDT_values = TacAnalysisText(filename);

                %Now for this data there much more to analyse, but start creating a
                %group-structure
                eval(['SDTGroup' Grouped '.meanCalc(i) = SDT.MeanDT;']);
                eval(['SDTGroup' Grouped '.meanTag(i) = SDT_values.Threshold;']);
                eval(['SDTGroup' Grouped '.DP_1(i) = SDT.dPrime_1;']);


            end
            %description of the task
            %Amplitude discrimination task (no adaptation) (same folder =
            %100)           

            A = dir('2*_2.txt');

            if isempty(A) == 1

                eval(['AD_NAGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['AD_NAGroup' Grouped '.meanTag(i) = NaN;']);
                eval(['AD_NAGroup' Grouped '.DP_1(i) = NaN;']);
                AD_NA = NaN;
                AD_NA_values = NaN;

            else
                filename = A.name;
                AD_NA = TacAnalysis(filename);
                AD_NA.name = 'AD_NA';

                %plot(RTS.data(:,1), '-ro')
                %take the average of the final 5 values in this task
                AD_NAL = length(AD_NA.data(:,1));
                AD_NA.MeanDT = mean((AD_NA.data(AD_NAL-4:AD_NAL,1)));
                
                %check standard
                B = dir('1*_2.txt');
                filename = B.name;
                standard_amp = CheckStandardAmp(filename);
                %---------------
                
                AD_NA.MeanDT = AD_NA.MeanDT-standard_amp; %THIS 100 IS CHANGEABLE, MAKE SURE STANDARD IS 100
                
                subplot(6,1,2)
                plot(AD_NA.data(:,1), 'bo-')
                xlabel('Number of trials')
                ylabel('DL (mn)')
                %title('Amplitude Discrimination - No adaptation');
                minlimit = ylim; minlimit = minlimit(1); %find minimum on graph
                text(0.5,minlimit+(minlimit/7), 'AD-no adaptation');

                %Percentage correct here is important, because 100% means
                %ceiling. We "want" about 75% correct I guess. So we can get
                %this from getting d'
                %Start separating the answer-interval info into separate vectors

                %Issue here with NaN
                Answer  = AD_NA.data((1:(AD_NAL-1)),4); %correct
                Response = AD_NA.data((1:(AD_NAL-1)),2); %response
                %from this data we can easily determine whether target was in
                %first or second interval
                Interval = [];
                for u = 1:length(Answer)
                    if (Answer(u) == 1) & (Response(u) == 1)
                        Interval(u) = 1;
                    elseif (Answer(u) == 1) & (Response(u) == 2)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 1)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 2)
                        Interval(u) = 1;
                    end
                end



                %interval 1 d'
                %going to calculate TP/FP/TN & FN for interval 1
                %TP = trials in which target is interval 1; choice is interval 1
                %FP = trials in which target is interval 2; choice is interval 1
                %TN = trials in which target is interval 2; choice is interval 2
                %FN = trials in which target is interval 1; choice is interval 2
                TP_1 = (sum(Answer == 1 & Interval' == 1));
                FP_1 = (sum(Answer == 0 & Interval' == 2));
                TN_1 = (sum(Answer == 1 & Interval' == 2));
                FN_1 = (sum(Answer == 0 & Interval' == 1));

                %TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                %FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                pHit_1 = TP_1/(TP_1+FN_1);
                if pHit_1 == 1
                    pHit_1 = 0.99;
                end
                pFalse_1 = FP_1/(FP_1+TN_1);
                if pFalse_1 == 0
                    pFalse_1 = 0.01;
                end
                zHit_1 = norminv(pHit_1) ;
                zFA_1 = norminv(pFalse_1) ;
                %d' = Z(hit rate) - Z(false alarm rate),
                AD_NA.dPrime_1 = zHit_1 - zFA_1 ;

                
                %-------------------------------------------------------------

                %Get values from tag-file
                B = dir('1*_2.txt');
                filename = B.name;
                AD_NA_values = TacAnalysisText(filename);

                %Now for this data there much more to analyse, but start creating a
                %group-structure

                eval(['AD_NAGroup' Grouped '.meanCalc(i) = AD_NA.MeanDT;']);
                eval(['AD_NAGroup' Grouped '.meanTag(i) = AD_NA_values.Threshold;']);
                eval(['AD_NAGroup' Grouped '.DP_1(i) = AD_NA.dPrime_1;']);

            end

            cd ..

        elseif strcmp(File, '713') == 1
            %description of the task
            %Dynamic detection threshold task
            %
            %
            A = dir('2*_1.txt');
            if isempty(A) == 1
                eval(['DDTGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['DDTGroup' Grouped '.meanTag(i) = NaN;']);
                DDT = NaN;
                DDT_values = NaN;
            else

                filename = A.name;
                DDT = TacAnalysis(filename);
                DDT.name = 'DDT';

                %take the average of all correct trials
                %get rid of incorrect trials
                DDT_mean = DDT.data(:,1);
                DDT_mean = DDT_mean(DDT.data(:,4) ==1);
                DDT_RT_corr = DDT.data(:,3) - DDT.data(:,6);
                DDT_RT_corrected = DDT_RT_corr(DDT.data(:,4) ==1);

                DDT.MeanDT = mean(DDT_mean);
                DDT.MeanRT = mean(DDT_RT_corrected);
                
                %also do some sort of bias-tracking? right-left perhaps? Only
                %7 trials though. Perhaps more interesting whether response
                %time differs for left-right
                DDT.resp_right = (DDT.data(:,3));
                DDT.resp_left = (DDT.data(:,3));
                DDT.resp_right = mean(DDT.resp_right(DDT.data(:,7) == 1));
                DDT.resp_left = mean(DDT.resp_left(DDT.data(:,7) == 0));

                %Get values from tag-file
                B = dir('1*_1.txt');
                filename = B.name;
                DDT_values = TacAnalysisText(filename);

                %Now for this data there much more to analyse, but start creating a
                %group-structure
                eval(['DDTGroup' Grouped '.meanCalc(i) = DDT.MeanDT;']);
                eval(['DDTGroup' Grouped '.meanTag(i) = DDT_values.Threshold;']);
                eval(['DDTGroup' Grouped '.meanRT(i) = DDT.MeanRT;']);

                cd ..
            end

        elseif strcmp(File, '103') == 1
            %description of the task
            %Amplitude discrimination task (dual site adaptation)
            %
            %
            A = dir('2*_1.txt');
            if isempty(A) == 1
                eval(['AD_DSAGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['AD_DSAGroup' Grouped '.meanTag(i) = NaN;']);
                eval(['AD_DSAGroup' Grouped '.DP_1(i) = NaN;']);
                AD_DSA = NaN;
                AD_DSA_values = NaN;
            else

                filename = A.name;
                AD_DSA = TacAnalysis(filename);
                AD_DSA.name = 'AD_DSA';

                %plot(RTS.data(:,1), '-ro')
                %take the average of the final 5 values in this task
                AD_DSAL = length(AD_DSA.data(:,1));
                AD_DSA.MeanDT = mean((AD_DSA.data(AD_DSAL-4:AD_DSAL,1)));
                
                %check standard
                B = dir('1*_1.txt');
                filename = B.name;
                standard_amp = CheckStandardAmp(filename);
                %-------
                
                AD_DSA.MeanDT = AD_DSA.MeanDT-standard_amp; %= threshold
                
                subplot(6,1,3)
                plot(AD_DSA.data(:,1), 'bo-')
                xlabel('Number of trials')
                ylabel('DL (mn)')
                %title('Amplitude Discrimination - DS adaptation');
                minlimit = ylim; minlimit = minlimit(1); %find minimum on graph
                text(0.5,minlimit+(minlimit/7), 'AD-DS adaptation');

                %Percentage correct here is important, because 100% means
                %ceiling. We "want" about 75% correct I guess. So we can get
                %this from getting d'
                %Start separating the answer-interval info into separate vectors

                %Issue here with NaN
                Answer  = AD_DSA.data((1:(AD_DSAL-1)),4); %correct
                Response = AD_DSA.data((1:(AD_DSAL-1)),2); %response
                %from this data we can easily determine whether target was in
                %first or second interval
                Interval = [];
                for u = 1:length(Answer)
                    if (Answer(u) == 1) & (Response(u) == 1)
                        Interval(u) = 1;
                    elseif (Answer(u) == 1) & (Response(u) == 2)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 1)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 2)
                        Interval(u) = 1;
                    end
                end

                %interval 1 d'
                %going to calculate TP/FP/TN & FN for interval 1
                %TP = trials in which target is interval 1; choice is interval 1
                %FP = trials in which target is interval 2; choice is interval 1
                %TN = trials in which target is interval 2; choice is interval 2
                %FN = trials in which target is interval 1; choice is interval 2
                TP_1 = (sum(Answer == 1 & Interval' == 1));
                FP_1 = (sum(Answer == 0 & Interval' == 2));
                TN_1 = (sum(Answer == 1 & Interval' == 2));
                FN_1 = (sum(Answer == 0 & Interval' == 1));

                %TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                %FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                pHit_1 = TP_1/(TP_1+FN_1);
                if pHit_1 == 1
                    pHit_1 = 0.99;
                end
                pFalse_1 = FP_1/(FP_1+TN_1);
                if pFalse_1 == 0
                    pFalse_1 = 0.01;
                end
                zHit_1 = norminv(pHit_1) ;
                zFA_1 = norminv(pFalse_1) ;
                %d' = Z(hit rate) - Z(false alarm rate),
                AD_DSA.dPrime_1 = zHit_1 - zFA_1 ;

                
                %-------------------------------------------------------------

                %Get values from tag-file
                B = dir('1*_1.txt');
                filename = B.name;
                AD_DSA_values = TacAnalysisText(filename);

                %Now for this data there much more to analyse, but start creating a
                %group-structure
                eval(['AD_DSAGroup' Grouped '.meanCalc(i) = AD_DSA.MeanDT;']);
                eval(['AD_DSAGroup' Grouped '.meanTag(i) = AD_DSA_values.Threshold;']);
                eval(['AD_DSAGroup' Grouped '.DP_1(i) = AD_DSA.dPrime_1;']);


                cd ..
            end

        elseif strcmp(File, '109') == 1
            %description of the task
            %Amplitude discrimination task (single site adaptation)
            %
            %
            A = dir('2*_1.txt');

            if isempty(A) == 1
                eval(['AD_SSAGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['AD_SSAGroup' Grouped '.meanTag(i) = NaN;']);
                eval(['AD_SSAGroup' Grouped '.DP_1(i) = NaN;']);
                AD_SSA = NaN;
                AD_SSA_values = NaN;

            else
                filename = A.name;
                AD_SSA = TacAnalysis(filename);
                AD_SSA.name = 'AD_SSA';

                %plot(RTS.data(:,1), '-ro')
                %take the average of the final 5 values in this task
                AD_SSAL = length(AD_SSA.data(:,1));
                AD_SSA.MeanDT = mean((AD_SSA.data(AD_SSAL-4:AD_SSAL,1)));

                %check standard
                B = dir('1*_1.txt');
                filename = B.name;
                standard_amp = CheckStandardAmp(filename);
                %-------
                
                AD_SSA.MeanDT = AD_SSA.MeanDT-standard_amp;
                
                subplot(6,1,4)
                plot(AD_SSA.data(:,1), 'bo-')
                xlabel('Number of trials')
                ylabel('DL (mn)')
                %title('Amplitude Discrimination - SS adaptation');
                minlimit = ylim; minlimit = minlimit(1); %find minimum on graph
                text(0.5,minlimit+(minlimit/7), 'AD-SS adaptation');
                %Percentage correct here is important, because 100% means
                %ceiling. We "want" about 75% correct I guess. So we can get
                %this from getting d'
                %Start separating the answer-interval info into separate vectors

                %Issue here with NaN
                Answer  = AD_SSA.data((1:(AD_SSAL-1)),4); %correct
                Response = AD_SSA.data((1:(AD_SSAL-1)),2); %response
                %from this data we can easily determine whether target was in
                %first or second interval
                Interval = [];
                for u = 1:length(Answer)
                    if (Answer(u) == 1) & (Response(u) == 1)
                        Interval(u) = 1;
                    elseif (Answer(u) == 1) & (Response(u) == 2)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 1)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 2)
                        Interval(u) = 1;
                    end
                end

                %interval 1 d'
                %going to calculate TP/FP/TN & FN for interval 1
                %TP = trials in which target is interval 1; choice is interval 1
                %FP = trials in which target is interval 2; choice is interval 1
                %TN = trials in which target is interval 2; choice is interval 2
                %FN = trials in which target is interval 1; choice is interval 2
                TP_1 = (sum(Answer == 1 & Interval' == 1));
                FP_1 = (sum(Answer == 0 & Interval' == 2));
                TN_1 = (sum(Answer == 1 & Interval' == 2));
                FN_1 = (sum(Answer == 0 & Interval' == 1));

                %TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                %FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                pHit_1 = TP_1/(TP_1+FN_1);
                if pHit_1 == 1
                    pHit_1 = 0.99;
                end
                pFalse_1 = FP_1/(FP_1+TN_1);
                if pFalse_1 == 0
                    pFalse_1 = 0.01;
                end
                zHit_1 = norminv(pHit_1) ;
                zFA_1 = norminv(pFalse_1) ;
                %d' = Z(hit rate) - Z(false alarm rate),
                AD_SSA.dPrime_1 = zHit_1 - zFA_1 ;

                
                %-------------------------------------------------------------

                %Get values from tag-file
                B = dir('1*_1.txt');
                filename = B.name;
                AD_SSA_values = TacAnalysisText(filename);

                %Now for this data there much more to analyse, but start creating a
                %group-structure
                eval(['AD_SSAGroup' Grouped '.meanCalc(i) = AD_SSA.MeanDT;']);
                eval(['AD_SSAGroup' Grouped '.meanTag(i) = AD_SSA_values.Threshold;']);
                eval(['AD_SSAGroup' Grouped '.DP_1(i) = AD_SSA.dPrime_1;']);

                cd ..
            end

        elseif strcmp(File, '220') == 1
            %description of the task
            %frequency discrimination task (sequential)


            A = dir('2*_1.txt');
            if isempty(A) == 1
                eval(['FD_SeqGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['FD_SeqGroup' Grouped '.meanTag(i) = NaN;']);
                eval(['FD_SeqGroup' Grouped '.DP_1(i) = NaN;']);
                FD_Seq = NaN;
                FD_Seq_values = NaN;
            else
                filename = A.name;
                FD_Seq = TacAnalysis(filename);
                FD_Seq.name = 'FD_Seq';

                %plot(RTS.data(:,1), '-ro')
                %take the average of the final 5 values in this task
                FD_SeqL = length(FD_Seq.data(:,1));
                FD_Seq.MeanDT = mean((FD_Seq.data(FD_SeqL-4:FD_SeqL,1)));
                
                %check standard
                B = dir('1*_1.txt');
                filename = B.name;
                standard_freq = CheckStandardFreq(filename);
                %-------
                                
                FD_Seq.MeanDT = FD_Seq.MeanDT-standard_freq;
                
                subplot(6,1,5)
                plot(FD_Seq.data(:,1), 'go-')
                xlabel('Number of trials')
                ylabel('DL (Hz)')
                %title('Frequency Discrimination - Sequential');
                minlimit = ylim; minlimit = minlimit(1); %find minimum on graph
                text(0.5,minlimit+(minlimit/14), 'FD-sequential');

                % Percentage correct here is important, because 100% means
                %ceiling. We "want" about 75% correct I guess. So we can get
                %this from getting d'
                %Start separating the answer-interval info into separate vectors

                %Issue here with NaN
                Answer  = FD_Seq.data((1:(FD_SeqL-1)),4); %correct
                Response = FD_Seq.data((1:(FD_SeqL-1)),2); %response
                % from this data we can easily determine whether target was in
                % first or second interval
                Interval = [];
                for u = 1:length(Answer)
                    if (Answer(u) == 1) & (Response(u) == 1)
                        Interval(u) = 1;
                    elseif (Answer(u) == 1) & (Response(u) == 2)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 1)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 2)
                        Interval(u) = 1;
                    end
                end

                %  interval 1 d'
                %  going to calculate TP/FP/TN & FN for interval 1
                %             TP = trials in which target is interval 1; choice is interval 1
                %             FP = trials in which target is interval 2; choice is interval 1
                %             TN = trials in which target is interval 2; choice is interval 2
                %             FN = trials in which target is interval 1; choice is interval 2
                TP_1 = (sum(Answer == 1 & Interval' == 1));
                FP_1 = (sum(Answer == 0 & Interval' == 2));
                TN_1 = (sum(Answer == 1 & Interval' == 2));
                FN_1 = (sum(Answer == 0 & Interval' == 1));

                %   TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                %   FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                pHit_1 = TP_1/(TP_1+FN_1);
                if pHit_1 == 1
                    pHit_1 = 0.99;
                end
                pFalse_1 = FP_1/(FP_1+TN_1);
                if pFalse_1 == 0
                    pFalse_1 = 0.01;
                end
                zHit_1 = norminv(pHit_1) ;
                zFA_1 = norminv(pFalse_1) ;
                %             d' = Z(hit rate) - Z(false alarm rate),
                FD_Seq.dPrime_1 = zHit_1 - zFA_1 ;

                

                %-------------------------------------------------------------

                %             Get values from tag-file
                B = dir('1*_1.txt');
                filename = B.name;
                FD_Seq_values = TacAnalysisText(filename);

                %             Now for this data there much more to analyse, but start creating a
                %             group-structure

                eval(['FD_SeqGroup' Grouped '.meanCalc(i) = FD_Seq.MeanDT;']);
                eval(['FD_SeqGroup' Grouped '.meanTag(i) = FD_Seq_values.Threshold;']);
                eval(['FD_SeqGroup' Grouped '.DP_1(i) = FD_Seq.dPrime_1;']);
                cd ..
            end
        elseif strcmp(File, '200') == 1
            %description of the task
            %frequency discrimination task (sequential)
            %
            %


            A = dir('2*_1.txt');
            if isempty(A) == 1
                eval(['FD_SimGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['FD_SimGroup' Grouped '.meanTag(i) = NaN;']);
                eval(['FD_SimGroup' Grouped '.DP_1(i) = NaN;']);
                FD_Sim = NaN;
                FD_Sim_values = NaN;
            else
                filename = A.name;
                FD_Sim = TacAnalysis(filename);
                FD_Sim.name = 'FD_Sim';

                %plot(RTS.data(:,1), '-ro')
                %take the average of the final 5 values in this task
                FD_SimL = length(FD_Sim.data(:,1));
                FD_Sim.MeanDT = mean((FD_Sim.data(FD_SimL-4:FD_SimL,1)));
                
                %check standard
                B = dir('1*_1.txt');
                filename = B.name;
                standard_freq = CheckStandardFreq(filename);
                %-------
                
                FD_Sim.MeanDT = FD_Sim.MeanDT-standard_freq;
                
                subplot(6,1,6)
                plot(FD_Sim.data(:,1), 'go-')
                xlabel('Number of trials')
                ylabel('DL (Hz)')
                title('Frequency Discrimination - Simultaneous');
                minlimit = ylim; minlimit = minlimit(1); %find minimum on graph
                text(0.5,minlimit+(minlimit/14), 'FD-simultaneous');
                %Percentage correct here is important, because 100% means
                %ceiling. We "want" about 75% correct I guess. So we can get
                %this from getting d'
                %Start separating the answer-interval info into separate vectors

                %Issue here with NaN
                Answer  = FD_Sim.data((1:(FD_SimL-1)),4); %correct
                Response = FD_Sim.data((1:(FD_SimL-1)),2); %response
                %from this data we can easily determine whether target was in
                %first or second interval
                Interval = [];
                for u = 1:length(Answer)
                    if (Answer(u) == 1) & (Response(u) == 1)
                        Interval(u) = 1;
                    elseif (Answer(u) == 1) & (Response(u) == 2)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 1)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 2)
                        Interval(u) = 1;
                    end
                end

                %interval 1 d'
                %going to calculate TP/FP/TN & FN for interval 1
                %TP = trials in which target is interval 1; choice is interval 1
                %FP = trials in which target is interval 2; choice is interval 1
                %TN = trials in which target is interval 2; choice is interval 2
                %FN = trials in which target is interval 1; choice is interval 2
                TP_1 = (sum(Answer == 1 & Interval' == 1));
                FP_1 = (sum(Answer == 0 & Interval' == 2));
                TN_1 = (sum(Answer == 1 & Interval' == 2));
                FN_1 = (sum(Answer == 0 & Interval' == 1));

                %TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                %FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                pHit_1 = TP_1/(TP_1+FN_1);
                if pHit_1 == 1
                    pHit_1 = 0.99;
                end
                pFalse_1 = FP_1/(FP_1+TN_1);
                if pFalse_1 == 0
                    pFalse_1 = 0.01;
                end
                zHit_1 = norminv(pHit_1) ;
                zFA_1 = norminv(pFalse_1) ;
                %d' = Z(hit rate) - Z(false alarm rate),
                FD_Sim.dPrime_1 = zHit_1 - zFA_1 ;

            
                %-------------------------------------------------------------

                %Get values from tag-file
                B = dir('1*_1.txt');
                filename = B.name;
                FD_Sim_values = TacAnalysisText(filename);

                %Now for this data there much more to analyse, but start creating a
                %group-structure
                eval(['FD_SimGroup' Grouped '.meanCalc(i) = FD_Sim.MeanDT;']);
                eval(['FD_SimGroup' Grouped '.meanTag(i) = FD_Sim_values.Threshold;']);
                eval(['FD_SimGroup' Grouped '.DP_1(i) = FD_Sim.dPrime_1;']);
                cd ..
            end
            %save figure, copied from Gannet(MRS software_
            %hax=axes('Position',[0.85, 0.05, 0.15, 0.15]);
            %set(gca,'Units','normalized');set(gca,'Position',[0.05 0.05 1.85 0.15]);
            % fix pdf output, where default is cm

            if(exist('./TacTracking','dir') ~= 7)
                mkdir TacTracking
            end

            set(gcf, 'PaperUnits', 'inches');
            set(gcf,'PaperSize',[7.5 11]);
            set(gcf,'PaperPosition',[.25 .25 6 10]);

            pdfname=[ 'TacTracking/Tracking.pdf' ];
            saveas(h, pdfname);

            pause(4)


            %Reserve for TOJ

        elseif strcmp(File, '301') == 1

            A = dir('2*_1.txt');

            if isempty(A) == 1
                eval(['TOJ_carrierGroup' Grouped '.meanCalc(i) = NaN;']);
                eval(['TOJ_carrierGroup' Grouped '.DP_1(i) = NaN;']);
                TOJ_carrierL = NaN;
                %eval(['save TOJ_Data TOJ_simpleGroup' Grouped ' TOJ_carrierGroup' Grouped]);

            else
                filename = A.name;
                TOJ_carrier = TacAnalysis(filename);
                TOJ_carrier.name = 'TOJ_carrier';

                %plot(RTS.data(:,1), '-ro')
                %take the average of the final 5 values in this task
                TOJ_carrierL = length(TOJ_carrier.data(:,1));
                TOJ_carrier.MeanDT = mean((TOJ_carrier.data(TOJ_carrierL-4:TOJ_carrierL,1)));

                figure(2)
                subplot(2,1,2)
                plot(TOJ_carrier.data(:,1), 'go-')
                xlabel('Number of trials')
                ylabel('DL (ms)')
                title('Temporal Order judgement - carrier');
                minlimit = ylim; minlimit = minlimit(1); %find minimum on graph
                text(0.5,minlimit+(minlimit/14), 'TOJ_carrier');
                %Percentage correct here is important, because 100% means
                %ceiling. We "want" about 75% correct I guess. So we can get
                %this from getting d'
                %Start separating the answer-interval info into separate vectors

                %Issue here with NaN
                Answer  = TOJ_carrier.data((1:(TOJ_carrierL-1)),4); %correct
                Response = TOJ_carrier.data((1:(TOJ_carrierL-1)),2); %response
                %from this data we can easily determine whether target was in
                %first or second interval
                Interval = [];
                for u = 1:length(Answer)
                    if (Answer(u) == 1) & (Response(u) == 1)
                        Interval(u) = 1;
                    elseif (Answer(u) == 1) & (Response(u) == 2)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 1)
                        Interval(u) = 2;
                    elseif (Answer(u) == 0) & (Response(u) == 2)
                        Interval(u) = 1;
                    end
                end

                %interval 1 d'
                %going to calculate TP/FP/TN & FN for interval 1
                %TP = trials in which target is interval 1; choice is interval 1
                %FP = trials in which target is interval 2; choice is interval 1
                %TN = trials in which target is interval 2; choice is interval 2
                %FN = trials in which target is interval 1; choice is interval 2
                TP_1 = (sum(Answer == 1 & Interval' == 1));
                FP_1 = (sum(Answer == 0 & Interval' == 2));
                TN_1 = (sum(Answer == 1 & Interval' == 2));
                FN_1 = (sum(Answer == 0 & Interval' == 1));

                %TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                %FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                pHit_1 = TP_1/(TP_1+FN_1);
                if pHit_1 == 1
                    pHit_1 = 0.99;
                end
                pFalse_1 = FP_1/(FP_1+TN_1);
                if pFalse_1 == 0
                    pFalse_1 = 0.01;
                end
                zHit_1 = norminv(pHit_1) ;
                zFA_1 = norminv(pFalse_1) ;
                %d' = Z(hit rate) - Z(false alarm rate),
                TOJ_carrier.dPrime_1 = zHit_1 - zFA_1 ;

               %-------------------------------------------------------------

                %Get values from tag-file will be NaN

                %Now for this data there much more to analyse, but start creating a
                %group-structure
                eval(['TOJ_carrierGroup' Grouped '.meanCalc(i) = TOJ_carrier.MeanDT;']);
                eval(['TOJ_carrierGroup' Grouped '.DP_1(i) = TOJ_carrier.dPrime_1;']);
                %eval(['save TOJ_Data TOJ_simpleGroup' Grouped ' TOJ_carrierGroup' Grouped]);

                cd ..
            end
            
            elseif strcmp(File, '300') == 1

                A = dir('2*_1.txt');
                if isempty(A) == 1
                    eval(['TOJ_simpleGroup' Grouped '.meanCalc(i) = NaN;']);
                    eval(['TOJ_simpleGroup' Grouped '.DP_1(i) = NaN;']);
                    TOJ_simple = NaN;

                else

                    filename = A.name;
                    TOJ_simple = TacAnalysis(filename);
                    TOJ_simple.name = 'TOJ_simple';

                    %plot(RTS.data(:,1), '-ro')
                    %take the average of the final 5 values in this task
                    TOJ_simpleL = length(TOJ_simple.data(:,1));
                    TOJ_simple.MeanDT = mean((TOJ_simple.data(TOJ_simpleL-4:TOJ_simpleL,1)));
                    figure(2)
                    subplot(2,1,1)
                    plot(TOJ_simple.data(:,1), 'go-')
                    xlabel('Number of trials')
                    ylabel('DL (ms)')
                    title('Temporal Order judgement - simple');
                    minlimit = ylim; minlimit = minlimit(1); %find minimum on graph
                    text(0.5,minlimit+(minlimit/14), 'TOJ_simple');
                    %Percentage correct here is important, because 100% means
                    %ceiling. We "want" about 75% correct I guess. So we can get
                    %this from getting d'
                    %Start separating the answer-interval info into separate vectors

                    %Issue here with NaN
                    Answer  = TOJ_simple.data((1:(TOJ_simpleL-1)),4); %correct
                    Response = TOJ_simple.data((1:(TOJ_simpleL-1)),2); %response
                    %from this data we can easily determine whether target was in
                    %first or second interval
                    Interval = [];
                    for u = 1:length(Answer)
                        if (Answer(u) == 1) & (Response(u) == 1)
                            Interval(u) = 1;
                        elseif (Answer(u) == 1) & (Response(u) == 2)
                            Interval(u) = 2;
                        elseif (Answer(u) == 0) & (Response(u) == 1)
                            Interval(u) = 2;
                        elseif (Answer(u) == 0) & (Response(u) == 2)
                            Interval(u) = 1;
                        end
                    end

                    %interval 1 d'
                    %going to calculate TP/FP/TN & FN for interval 1
                    %TP = trials in which target is interval 1; choice is interval 1
                    %FP = trials in which target is interval 2; choice is interval 1
                    %TN = trials in which target is interval 2; choice is interval 2
                    %FN = trials in which target is interval 1; choice is interval 2
                    TP_1 = (sum(Answer == 1 & Interval' == 1));
                    FP_1 = (sum(Answer == 0 & Interval' == 2));
                    TN_1 = (sum(Answer == 1 & Interval' == 2));
                    FN_1 = (sum(Answer == 0 & Interval' == 1));

                    %TPR (or hit rate;sensitivity) = TP/(TP+FN) --> pHit_1
                    %FPR (or false alarm rate) = FP/(FP + TN) --> pFalse_1

                    pHit_1 = TP_1/(TP_1+FN_1);
                    if pHit_1 == 1
                        pHit_1 = 0.99;
                    end
                    pFalse_1 = FP_1/(FP_1+TN_1);
                    if pFalse_1 == 0
                        pFalse_1 = 0.01;
                    end
                    zHit_1 = norminv(pHit_1) ;
                    zFA_1 = norminv(pFalse_1) ;
                    %d' = Z(hit rate) - Z(false alarm rate),
                    TOJ_simple.dPrime_1 = zHit_1 - zFA_1 ;

                    %-------------------------------------------------------------

                    %Get values from tag-file will be NaN

                    %Now for this data there much more to analyse, but start creating a
                    %group-structure
                    eval(['TOJ_simpleGroup' Grouped '.meanCalc(i) = TOJ_simple.MeanDT;']);
                    eval(['TOJ_simpleGroup' Grouped '.DP_1(i) = TOJ_simple.dPrime_1;']);

                end
            end

        end

    



    %Save a subject specific variable containing the data, useful for further
    %processing which I'll plan to do below this initial data read.
    cd ..
    Subject = regexprep(Participant, '-', '_');
    %Should make this more automatic, but works for now
    eval(['Data_' Subject ' = {RTS RTS_values RTC RTC_values SDT SDT_values AD_NA AD_NA_values DDT DDT_values AD_DSA AD_DSA_values AD_SSA AD_SSA_values FD_Seq FD_Seq_values FD_Sim FD_Sim_values};']);
    eval(['save Data_' Subject ]);
    cd C:\Users\Nick\Documents\MATLAB\CM4\Data\HealthyAdults\

end

%calculate DDT_corrected
%1. we have corrected reaction time in DT task
%2. correct this for mean CHOICE reaction time

eval(['RTCmeanRT = transpose(RTCGroup' Grouped '.meanCalc);']);%transpose both
eval(['DDTmeanRT = transpose(DDTGroup' Grouped '.meanRT);']);%transpose both
NewRT = DDTmeanRT - RTCmeanRT; %is correct up to here
eval(['DDTGroup' Grouped '.corrDT  =  ((0.002*NewRT) + 0.1397);']);
eval(['DDTGroup' Grouped '.corrDT  =  transpose(DDTGroup' Grouped '.corrDT);']);


%save individual participant data in large file
eval(['save All_Data' Grouped])
for jj = 1:length(Participants)
    DataFormName = {'RTS' 'RTSVar' 'RTC' 'SDT' 'DDT' 'DDTRT' 'AD_NA' 'AD_DSA' 'AD_SSA' 'FDSeq' 'FDSim' 'TOJsim' 'TOJcar'};
    ParticipantForm = Participants';
    eval(['ParticipantInfo = [BirthdayList' Grouped '; Handedness' Grouped '; GenderList' Grouped '];']);
    ParticipantInfo = ParticipantInfo';
    eval(['DataForm' Grouped '(jj,:) = [RTSGroup' Grouped '.meanCalc(jj) RTSGroup' Grouped '.Var(jj) RTCGroup' Grouped '.meanCalc(jj) SDTGroup' Grouped '.meanCalc(jj) DDTGroup' Grouped '.meanCalc(jj) DDTGroup' Grouped '.corrDT(jj) AD_NAGroup' Grouped '.meanCalc(jj) AD_DSAGroup' Grouped '.meanCalc(jj) AD_SSAGroup' Grouped '.meanCalc(jj) FD_SeqGroup' Grouped '.meanCalc(jj) FD_SimGroup' Grouped '.meanCalc(jj) TOJ_simpleGroup' Grouped '.meanCalc(jj) TOJ_carrierGroup' Grouped '.meanCalc(jj)];']);
    eval(['save DataForm' Grouped '.txt DataForm' Grouped ' -ASCII']);
    
end

%TacAnalysisPlot


%running and saving bit done. Can import this data into excel
%==============================================
%===============PART II========================
%==============================================

%Getting all averages-----------------------------------------
%Here we can start distinguishing groups for instance
%e.g copy into new file and changing it to ..._gr1
%and then rerunning. This would work for defining groups

%means and stds
%First, transpose all vectors (frustratingly)
eval(['RTSGroup' Grouped '.meanCalc = transpose(RTSGroup' Grouped '.meanCalc);']);
eval(['RTCGroup' Grouped '.meanCalc = transpose(RTCGroup' Grouped '.meanCalc);']);
eval(['RTSGroup' Grouped '.Var = transpose(RTSGroup' Grouped '.Var);']);
eval(['RTCGroup' Grouped '.Var = transpose(RTCGroup' Grouped '.Var);']);
%==
eval(['SDTGroup' Grouped '.meanCalc = transpose(SDTGroup' Grouped '.meanCalc);']);
eval(['DDTGroup' Grouped '.meanCalc = transpose(DDTGroup' Grouped '.meanCalc);']);
%==
eval(['AD_NAGroup' Grouped '.meanCalc = transpose(AD_NAGroup' Grouped '.meanCalc);']);
eval(['AD_DSAGroup' Grouped '.meanCalc = transpose(AD_DSAGroup' Grouped '.meanCalc);']);
eval(['AD_SSAGroup' Grouped '.meanCalc = transpose(AD_SSAGroup' Grouped '.meanCalc);']);
%==
eval(['FD_SeqGroup' Grouped '.meanCalc = transpose(FD_SeqGroup' Grouped '.meanCalc);']);
eval(['FD_SimGroup' Grouped '.meanCalc = transpose(FD_SimGroup' Grouped '.meanCalc);']);
%==
eval(['TOJ_simpleGroup' Grouped '.meanCalc = transpose(TOJ_simpleGroup' Grouped '.meanCalc);']);
eval(['TOJ_carrierGroup' Grouped '.meanCalc = transpose(TOJ_carrierGroup' Grouped '.meanCalc);']);

%D primes too
eval(['RTCGroup' Grouped '.DP_1 = transpose(RTCGroup' Grouped '.DP_1);']);
eval(['SDTGroup' Grouped '.DP_1 = transpose(SDTGroup' Grouped '.DP_1);']);
%==
eval(['AD_NAGroup' Grouped '.DP_1 = transpose(AD_NAGroup' Grouped '.DP_1);']);
eval(['AD_DSAGroup' Grouped '.DP_1 = transpose(AD_DSAGroup' Grouped '.DP_1);']);
eval(['AD_SSAGroup' Grouped '.DP_1 = transpose(AD_SSAGroup' Grouped '.DP_1);']);
%==
eval(['FD_SeqGroup' Grouped '.DP_1 = transpose(FD_SeqGroup' Grouped '.DP_1);']);
eval(['FD_SimGroup' Grouped '.DP_1 = transpose(FD_SimGroup' Grouped '.DP_1);']);

%=====================================================================
%Secondly, we need to remove the NaN's from the files to calculate means
eval(['RTSGroup' Grouped '.meanCalc(any(isnan(RTSGroup' Grouped '.meanCalc),2),:) = [];']); 
eval(['RTCGroup' Grouped '.meanCalc(any(isnan(RTCGroup' Grouped '.meanCalc),2),:) = [];']);
eval(['RTSGroup' Grouped '.Var(any(isnan(RTSGroup' Grouped '.Var),2),:) = [];']); 
eval(['RTCGroup' Grouped '.Var(any(isnan(RTCGroup' Grouped '.Var),2),:) = [];']); 
%==
eval(['SDTGroup' Grouped '.meanCalc(any(isnan(SDTGroup' Grouped '.meanCalc),2),:) = [];']); 
eval(['DDTGroup' Grouped '.meanCalc(any(isnan(DDTGroup' Grouped '.meanCalc),2),:)= [];']); 
%==
eval(['AD_NAGroup' Grouped '.meanCalc(any(isnan(AD_NAGroup' Grouped '.meanCalc),2),:)= [];']); 
eval(['AD_DSAGroup' Grouped '.meanCalc(any(isnan(AD_DSAGroup' Grouped '.meanCalc),2),:)= [];']); 
eval(['AD_SSAGroup' Grouped '.meanCalc(any(isnan(AD_SSAGroup' Grouped '.meanCalc),2),:)= [];']); 
%==
eval(['FD_SeqGroup' Grouped '.meanCalc(any(isnan(FD_SeqGroup' Grouped '.meanCalc),2),:)= [];']); 
eval(['FD_SimGroup' Grouped '.meanCalc(any(isnan(FD_SimGroup' Grouped '.meanCalc),2),:)= [];']);
%==
eval(['TOJ_simpleGroup' Grouped '.meanCalc(any(isnan(TOJ_simpleGroup' Grouped '.meanCalc),2),:)= [];']); 
eval(['TOJ_carrierGroup' Grouped '.meanCalc(any(isnan(TOJ_carrierGroup' Grouped '.meanCalc),2),:)= [];']); 


% d-primes
%First, we need to remove the NaN's from the files to calculate means
eval(['RTCGroup' Grouped '.DP_1(any(isnan(RTCGroup' Grouped '.DP_1),2),:)= [];']); 
%==
eval(['SDTGroup' Grouped '.DP_1(any(isnan(SDTGroup' Grouped '.DP_1),2),:)= [];']); 
%==
eval(['AD_NAGroup' Grouped '.DP_1(any(isnan(AD_NAGroup' Grouped '.DP_1),2),:)= [];']); 
eval(['AD_DSAGroup' Grouped '.DP_1(any(isnan(AD_DSAGroup' Grouped '.DP_1),2),:)= [];']); 
eval(['AD_SSAGroup' Grouped '.DP_1(any(isnan(AD_SSAGroup' Grouped '.DP_1),2),:)= [];']); 
%==
eval(['FD_SeqGroup' Grouped '.DP_1(any(isnan(FD_SeqGroup' Grouped '.DP_1),2),:)= [];']); 
eval(['FD_SimGroup' Grouped '.DP_1(any(isnan(FD_SimGroup' Grouped '.DP_1),2),:)= [];']); 

%===================================


%===Now can calculate means and standard deviations
eval(['RTSmean' Grouped ' = mean(RTSGroup' Grouped '.meanCalc);']);
eval(['RTCmean' Grouped ' = mean(RTCGroup' Grouped '.meanCalc);']);
eval(['RTSVar' Grouped ' = mean(RTSGroup' Grouped '.Var);']);
eval(['RTCVar' Grouped ' = mean(RTSGroup' Grouped '.Var);']);
%================================
eval(['SDTmean' Grouped ' = mean(SDTGroup' Grouped '.meanCalc);']);
eval(['DDTmean' Grouped ' = mean(DDTGroup' Grouped '.meanCalc);']);
%================================
eval(['AD_NAmean' Grouped ' = mean(AD_NAGroup' Grouped '.meanCalc);']);
eval(['AD_DSAmean' Grouped ' = mean(AD_DSAGroup' Grouped '.meanCalc);']);
eval(['AD_SSAmean' Grouped ' = mean(AD_SSAGroup' Grouped '.meanCalc);']);
%================================
eval(['FD_Seqmean' Grouped ' = mean(FD_SeqGroup' Grouped '.meanCalc);']);
eval(['FD_Simmean' Grouped ' = mean(FD_SimGroup' Grouped '.meanCalc);']);
%================================
eval(['TOJ_simplemean' Grouped ' = mean(TOJ_simpleGroup' Grouped '.meanCalc);']);
eval(['TOJ_carriermean' Grouped ' = mean(TOJ_carrierGroup' Grouped '.meanCalc);']);


%================================
eval(['RTSstd' Grouped ' = std(RTSGroup' Grouped '.meanCalc);']);
eval(['RTCstd' Grouped ' = std(RTCGroup' Grouped '.meanCalc);']);
eval(['RTSVar' Grouped ' = std(RTSGroup' Grouped '.Var);']);
eval(['RTCVar' Grouped ' = std(RTSGroup' Grouped '.Var);']);
%================================
eval(['SDTstd' Grouped ' = std(SDTGroup' Grouped '.meanCalc);']);
eval(['DDTstd' Grouped ' = std(DDTGroup' Grouped '.meanCalc);']);
%================================
eval(['AD_NAstd' Grouped ' = std(AD_NAGroup' Grouped '.meanCalc);']);
eval(['AD_DSAstd' Grouped ' = std(AD_DSAGroup' Grouped '.meanCalc);']);
eval(['AD_SSAstd' Grouped ' = std(AD_SSAGroup' Grouped '.meanCalc);']);
%================================
eval(['FD_Seqstd' Grouped ' = std(FD_SeqGroup' Grouped '.meanCalc);']);
eval(['FD_Simstd' Grouped ' = std(FD_SimGroup' Grouped '.meanCalc);']);
%================================
eval(['TOJ_simplestd' Grouped ' = std(TOJ_simpleGroup' Grouped '.meanCalc);']);
eval(['TOJ_carrierstd' Grouped ' = std(TOJ_carrierGroup' Grouped '.meanCalc);']);

%For looking at differences in D'
eval(['RTC_DP1' Grouped ' = mean(RTCGroup' Grouped '.DP_1);']);
eval(['SDT_DP1' Grouped ' = mean(SDTGroup' Grouped '.DP_1);']);
eval(['AD_NA_DP1' Grouped ' = mean(AD_NAGroup' Grouped '.DP_1);']);
eval(['AD_DSA_DP1' Grouped ' = mean(AD_DSAGroup' Grouped '.DP_1);']);
eval(['AD_SSA_DP1' Grouped ' = mean(AD_SSAGroup' Grouped '.DP_1);']);
eval(['FD_Seq_DP1' Grouped ' = mean(FD_SeqGroup' Grouped '.DP_1);']);
eval(['FD_Sim_DP1' Grouped ' = mean(FD_SimGroup' Grouped '.DP_1);']);

eval(['AD_NAse' Grouped ' = AD_NAstd' Grouped '/(sqrt(10));'])
eval(['AD_DSAse' Grouped ' = AD_DSAstd' Grouped '/(sqrt(10));'])
eval(['AD_SSAse' Grouped ' = AD_SSAstd' Grouped '/(sqrt(10));'])


%-------------------------
%preparing to plot results; this is on the single group-level
%-------------------------
%For x-axis
X1 = [1 2];
X2 = [1 2 3];

%Reaction time and variability
eval(['RT' Grouped ' = [RTSmean' Grouped ' RTCmean' Grouped '];']);
eval(['RTv' Grouped ' = [RTSVar' Grouped ' RTCVar' Grouped '];']);
%of course we can do this with groups as well, e.g.
%RTSv = [RTSVar_gr1 RTCVar_gr2]

figure(2)
subplot(2,1,1);
eval(['bar(X1, RT' Grouped ');']);
xlabel('RTS         RTC ')
ylabel('Mean Reaction time(ms)')
title('Reaction time');
subplot(2,1,2);
eval(['bar(X1, RTv' Grouped ');']);
xlabel('RTS   RTC ')
ylabel('Standard deviation RT(ms)')


%Detection threshold
eval(['DT' Grouped ' = [SDTmean' Grouped ' DDTmean' Grouped '];']);

figure(3)
eval(['bar(X1, DT' Grouped ');']);
xlabel('SDT        DDT ')
ylabel('DL (mn)')
title('Detection Threshold');

%Frequency discrimination
eval(['FDT' Grouped ' = [FD_Seqmean' Grouped ' FD_Simmean' Grouped '];']);

figure(4)
eval(['bar(X1, FDT' Grouped ');']);
xlabel('FD_seq       FD_sim ')
ylabel('DL (Hz)')
title('Frequency Discrimination');

%Amplitude Adaptation
eval(['AD' Grouped ' = [AD_NAmean' Grouped ' AD_DSAmean' Grouped ' AD_SSAmean' Grouped '];'])
eval(['ADstd' Grouped ' = [AD_NAse' Grouped ' AD_DSAse' Grouped ' AD_SSAse' Grouped '];'])

figure(5)
subplot(2,1,1)
eval(['bar(X2, AD' Grouped ');']);
xlabel('AD_NA    AD_DSA      AD_SSA ')
ylabel('DL (mn)')
title('Amplitude Discrimination');
subplot(2,1,2)
eval(['errorbar(X2, AD' Grouped ', ADstd' Grouped ');']);
xlabel('AD_NA   AD_DSA   AD_SSA ')
ylabel('DL (mn)')
title('Amplitude Discrimination');

%plot all comparisons for d' into same graph
figure(6)
% RTCDP = [RTC_DP1];
% SDTDP = [SDT_DP1];
eval(['AD_DP' Grouped ' = [AD_NA_DP1' Grouped ' AD_DSA_DP1' Grouped ' AD_SSA_DP1' Grouped '];']);
eval(['FD_DP' Grouped ' = [FD_Seq_DP1' Grouped ' FD_Sim_DP1' Grouped '];']);

subplot(2,1,1)
eval(['bar(AD_DP' Grouped ');']);
xlabel('AD_NA      AD_DSA       AD_SSA ')
ylabel('D-prime')
title('Amplitude Discrimination - Bias');
subplot(2,1,2)
eval(['bar(FD_DP' Grouped ');']);
xlabel('FD_sim           FD_seq ')
ylabel('D-prime');
title('Frequency Discrimination - Bias');

eval(['TOJ' Grouped ' = [TOJ_simplemean' Grouped ' TOJ_carriermean' Grouped '];']);

figure(7)
eval(['bar(X1, TOJ' Grouped ');']);
xlabel('TOJ_s       TOJ_c ')
ylabel('DL (ms)')
title('Temporal Order Judgement');











