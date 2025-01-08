Run mainGUI.m for graphical user interface. (Recomended for Kinematics, limited Dynamics)

Run NE_invdyn2.m for numerical inverse Newton-Euler on MATLAB.
Run NE_invdyn.m for symbolic inverse Newton-Euler on MATLAB.
Run EL_invdyn.m for symbolic inverse Euler-Lagrange on MATLAB.

Run NE_fwddyn.m for numerical forward Newton-Euler on MATLAB.
Run EL_fwddyn.m for symbolic forward Euler-Lagrange on MATLAB.

Run EL_simulink.slx for inverse and forward Euler-Lagrange on Simulink.
Run NE_simulink_working.slx for for inverse and forward Newton-Euler on Simulink.

Functions used in GUI:
	DHParameters.m
	DynParameters.m
	Jacobian.m
	MDHParameters.m
	Transformation.m

Functions downloaded from MATLAB Central- File Exchange:
	dispstat.m
	LimitFigSize.m
	onoff.m

Others:
	ELinv4ELfwd.m used in EL_fwddyn.m
	NEinv4NEfwd.m used in NE_fwddyn.m
	NE_simulink_not_working.slx has better structure but not working