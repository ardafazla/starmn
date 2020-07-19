%First I ran 'VideoToFrame.m' to convert video into frames (all folders)
%Then I ran 'BorderOnImg' to put boxes on original locations of drones (all folders)

%'MainCode.m' is ran in 30 given folders with YOLOv3 outputs.
M = readmatrix('DataFolder'); % Information from YOLOv3 (see 'DataMatrixSF.m')

MN = 1; % if M/N=1(0) do(don't do) elimination due to M/N
CC = 1; % if CC=1(0) do(don't do) cross correlation

detectionfolder = zeros(length(M(:,1)),1);
for k=1:length(M(:,1))
    if(M(k,1)>0.5)
        detectionfolder(k,1)=1;
    end
end  

P = cumsum(detectionfolder); %for MN Elimination (to see how many detections in last N frames)

val = jsondecode(fileread('IR_label.json'));
temp_table1 = struct2table(val);
writetable(temp_table1,'info.txt');
orgdata = readtable('info.txt');
orgdata = table2array(orgdata); %to compare with original locations of drones

objectpresentfolder = zeros(length(orgdata(:,1)),1);
for k=1:length(orgdata(:,1))
    if(orgdata(k,1)>0)
        objectpresentfolder(k,1)=1;
    end
end %for hr hwr far calculation (see line 476)

if(MN==1)
O = cumsum(objectpresentfolder([26:length(orgdata(:,1))]));
elseif(MN==0)
O = cumsum(objectpresentfolder);
end
frameswithobject = O(end); %because during MN, I ignored first N frames for fair evaluation

txtmaxobj = ['notMaxObjectness'];
txtmn = ['eliminated:M/N'];

tempv1 = {15,25,0,0,0,0}; 
[m,n,detnumb,tfa,tious,tiou] = tempv1{:};
tempv2 = {0,0,0,0,0,0,0,0};

for k=1:length(M(:,1))
        [hit,whit,fa,ehit,ewhit,efa,iou,ious] = tempv2{:};
        matrixORG = orgdata(k,[2:5]);
        areaORG = rectint(matrixORG,matrixORG);
        x = strcat('data',num2str(k),'.jpg');
        
            if (M(k,1)~=0)
                    if((k==1) || (objectpresentfolder((k-1),1)==0) || (M(k,6)==0) || (CC==0))
                    ImgRead = strcat('border',num2str(k),'.jpg');
                    I = imread(ImgRead);
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
                    
                    if((k<=n)&&(MN==0))
                        if((P(k)>m)||(MN==0))
                            detnumb = P(k);
                            if(IOU>0.5)
                            hit=1;
                            ious=1;
                            iou=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','red');
                            elseif(IOU==0)
                            fa=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','blue');
                            elseif(IOU<0.5)
                            whit=1;
                            iou=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','yellow');
                            end                          
                        else
                            detnumb = P(k);
                            if(IOU>0.5)
                            ehit=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[255,102,102]);
                            elseif(IOU==0)
                            efa=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[72,209,204]);
                            elseif(IOU<0.5)
                            ewhit=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[255,255,224]);
                            end
                        end
                        
                    elseif((k>n)&&(MN==0))
                        if(((P(k)-P(k-n))>m)||(MN==0))
                            detnumb = P(k)-P(k-n);
                            if(IOU>0.5)
                            hit=1;
                            ious=1;
                            iou=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','red');
                            elseif(IOU==0)
                            fa=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','blue');
                            elseif(IOU<0.5)
                            whit=1;
                            iou=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','yellow');
                            end
                        else
                            detnumb = P(k)-P(k-n);
                            if(IOU>0.5)
                            ehit=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[255,102,102]);
                            elseif(IOU==0)
                            efa=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[72,209,204]);
                            elseif(IOU<0.5)
                            ewhit=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[255,255,224]);
                            end
                        end
                    end

                    if(M(k,6)==0)
                    text_str = cell(8,1);
                    text_str{1} = ['IOU:' num2str(IOU)];
                    text_str{2} = ['Hit:' num2str(hit)];
                    text_str{3} = ['Weak Hit:' num2str(whit)];
                    text_str{4} = ['False Alarm:' num2str(fa)];
                    text_str{5} = ['Detection M/N:' num2str(detnumb) '/' num2str(n)];
                    text_str{6} = ['Eliminated Hit:' num2str(ehit)];
                    text_str{7} = ['Eliminated Weak Hit:' num2str(ewhit)];
                    text_str{8} = ['Eliminated False Alarm:' num2str(efa)];
                    ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                    imwrite(ImgBorData,x);
                    
                    elseif(M(k,6)~=0)

                    e1 = M(k,7);
                    e3 = M(k,9)-M(k,7);
                    e2 = M(k,8);
                    e4 = M(k,10)-M(k,8);
                    
                    matrixYOLOb = [e1 e2 e3 e4];
                    IOU2 = rectint(matrixORG,matrixYOLOb);
                    IOU2 = IOU2/areaORG;
                    
                            if(IOU2>0.5)
                            ehit=ehit+1;
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtmaxobj,'LineWidth',3,'Color',[255,102,102]);
                            elseif(IOU2==0)
                            efa=efa+1;
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtmaxobj,'LineWidth',3,'Color',[72,209,204]);
                            elseif(IOU2<0.5)
                            ewhit=ewhit+1;
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtmaxobj,'LineWidth',3,'Color',[255,255,224]);
                            end 
                            
                        if(M(k,11)==0)
                            text_str = cell(8,1);
                            text_str{1} = ['IOU:',num2str(IOU),',',num2str(IOU2)];
                            text_str{2} = ['Hit:' num2str(hit)];
                            text_str{3} = ['Weak Hit:' num2str(whit)];
                            text_str{4} = ['False Alarm:' num2str(fa)];
                            text_str{5} = ['Detection M/N:' num2str(detnumb) '/' num2str(n)];
                            text_str{6} = ['Eliminated Hit:' num2str(ehit)];
                            text_str{7} = ['Eliminated Weak Hit:' num2str(ewhit)];
                            text_str{8} = ['Eliminated False Alarm:' num2str(efa)];
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            imwrite(ImgBorData,x);
                            
                        elseif(M(k,11)~=0)
                            
                            f1 = M(k,12);
                            f3 = M(k,14)-M(k,12);
                            f2 = M(k,13);
                            f4 = M(k,15)-M(k,13);
                    
                            matrixYOLOc = [f1 f2 f3 f4];
                            IOU3 = rectint(matrixORG,matrixYOLOc);
                            IOU3 = IOU3/areaORG;
                            
                            text_str = cell(8,1);
                            text_str{1} = ['IOU:',num2str(IOU),',',num2str(IOU2),',',num2str(IOU3)];
                            text_str{2} = ['Hit:' num2str(hit)];
                            text_str{3} = ['Weak Hit:' num2str(whit)];
                            text_str{4} = ['False Alarm:' num2str(fa)];
                            text_str{5} = ['Detection M/N:' num2str(detnumb) '/' num2str(n)];
                            text_str{6} = ['Eliminated Hit:' num2str(ehit)];
                            text_str{7} = ['Eliminated Weak Hit:' num2str(ewhit)];
                            text_str{8} = ['Eliminated False Alarm:' num2str(efa)];
                            if(IOU3>0.5)
                            ehit=ehit+1;
                            text_str{6} = ['Eliminated Hit:' num2str(ehit)];
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOc,txtmaxobj,'LineWidth',3,'Color',[255,102,102]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            elseif(IOU3==0)
                            efa=efa+1;
                            text_str{8} = ['Eliminated False Alarm:' num2str(efa)];
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOc,txtmaxobj,'LineWidth',3,'Color',[72,209,204]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            elseif(IOU3<0.5)
                            ewhit=ewhit+1;
                            text_str{7} = ['Eliminated Weak Hit:' num2str(ewhit)];
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',[d1 d2 d3 d4],txtmaxobj,'LineWidth',3,'Color',[255,255,224]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            end
                            imwrite(ImgBorData,x);
                        end
                    end
                    
            elseif((objectpresentfolder((k-1),1)~=0) && (CC==1))
                    ImgRead = strcat('border',num2str(k),'.jpg');
                    I = imread(ImgRead);
                     
                    A = imread(num2str(k-1),'jpg');
                    B = imread(num2str(k),'jpg');
                    d3 = matrixYOLOa(1);
                    d4 = matrixYOLOa(1)+matrixYOLOa(3);
                    d1 = matrixYOLOa(2);
                    d2 = matrixYOLOa(2)+matrixYOLOa(4);
                    template = A((d1-1):(d2+1),(d3-1):(d4+1));
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
                    
                    if((size(template,1)>size(detection1,1)) && (size(template,2)>size(detection1,2)))
                    c1 = max(max(normxcorr2(detection1,template)));
                    elseif((size(template,1)<size(detection1,1)) && (size(template,2)<size(detection1,2)))
                    c1 = max(max(normxcorr2(template,detection1)));
                    end
                    
                    if((size(template,1)>size(detection2,1)) && (size(template,2)>size(detection2,2)))
                    c2 = max(max(normxcorr2(detection2,template)));
                    elseif((size(template,1)<size(detection2,1)) && (size(template,2)<size(detection2,2)))
                    c2 = max(max(normxcorr2(template,detection2)));
                    end
                    
                    if(M(k,11)~=0)
                    f1 = M(k,12);
                    f3 = M(k,14)-M(k,12);
                    f2 = M(k,13);
                    f4 = M(k,15)-M(k,13);
                    matrixYOLO3 = [f1 f2 f3 f4];
                    detection3 = B(M(k,13):M(k,15),M(k,12):M(k,14));
                    
                    if((size(template,1)>size(detection3,1)) && (size(template,2)>size(detection3,2)))
                    c3 = max(max(normxcorr2(detection3,template)));
                    elseif((size(template,1)<size(detection3,1)) && (size(template,2)<size(detection3,2)))
                    c3 = max(max(normxcorr2(template,detection3)));
                    end
                    
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
                    
                    if((k<=n)||(MN==0))
                        if((P(k)>m)||(MN==0))
                            detnumb = P(k);
                            if(IOU>0.5)
                            hit=1;
                            ious=1;
                            iou=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','red');
                            elseif(IOU==0)
                            fa=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','blue');
                            elseif(IOU<0.5)
                            whit=1;
                            iou=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','yellow');
                            end                          
                        else
                            detnumb = P(k);
                            if(IOU>0.5)
                            ehit=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[255,102,102]);
                            elseif(IOU==0)
                            efa=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[72,209,204]);
                            elseif(IOU<0.5)
                            ewhit=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[255,255,224]);
                            end
                        end
                        
                    elseif(k>n)
                        if((P(k)-P(k-n))>m)
                            detnumb = P(k)-P(k-n);
                            if(IOU>0.5)
                            hit=1;
                            ious=1;
                            iou=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','red');
                            elseif(IOU==0)
                            fa=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','blue');
                            elseif(IOU<0.5)
                            whit=1;
                            iou=1;
                            ImgBor = insertShape(I,'Rectangle',matrixYOLOa,'LineWidth',3,'Color','yellow');
                            end
                        else
                            detnumb = P(k)-P(k-n);
                            if(IOU>0.5)
                            ehit=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[255,102,102]);
                            elseif(IOU==0)
                            efa=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[72,209,204]);
                            elseif(IOU<0.5)
                            ewhit=1;
                            ImgBor = insertObjectAnnotation(I,'Rectangle',matrixYOLOa,txtmn,'LineWidth',3,'Color',[255,255,224]);
                            end
                        end
                    end
                    
                    if(M(k,6)~=0)

                    IOU2 = rectint(matrixORG,matrixYOLOb);
                    IOU2 = IOU2/areaORG;
                    
                            if(IOU2>0.5)
                            ehit=ehit+1;
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtmaxobj,'LineWidth',3,'Color',[255,102,102]);
                            elseif(IOU2==0)
                            efa=efa+1;
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtmaxobj,'LineWidth',3,'Color',[72,209,204]);
                            elseif(IOU2<0.5)
                            ewhit=ewhit+1;
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtmaxobj,'LineWidth',3,'Color',[255,255,224]);
                            end 
                            
                        if(M(k,11)==0)
                            text_str = cell(8,1);
                            text_str{1} = ['IOU:',num2str(IOU),',',num2str(IOU2)];
                            text_str{2} = ['Hit:' num2str(hit)];
                            text_str{3} = ['Weak Hit:' num2str(whit)];
                            text_str{4} = ['False Alarm:' num2str(fa)];
                            text_str{5} = ['Detection M/N:' num2str(detnumb) '/' num2str(n)];
                            text_str{6} = ['Eliminated Hit:' num2str(ehit)];
                            text_str{7} = ['Eliminated Weak Hit:' num2str(ewhit)];
                            text_str{8} = ['Eliminated False Alarm:' num2str(efa)];
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            imwrite(ImgBorData,x);
                            
                        elseif(M(k,11)~=0)
                            
                            IOU3 = rectint(matrixORG,matrixYOLOc);
                            IOU3 = IOU3/areaORG;
                            
                            text_str = cell(8,1);
                            text_str{1} = ['IOU:',num2str(IOU),',',num2str(IOU2),',',num2str(IOU3)];
                            text_str{2} = ['Hit:' num2str(hit)];
                            text_str{3} = ['Weak Hit:' num2str(whit)];
                            text_str{4} = ['False Alarm:' num2str(fa)];
                            if(MN==1)
                            text_str{5} = ['Detection M/N:' num2str(detnumb) '/' num2str(n)];
                            end
                            text_str{6} = ['Eliminated Hit:' num2str(ehit)];
                            text_str{7} = ['Eliminated Weak Hit:' num2str(ewhit)];
                            text_str{8} = ['Eliminated False Alarm:' num2str(efa)];
                            if(IOU3>0.5)
                            ehit=ehit+1;
                            text_str{6} = ['Eliminated Hit:' num2str(ehit)];
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOc,txtmaxobj,'LineWidth',3,'Color',[255,102,102]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            elseif(IOU3==0)
                            efa=efa+1;
                            text_str{8} = ['Eliminated False Alarm:' num2str(efa)];
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOc,txtmaxobj,'LineWidth',3,'Color',[72,209,204]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            elseif(IOU3<0.5)
                            ewhit=ewhit+1;
                            text_str{7} = ['Eliminated Weak Hit:' num2str(ewhit)];
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOc,txtmaxobj,'LineWidth',3,'Color',[255,255,224]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            end
                            imwrite(ImgBorData,x);
                        end
                    end
            end
                    
            elseif(M(k,1)==0)
                    if(areaORG>0)
                    text_str = ['Target Missed'];
                    ImgRead = strcat('border',num2str(k),'.jpg');
                    I = imread(ImgRead);
                    ImgBorData = insertText(I,[500 40],text_str);
                    imwrite(ImgBorData,x);
                    else
                    ImgRead = strcat('border',num2str(k),'.jpg');
                    I = imread(ImgRead);
                    imwrite(I,x);
                    end
            end
            tious=tious+ious;
            tiou=tiou+iou;
            tfa=tfa+fa;
            
            if((k==n) && (MN==1))
                tfa=0;
                tious=0;
                tiou=0;
            end
            
            if(k==length(M(:,1)))
                tfa = (tfa * 1500)/(length(M(:,1)));
                tious = (tious)*100/(frameswithobject);
                tiou = (tiou)*100/(frameswithobject);
                textf1 = strcat('FA Rate:',32,num2str(tfa));
                textf2 = strcat('Hit Rate:',32,num2str(tious));
                textf3 = strcat('Hit+Weakhit Rate:',32,num2str(tiou));
                info = {textf1;textf2;textf3};
                writecell(info,'info.txt');
            end
end