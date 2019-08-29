clear variables


fontnames = dir('ChineseFonts/');
clear allfonts
fontcount = 0;

for i=1:length(fontnames)
    fname = fontnames(i).name;
    if ~isempty(strfind(fname,'.png'))
        [im,cmap] = imread(sprintf('ChineseFonts/%s',fname));
        greyim = reshape(cmap(im(:)+1,1),size(im));  %convert to greyscale from colormap
        fontcount = fontcount + 1;
        allfonts(:,:,fontcount) = single(greyim);
        fprintf('%s\n',fname);
    end
end

fprintf('loaded %d font styles\n',fontcount);


figure(1); clf; colormap(gray); imagesc(mean(allfonts,3)); axis image

%% Digit extraction

[r,c,l]=size(allfonts);
a=31;
b=31;
digit_set=zeros(a+1,b+1,l);
class=zeros(l,1);

for i=1:l
    % extract row with digits
    bw=im2bw(allfonts(:,:,i),0.8);
    pixels=sum(~bw,2);
    j=0;
    ind=0;
    while j<c
        j=j+1;
        if pixels(j)>0
            ind=ind+1;
            if ind==7
                % find columns that contain character
                j1=j;
                while pixels(j)>0
                    j=j+1;
                end
                j2=j-1;
                % find middle of character and take 9 pixels around
                jm=round((j1+j2)/2);
                % pause if it fails
                if (j2-j1)>40
                    %imshow(digits)
                    %pause
                end
                
                pad=a-(j2-j1);
                if 2*round(pad/2)==pad
                    digits=[ones(pad/2,c);bw(j1:j2,:);ones(pad/2,c)];
                else
                    digits=[ones(pad/2-0.5,c);bw(j1:j2,:);ones(pad/2+0.5,c)];
                end
                                    % imshow(digits)
                                   %  pause
            else
                while(pixels(j)>0)
                    j=j+1;
                end
            end
        end
    end
    
    % Extract individual digits
    pixels=sum(~digits);
    j=length(pixels);
    while pixels(j)==0
        pixels(j)=[];
        digits(:,j)=[];
        j=j-1;
    end
    while pixels(1)==0
        pixels(1)=[];
        digits(:,1)=[];
    end
    w=length(pixels)/10;
    for j=1:10 %extract and numerate the class
        n=10*i-j+1;
        class(n)=j;
        j1=round((j-1)*w)+1;
        j2=round(j*w);
        pad=b-(j2-j1);
        if 2*round(pad/2)==pad
            character=[ones(a+1,pad/2),digits(:,j1:j2),ones(a+1,pad/2)];
        else
            character=[ones(a+1,pad/2-0.5),digits(:,j1:j2),ones(a+1,pad/2+0.5)];
        end
        digit_set(:,:,n)=character;
    end
end

% Format data
imdb.images.id=1:10*l;
imdb.images.data=single(digit_set);
imdb.images.label=class';
imdb.images.set=[ones(1,7*l),2*ones(1,3*l)];