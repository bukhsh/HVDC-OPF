% MATLAB function to write objective function file for HVDC_OPF
% W. Bukhsh, July 2013
% w.a.bukhsh@sms.ed.ac.uk

function write_objec(file,gencost)

nG=size(gencost,1);

fid=fopen(file,'w');

fprintf(fid,'%%===MATLAB generated Objective file===\n');
fprintf(fid,'%%===Waqquas Bukhsh, July 2013===\n\n');
fprintf(fid,'function f = %s(x)\n\n',file(1:end-2));

fprintf(fid,'f = ');
for p = 1:nG-1
    fprintf(fid,'%4.4f*x(%d)+%4.4f+ ... \n',gencost(p,6),p,gencost(p,7));
end
fprintf(fid,'%4.4f*x(%d)+%4.4f; \n',gencost(end,6),nG,gencost(end,7));
