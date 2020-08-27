D = 'D:/STAR/Videos30/';
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.
filename = 'training.xlsx';
numb1 = 3;

for ii = 1:numel(N)
    cd(fullfile(D,N{ii}));

M = readmatrix('SquareDataFolderObj15v3');
orgdata = readmatrix('orgdata.txt');

objectpresentfolder = zeros(length(orgdata(:,1)),1);
for k=1:length(orgdata(:,1))
    if(orgdata(k,1)>0)
        objectpresentfolder(k,1)=1;
    end
end
O = cumsum(objectpresentfolder);
frameswithobject = O(end);

tfa=0;
tious=0;
tiou=0;

  for k=1:length(M(:,1))
        hit=0;
        fa=0;
        whit=0;
        iou=0;
        ious=0;
        matrixORG = orgdata(k,[2:5]);
        areaORG = rectint(matrixORG,matrixORG);
        
        if(orgdata(k,1)~=(-1))
            if (M(k,1)~=0)
                
                    d1 = M(k,2);
                    d3 = M(k,4)-M(k,2);
                    d2 = M(k,3);
                    d4 = M(k,5)-M(k,3);
                    
                    matrixYOLO = [d1 d2 d3 d4];
                    
                    if(orgdata(k,1)~=0)
                    IOU = rectint(matrixORG,matrixYOLO);
                    IOU = IOU/areaORG;
                    elseif(orgdata(k,1)==0)
                    IOU = 0;
                    end
                    
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
                    
                    if(M(k,6)~=0)

                    d1 = M(k,7);
                    d3 = M(k,9)-M(k,7);
                    d2 = M(k,8);
                    d4 = M(k,10)-M(k,8);
                    
                    matrixYOLO = [d1 d2 d3 d4];
                    IOU2 = rectint(matrixORG,matrixYOLO);
                    IOU2 = IOU2/areaORG;
                    
                            if(IOU2>0.5)
                            hit=hit+1;
                            ious=1;
                            iou=1;
                            elseif(IOU2==0)
                            fa=fa+1;                           
                            elseif(IOU2<0.5)
                            whit=whit+1;
                            iou=1;
                            end 
                            
                        if(M(k,11)~=0)
                            
                            d1 = M(k,12);
                            d3 = M(k,14)-M(k,12);
                            d2 = M(k,13);
                            d4 = M(k,15)-M(k,13);
                    
                            matrixYOLO = [d1 d2 d3 d4];
                            IOU3 = rectint(matrixORG,matrixYOLO);
                            IOU3 = IOU3/areaORG;
                            
                            if(IOU3>0.5)
                            hit=hit+1;
                            ious=1;
                            iou=1;
                            elseif(IOU3==0)
                            fa=fa+1;
                            elseif(IOU3<0.5)
                            whit=whit+1;
                            iou=1;
                            end
                            
                            if(M(k,16)~=0)

                            d1 = M(k,17);
                            d3 = M(k,19)-M(k,17);
                            d2 = M(k,18);
                            d4 = M(k,20)-M(k,18);
                    
                            matrixYOLO = [d1 d2 d3 d4];
                            IOU4 = rectint(matrixORG,matrixYOLO);
                            IOU4 = IOU4/areaORG;
                    
                            if(IOU4>0.5)
                            hit=hit+1;
                            ious=1;
                            iou=1;
                            elseif(IOU4==0)
                            fa=fa+1;                           
                            elseif(IOU4<0.5)
                            whit=whit+1;
                            iou=1;
                            end
                            end
                        end
                    end
            end
        end
            tious=tious+ious;
            tiou=tiou+iou;
            tfa=tfa+fa;  
  end
                tfa = (tfa * 1500)/(length(M(:,1)));
                tious = (tious)*100/(frameswithobject);
                tiou = (tiou)*100/(frameswithobject);
                textf1 = strcat(num2str(tfa));
                textf2 = strcat(num2str(tious));
                textf3 = strcat(num2str(tiou));
                info = {textf2,textf3,textf1};
                textf4 = strcat('B',num2str(numb1),':D',num2str(numb1));
                numb1 = numb1+1;
                cd(D);
                writecell(info,filename,'Sheet','15v3basic','Range',textf4);
end