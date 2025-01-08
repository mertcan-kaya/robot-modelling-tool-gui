function [C,C_sym] = Cblock(v,q,q_d)  % add necessary inputs and outputs

    syms q1 q2 q3 q4 q5 q6
    syms q1_d q2_d q3_d q4_d q5_d q6_d
    syms q1_dd q2_dd q3_dd q4_dd q5_dd q6_dd
    
    q_sym       = [q1;q2;q3;q4;q5;q6];
    q_d_sym     = [q1_d;q2_d;q3_d;q4_d;q5_d;q6_d];
    q_dd_sym	= [q1_dd;q2_dd;q3_dd;q4_dd;q5_dd;q6_dd];
    
    n = 6;
    
    [~,D_sym] = Dblock(v,q);
        
    % Christoffel symbols
    c = zeros(n,n,n,'sym');
    
    for k = 1:n
        for j = 1:n
            for i = 1:n
                c(i,j,k) = (1/2)*( diff(D_sym(k,j),q_sym(i)) + diff(D_sym(k,i),q_sym(j)) - diff(D_sym(i,j),q_sym(k)) );
            end
        end
    end
    
    % Christoffel Matrix
    C = zeros(n,n,'sym');
    
    for k = 1:n
        for j = 1:n
            for i = 1:n
                C(k,j) = C(k,j)+c(i,j,k)*q_d_sym(i);
            end
        end
    end
    C_sym = simplify(C);
    
    C = double(subs(C_sym,[q_sym q_d_sym],[q q_d]));
%     C = C_sym;
    
end