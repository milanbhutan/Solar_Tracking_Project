R_m = 10;               % Motor Resistance (Ohm)
K_a = 0.2;              % Motor Torque Constant (Nm / A)
K_b  = 0.009549;        % Back EMF Constant (V / (rad / s))
K_f = 0.047746;         % Rotational Friction Coefficient (Nm / (rad / s)) 
N = 2;                  % Gear Ratio

J_r = 0.001;            % Motor Rotor Moment of Inertia (kg / m^2)
J_p = 1;                % Solar Panel Moment of Inertia (kg / m^2)
J = J_r + J_p;          % Total Moment of Inertia (kg / m^2)