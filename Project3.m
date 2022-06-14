clc; clear; close all;

load('04-12-19_04.45 765_LA92_40degC_Turnigy_Graphene.mat');
LiPoly.RecordingTime            = meas.Time;
LiPoly.Measured_Voltage         = meas.Voltage;
LiPoly.Measured_Current         = meas.Current;
LiPoly.Measured_Temperature     = meas.Battery_Temp_degC;

nominalCap                      = 4.81; % Battery capacity in Ah taken from data.
LiPoly.Measured_SOC             = (nominalCap + meas.Ah).*100./nominalCap;  % Calculate the SOC using Coloumb Counting for comparison

LiPoly.RecordingTime            = LiPoly.RecordingTime(1:10:end);
LiPoly.Measured_Voltage         = LiPoly.Measured_Voltage(1:10:end);
LiPoly.Measured_Current         = LiPoly.Measured_Current(1:10:end);
LiPoly.Measured_Temperature     = LiPoly.Measured_Temperature(1:10:end);
LiPoly.Measured_SOC             = LiPoly.Measured_SOC(1:10:end);

% Current Definition: (+) Discharging, (-) Charging
LiPoly.Measured_Current_R       = - LiPoly.Measured_Current;

% Converting seconds to hours
LiPoly.RecordingTime_Hours      = LiPoly.RecordingTime/3600;

[SOC_Estimated, Vt_Estimated, Vt_Error] = EKF_SOC_Estimation(LiPoly.Measured_Current_R, LiPoly.Measured_Voltage, LiPoly.Measured_Temperature);
[SOC_Estimated1, Vt_Estimated1, Vt_Error1] = UKF_SOC_Estimation(LiPoly.Measured_Current_R, LiPoly.Measured_Voltage, LiPoly.Measured_Temperature);

% Terminal Voltage Measured vs. Estimated
figure(1)
plot(LiPoly.RecordingTime_Hours,LiPoly.Measured_Voltage);
hold on
plot(LiPoly.RecordingTime_Hours,Vt_Estimated);
hold on
plot(LiPoly.RecordingTime_Hours,Vt_Estimated1);
hold off;
legend('Measured','Estimated EKF', 'Estimated UKF');
ylabel('Terminal Voltage[V]');xlabel('Time[hr]');
title('Measured vs. Estimated Terminal Voltage (V) at 0 Deg C')
% grid minor

% Terminal Voltage Error
figure(2)
plot(LiPoly.RecordingTime_Hours,Vt_Error);
hold on
plot(LiPoly.RecordingTime_Hours,Vt_Error1);
hold off;
legend('Terminal Voltage Error EKF', 'Terminal Voltage Error UKF');
ylabel('Terminal Voltage Error');
xlabel('Time[hr]');

% SOC Coulomb Counting vs. Estimated
figure(3)
plot (LiPoly.RecordingTime_Hours,LiPoly.Measured_SOC);
hold on
plot (LiPoly.RecordingTime_Hours,SOC_Estimated*100);
hold on
plot (LiPoly.RecordingTime_Hours,SOC_Estimated1*100);
hold off;
legend('Coulomb Counting','Estimated EKF', 'Estimated UKF');
ylabel('SOC[%]');xlabel('Time[hr]');
title('Coulomb Counting vs. SOC Estimated at 0 Deg C')
% grid minor

% SOC Error
figure(4)
plot(LiPoly.RecordingTime_Hours,(LiPoly.Measured_SOC - SOC_Estimated*100));
hold on
plot(LiPoly.RecordingTime_Hours,(LiPoly.Measured_SOC - SOC_Estimated1*100));
hold off;
legend('SOC Error EKF', 'SOC Error UKF');
ylabel('SOC Error [%]');
xlabel('Time[hr]');
% grid minor

RMSE_Vt     = sqrt((sum((LiPoly.Measured_Voltage - Vt_Estimated).^2)) /(length(LiPoly.Measured_Voltage)))*1000
RMSE_SOC    = sqrt((sum((LiPoly.Measured_SOC - SOC_Estimated*100).^2)) /(length(LiPoly.Measured_SOC)))
Max_Vt      = max(abs(LiPoly.Measured_Voltage - Vt_Estimated))*1000
Max_SOC     = max(abs(LiPoly.Measured_SOC - SOC_Estimated*100))

RMSE_Vt1     = sqrt((sum((LiPoly.Measured_Voltage - Vt_Estimated1).^2)) /(length(LiPoly.Measured_Voltage)))*1000
RMSE_SOC1    = sqrt((sum((LiPoly.Measured_SOC - SOC_Estimated1*100).^2)) /(length(LiPoly.Measured_SOC)))
Max_Vt1      = max(abs(LiPoly.Measured_Voltage - Vt_Estimated1))*1000
Max_SOC1     = max(abs(LiPoly.Measured_SOC - SOC_Estimated1*100))