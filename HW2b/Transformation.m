function [T0_i, A_i] = Transformation(d,d_plus,theta,theta_plus,a,alpha,MDH_val,sym)

    n = length(d);
    
%     if MDH_val == 0
%         % A_i = % Trn_(z_(i-1),d_i)*Rot_(z_(i-1),theta_i)*Trn_(x_i,a_i)*Rot_(x_i,alpha_i)
%         n = length(d);
%     else
%         % A_i = % Rot_(x_(i-1),alpha_(i-1)*Trn_(x_(i-1),a_(i-1)*Rot_(z_i,theta_i)*Trn_(z_i,d_i)
%         n = length(d)+1;
%     end
    
    if sym == 0
        trnZ_x  = zeros(4,4,n);
        rotZ_x  = zeros(4,4,n);
        trnX_i  = zeros(4,4,n);
        rotX_i  = zeros(4,4,n);

        A_i     = zeros(4,4,n);
    else
        trnZ_x  = zeros(4,4,n,'sym');
        rotZ_x  = zeros(4,4,n,'sym');
        trnX_i  = zeros(4,4,n,'sym');
        rotX_i  = zeros(4,4,n,'sym');

        A_i     = zeros(4,4,n,'sym');
    end
    
    for i=1:n
        
        % Trans_z_x (x = i if DH, x = h if MDH)
        trnZ_x(:,:,i)	= [ 1 0 0 0;
                            0 1 0 0
                            0 0 1 d(i)+d_plus(i)
                            0 0 0 1 ];

        % Rot_z_x (x = i if DH, x = h if MDH)
        rotZ_x(:,:,i)   = [ cos(theta(i)+theta_plus(i))	-sin(theta(i)+theta_plus(i))	0	0
                            sin(theta(i)+theta_plus(i))	 cos(theta(i)+theta_plus(i))	0	0
                            0                          	 0                          	1	0
                            0                          	 0                           	0	1 ];

        % Trans_x_i
        trnX_i(:,:,i)   = [ 1 0 0 a(i)
                            0 1 0 0
                            0 0 1 0
                            0 0 0 1 ];

        % Rot_x_i
        rotX_i(:,:,i)   = [ 1	0               0               0
                            0	cos(alpha(i))  -sin(alpha(i))	0
                            0	sin(alpha(i))	cos(alpha(i))	0
                            0	0               0               1 ];

        if MDH_val == 0
            trnZ_h = trnZ_x;
            rotZ_h = rotZ_x;
            
            % A_i = % Trn_(z_(i-1),d_i)*Rot_(z_(i-1),theta_i)*Trn_(x_i,a_i)*Rot_(x_i,alpha_i)
            A_i(:,:,i) = trnZ_h(:,:,i)*rotZ_h(:,:,i)*trnX_i(:,:,i)*rotX_i(:,:,i);
        else
            trnZ_i = trnZ_x;
            rotZ_i = rotZ_x;
            
            % A_i = % Rot_(x_(i-1),alpha_(i-1)*Trn_(x_(i-1),a_(i-1)*Rot_(z_i,theta_i)*Trn_(z_i,d_i)
            A_i(:,:,i) = rotX_i(:,:,i)*trnX_i(:,:,i)*rotZ_i(:,:,i)*trnZ_i(:,:,i);
        end
        
    end
    
    % Transformation n to 0
    T0_i(:,:,1) = A_i(:,:,1);
    for i = 1:n-1
        T0_i(:,:,i+1) = T0_i(:,:,i)*A_i(:,:,i+1);
    end

end