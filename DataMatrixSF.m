m = readtable('comp4_det_test_thermal.txt');
A = table2array(m);
A(:,1) = A(:,1) - 20000000;
oldrnd = 2;
objscore = 0.5;
DataFolder = zeros(1000,15);

D = 'D:/STAR/Project/';
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'});

rnd = 2;
cd(fullfile(D,N{rnd}));

for k=1:length(A(:,1))
rnd = round(A(k,1)/10000);
len = (10^4)*rnd;
frameNumb = A(k,1)-len;

if(rnd~=oldrnd)
x = strcat('Data','Folder');
len = (10^4)*oldrnd;
OldframeNumb = A((k-1),1)-len;
SmartData=DataFolder([1:OldframeNumb],:);
writematrix(SmartData,x);
DataFolder = zeros(1000,15);
cd(fullfile(D,N{rnd}));
end

if((DataFolder(frameNumb,1)==0)&&(A(k,2)>objscore))
DataFolder(frameNumb,1)=A(k,2);
DataFolder(frameNumb,2)=A(k,3);
DataFolder(frameNumb,3)=A(k,4);
DataFolder(frameNumb,4)=A(k,5);
DataFolder(frameNumb,5)=A(k,6);

elseif((DataFolder(frameNumb,1)~=0)&&(DataFolder(frameNumb,6)==0)&&(A(k,2)>objscore))
DataFolder(frameNumb,6)=A(k,2);
DataFolder(frameNumb,7)=A(k,3);
DataFolder(frameNumb,8)=A(k,4);
DataFolder(frameNumb,9)=A(k,5);
DataFolder(frameNumb,10)=A(k,6);

elseif((DataFolder(frameNumb,1)~=0)&&(DataFolder(frameNumb,6)~=0)&&(A(k,2)>objscore))
DataFolder(frameNumb,11)=A(k,2);
DataFolder(frameNumb,12)=A(k,3);
DataFolder(frameNumb,13)=A(k,4);
DataFolder(frameNumb,14)=A(k,5);
DataFolder(frameNumb,15)=A(k,6);
end

if(k==28486)
x = strcat('Data','Folder');
SmartData=DataFolder([1:frameNumb],:);
writematrix(SmartData,x);
end

oldrnd = rnd;
end