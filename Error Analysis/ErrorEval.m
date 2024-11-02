%% Calculate PAR from raw
% Base.PAR = (Base.Volt)*100; %Convert from mV to umol/m^2s

BaseTT = table2timetable(Base);
TestTT = table2timetable(Test);
TestTT = sortrows(TestTT);
FullTT = synchronize(BaseTT, TestTT, 'hourly', 'mean');
%% Generate Fits
R2B_Fit = (FullTT.Red*2 + FullTT.Blue)*3.3258e+03;

%% Correction
InputValues = TestTT.Blue;
InputShift = circshift(InputValues, 1);
InputShift(1) = InputValues(1); %Copy the first value back so division = 1
Rising = (InputValues)./InputShift;
Falling = InputShift./(InputValues);

LowPoints = (InputShift < 0.01) & (InputValues < 0.01); %Find places where both test points are tiny
Rising(LowPoints) = 1; %Set these tiny points to no change
Rising(Rising < 1) = 1; %Set all negative changes to steady state. Any actual gain changes will be handled by the complementary test
Falling(LowPoints) = 1;
Falling(Falling < 1) = 1;

GainCorrectExp = ones(height(TestTT), 1);
RisingExp = (log2(Rising)); %Take log base 2 of scale of change, round this to get integer - desire nearest integer for best fit
FallingExp = (log2(Falling));
% RisingExp = round(Rising/8.0); %Take log base 2 of scale of change, round this to get integer - desire nearest integer for best fit
% FallingExp = round(Falling/8.0);
RisingExp(RisingExp < 2.75) = 0; %Only look at gain changes greater or equal to 8x
FallingExp(FallingExp < 2.75) = 0;
% RisingExp(RisingExp < 1) = 0; %Only look at gain changes greater or equal to 8x
% FallingExp(FallingExp < 1) = 0;
PrevGain = 0;
NewGain = 0;

for i = 1:height(InputValues)
    if RisingExp(i) > 0
        NewGain = PrevGain - RisingExp(i);
    elseif FallingExp(i) > 0
        NewGain = FallingExp(i);
    elseif InputValues(i) == 0 %Return to min gain at dark periods
        NewGain = 0; 
%         NewGain = 0.125; 
    else
        NewGain = PrevGain;
    end
    if NewGain < 0 %Clamp to 0
        NewGain = 0;
%         NewGain = 0.125;
%     elseif NewGain > 6 %Clamp to 6
%         NewGain = 6;
%         elseif NewGain > 8 %Clamp to 6
%         NewGain = 8;
    end
    PrevGain = NewGain;
    GainCorrectExp(i) = (NewGain);
end

CorrectedOutput = (InputValues).*(2.^(GainCorrectExp));
% CorrectedOutput = (InputValues).*(8*GainCorrectExp); 
%Reduce any excessive gain instances 
sum(CorrectedOutput > 1)
while sum(CorrectedOutput > 1) > 0 %Repeat reducing gain until no corrected values exceed 1
    GainCorrectExp(CorrectedOutput > 1) = GainCorrectExp(CorrectedOutput > 1) - 1; %Decrease gain for all instances where corrected output exceeds 1
    CorrectedOutput = (InputValues).*(2.^(GainCorrectExp)); %Update test values
%     CorrectedOutput = (InputValues).*(8*GainCorrectExp); %Update test values
end
TestTT.BlueCorr = (InputValues).*(2.^(GainCorrectExp));
% TestTT.RedCorr = (InputValues).*(8*GainCorrectExp);

%% Optimize Multiple
minRMSE = 1000;
gain = 0;
for i = 1:3000
    TestTT.PAR_Model = (TestTT.BlueCorr.*i);
    FullTT = synchronize(BaseTT, TestTT, 'hourly', 'mean'); %Take hourly means and synchronize timebase
    RMSE = sqrt(nanmean((FullTT.PAR - FullTT.PAR_Model).^2));
    if RMSE < minRMSE
        minRMSE = RMSE;
        gain = i;
    end
end
%% Test fit
groupStart = datetime(2023,09,01); %Setup start and stop time for testing reduced range
groupEnd = datetime(2023,09,30);
groupTime = timerange(groupStart,groupEnd);
TestTT.PAR_Model = (TestTT.BlueCorr.*2190);
FullTT = synchronize(BaseTT, TestTT, 'hourly', 'mean'); %Take hourly means and synchronize timebase
fitlm(FullTT.PAR,FullTT.BlueCorr) %Test over full range
% fitlm(FullTT(groupTime, 'PAR').PAR, FullTT(groupTime, 'BlueCorr').BlueCorr) %Test fit over limited range

%% Error Eval
RMSE = sqrt(nanmean((FullTT.PAR - FullTT.PAR_Model).^2))
MAE = nanmean(abs(FullTT.PAR - FullTT.PAR_Model))
ME = nanmean((FullTT.PAR - FullTT.PAR_Model))

    