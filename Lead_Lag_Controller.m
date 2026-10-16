params;

s = tf('s');
z = tf('z',Ts);
%MOTOR CIRCUIT
mot_circ = 1/(La*s + R_m);

%MOTOR DYNAMICS
mot_dyn = 1/(J*s+K_f);

%Continuous Motor assembly
Gspeed = feedback(mot_circ*K_a*mot_dyn,K_b); %back emf simplified
Gpos = Gspeed * (1/N) * (1/s) * K_p; 



%digital Motor
Gz = c2d(Gpos, Ts, 'zoh');    %digital plant for digital controller design
                              %effectively does what the Arduino does for us.

fprintf('DIGITIZED MOTOR MODEL')
[~, denGz] = tfdata(Gz,'v');
rootsGz = roots(denGz);
disp('Roots of the denominator of Gz:')
disp(rootsGz)

%Lag Controller
K = 500;
s_p_lag = 0.0001;
s_z_lag = 0.01;
s_p_lead = 30;
s_z_lead = 3;


numCz_lag = (z - exp(-s_z_lag*Ts));
denCz_lag = (z - exp(-s_p_lag*Ts));

numCz_lead = (z - exp(-s_z_lead*Ts));
denCz_lead = (z - exp(-s_p_lead*Ts));

Cz = K * (numCz_lag / denCz_lag) * (numCz_lead / denCz_lead);
[numCz , denCz] = tfdata(Cz, 'v');

OL = Cz*Gz ;
PID_cltf = feedback(OL, K_s * K_p2);

[~, denPID_cltf] = tfdata(PID_cltf,'v');
rootsPID_cltf = roots(denPID_cltf);
disp('Roots of the denominator of PID_cltf:')
disp(rootsPID_cltf)

%PLOTING FOR PID PERFORMANCE/STABILITY
t = 0:Ts:60; % 5 seconds of performance data

figure(1)
clf
step(PID_cltf,t)
title('Step Response of PD', 'FontSize', 18)
xlabel('Time (s)', 'FontSize', 18)
ylabel('Radians', 'FontSize', 18)
grid on
fprintf('PERFORMANCE DATA OF PID')
stepinfo(PID_cltf)

figure(2)
clf
margin(OL * K_s * K_p2)
title('Phase Margin detection for PD control')

f = -10 : 0.1: 10;
pulse_time = 5;
pulse_height = 0.2;

fft_rect = pulse_height*pulse_time*(sin(pi*pulse_time.*f)./(pi*pulse_time.*f));

figure(3);
plot(f, fft_rect);
xlabel("Frequency", "FontSize",18);
ylabel("Magnitude", "FontSize",18);
