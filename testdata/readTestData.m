function [data_out] = readTestData(testrun_nr)

data_out = struct;

%date_vec = datevec(date);
%datestr = ['_',int2str(date_vec(3)),'_',int2str(date_vec(2)),'_',int2str(date_vec(1))];

%%%%%%%%%%%%%
%% read files
%%%%%%%%%%%%%
filename = ['testrun' int2str(testrun_nr)]; %datestr]; 
manoData_name  = [filename '_manoData' '.xlsx'];
testData_name  = [filename '_testData' '.xlsx'];
numbering_name = [filename '_numbers'  '.xlsx'];

data = struct;
manoData  		      = xlsread([filename '/' manoData_name]);
data.manometer        = manoData;

data.no_of_datapoints = length(manoData(:,1));
data.no_of_tests      = length(manoData(1,:))-1;

num = xlsread([filename '/' numbering_name]);
data.numbers.pipes = num(:,1);
data.numbers.holes = num(:,2);


%%%%%%%%%%%%%%%%%%%%%%%
%% extract tube numbers
%%%%%%%%%%%%%%%%%%%%%%%
map_max = max(data.numbers.holes);
mapping_vect = zeros(map_max,1);
data.no_of_valid_datapoints = 0;
for i=1:length(data.numbers.pipes)
    hole = data.numbers.holes(i);
    if hole ~= -1
        mapping_vect(hole)=i;
		  if hole ~= 101 && hole ~= 102
				data.no_of_valid_datapoints = data.no_of_valid_datapoints + 1; 
		  end
    end
end

% use this mapping vector to extract which tube the corresponding hole
% belongs to

%data_out.map = mapping_vect;

% create one to one2one vector
data.airfoil_tube = zeros(data.no_of_valid_datapoints,1);
k = 1;
for i=1:length(mapping_vect)
	m = mapping_vect(i);	
	if m ~= 0 && i~= 101 && i~= 102
		data.airfoil_tube(k) = i;
		k = k + 1;
	end
end
data.no_airfoil_tubes =	data.airfoil_tube(length(data.airfoil_tube));
%data_out.air_tube = data.airfoil_tube;



% to do:
%	extract the other testdata as well
%%%%%%%%%%%%%%%%%%%%%%%
%% extract test data
%%%%%%%%%%%%%%%%%%%%%%%
[testData_val, testData_str]  = xlsread([filename '/' testData_name]);

attack = 'Angrepsvinkel';
tilt = 'Rotorvinkel';
manoangle = 'Manovinkel';

testParam_str = num2cell(testData_str(1,:));
data_out.param.attack      = testData_val(:,strmatch(attack,testData_str(1,:))-1);
data_out.param.tilt        = testData_val(:,strmatch(tilt,testData_str(1,:))-1);
% do the calculation here instead?
%data_out.param.manoangle   = testData_val(:,strmatch(manoangle,testData_str(1,:))-1);
data.manoangle   = testData_val(:,strmatch(manoangle,testData_str(1,:))-1);


%%%%%%%%%%%%%%%%%%%%%%%
%% extract pressure data
%%%%%%%%%%%%%%%%%%%%%%%

data.pitot.tube1 = mapping_vect(101);
data.pitot.tube2 = mapping_vect(102);

% extract pitot pressure values and pressure values
data.pitot1  = zeros(data.no_of_tests,1);
data.pitot2  = zeros(data.no_of_tests,1);

for i=1:data.no_of_tests
	manoangle = data.manoangle(i);
	manoTubesZ  = manoData(:,i+1);
	manoTubesZ0 = manoData(:,1);

	% extract pitot pressures
	if manoTubesZ(data.pitot.tube1) == -1 && manoTubesZ(data.pitot.tube2) == -1
		% no valid pitot measurement
		data.pitot1(i) = 0;
		data.pitot2(i) = 0;
		%data.deltaZ{i} = [manoData(:,i+1)-manoData(:,1) data.airfoil_tube']; 
	else
		data.pitot1(i) = manoTubesZ(data.pitot.tube1)*sind(manoangle);
		data.pitot2(i) = manoTubesZ(data.pitot.tube2)*sind(manoangle);
	end
	
	deltaH_curr = zeros(data.no_of_valid_datapoints,2);	
	% extract airfoil pressures
	j = 1;
	for k=1:length(mapping_vect)
		tube = mapping_vect(k);
		if tube ~= 0 && k ~= 101 && k ~= 102
			z  = manoTubesZ(mapping_vect(k));
		   z0 = manoTubesZ0(mapping_vect(k));
			deltaH_curr(j,:) = [(z - z0)*sind(manoangle), k];
			j = j + 1;
		end	
	end;
	% use cell2mat(data_out.deltaZ(i)) to extract the matrix again
	data_out.deltaH{i} = deltaH_curr;	
end;

data_out.pitot_h1 = data.pitot1;
data_out.pitot_h2 = data.pitot2;


end
