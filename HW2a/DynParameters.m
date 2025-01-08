function [m,ri_h_ci,It] = DynParameters(v,n)
    
    switch (v)
        case 1
            % UR5
            
            % Mass [kg]
            m(1) = 3.7;
            m(2) = 8.393;
            m(3) = 2.275;
            m(4) = 1.219;
            m(5) = 1.219;
            m(6) = 0.1879;
            
            % Center of mass from next origin (Corrected for my DH) [m]
            ri_h_ci(:,1) = 1e-3*[0          ;-25.61	;1.93	];
            ri_h_ci(:,2) = 1e-3*[-212.5     ;0      ;113.36	];
            ri_h_ci(:,3) = 1e-3*[-119.93	;0      ;26.5   ];
            ri_h_ci(:,4) = 1e-3*[0          ;-1.8   ;16.34 	];
            ri_h_ci(:,5) = 1e-3*[0          ;-1.8  	;16.34 	];
            ri_h_ci(:,6) = 1e-3*[0          ;0      ;-1.159 ];
            
            % Center of mass from previous origin w.r.t next CF [m]
            ri_i_ci(:,1) = 1e-3*[0     	;63.39	;1.93	];
            ri_i_ci(:,2) = 1e-3*[212.5	;0      ;113.36	];
            ri_i_ci(:,3) = 1e-3*[272.32	;0      ;26.5   ];
            ri_i_ci(:,4) = 1e-3*[0     	;107.35 ;16.34 	];
            ri_i_ci(:,5) = 1e-3*[0     	;92.85 	;16.34 	];
            ri_i_ci(:,6) = 1e-3*[0     	;0      ;81.141 ];
            
            % Inertia tensors (approximated)
            It(:,:,1) = diag([0.0084 0.0064 0.0084]);
            It(:,:,2) = diag([0.0078 0.2100 0.2100]);
            It(:,:,3) = diag([0.0016 0.0462 0.0462]);
            It(:,:,4) = diag([0.0016 0.0016 0.0009]);
            It(:,:,5) = diag([0.0016 0.0016 0.0009]);
            It(:,:,6) = diag([0.0001 0.0001 0.0001]);
            
        case 2
            % UR10
            
            % Mass [kg]
            m(1) = 7.1;
            m(2) = 12.7;
            m(3) = 4.27;
            m(4) = 2;
            m(5) = 2;
            m(6) = 0.365;
            
            % Center of mass [m]
            ri_h_ci(:,1) = 1e-3*[21     ;0  	;27     ];
            ri_h_ci(:,2) = 1e-3*[380 	;0      ;158	];
            ri_h_ci(:,3) = 1e-3*[240  	;0      ;68     ];
            ri_h_ci(:,4) = 1e-3*[0     	;7      ;18 	];
            ri_h_ci(:,5) = 1e-3*[0    	;7      ;18 	];
            ri_h_ci(:,6) = 1e-3*[0     	;0      ;-26	];
            
            % Inertia tensors (approximated)
            It(:,:,1) = diag([0.0315 0.0315 0.0219]);
            It(:,:,2) = diag([0.4218 0.4218 0.0364]);
            It(:,:,3) = diag([0.1111 0.1111 0.0109]);
            It(:,:,4) = diag([0.0051 0.0051 0.0055]);
            It(:,:,5) = diag([0.0051 0.0051 0.0055]);
            It(:,:,6) = diag([0.0005 0.0005 0.0006]);
            
%             link name="base_link"
%             mass value="4.0"
%             inertia ixx="0.0061063308908" ixy="0.0" ixz="0.0" iyy="0.0061063308908" iyz="0.0" izz="0.01125"
%             link name="shoulder_link"
%             mass value="7.778"
%             ixx="0.0314743125769" ixy="0.0" ixz="0.0" iyy="0.0314743125769" iyz="0.0" izz="0.021875625"
%             link name="upper_arm_link"
%             mass value="12.93"
%             inertia ixx="0.421753803798" ixy="0.0" ixz="0.0" iyy="0.421753803798" iyz="0.0" izz="0.036365625"
%             link name="forearm_link"
%             mass value="3.87"
%             inertia ixx="0.111069694097" ixy="0.0" ixz="0.0" iyy="0.111069694097" iyz="0.0" izz="0.010884375"
%             link name="wrist_1_link"
%             mass value="1.96"
%             inertia ixx="0.0051082479567" ixy="0.0" ixz="0.0" iyy="0.0051082479567" iyz="0.0" izz="0.0055125"
%             link name="wrist_2_link"
%             mass value="1.96"
%             inertia ixx="0.0051082479567" ixy="0.0" ixz="0.0" iyy="0.0051082479567" iyz="0.0" izz="0.0055125"
%             link name="wrist_3_link"
%             mass value="0.202"
%             inertia ixx="0.000526462289415" ixy="0.0" ixz="0.0" iyy="0.000526462289415" iyz="0.0" izz="0.000568125"
            
        case 3
            % Stäubli RX160
            
            % Parameters are removed due to confidentialy

        case 4
            % ABB IRB 140
            
            % Mass [kg]
            m(1) = 27;
            m(2) = 22;
            m(3) = 0;
            m(4) = 25;
            m(5) = 0;
            m(6) = 1;
                        
            % Center of mass from previous CF origin w.r.t CF of current link [m]
            ri_h_ci(:,1) = [0.014	;-0.264	;0.067  ];
            ri_h_ci(:,2) = [0.201	;0      ;-0.07  ];
            ri_h_ci(:,3) = [0       ;0      ;0      ];
            ri_h_ci(:,4) = [0       ;0.080  ;0      ];
            ri_h_ci(:,5) = [0    	;0      ;0      ];
            ri_h_ci(:,6) = [0    	;0      ;0.029  ];
    
%             % Distance between previous CF and CF of current link [m]
%             r_h_i(:,1) = [0.070	;-0.352	;0      ];
%             r_h_i(:,2) = [0.360	;0      ;0      ];
%             r_h_i(:,3) = [0       ;0      ;0      ];
%             r_h_i(:,4) = [0       ;0.380  ;0      ];
%             r_h_i(:,5) = [0    	;0      ;0      ];
%             r_h_i(:,6) = [0    	;0      ;0.065	];
           	
            % Radius [m]
            r(1) = 0.147;
            r(2) = 0.108;
            r(3) = 0;
            r(4) = 0.094;
            r(5) = 0;
            r(6) = 0.054;
            
            % Height [m]
            h(1) = 0.264;
            h(2) = 0.402;
            h(3) = 0;
            h(4) = 0.6;
            h(5) = 0;
            h(6) = 0.072;
            
            % Inertia tensors (cylindercal)
            for i = 1:6
                Ixx(i) = (1/12)*m(i)*h(i)^2+(1/4)*m(i)*r(i)^2;
                Iyy(i) = (1/12)*m(i)*h(i)^2+(1/4)*m(i)*r(i)^2;
                Izz(i) = (1/2)*m(i)*r(i)^2;
                It(:,:,i) = diag([Ixx(i) Iyy(i) Izz(i)]);
            end
            
        otherwise
            
            m   	= zeros(n,1);
            ri_h_ci	= zeros(3,n);
            It    	= zeros(3,3,n);
            
    end
    
end