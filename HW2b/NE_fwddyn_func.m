function NE_fwddyn_func(v,n,t_val)

    % Comptute N and D matrices
    
    sym = 0;

    % Compute N(q,q_d) vector with givin q_dd = 0
    q_dd    = zeros(n,1);
    q_d     = zeros(n,1);
    q       = zeros(n,1);
    kappa   = zeros(n,1);

        t_0     = 0;    % initial time [s]
        t_stp   = 1;	% time step [s]
        t_end   = 0;  	% final time [s]

        t_val1 = [t_0;t_stp;t_end];

    tau = NE_inv4fwd(q,q_d,q_dd,kappa,t_val1,sym,v,n);

    N = zeros(n,1);
    for i=1:n
        N(i,:) = tau(i,3);
    end

    D = zeros(n,n);
    for i=1:n
        q_dd = zeros(n,1);
        q_dd(i,:) = 1;

        tau = NE_inv4fwd(q,q_d,q_dd,kappa,t_val1,sym,v,n);

        for j=1:n
            D(j,i) = tau(j,3);
        end

    end

    %% Inputs

    % New symbolic inputs
    syms time

    omega       = ones(n,1);
    q_dd_sym    = zeros(n,1,'sym');
    q_d_sym     = zeros(n,1,'sym');
    q_sym       = zeros(n,1,'sym');
    kappa       = 0;

    for i = 1:n
        q_dd_sym(i,1)	= sin(omega(i)*time);
        q_d_sym(i,1)    = int(q_dd_sym(i));
        q_sym(i,1)      = int(q_d_sym(i));
    end

    t_0     = t_val(1);     % initial time [s]
    t_stp   = t_val(2);     % time step [s]
    t_end   = t_val(3);  	% final time [s]

    %% Plot Input
    figure
    subplot(3,1,1)
    q_dd_plot = subs(q_dd_sym(1,:),time,t_0:t_stp:t_end);
    plot(t_0:t_stp:t_end,q_dd_plot)
    title('q¨ = sin(t)')
    xlabel('time [sec]')
    ylabel('amplitude')

    subplot(3,1,2)
    q_d_plot = subs(q_d_sym(1,:),time,t_0:t_stp:t_end);
    plot(t_0:t_stp:t_end,q_d_plot)
    title('q^. = -cos(t)')
    xlabel('time [sec]')
    ylabel('amplitude')

    subplot(3,1,3)
    q_plot = subs(q_sym(1,:),time,t_0:t_stp:t_end);
    plot(t_0:t_stp:t_end,q_plot)
    title('q = -sin(t)')
    xlabel('time [sec]')
    ylabel('amplitude')

    %% The rest
    sym = 1;

    tau = NE_inv4fwd(q_sym,q_d_sym,q_dd_sym,kappa,t_val,sym,v,n);

    tau_z = tau(:,3,:);

    timerVal3 = tic;

    j = 0;
    
    q_dd_num = zeros(n,(t_end/t_stp)+1);
    for t = t_0:t_end/t_stp
        j = 1+j;
        q_dd_num(:,j) = D\(tau_z(:,:,j)-N);
    end

    elapsedTime3 = toc(timerVal3);

    plot_x = t_0:t_stp:t_end;

    fprintf('\nIntagrating acceleration:\n');

    q_d_num = zeros(n,(t_end/t_stp)+1);
    for i = 1:n
        q_d_num(i,:) = cumtrapz(plot_x,q_dd_num(i,:));
    end

    disp('First integral done.');

    q_num = zeros(n,(t_end/t_stp)+1);
    for i = 1:n
        q_num(i,:) = cumtrapz(plot_x,q_d_num(i,:));
    end

    disp('Second integral done.');

    figure
    for i = 1:n
        subplot(n/2,2,i)
        plot(plot_x,q_dd_num(i,:),plot_x,q_d_num(i,:),plot_x,q_num(i,:))
        title(sprintf('Desired Trajectory %d',i))
        xlabel('time [sec]')
        ylabel('Amplitude')
        legend('q_dd','q_d','q')
    end

end