function J = Jacobian(Ti_0,j)

    Tsize = size(Ti_0);
    n = Tsize(3);
    
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

    % Jacobian matrices of each link for their end
    for k = 1:n
        for i = 1:n
            % if current link smaller than or equal with last link else zero 
            if i <= k
                % if revoulte else prismatic
                if j(i)==0
                    Jv(:,i,k) = cross(z(:,:,i),(o(:,:,k+1)-o(:,:,i)));
                    Jw(:,i,k) = z(:,:,i);
                else
                    Jv(:,i,k) = z(:,:,i);
                    Jw(:,i,k) = zeros(3,1);
                end
            else
                Jv(:,i,k) = zeros(3,1);
                Jv(:,i,k) = zeros(3,1);
            end
        end
    end
    J = [Jv;Jw];
    
end