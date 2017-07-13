% MATLAB function to write constraints file for HVDC_OPF
% W. Bukhsh, July 2013
% w.a.bukhsh@sms.ed.ac.uk

function write_const(file,mpc)

nG = size(mpc.gen,1);
nL = size(mpc.branch,1);
nB = size(mpc.bus,1);

fid = fopen(file,'w');

fprintf(fid,'%%===MATLAB generated Constraint file===\n');
fprintf(fid,'%%===Waqquas Bukhsh, July 2013===\n\n');
fprintf(fid,'function [c ceq] = %s(x)\n\n',file(1:end-2));
fprintf(fid,'%%%%Definition og variables\n');
fprintf(fid,'%%First nG variables are real power generation. nG to nG+2*nL are variables for line flows. nG+2nL+nB are the voltages\n');

fprintf(fid,'%%%%Equality constraints\n');
fprintf(fid,'%%Power Balance Equations\n');

fprintf(fid,'ceq = [');

for p = 1:nB
    if mpc.bus(p,2)==2 || mpc.bus(p,2)==3    
        fprintf(fid,'x(%d)-%4.4f-',find(mpc.gen(:,1)==p),mpc.bus(p,3)/mpc.baseMVA);
    else
        fprintf(fid,'0-%4.4f-',mpc.bus(p,3)/mpc.baseMVA);
    end
    
    q1=(find(mpc.branch(:,[1])==p)); %from ends
    q2=(find(mpc.branch(:,[2])==p)); %to ends
    for q=1:numel(q1)
        fprintf(fid,'x(%d)-',nG+2*q1(q)-1);
    end
    for q=1:numel(q2)
        fprintf(fid,'x(%d)-',2*q2(q)+nG);
    end
    fprintf(fid,'0; \n');
end
fprintf(fid,'%%Power Flow Equations\n');

%2*nL+nG+1:nB
for p=1:nL-1
    fprintf(fid,'x(%d)-x(%d)*(x(%d)-x(%d))/%4.4f ;\n',nG+2*p-1,(mpc.branch(p,1)+2*nL+nG),(mpc.branch(p,1)+2*nL+nG),(mpc.branch(p,2)+2*nL+nG),mpc.branch(p,3));
    fprintf(fid,'x(%d)-x(%d)*(x(%d)-x(%d))/%4.4f ;\n',nG+2*p,(mpc.branch(p,2)+2*nL+nG),(mpc.branch(p,2)+2*nL+nG),(mpc.branch(p,1)+2*nL+nG),mpc.branch(p,3));
end
%print last two lines
p=nL;
fprintf(fid,'x(%d)-x(%d)*(x(%d)-x(%d))/%4.4f ;\n',nG+2*p-1,(mpc.branch(p,1)+2*nL+nG),(mpc.branch(p,1)+2*nL+nG),(mpc.branch(p,2)+2*nL+nG),mpc.branch(p,3));
fprintf(fid,'x(%d)-x(%d)*(x(%d)-x(%d))/%4.4f ];\n',nG+2*p,(mpc.branch(p,2)+2*nL+nG),(mpc.branch(p,2)+2*nL+nG),(mpc.branch(p,1)+2*nL+nG),mpc.branch(p,3));
    

% No inequality constraints
fprintf(fid,'c=[];');

