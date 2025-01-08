% function tau = EL_invdyn(v,j,Ti_0)

clc
clear all
close all

timerVal1 = tic;
    %% Inputs

    syms q1 q2 q3 q4 q5 q6
    syms q1_d q2_d q3_d q4_d q5_d q6_d
    syms q1_dd q2_dd q3_dd q4_dd q5_dd q6_dd
    
    q       = [q1;q2;q3;q4;q5;q6];
    q_d     = [q1_d;q2_d;q3_d;q4_d;q5_d;q6_d];
    q_dd	= [q1_dd;q2_dd;q3_dd;q4_dd;q5_dd;q6_dd];
    
    MDH_val = 0;    % Use 0 for DH, 1 for MDH Parameters
    v = 1;          % 1: UR5, 2: UR10, 3: RX160, 4: IRB 140
    n = 6;          % DoF [Don't change]
    sym = 1;
    
    [m,ri_h_ci,It] = DynParameters(v,n);

    if MDH_val == 0
        [DH,~,~,j,alpha_sym,theta_plus_sym] = DHParameters(v,n);
    else
        [DH,~,~,j,alpha_sym,theta_plus_sym] = MDHParameters(v,n);
    end
    
    d           = zeros(n,1);
    d_plus      = 1e-3*DH(:,3);
    theta       = q;
    theta_plus  = theta_plus_sym;
    a           = 1e-3*DH(:,1);
    alpha       = alpha_sym;
    
    [T0_i, ~]   = Transformation(d,d_plus,theta,theta_plus,a,alpha,MDH_val,sym);
    
%     T0_i
    
  	%% Actual Part
    
    t_0     = 0;    % initial time [s]
    t_end   = 20;  	% final time [s]
    t_stp   = 0.1;	% time step [s]
    
    g = [0;0;-9.81];	% gravitational acceleration
    
%     Tsize = size(T0_i);
%     n = Tsize(3);
    
    % Rotation matrices
    R0_i = zeros(3,3,n,'sym');
%     Rh_i = zeros(3,3,n,'sym');
    
    for i=1:n
        R0_i(:,:,i) = T0_i(1:3,1:3,i);
%         Rh_i(:,:,i) = A(1:3,1:3,i);
    end
%     Rh_i(:,:,7) = zeros(3,3,'sym');
    
%     % Displacement vector between current frame and previous frame
%     r_h_i_sym = zeros(3,1,n,'sym');
%     for i=1:n
%         r_h_i_sym(:,:,i) = transpose(Rh_i_sym(:,:,i))*A_i(1:3,4,i);
%     end
    
    % Unit vectors
    z_h = zeros(3,1,n,'sym');
    z_h(:,1,1) = [0;0;1];
    for i = 1:n-1
        z_h(:,:,i+1) = T0_i(1:3,3,i);
    end
    
%     % Rotation axis for other joints
%     b_sym(:,:,1) = transpose(R0_i_sym(:,:,1))*z_h(:,:,1);
%     for i = 2:n
%         b_sym(:,:,i) = transpose(R0_i_sym(:,:,i))*R0_i_sym(:,:,i-1)*z_h(:,:,1);
%     end
    
    % Coordinates of origins
    o_h(:,:,1) = zeros(3,1,'sym');
    for i = 1:n
        o_h(:,:,i+1) = T0_i(1:3,4,i);
    end
    
    % Center of mass w.r.t previous CF [m]
    rh_h_ci = zeros(3,n,'sym');
    
    for i = 1:n
        rh_h_ci(:,i) = R0_i(:,:,i)*ri_h_ci(:,i);
    end
    
    % Center of mass w.r.t origin of robot [m]
    r0_ci = zeros(3,n,'sym');
    
    for i = 1:n
        r0_ci(:,i) = o_h(:,:,i)+rh_h_ci(:,i);
    end
   	
    % Jacobian matrices of each link for their center of mass
    Jv_c = zeros(3,n,n,'sym');
    Jw_c = zeros(3,n,n,'sym');
    
    for k = 1:n
        for i = 1:n
            if i <= k
                if j(i)==0
                    Jv_c(:,i,k) = cross(z_h(:,:,i),(r0_ci(:,k)-o_h(:,:,i)));
                    Jw_c(:,i,k) = z_h(:,:,i);
                else
                    Jv_c(:,i,k) = z_h(:,:,i);
                    Jw_c(:,i,k) = zeros(3,1);
                end
            else
                Jv_c(:,i,k) = zeros(3,1);
                Jv_c(:,i,k) = zeros(3,1);
            end
        end
    end
    J_c = [Jv_c;Jw_c];
    disp('J computed.')
    
    % Inertia matrix
    I = zeros(3,3,n,'sym');
    
    for i = 1:n
        I(:,:,i) = R0_i(:,:,i)*It(:,:,i)*transpose(R0_i(:,:,i));
    end
    
    % Inertia Matrix
    Dv  = zeros(n,n,n,'sym');
    Dw  = zeros(n,n,n,'sym');
    Di  = zeros(n,n,n,'sym');
    D   = zeros(n,n,'sym');
    
    for i = 1:n
        Dv(:,:,i)   = m(i)*transpose(Jv_c(:,:,i))*Jv_c(:,:,i);
        Dw(:,:,i)   = transpose(Jw_c(:,:,i))*I(:,:,i)*Jw_c(:,:,i);
        Di(:,:,i)   = Dv(:,:,i) + Dw(:,:,i);
        D           = D+Di(:,:,i);
    end
    D_sym = simplify(D)
%     D_invChol = invChol_mex(D_sym)
    
    disp('D computed.')
    
%     % Christoffel symbols
%     c = zeros(n,n,n,'sym');
%     
%     for k = 1:n
%         for j = 1:n
%             for i = 1:n
%                 c(i,j,k) = (1/2)*( diff(D_sym(k,j),q(i)) + diff(D_sym(k,i),q(j)) - diff(D_sym(i,j),q(k)) );
%             end
%         end
%     end
%     disp('c computed.')
%     
%     % Christoffel Matrix
%     C = zeros(n,n,'sym');
%     
%     for k = 1:n
%         for j = 1:n
%             for i = 1:n
%                 C(k,j) = C(k,j)+c(i,j,k)*q_d(i);
%             end
%         end
%     end
%     C_sym = simplify(C);
%     disp('C computed.')
%     
%     % Potential Energy
%     P = zeros(n,1,'sym');
%     
%     for i = 1:n
%         P(i,1) = m(i)*transpose(g)*r0_ci(:,i);
%     end
%     P_sym = sum(P);
%     disp('P computed.')
%     
%     % Gravitational term
%     phi = zeros(n,1,'sym');
%     
%     for i = 1:n
%         phi(i,1) = diff(P_sym,q(i));
%     end
%     phi_sym = phi;
%     disp('phi computed.')
%     
%     % New symbolic inputs
%     syms time
% 
%     omega       = ones(n,1);
%     q_dd_sym    = zeros(n,1,'sym');
%     q_d_sym     = zeros(n,1,'sym');
%     q_sym       = zeros(n,1,'sym');
%     
%     for i = 1:n
%         q_dd_sym(i,1)	= sin(omega(i)*time);
%         q_d_sym(i,1)    = int(q_dd_sym(i));
%         q_sym(i,1)      = int(q_d_sym(i));
%     end
% 
%     % Replace old symbols with new ones
%     D_sym   = subs(D_sym,q,q_sym);
%     C_sym   = subs(C_sym,[q q_d],[q_sym q_d_sym]);
%     phi_sym	= subs(phi_sym,q,q_sym);
%     
%     elapsedTime_initial = toc(timerVal1);
%     timerVal2 = tic;
%     
%     dispstat('','init'); %one time only init 
%     dispstat('Required torque:','keepthis');
%     
%     % Torque
%     i = 0;
%     tau = zeros(n,1,t_end/t_stp+1,'sym');
%     for t = t_0:t_end/t_stp
% 
%         i = 1+i;
%         dispstat(sprintf('Computing... %d%% (%d/%d)',round(100*i/(t_end/t_stp+1)),i,(t_end/t_stp)+1));
%         
%         q_d     = subs(q_d_sym,time,t*t_stp);
%         q_dd    = subs(q_dd_sym,time,t*t_stp);
% 
%         D       = subs(D_sym,time,t*t_stp);
%         C       = subs(C_sym,time,t*t_stp);
%         phi     = subs(phi_sym,time,t*t_stp);
% 
%         tau(:,1,i) = D*q_dd+C*q_d+phi;
% 
%     end
% 
%     dispstat('Finished.','keepprev');
%     
%     plot_x = t_0:t_stp:t_end;
%     plot_y = zeros(n,(t_end/t_stp)+1);
%     for i = 1:n
%         plot_y(i,:) = tau(i,1,:);
%         figure(i)
%         plot(plot_x,plot_y(i,:))
%     end
% 
%     elapsedTime_torque = toc(timerVal2);
%     elapsedTime_total = toc(timerVal1);
%    
% 	fprintf('\nTotal computing time: %d min %d sec\n', round(elapsedTime_total/60), round(rem(elapsedTime_total,60)))
%    
% % end