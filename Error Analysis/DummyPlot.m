tstart = datetime(2023,07,23);
tend = datetime(2023,07,24);

subplot(2, 1, 1);
plot(FullTT.Time, (FullTT.PAR)./max(FullTT.PAR));
hold on
plot(TestTT.Time, TestTT.Red)
% plot(FullTT.Time, FullTT.RedCorr);
% plot(FullTT.Time, FullTT.GreenCorr);
% plot(FullTT.Time, FullTT.BlueCorr);
xlim([tstart tend])
legend("PAR","Red","Green","Blue");
subplot(2, 1, 2);
plot(TestTT.Time, Rising)
hold on
plot(TestTT.Time, Falling)
plot(TestTT.Time, GainCorrectExp)
legend("Rising","Falling", "GainExp");


xlim([tstart tend])

%% 


plot(FullTT.Time, (FullTT.BlueCorr.*2190), '-s', 'LineWidth', 1.5, 'MarkerSize',5);
hold on
plot(FullTT.Time, FullTT.PAR,'-d','LineWidth', 1.5, 'MarkerSize',5);
% plot(TestTT.Time, TestTT.Blue,'-^','LineWidth', 1.5, 'MarkerSize',5)

xlim([tstart tend])
xlabel("Time");
% ylabel("Relative Amplitude");
ylabel("\mu mol m^{-2} s^{-1}")
title("PAR vs Modeled PAR");
% title("PAR ADC Offset");
% line([datetime(2023,07,23,09,00,00),datetime(2023,07,23,09,00,00)],[0,0.7],'Color','black','LineStyle','--')
% line([datetime(2023,07,23,00,00,00),datetime(2024,07,23,00,00,00)],[56, 56],'Color','black','LineStyle','--')
% legend("TCS3400 - Blue, Corrected","PAR (Normalized)", "TCS3400 - Blue");
legend("PAR", "Modeled PAR");

%%
% minVal = min(min(FullTT.PAR), min(FullTT.PAR_Model));
% maxVal = max(max(FullTT.PAR), max(FullTT.PAR_Model));
xMax = max(FullTT.PAR);
scatter(FullTT.PAR, FullTT.PAR_Model);
line([0,xMax],[16.882, xMax*0.71683],'Color','red','LineStyle','--','LineWidth', 1.5)
line([0,xMax],[0, xMax],'Color','black','LineStyle',':','LineWidth', 1.5)
title("Regression of PAR vs Modeled PAR");
xlabel("PAR [\mu mol m^{-2} s^{-1}]");
ylabel("PAR - Modeled [\mu mol m^{-2} s^{-1}]");
dim = [0.2 0.5 0.4 0.4];
str = {'Fit: y = 0.71683*x + 16.882'};
legend("Data","Regression Fit","1:1 Line")
annotation('textbox',dim,'String',str,'FitBoxToText','on');