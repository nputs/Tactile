function [standard_freq] = CheckStandardFreq(filename)
%Extract standard frequency

FID = fopen(filename, 'r');
if FID == -1, error('Cannot open file'), end
Data = textscan(FID, '%s', 'delimiter', '\n', 'whitespace', '');
CStr = Data{1};
fclose(FID);

IndexA = strfind(CStr, 'Stimulus_1_freq');
IndexA = find(~cellfun('isempty', IndexA), 1);

A = CStr(IndexA);
A = A{1};
A = regexprep(A, '\t', ' ');
tmp = strfind(A,' ');
A = A((tmp+1):(length(A)));
standard_freq = str2num(A);
