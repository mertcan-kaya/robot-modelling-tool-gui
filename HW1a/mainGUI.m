function mainGUI
%%
evalin('base', 'clearvars');
clc
clear
close all

%% Initializing some global variables and flags
        
    q1 = [];
    q2 = [];
    q3 = [];
    q4 = [];
    q5 = [];
    q6 = [];
    phi = [];
    the = [];
    psi = [];

    % Symbolic angle variables
    syms q1 q2 q3 q4 q5 q6 phi the psi
            
    % Link number
    n = 6;
    
    % Initial values
    a           = zeros(n,1);
    alpha       = zeros(n,1);
    d           = zeros(n,1);
    theta_plus	= zeros(n,1);
    theta = zeros(n,1);

    trnZ        = zeros(4,4,n);
    rotZ        = zeros(4,4,n);
    trnX        = zeros(4,4,n);
    rotX        = zeros(4,4,n);

    A           = zeros(4,4,n);

    dh = [a alpha d theta_plus];
               
    % Transformation n to 0
    Ti_0 = zeros(4,4,n);
    
    J = zeros(6,n);
    Ja = zeros(6,n);
    
    q1Store = 0;
    q2Store = 0;
    q3Store = 0;
    q4Store = 0;
    q5Store = 0;
    q6Store = 0;
    
    %% GUI setup
    % Figure is invisible until setup is complete
    robotModels = ['UR5           '
                   'UR10 (default)'
                   'Stäubli RX160 '
                   'Stäubli RX160L'];

    w = 380;
    h = 350;

    mainFig = figure('Visible',     'on', ...
                     'MenuBar',     'none', ...
                     'NumberTitle', 'off', ...
                     'Name',        'Robot Modeling Tool GUI v1a', ...
                     'Resize',      'off', ...
                     'Position',    [500 250 w h]);

    pad = 11;
    h1_2 = h-320;

    b3 = pad;
    h3 = 24;
    b2 = h3-4+2*pad;
    h2 = (h-h1_2)-2*(h3+2*pad+11);
    b1 = h1_2+h3+h2-2+3*pad;
    h1 = 50;

    panel(1) = uipanel('Visible',       'off', ...
                       'Parent',        mainFig, ...
                       'BorderType',    'etchedin', ...
                       'Title',         'Choose robot', ...
                       'Units',         'pixels', ...
                       'Position',      [pad b1 w-2*(pad-1) h1]);

    dhname = 'Standard DH table';

    panel(2) = uipanel('Visible',       'off', ...
                       'Parent',        mainFig, ...
                       'BorderType',    'etchedin', ...
                       'Title',         dhname, ...
                       'Units',         'pixels', ...
                       'Position',      [pad b2 w-2*(pad-1) h2]);

    panel(3) = uipanel('Visible',       'off', ...
                       'Parent',        mainFig, ...
                       'BorderType',    'none', ...
                       'Units',         'pixels', ...
                       'Position',      [pad b3 w-2*(pad-1) h3]);

    % Panel 1 ---------------------------------------------------------------
    handles.radio(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(1), ...
                                    'Units',                'pixels', ...
                                    'Position',             [9 13 65 13], ...
                                    'String',               'Custom', ...
                                    'HorizontalAlignment',  'center', ...
                                    'Callback',             @myRadio, ...
                                    'Value',                1);

    handles.radio(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(1), ...
                                    'Units',                'pixels', ...
                                    'Position',             [170 13 65 13], ...
                                    'String',               'Preset', ...
                                    'HorizontalAlignment',  'center', ...
                                    'Callback',             @myRadio, ...
                                    'Value',                0);

    guidata(mainFig, handles);

    modelList           = uicontrol('Style',                'popupmenu', ...
                                    'Parent',               panel(1), ...
                                    'Units',                'pixels', ...
                                    'Position',             [238 9 108 22], ...
                                    'BackgroundColor',      [1 1 1], ...
                                    'String',               robotModels, ...
                                    'HorizontalAlignment',  'center', ...
                                    'Callback',             @modelListCallback, ...
                                    'Value',                2, ...
                                    'Enable',               'off');

    clearButton         = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panel(1), ...
                                    'Units',                'pixels', ...
                                    'Position',             [80 8 65 23], ...
                                    'String',               'Clear', ...
                                    'HorizontalAlignment',  'center', ...
                                    'Callback',             @clearButtonCallback, ...
                                    'Enable',               'on');

    % Between Pane 1 and Panel 2 --------------------------------------------
    dhText              = uicontrol('Style',                'text', ...
                                    'Parent',               mainFig, ...
                                    'Units',                'pixels', ...
                                    'Position',             [9 b2+h2+5 80 22], ...
                                    'String',               'DH parameters:', ...
                                    'HorizontalAlignment',	'left', ...
                                    'Visible',              'off');

    handles.dhpara(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               mainFig, ...
                                    'Units',                'pixels', ...
                                    'Position',             [93 b2+h2+13 65 13], ...
                                    'String',               'Standard', ...
                                    'HorizontalAlignment',  'center', ...
                                    'Callback',             @dhparaCallback, ...
                                    'Value',                1, ...
                                    'Visible',              'off');

    handles.dhpara(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               mainFig, ...
                                    'Units',                'pixels', ...
                                    'Position',             [170 b2+h2+13 65 13], ...
                                    'String',               'Modified', ...
                                    'HorizontalAlignment',  'center', ...
                                    'Callback',             @dhparaCallback, ...
                                    'Value',                0, ...
                                    'Visible',              'off');

    guidata(mainFig, handles);

    % Panel 2 ---------------------------------------------------------------
    linkNumText = uicontrol('Style',                'text', ...
                            'Parent',               panel(2), ...
                            'Units',                'pixels', ...
                            'Position',             [9 160 80 22], ...
                            'String',               'Number of links:', ...
                            'HorizontalAlignment',	'left');

    nLinkButton = uicontrol('Style',                'pushbutton', ...
                            'Parent',               panel(2), ...
                            'Units',                'pixels', ...
                            'Position',             [100 164 22 22], ...
                            'String',               '-', ...
                            'HorizontalAlignment',  'center', ...
                            'Callback',             @nLinkButtonCallback, ...
                            'Enable',               'on');

    pLinkButton = uicontrol('Style',                'pushbutton', ...
                            'Parent',               panel(2), ...
                            'Units',                'pixels', ...
                            'Position',             [138 164 22 22], ...
                            'String',               '+', ...
                            'HorizontalAlignment',  'center', ...
                            'Callback',             @pLinkButtonCallback, ...
                            'Enable',               'off');

    linkEdit = uicontrol('Style',                   'edit', ...
                         'Parent',                  panel(2), ...
                         'Units',                   'pixels', ...
                         'Position',                [120 165 20 20], ...
                         'String',                  n, ...
                         'HorizontalAlignment',     'center', ...
                         'Callback',                @linkEditCallback);

    symCheckbox = uicontrol('Style',                'checkbox', ...
                            'Parent',               panel(2), ...
                            'Units',                'pixels', ...
                            'Position',             [180 164 70 22], ...
                            'String',               'Symbolic', ...
                            'HorizontalAlignment',  'left', ...
                            'Callback',             @symCheckboxCallback, ...
                            'Enable',               'on');
                        
    handles.degrad(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(2), ...
                                    'Units',                'pixels', ...
                                    'Position',             [265 168 65 13], ...
                                    'String',               'rad', ...
                                    'HorizontalAlignment',  'center', ...
                                    'Callback',             @degradCallback, ...
                                    'Value',                1);

    handles.degrad(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(2), ...
                                    'Units',                'pixels', ...
                                    'Position',             [310 168 65 13], ...
                                    'String',               'deg', ...
                                    'HorizontalAlignment',  'center', ...
                                    'Callback',             @degradCallback, ...
                                    'Value',                0);

    guidata(mainFig, handles);

    if verLessThan('matlab','9.0')
        % -- Code to run in MATLAB R2015b and earlier here --
        cName = {'a_i', 'alpha_i', 'd_i', 'theta_i'};
    else
        % -- Code to run in MATLAB R2016a and later here --
        cName = {'a_i', sprintf('\x3b1_i'), 'd_i', sprintf('\x3b8_i')};
    end

    link = {' 1 ' ' 2 ' ' 3 ' ' 4 ' ' 5 ' ' 6 '};

    dhtable = uitable('Data',           dh, ...
                      'ColumnName',     cName, ...
                      'ColumnWidth',    {60 60 60 60}, ...
                      'RowName',        link(1:n), ...
                      'ColumnEditable', true(1,4), ...
                      'Units',          'pixels', ...
                      'Position',       [10 10 295 145], ...
                      'Parent',         panel(2));

    linkText = uicontrol('Style',                'text', ...
                         'Parent',               panel(2), ...
                         'Units',                'pixels', ...
                         'Position',             [22 135 25 15], ...
                         'String',               'Link', ...
                         'HorizontalAlignment',	 'left');

    linkText = uicontrol('Style',                'text', ...
                         'Parent',               panel(2), ...
                         'Units',                'pixels', ...
                         'Position',             [323 135 25 15], ...
                         'String',               'q_i', ...
                         'HorizontalAlignment',	 'left');

    w_e = 38;
    h_e = 17;
    l_e = 312;
    b_e = 27;

    q1Edit = uicontrol('Style',                   'edit', ...
                       'Parent',                  panel(2), ...
                       'Units',                   'pixels', ...
                       'Position',                [l_e b_e+5*(h_e+1) w_e h_e], ...
                       'String',                  0, ...
                       'HorizontalAlignment',     'center', ...
                       'Callback',                @q1EditCallback);

    q2Edit = uicontrol('Style',                   'edit', ...
                       'Parent',                  panel(2), ...
                       'Units',                   'pixels', ...
                       'Position',                [l_e b_e+4*(h_e+1) w_e h_e], ...
                       'String',                  0, ...
                       'HorizontalAlignment',     'center', ...
                       'Callback',                @q2EditCallback);

    q3Edit = uicontrol('Style',                   'edit', ...
                       'Parent',                  panel(2), ...
                       'Units',                   'pixels', ...
                       'Position',                [l_e b_e+3*(h_e+1) w_e h_e], ...
                       'String',                  0, ...
                       'HorizontalAlignment',     'center', ...
                       'Callback',                @q3EditCallback);

    q4Edit = uicontrol('Style',                   'edit', ...
                       'Parent',                  panel(2), ...
                       'Units',                   'pixels', ...
                       'Position',                [l_e b_e+2*(h_e+1) w_e h_e], ...
                       'String',                  0, ...
                       'HorizontalAlignment',     'center', ...
                       'Callback',                @q4EditCallback);

    q5Edit = uicontrol('Style',                   'edit', ...
                       'Parent',                  panel(2), ...
                       'Units',                   'pixels', ...
                       'Position',                [l_e b_e+h_e+1 w_e h_e], ...
                       'String',                  0, ...
                       'HorizontalAlignment',     'center', ...
                       'Callback',                @q5EditCallback);

    q6Edit = uicontrol('Style',                   'edit', ...
                       'Parent',                  panel(2), ...
                       'Units',                   'pixels', ...
                       'Position',                [l_e b_e w_e h_e], ...
                       'String',                  0, ...
                       'HorizontalAlignment',     'center', ...
                       'Callback',                @q6EditCallback);

    % Panel 3 ---------------------------------------------------------------
    tn_0Button = uicontrol('Style',                     'pushbutton', ...
                               'Parent',                panel(3), ...
                               'Units',                 'pixels', ...
                               'Position',              [0 0 75 23], ...
                               'String',                'Tn_0', ...
                               'HorizontalAlignment',   'center', ...
                               'Callback',              @(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                        {@(h,e)tn_0ButtonCallback(h), ...
                                                        @(h,e)tn_0ButtonPrintCallback(h)})));

    jacobianButton = uicontrol('Style',                 'pushbutton', ...
                               'Parent',                panel(3), ...
                               'Units',                 'pixels', ...
                               'Position',              [75+7 0 78 23], ...
                               'String',                'Jacobian', ...
                               'HorizontalAlignment',   'center', ...
                               'Callback',              @(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                        {@(h,e)jacobianButtonCallback(h), ...
                                                        @(h,e)jacobianButtonPrintCallback(h)})));

    aJacobianButton = uicontrol('Style',              	'pushbutton', ...
                                'Parent',             	panel(3), ...
                                'Units',              	'pixels', ...
                                'Position',             [75+78+14 0 90 23], ...
                                'String',             	'A. Jacobian', ...
                                'HorizontalAlignment',	'center', ...
                                'Callback',           	@(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                        {@(h,e)aJacobianButtonCallback(h), ...
                                                        @(h,e)aJacobianButtonPrintCallback(h)})), ...
                                'Enable',             	'on');

    openRoboDKButton = uicontrol('Style',               'pushbutton', ...
                                'Parent',              	panel(3), ...
                                'Units',               	'pixels', ...
                                'Position',            	[75+78+90+3*7 0 97 23], ...
                                'String',              	'Open RoboDK', ...
                                'HorizontalAlignment', 	'center', ...
                                'Callback',            	@openRoboDKButtonCallback, ...
                                'Enable',               'on');

    set(panel(1), 'Visible', 'on');
    set(dhText, 'Visible', 'on');
    set(handles.dhpara(1), 'Visible', 'on');
    set(handles.dhpara(2), 'Visible', 'on');
    set(panel(2), 'Visible', 'on');
    set(panel(3), 'Visible', 'on');

%% myRadioCallback
    function myRadio(RadioH,~)

        handles = guidata(RadioH);
        otherRadio = handles.radio(handles.radio ~= RadioH);
        sameRadio = handles.radio(handles.radio == RadioH);

        % This selects one and deselects other
        set(otherRadio, 'Value', 0);
        set(sameRadio, 'Value', 1);

        % This is value of the selected
        radioVal = get(handles.radio(1), 'Value');

        % This activates the selection
        if radioVal==0
            n = 6;
            modelListCallback(get(modelList, 'Value'));
            set(modelList, 'Enable', 'on');
            set(dhtable, 'Enable', 'off');
            set(nLinkButton, 'Enable', 'off');
            set(pLinkButton, 'Enable', 'off');
            set(linkEdit, 'Enable', 'off');
            set(linkEdit, 'String', n);
        else
            set(modelList, 'Enable', 'off');
            set(dhtable, 'Enable', 'on');
            if n == 1
                set(nLinkButton, 'Enable', 'off');
            else
                set(nLinkButton, 'Enable', 'on');
            end
            if n == 6
                set(pLinkButton, 'Enable', 'off');
            else
                set(pLinkButton, 'Enable', 'on');
            end
            set(linkEdit, 'Enable', 'on');
        end

    end

%% clearButtonCallback
    function clearButtonCallback(~,~)

        dh = zeros(n,4);

        set(handles.radio(1), 'Value', 1);
        set(handles.radio(2), 'Value', 0);
        set(modelList, 'Enable', 'off');
        set(dhtable, 'Enable', 'on');
        set(dhtable, 'Data', dh);
        if n == 1
            set(nLinkButton, 'Enable', 'off');
        else
            set(nLinkButton, 'Enable', 'on');
        end
        if n == 6
            set(pLinkButton, 'Enable', 'off');
        else
            set(pLinkButton, 'Enable', 'on');
        end
        set(linkEdit, 'Enable', 'on');
        set(dhtable, 'RowName', link(1:n));

    end

%% modelListCallback
    function modelListCallback(~,~)

        modelListVal = get(modelList, 'Value');

        switch (modelListVal)
            case 1
                % UR5
                % dist btw z_i-1 & z_i along x_i in mm
                a = [0;425;392.25;0;0;0];

                % angle from z_i-1 to z_i around x_i in deg
                alpha_deg = [90;0;0;90;90;0];
                alpha = deg2rad(alpha_deg); % converts deg to rad

                % dist btw x_i-1 & x_i along z_i-1 in mm
                d = [89.16;0;0;109.15;94.65;82.3];

                % angle from x_i-1 to x_i around z_i-1 in deg
                theta_plus_deg = [180;90;0;90;180;0];
                theta_plus = deg2rad(theta_plus_deg); % converts deg to rad
            case 2
                % UR10
                % dist btw z_i-1 & z_i along x_i in mm
                a = [0;612.7;571.6;0;0;0];

                % angle from z_i-1 to z_i around x_i in deg
                alpha_deg = [90;0;0;90;90;0];
                alpha = deg2rad(alpha_deg); % converts deg to rad

                % dist btw x_i-1 & x_i along z_i-1 in mm
                d = [128;0;0;163.9;115.7;92.2];

                % angle from x_i-1 to x_i around z_i-1 in deg
                theta_plus_deg = [180;90;0;90;180;0];
                theta_plus = deg2rad(theta_plus_deg); % converts deg to rad
            case 3
                % Stäubli RX160
                % dist btw z_i-1 & z_i along x_i in mm
                a = [150;825;0;0;0;0];

                % angle from z_i-1 to z_i around x_i in deg
                alpha_deg = [-90;0;90;90;90;0];
                alpha = deg2rad(alpha_deg); % converts deg to rad

                % dist btw x_i-1 & x_i along z_i-1 in mm
                d = [550;0;0;625;0;110];

                % angle from x_i-1 to x_i around z_i-1 in deg
                theta_plus_deg = [0;-90;90;180;180;0];
                theta_plus = deg2rad(theta_plus_deg); % converts deg to rad
            case 4
                % Stäubli RX160L
                % dist btw z_i-1 & z_i along x_i in mm
                a = [150;825;0;0;0;0];

                % angle from z_i-1 to z_i around x_i in deg
                alpha_deg = [-90;0;90;90;90;0];
                alpha = deg2rad(alpha_deg); % converts deg to rad

                % dist btw x_i-1 & x_i along z_i-1 in mm
                d = [550;0;0;925;0;110];

                % angle from x_i-1 to x_i around z_i-1 in deg
                theta_plus_deg = [0;-90;90;180;180;0];
                theta_plus = deg2rad(theta_plus_deg); % converts deg to rad
            otherwise
                a           = zeros(6,1);
                alpha       = zeros(6,1);
                d           = zeros(6,1);
                theta_plus	= zeros(6,1);
        end

        radVal = get(handles.degrad(1), 'Value');

        if radVal == 1
            dh = [a alpha d theta_plus];
        else
            dh = [a alpha_deg d theta_plus_deg];
        end

        set(dhtable, 'Data', dh);
        set(dhtable, 'RowName', link(1:n));

    end

%% dhparaCallback
    function dhparaCallback(Radio3,~)

        handles = guidata(Radio3);
        otherRadio = handles.dhpara(handles.dhpara ~= Radio3);
        sameRadio = handles.dhpara(handles.dhpara == Radio3);

        % This selects one and deselects other
        set(otherRadio, 'Value', 0);
        set(sameRadio, 'Value', 1);

        % This is value of the selected
        radioVal = get(handles.dhpara(1), 'Value');

        % This activates the selection
        if radioVal==0
            set(panel(2), 'Title', 'Modified DH table');
            if verLessThan('matlab','9.0')
                % -- Code to run in MATLAB R2015b and earlier here --
                set(dhtable, 'ColumnName', {'a_i-1', 'alpha_i-1', 'd_i', 'theta_i'});
            else
                % -- Code to run in MATLAB R2016a and later here --
                set(dhtable, 'ColumnName', {'a_i-1', sprintf('\x3b1_i-1'), 'd_i', sprintf('\x3b8_i')});
            end
        else
            set(panel(2), 'Title', 'Standard DH table');
            if verLessThan('matlab','9.0')
                % -- Code to run in MATLAB R2015b and earlier here --
                set(dhtable, 'ColumnName', {'a_i', 'alpha_i', 'd_i', 'theta_i'});
            else
                % -- Code to run in MATLAB R2016a and later here --
                set(dhtable, 'ColumnName', {'a_i', sprintf('\x3b1_i'), 'd_i', sprintf('\x3b8_i')});
            end
        end

    end

%% nLinkButtonCallback
    function nLinkButtonCallback(~,~)

        if n>2 
            n = n-1;
            set(linkEdit, 'String', n);
            set(pLinkButton, 'Enable', 'on');
        else
            n = n-1;
            set(linkEdit, 'String', n);
            set(nLinkButton, 'Enable', 'off');
        end

        dh = dh(1:n,:);        
        set(dhtable, 'Data', dh);
        set(dhtable, 'RowName', link(1:n));

        qEditSwitchCallback(1)

    end

%% pLinkButtonCallback
    function pLinkButtonCallback(~,~)

        if n<5 
            n = n+1;
            set(linkEdit, 'String', n);
            set(nLinkButton, 'Enable', 'on');
        else
            n = n+1;
            set(linkEdit, 'String', n);
            set(pLinkButton, 'Enable', 'off');
        end

        zeroM = zeros(n,4);
        zeroM(1:n-1,:);
        zeroM(1:n-1,:) = dh;
        dh = zeroM;

        set(dhtable, 'Data', dh);
        set(dhtable, 'RowName', link(1:n));

        qEditSwitchCallback(1)

    end

%% linkEditCallback
    function linkEditCallback(~,~)

        n_string = get(linkEdit, 'String');
        n_trial = str2double(n_string);

        if (isnan(n_trial))
            set(linkEdit, 'String', n);
        else
            if n_trial<=n
                n_bigger = 1;
            elseif  n_trial>n
                n_bigger = 0;
                n_diff = n_trial-n;
            else
            end
            if n_trial<1 || n_trial>6
                set(linkEdit, 'String', n);
            else
                if n_trial>1 && n_trial<6
                    n = n_trial;
                    set(pLinkButton, 'Enable', 'on');
                    set(nLinkButton, 'Enable', 'on');
                elseif n_trial == 1
                    n = n_trial;
                    set(pLinkButton, 'Enable', 'on');
                    set(nLinkButton, 'Enable', 'off');
                elseif n_trial == 6
                    n = n_trial;
                    set(pLinkButton, 'Enable', 'off');
                    set(nLinkButton, 'Enable', 'on');
                else
                    set(linkEdit, 'String', n);
                end
                if n_bigger==0
                    zeroM = zeros(n,4);
                    zeroM(1:n-n_diff,:);
                    zeroM(1:n-n_diff,:) = dh;
                    dh = zeroM;
                else
                    dh = dh(1:n,:);
                end
            end            

            set(dhtable, 'Data', dh);
            set(dhtable, 'RowName', link(1:n));

            qEditSwitchCallback(1)

        end

    end

%% qEditSwitchCallback
    function qEditSwitchCallback(~,~)
        switch (n)
            case 1
                set(q1Edit, 'Visible', 'on')
                set(q2Edit, 'Visible', 'off')
                set(q3Edit, 'Visible', 'off')
                set(q4Edit, 'Visible', 'off')
                set(q5Edit, 'Visible', 'off')
                set(q6Edit, 'Visible', 'off')
            case 2
                set(q1Edit, 'Visible', 'on')
                set(q2Edit, 'Visible', 'on')
                set(q3Edit, 'Visible', 'off')
                set(q4Edit, 'Visible', 'off')
                set(q5Edit, 'Visible', 'off')
                set(q6Edit, 'Visible', 'off')
            case 3
                set(q1Edit, 'Visible', 'on')
                set(q2Edit, 'Visible', 'on')
                set(q3Edit, 'Visible', 'on')
                set(q4Edit, 'Visible', 'off')
                set(q5Edit, 'Visible', 'off')
                set(q6Edit, 'Visible', 'off')
            case 4
                set(q1Edit, 'Visible', 'on')
                set(q2Edit, 'Visible', 'on')
                set(q3Edit, 'Visible', 'on')
                set(q4Edit, 'Visible', 'on')
                set(q5Edit, 'Visible', 'off')
                set(q6Edit, 'Visible', 'off')
            case 5
                set(q1Edit, 'Visible', 'on')
                set(q2Edit, 'Visible', 'on')
                set(q3Edit, 'Visible', 'on')
                set(q4Edit, 'Visible', 'on')
                set(q5Edit, 'Visible', 'on')
                set(q6Edit, 'Visible', 'off')
            otherwise
                set(q1Edit, 'Visible', 'on')
                set(q2Edit, 'Visible', 'on')
                set(q3Edit, 'Visible', 'on')
                set(q4Edit, 'Visible', 'on')
                set(q5Edit, 'Visible', 'on')
                set(q6Edit, 'Visible', 'on')
        end
    end

%% symCheckboxCallback
    function symCheckboxCallback(~,~)
        
        symCheckboxVal  = get(symCheckbox,'Value');
        radioVal        = get(handles.degrad(1), 'Value');
        
        q1Store = str2double(get(q1Edit, 'String'));
        q2Store = str2double(get(q2Edit, 'String'));
        q3Store = str2double(get(q3Edit, 'String'));
        q4Store = str2double(get(q4Edit, 'String'));
        q5Store = str2double(get(q5Edit, 'String'));
        q6Store = str2double(get(q6Edit, 'String'));
            
        if radioVal==0
        else
            q1Store = deg2rad(q1Store);
            q2Store = deg2rad(q2Store);
            q3Store = deg2rad(q3Store);
            q4Store = deg2rad(q4Store);
            q5Store = deg2rad(q5Store);
            q6Store = deg2rad(q6Store);
        end
                
        if (symCheckboxVal == 1)
            set(q1Edit, 'Enable', 'off')
            set(q2Edit, 'Enable', 'off')
            set(q3Edit, 'Enable', 'off')
            set(q4Edit, 'Enable', 'off')
            set(q5Edit, 'Enable', 'off')
            set(q6Edit, 'Enable', 'off')
        else
            if radioVal==0
                set(q1Edit, 'String', q1Store)
                set(q2Edit, 'String', q2Store)
                set(q3Edit, 'String', q3Store)
                set(q4Edit, 'String', q4Store)
                set(q5Edit, 'String', q5Store)
                set(q6Edit, 'String', q6Store)
            else
                set(q1Edit, 'String', rad2deg(q1Store))
                set(q2Edit, 'String', rad2deg(q2Store))
                set(q3Edit, 'String', rad2deg(q3Store))
                set(q4Edit, 'String', rad2deg(q4Store))
                set(q5Edit, 'String', rad2deg(q5Store))
                set(q6Edit, 'String', rad2deg(q6Store))
            end
            set(q1Edit, 'Enable', 'on')
            set(q2Edit, 'Enable', 'on')
            set(q3Edit, 'Enable', 'on')
            set(q4Edit, 'Enable', 'on')
            set(q5Edit, 'Enable', 'on')
            set(q6Edit, 'Enable', 'on')
        end
    end

%% degradCallback
    function degradCallback(Radio2,~)

        handles = guidata(Radio2);
        otherRadio = handles.degrad(handles.degrad ~= Radio2);
        sameRadio = handles.degrad(handles.degrad == Radio2);

        sameRadioValue = get(sameRadio, 'Value');

        % This selects one and deselects other
        set(otherRadio, 'Value', 0);
        set(sameRadio, 'Value', 1);

        % This is value of the selected
        radioVal = get(handles.degrad(1), 'Value');
        symVal = get(symCheckbox, 'Value');
                     
                    
        if sameRadioValue
            dh = get(dhtable,'Data');

            % This activates the selection
            if radioVal==0
                if symVal==1
                    set(q1Edit, 'String', q1Store);
                    set(q2Edit, 'String', q2Store);
                    set(q3Edit, 'String', q3Store);
                    set(q4Edit, 'String', q4Store);
                    set(q5Edit, 'String', q5Store);
                    set(q6Edit, 'String', q6Store);
                    theta = [q1;q2;q3;q4;q5;q6];
                else
                    theta = zeros(6,1);
                    set(q1Edit, 'String', q1Store);
                    set(q2Edit, 'String', q2Store);
                    set(q3Edit, 'String', q3Store);
                    set(q4Edit, 'String', q4Store);
                    set(q5Edit, 'String', q5Store);
                    set(q6Edit, 'String', q6Store);
                end
                theta_plus = rad2deg(theta_plus);
                dh(:,2) = rad2deg(dh(:,2));
                dh(:,4) = rad2deg(dh(:,4));
                set(dhtable, 'Data', dh);
            else
                if symVal==1
                    set(q1Edit, 'String', deg2rad(q1Store));
                    set(q2Edit, 'String', deg2rad(q2Store));
                    set(q3Edit, 'String', deg2rad(q3Store));
                    set(q4Edit, 'String', deg2rad(q4Store));
                    set(q5Edit, 'String', deg2rad(q5Store));
                    set(q6Edit, 'String', deg2rad(q6Store));
                    theta = [q1;q2;q3;q4;q5;q6];
                else
                    theta = zeros(6,1);
                    set(q1Edit, 'String', deg2rad(q1Store));
                    set(q2Edit, 'String', deg2rad(q2Store));
                    set(q3Edit, 'String', deg2rad(q3Store));
                    set(q4Edit, 'String', deg2rad(q4Store));
                    set(q5Edit, 'String', deg2rad(q5Store));
                    set(q6Edit, 'String', deg2rad(q6Store));
                end
                theta_plus = deg2rad(theta_plus);
                dh(:,2) = deg2rad(dh(:,2));
                dh(:,4) = deg2rad(dh(:,4));
                set(dhtable, 'Data', dh);
            end
        else
        end

    end

%% q1EditCallback
    function q1EditCallback(~,~)

        theta_string = get(q1Edit, 'String');
        theta_trial = str2double(theta_string);

        if size(theta_string) == size('pi')
            if theta_string == 'pi'
                theta(1) = pi;
                q1Store = pi;
            elseif (isnan(theta_trial))
                set(q1Edit, 'String', theta(1));
            else
                theta(1) = theta_trial;
                q1Store = theta_trial;
            end
        else
            if (isnan(theta_trial))
                set(q1Edit, 'String', theta(1));
            else
                theta(1) = theta_trial;
                q1Store = theta_trial;
            end
        end

    end

%% q2EditCallback
    function q2EditCallback(~,~)

        theta_string = get(q2Edit, 'String');
        theta_trial = str2double(theta_string);

        if size(theta_string) == size('pi')
            if theta_string == 'pi'
                theta(2) = pi;
                q2Store = pi;
            elseif (isnan(theta_trial))
                set(q2Edit, 'String', theta(2));
            else
                theta(2) = theta_trial;
                q2Store = theta_trial;
            end
        else
            if (isnan(theta_trial))
                set(q2Edit, 'String', theta(2));
            else
                theta(2) = theta_trial;
                q2Store = theta_trial;
            end
        end

    end

%% q3EditCallback
    function q3EditCallback(~,~)
        
        theta_string = get(q3Edit, 'String');
        theta_trial = str2double(theta_string);
        
        if size(theta_string) == size('pi')
            if theta_string == 'pi'
                theta(3) = pi;
                q3Store = pi;
            elseif (isnan(theta_trial))
                set(q3Edit, 'String', theta(3));
            else
                theta(3) = theta_trial;
                q3Store = theta_trial;
            end
        else
            if (isnan(theta_trial))
                set(q3Edit, 'String', theta(3));
            else
                theta(3) = theta_trial;
                q3Store = theta_trial;
            end
        end
        
    end

%% q4EditCallback
    function q4EditCallback(~,~)
        
        theta_string = get(q4Edit, 'String');
        theta_trial = str2double(theta_string);
        
        if size(theta_string) == size('pi')
            if theta_string == 'pi'
                theta(4) = pi;
                q4Store = pi;
            elseif (isnan(theta_trial))
                set(q4Edit, 'String', theta(4));
            else
                theta(4) = theta_trial;
                q4Store = theta_trial;
            end
        else
            if (isnan(theta_trial))
                set(q4Edit, 'String', theta(4));
            else
                theta(4) = theta_trial;
                q4Store = theta_trial;
            end
        end
        
    end

%% q5EditCallback
    function q5EditCallback(~,~)
        
        theta_string = get(q5Edit, 'String');
        theta_trial = str2double(theta_string);
        
        if size(theta_string) == size('pi')
            if theta_string == 'pi'
                theta(5) = pi;
                q5Store = pi;
            elseif (isnan(theta_trial))
                set(q5Edit, 'String', theta(5));
            else
                theta(5) = theta_trial;
                q5Store = theta_trial;
            end
        else
            if (isnan(theta_trial))
                set(q5Edit, 'String', theta(5));
            else
                theta(5) = theta_trial;
                q5Store = theta_trial;
            end
        end
        
    end

%% q6EditCallback
    function q6EditCallback(~,~)
        
        theta_string = get(q6Edit, 'String');
        theta_trial = str2double(theta_string);
                
        if size(theta_string) == size('pi')
            if theta_string == 'pi'
                theta(6) = pi;
                q6Store = pi;
            elseif (isnan(theta_trial))
                set(q6Edit, 'String', theta(6));
            else
                theta(6) = theta_trial;
                q6Store = theta_trial;
            end
        else
            if (isnan(theta_trial))
                set(q6Edit, 'String', theta(6));
            else
                theta(6) = theta_trial;
                q6Store = theta_trial;
            end
        end
        
    end

%% tn_0ButtonCallback
    function tn_0ButtonCallback(~,~)
        
        dh = get(dhtable,'Data');
        a  = dh(:,1);
        d  = dh(:,3);
        
        radVal = get(handles.degrad(1), 'Value');
        symVal = get(symCheckbox, 'Value');
        
        if radVal == 1
            alpha       = dh(:,2);
            theta_plus  = dh(:,4);
            if symVal==1
                theta = [q1;q2;q3;q4;q5;q6];
            else
            end
        else
            alpha       = deg2rad(dh(:,2));
            theta_plus  = deg2rad(dh(:,4));
            if symVal==1
                theta = [q1;q2;q3;q4;q5;q6];
            else
                theta = deg2rad(theta);
            end
        end
        
        if symVal==1
                
                % Trans_z_0
                trnZ_0 = [1 0 0 0;
                          0 1 0 0
                          0 0 1 d(1)
                          0 0 0 1];

                % Rot_z_0 
                rotZ_0 = [cos(theta(1)+theta_plus(1))	-sin(theta(1)+theta_plus(1))	0	0
                         sin(theta(1)+theta_plus(1))	cos(theta(1)+theta_plus(1))     0	0
                         0                              0                               1	0
                         0                              0                               0	1];

                % Trans_x_1
                trnX_1 = [1 0 0 a(1)
                          0 1 0 0
                          0 0 1 0
                          0 0 0 1];

                % Rot_x_1
                rotX_1 = [1	0               0               0
                         0	cos(alpha(1))	-sin(alpha(1))	0
                         0	sin(alpha(1))	cos(alpha(1))	0
                         0	0               0               1];

                A1 = trnZ_0*rotZ_0*trnX_1*rotX_1;
%                 vpa(A1,2)
                % Trans_z_1
                trnZ_1 = [1 0 0 0;
                          0 1 0 0
                          0 0 1 d(2)
                          0 0 0 1];

                % Rot_z_1 
                rotZ_1 = [cos(theta(2)+theta_plus(2))	-sin(theta(2)+theta_plus(2))	0	0
                         sin(theta(2)+theta_plus(2))	cos(theta(2)+theta_plus(2))     0	0
                         0                              0                               1	0
                         0                              0                               0	1];

                % Trans_x_2
                trnX_2 = [1 0 0 a(2)
                          0 1 0 0
                          0 0 1 0
                          0 0 0 1];

                % Rot_x_2
                rotX_2 = [1	0               0               0
                         0	cos(alpha(2))	-sin(alpha(2))	0
                         0	sin(alpha(2))	cos(alpha(2))	0
                         0	0               0               1];

                A2 = trnZ_1*rotZ_1*trnX_2*rotX_2;
                
                % Trans_z_2
                trnZ_2 = [1 0 0 0;
                          0 1 0 0
                          0 0 1 d(3)
                          0 0 0 1];

                % Rot_z_2
                rotZ_2 = [cos(theta(3)+theta_plus(3))	-sin(theta(3)+theta_plus(3))	0	0
                         sin(theta(3)+theta_plus(3))	cos(theta(3)+theta_plus(3))     0	0
                         0                              0                               1	0
                         0                              0                               0	1];

                % Trans_x_3
                trnX_3 = [1 0 0 a(3)
                          0 1 0 0
                          0 0 1 0
                          0 0 0 1];

                % Rot_x_3
                rotX_3 = [1	0               0               0
                         0	cos(alpha(3))	-sin(alpha(3))	0
                         0	sin(alpha(3))	cos(alpha(3))	0
                         0	0               0               1];

                A3 = trnZ_2*rotZ_2*trnX_3*rotX_3;
                
                % Trans_z_3
                trnZ_3 = [1 0 0 0;
                          0 1 0 0
                          0 0 1 d(4)
                          0 0 0 1];

                % Rot_z_3 
                rotZ_3 = [cos(theta(4)+theta_plus(4))	-sin(theta(1)+theta_plus(4))	0	0
                         sin(theta(4)+theta_plus(4))	cos(theta(1)+theta_plus(4))     0	0
                         0                              0                               1	0
                         0                              0                               0	1];

                % Trans_x_4
                trnX_4 = [1 0 0 a(4)
                          0 1 0 0
                          0 0 1 0
                          0 0 0 1];

                % Rot_x_4
                rotX_4 = [1	0               0               0
                         0	cos(alpha(4))	-sin(alpha(4))	0
                         0	sin(alpha(4))	cos(alpha(4))	0
                         0	0               0               1];

                A4 = trnZ_3*rotZ_3*trnX_4*rotX_4;
                
                % Trans_z_4
                trnZ_4 = [1 0 0 0;
                          0 1 0 0
                          0 0 1 d(5)
                          0 0 0 1];

                % Rot_z_4 
                rotZ_4 = [cos(theta(5)+theta_plus(5))	-sin(theta(5)+theta_plus(5))	0	0
                         sin(theta(5)+theta_plus(5))	cos(theta(5)+theta_plus(5))     0	0
                         0                              0                               1	0
                         0                              0                               0	1];

                % Trans_x_5
                trnX_5 = [1 0 0 a(5)
                          0 1 0 0
                          0 0 1 0
                          0 0 0 1];

                % Rot_x_5
                rotX_5 = [1	0               0               0
                         0	cos(alpha(5))	-sin(alpha(5))	0
                         0	sin(alpha(5))	cos(alpha(5))	0
                         0	0               0               1];

                A5 = trnZ_4*rotZ_4*trnX_5*rotX_5;
                
                % Trans_z_5
                trnZ_5 = [1 0 0 0;
                          0 1 0 0
                          0 0 1 d(6)
                          0 0 0 1];

                % Rot_z_5 
                rotZ_5 = [cos(theta(6)+theta_plus(6))	-sin(theta(6)+theta_plus(6))	0	0
                         sin(theta(6)+theta_plus(6))	cos(theta(6)+theta_plus(6))     0	0
                         0                              0                               1	0
                         0                              0                               0	1];

                % Trans_x_6
                trnX_6 = [1 0 0 a(6)
                          0 1 0 0
                          0 0 1 0
                          0 0 0 1];

                % Rot_x_6
                rotX_6 = [1	0               0               0
                         0	cos(alpha(6))	-sin(alpha(6))	0
                         0	sin(alpha(6))	cos(alpha(6))	0
                         0	0               0               1];

                A6 = trnZ_5*rotZ_5*trnX_6*rotX_6;
        else
            for i=1:n
                % Trans_z_i-1
                trnZ(:,:,i) = [1 0 0 0;
                               0 1 0 0
                               0 0 1 d(i)
                               0 0 0 1];

                % Rot_z_i-1 
                rotZ(:,:,i) = [cos(theta(i)+theta_plus(i))	-sin(theta(i)+theta_plus(i))	0	0
                               sin(theta(i)+theta_plus(i))	cos(theta(i)+theta_plus(i))     0	0
                               0                            0                               1	0
                               0                            0                               0	1];

                % Trans_x_i
                trnX(:,:,i) = [1 0 0 a(i)
                               0 1 0 0
                               0 0 1 0
                               0 0 0 1];

                % Rot_x_i
                rotX(:,:,i) = [1	0               0               0
                               0	cos(alpha(i))	-sin(alpha(i))	0
                               0	sin(alpha(i))	cos(alpha(i))	0
                               0	0               0               1];

                A(:,:,i) = trnZ(:,:,i)*rotZ(:,:,i)*trnX(:,:,i)*rotX(:,:,i);
            end
        end

        % Transformation n to 0
        Ti_0(:,:,1) = A(:,:,1);
        for i = 1:n-1
            Ti_0(:,:,i+1) = Ti_0(:,:,i)*A(:,:,i+1);
        end
        
        if radVal == 1
        else
            if symVal==1
                theta = [q1;q2;q3;q4;q5;q6];
            else
                theta = rad2deg(theta);
            end
        end
        
    end


    %% tn_0ButtonPrintCallback
    function tn_0ButtonPrintCallback(~,~)
        Ti_0(:,:,n)
%         Tn_0 = Ti_0(:,:,n)
%         Tn_0Simple = simplify(Tn_0)
        % MuPAD Notebook
%         mu1 = openmn('mu_Tn_0.mn');
%         setVar(mu1,'n',n)
%         setVar(mu1,'Tn_0Simple',Tn_0)
    end
%% jacobianButtonCallback
    function jacobianButtonCallback(~,~)
        
        tn_0ButtonCallback(1)
                
        % Unit vectors        
        z0 = [0;0;1];
        for i = 1:n
            z(:,:,i+1) = Ti_0(1:3,3,i);
        end
        z(:,:,1) = z0;

        % Coordinates of origins
        o0 = zeros(3,1);
        for i = 1:n
            o(:,:,i+1) = Ti_0(1:3,4,i);
        end
        o(:,:,1) = o0;
        
        
        % Linear Jacobians (for revolute joints)
        for i = 1:n
            Jv(:,i) = cross(z(:,:,i),(o(:,:,n+1)-o(:,:,i)));
        end

        % Angular Jacobians (for revolute joints)
        for i = 1:n
            Jw(:,i) = z(:,:,i);
        end

        % Jacobian
        J = [Jv;Jw];
    end

    %% jacobianButtonPrintCallback
    function jacobianButtonPrintCallback(~,~)
        J
%         JSimple = simplify(J)
%         % MuPAD Notebook
%         mu2 = openmn('mu_J.mn');
%         setVar(mu2,'JSimple',JSimple)
    end

%% aJacobianButtonCallback
    function aJacobianButtonCallback(~,~)
        
        jacobianButtonCallback(1)
                
        % Analytical Jacobian (there is no wrist origin in this example)
        alpha       = [phi;the;psi];
        B           = [cos(psi)*sin(the) -sin(psi) 0;sin(psi)*sin(the) cos(psi) 0;cos(the) 0 1];
        invB        = inv(B);
        invBSimple  = simplify(invB);
        Ja          = [eye(3) zeros(3,3);zeros(3,3) invB]*J;
        JaSimple    = simplify(Ja);
        
    end

    %% aJacobianButtonPrintCallback
    function aJacobianButtonPrintCallback(~,~)
        Ja
    end

    %% openRoboDKButtonPrintCallback
    function openRoboDKButtonCallback(~,~)
        % Generate a Robolink object RDK. This object interfaces with RoboDK.
        path = 'C:\RoboDK\Matlab';
        RDK = Robolink;

        % Get the library path
        path = RDK.getParam('PATH_LIBRARY');
% 
%         % Open example 1
%         RDK.AddFile([path,'Example 01 - Pick and place.rdk']);
% 
%         % Display a list of all items
%         fprintf('Available items in the station:\n');
%         disp(RDK.ItemList());
% 
%         % Get one item by its name
%         program = RDK.Item('Pick and place');
% 
%         % Start "Pick and place" program
%         program.RunProgram();

    end
end