m = readtable('test_batch_34008.txt');
A = table2array(m);
oldrnd = 2; %deðiþtirmeyi unutma dataset için 2 training için 1
objscore = 0.45;
DataFolder = zeros(1000,20);

D = 'D:/STAR/Videos30/';
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'});

m = 0;
a = 1;
cd(fullfile(D,N{a}));

for k=1:length(A(:,1))
rnd = round(A(k,1)/10000);
len = (10^4)*rnd;
frameNumb = A(k,1)-len;

if(rnd~=oldrnd)
x = strcat('Square','Data','Folder','Obj','45','v3');
len = (10^4)*oldrnd;
OldframeNumb = A((k-1),1)-len;
SmartData=DataFolder([1:OldframeNumb],:);
writematrix(SmartData,x);
DataFolder = zeros(1000,20);
a = a+1;
cd(fullfile(D,N{a}));
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
      
elseif((DataFolder(frameNumb,1)~=0)&&(DataFolder(frameNumb,6)~=0)&&(DataFolder(frameNumb,11)==0)&&(A(k,2)>objscore))
DataFolder(frameNumb,11)=A(k,2);
DataFolder(frameNumb,12)=A(k,3);
DataFolder(frameNumb,13)=A(k,4);
DataFolder(frameNumb,14)=A(k,5);
DataFolder(frameNumb,15)=A(k,6);

elseif((DataFolder(frameNumb,1)~=0)&&(DataFolder(frameNumb,6)~=0)&&(DataFolder(frameNumb,11)~=0)&&(DataFolder(frameNumb,16)==0)&&(A(k,2)>objscore))
DataFolder(frameNumb,16)=A(k,2);
DataFolder(frameNumb,17)=A(k,3);
DataFolder(frameNumb,18)=A(k,4);
DataFolder(frameNumb,19)=A(k,5);
DataFolder(frameNumb,20)=A(k,6);

elseif((DataFolder(frameNumb,1)~=0)&&(DataFolder(frameNumb,6)~=0)&&(DataFolder(frameNumb,11)~=0)&&(DataFolder(frameNumb,16)~=0)&&(A(k,2)>objscore))
m=m+1;
end

if(k==length(A(:,1)))
x = strcat('Square','Data','Folder','Obj','45','v3');
SmartData=DataFolder([1:frameNumb],:);
writematrix(SmartData,x);
end

oldrnd = rnd;
end