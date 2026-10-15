% clear all;
% 
% %Step Input, No Disturbance
% R_m = 10;               % Motor Resistance (Ohm)
% K_a = 0.2;              % Motor Torque Constant (Nm / A)
% K_b  = 0.009549;        % Back EMF Constant (V / (rad / s))
% K_f = 0.047746;         % Rotational Friction Coefficient (Nm / (rad / s)) 
% N = 20;                  % Gear Ratio
% 
% La = 0;                 %Negligable motor inductance
% 
% J_r = 0.001;            % Motor Rotor Moment of Inertia (kg / m^2)
% J_p = 15.44;                % Solar Panel Moment of Inertia (kg / m^2)
% J = J_r + (J_p/N^2);          % Total Moment of Inertia (kg / m^2)
% 
% Ts = 0.01; %Seconds
% 
% K_p = 4; %Power Amplifier gain
% h = 1.5; %Height between panels in meters
% K_s = h*(2/1.8); %sensor Gain Converts rads to Amps
% %This assumes that at 90deg off from optimal that we get a 2A difference
% 
% syms s_sym z_sym R_m_sym K_a_sym K_b_sym K_f_sym N_sym ...
%     La_sym J_r_sym J_p_sym J_sym Ts_sym K_p_sym h_sym Gs_sym Gz_sym Cz_symb
% %{
% Arduino Uno Rev3 has a 16MHz clock
% so 62ns per tick and you need two ticks for each ....
% This gives us plenty of room to not threaten the clock
% %}
% 
% s = tf('s');
% z = tf('z',Ts);
% %MOTOR CIRCUIT
% 
% mot_circ = 1 / (La_sym*s_sym + R_m_sym);
% %MOTOR DYNAMICS
% mot_dyn = 1 / (J_sym * s_sym + K_f_sym);
% %Continuous Motor assembly
% G_motor = mot_circ * K_a_sym * mot_dyn;
% Gspeed = simplify(G_motor/(1 + G_motor*K_b_sym));
% Gpos = Gspeed*(1/N_sym)*(1/s_sym) * K_p_sym; 
% pretty(Gpos);
% 
% %Lag Controller
% K = 100;
% s_p = 0.0001;
% s_z = 0.01;
% 
% Cs = K * ((s + s_z) / (s + s_p));
% numCz = K * (z - exp(-s_z*Ts));
% denCz = (z - exp(-s_p*Ts));
% Cz = numCz / denCz;
% [numCz , denCz] = tfdata(Cz, 'v');
% 
% 
% Gpos_nominal = subs(Gpos, ...
%     [R_m_sym K_a_sym K_b_sym K_f_sym N_sym La_sym J_sym K_p_sym], ...
%     [R_m     K_a     K_b     K_f     N     La     J     K_p]);
% 
% [num_expr, den_expr] = numden(Gpos_nominal);
% num_Gpos = sym2poly(expand(num_expr));
% den_Gpos = sym2poly(expand(den_expr));
% 
% Gpos_tf = tf(num_Gpos, den_Gpos);
% disp(Gpos_tf);
