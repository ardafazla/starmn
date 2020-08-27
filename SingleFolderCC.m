MN = 1;
CC = 1;
objscore = 0.50;
 
M = readmatrix('SquareDataFolderObj50v2');
orgdata = readmatrix('orgdata.txt');

objectpresentfolder = zeros(length(orgdata(:,1)),1);
for k=1:length(orgdata(:,1))
    if(orgdata(k,1)>0)
        objectpresentfolder(k,1)=1;
    end
end %for hr hwr far calculation (see line 476)

O = cumsum(objectpresentfolder);
frameswithobject = O(end); %because during MN, I ignored first N frames for fair evaluation
coverage = frameswithobject;

txtmaxobj = ['notMaxObjectness'];
txtmn = ['eliminated:M/N'];
txtcc = ['notMaxCC'];

tempv1 = {15,25,0,0,0,0}; 
[m,n,detnumb,tfa,tious,tiou] = tempv1{:};
tempv2 = {0,0,0,0,0,0,0,0};
t=1;

for k=1:length(M(:,1))
        [hit,whit,fa,ehit,ewhit,efa,iou,ious] = tempv2{:};
        matrixORG = orgdata(k,[2:5]);
        areaORG = rectint(matrixORG,matrixORG);
        x = strcat('data',num2str(k),'.jpg');
        
        if(orgdata(k,1)~=(-1))
            
            if(M(k,1)>objscore)
               detectionfolder(t,1)=1;
            else
               detectionfolder(t,1)=0;
            end
            
            P = cumsum(detectionfolder);
            
            if (M(k,1)~=0)
                    if((k==1) || (detectionfolder((t-1),1)==0) || (M(k,6)==0) || (orgdata((k-1),1)==(-1)) || (CC==0))
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
                    
                    if(t<=n)
                        if((P(t)>m)||(MN==0))
                            detnumb = P(t);
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
                            if(areaORG>0)
                            coverage = coverage-1;
                            end
                            detnumb = P(t);
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
                        
                    elseif(t>n)
                        if(((P(t)-P(t-n))>m)||(MN==0))
                            detnumb = P(t)-P(t-n);
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
                            if(areaORG>0)
                            coverage = coverage-1;
                            end
                            detnumb = P(t)-P(t-n);
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
                    
            elseif((detectionfolder((t-1),1)~=0) && (CC==1))
                    ImgRead = strcat('border',num2str(k),'.jpg');
                    I = imread(ImgRead);
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
                            detnumb = P(t);
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
                            detnumb = P(t);
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
                        
                    elseif(t>n)
                        if((P(t)-P(t-n))>m)
                            detnumb = P(t)-P(t-n);
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
                            detnumb = P(t)-P(t-n);
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
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtcc,'LineWidth',3,'Color',[255,102,102]);
                            elseif(IOU2==0)
                            efa=efa+1;
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtcc,'LineWidth',3,'Color',[72,209,204]);
                            elseif(IOU2<0.5)
                            ewhit=ewhit+1;
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOb,txtcc,'LineWidth',3,'Color',[255,255,224]);
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
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOc,txtcc,'LineWidth',3,'Color',[255,102,102]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            elseif(IOU3==0)
                            efa=efa+1;
                            text_str{8} = ['Eliminated False Alarm:' num2str(efa)];
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOc,txtcc,'LineWidth',3,'Color',[72,209,204]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            elseif(IOU3<0.5)
                            ewhit=ewhit+1;
                            text_str{7} = ['Eliminated Weak Hit:' num2str(ewhit)];
                            ImgBor = insertObjectAnnotation(ImgBor,'Rectangle',matrixYOLOc,txtcc,'LineWidth',3,'Color',[255,255,224]);
                            ImgBorData = insertText(ImgBor,[370 40;370 65;370 90;370 115;480 40;480 65;480 90;480 115],text_str);
                            end
                            imwrite(ImgBorData,x);
                        end
                    end
            end
                    
            elseif(M(k,1)==0)
                    if((areaORG>0) && (orgdata(k,1)==1))
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
            
            t=t+1;
            %tious=tious+ious;
            %tiou=tiou+iou;
            %tfa=tfa+fa;
            elseif(orgdata(k,1)==(-1))
               ImgRead = strcat('border',num2str(k),'.jpg');
               I = imread(ImgRead);
               imwrite(I,x);
end

end
                %tfa = (tfa * 1500)/(length(M(:,1)));
                %tious = (tious)*100/(frameswithobject);
                %tiou = (tiou)*100/(frameswithobject);
                %coverage = coverage*100/(frameswithobject);
                %ntious = tious*(100/coverage);
                %ntiou = tiou*(100/coverage);