function [u_inf] = airspeed(delta_l, alpha, rho_a, rho_rs, g)

u_inf = sqrt(2*g*delta_l*sin(alpha*(180/pi))*(rho_rs/rho_a));

end
