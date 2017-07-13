%% 
% This is a run file to solve HVDC Optimal Power Flow (OPF) problem
% The data for test case is in Matpower format
% Waqquas A. Bukhsh, July 2013
% w.a.bukhsh@sms.ed.ac.uk

clear all
clc

%% Test Cases
casefiles{1} = 'case6ww'; 
casefiles{2} = 'case3_bernie'; 
casefiles{3} = 'case2'; 


%% Paramaters
ff = 1; %Choose casefile
vol_lim = 10; %Select voltage limits in percentage


%% Build Optimization Model
mpc=eval(casefiles{ff}); %load data into structure

nB = size(mpc.bus,1); %number of buses in the network
nL = size(mpc.branch,1); %number of branches in the network
nG = size(mpc.gen,1); %number of generators in the network

%
obj_file   = 'obj_fun.m'; %file to write objective function
const_file = 'const_fun.m';%file to write constraints

write_objec(obj_file,mpc.gencost); %write objective file
write_const(const_file,mpc); %write constraint file

%% Bounds on variables
%first nG variables are generators
lb(1:nG) = mpc.gen(:,10)/mpc.baseMVA;
ub(1:nG) = mpc.gen(:,9)/mpc.baseMVA;
%nG+1:nG+2*nL are the line flows
lb(nG+1:nG+2*nL) = -9900;
ub(nG+1:nG+2*nL) =  9900;

%nG+2*nL+1:nG+2*nL+nB are the voltages at the buses
lb(nG+2*nL+1:nG+2*nL+nB) = 1-vol_lim/100;
ub(nG+2*nL+1:nG+2*nL+nB) = 1+vol_lim/100;

options = optimset('Display','iter','TolFun',1e-8);
total_var=nG+nL*2+nB;

%% Solve the Optimization Problem
%Initial Point
x0=zeros(1,total_var);
x0(1:nG) = 0.5*(lb(1:nG)+ub(1:nG));
x0(nG+1:nG+2*nL) = 0.0;
x0(nG+2*nL+1:nG+2*nL+nB) = 1.0;



[x,fval,exitflag,output] = fmincon(@obj_fun,x0,...
    [],[],[],[],lb,ub,@const_fun,options);


%% OUTPUT
if exitflag==1
    fprintf('\n\n\n************************************\n');
    display('Optimization solved successfully');
    fprintf('\n************************************\n\n\n');
end

fprintf('Bus# | Voltage(p.u.)\n');
for p=1:nB  
    fprintf('%d       %4.4f\n',p,x(nG+2*nL+p));
end


fprintf('\nBus# | Generation(p.u.)\n');
for p=1:nG
    fprintf('%d       %4.4f\n',mpc.gen(p,1),x(p));
end
