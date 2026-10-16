params;
Lead_Lag_Controller;

syms s_sym z_sym R_m_sym K_a_sym K_b_sym K_f_sym N_sym ...
    La_sym J_r_sym J_p_sym J_sym Ts_sym K_p_sym h_sym Gs_sym Gz_sym Cz_symb
%{
Arduino Uno Rev3 has a 16MHz clock
so 62ns per tick and you need two ticks for each ....
This gives us plenty of room to not threaten the clock
%}

s = tf('s');
z = tf('z',Ts);
%MOTOR CIRCUIT

mot_circ = 1 / (La_sym*s_sym + R_m_sym);
%MOTOR DYNAMICS
mot_dyn = 1 / (J_sym * s_sym + K_f_sym);
%Continuous Motor assembly
G_motor = mot_circ * K_a_sym * mot_dyn;
Gspeed = simplify(G_motor/(1 + G_motor*K_b_sym));
Gpos = Gspeed*(1/N_sym)*(1/s_sym) * K_p_sym; 

pretty(Gpos);


Gpos_nominal = subs(Gpos, ...
    [R_m_sym K_a_sym K_b_sym K_f_sym N_sym La_sym J_sym K_p_sym], ...
    [R_m     K_a     K_b     K_f     N     La     J     K_p]);

[num_expr, den_expr] = numden(Gpos_nominal);
num_Gpos = sym2poly(expand(num_expr));
den_Gpos = sym2poly(expand(den_expr));

Gpos_tf_s = tf(num_Gpos/num_Gpos(1), den_Gpos/num_Gpos(1));
Gpos_tf_z = c2d(Gpos_tf_s, Ts);

[numGpos_z, denGpos_z] = tfdata(Gpos_tf_z, 'v');

% disp(Gpos_tf_z);
% RMSE = rmse(out.theta_offset_plant1.Data, out.theta_offset_plant2.Data);
% fprintf("RMSE: %.10f \n", RMSE);

load('linsys1.mat');
[num_dist, den_dist] = tfdata(linsys1, 'v');