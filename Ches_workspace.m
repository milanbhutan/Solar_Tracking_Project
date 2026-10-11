R_m = 10;               % Motor Resistance (Ohm)
K_a = 0.2;              % Motor Torque Constant (Nm / A)
K_b  = 0.009549;        % Back EMF Constant (V / (rad / s))
K_f = 0.047746;         % Rotational Friction Coefficient (Nm / (rad / s)) 
N = 2;                  % Gear Ratio

La = 0;                 %Negligable motor inductance

J_r = 0.001;            % Motor Rotor Moment of Inertia (kg / m^2)
J_p = 1;                % Solar Panel Moment of Inertia (kg / m^2)
J = J_r + (J_p/N^2);          % Total Moment of Inertia (kg / m^2)

Ts = 0.01; %Seconds
K_s = 1.273; %sensor Gain Converts rads to Amps
K_p = 4; %Power Amplifier gain
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

Kp = 0.55;    %proportional gain
Ki = 0;     %Integral gain
Kd = 0.05;    %Derivative Gain

Cz = Kp + Ki*(Ts/2)*(z+1)/(z-1) + Kd*(z-1)/(Ts*z);
OL = Cz*Gz*K_p ;
PID_cltf = feedback(OL,K_s);

[~, denPID_cltf] = tfdata(PID_cltf,'v');
rootsPID_cltf = roots(denPID_cltf);
disp('Roots of the denominator of PID_cltf:')
disp(rootsPID_cltf)

%PLOTING FOR PID PERFORMANCE/STABILITY
t = 0:Ts:60; % 5 seconds of performance data

figure (1)
clf
step(PID_cltf,t)
title('Step Response of PID')
ylabel('Radians')
grid on
fprintf('PERFORMANCE DATA OF PID')
stepinfo(PID_cltf)

figure(2)
clf
margin(OL)
title('Phase Margin detection for PID control')


%LEAD CONTroller git test
%%%%%%%%%%%%
%]
%
%
%
%