%Step Input, No Disturbance
R_m = 10;               % Motor Resistance (Ohm)
K_a = 0.2;              % Motor Torque Constant (Nm / A)
K_b  = 0.009549;        % Back EMF Constant (V / (rad / s))
K_f = 0.047746;         % Rotational Friction Coefficient (Nm / (rad / s)) 
N = 20;                  % Gear Ratio

La = 0;                 %Negligable motor inductance

J_r = 0.001;            % Motor Rotor Moment of Inertia (kg / m^2)
J_p = 15.44;                % Solar Panel Moment of Inertia (kg / m^2)
J = J_r + (J_p/N^2);          % Total Moment of Inertia (kg / m^2)

Ts = 0.01; %Seconds

K_p = 4; %Power Amplifier gain
h = 0.25; %Height between panels in meters
K_s = h*(2/1.8); %sensor Gain Converts rads to Amps
%This assumes that at 90deg off from optimal that we get a 2A difference

K_p2 = 25;


%{
Arduino Uno Rev3 has a 16MHz clock
so 62ns per tick and you need two ticks for each ....
This gives us plenty of room to not threaten the clock
%}