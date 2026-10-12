R_m = 10;               % Motor Resistance (Ohm)
K_a = 0.2;              % Motor Torque Constant (Nm / A)
K_b  = 0.009549;        % Back EMF Constant (V / (rad / s))
K_f = 0.047746;         % Rotational Friction Coefficient (Nm / (rad / s)) 
N = 20;                  % Gear Ratio

La = 0;                 %Negligable motor inductance

J_r = 0.001;            % Motor Rotor Moment of Inertia (kg / m^2)
J_p = 1;                % Solar Panel Moment of Inertia (kg / m^2)
J = J_r + (J_p/N^2);          % Total Moment of Inertia (kg / m^2)

Ts = 0.01; %Seconds

K_p = 4; %Power Amplifier gain
h = 1.5; %Height between panels in meters
K_s = h*(2/1.8); %sensor Gain Converts rads to Amps

%This assumes that at 90deg off from optimal that we get a 2A difference

%{
Arduino Uno Rev3 has a 16MHz clock
so 62ns per tick and you need two ticks for each ....
This gives us plenty of room to not threaten the clock
%}

s = tf('s');
z = tf('z',Ts);
%MOTOR CIRCUIT

mot_circ = 1/(La*s + R_m);
%MOTOR DYNAMICS
mot_dyn = 1/(J*s+K_f);
%Continuous Motor assembly
Gspeed = feedback(mot_circ*K_a*mot_dyn,K_b); %back emf simplified
Gpos = Gspeed*(1/N)*(1/s); 
%digital Motor
Gz = c2d(Gpos, Ts, 'zoh');    %digital plant for digital controller design
                        %effectively does what the Ardunio does for us.
fprintf('DIGITIZED MOTOR MODEL')
[~, denGz] = tfdata(Gz,'v');
rootsGz = roots(denGz);
disp('Roots of the denominator of Gz:')
disp(rootsGz)
%PID

Kp = 1;    %proportional gain
Ki = 0;     %Integral gain
Kd = 15;    %Derivative Gain

Cz = Kp + Ki*(Ts/2)*(z+1)/(z-1) + Kd*(z-1)/(Ts*z);
OL = Cz*Gz*K_p ;
PID_cltf = feedback(OL,K_s);

%PLOTING FOR PID PERFORMANCE/STABILITY
t = 0:Ts:60; % 5 seconds of performance data

figure (1)
clf
step(PID_cltf,t)
title('Step Response of PD')
ylabel('Radians')
grid on
fprintf('PERFORMANCE DATA OF PID')
%stepinfo(PID_cltf)

% Get the PID closed loop step response
[y, t_out] = step(PID_cltf, t);
y = squeeze(y);

% Desired panel angle for a 1 A current difference reference
ref = 0.785;

% Measure response metrics
[peak_time, percent_overshoot, settling_time_2pct, steady_state_error] = ...
    measure_step_metrics(y, t_out, ref);

% Display results
fprintf('Peak Time: %.3f s\n', peak_time)
fprintf('Percent Overshoot: %.2f %%\n', percent_overshoot)
fprintf('2%% Settling Time: %.3f s\n', settling_time_2pct)
fprintf('Steady State Error: %.4f rad\n', steady_state_error)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
clf
margin(OL)
title('Phase Margin detection for PD control')

%% Steady State Stuff
% Extract voltage data
t_volt = ard_out_volt.Time;
volt = squeeze(ard_out_volt.Data);

% Extract angle data and convert radians to degrees
t_theta = theta_offset.Time;
theta_deg = squeeze(theta_offset.Data);

% Extract wind torque data
t_wind = wind_torq.Time;
torq = squeeze(wind_torq.Data);

% Create plots
figure(3)
clf

subplot(3,1,1)
plot(t_volt, volt, 'LineWidth', 1.5)
grid on
xlabel('Time (s)')
ylabel('Voltage (V)')
title('Arduino Output Voltage')

subplot(3,1,2)
plot(t_theta, theta_deg, 'LineWidth', 1.5)
grid on
xlabel('Time (s)')
ylabel('Angle (deg)')
title('Panel Angle Offset')

subplot(3,1,3)
plot(t_wind, torq, 'LineWidth', 1.5)
grid on
xlabel('Time (s)')
ylabel('Torque (N m)')
title('Wind Torque')