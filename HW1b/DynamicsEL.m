function DynamicsEL
    
    clc
    clear all
    
    t = 1:20;               % Time 20 seconds
    g = [0;0;-9.81];
    
    n = 6;
    
    d       = zeros(n,1);
    theta   = zeros(n,1);
    
    j  = zeros(n,1);
    I  = zeros(3,3,n);
    Dv = zeros(n,n,n);
    Dw = zeros(n,n,n);
    D  = zeros(n,n);
    
    % desired angle
    theta(1) = deg2rad(90.0);
    theta(2) = deg2rad(-20.0);
    theta(3) = deg2rad(110.0);
    theta(4) = deg2rad(0.0);
    theta(5) = deg2rad(90.0);
    theta(6) = deg2rad(0.0);
    
%     % desired velocity
%     t1v = 1.0*deg_to_rad;
%     t2v = 1.0*deg_to_rad;
%     t3v = 1.0*deg_to_rad;
%     t4v = 1.0*deg_to_rad;
%     t5v = 1.0*deg_to_rad;
%     t6v = 1.0*deg_to_rad;
% 
%     % desired acceleration
%     t1a = 0.0*deg_to_rad;
%     t2a = 0.0*deg_to_rad;
%     t3a = 0.0*deg_to_rad;
%     t4a = 0.0*deg_to_rad;
%     t5a = 0.0*deg_to_rad;
%     t6a = 0.0*deg_to_rad;
    
    % Mass [kg]
    m(1) = 3.7;
    m(2) = 8.393;
    m(3) = 2.275;
    m(4) = 1.219;
    m(5) = 1.219;
    m(6) = 0.1879;
    
    % Center of mass [m]
    ri_mi(:,1) = 1e-3*[-150.0;58.0;41.0];
    ri_mi(:,2) = 1e-3*[-467.0;0.0;230.0];
    ri_mi(:,3) = 1e-3*[-17.0;25.0;16.0];
    ri_mi(:,4) = 1e-3*[-11.0;120.0;23.0];
    ri_mi(:,5) = 1e-3*[0.0;8.0;25.0];
    ri_mi(:,6) = 1e-3*[0.0;0.0;-168.5];
    
    % Inertia tensors (approximated)
    It(:,:,1) = diag([0.0084 0.0064 0.0084]);
    It(:,:,2) = diag([0.0078 0.2100 0.2100]);
    It(:,:,3) = diag([0.0016 0.0462 0.0462]);
    It(:,:,4) = diag([0.0016 0.0016 0.0009]);
    It(:,:,5) = diag([0.0016 0.0016 0.0009]);
    It(:,:,6) = diag([0.0001 0.0001 0.0001]);
    
   	% dist btw z_i-1 & z_i along x_i in mm
    a = 1e-3*[150;825;0;0;0;0];
    
    % angle from z_i-1 to z_i around x_i in deg
    alpha = [-pi/2;0;pi/2;pi/2;pi/2;0];
    
    % dist btw x_i-1 & x_i along z_i-1 in mm
    d_plus = 1e-3*[550;0;0;625;0;110];
    
    % angle from x_i-1 to x_i around z_i-1 in deg
    theta_plus = [0;-pi/2;pi/2;pi;pi;0];
    
    for i = 1:n
        
        % Trans_z_i-1
        trnZ(:,:,i) = [1 0 0 0;
                       0 1 0 0
                       0 0 1 d(i)+d_plus(i)
                       0 0 0 1];
        
        % Rot_z_i-1 
        rotZ(:,:,i) = [cos(theta(i)+theta_plus(i)) -sin(theta(i)+theta_plus(i))	0	0
                       sin(theta(i)+theta_plus(i))	cos(theta(i)+theta_plus(i))	0	0
                       0                            0                          	1	0
                       0                            0                          	0	1];
        
        % Trans_x_i
        trnX(:,:,i) = [1 0 0 a(i)
                       0 1 0 0
                       0 0 1 0
                       0 0 0 1];
        
        % Rot_x_i
        rotX(:,:,i) = [1	0               0               0
                       0	cos(alpha(i))  -sin(alpha(i))	0
                       0	sin(alpha(i))	cos(alpha(i))	0
                       0	0               0               1];
        
        A(:,:,i) = trnZ(:,:,i)*rotZ(:,:,i)*trnX(:,:,i)*rotX(:,:,i);
        
    end
    
    % Transformation n to 0
    Ti_0(:,:,1) = A(:,:,1);
    for i = 1:n-1
        Ti_0(:,:,i+1) = Ti_0(:,:,i)*A(:,:,i+1);
    end
    
    % Rotation matrices
    for i=1:n
        Ri_0(:,:,i) = Ti_0(1:3,1:3,i);
    end
    
    % Unit vectors
    z0 = [0;0;1];
    for i = 1:n-1
        z(:,:,i+1) = Ti_0(1:3,3,i);
    end
    z(:,:,1) = z0;
    
    % Coordinates of origins
    o0 = zeros(3,1);
    for i = 1:n
        o(:,:,i+1) = Ti_0(1:3,4,i);
    end
    o(:,:,1) = o0;
    
    % Center of mass w.r.t origin of previous link end [m]
    for i = 1:n
        ri_m_prev(:,i) = Ri_0(:,:,i)*ri_mi(:,i);
    end
    
    % Center of mass w.r.t origin of robot [m]
    for i = 1:n
        ri_m0(:,i) = o(:,:,i)+ri_m_prev(:,i);
    end
    
    % Jacobian matrices of each link for their center of mass
    for k = 1:n
        for i = 1:n
            if i <= k
                if j(i)==0
                    Jv_c(:,i,k) = cross(z(:,:,i),(ri_m0(:,k)-o(:,:,i)));
                    Jw_c(:,i,k) = z(:,:,i);
                else
                    Jv_c(:,i,k) = z(:,:,i);
                    Jw_c(:,i,k) = zeros(3,1);
                end
            else
                Jv_c(:,i,k) = zeros(3,1);
                Jv_c(:,i,k) = zeros(3,1);
            end
        end
    end
    J_c = [Jv_c;Jw_c];
    
    % Inertia matrix
    for i = 1:n
        I(:,:,i) = Ri_0(:,:,i)*It(:,:,i)*transpose(Ri_0(:,:,i));
    end
    
    % Calculating inertia matrix M
    for i = 1:n
        Dv(:,:,i) = m(i)*transpose(Jv_c(:,:,i))*Jv_c(:,:,i);
        Dw(:,:,i) = transpose(Jw_c(:,:,i))*I(:,:,i)*Jw_c(:,:,i);
        Di(:,:,i) = Dv(:,:,i) + Dw(:,:,i);
        D = D+Di(:,:,i);
    end
    
    % Christoffel symbols
    for k = 1:n
        for j = 1:n
            for i = 1:n
                c(i,j,k) = (1/2)*( diff(D(k,j),q(i)) + diff(D(k,i),q(j)) - diff(D(i,j),q(k)) );
            end
        end
    end
    
%     P = zeros(n,1);
    % Gravitational
    for i = 1:n
        P(i) = m(i)*transpose(g)*ri_m0(:,i);
    end
    P = sum(P);
    
    % Gravitational term
    for i = 1:n
        phi(i) = diff(P,q(i));
    end
    
    % Torque
  	tau = D*q_dd+C*q_d+phi;
%     for i = 1:n
%         tau(i,1) = D(i,:)*q_dd+C(i,:)*q_d+phi(i);
%     end
    
end