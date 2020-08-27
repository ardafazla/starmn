D = 'D:/STAR/Videos30/';
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.
filename = 'training.xlsx';
numb1 = 3;

objscore = 0.50;
MN = 1;
CC = 1;

for ii = 1:numel(N)
    cd(fullfile(D,N{ii}));
    
M = readmatrix('SquareDataFolderObj50v2');
orgdata = readmatrix('orgdata.txt');

objectpresentfolder = zeros(length(orgdata(:,1)),1);
for k=1:length(orgdata(:,1))
    if(orgdata(k,1)>0)
        objectpresentfolder(k,1)=1;
    end
end

O = cumsum(objectpresentfolder);
frameswithobject = O(end);
coverage = frameswithobject;

tempv1 = {15,25,0,0,0,0}; 
[m,n,detnumb,tfa,tious,tiou] = tempv1{:};
tempv2 = {0,0,0,0,0,0,0,0};
t = 1;

for k=1:length(M(:,1))
        [hit,whit,fa,ehit,ewhit,efa,iou,ious] = tempv2{:};
        matrixORG = orgdata(k,[2:5]);
        areaORG = rectint(matrixORG,matrixORG);
        
        if(orgdata(k,1)~=(-1))

            if(M(k,1)>objscore)
               detectionfolder(t,1)=1;
            else
               detectionfolder(t,1)=0;
            end

            P = cumsum(detectionfolder);

            if (M(k,1)~=0)
                    if((k==1) || (detectionfolder((t-1),1)==0) || (M(k,6)==0) || (orgdata((k-1),1)==(-1)) || (CC==0))
                    d1 = M(k,2);
                    d3 = M(k,4)-M(k,2);
                    d2 = M(k,3);
                    d4 = M(k,5)-M(k,3);
                    matrixYOLOa = [d1 d2 d3 d4];
                    
                    if(orgdata(k,1)~=0)
                    IOU = rectint(matrixORG,matrixYOLOa);
                    IOU = IOU/areaORG;
                    elseif(orgdata(k,1)==0)
                    IOU = 0;
                    end
                    
                    if(t<=n)
                        if((P(t)>m)||(MN==0))
                            if(IOU>0.5)
                            hit=1;
                            ious=1;
                            iou=1;
                            elseif(IOU==0)
                            fa=1;
                            elseif(IOU<0.5)
                            whit=1;
                            iou=1;
                            end                          
                        else
                            if(areaORG>0);
                            coverage = coverage-1;
                            end
                        end
                        
                    elseif(t>n)
                        if(((P(t)-P(t-n))>m)||(MN==0))
                            if(IOU>0.5)
                            hit=1;
                            ious=1;
                            iou=1;
                            elseif(IOU==0)
                            fa=1;
                            elseif(IOU<0.5)
                            whit=1;
                            iou=1;
                            end
                        else
                            if(areaORG>0);
                            coverage = coverage-1;
                            end
                        end
                    end
                    
            elseif((detectionfolder((t-1),1)~=0) && (CC==1))
                    A = imread(num2str(k-1),'jpg');
                    B = imread(num2str(k),'jpg');
                    y3 = matrixYOLOa(1);
                    y4 = matrixYOLOa(1)+matrixYOLOa(3);
                    y1 = matrixYOLOa(2);
                    y2 = matrixYOLOa(2)+matrixYOLOa(4);
                    detection1 = B(M(k,3):M(k,5),M(k,2):M(k,4));
                    detection2 = B(M(k,8):M(k,10),M(k,7):M(k,9));
                    
                    d1 = M(k,2);
                    d3 = M(k,4)-M(k,2);
                    d2 = M(k,3);
                    d4 = M(k,5)-M(k,3);
                    matrixYOLO1 = [d1 d2 d3 d4];
                    
                    e1 = M(k,7);
                    e3 = M(k,9)-M(k,7);
                    e2 = M(k,8);
                    e4 = M(k,10)-M(k,8);
                    matrixYOLO2 = [e1 e2 e3 e4];
                    
                    template = A((y1):(y2),(y3):(y4));
                    
                    YO(1) = [size(detection1,1)-size(template,1)];
                    YO(2) = [size(detection1,2)-size(template,2)];
                    YO(3) = [size(detection2,1)-size(template,1)];
                    YO(4)= [size(detection2,2)-size(template,2)];
                    
                    if(M(k,11)==0)
                    pro = max(YO)+1;
                    elseif(M(k,11)~=0)
                    detection3 = B(M(k,13):M(k,15),M(k,12):M(k,14));
                    YO(5) = [size(detection3,1)-size(template,1)];
                    YO(6) = [size(detection3,2)-size(template,2)];
                    pro = max(YO)+1;
                    end
                    
                    template = A((y1-pro/2):(y2+pro/2),(y3-pro/2):(y4+pro/2));
                    what1 = normxcorr2(detection1,template);
                    c1 = what1(ceil(end/2),ceil(end/2));
                    what2 = normxcorr2(detection2,template);
                    c2 = what2(ceil(end/2),ceil(end/2));
                    
                    if(M(k,11)~=0)
                    f1 = M(k,12);
                    f3 = M(k,14)-M(k,12);
                    f2 = M(k,13);
                    f4 = M(k,15)-M(k,13);
                    matrixYOLO3 = [f1 f2 f3 f4];
                    what3 = normxcorr2(detection3,template);
                    c3 = what3(ceil(end/2),ceil(end/2));
                    ms1 = max([c1,c2,c3]);
                    ms2 = median([c1,c2,c3]);
                    ms3 = min([c1,c2,c3]);
                    switch ms1
                        case c1
                            matrixYOLOa = matrixYOLO1;
                        case c2
                            matrixYOLOa = matrixYOLO2;
                        case c3
                            matrixYOLOa = matrixYOLO3;
                    end
                    switch ms2
                        case c1
                            matrixYOLOb = matrixYOLO1;
                        case c2
                            matrixYOLOb = matrixYOLO2;
                        case c3
                            matrixYOLOb = matrixYOLO3;
                    end
                    switch ms3
                        case c1
                            matrixYOLOc = matrixYOLO1;
                        case c2
                            matrixYOLOc = matrixYOLO2;
                        case c3
                            matrixYOLOc = matrixYOLO3;
                    end
                    
                    elseif(M(k,11)==0)
                    ms1 = max([c1,c2]);
                    ms2 = min([c1,c2]);
                    switch ms1
                        case c1
                            matrixYOLOa = matrixYOLO1;
                        case c2
                            matrixYOLOa = matrixYOLO2;

                    end
                    switch ms2
                        case c1
                            matrixYOLOb = matrixYOLO1;
                        case c2
                            matrixYOLOb = matrixYOLO2;
                    end
                    end
                    
                    if(orgdata(k,1)~=0)
                    IOU = rectint(matrixORG,matrixYOLOa);
                    IOU = IOU/areaORG;
                    elseif(orgdata(k,1)==0)
                    IOU = 0;
                    end
                    
                    if(t<=n)
                        if((P(t)>m)||(MN==0))
                            if(IOU>0.5)
                            hit=1;
                            ious=1;
                            iou=1;
                            elseif(IOU==0)
                            fa=1;
                            elseif(IOU<0.5)
                            whit=1;
                            iou=1;
                            end                          
                        else
                            if(areaORG>0);
                            coverage = coverage-1;
                            end
                        end
                        
                    elseif(t>n)
                        if(((P(t)-P(t-n))>m)||(MN==0))
                            if(IOU>0.5)
                            hit=1;
                            ious=1;
                            iou=1;
                            elseif(IOU==0)
                            fa=1;
                            elseif(IOU<0.5)
                            whit=1;
                            iou=1;
                            end
                        else
                            if(areaORG>0);
                            coverage = coverage-1;
                            end
                        end
                    end    
            end

            end
            t=t+1;
        end
        
            tious=tious+ious;
            tiou=tiou+iou;
            tfa=tfa+fa;
end
                clear detectionfolder;
                clear P;
                tfa = (tfa * 1500)/(length(M(:,1)));
                tious = (tious)*100/(frameswithobject);
                tiou = (tiou)*100/(frameswithobject);
                coverage = coverage*100/(frameswithobject);
                ntious = tious*(100/coverage);
                ntiou = tiou*(100/coverage);
                textf1 = strcat(num2str(tfa));
                textf2 = strcat(num2str(tious));
                textf3 = strcat(num2str(tiou));
                textf4 = strcat(num2str(coverage));
                textf5 = strcat(num2str(ntiou));
                textf6 = strcat(num2str(ntious));
                info = {textf2,textf3,textf1,textf4,textf6,textf5};
                textf7 = strcat('N',num2str(numb1),':S',num2str(numb1));
                numb1 = numb1+1;
                cd(D);
                writecell(info,filename,'Sheet','50v2CCn','Range',textf7);
end