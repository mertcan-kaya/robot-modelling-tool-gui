function mainGUI
%%

clc
clear all
close all

%% Initializing some global variables and flags
    
    % Link number
    n               = 6; % Default value
    n_diff          = 0;
    
    % Initial values
    a               = zeros(n,1);
    alpha           = zeros(n,1);
    d               = zeros(n,1); % variable
    d_plus          = zeros(n,1);
    theta           = zeros(n,1); % variable
    theta_plus      = zeros(n,1);

    q               = zeros(n,1);
    j               = zeros(n,1);
    qEditVisible    = zeros(6,1);

    DH              = [a alpha d_plus theta_plus];
    Ti_0            = zeros(4,4,n);
    J               = zeros(6,n);

    theta_i         = {'\x3b8_1' '\x3b8_2' '\x3b8_3' '\x3b8_4' '\x3b8_5' '\x3b8_6'};
    d_i             = {'d_1' 'd_2' 'd_3' 'd_4' 'd_5' 'd_6'};
    
    % GUI parameters
    pad1 = 10;
    pad2 = 7;
    pad3 = 1;

    % Initial dimensional parameters
    b5 = pad3+1;        % 2
    h5 = 19;
    b4 = b5+h5+pad1;	% 31
    h4 = 24;
    b3 = b4+h4+pad2;	% 62
    h3 = 193;
    b2 = b3+h3+pad2;  	% 262
    h2 = 24;
    b1 = b2+h2+pad1;   	% 296
    h1 = 50;
    
    w_main = 422+7+4-2;
    h_main = b1+h1+pad2;% 353

    % GUI element dimensions
    bH  = 23; 	% Button height
    eW  = 57;  	% Edith width
    sW  = 78;  	% Save As... width
    dW  = 60; 	% Delete width
    DHW = 77;  	% DHText width
    DPW = 65;  	% DHPara width
    cTW = 90; 	% Clear Table width
    lNW = 80;  	% linkNumText width
    lBS = 22;  	% Link button size
    lES = 20; 	% linkEdit size
    tH  = 15; 	% Text heigth
    rH  = 13;  	% Radio heigth
    DRW = 45; 	% degRad width
    aTW = 25;	% angleText width
    eH  = 17;	% edith heigth
    DTT = 62;	% DHTable from top
    qEW = 44;   % qEdit width
    rW  = 15;   % Radio width
    
    %% GUI setup
    
    mainFig             = figure(   'Visible',              'off', ...
                                    'MenuBar',              'none', ...
                                    'NumberTitle',          'off', ...
                                    'Name',                 'Robot Modeling Tool GUI v1b', ...
                                    'Resize',               'on', ...
                                    'Position',             [1 1 w_main h_main], ...
                                    'SizeChangedFcn',       @resizeFunc);

    movegui(mainFig,'center');

    panel(1)            = uipanel(  'Visible',              'off', ...
                                    'Parent',               mainFig, ...
                                    'BorderType',           'etchedin', ...
                                    'Units',                'pixels', ...
                                    'Title',                'Robot selection');
                                
    panel(2)            = uipanel(  'Visible',              'off', ...
                                    'Parent',               mainFig, ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels');

    DHName = 'Standard DH table';

    panel(3)            = uipanel(  'Visible',              'off', ...
                                    'Parent',               mainFig, ...
                                    'BorderType',           'etchedin', ...
                                    'Title',                DHName, ...
                                    'Units',                'pixels');

    panel(4)            = uipanel(  'Visible',              'off', ...
                                    'Parent',               mainFig, ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels');
                                
    panel(5)            = uipanel(  'Visible',              'off', ...
                                    'Parent',               mainFig, ...
                                    'BorderType',           'beveledin', ...
                                    'Units',                'pixels');

    
    % Panel 1 ---------------------------------------------------------------

    [DH,robotModels,defaultValue] = DHParameters(1,n);
    
    modelList           = uicontrol('Style',                'popupmenu', ...
                                    'Parent',               panel(1), ...
                                    'String',               robotModels, ...
                                    'Callback',             @modelListCallback, ...
                                    'Value',                defaultValue);
    
    editButton          = uicontrol('Style',                'togglebutton', ...
                                    'Parent',               panel(1), ...
                                    'String',               'Edit', ...
                                    'Callback',             @editButtonCallback);
        
    saveButton          = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panel(1), ...
                                    'String',               'Save As...', ...
                                    'Callback',             @saveButtonCallback);
                                
    deleteButton        = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panel(1), ...
                                    'String',               'Delete', ...
                                    'Callback',             @deleteButtonCallback);

    % Panel 2 ---------------------------------------------------------------

    DHText              = uicontrol('Style',                'text', ...
                                    'Parent',               panel(2), ...
                                    'String',               'DH parameters:', ...
                                    'HorizontalAlignment',	'left');

    handles.DHPara(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(2), ...
                                    'String',               'Standard', ...
                                    'Callback',             @DHParaCallback, ...
                                    'Value',                1);

    handles.DHPara(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(2), ...
                                    'String',               'Modified', ...
                                    'Callback',             @DHParaCallback, ...
                                    'Value',                0);

    guidata(mainFig, handles);
    
    symCheckbox         = uicontrol('Style',                'checkbox', ...
                                    'Parent',               panel(2), ...
                                    'String',               'Symbolic', ...
                                    'Callback',             @symCheckboxCallback, ...
                                    'TooltipString',      	'Make computitons symbolically');
 
    clearTableButton    = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panel(2), ...
                                    'String',               'Clear Table', ...
                                    'Callback',             @clearButtonCallback);
                                                           
    % Panel 3 ---------------------------------------------------------------

    linkNumText         = uicontrol('Style',                'text', ...
                                    'Parent',               panel(3), ...
                                    'String',               'Number of links:', ...
                                    'HorizontalAlignment',	'left');

    nLinkButton         = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panel(3), ...
                                    'String',               '-', ...
                                    'Callback',             @nLinkButtonCallback);

    pLinkButton         = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panel(3), ...
                                    'String',               '+', ...
                                    'Callback',             @pLinkButtonCallback);

    linkEdit            = uicontrol('Style',               	'edit', ...
                                    'Parent',             	panel(3), ...
                                    'String',             	n, ...
                                    'Callback',           	@linkEditCallback);
	
    lengthText          = uicontrol('Style',                'text', ...
                                    'Parent',               panel(3), ...
                                    'String',               'Len:', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Distance Unit');
                        
    handles.lenRad(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'String',               'mm', ...
                                    'Callback',             @lenRadCallback, ...
                                    'Value',                1, ...
                                    'TooltipString',      	'Set Distance Unit as mm');

    handles.lenRad(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'String',               'm', ...
                                    'Callback',             @lenRadCallback, ...
                                    'Value',                0, ...
                                    'TooltipString',      	'Set Distance Unit as m');

    guidata(mainFig, handles);

    angleText           = uicontrol('Style',                'text', ...
                                    'Parent',               panel(3), ...
                                    'String',               'Ang:', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Angular Unit');
                        
    handles.degRad(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'String',               'rad', ...
                                    'Callback',             @degRadCallback, ...
                                    'Value',                1, ...
                                    'TooltipString',      	'Set Angular Unit as radian');

    handles.degRad(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'String',               'deg', ...
                                    'Callback',             @degRadCallback, ...
                                    'Value',                0, ...
                                    'TooltipString',      	'Set Angular Unit as degree');

    guidata(mainFig, handles);

    panelTable        	= uipanel(  'Visible',              'on', ...
                                    'Parent',               panel(3), ...
                                    'BorderType',           'etchedin', ...
                                    'Units',                'pixels');
                                
    if verLessThan('matlab','9.0')
        % -- Code to run in MATLAB R2015b and earlier here --
        cName = {'a_i', 'alpha_i', 'd_i', 'theta_i'};
    else
        % -- Code to run in MATLAB R2016a and later here --
        cName = {'a_i', sprintf('\x3b1_i'), 'd_i', sprintf('\x3b8_i')};
    end

    link                = {' 1 ' ' 2 ' ' 3 ' ' 4 ' ' 5 ' ' 6 '};

    DHTable             = uitable(  'Data',                 DH, ...
                                    'ColumnName',           cName, ...
                                    'ColumnWidth',          {60 60 60 60}, ...
                                    'RowName',              link(1:n), ...
                                    'ColumnEditable',       true(1,4), ...
                                    'Parent',               panel(3), ...
                                    'CellEditCallback',     @inputTableCallback);

    linkText            = uicontrol('Style',                'text', ...
                                    'Parent',               panel(3), ...
                                    'String',               'Link', ...
                                    'HorizontalAlignment',	'left');

    q_iText             = uicontrol('Style',                'text', ...
                                    'Parent',               panel(3), ...
                                    'String',               'q_i', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Joint Variables');

    revText             = uicontrol('Style',                'text', ...
                                    'Parent',               panel(3), ...
                                    'String',               'R', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Revolute Joint');
                     
    prisText            = uicontrol('Style',                'text', ...
                                    'Parent',               panel(3), ...
                                    'String',               'P', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Prismatic Joint');
    
    q1Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panel(3), ...
                                    'String',              	0, ...
                                    'Callback',            	@q1EditCallback);

    q2Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panel(3), ...
                                    'String',               0, ...
                                    'Callback',            	@q2EditCallback);

    q3Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panel(3), ...
                                    'String',              	0, ...
                                    'Callback',            	@q3EditCallback);

    q4Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panel(3), ...
                                    'String',              	0, ...
                                    'Callback',            	@q4EditCallback);

    q5Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panel(3), ...
                                    'String',              	0, ...
                                    'Callback',            	@q5EditCallback);

    q6Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',               panel(3), ...
                                    'String',              	0, ...
                                    'Callback',            	@q6EditCallback);

    qEdit               = [q1Edit;q2Edit;q3Edit;q4Edit;q5Edit;q6Edit];
    
    qEditCallback       = {@q1EditCallback;@q2EditCallback;@q3EditCallback; ...
                           @q4EditCallback;@q5EditCallback;@q6EditCallback};
    
    handles.q1Radio(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q1RadioCallback, ...
                                    'Value',                1, ...
                                    'TooltipString',      	'Set Joint 1 as revolute');

    handles.q1Radio(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q1RadioCallback, ...
                                    'Value',                0, ...
                                    'TooltipString',      	'Set Joint 1 as prismatic');
    
    guidata(mainFig, handles);
    
    handles.q2Radio(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q2RadioCallback, ...
                                    'Value',                1, ...
                                    'TooltipString',      	'Set Joint 2 as revolute');

    handles.q2Radio(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q2RadioCallback, ...
                                    'Value',                0, ...
                                    'TooltipString',      	'Set Joint 2 as prismatic');

    guidata(mainFig, handles);
    
    handles.q3Radio(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q3RadioCallback, ...
                                    'Value',                1, ...
                                    'TooltipString',      	'Set Joint 3 as revolute');

    handles.q3Radio(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q3RadioCallback, ...
                                    'Value',                0, ...
                                    'TooltipString',      	'Set Joint 3 as prismatic');

    guidata(mainFig, handles);
    
    handles.q4Radio(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q4RadioCallback, ...
                                    'Value',                1, ...
                                    'TooltipString',      	'Set Joint 4 as revolute');

    handles.q4Radio(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q4RadioCallback, ...
                                    'Value',                0, ...
                                    'TooltipString',      	'Set Joint 4 as prismatic');

    guidata(mainFig, handles);
    
    handles.q5Radio(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q5RadioCallback, ...
                                    'Value',                1, ...
                                    'TooltipString',      	'Set Joint 5 as revolute');

    handles.q5Radio(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q5RadioCallback, ...
                                    'Value',                0, ...
                                    'TooltipString',      	'Set Joint 5 as prismatic');

    guidata(mainFig, handles);
    
    handles.q6Radio(1)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q6RadioCallback, ...
                                    'Value',                1, ...
                                    'TooltipString',      	'Set Joint 6 as revolute');

    handles.q6Radio(2)	= uicontrol('Style',                'radiobutton', ...
                                    'Parent',               panel(3), ...
                                    'Callback',             @q6RadioCallback, ...
                                    'Value',                0, ...
                                    'TooltipString',      	'Set Joint 6 as prismatic');

    guidata(mainFig, handles);
    
    qRadio              = [handles.q1Radio;handles.q2Radio;handles.q3Radio; ...
                           handles.q4Radio;handles.q5Radio;handles.q6Radio];
    
    % Panel 4 ---------------------------------------------------------------
    
    b_h  = 23;
    b1_w = 75;
    b2_w = 78;
    b3_w = 90;
    b4_w = 97;
    b1_l = 0;
    b2_l = b1_l+b1_w+pad2;
    b3_l = b2_l+b2_w+pad2;
    b4_l = b3_l+b3_w+pad2;
    
    Tn_0Button          = uicontrol('Style',              	'pushbutton', ...
                                    'Parent',             	panel(4), ...
                                    'Position',           	[b1_l 0 b1_w b_h], ...
                                    'String',             	'Tn_0', ...
                                    'Callback',           	@(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                            {@(h,e)Tn_0ButtonCallback(h), ...
                                                            @(h,e)Tn_0ButtonPrintCallback(h)})), ...
                                    'Enable',             	'on');

    JacobianButton      = uicontrol('Style',               	'pushbutton', ...
                                    'Parent',              	panel(4), ...
                                    'Position',            	[b2_l 0 b2_w b_h], ...
                                    'String',             	'Jacobian', ...
                                    'Callback',            	@(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                            {@(h,e)JacobianButtonCallback(h), ...
                                                            @(h,e)JacobianButtonPrintCallback(h)})), ...
                                    'Enable',             	'on');

    dynamicsButton      = uicontrol('Style',              	'pushbutton', ...
                                    'Parent',             	panel(4), ...
                                    'Position',             [b3_l 0 b3_w b_h], ...
                                    'String',             	'Dynamics', ...
                                    'Callback',           	@(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                            {@(h,e)dynamicsButtonCallback(h), ...
                                                            @(h,e)dynamicsButtonPrintCallback(h)})), ...
                                    'Enable',             	'off');

    openRoboDKButton    = uicontrol('Style',                'pushbutton', ...
                                    'Parent',              	panel(4), ...
                                    'Position',            	[b4_l 0 b4_w b_h], ...
                                    'String',              	'Open RoboDK', ...
                                    'Callback',            	@openRoboDKButtonCallback, ...
                                    'Enable',               'on');

    % Panel 5 ---------------------------------------------------------------
    
    progressText        = uicontrol('Style',                'text', ...
                                    'Parent',               panel(5), ...
                                    'Units',                'pixels', ...
                                    'Position',             [5 0 200 16], ...
                                    'String',               '', ...
                                    'HorizontalAlignment',	'left');
    
    modelListCallback()
    
    mainFig.Visible = 'on';
    
    resizeFunc()

    panel(1).Visible = 'on';
    panel(2).Visible = 'on';
    panel(3).Visible = 'on';
    panel(4).Visible = 'on';
    panel(5).Visible = 'on';
        
    LimitFigSize(mainFig, 'min', [w_main, h_main])
    
%% resizeFunc
    function resizeFunc(~,~)
        
        fP   = mainFig.Position;
        b1V  = fP(4)-(h1+pad2);        	% Bottom of panel 1 (Variable)
        b2V  = b1V-(h2+pad1);          	% Bottom of panel 2 (Variable)
        h3V  = b2V-pad2-b3+4;           % Height of panel 3 (Variable)
        dR   = 2*(pad1+2)+(pad2-1)+dW;	% Delete from rigth [90]
        sR   = dR+pad2-1+sW;           	% Save As... from rigth [174]
        eR   = sR+pad2-1+eW;           	% Edith from rigth [237]
        mLR  = eR+2*pad2;              	% Model List from rigth [251]
        DP1  = pad1+1+5+DHW;            % DHPara from left [99]
        DP2  = DP1+65+5;                % DHPara from left [179]
        lEL  = lNW+2*pad1+lBS-2;        % linkEdit from left [120]
        sCL  = lEL+lES+lBS+pad1+3;      % symCheckbox from left [175]
        p3T1 = b2V-(pad1+pad2+h1+h2-6); % Panel 3 from top 1 [b2V-93]
        p3T2 = p3T1-37;                 % Panel 3 from top 2 [b2V-130]
        DR2R = DRW+pad1+pad2+6;        	% degRad(2) from rigth [68]
        DR1R = DR2R+DRW;               	% degRad(1) from rigth [113]
        aTR  = DR1R+aTW+2;             	% angleText from rigth [155]
        pTR  = 2*(pad1+2)+15+2+10;       % prisText from rigth [41]
        rTR  = pTR+15+5;              % revText from rigth [61]
        qTR  = rTR+25+11;             % q_iText from rigth [97]
        q2R  = 2*(pad1+2)+15+5+10;       % q2Radio from rigth [44]
        q1R  = q2R+15+5;               	% q1Radio from rigth [64]
        qER  = q1R+38+12;               % q_iEdit from rigth [108]
        DTH  = h3V-DTT;               	% DHTable heigth [135]
        DTR  = 2*pad1+qER-4;           	% DHTable from rigth [125]
        qRT  = p3T2-(tH+rH+3);          % q_iRadio from top [109]
        qET  = p3T2-(tH+eH+1);      	% q_iEdit from top [107]
        panel(1).Position           = [pad1+1              	b1V                 fP(3)-2*pad1	h1];
        panel(2).Position           = [pad3+1             	b2V                 fP(3)-2*pad3	h2];
        panel(3).Position           = [pad1+1             	b3                  fP(3)-2*pad1	h3V];
        panel(4).Position           = [pad1+1              	b4                  fP(3)-2*pad1	h4];
        panel(5).Position           = [pad3+1             	b5                  fP(3)-2*pad3	h5];
        modelList.Position          = [pad2                 8                   fP(3)-mLR       22];
        editButton.Position         = [fP(3)-eR             8                   eW              bH];
        saveButton.Position         = [fP(3)-sR             8                   sW              bH];
        deleteButton.Position       = [fP(3)-dR             8                   dW              bH];
        DHText.Position             = [pad1-1               5                   DHW             tH];
        handles.DHPara(1).Position  = [DP1                	7                   DPW             rH];
        handles.DHPara(2).Position  = [DP2                	7                   DPW             rH];
        symCheckbox.Position        = [fP(3)-(cTW+pad1+78)  3                   70              22];
        clearTableButton.Position   = [fP(3)-(cTW+pad1)     2                   cTW             bH];
        linkNumText.Position        = [pad1-1             	p3T1-(tH+4)         lNW             tH];
        nLinkButton.Position        = [lEL-lBS          	p3T1-lBS            lBS             lBS];
        pLinkButton.Position        = [lEL+lES-4            p3T1-lBS            lBS             lBS];
        linkEdit.Position           = [lEL-2                p3T1-(lES+1)        lES             lES];
        angleText.Position          = [fP(3)-aTR+2         	p3T1-(tH+4)         aTW             tH];
        handles.degRad(1).Position  = [fP(3)-DR1R+5        	p3T1-(rH+4)         DRW             rH];
        handles.degRad(2).Position  = [fP(3)-DR2R           p3T1-(rH+4)         DRW             rH];
        lengthText.Position         = [fP(3)-aTR-110       	p3T1-(tH+4)         aTW             tH];
        handles.lenRad(1).Position  = [fP(3)-DR1R-109      	p3T1-(rH+4)         DRW             rH];
        handles.lenRad(2).Position  = [fP(3)-DR2R-114     	p3T1-(rH+4)         DRW             rH];
        panelTable.Position         = [fP(3)-qTR-25        	pad1-1              101             DTH+1];
        DHTable.Position            = [pad1-1              	pad1                fP(3)-DTR       DTH];
        linkText.Position           = [2*pad1+1             p3T2-tH             25              tH];
        q_iText.Position            = [fP(3)-qTR-3        	p3T2-tH             25              tH];
        revText.Position            = [fP(3)-rTR          	p3T2-tH             15              tH];
        prisText.Position           = [fP(3)-pTR           	p3T2-tH             15              tH];
        q1Edit.Position             = [fP(3)-qER         	qET                 qEW             eH];
        q2Edit.Position             = [fP(3)-qER            qET-18              qEW             eH];
        q3Edit.Position             = [fP(3)-qER            qET-(2*18)          qEW             eH];
        q4Edit.Position             = [fP(3)-qER            qET-(3*18)          qEW             eH];
        q5Edit.Position             = [fP(3)-qER            qET-(4*18)          qEW             eH];
        q6Edit.Position             = [fP(3)-qER            qET-(5*18)          qEW             eH];
        handles.q1Radio(1).Position = [fP(3)-q1R            qRT                 rW              rH];
        handles.q1Radio(2).Position = [fP(3)-q2R            qRT                 rW              rH];
        handles.q2Radio(1).Position	= [fP(3)-q1R            qRT-18              rW              rH];
        handles.q2Radio(2).Position = [fP(3)-q2R            qRT-18              rW              rH];
        handles.q3Radio(1).Position = [fP(3)-q1R            qRT-(2*18)          rW              rH];
        handles.q3Radio(2).Position = [fP(3)-q2R            qRT-(2*18)          rW              rH];
        handles.q4Radio(1).Position = [fP(3)-q1R            qRT-(3*18)          rW              rH];
        handles.q4Radio(2).Position = [fP(3)-q2R            qRT-(3*18)          rW              rH];
        handles.q5Radio(1).Position = [fP(3)-q1R            qRT-(4*18)          rW              rH];
        handles.q5Radio(2).Position = [fP(3)-q2R            qRT-(4*18)          rW              rH];
        handles.q6Radio(1).Position = [fP(3)-q1R            qRT-(5*18)          rW              rH];
        handles.q6Radio(2).Position = [fP(3)-q2R            qRT-(5*18)          rW              rH];
        
    end

%% modelListCallback
    function modelListCallback(~,~)
        
        n_old = n;
        
        [DH_new,~,~,j] = DHParameters(modelList.Value,n);
        
        if modelList.Value~=5
            n = length(j);
            deleteButton.Enable = 'on';
            linkEdit.String = n;
            DHTable.RowName	= link(1:n);
            qEditSwitchCallback();
            DHTableDisable();
            qRadioDisable();
        else
            deleteButton.Enable = 'off';
            DHTableEnable();
            qRadioEnable();
        end
        
        saveAsState();
        
        n_diff = n-n_old;
        
        qEditAdd();
        DH = DH_new;
        
        DHTable.Data	= DH;
        a               = DH(:,1);
        alpha           = DH(:,2);
        d_plus          = DH(:,3);
        theta_plus      = DH(:,4);
        
        qStringEdit();    
        qEditSwitchCallback();
        qRadioSelect();
        symCheckboxCallback();
        
    end

%% saveAsState
    function saveAsState(~,~)
        
        fP = mainFig.Position;

        if modelList.Value~=5
            eW = 57;                   	% Edith width
            dW = 60;                  	% Delete width
            sW = 78;                 	% Save As... width

            saveButton.Enable    = 'off';
            saveButton.String    = 'Save As...';
            editButton.Value     = 0;
        else
            eW = 65;                	% Edith width
            dW = 65;                   	% Delete width
            sW = 65;                   	% Save width

            saveButton.Enable    = 'on';
            saveButton.String    = 'Save';
            editButton.Value     = 1;
        end
        
        dR = 2*(pad1+2)+(pad2-1)+dW;   	% Delete from rigth [90 or 95]
        sR = dR+pad2-1+sW;           	% Save As... from rigth [174 or 182]
        eR = sR+pad2-1+eW;           	% Edith from rigth [237]
        
        editButton.Position    	= [fP(3)-eR     8    	eW    	bH];
        saveButton.Position   	= [fP(3)-sR     8     	sW     	bH];
        deleteButton.Position	= [fP(3)-dR   	8     	dW     	bH];

    end

%% editButtonCallback
    function editButtonCallback(~,~)
        
        saveButton.Enable = 'on';
        
        if modelList.Value==5
            editButton.Value = 1;
        else
        end
        
        if editButton.Value==0
            DHTableDisable();
            [DH,~,~,j] = DHParameters(modelList.Value,n);
            n = length(j);
            q = zeros(n,1);
            theta = zeros(n,1);
            d = zeros(n,1);
            linkEdit.String = n;
            qEditSwitchCallback();
            qRadioSelect();
            qRadioDisable();
            symCheckboxCallback();
        else
            DHTableEnable();
            qRadioEnable();
        end
        
        DHTable.Data   	= DH;
        a               = DH(:,1);
        alpha           = DH(:,2);
        d_plus          = DH(:,3);
        theta_plus      = DH(:,4);
        DHTable.RowName	= link(1:n);
            
    end

%% symCheckboxCallback
    function symCheckboxCallback(~,~)
            
        if symCheckbox.Value == 1
            for i=1:n
                qEdit(i).Enable = 'off';
                if qRadio(i,1).Value==1
                    qEdit(i).String = sprintf(theta_i{i});
                else
                    qEdit(i).String = sprintf(d_i{i});
                end
            end
        else
            for i=1:n
                qEdit(i).Enable = 'on';
                qEdit(i).String = q(i);
            end
        end
        
    end

%% clearButtonCallback
    function clearButtonCallback(~,~)

        modelList.Value     = 5;
        editButton.Value    = 1;
        deleteButton.Enable = 'off';
        
        saveAsState();
        
        DH = zeros(n,4);
        
        a           = DH(:,1);
        alpha       = DH(:,2);
        d_plus      = DH(:,3);
        theta_plus  = DH(:,4);
        
        DHTableEnable();
        qRadioEnable();
        DHTable.Data   	= DH;
        DHTable.RowName	= link(1:n);

        j = zeros(n,1);
        qRadioSelect();
        
        q       = zeros(n,1);
        theta   = zeros(n,1);
        d       = zeros(n,1);
        
        qStringEdit();
            
    end

%% DHTableEnable
    function DHTableEnable(~,~)
        
        saveButton.Enable = 'on';
        if n==1
            nLinkButton.Enable = 'off';
        else
            nLinkButton.Enable = 'on';
        end
        if n==6
            pLinkButton.Enable = 'off';
        else
            pLinkButton.Enable = 'on';
        end
        linkEdit.Enable	= 'on';
        DHTable.Enable	= 'on';

    end

%% DHTableDisable
    function DHTableDisable(~,~)
        
        saveButton.Enable   = 'off';
        nLinkButton.Enable	= 'off';
        pLinkButton.Enable  = 'off';
        linkEdit.Enable    	= 'off';
        DHTable.Enable      = 'off';

    end

%% DHParaCallback
    function DHParaCallback(DHRadio,~)

        radioVal = radioFunction(DHRadio,handles.DHPara);
        
        % This activates the selection
        if radioVal==0
            panel(3).Title = 'Modified DH table';
            if verLessThan('matlab','9.0')
                % -- Code to run in MATLAB R2015b and earlier here --
                set(DHTable, 'ColumnName', {'a_i-1', 'alpha_i-1', 'd_i', 'theta_i'});
            else
                % -- Code to run in MATLAB R2016a and later here --
                DHTable.ColumnName = {'a_i-1', sprintf('\x3b1_i-1'), 'd_i', sprintf('\x3b8_i')};
            end
        else
            panel(3).Title = 'Standard DH table';
            if verLessThan('matlab','9.0')
                % -- Code to run in MATLAB R2015b and earlier here --
                set(DHTable, 'ColumnName', {'a_i', 'alpha_i', 'd_i', 'theta_i'});
            else
                % -- Code to run in MATLAB R2016a and later here --
                DHTable.ColumnName = {'a_i', sprintf('\x3b1_i'), 'd_i', sprintf('\x3b8_i')};
            end
        end

    end

%% inputTableCallback
    function inputTableCallback(hO,ed)

        t_string = ed.EditData;
        t_trial = str2double(t_string);

        r = ed.Indices(1);
        c = ed.Indices(2);
        
        if c == 2 || c == 4
            hO.Data(r,c) = numCheck(t_string,t_trial,ed.PreviousData);
        else
            if (isnan(t_trial))                         % if it is non-numeric return prev.
                hO.Data(r,c) = ed.PreviousData;
            else                                        % if it is numeric output will be input
                hO.Data(r,c) = t_trial;
            end
        end
        
        DH          = DHTable.Data;
        a           = DH(:,1);
        alpha       = DH(:,2);
        d_plus      = DH(:,3);
        theta_plus  = DH(:,4);
        
    end

%% nLinkButtonCallback
    function nLinkButtonCallback(~,~)

        if n>2 
            n = n-1;
            linkEdit.String = n;
            pLinkButton.Enable = 'on';
        else
            n = n-1;
            linkEdit.String = n;
            nLinkButton.Enable = 'off';
        end

        DH = DH(1:n,:);        
        DHTable.Data = DH;
        DHTable.RowName = link(1:n);
        
        a           = a(1:n);
        alpha       = alpha(1:n);
        d_plus      = d_plus(1:n);
        theta_plus	= theta_plus(1:n);
        
        q           = q(1:n);
        d           = d(1:n);
        theta       = theta(1:n);
        j           = j(1:n);
        
        qEditSwitchCallback();

    end

%% pLinkButtonCallback
    function pLinkButtonCallback(~,~)

        if n<5 
            n = n+1;
            linkEdit.String = n;
            nLinkButton.Enable = 'on';
        else
            n = n+1;
            linkEdit.String = n;
            pLinkButton.Enable = 'off';
        end
        
        n_diff = 1;
        qEditAdd();
        
        DHTable.Data = DH;
        DHTable.RowName = link(1:n);
        
        a           = DH(:,1);
        alpha       = DH(:,2);
        d_plus      = DH(:,3);
        theta_plus  = DH(:,4);
        
        qEditSwitchCallback();
        qRadioSelect();
        qStringEdit();
        symCheckboxCallback();
        
    end

%% linkEditCallback
    function linkEditCallback(~,~)

        n_string = linkEdit.String;
        n_trial = str2double(n_string);

        if (isnan(n_trial))
            linkEdit.String = n;
        else
            if n_trial<=n
                n_bigger = 1;
            elseif  n_trial>n
                n_bigger = 0;
                n_diff = n_trial-n;
            else
            end
            if n_trial<1 || n_trial>6
                linkEdit.String = n;
            else
                if n_trial>1 && n_trial<6
                    n = n_trial;
                    pLinkButton.Enable = 'on';
                    nLinkButton.Enable = 'on';
                elseif n_trial == 1
                    n = n_trial;
                    pLinkButton.Enable = 'on';
                    nLinkButton.Enable = 'off';
                elseif n_trial == 6
                    n = n_trial;
                    pLinkButton.Enable = 'off';
                    nLinkButton.Enable = 'on';
                else
                    linkEdit.String = n;
                end
                if n_bigger==0
                    qEditAdd();
                else
                    DH      = DH(1:n,:);
                    q       = q(1:n);
                    theta	= theta(1:n);
                    d       = d(1:n);
                    j       = j(1:n);
                end
            end

            DHTable.Data = DH;
            DHTable.RowName = link(1:n);
            
            qStringEdit();
            qEditSwitchCallback();
            
        end

    end

%% lenRadCallback
    function lenRadCallback(lenRadRadio,~)

        [radioVal,sameRadioVal] = radioFunction(lenRadRadio,handles.lenRad);
        
        if sameRadioVal
            DH = DHTable.Data;

            % This activates the selection
            if radioVal==0
                a       = 1e-3*a;
                d       = 1e-3*d;
                d_plus  = 1e-3*d_plus;
            else
                a       = 1e3*a;
                d       = 1e3*d;
                d_plus  = 1e3*d_plus;
            end
            
            DH(:,1) = a;
            DH(:,3) = d_plus;
            DHTable.Data = DH;
            
            q = theta+d;
            
            qStringEdit();
        else
        end

    end

%% degRadCallback
    function degRadCallback(degRadRadio,~)

        [radioVal,sameRadioVal] = radioFunction(degRadRadio,handles.degRad);
        
        if sameRadioVal
            DH = DHTable.Data;

            % This activates the selection
            if radioVal==0
                alpha       = rad2deg(alpha);
                theta       = rad2deg(theta);
                theta_plus  = rad2deg(theta_plus);
            else
                alpha       = deg2rad(alpha);
                theta       = deg2rad(theta);
                theta_plus  = deg2rad(theta_plus);
            end
            
            DH(:,2) = alpha;
            DH(:,4) = theta_plus;
            DHTable.Data = DH;
            
            q = theta+d;
            
            qStringEdit();
        else
        end

    end

%% qEditAdd
    function qEditAdd(~,~)
        
        DH      = addZeroFunc(DH);
        q       = addZeroFunc(q);
        theta   = addZeroFunc(theta);
        d       = addZeroFunc(d);
        j       = addZeroFunc(j);
                    
    end

%% addZeroFunc
    function output = addZeroFunc(input)
        
        zeroM = zeros(n,length(input(1,:)));
        zeroM(1:n-n_diff,:);
        zeroM(1:n-n_diff,:) = input;
        output = zeroM;
        
    end

%% qRadioSelect
    function qRadioSelect(~,~)
        
        for i=1:n
            qRadio(i,1).Value = 1-j(i);
            qRadio(i,2).Value = j(i);
        end
        
    end

%% qRadioEnable
    function qRadioEnable(~,~)
        
        for i=1:n
            qRadio(i,1).Enable = 'on';
            qRadio(i,2).Enable = 'on';
        end

    end

%% qRadioDisable
    function qRadioDisable(~,~)
        
        for i=1:n
            qRadio(i,1).Enable = 'off';
            qRadio(i,2).Enable = 'off';
        end
    end

%% qEditSwitchCallback
    function qEditSwitchCallback(~,~)
        
        switch (n)
            case 1
                qEditVisible = [0,0,0,0,0];
            case 2
                qEditVisible = [1,0,0,0,0];
            case 3
                qEditVisible = [1,1,0,0,0];
            case 4
                qEditVisible = [1,1,1,0,0];
            case 5
                qEditVisible = [1,1,1,1,0];
            otherwise
                qEditVisible = [1,1,1,1,1];
        end
        
        qEditRadioVisible();
        
    end

%% qEditRadioVisible
    function qEditRadioVisible(~,~)
        
        qOnOff = onoff(qEditVisible);
        for i=1:5
            qEdit(i+1).Visible    = qOnOff{i};
            qRadio(i+1,1).Visible = qOnOff{i};
            qRadio(i+1,2).Visible = qOnOff{i};
        end
        
    end

%% qStringEdit
    function qStringEdit(~,~)
    
        if symCheckbox.Value==0
            for i=1:n
                qEdit(i).Enable = 'on';
                qEdit(i).String = q(i);
                qEditCallback{i};
            end
        else
        end
        
    end

%% q1EditCallback
    function q1EditCallback(~,~)

        qEditFunction(1,q1Edit.String,handles.q1Radio(1).Value);
        q1Edit.String = q(1);
        
    end

%% q2EditCallback
    function q2EditCallback(~,~)

        qEditFunction(2,q2Edit.String,handles.q2Radio(1).Value);
        q2Edit.String = q(2);
        
    end

%% q3EditCallback
    function q3EditCallback(~,~)

        qEditFunction(3,q3Edit.String,handles.q3Radio(1).Value);
        q3Edit.String = q(3);
        
    end

%% q4EditCallback
    function q4EditCallback(~,~)

        qEditFunction(4,q4Edit.String,handles.q4Radio(1).Value);
        q4Edit.String = q(4);
        
    end

%% q5EditCallback
    function q5EditCallback(~,~)

        qEditFunction(5,q5Edit.String,handles.q5Radio(1).Value);
        q5Edit.String = q(5);
        
    end

%% q6EditCallback
    function q6EditCallback(~,~)

        qEditFunction(6,q6Edit.String,handles.q6Radio(1).Value);
        q6Edit.String = q(6);
        
    end

%% qEditFunction
    function qEditFunction(i,qEditString,qRadio1Value)
        
        q_string = qEditString;
        q_trial = str2double(q_string);
                
        % returns previous value if input is not numeric, pi or 
        % product of by a single digit number
        if qRadio1Value==1                              % if q1 is radian
            q(i) = numCheck(q_string,q_trial,q(i));
            theta(i) = q(i);                            % set joint variable as theta
        else                                            % if q1 is degree
            if (isnan(q_trial))                         % if it is non-numeric return prev.
            else                                        % if it is numeric output will be input
                q(i) = q_trial;
            end
            d(i) = q(i);                                % set joint variable as d
        end
        
    end

%% q1RadioCallback
    function q1RadioCallback(Radio_q1,~)

        qRadioFunction(Radio_q1,handles.q1Radio,1);
        
        if symCheckbox.Value == 1
            qEditSym(handles.q1Radio(1).Value,q1Edit,1);
        else
        end
        
    end

%% q2RadioCallback
    function q2RadioCallback(Radio_q2,~)

        qRadioFunction(Radio_q2,handles.q2Radio,2);
        
        if symCheckbox.Value == 1
            qEditSym(handles.q2Radio(1).Value,q2Edit,2);
        else
        end
        
    end

%% q3RadioCallback
    function q3RadioCallback(Radio_q3,~)

        qRadioFunction(Radio_q3,handles.q3Radio,3);
        
        if symCheckbox.Value == 1
            qEditSym(handles.q3Radio(1).Value,q3Edit,3);
        else
        end
        
    end

%% q4RadioCallback
    function q4RadioCallback(Radio_q4,~)

        qRadioFunction(Radio_q4,handles.q4Radio,4);
        
        if symCheckbox.Value == 1
            qEditSym(handles.q4Radio(1).Value,q4Edit,4);
        else
        end
        
    end

%% q5RadioCallback
    function q5RadioCallback(Radio_q5,~)

        qRadioFunction(Radio_q5,handles.q5Radio,5);
        
        if symCheckbox.Value == 1
            qEditSym(handles.q5Radio(1).Value,q5Edit,5);
        else
        end
        
    end

%% q6RadioCallback
    function q6RadioCallback(Radio_q6,~)

        qRadioFunction(Radio_q6,handles.q6Radio,6);
        
        if symCheckbox.Value == 1
            qEditSym(handles.q6Radio(1).Value,q6Edit,6)
        else
        end
        
    end

%% qRadioFunction
    function qRadioFunction(q_iRadio,handles_qRadio,i)
        
        radioVal = radioFunction(q_iRadio,handles_qRadio);
        
        if radioVal==1
            d(i)        = 0;
            theta(i)    = q(i);
            j(i)        = 0;
        else
            d(i)        = q(i);
            theta(i)    = 0;
            j(i)        = 1;
        end

    end

%% numCheck
    function nextVal = numCheck(i_string,i_trial,prevVal)
        
        % returns previous value if input is not numeric or pi, 
        % else product/division of pi by a single digit number.
        if size(i_string) == size('pi')             % check input same size with pi
            if i_string == 'pi'                     % if it is pi output will be pi
                nextVal = pi;
            elseif (isnan(i_trial))                 % if it is non-numeric return prev.
                nextVal = prevVal;
            else                                    % if it is numeric output will be input
                nextVal = i_trial;
            end
        elseif size(i_string) == size('-pi')        % check input same size with -pi
            if i_string == '-pi'                    % if it is pi output will be -pi
                nextVal = -pi;
            elseif (isnan(i_trial))                 % if it is non-numeric return prev.
                nextVal = prevVal;
            else                                    % if it is numeric output will be input
                nextVal = i_trial;
            end
        elseif size(i_string) == size('pi/x')       % check input same size with pi/x
            if i_string(1:2) == 'pi'                % if first two char is pi
                if (isnan(str2double(i_string(4)))) % if fourth char is non-numeric
                    nextVal = prevVal;              % return previous value
                else
                    if i_string(3) == '*'           % check 3rd char. for product
                        nextVal = pi*str2double(i_string(4));
                    elseif i_string(3) == '/'       % check 3rd char. for division
                        nextVal = pi/str2double(i_string(4));
                    else                            % else return previous value
                        nextVal = prevVal;
                    end
                end
            elseif i_string(3:4) == 'pi'            % if last two char is pi
                if (isnan(str2double(i_string(1)))) % if first char is non-numeric
                    nextVal = prevVal;              % return previous value
                else
                    if i_string(2) == '*'           % check 2nd char. for product
                        nextVal = str2double(i_string(1))*pi;
                    elseif i_string(2) == '/'       % check 2nd char. for division
                        nextVal = str2double(i_string(1))/pi;
                    else                            % else return previous value
                        nextVal = prevVal;
                    end
                end
            elseif (isnan(i_trial))                 % if it is non-numeric return prev.
                nextVal = prevVal;
            else                                    % if it is numeric output will be input
                nextVal = i_trial;
            end
        elseif size(i_string) == size('-pi/x')      % check input same size with -pi/x
            if i_string(1:3) == '-pi'               % if first three char is -pi
                if (isnan(str2double(i_string(5)))) % if fifth char is non-numeric
                    nextVal = prevVal;              % return previous value
                else
                    if i_string(4) == '*'           % check 4th char. for product
                        nextVal = -pi*str2double(i_string(5));
                    elseif i_string(4) == '/'       % check 4th char. for division
                        nextVal = -pi/str2double(i_string(5));
                    else                            % else return previous value
                        nextVal = prevVal;
                    end
                end
            % if first char. is - and last two char. is pi
            elseif i_string(1) == '-' && strcmp(i_string(4:5),'pi')
                if (isnan(str2double(i_string(2)))) % if second char is non-numeric
                    nextVal = prevVal;              % return previous value
                else
                    if i_string(3) == '*'           % check 3rd char. for product
                        nextVal = -1*str2double(i_string(2))*pi;
                    elseif i_string(3) == '/'       % check 3rd char. for division
                        nextVal = -1*str2double(i_string(2))/pi;
                    else                            % else return previous value
                        nextVal = prevVal;
                    end
                end
            elseif (isnan(i_trial))                 % if it is non-numeric return prev.
                nextVal = prevVal;
            else                                    % if it is numeric output will be input
                nextVal = i_trial;
            end
        else                                        % if input size is not 2 or 4
            if (isnan(i_trial))                     % if it is non-numeric return prev.
                nextVal = prevVal;
            else                                    % if it is numeric output will be input
                nextVal = i_trial;
            end
        end
        
    end

%% radioFunction
    function [radioVal,sameRadioVal] = radioFunction(radio,handles_radio)
        
        handles = guidata(radio);
        otherRadio = handles_radio(handles_radio ~= radio);
        sameRadio  = handles_radio(handles_radio == radio);
        
        sameRadioVal = sameRadio.Value;
        
        % This selects one and deselects other
        otherRadio.Value = 0;
        sameRadio.Value  = 1;

        % This is value of the selected
        radioVal = handles_radio(1).Value;
        
    end

%% qEditSym
    function qEditSym(qRadioVal,q_iEdit,i)
        
        if qRadioVal==1
            q_iEdit.String = sprintf(theta_i{i});
        else
            q_iEdit.String = sprintf(d_i{i});
        end
        
    end

%% p3ButtonDisable
    function p3ButtonDisable(~,~)
        
        Tn_0Button.Enable       = 'off';
        JacobianButton.Enable   = 'off';
        dynamicsButton.Enable   = 'off';
        openRoboDKButton.Enable = 'off';
        
    end

%% p3ButtonEnable
    function p3ButtonEnable(~,~)
        
        Tn_0Button.Enable       = 'on';
        JacobianButton.Enable   = 'on';
        dynamicsButton.Enable   = 'on';
        openRoboDKButton.Enable = 'on';
        
    end

%% Tn_0ButtonCallback
    function Tn_0ButtonCallback(~,~)
        
        p3ButtonDisable()
        
        progressText.String = 'Calculating Transformation Matrix...';
        drawnow;
        
        % Store variables to restore after symbolic calculation
        q_temp      = q;
        d_temp      = d;
        theta_temp  = theta;
            
        if symCheckbox.Value == 0
            if handles.degRad(1).Value == 1
            else
                alpha       = deg2rad(alpha);
                theta_plus  = deg2rad(theta_plus);
                theta       = deg2rad(theta);
            end
            if handles.lenRad(1).Value == 1
                a       = 1e-3*a;
                d_plus  = 1e-3*d_plus;
                d       = 1e-3*d;
            else
            end
        else
            % Explicitly declare the variables to avoid the dynamic assignment error 
            q1=[]; q2=[]; q3=[]; q4=[]; q5=[]; q6=[];
            
            % Symbolic angle variables
            syms q1 q2 q3 q4 q5 q6

            q = [q1;q2;q3;q4;q5;q6];
            
            [~,~,~,~,alpha_sym,theta_plus_sym] = DHParameters(modelList.Value,n);

            DH = DHTable.Data;
            
            if modelList.Value == 5
                a           = DH(:,1);
                alpha       = DH(:,2);
                d_plus      = DH(:,3);
                theta_plus  = DH(:,4);
            else
                alpha       = alpha_sym;
                theta_plus  = theta_plus_sym;
            end

            theta       = sym(zeros(n,1));
            d           = sym(zeros(n,1));

            for i=1:n
                if j(i)==0
                    theta(i) = q(i);
                else
                    d(i) = q(i);
                end
            end
        end
        
        Ti_0 = Transformation(d,d_plus,theta,theta_plus,a,alpha);
        
        % Restore variables after symbolic calculation
        q       = q_temp;
        d       = d_temp;
        theta   = theta_temp;
        
        if handles.degRad(1).Value == 1
        else
            alpha       = rad2deg(alpha);
            theta_plus  = rad2deg(theta_plus);
        end
        if handles.lenRad(1).Value == 1
            a       = 1e3*a;
            d_plus  = 1e3*d_plus;
        else
        end
            
    end

%% Tn_0ButtonPrintCallback
    function Tn_0ButtonPrintCallback(~,~)
        
        progressText.String = 'Simplifiying Transformation Matrix...';
        drawnow;
        
        fprintf('T%d_0 =\n\n',n)
        if symCheckbox.Value == 0
            disp(Ti_0(:,:,n))
        else
            disp(simplify(Ti_0(:,:,n)))
        end
        progressText.String = 'Transformation Matrix Computed.';
        
        p3ButtonEnable()
        
    end

%% JacobianButtonCallback
    function JacobianButtonCallback(~,~)
        
        Tn_0ButtonCallback()
        
        progressText.String = 'Computing Jacobian...';
        drawnow;
        
        J = Jacobian(Ti_0,j);
        
    end

%% JacobianButtonPrintCallback
    function JacobianButtonPrintCallback(~,~)
        
        progressText.String = 'Simplifiying Jacobian...';
        drawnow;
        
        fprintf('J =\n\n')
        if symCheckbox.Value == 0
            disp(J(:,:,n))
        else
            disp(simplify(J(:,:,n)))
        end
        
        progressText.String = 'Jacobian Computed.';
        
        p3ButtonEnable()
        
    end

%% DynamicsButtonCallback
    function DynamicsButtonCallback(~,~)
        
        JacobianButtonCallback()
        
        progressText.String = 'Computing Dynamics...';
        drawnow;
        
        p3ButtonEnable()
        
    end

%% DynamicsButtonPrintCallback
    function DynamicsButtonPrintCallback(~,~)
        
        progressText.String = 'Dynamics Computed.';
        
    end

%% openRoboDKButtonCallback
    function openRoboDKButtonCallback(~,~)

        DH
        
        tonguc = [a alpha d_plus theta_plus]
        
        zombak = [q d theta j]
        
    end

end