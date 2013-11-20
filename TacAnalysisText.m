function [Tac_struct] = TacAnalysisText(filename)

%For now just extract Threshold 1 (actual threshold as measured by
%Tommerdahl) and Threshold 2 (percentage correct)

FID = fopen(filename, 'r');
if FID == -1, error('Cannot open file'), end
Data = textscan(FID, '%s', 'delimiter', '\n', 'whitespace', '');
CStr = Data{1};
fclose(FID);

IndexC = strfind(CStr, 'Threshold_1');
IndexC = find(~cellfun('isempty', IndexC), 1);
IndexD = strfind(CStr, 'Threshold_2');
IndexD = find(~cellfun('isempty', IndexD), 1);

IndexE = strfind(CStr, 'Birthdate');
IndexE = find(~cellfun('isempty', IndexE), 1);
IndexF = strfind(CStr, 'Gender');
IndexF = find(~cellfun('isempty', IndexF), 1);
IndexG = strfind(CStr, 'Handedness');
IndexG = find(~cellfun('isempty', IndexG), 1);


A = CStr(IndexC);
A = A{1};
A = regexprep(A, '\t', ' ');
tmp = strfind(A,' ');
A = A((tmp+1):(length(A)));
Tac_struct.Threshold = str2num(A);

if IndexD >= 0
A = CStr(IndexD);
A = A{1};
A = regexprep(A, '\t', ' ');
tmp = strfind(A,' ');
A = A((tmp+1):(length(A)));
Tac_struct.Correct = str2num(A);
end

A = CStr(IndexE);
A = A{1};
A = regexprep(A, '\t', ' ');
tmp = strfind(A,' ');
A = A((tmp+1):(length(A)));
Tac_struct.Birthdate = A;

A = CStr(IndexF);
A = A{1};
A = regexprep(A, '\t', ' ');
tmp = strfind(A,' ');
A = A((tmp+1):(length(A)));
Tac_struct.Gender = A;

A = CStr(IndexG);
A = A{1};
A = regexprep(A, '\t', ' ');
tmp = strfind(A,' ');
A = A((tmp+1):(length(A)));
Tac_struct.Handedness = A;

%Tac_struct.DataName = filename( (lastslash-3) : (dot7-1) );

end







