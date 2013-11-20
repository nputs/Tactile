function [Tac_struct] = TacAnalysis(filename)

tmp = strfind(filename,'_');
lastslash=tmp(end);
dot7 = tmp(end);


Tac_struct = importdata(filename);
Tac_struct.DataName = filename( (lastslash-3) : (dot7-1) );









