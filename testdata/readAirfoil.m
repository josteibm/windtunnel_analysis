function [data_out] = readAirfoil()

data_out = struct;

%%%%%%%%%%%%%
%% read files
%%%%%%%%%%%%%
filename = 'airfoil_data.xlsx'; 

%%%%%%%%%%%%%%%%%%%%%%%
%% extract test data
%%%%%%%%%%%%%%%%%%%%%%%
[testData_val, testData_str]  = xlsread(filename);

angle = 'Vinkel';
areal = 'Areal';

testParam_str = num2cell(testData_str(1,:));
data_out.angle = testData_val(:,strmatch(angle,testData_str(1,:)));
data_out.areal = testData_val(:,strmatch(areal,testData_str(1,:)));


end
