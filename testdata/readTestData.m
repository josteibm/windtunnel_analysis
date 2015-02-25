function [data_out] = readTestData(testrun_nr)


%date_vec = datevec(date);
%datestr = ['_',int2str(date_vec(3)),'_',int2str(date_vec(2)),'_',int2str(date_vec(1))];
filename = ['testrun' int2str(testrun_nr)]; %datestr]; 
manoData_name  = [filename '_manoData' '.xlsx'];
testData_name  = [filename '_testData' '.xlsx'];
numbering_name = [filename '_numbers'  '.xlsx'];

data = struct;
manoData  		      = xlsread([filename '/' manoData_name]);
data.manometer        = manoData;
data.no_of_datapoints = length(manoData(:,1)-2);
data.no_of_tests      = length(manoData(1,:))-1;

num = xlsread([filename '/' numbering_name]);
numbers.pipes = num(1,:)
numbers.holes = num(2,:)
[testData_val, testData_str]  = xlsread([filename '/' testData_name]);

% to do:
%	extract the other testdata as well

pitot1 = 'p1';
pitot2 = 'p2';

testParam_str = num2cell(testData_str(1,:));
data.pitot.tubenr_z0 = testData_val(:,strmatch(pitot1,testData_str(1,:))-1);
data.pitot.tubenr_z  = testData_val(:,strmatch(pitot2,testData_str(1,:))-1);

% extract pitot pressure values and pressure values
data.pitot.z0 = zeros(data.no_of_tests,1);
data.pitot.z  = zeros(data.no_of_tests,1);

for i=1:data.no_of_tests
	if data.pitot.tubenr_z0(i) == -1 && data.pitot.tubenr_z0(i) == -1
		% no valid pitot measurement, assume all measurement are valid
		data.pitot.z0(i) = 0;
		data.pitot.z(i) = 0;
		data.deltaZ{i} = [manoData(:,i+1)-manoData(:,1) (1:1:data.no_of_datapoints)']; 
	else		
		deltaZ_curr_test = zeros(data.no_of_datapoints-2,2);
		p = 1;
		for j=1:data.no_of_datapoints
			mano = manoData(j,i+1);
			if j == data.pitot.tubenr_z0(i) 
				% pitot measurement
				data.pitot.z0(i) = mano; 
			elseif j == data.pitot.tubenr_z(i)
				% pitot measurement
				data.pitot.z(i) = mano;
			else
				deltaZ_curr_test(p,:) = [mano - manoData(j,1) j]; 
				% add j as tag (indicate which sensor it came from)
				p = p + 1;
			end;
		end;
		data.deltaZ{i} = deltaZ_curr_test;
	end;
end;

data.parameters.values = testData_val;
data.parameters.text = testData_str;

end
