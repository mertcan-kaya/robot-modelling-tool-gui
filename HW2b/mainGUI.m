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
    A_i            = zeros(4,4,n);
    T0_i            = zeros(4,4,n);
    J               = zeros(6,n);
    tau             = zeros(n,1);

    theta_i         = {'\x3b8_1' '\x3b8_2' '\x3b8_3' '\x3b8_4' '\x3b8_5' '\x3b8_6'};
    d_i             = {'d_1' 'd_2' 'd_3' 'd_4' 'd_5' 'd_6'};
    
    MDH_val         = 0;
    
    % GUI parameters
    pad1 = 10;
    pad2 = 7;
    pad3 = 1;

    % Initial dimensional parameters
    b6 = pad3+1;        % 2
    h6 = 19;
    b5 = b6+h6+pad2+1;	% 31
    h5 = 49;
    b4 = b5;            % 31
    h4 = h5;
    b3 = b4+h4+pad3+2;	% 62
    h3 = 193;
    b2 = b3+h3+pad2;  	% 262
    h2 = 24;
    b1 = b2+h2+pad1;   	% 296
    h1 = 50;
    
    w_main = 431;
    h_main = b1+h1+pad2+15;% 353

    % GUI element dimensions
    bH  = 23; 	% Button height
    eW  = 57;  	% Edith width
    sW  = 78;  	% Save As... width
    dW  = 60; 	% Delete width
    DHW = 50;  	% DHText width
    DPW = 65;  	% DHPara width
    cTW = 90; 	% Clear Table width
    lNW = 80;  	% linkNumText width
    lBS = 22;  	% Link button size
    lES = 20; 	% linkEdit size
    tH  = 15; 	% Text heigth
    rH  = 13;  	% Radio heigth
    DRW = 40; 	% Unit width
    aTW = 25;	% angleText width
    eH  = 17;	% edith heigth
    DTT = 62;	% DHTable from top
    qEW = 44;   % qEdit width
    rW  = 15;   % Radio width
    
    %% GUI setup
    
    mainFig             = figure(   'Visible',              'off', ...
                                    'MenuBar',              'none', ...
                                    'NumberTitle',          'off', ...
                                    'Name',                 'Robot Modeling Tool GUI v2b', ...
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
                                
    tgroup = uitabgroup('Parent', panel(2));
    tab1 = uitab('Parent', tgroup, 'Title', 'DH Parameters');
    tab2 = uitab('Parent', tgroup, 'Title', 'Mass Parameters');
    tab3 = uitab('Parent', tgroup, 'Title', 'Inertial Parameters');

    panelTab1(1)       	= uipanel(  'Visible',              'off', ...
                                    'Parent',               tab1, ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels');
                                
    panelTab1(2)      	= uipanel(  'Visible',              'off', ...
                                    'Parent',               tab1, ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels');
    
    panelTab2(1)     	= uipanel(  'Visible',              'off', ...
                                    'Parent',               tab2, ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels');
    
    panelTab3(1)     	= uipanel(  'Visible',              'off', ...
                                    'Parent',               tab3, ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels');
    
    panelTab3(2)     	= uipanel(  'Visible',              'off', ...
                                    'Parent',               tab3, ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels');
    
    panel(3)            = uipanel(  'Visible',              'off', ...
                                    'Parent',               mainFig, ...
                                    'BorderType',           'etchedin', ...
                                    'Units',                'pixels', ...
                                    'Title',                'Kinematics');
                                
    panel(4)            = uipanel(  'Visible',              'off', ...
                                    'Parent',               mainFig, ...
                                    'BorderType',           'etchedin', ...
                                    'Units',                'pixels', ...
                                    'Title',                'Dynamics');
                                
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

    
    % PanelTab1 1 ---------------------------------------------------------------

    DHParaBG       	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(1), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) DHParaCallback(bg,event));
    
    DHText              = uicontrol(DHParaBG, ...
                                    'Style',            	'text', ...
                                    'String',               'DH Type:', ...
                                    'HorizontalAlignment',	'left');
    
  	DHParaR1          	= uicontrol(DHParaBG, ...
                                    'Style',                'radiobutton',...
                                    'String',               'Standard',...
                                    'Tag',                  'Std');
              
    DHParaR2         	= uicontrol(DHParaBG, ...
                                    'Style',                'radiobutton',...
                                   	'String',               'Modified',...
                                    'Tag',                  'Mod');
                                
    DHParaBG.Visible = 'on';
    
    symCheckbox         = uicontrol('Style',                'checkbox', ...
                                    'Parent',               panelTab1(1), ...
                                    'String',               'Symbolic', ...
                                    'Callback',             @symCheckboxCallback, ...
                                    'TooltipString',      	'Make computitons symbolically');
    
    clearTableButton    = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panelTab1(1), ...
                                    'String',               'Clear Table', ...
                                    'Callback',             @clearButtonCallback);
                                                       
    % PanelTab1 2 ---------------------------------------------------------------

    linkNumText         = uicontrol('Style',                'text', ...
                                    'Parent',               panelTab1(2), ...
                                    'String',               'Number of links:', ...
                                    'HorizontalAlignment',	'left');

    nLinkButton         = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panelTab1(2), ...
                                    'String',               '-', ...
                                    'Callback',             @nLinkButtonCallback);

    pLinkButton         = uicontrol('Style',                'pushbutton', ...
                                    'Parent',               panelTab1(2), ...
                                    'String',               '+', ...
                                    'Callback',             @pLinkButtonCallback);

    linkEdit            = uicontrol('Style',               	'edit', ...
                                    'Parent',             	panelTab1(2), ...
                                    'String',             	n, ...
                                    'Callback',           	@linkEditCallback);
    
    lengthBG       	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(2), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) lengthCallback(bg,event));
    
    lengthText          = uicontrol(lengthBG, ...
                                    'Style',                'text', ...
                                    'String',               'Len:', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Distance Unit');
    
    lenUnitR1           = uicontrol(lengthBG, ...
                                    'Style',                'radiobutton', ...
                                    'String',               'mm', ...
                                    'Tag',                  'mm', ...
                                    'TooltipString',      	'Set Distance Unit as mm');
    
    lenUnitR2           = uicontrol(lengthBG, ...
                                    'Style',                'radiobutton', ...
                                    'String',               'm', ...
                                    'Tag',                  'm', ...
                                    'TooltipString',      	'Set Distance Unit as m');
    
    lengthBG.Visible = 'on';
    
    angleBG       	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(2), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) angleCallback(bg,event));
    
    angleText           = uicontrol(angleBG, ...
                                    'Style',                'text', ...
                                    'String',               'Ang:', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Angular Unit');
                        
    angUnitR1           = uicontrol(angleBG, ...
                                    'Style',                'radiobutton', ...
                                    'String',               'rad', ...
                                    'Tag',                  'rad', ...
                                    'TooltipString',      	'Set Angular Unit as radian');

    angUnitR2           = uicontrol(angleBG, ...
                                    'Style',                'radiobutton', ...
                                    'String',               'deg', ...
                                    'Tag',                  'deg', ...
                                    'TooltipString',      	'Set Angular Unit as degree');

    angleBG.Visible = 'on';
    
    panelTable        	= uipanel(  'Visible',              'on', ...
                                    'Parent',               panelTab1(2), ...
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
                                    'Parent',               panelTab1(2), ...
                                    'CellEditCallback',     @inputTableCallback);
    
    linkText            = uicontrol('Style',                'text', ...
                                    'Parent',               panelTab1(2), ...
                                    'String',               'Link', ...
                                    'HorizontalAlignment',	'left');
    
    q_iText             = uicontrol('Style',                'text', ...
                                    'Parent',               panelTab1(2), ...
                                    'String',               'q_i', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Joint Variables');
    
    revText             = uicontrol('Style',                'text', ...
                                    'Parent',               panelTab1(2), ...
                                    'String',               'R', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Revolute Joint');
	
    prisText            = uicontrol('Style',                'text', ...
                                    'Parent',               panelTab1(2), ...
                                    'String',               'P', ...
                                    'HorizontalAlignment',	'left', ...
                                    'TooltipString',      	'Prismatic Joint');
    
    q1Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panelTab1(2), ...
                                    'String',              	0, ...
                                    'Callback',            	@q1EditCallback);

    q2Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panelTab1(2), ...
                                    'String',               0, ...
                                    'Callback',            	@q2EditCallback);

    q3Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panelTab1(2), ...
                                    'String',              	0, ...
                                    'Callback',            	@q3EditCallback);

    q4Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panelTab1(2), ...
                                    'String',              	0, ...
                                    'Callback',            	@q4EditCallback);

    q5Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',              	panelTab1(2), ...
                                    'String',              	0, ...
                                    'Callback',            	@q5EditCallback);
    
    q6Edit              = uicontrol('Style',               	'edit', ...
                                    'Parent',               panelTab1(2), ...
                                    'String',              	0, ...
                                    'Callback',            	@q6EditCallback);
    
    qEdit               = [q1Edit;q2Edit;q3Edit;q4Edit;q5Edit;q6Edit];
    
    qEditCallback       = {@q1EditCallback;@q2EditCallback;@q3EditCallback; ...
                           @q4EditCallback;@q5EditCallback;@q6EditCallback};
    
    q1RadioBG     	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(2), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) q1RadioCallback(bg,event));
   	
    q1RadioR1         	= uicontrol(q1RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'R', ...
                                    'TooltipString',      	'Set Joint 1 as revolute');
    
    q1RadioR2           = uicontrol(q1RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'P', ...
                                    'TooltipString',      	'Set Joint 1 as prismatic');
	
    q1RadioBG.Visible = 'on';
    
    q2RadioBG     	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(2), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) q2RadioCallback(bg,event));
                                
    q2RadioR1           = uicontrol(q2RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'R', ...
                                    'TooltipString',      	'Set Joint 2 as revolute');

    q2RadioR2           = uicontrol(q2RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'P', ...
                                    'TooltipString',      	'Set Joint 2 as prismatic');

    q2RadioBG.Visible = 'on';
    
    q3RadioBG     	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(2), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) q3RadioCallback(bg,event));
   	
    q3RadioR1           = uicontrol(q3RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'R', ...
                                    'TooltipString',      	'Set Joint 3 as revolute');

    q3RadioR2           = uicontrol(q3RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'P', ...
                                    'TooltipString',      	'Set Joint 3 as prismatic');

    q3RadioBG.Visible = 'on';
    
    q4RadioBG     	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(2), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) q4RadioCallback(bg,event));
   	
    q4RadioR1           = uicontrol(q4RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'R', ...
                                    'TooltipString',      	'Set Joint 4 as revolute');

    q4RadioR2           = uicontrol(q4RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'P', ...
                                    'TooltipString',      	'Set Joint 4 as prismatic');

    q4RadioBG.Visible = 'on';
    
    q5RadioBG     	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(2), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) q5RadioCallback(bg,event));
   	
    q5RadioR1           = uicontrol(q5RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'R', ...
                                    'TooltipString',      	'Set Joint 5 as revolute');

    q5RadioR2           = uicontrol(q5RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'P', ...
                                    'TooltipString',      	'Set Joint 5 as prismatic');

    q5RadioBG.Visible = 'on';
    
    q6RadioBG     	= uibuttongroup('Visible',              'off',...
                                    'Parent',               panelTab1(2), ...
                                    'BorderType',           'none', ...
                                    'Units',                'pixels', ...
                                    'SelectionChangedFcn',  @(bg,event) q6RadioCallback(bg,event));
   	
    q6RadioR1           = uicontrol(q6RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'R', ...
                                    'TooltipString',      	'Set Joint 6 as revolute');
    
    q6RadioR2           = uicontrol(q6RadioBG, ...
                                    'Style',                'radiobutton', ...
                                    'Tag',                  'P', ...
                                    'TooltipString',      	'Set Joint 6 as prismatic');
    
    q6RadioBG.Visible = 'on';
   	
    qRadio = [q1RadioBG;q2RadioBG;q3RadioBG;q4RadioBG;q5RadioBG;q6RadioBG];
    
    % Panel Tab 2 & 3 -----------------------------------------------------
    
    [m,ri_h_ci,It] = DynParameters(1,n);
    
    % Panel Tab 2  ----------------------------------------------------------
    
    m_Mtx = m';
    
    c2Name = {'m'};

    mText               = uicontrol('Style',                'text', ...
                                    'Parent',               panelTab2(1), ...
                                    'String',               'Mass [kg]:', ...
                                    'HorizontalAlignment',	'left');
                                
    link2               = {'1' '2' '3' '4' '5' '6'};

    mTable          	= uitable(  'Data',                 m_Mtx, ...
                                    'ColumnName',           c2Name, ...
                                    'ColumnWidth',          {60 60 60 60}, ...
                                    'RowName',              link2(1:n), ...
                                    'Parent',               panelTab2(1));
    
    ri_h_ci_Mtx = ri_h_ci';
    
    ri_h_ciText       	= uicontrol('Style',                'text', ...
                                    'Parent',               panelTab2(1), ...
                                    'String',               'Center of Mass [m]:', ...
                                    'HorizontalAlignment',	'left');
                                
    c3Name = {'ri_h_ci(x)', 'ri_h_ci(y)', 'ri_h_ci(z)'};
    
    link3               = {'1' '2' '3' '4' '5' '6'};

    ri_h_ciTable      	= uitable(  'Data',                 ri_h_ci_Mtx, ...
                                    'ColumnName',           c3Name, ...
                                    'ColumnWidth',          {60 60 60 60}, ...
                                    'RowName',              link3(1:n), ...
                                    'Parent',               panelTab2(1));
    
    % Panel Tab 3 ---------------------------------------------------------
    
    It1_Mtx = It(:,:,1);
    
    It1Text           	= uicontrol('Style',                'text', ...
                                    'Parent',               panelTab3(1), ...
                                    'String',               'It_1:', ...
                                    'HorizontalAlignment',	'left');
    
    cIt1Name            = {'x','y','z'};
    linkIt1             = {'x' 'y' 'z'};

    It1Table          	= uitable(  'Data',                 It1_Mtx, ...
                                    'ColumnName',           cIt1Name, ...
                                    'ColumnWidth',          {40 40 40}, ...
                                    'RowName',              linkIt1, ...
                                    'Parent',               panelTab3(1));
    
    It2_Mtx = It(:,:,2);
    
    It2Text           	= uicontrol('Style',                'text', ...
                                    'Parent',               panelTab3(1), ...
                                    'String',               'It_2:', ...
                                    'HorizontalAlignment',	'left');
    
    cIt2Name            = {'x','y','z'};
    linkIt2             = {'x' 'y' 'z'};

    It2Table          	= uitable(  'Data',                 It2_Mtx, ...
                                    'ColumnName',           cIt2Name, ...
                                    'ColumnWidth',          {40 40 40}, ...
                                    'RowName',              linkIt2, ...
                                    'Parent',               panelTab3(1));
    
    It3_Mtx = It(:,:,3);
    
    It3Text           	= uicontrol('Style',                'text', ...
                                    'Parent',               panelTab3(1), ...
                                    'String',               'It_3:', ...
                                    'HorizontalAlignment',	'left');
    
    cIt3Name            = {'x','y','z'};
    linkIt3             = {'x' 'y' 'z'};

    It3Table          	= uitable(  'Data',                 It3_Mtx, ...
                                    'ColumnName',           cIt3Name, ...
                                    'ColumnWidth',          {40 40 40}, ...
                                    'RowName',              linkIt3, ...
                                    'Parent',               panelTab3(1));
    
    It4_Mtx = It(:,:,4);
    
    It4Text           	= uicontrol('Style',                'text', ...
                                    'Parent',               panelTab3(2), ...
                                    'String',               'It_4:', ...
                                    'HorizontalAlignment',	'left');
    
    cIt4Name            = {'x','y','z'};
    linkIt4             = {'x' 'y' 'z'};

    It4Table          	= uitable(  'Data',                 It4_Mtx, ...
                                    'ColumnName',           cIt4Name, ...
                                    'ColumnWidth',          {40 40 40}, ...
                                    'RowName',              linkIt4, ...
                                    'Parent',               panelTab3(2));
    
    It5_Mtx = It(:,:,5);
    
    It5Text           	= uicontrol('Style',                'text', ...
                                    'Parent',               panelTab3(2), ...
                                    'String',               'It_5:', ...
                                    'HorizontalAlignment',	'left');
    
    cIt5Name            = {'x','y','z'};
    linkIt5             = {'x' 'y' 'z'};

    It5Table          	= uitable(  'Data',                 It5_Mtx, ...
                                    'ColumnName',           cIt5Name, ...
                                    'ColumnWidth',          {40 40 40}, ...
                                    'RowName',              linkIt5, ...
                                    'Parent',               panelTab3(2));
    
    It6_Mtx = It(:,:,6);
    
    It6Text           	= uicontrol('Style',                'text', ...
                                    'Parent',               panelTab3(2), ...
                                    'String',               'It_6:', ...
                                    'HorizontalAlignment',	'left');
    
    cIt6Name            = {'x','y','z'};
    linkIt6             = {'x' 'y' 'z'};

    It6Table          	= uitable(  'Data',                 It6_Mtx, ...
                                    'ColumnName',           cIt6Name, ...
                                    'ColumnWidth',          {40 40 40}, ...
                                    'RowName',              linkIt6, ...
                                    'Parent',               panelTab3(2));
    
    % Panel 3 ---------------------------------------------------------------
    
    TransButton       	= uicontrol('Style',              	'pushbutton', ...
                                    'Parent',             	panel(3), ...
                                    'String',             	'Transformation', ...
                                    'Callback',           	@(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                            {@(h,e)TransButtonCallback(h), ...
                                                            @(h,e)TransButtonPrintCallback(h)})), ...
                                    'Enable',             	'on');

    JacobianButton      = uicontrol('Style',               	'pushbutton', ...
                                    'Parent',              	panel(3), ...
                                    'String',             	'Jacobian', ...
                                    'Callback',            	@(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                            {@(h,e)JacobianButtonCallback(h), ...
                                                            @(h,e)JacobianButtonPrintCallback(h)})), ...
                                    'Enable',             	'on');

    % Panel 4 ---------------------------------------------------------------
    
    ELButton            = uicontrol('Style',              	'pushbutton', ...
                                    'Parent',             	panel(4), ...
                                    'String',             	'Euler-Lagrange', ...
                                    'Callback',           	@(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                            {@(h,e)ELButtonCallback(h), ...
                                                            @(h,e)ELButtonPrintCallback(h)})), ...
                                    'TooltipString',       	'Computes required torque symbolically', ...
                                    'Enable',             	'on');
    
    NEButton            = uicontrol('Style',                'pushbutton', ...
                                    'Parent',              	panel(4), ...
                                    'String',              	'Newton-Euler', ...
                                    'Callback',           	@(h,e)(cellfun(@(x)feval(x,h,e), ...
                                                            {@(h,e)NEButtonCallback(h), ...
                                                            @(h,e)NEButtonPrintCallback(h)})), ...
                                    'TooltipString',       	'Computes required torque symbolically', ...
                                    'Enable',               'on');
    
    % Panel 5 ---------------------------------------------------------------
    
    progressText        = uicontrol('Style',                'text', ...
                                    'Parent',               panel(5), ...
                                    'Units',                'pixels', ...
                                    'String',               '', ...
                                    'HorizontalAlignment',	'left');
    
    modelListCallback()
    
    mainFig.Visible = 'on';
    
    resizeFunc()
    
    panel(1).Visible = 'on';
    panel(2).Visible = 'on';
    panelTab1(1).Visible = 'on';
    panelTab1(2).Visible = 'on';
    panelTab2(1).Visible = 'on';
    panelTab3(1).Visible = 'on';
    panelTab3(2).Visible = 'on';
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
        DP1  = 7+DHW;                   % DHPara from left [84]
        DP2  = DP1+65+5;                % DHPara from left [154]
        lEL  = lNW+2*pad1+lBS-2;        % linkEdit from left [120]
        sCR  = cTW+pad1+78;            	% symCheckbox from left [178]
        p3T1 = b2V-(pad1+pad2+h1+h2+30);% Panel 3 from top 1 [b2V-93]
        p3T2 = p3T1-37;                 % Panel 3 from top 2 [b2V-127]
        DR2R = DRW+pad1+pad2+11;        % angUnit(2) from rigth [68]
        DR1R = DR2R+DRW+5;             	% angUnit(1) from rigth [113]
        aTR  = DR1R+aTW+2;             	% angleText from rigth [140]
        pTR  = 2*(pad1+2)+29;           % prisText from rigth [51]
        rTR  = pTR+15+5;               	% revText from rigth [71]
        qTR  = rTR+25+11;              	% q_iText from rigth [107]
        q2R  = 2*(pad1+2)+31;           % q2Radio from rigth [54]
        q1R  = q2R+15+5;               	% q1Radio from rigth [74]
        qER  = q1R+38+12;              	% q_iEdit from rigth [124]
        DTH  = h3V-DTT-15;            	% DHTable heigth [135]
        DTR  = 2*pad1+qER-4;           	% DHTable from rigth [140]
        qRT  = p3T2-(tH+rH+5);          % q_iRadio from top [111]
        qET  = p3T2-(tH+eH+1);      	% q_iEdit from top [107]
        
        b_h  = 23;
        b1_w = 100;
        b2_w = 69;
        b3_w = 95;
        b4_w = 92;
        b1_l = pad2;
        b2_l = b1_l+b1_w+pad2-1;
        b3_l = pad2;
        b4_l = b3_l+b3_w+pad2-1;
        b1_b = pad2;
        b2_b = pad2;
        b3_b = pad2;
        b4_b = pad2;
        
        panel(1).Position           = [pad1+1              	b1V                 fP(3)-2*pad1	h1];
        panel(2).Position           = [pad1+1             	b3-1                fP(3)-2*pad1+1  h3V+32];
        panelTab1(1).Position       = [1                    fP(4)-203           fP(3)-2*pad1-5	31];
        panelTab1(2).Position       = [1                    1                   fP(3)-2*pad1-5	h3V+1-30];
        panelTab2(1).Position       = [1                    fP(4)-345           fP(3)-2*pad1-5	173];
        panelTab3(1).Position       = [1                    fP(4)-290           fP(3)-2*pad1-5	118];
        panelTab3(2).Position       = [1                    fP(4)-411           fP(3)-2*pad1-5	118];
        panel(3).Position           = [pad1+1              	b4                  fP(3)/2-23     	h4];
        panel(4).Position           = [pad1-13+fP(3)/2      b5                  fP(3)/2-5      	h5];
        panel(5).Position           = [pad3+1             	b6                  fP(3)-2*pad3	h6];
        modelList.Position          = [pad2                 8                   fP(3)-mLR       22];
        editButton.Position         = [fP(3)-eR             8                   eW              bH];
        saveButton.Position         = [fP(3)-sR             8                   sW              bH];
        deleteButton.Position       = [fP(3)-dR             8                   dW              bH];
        DHParaBG.Position           = [pad2+1               4                   240             23];
        DHText.Position             = [0                    3                   DHW             tH];
        DHParaR1.Position           = [DP1                  2                   DPW             20];
        DHParaR2.Position           = [DP2                  2                   DPW             20];
        symCheckbox.Position        = [fP(3)-sCR-18         4                   70              22];
        clearTableButton.Position   = [fP(3)-(cTW+pad1)-21  3                   cTW             bH];
        linkNumText.Position        = [pad1-3             	p3T1-(tH+4)         lNW             tH];
        nLinkButton.Position        = [lEL-lBS          	p3T1-lBS            lBS             lBS];
        pLinkButton.Position        = [lEL+lES-4            p3T1-lBS            lBS             lBS];
        linkEdit.Position           = [lEL-2                p3T1-(lES+1)        lES             lES];
        angleBG.Position            = [fP(3)-aTR+2       	p3T1-(tH+7)         110             23];
        angleText.Position          = [1                    4                   aTW             tH];
        angUnitR1.Position          = [aTW+6            	6                   DRW             rH];
        angUnitR2.Position          = [aTW+DRW+6            6                   DRW             rH];
        lengthBG.Position           = [fP(3)-aTR-110       	p3T1-(tH+7)         110             23];
        lengthText.Position         = [1                    4                   aTW             tH];
        lenUnitR1.Position          = [aTW+4                6                   DRW             rH];
        lenUnitR2.Position          = [aTW+DRW+4            6                   DRW             rH];
        panelTable.Position         = [fP(3)-qTR-24        	pad1-3              102             DTH+1];
        DHTable.Position            = [pad1-2              	pad1-2              fP(3)-DTR+1     DTH];
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
        q1RadioBG.Position       	= [fP(3)-q1R            qRT                 35              18];
        q1RadioR1.Position         	= [1                    3                   rW              rH];
        q1RadioR2.Position          = [rW+6                 3                   rW              rH];
        q2RadioBG.Position       	= [fP(3)-q1R            qRT-18              35              18];
        q2RadioR1.Position          = [1                    3                   rW              rH];
        q2RadioR2.Position          = [rW+6                 3                   rW              rH];
        q3RadioBG.Position       	= [fP(3)-q1R            qRT-(2*18)      	35              18];
        q3RadioR1.Position          = [1                    3                   rW              rH];
        q3RadioR2.Position          = [rW+6                	3                   rW              rH];
        q4RadioBG.Position       	= [fP(3)-q1R            qRT-(3*18)      	35              18];
        q4RadioR1.Position          = [1                    3                   rW              rH];
        q4RadioR2.Position          = [rW+6                	3                   rW              rH];
        q5RadioBG.Position       	= [fP(3)-q1R            qRT-(4*18)      	35              18];
        q5RadioR1.Position          = [1                    3                   rW              rH];
        q5RadioR2.Position          = [rW+6                	3                   rW              rH];
        q6RadioBG.Position       	= [fP(3)-q1R            qRT-(5*18)      	35              18];
        q6RadioR1.Position          = [1                    3                   rW              rH];
        q6RadioR2.Position          = [rW+6                	3                   rW              rH];
        mText.Position              = [pad1-2               135+15              60              tH];
        mTable.Position             = [pad1-2              	pad1-2              97              135];
        ri_h_ciText.Position       	= [113                  135+15              120             tH];
        ri_h_ciTable.Position       = [113              	pad1-2              217             135];
        It1Text.Position           	= [pad1-2               80+15               60              tH];
        It1Table.Position          	= [pad1-2              	pad1-2              156             80];
        It2Text.Position           	= [pad1-2+156+7       	80+15               60              tH];
        It2Table.Position          	= [pad1-2+156+7       	pad1-2              156             80];
        It3Text.Position           	= [pad1-2+2*(156+7)    	80+15               60              tH];
        It3Table.Position          	= [pad1-2+2*(156+7)   	pad1-2              156             80];
        It4Text.Position           	= [pad1-2               80+15               60              tH];
        It4Table.Position          	= [pad1-2              	pad1-2              156             80];
        It5Text.Position           	= [pad1-2+156+7       	80+15               60              tH];
        It5Table.Position          	= [pad1-2+156+7       	pad1-2              156             80];
        It6Text.Position           	= [pad1-2+2*(156+7)    	80+15               60              tH];
        It6Table.Position          	= [pad1-2+2*(156+7)   	pad1-2              156             80];
        TransButton.Position       	= [b1_l                 b1_b                b1_w            b_h];
        JacobianButton.Position     = [b2_l                 b2_b                b2_w            b_h];
        ELButton.Position           = [b3_l                 b3_b                b3_w            b_h];
        NEButton.Position           = [b4_l                 b4_b                b4_w            b_h];
        progressText.Position       = [pad2-2              	0                   fP(3)-10       	16];
        
    end

%% modelListCallback
    function modelListCallback(~,~)
        
        n_old = n;
        
        if strcmp(DHParaBG.SelectedObject.Tag,'Std')
            [DH_new,~,~,j] = DHParameters(modelList.Value,n);
            [m,ri_h_ci,It] = DynParameters(modelList.Value,n);
        else
            [DH_new,~,~,j] = MDHParameters(modelList.Value,n);
            [m,ri_h_ci,It] = DynParameters(modelList.Value,n);
        end
        
        if modelList.Value~=5
            n = length(j);
            deleteButton.Enable = 'on';
            DHParaR1.Enable = 'on';
            DHParaR2.Enable = 'on';
            clearTableButton.Enable = 'off';
            linkEdit.String = n;
            DHTable.RowName	= link(1:n);
            qEditSwitchCallback();
            DHTableDisable();
            qRadioDisable();
            for i=1:n
                if j(i)==0
                    qRadio(i).Children(1).Value = 0;
                    qRadio(i).Children(2).Value = 1;
                else
                    qRadio(i).Children(1).Value = 1;
                    qRadio(i).Children(2).Value = 0;
                end
            end
        else
            deleteButton.Enable = 'off';
            DHParaBG.SelectedObject = DHParaR1;
            columnNameFunc(DHParaR1.Tag)
            DHParaR1.Enable = 'off';
            DHParaR2.Enable = 'off';
            clearTableButton.Enable = 'on';
            DHTableEnable();
            qRadioEnable();
        end
        
        dynButtonsCheck();
        saveAsState();
        
        n_diff = n-n_old;
        
        qEditAdd();
        
        if lenUnitR1.Value == 0
            DH_new(:,1) = 1e-3*DH_new(:,1);
            DH_new(:,3) = 1e-3*DH_new(:,3);
        else
        end
        
        if angUnitR1.Value == 0
            DH_new(:,2) = rad2deg(DH_new(:,2));
            DH_new(:,4) = rad2deg(DH_new(:,4));
        else
        end
        
        DH = DH_new;
        
        DHTable.Data	= DH;
        a               = DH(:,1);
        alpha           = DH(:,2);
        d_plus          = DH(:,3);
        theta_plus      = DH(:,4);
        
        qStringEdit();    
        qEditSwitchCallback();
        symCheckboxCallback();
        
        m_Mtx       = m';
        ri_h_ci_Mtx = ri_h_ci';
        It1_Mtx     = It(:,:,1);
        It2_Mtx     = It(:,:,2);
        It3_Mtx     = It(:,:,3);
        It4_Mtx     = It(:,:,4);
        It5_Mtx     = It(:,:,5);
        It6_Mtx     = It(:,:,6);
        
        mTable.Data         = m_Mtx;
        ri_h_ciTable.Data	= ri_h_ci_Mtx;
        It1Table.Data       = It1_Mtx;
        It2Table.Data       = It2_Mtx;
        It3Table.Data       = It3_Mtx;
        It4Table.Data       = It4_Mtx;
        It5Table.Data       = It5_Mtx;
        It6Table.Data       = It6_Mtx;
        
    end

%% DHParaCallback
    function DHParaCallback(~,event)
        
        columnNameFunc(event.NewValue.Tag)
        
        modelListCallback()
        
    end

%% columnNameFunc
    function columnNameFunc(NewValue)
        
        if strcmp(NewValue,'Mod')
%             tab1.Title = 'MDH Parameters';
            if verLessThan('matlab','9.0')
                % -- Code to run in MATLAB R2015b and earlier here --
                set(DHTable, 'ColumnName', {'a_i-1', 'alpha_i-1', 'd_i', 'theta_i'});
            else
                % -- Code to run in MATLAB R2016a and later here --
                DHTable.ColumnName = {'a_i-1', sprintf('\x3b1_i-1'), 'd_i', sprintf('\x3b8_i')};
            end
            MDH_val = 1;
        else
%             tab1.Title = 'DH Parameters';
            if verLessThan('matlab','9.0')
                % -- Code to run in MATLAB R2015b and earlier here --
                set(DHTable, 'ColumnName', {'a_i', 'alpha_i', 'd_i', 'theta_i'});
            else
                % -- Code to run in MATLAB R2016a and later here --
                DHTable.ColumnName = {'a_i', sprintf('\x3b1_i'), 'd_i', sprintf('\x3b8_i')};
            end
            MDH_val = 0;
        end
        
    end
%% dynButtonsCheck
    function dynButtonsCheck(~,~)
        
        if symCheckbox.Value == 1
            switch (modelList.Value)
                case 1
                    ELButton.Enable = 'on';
                    NEButton.Enable = 'on';
                case 2
                    ELButton.Enable = 'off';
                    NEButton.Enable = 'off';
                case 3
                    ELButton.Enable = 'off';
                    NEButton.Enable = 'off';
                case 4
                    ELButton.Enable = 'on';
                    NEButton.Enable = 'on';
                otherwise
                    ELButton.Enable = 'off';
                    NEButton.Enable = 'off';
            end
        else
            ELButton.Enable = 'off';
            NEButton.Enable = 'off';
        end
        
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
            DHParaR1.Enable = 'on';
            DHParaR2.Enable = 'on';
            clearTableButton.Enable = 'off';
            DHTableDisable();
            [DH,~,~,j] = DHParameters(modelList.Value,n);
            n = length(j);
            q = zeros(n,1);
            theta = zeros(n,1);
            d = zeros(n,1);
            linkEdit.String = n;
            qEditSwitchCallback();
            qRadioDisable();
            symCheckboxCallback();
            for i=1:n
                if j(i)==0
                    qRadio(i).Children(1).Value = 0;
                    qRadio(i).Children(2).Value = 1;
                else
                    qRadio(i).Children(1).Value = 1;
                    qRadio(i).Children(2).Value = 0;
                end
            end
        else
            DHParaR1.Enable = 'off';
            DHParaR2.Enable = 'off';
            clearTableButton.Enable = 'on';
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
                if strcmp(qRadio(i).SelectedObject.Tag,'R')
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
        
        dynButtonsCheck();
        
    end

%% clearButtonCallback
    function clearButtonCallback(~,~)

        modelList.Value     = 5;
        editButton.Value    = 1;
        deleteButton.Enable = 'off';
        DHParaBG.SelectedObject = DHParaR1;
        columnNameFunc(DHParaR1.Tag)
        DHParaR1.Enable = 'off';
        DHParaR2.Enable = 'off';
        
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

%% lengthCallback
    function lengthCallback(~,event)

        % This activates the selection
        if strcmp(event.NewValue.Tag,'m')
            a       = 1e-3*DH(:,1);
            d       = 1e-3*d;
            d_plus  = 1e-3*DH(:,3);
        else
            a       = 1e3*DH(:,1);
            d       = 1e3*d;
            d_plus  = 1e3*DH(:,3);
        end

        DH(:,1) = a;
        DH(:,3) = d_plus;
        DHTable.Data = DH;

        q = theta+d;

        qStringEdit();

    end

%% angleCallback
    function angleCallback(~,event)

        % This activates the selection
        if strcmp(event.NewValue.Tag,'deg')
            alpha       = rad2deg(DH(:,2));
            theta       = rad2deg(theta);
            theta_plus  = rad2deg(DH(:,4));
        else
            alpha       = deg2rad(DH(:,2));
            theta       = deg2rad(theta);
            theta_plus  = deg2rad(DH(:,4));
        end

        DH(:,2) = alpha;
        DH(:,4) = theta_plus;
        DHTable.Data = DH;

        q = theta+d;

        qStringEdit();
            
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

%% qRadioEnable
    function qRadioEnable(~,~)
        
        for i=1:n
            qRadio(i).Children(1).Enable = 'on';
            qRadio(i).Children(2).Enable = 'on';
        end

    end

%% qRadioDisable
    function qRadioDisable(~,~)
        
        for i=1:n
            qRadio(i).Children(1).Enable = 'off';
            qRadio(i).Children(2).Enable = 'off';
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
            qEdit(i+1).Visible	= qOnOff{i};
            qRadio(i+1).Visible	= qOnOff{i};
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

        qEditFunction(1,q1Edit.String,q1RadioR1.Value);
        q1Edit.String = q(1);
        
    end

%% q2EditCallback
    function q2EditCallback(~,~)

        qEditFunction(2,q2Edit.String,q2RadioR1.Value);
        q2Edit.String = q(2);
        
    end

%% q3EditCallback
    function q3EditCallback(~,~)

        qEditFunction(3,q3Edit.String,q3RadioR1.Value);
        q3Edit.String = q(3);
        
    end

%% q4EditCallback
    function q4EditCallback(~,~)

        qEditFunction(4,q4Edit.String,q4RadioR1.Value);
        q4Edit.String = q(4);
        
    end

%% q5EditCallback
    function q5EditCallback(~,~)

        qEditFunction(5,q5Edit.String,q5RadioR1.Value);
        q5Edit.String = q(5);
        
    end

%% q6EditCallback
    function q6EditCallback(~,~)

        qEditFunction(6,q6Edit.String,q6RadioR1.Value);
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

        qRadioFunction(Radio_q1,1);
        
        if symCheckbox.Value == 1
            qEditSym(q1RadioR1.Value,q1Edit,1);
        else
        end
        
    end

%% q2RadioCallback
    function q2RadioCallback(Radio_q2,~)

        qRadioFunction(Radio_q2,2);
        
        if symCheckbox.Value == 1
            qEditSym(q2RadioR1.Value,q2Edit,2);
        else
        end
        
    end

%% q3RadioCallback
    function q3RadioCallback(Radio_q3,~)

        qRadioFunction(Radio_q3,3);
        
        if symCheckbox.Value == 1
            qEditSym(q3RadioR1.Value,q3Edit,3);
        else
        end
        
    end

%% q4RadioCallback
    function q4RadioCallback(Radio_q4,~)

        qRadioFunction(Radio_q4,4);
        
        if symCheckbox.Value == 1
            qEditSym(q4RadioR1.Value,q4Edit,4);
        else
        end
        
    end

%% q5RadioCallback
    function q5RadioCallback(Radio_q5,~)

        qRadioFunction(Radio_q5,5);
        
        if symCheckbox.Value == 1
            qEditSym(q5RadioR1.Value,q5Edit,5);
        else
        end
        
    end

%% q6RadioCallback
    function q6RadioCallback(Radio_q6,~)

        qRadioFunction(Radio_q6,6);
        
        if symCheckbox.Value == 1
            qEditSym(q6RadioR1.Value,q6Edit,6)
        else
        end
        
    end

%% qRadioFunction
    function qRadioFunction(q_iRadio,i)
        
        if strcmp(q_iRadio.SelectedObject.Tag,'R')
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
        
        TransButton.Enable  	= 'off';
        JacobianButton.Enable   = 'off';
        ELButton.Enable         = 'off';
        NEButton.Enable         = 'off';
        
    end

%% p3ButtonEnable
    function p3ButtonEnable(~,~)
        
        TransButton.Enable   	= 'on';
        JacobianButton.Enable   = 'on';
        if symCheckbox.Value == 1
            ELButton.Enable         = 'on';
            NEButton.Enable         = 'on';
        else
        end
        
    end

%% TransButtonCallback
    function TransButtonCallback(~,~)
        
        p3ButtonDisable()
        
        progressText.String = 'Computing Transformation Matrix...';
        drawnow;
        
        % Store variables to restore after symbolic calculation
        q_temp      = q;
        d_temp      = d;
        theta_temp  = theta;
            
        if symCheckbox.Value == 0
            if angUnitR1.Value == 1
            else
                alpha       = deg2rad(alpha);
                theta_plus  = deg2rad(theta_plus);
                theta       = deg2rad(theta);
            end
            if lenUnitR1.Value == 1
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

            theta       = zeros(n,1,'sym');
            d           = zeros(n,1,'sym');

            for i=1:n
                if j(i)==0
                    theta(i) = q(i);
                else
                    d(i) = q(i);
                end
            end
        end
        
        [T0_i, A_i] = Transformation(d,d_plus,theta,theta_plus,a,alpha,MDH_val,symCheckbox.Value);
        
        % Restore variables after symbolic calculation
        q       = q_temp;
        d       = d_temp;
        theta   = theta_temp;
        
        if angUnitR1.Value == 1
        else
            alpha       = rad2deg(alpha);
            theta_plus  = rad2deg(theta_plus);
        end
        if lenUnitR1.Value == 1
            a       = 1e3*a;
            d_plus  = 1e3*d_plus;
        else
        end
       	
    end

%% TransButtonPrintCallback
    function TransButtonPrintCallback(~,~)
                
        if symCheckbox.Value == 0
%             fprintf('T0_%d =\n\n',n)
%             disp(T0_i(:,:,n))
            fprintf('T0_i =\n\n')
            disp(T0_i)
        else
            progressText.String = 'Simplifiying Transformation Matrix...';
            drawnow;
%             T0_iSimple = simplify(T0_i(:,:,n));
%             fprintf('T0_%d =\n\n',n)
%             disp(T0_iSimple)
            T0_iSimple = simplify(T0_i);
            fprintf('T0_i =\n\n')
            disp(T0_iSimple)
        end
        
        progressText.String = 'Transformation Matrix Computed.';
        
        p3ButtonEnable()
        
    end

%% JacobianButtonCallback
    function JacobianButtonCallback(~,~)
        
        TransButtonCallback()
        
        progressText.String = 'Computing Jacobian...';
        drawnow;
        
        J = Jacobian(T0_i,j);
        
    end

%% JacobianButtonPrintCallback
    function JacobianButtonPrintCallback(~,~)
       	
        if symCheckbox.Value == 0
            fprintf('J =\n\n')
            disp(J(:,:,n))
        else
            progressText.String = 'Simplifiying Jacobian...';
            drawnow;
            JSimple = simplify(J(:,:,n));
            fprintf('J =\n\n')
            disp(JSimple)
        end
        
        progressText.String = 'Jacobian Computed.';
        
        p3ButtonEnable()
        
    end

%% ELButtonCallback
    function ELButtonCallback(~,~)
      	
        TransButtonCallback()
        
        progressText.String = 'Computing Dynamics via Euler-Lagrange Approach...';
        drawnow;
       	
        tau = DynamicsELsym(modelList.Value,j,T0_i);
        
    end

%% ELButtonPrintCallback
    function ELButtonPrintCallback(~,~)
        
        if symCheckbox.Value == 0
            fprintf('Torque =\n\n')
            disp(tau)
        else
            progressText.String = 'Simplifiying torque...';
            drawnow;
            tauSimple = simplify(tau);
            fprintf('Torque =\n\n')
            disp(tauSimple)
        end
        
        progressText.String = 'Dynamics Computed via Euler-Lagrange Approach.';
        
        p3ButtonEnable()
        
    end

%% NEButtonCallback
    function NEButtonCallback(~,~)
      	
        TransButtonCallback()
        
        progressText.String = 'Computing Dynamics via Newton-Euler Approach...';
        drawnow;
       	
        tau = DynamicsNEsym(modelList.Value,j,T0_i);
        
    end

%% NEButtonPrintCallback
    function NEButtonPrintCallback(~,~)
        
        if symCheckbox.Value == 0
            fprintf('Torque =\n\n')
            disp(tau)
        else
            progressText.String = 'Simplifiying torque...';
            drawnow;
            tauSimple = simplify(tau);
            fprintf('Torque =\n\n')
            disp(tauSimple)
        end
        
        progressText.String = 'Dynamics Computed via Newton-Euler Approach.';
        
        p3ButtonEnable()
        
    end

%% deleteButtonCallback
    function deleteButtonCallback(~,~)
      	
        DH
        
        tonguc = [a alpha d_plus theta_plus]
        
        zombak = [q d theta j]
        
    end

end