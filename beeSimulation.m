function [posD, posA, vel] = beeSimulation(posD, posA, vel, T, draw)
    
    global casu_pos
    % speed
    dist = 0.1;
    % rectangular arena approximation
    arena_len = 15;
    
    % random angular change of bees 
    random_angle = min(max(rand(size(posD))*pi-pi/2,-pi/2),pi/2);
    
    % if left warmer - more towards left; if right warmer - more towards 
    % right.
    % Left always smaller node index.
    left = 1;
    right = 2;
    
    % if warmer on the left - bees want to go in direction pi - position
    % if warmer on the right - want to go in dir 0 - position
    
    grad = - (T(left) - T(right) > 0) + (T(left) - T(right) < 0) + 0*(T(left)-T(right) == 0);
    
    phi_temp = atan2(-posA.*sin(posD), grad * casu_pos-posA.*cos(posD));
    phi_temp = phi_temp - vel;
    if phi_temp > pi
        phi_temp = phi_temp - 2 * pi;
    end
    if phi_temp < -pi
        phi_temp = phi_temp + 2 * pi;
    end
%     random_angle = random_angle + phi_temp .* abs(rand(size(random_angle)));
    
    scale = exp(abs(T(left)-T(right))/10 - 1);
    vel = vel + random_angle + (T(left) ~= T(right)) * phi_temp .* ...
        (rand(size(random_angle))).^2 * scale;
    if vel < -pi
        vel = vel + 2 * pi;
    end
    if vel > pi
        vel = vel - 2 * pi;
    end
    
    x = posA.*cos(posD);
    y = posA.*sin(posD);
    x = min(max(x + dist * cos(vel),-arena_len/2),arena_len/2);
    y = min(max(y + dist * sin(vel),-arena_len/2),arena_len/2);
    posD = atan2(y,x);
    posA = sqrt(x.^2 + y.^2);
    
    if draw
        scatter(x,y);
        hold on
    %     quiver(x,y,cos(vel),sin(vel));
    %     quiver(x,y,cos(random_angle),sin(random_angle),'--');
    %     quiver(x,y,cos(phi_temp),sin(phi_temp),'--');
        scatter(-casu_pos,0,[],'b','x');
        scatter(casu_pos,0,[],'b','x');
        hold off
        axis([-10,10,-10,10])

    %      hold on;
    %     figure(2)
    %      plot(phi)
    end
end