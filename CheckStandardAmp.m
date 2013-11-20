function [standard_amp] = CheckStandardAmp(filename)
%Extract standard amplitude

FID = fopen(filename, 'r');
if FID == -1, error('Cannot open file'), end
Data = textscan(FID, '%s', 'delimiter', '\n', 'whitespace', '');
CStr = Data{1};
fclose(FID);

IndexA = strfind(CStr, 'Stimulus_1_amp');
IndexA = find(~cellfun('isempty', IndexA), 1);

A = CStr(IndexA);
A = A{1};
A = regexprep(A, '\t', ' ');
tmp = strfind(A,' ');
A = A((tmp+1):(length(A)));
standard_amp = str2num(A);