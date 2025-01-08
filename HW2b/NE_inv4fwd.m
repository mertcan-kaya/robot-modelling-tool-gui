function tau_i = NE_inv4fwd(q,q_d,q_dd,kappa,t_val,sym,v,n)

    MDH_val = 0;    % Use 0 for DH, 1 for MDH Parameters
%     v = 1;          % 1: UR5, 2: UR10, 3: RX160, 4: IRB 140
%     n = 6;
    
    t_0     = t_val(1);    % initial time [s]
    t_stp   = t_val(2);	% time step [s]
    t_end   = t_val(3);  	% final time [s]
    
    g = 9.81;	% gravitational acceleration

    [m,ri_h_ci,It] = DynParameters(v,n);

    if MDH_val == 0
        [DH,~,~,~,~,~] = DHParameters(v,n);
    else
        [DH,~,~,~,~,~] = MDHParameters(v,n);
    end
    
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
    g_h             = zeros(3,1,n);
    g_h(:,:,1)      = [0;0;-g];
    
    if sym == 1
        dispstat('','init'); %one time only init 
        dispstat('Required torque:','keepthis');

        syms time
        q_sym = q;
        q_d_sym = q_d;
        q_dd_sym = q_dd;
    else
    end
    
    j = 0;
    for t = t_0:t_end/t_stp
        
        j = 1+j;
        
        if sym == 1
            dispstat(sprintf('Computing... %d%% (%d/%d)',round(100*j/(t_end/t_stp+1)),j,(t_end/t_stp)+1));
            q       = double(subs(q_sym,time,t*t_stp));
            q_d     = double(subs(q_d_sym,time,t*t_stp));
            q_dd    = double(subs(q_dd_sym,time,t*t_stp));
        else
        end
        
        d           = zeros(n,1);
        d_plus      = 1e-3*DH(:,3);
        theta       = q;
        theta_plus  = DH(:,4);
        a           = 1e-3*DH(:,1);
        alpha       = DH(:,2);

        [T0_i, A_i] = Transformation(d,d_plus,theta,theta_plus,a,alpha,MDH_val,sym);
        
        %% Actual Part

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
        
    %     % Coordinates of origins
    %     o_h(:,:,1) = zeros(3,1);
    %     for i = 1:n
    %         o_h(:,:,i+1) = T0_i(1:3,4,i);
    %     end

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
            a_eh(:,:,i+1)     	= transpose(Rh_i(:,:,i))*a_eh(:,:,i)+cross(omega_d_h(:,:,i+1),r_h_i(:,i))+cross(omega_h(:,:,i+1),cross(omega_h(:,:,i+1),r_h_i(:,i)));
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
    
    if sym == 1
        
        dispstat('Finished.','keepprev');
        
        figure
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
    
    else
    end
    
end