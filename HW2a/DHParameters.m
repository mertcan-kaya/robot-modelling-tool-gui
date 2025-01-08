function [DH,rm,dv,j,alpha_sym,theta_plus_sym] = DHParameters(v,n)

    rm	= {'UR5 (default)';
           'UR10';
           'Stäubli RX160';
           'ABB IRB 140';
           'Custom...'};
    
    dv = 1; % default value
    
    piOver2 = sym('pi')/2;
    
    switch (v)
        case 1
            % UR5
            % 0 for revolute joints, 1 for prismatic joints
            j = [0;0;0;0;0;0];
            % dist btw z_i-1 & z_i along x_i in mm
            a = [0;425;392.25;0;0;0];

            % angle from z_i-1 to z_i around x_i in rad
            alpha = [pi/2;0;0;pi/2;pi/2;0];
            alpha_sym = [piOver2;0;0;piOver2;piOver2;0];

            % dist btw x_i-1 & x_i along z_i-1 in mm
            d_plus = [89.16;0;0;109.15;94.65;82.3];

            % angle from x_i-1 to x_i around z_i-1 in rad
            theta_plus = [pi;pi/2;0;pi/2;pi;0];
            theta_plus_sym = [pi;piOver2;0;piOver2;pi;0];
        case 2
            % UR10
            % 0 for revolute joints, 1 for prismatic joints
            j = [0;0;0;0;0;0];
            % dist btw z_i-1 & z_i along x_i in mm
            a = [0;612.7;571.6;0;0;0];

            % angle from z_i-1 to z_i around x_i in rad
            alpha = [pi/2;0;0;pi/2;pi/2;0];
            alpha_sym = [piOver2;0;0;piOver2;piOver2;0];

            % dist btw x_i-1 & x_i along z_i-1 in mm
            d_plus = [128;0;0;163.9;115.7;92.2];

            % angle from x_i-1 to x_i around z_i-1 in rad
            theta_plus = [pi;pi/2;0;pi/2;pi;0];
            theta_plus_sym = [pi;piOver2;0;piOver2;pi;0];
        case 3
            % Stäubli RX160
            % 0 for revolute joints, 1 for prismatic joints
            j = [0;0;0;0;0;0];
            % dist btw z_i-1 & z_i along x_i in mm
            a = [150;825;0;0;0;0];

            % angle from z_i-1 to z_i around x_i in rad
            alpha = [-pi/2;0;pi/2;pi/2;pi/2;0];
            alpha_sym = [-piOver2;0;piOver2;piOver2;piOver2;0];

            % dist btw x_i-1 & x_i along z_i-1 in mm
            d_plus = [550;0;0;625;0;110];

            % angle from x_i-1 to x_i around z_i-1 in rad
            theta_plus = [0;-pi/2;pi/2;pi;pi;0];
            theta_plus_sym = [0;-piOver2;piOver2;pi;pi;0];
        case 4
            % ABB IRB 140 Robot
            % 0 for revolute joints, 1 for prismatic joints
            j = [0;0;0;0;0;0];
            % dist btw z_i-1 & z_i along x_i in mm
            a = [70;360;0;0;0;0];

            % angle from z_i-1 to z_i around x_i in rad
            alpha = [-pi/2;0;pi/2;pi/2;pi/2;0];
            alpha_sym = [-piOver2;0;piOver2;piOver2;piOver2;0];

            % dist btw x_i-1 & x_i along z_i-1 in mm
            d_plus = [352;0;0;380;0;65];

            % angle from x_i-1 to x_i around z_i-1 in rad
            theta_plus = [0;-pi/2;pi;pi;pi;0];
            theta_plus_sym = [0;-piOver2;pi;pi;pi;0];
        otherwise
            j               = [0;0;0;0;0;0];
            a               = zeros(n,1);
            alpha           = zeros(n,1);
            alpha_sym       = zeros(n,1);
            d_plus          = zeros(n,1);
            theta_plus      = zeros(n,1);
            theta_plus_sym  = zeros(n,1);
    end

    DH = [a alpha d_plus theta_plus];
        
end