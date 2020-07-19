D = 'D:/STAR/Project/';
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.

for ii = 1:numel(N)
    T = dir(fullfile(D,N{ii},'*')); % improve by specifying the file extension.
    C = {T(~[T.isdir]).name}; % files in subfolder.
    
    cd(fullfile(D,N{ii}));
    
    val = jsondecode(fileread('IR_label.json'));
    temp_table1 = struct2table(val);
    writetable(temp_table1,'deneme.txt');
    A = readtable('deneme.txt');
    delete('deneme.txt');
    Y = size(A(:,1));

        for i = 1:Y;
            V = table2array(A(i,:));
            if V(1)==0;
                V = [-1,0,0,0,0];
            else V = V;
            end
            MyMatrix(i,:)=V;
        end
        
         for i = 1:Y;
                A = strcat(num2str(i),'.jpg');
                I = imread(A);
                S = MyMatrix(i,[2:5]);
                ImgBor = insertShape(I,'Rectangle',S,'LineWidth',3,'Color','green');
                x = strcat('border',num2str(i),'.jpg');
                imwrite(ImgBor,x);
         end
end