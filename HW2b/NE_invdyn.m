% function tau = NE_invdyn(v,j,Ti_0)

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
        [DH,~,~,~,alpha_sym,theta_plus_sym] = DHParameters(v,n);
    else
        [DH,~,~,~,alpha_sym,theta_plus_sym] = MDHParameters(v,n);
    end
    
    d           = zeros(n,1);
    d_plus      = 1e-3*DH(:,3);
    theta       = q;
    theta_plus  = theta_plus_sym;
    a           = 1e-3*DH(:,1);
    alpha       = alpha_sym;
    
    [T0_i, A_i] = Transformation(d,d_plus,theta,theta_plus,a,alpha,MDH_val,sym);
    
%     T0_i
    
    %% Actual Part
    
    t_0     = 0;    % initial time [s]
    t_end   = 20;  	% final time [s]
    t_stp   = 0.1;	% time step [s]
    
    g = 9.81;	% gravitational acceleration

%     Tsize = size(T0_i);
%     n = Tsize(3);

    % Rotation matrices
    R0_i_sym = zeros(3,3,n,'sym');
    Rh_i_sym = zeros(3,3,n,'sym');
    
    for i=1:n
        R0_i_sym(:,:,i) = T0_i(1:3,1:3,i);
        Rh_i_sym(:,:,i) = A_i(1:3,1:3,i);
    end
    Rh_i_sym(:,:,7) = zeros(3,3,'sym');
    
    % Displacement vector between current frame and previous frame
    r_h_i_sym = zeros(3,1,n,'sym');
    for i=1:n
        r_h_i_sym(:,:,i) = transpose(Rh_i_sym(:,:,i))*A_i(1:3,4,i);
    end
    
    % Unit vectors
    z_h = zeros(3,1,n,'sym');
    z_h(:,1,1) = [0;0;1];
    for i = 1:n-1
        z_h(:,:,i+1) = T0_i(1:3,3,i);
    end
    
    % Rotation axis for other joints
    b_sym(:,:,1) = transpose(R0_i_sym(:,:,1))*z_h(:,:,1);
    for i = 2:n
        b_sym(:,:,i) = transpose(R0_i_sym(:,:,i))*R0_i_sym(:,:,i-1)*z_h(:,:,1);
    end
    
%     % Coordinates of origins
%     o_h(:,:,1) = zeros(3,1,'sym');
%     for i = 1:n
%         o_h(:,:,i+1) = T0_i(1:3,4,i);
%     end
    
    % New symbolic inputs
    syms time

    omega       = ones(n,1);
    q_dd_sym    = zeros(n,1,'sym');
    q_d_sym     = zeros(n,1,'sym');
    q_sym       = zeros(n,1,'sym');
    
    for i = 1:n
        q_dd_sym(i,1)	= sin(omega(i)*time);
        q_d_sym(i,1)    = int(q_dd_sym(i));
        q_sym(i,1)      = int(q_d_sym(i));
    end
    
    % Replace old symbols with new ones
    Rh_i_sym	= subs(Rh_i_sym,q,q_sym);
    R0_i_sym    = subs(R0_i_sym,[q q_d],[q_sym q_d_sym]);
    r_h_i_sym	= subs(r_h_i_sym,q,q_sym);
    b_sym    	= subs(b_sym,q,q_sym);
    z_h_sym     = subs(z_h,q,q_sym);
    
    % Initial conditions
    omega_h         = zeros(3,1,n+1);
    omega_d_h       = zeros(3,1,n+1);
    alpha_h         = zeros(3,1,n+1);
    a_eh            = zeros(3,1,n+1);
    a_ch            = zeros(3,1,n+1);
    
    f               = zeros(3,1,n+1);
    tau             = zeros(3,1,n+1);
    tau_z           = zeros(1,1,(t_end/t_stp)+1);
    g_h             = zeros(3,1,n);
    g_h(:,:,1)      = [0;0;-g];
    
    elapsedTime_initial = toc(timerVal1);
    timerVal2 = tic;
    
    dispstat('','init'); %one time only init 
    dispstat('Required torque:','keepthis');
    
    j = 0;
    for t = t_0:t_end/t_stp

        j = 1+j;
        dispstat(sprintf('Computing... %d%% (%d/%d)',round(100*j/(t_end/t_stp+1)),j,(t_end/t_stp)+1));
        
        q_d     = subs(q_d_sym,time,t*t_stp);
        q_dd    = subs(q_dd_sym,time,t*t_stp);

        Rh_i    = subs(Rh_i_sym,time,t*t_stp);
        R0_i    = subs(R0_i_sym,time,t*t_stp);

        r_h_i   = subs(r_h_i_sym,time,t*t_stp);
    
        b       = subs(b_sym,time,t*t_stp);
        z_h     = subs(z_h_sym,time,t*t_stp);

        % Forward Recursion (Link 1 to n)
        for i = 1:n
            omega_h(:,:,i+1)  	= transpose(Rh_i(:,:,i))*omega_h(:,:,i)+b(:,:,i)*q_d(i);
            omega_d_h(:,:,i+1)	= omega_d_h(:,:,i)+z_h(:,:,i)*q_dd(i)+cross(omega_h(:,:,i+1),(z_h(:,:,i)*q_d(i)));
            alpha_h(:,:,i+1)   	= transpose(Rh_i(:,:,i))*alpha_h(:,:,i)+b(:,:,i)*q_dd(i)+cross(omega_h(:,:,i+1),b(:,:,i)*q_d(i));
            a_eh(:,:,i+1)      	= transpose(Rh_i(:,:,i))*a_eh(:,:,i)+cross(omega_d_h(:,:,i+1),r_h_i(:,i))+cross(omega_h(:,:,i+1),cross(omega_h(:,:,i+1),r_h_i(:,i)));
            a_ch(:,:,i+1)      	= transpose(Rh_i(:,:,i))*a_ch(:,:,i)+cross(omega_d_h(:,:,i+1),ri_h_ci(:,i))+cross(omega_h(:,:,i+1),cross(omega_h(:,:,i+1),ri_h_ci(:,i)));
        end

        % Backward Recursion (Link n to 1)
        for i = n:-1:1
            g_h(:,:,i+1)	= transpose(R0_i(:,:,i))*g_h(:,:,1);

            f(:,:,i)      	= Rh_i(:,:,i+1)*f(:,:,i+1)+m(i)*a_ch(:,:,i+1)-m(i)*g_h(:,:,i+1);
            tau(:,:,i)    	= Rh_i(:,:,i+1)*tau(:,:,i+1)-cross(f(:,:,i),ri_h_ci(:,i))+cross(omega_h(:,:,i+1),(It(:,:,i)*omega_h(:,:,i+1)))+It(:,:,i)*alpha_h(:,:,i+1);
        end

        tau_z(1,t+1) = tau(3,1,1);
        tau_z(2,t+1) = tau(3,1,2);
        tau_z(3,t+1) = tau(3,1,3);
        tau_z(4,t+1) = tau(3,1,4);
        tau_z(5,t+1) = tau(3,1,5);
        tau_z(6,t+1) = tau(3,1,6);

    end
        
    dispstat('Finished.','keepprev');

    plot_x = t_0:t_stp:t_end;
    plot_y = zeros(n,(t_end/t_stp)+1);
    for i = 1:n
        plot_y(i,:) = tau_z(i,:);
        subplot(n/2,2,i)
        plot(plot_x,plot_y(i,:))
        title(sprintf('Required Torque %d',i))
        xlabel('time [sec]')
        ylabel('torque [N*m]')
    end
    
	elapsedTime_torque = toc(timerVal2);
	elapsedTime_total = toc(timerVal1);
    
    fprintf('\nTotal computing time: %d min %d sec\n', round(elapsedTime_total/60), round(rem(elapsedTime_total,60)))
   
% end