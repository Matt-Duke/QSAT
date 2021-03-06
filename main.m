clear
clc
%% Satellite Specifications
% Define global satellite constants to be used by multiple functions
global Isat msat r
Isat = inertia(0.1,0.1,0.3,4);
msat=[1,0,0]*0.3; %magnetic moment for permanent magnets Am^2
r = 6371; %radius of Earth in km
% hystersis rod specs
global p Bs Hc Vhyst uhyst
uhyst=[0,1,1]; %hysteresis rod unit vectors
Hc=12; %Coercive force, A/m
Br=0.004; %remanence, T
Bs=0.025; %saturation induction, T
p=(1/Hc)*tan((pi*Br)/(2*Bs)); %constant from Flatley and Henretty
Vhyst = 95e-3*5e-3*5e-3; %rod volume in m
%% Keplerian Elements
% Parameters for ISS Orbit
mu = 398600;       % Earth�s gravitational parameter [km^3/s^2]
h    = 7.67*(405+r);   % [km^2/s] Specific angular momentum
i    = 51.64;      % [deg] Inclination
RAAN = 194.78;     % [deg] Right ascension (RA) of the ascending node
e    = 0.0007;     % Eccentricity
omega = 255.33;    % [deg] Argument of periapsis
n=[10,10]; % resolution modifier
theta = linspace(0,n(1)*360,n(1)*360*n(2));   % [deg] True anomaly, controls sim resolution and length
%ensure practicality
if length(theta)>1000000
    error('The array length is greater than 1,000,000. Are you trying to melt your computer?');
end
%% Setup Orbit
[R,~,Rmag,~] = orbit(h,i,RAAN,e,omega,theta,mu); %return the x,y,z components of the orbit path
%orbitPlot(theta,R,true,'ISS'); %show orbit!
[A,Ai] = max(Rmag); %apoapsis and index
[~,Pi] = min(Rmag); %periapsis and index
T=2*pi*sqrt((A^3)/mu); %period
fprintf('Apoapsis: %3.2f km\nPeriapsis: %3.2f km\n',Rmag(Ai),Rmag(Pi));
GEO = cart2geo(R(1,:),R(2,:),R(3,:)); %convert from ECEF cartesian to GCS
clear R
%% Simulation
% Initial Conditions
dt = (T*(max(theta)/360))/length(theta); %timestep
t=[0,dt]; %time range for ODE solver
eul0=[0,0,0]; %initial angle in rad
w0=[0,1,1]*0.001; %initial rotation in rad/s
% Run simulation function: requires orbit path & initial conditions
[EUL,W]=simulation(eul0,t,w0,theta,GEO,'high');
%plot angular velocity and angle wrt. time
figure
t=linspace(0,n(1)*T/3600,length(theta));
plot([t',t',t'],EUL);
title('Angle about XYZ axis in ECEF Frame');
xlabel('Time [hours]');
ylabel('Normalized Angle [rad]');
legend('\Omega_x','\Omega_y','\Omega_z');
figure
plot([t',t',t'],W);
title('Angular Velocity about XYZ axis');
xlabel('Time [hours]');
legend('\omega_x','\omega_y','\omega_z');
fprintf('done :)\n');
