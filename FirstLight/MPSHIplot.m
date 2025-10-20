%This plot is made by Tony Vincent.  It is the for the fourth figure in the
%paper.  It is a plot of the MPS-HI instrument response function.  

clear vars;
close all;

GOES1 = readtable("G17_mpshi_E1S_gf.csv");
GOES2 = readtable("G17_mpshi_E2_gf.csv");

verthiy2 = [0,1];
verthix2 = [145,145];
verthiy1 = [0,1];
verthix1 = [20,20];

fig1 = figure('DefaultAxesFontSize', 12);
ax = axes();
fig1.Position = [750 25 1200 500];

p1 = semilogx(GOES1.E_keV_, GOES1.ETel2./max(GOES1.ETel2), "b",...
    GOES2.E_keV_, GOES2.ETel2./max(GOES2.ETel2), "r",...
    verthix1, verthiy1, "k--", verthix2, verthiy2,"k--");
hold on
p1(1).LineWidth = 2;
p1(2).LineWidth = 2;
p1(3).LineWidth = 3;
p1(4).LineWidth = 3;
%set(gca,'LineWidth',2,'TickLength',[0.025 0.025]);
set(gca,'LineWidth',2);
ylabel('Instrument Response (arb.)');
xlabel('Electron Energy (keV)');
ax = gca; 
ax.FontSize = 16;
legend('MPS-HI 1','MPS-HI 2','SEED Range')

dt = datetime('now');
yearStr = num2str(dt.Year);
monthStr = num2str(dt.Month, '%02d');
dayStr = num2str(dt.Day, '%02d');
dateStr = [yearStr, monthStr, dayStr];
saveName = ['/SS1/STPSat-6/Papers/FirstLight/MPS-HI_Instrument_Response', ...
    dateStr];

fig1FileName = strcat(saveName, '.png');

%Save the plot to a file.
saveas(fig1, fig1FileName);