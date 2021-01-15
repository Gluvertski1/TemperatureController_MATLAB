# TemperatureController_MATLAB
A temperature controller programmed in MATLAB for graduate sensors course.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jared  4/19/2017
%
% Sensors Lab 10- Temperature Controller
%
% This program will use a constructed closed-loop temperature controller
% (LM335)circuit to control a heater. The program will acquire temperature
% at 1 second intervales once the user selects the START button on the GUI.
% The temperature volates from the temp sensor wll then be converted into
% celcius and then compared upper and lower set point temperatures and also
% compared to see if the circuit is giving reasonable values. The latter is
% an instance of error handling, i.e. if the temperature is initially out
% of range it is likely that the circuit needs to be adjusted or fixed. 
%
% The heater will turn on if the temperature is below the user defined 
% threshold it will turn the heater on and similarly if the temperature is 
% above the user defined temperature threshold the heater will turn off. 
% The user will also define a Tset value that will be used in junction with
% the Tthresh defined value accordingly. The user will then defined by
% selection on a push botton sequence box the desired output channel used
% that will send a logical high to the heater to be turned on if the
% correct conditions occur.
%
% Also, the MATLAB code below will display the temperature
% values on a graph, and in a display box. Futhermore, the user will have
% the options to start and stop the program, select input channels, and
% write the data to excel. The code below will also use general and
% specfic error handling techniques and pop up with a message box if an
% error occurs. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
