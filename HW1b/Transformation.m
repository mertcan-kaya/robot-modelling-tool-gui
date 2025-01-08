function Ti_0 = Transformation(d,d_plus,theta,theta_plus,a,alpha)

    n = length(d);
    
    for i=1:n
        
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

end