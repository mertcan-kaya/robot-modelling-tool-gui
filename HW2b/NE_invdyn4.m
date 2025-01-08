% function tau = NE_invdyn(v,j,Ti_0)

clc
clear all
close all

timerVal1 = tic;

    %% Inputs

    % New symbolic inputs
    syms time

    n = 6;          % DoF [Don't change]
    
    omega       = ones(n,1);
    q_dd_sym    = zeros(n,1,'sym');
    q_d_sym     = zeros(n,1,'sym');
    q_sym       = zeros(n,1,'sym');
    
    for i = 1:n
        q_dd_sym(i,:)	= sin(omega(i)*time);
        q_d_sym(i,:)    = int(q_dd_sym(i));
        q_sym(i,:)      = int(q_d_sym(i));
    end
   	
    %% Plot Input
    
    subplot(3,1,1)
    q_dd_plot = subs(q_dd_sym(1,:),time,0:0.01:20);
    plot(0:0.01:20,q_dd_plot)
    title('q¨ = sin(t)')
    xlabel('time [sec]')
    ylabel('amplitude')
    subplot(3,1,2)
    q_d_plot = subs(q_d_sym(1,:),time,0:0.01:20);
    plot(0:0.01:20,q_d_plot)
    title('q^. = -cos(t)')
    xlabel('time [sec]')
    ylabel('amplitude')
    subplot(3,1,3)
    q_plot = subs(q_sym(1,:),time,0:0.01:20);
    plot(0:0.01:20,q_plot)
    title('q = -sin(t)')
    xlabel('time [sec]')
    ylabel('amplitude')
    
    %% Parameters    
    MDH_val = 0;    % Use 0 for DH, 1 for MDH Parameters
    v = 1;          % 1: UR5, 2: UR10, 3: RX160, 4: IRB 140
    sym = 0;
    
    t_0     = 0;    % initial time [s]
    t_end   = 20;  	% final time [s]
    t_stp   = 0.1;	% time step [s]
    
    g = 9.81;	% gravitational acceleration

    [m,ri_h_ci,It] = DynParameters(v,n);
    
    if MDH_val == 0
        [DH,~,~,~,~,~] = DHParameters(v,n);
    else
        [DH,~,~,~,~,~] = MDHParameters(v,n);
    end
    
    %%
    elapsedTime_initial = toc(timerVal1);
    timerVal2 = tic;

    dispstat('','init'); %one time only init 
    dispstat('Required torque:','keepthis');
    
    % Initial conditions
    omega_h         = zeros(3,1,n+1);
    omega_d_h       = zeros(3,1,n+1);
    alpha_h         = zeros(3,1,n+1);
    a_eh            = zeros(3,1,n+1);
    a_ch            = zeros(3,1,n+1);

    f               = zeros(3,1,n+1);
    norm            = zeros(3,1,n+1);
    tau             = zeros(3,1,n+1);
    tau_i           = zeros(n,3,(t_end/t_stp)+1);
    tau_z           = zeros(n,1,(t_end/t_stp)+1);
    g_h             = zeros(3,1,n+1);
    g_h(:,:,1)      = [0;0;-g];
        
    j = 0;
    for t = t_0:t_end/t_stp
        
        j = 1+j;
        dispstat(sprintf('Computing... %d%% (%d/%d)',round(100*j/(t_end/t_stp+1)),j,(t_end/t_stp)+1));
        
        q       = double(subs(q_sym,time,t*t_stp));
        q_d     = double(subs(q_d_sym,time,t*t_stp));
        q_dd    = double(subs(q_dd_sym,time,t*t_stp));
        
        d           = zeros(n,1);
        d_plus      = 1e-3*DH(:,3);
        theta       = q;
        theta_plus  = DH(:,4);
        a           = 1e-3*DH(:,1);
        alpha       = DH(:,2);

        [T0_i, A_i] = Transformation(d,d_plus,theta,theta_plus,a,alpha,MDH_val,sym);
        
        %% Actual Part

    %     Tsize = size(T0_i);
    %     n = Tsize(3);

        % Rotation matrices
        R0_i = zeros(3,3,n);
        Rh_i = zeros(3,3,n);

        for i=1:n
            R0_i(:,:,i) = T0_i(1:3,1:3,i);
            Rh_i(:,:,i) = A_i(1:3,1:3,i);
        end
        Rh_i(:,:,7) = zeros(3,3);

        % Displacement vector between current frame and previous frame
        r_h_i = zeros(3,1,n);
        for i=1:n
            r_h_i(:,:,i) = transpose(Rh_i(:,:,i))*A_i(1:3,4,i);
        end
        
        % Disp vector from end to CoG
        ri_i_ci = zeros(3,1,n);
        for i=1:n
            ri_i_ci(:,:,i) = ri_h_ci(:,i)+r_h_i(:,:,i);
        end
        
        % Unit vectors
        z_h = zeros(3,1,n);
        z_h(:,:,1) = [0;0;1];
        for i = 1:n-1
            z_h(:,:,i+1) = T0_i(1:3,3,i);
        end
        
        % Rotation axis for other joints
        b(:,:,1) = transpose(R0_i(:,:,1))*z_h(:,:,1);
        for i = 2:n
            b(:,:,i) = transpose(R0_i(:,:,i))*R0_i(:,:,i-1)*z_h(:,:,1);
        end
        
%         % Coordinates of origins
%         o_h(:,:,1) = zeros(3,1);
%         for i = 1:n
%             o_h(:,:,i+1) = T0_i(1:3,4,i);
%         end
        
        % Inertia matrix
        I = zeros(3,3,n);

        for i = 1:n
            I(:,:,i) = R0_i(:,:,i)*It(:,:,i)*transpose(R0_i(:,:,i));
        end
    
        % Forward Recursion (Link 1 to n)
        for i = 1:n
            omega_h(:,:,i+1)  	= transpose(Rh_i(:,:,i))*omega_h(:,:,i)+b(:,:,i)*q_d(i);
            omega_d_h(:,:,i+1)  = omega_d_h(:,:,i)+z_h(:,:,i)*q_dd(i)+cross(omega_h(:,:,i+1),(z_h(:,:,i)*q_d(i)));
            alpha_h(:,:,i+1) 	= transpose(Rh_i(:,:,i))*alpha_h(:,:,i)+b(:,:,i)*q_dd(i)+cross(omega_h(:,:,i+1),b(:,:,i)*q_d(i));
            a_eh(:,:,i+1)     	= transpose(Rh_i(:,:,i))*a_eh(:,:,i)+cross(omega_d_h(:,:,i+1),r_h_i(:,:,i))+cross(omega_h(:,:,i+1),cross(omega_h(:,:,i+1),r_h_i(:,:,i)));
            a_ch(:,:,i+1)     	= transpose(Rh_i(:,:,i))*a_ch(:,:,i)+cross(omega_d_h(:,:,i+1),ri_h_ci(:,i))+cross(omega_h(:,:,i+1),cross(omega_h(:,:,i+1),ri_h_ci(:,i)));
        end

        % Backward Recursion (Link n to 1)
        for i = n:-1:1
            g_h(:,:,i+1)	= transpose(R0_i(:,:,i))*g_h(:,:,1);

            f(:,:,i)      	= Rh_i(:,:,i+1)*f(:,:,i+1)+m(i)*a_ch(:,:,i+1)-m(i)*g_h(:,:,i+1);
            norm(:,:,i)     = Rh_i(:,:,i+1)*norm(:,:,i+1)-cross(f(:,:,i),ri_h_ci(:,i))+cross((Rh_i(:,:,i+1)*f(:,:,i+1)),ri_i_ci(:,:,i))+cross(omega_h(:,:,i+1),(I(:,:,i)*omega_h(:,:,i+1)))+I(:,:,i)*alpha_h(:,:,i+1);
            
            tau(:,:,i)      = transpose(norm(:,:,i))*b(:,:,i);
            tau_i(i,:,t+1)  = tau(:,:,i);
            tau_z(i,:,t+1)  = tau_i(i,3,t+1);
        end

  	end
        
    dispstat('Finished.','keepprev');

    plot_x = t_0:t_stp:t_end;
    plot_y = zeros(n,(t_end/t_stp)+1);
    for i = 1:n
        plot_y(i,:) = tau_z(i,:,:);
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