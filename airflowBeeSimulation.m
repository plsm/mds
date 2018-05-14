function [posD, posA, vel] = airflowBeeSimulation (...
  posD, posA, vel, T,      ...
  air,                     ... a 1x2 array with 0 or 1 representing state of airpump
  casu_pos = 4.5,          ... CASU position in the arena
  dist = 0.1,              ... speed
  arena_len = 15,          ... rectangular arena approximation
  arena_width = 7,         ... rectangular arena approximation
  airflow_strength = 0.5   ...
  )
  % random angular change of bees
  random_angle = rand (size (posD)) * pi - pi/2;
  
  x = posA.*cos(posD);
  y = posA.*sin(posD);
  
  % if left warmer - more towards left; if right warmer - more towards
  % right.
  % Left always smaller node index.
  left = 1;
  right = 2;
  
  % if warmer on the left - bees want to go in direction pi - position
  % if warmer on the right - want to go in dir 0 - position
  
  grad = ...
    - (T(left) - T(right) > 0) ...
    + (T(left) - T(right) < 0) ...
    ;
  phi_temp = atan2(-posA.*sin(posD), grad * casu_pos-posA.*cos(posD));
  phi_temp = phi_temp - vel;
  if phi_temp > pi
      phi_temp = phi_temp - 2 * pi;
  end
  if phi_temp < -pi
      phi_temp = phi_temp + 2 * pi;
  end
  
  % bees are repeled from CASUs blowing air
  x_air = vertcat ( ...
      x - casu_pos * ones (size (posD)), ...
      x + casu_pos * ones (size (posD)));
  y_air = vertcat (y, y);
  alpha_air = atan2 (y_air, x_air);
  dist_air = sqrt (x_air .^ 2 + y_air .^ 2);
  phi_air = vel .- alpha_air;
  phi_air = air' .* phi_air;
  phi_air = phi_air .+ 2 * pi * (phi_air < -pi);
  phi_air = phi_air .- 2 * pi * (phi_air > pi);
  phi_air = phi_air ./ (1 .+ dist_air);
  phi_air = airflow_strength * phi_air;
  
  scale = exp(abs(T(left)-T(right))/10 - 1);
  vel = vel + random_angle + (T(left) ~= T(right)) * phi_temp .* ...
      (rand(size(random_angle))).^2 * scale + ...
      phi_air (1,:) + phi_air (2,:);
  vel = vel .+ 2 * pi * (vel < -pi);
  vel = vel .- 2 * pi * (vel > pi);
  
  x = min(max(x + dist * cos(vel),-arena_len/2),arena_len/2);
  y = min(max(y + dist * sin(vel),-arena_width/2),arena_width/2);
  posD = atan2(y,x);
  posA = sqrt(x.^2 + y.^2);

end
