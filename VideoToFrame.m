D = 'D:/STAR/Project/';
S = dir(fullfile(D,'*'));
N = setdiff({S([S.isdir]).name},{'.','..'}); % list of subfolders of D.
for ii = 1:numel(N)
    T = dir(fullfile(D,N{ii},'*')); % improve by specifying the file extension.
    C = {T(~[T.isdir]).name}; % files in subfolder.
    
    cd(fullfile(D,N{ii}));
    
        F = fullfile(D,N{ii},C{1})
        
        v = VideoReader(F);
        y = v.NumberOfFrames;
        
        for i = 1:y;
            file = read(v,i);
            x = strcat(num2str(i),'.jpg');
            imwrite(file,x);
        end
end