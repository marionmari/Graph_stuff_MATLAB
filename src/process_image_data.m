
addpath(genpath('../'))

data_path = '../data/ImageData/';
dataset = 'MSRC_23_Nov13';     %'MSRC_9'    % 'MSRC_21' 'MSRC_21C'


% LOAD graph data
load([data_path dataset '.mat'])
A      = data;
labels = responses;
clear('data', 'responses');

%LOAD images/GT regions
[ids, imnames] = textread([data_path 'map_id2im_' dataset '.txt'], '%d %s');


PLOT = false;
count = 0;
for i=1:size(ids,1)
    
    [~, imname, ext] = fileparts(char(imnames(i)));
    
%     if strcmp(imname,'4_1_s')
%         I = imread([data_path dataset '/Images/' imname ext]);
%         size(I)
%         load([data_path dataset '/Superpixels/' imname '.mat']);
%         size(unique(SP),1)
%         size(find(graph_ind==ids(i)),1)
%     else 
%         continue
%     end
    
    % IMAGE 
    I = imread([data_path dataset '/Images/' imname ext]);
    if PLOT
        figure;
        imshow(I)
    end
    
    % GROUND TRUTH segmentation
    GT = imread([data_path dataset '/GT/' imname '.bmp']);
%     %GT = load([data_path dataset '/Labels/' imname '.regions.txt']);
    if PLOT
        figure;
        imshow(GT)
    end
    
    
    % SUPERPIXEL segmentation
    load([data_path dataset '/Superpixels/' imname '.mat']);
    if PLOT
        figure;
        cmap = colormap();
        s = RandStream('mt19937ar','Seed',0);
        cmap = cmap(randperm(s,size(cmap,1)),:);
        image(SP), colormap(cmap);
    end
    
    % number of superpixels
    if size(unique(SP),1) ~= size(find(graph_ind==ids(i)),1)
        count = count+1;
        char(imnames(i))
        size(unique(SP),1)
        size(find(graph_ind==ids(i)),1)
    end
  
    if PLOT
        break
    end
end    
count
break

figure;
image(GT), colormap(cmap);
unique(GT)
load([data_path dataset '/' 'map_label2str.mat']);
map_label2str



% map_label2str = containers.Map('KeyType','int32','ValueType','char');
% 
% map_label2str(-2) = 'foreground';
% map_label2str(-1) = 'unknown';
% map_label2str(0) = 'sky';
% map_label2str(1) = 'tree';
% map_label2str(2) = 'road';
% map_label2str(3) = 'grass';
% map_label2str(4) = 'water';
% map_label2str(5) = 'building';
% map_label2str(6) = 'mountain';
% map_label2str(7) = 'person';
% map_label2str(8) = 'cow';
% map_label2str(9) = 'sheep';
% map_label2str(10) = 'airplane';
% map_label2str(11) = 'car';
% map_label2str(12) = 'bicycle';
% map_label2str(13) = 'motorbike';
% map_label2str(14) = 'bus';
% map_label2str(15) = 'boat';
% map_label2str(16) = 'sign';
% map_label2str(17) = 'dog';
% map_label2str(18) = 'cat';
% map_label2str(19) = 'horse';
% map_label2str(20) = 'chair';
% map_label2str(21) = 'bird';
% map_label2str(22) = 'flower';
% map_label2str(23) = 'other';
% 
% save([data_path dataset '/' 'map_label2str.mat'], 'map_label2str');


% % SAVE GT images
% map_id2im = load([data_path 'map_id2im_' dataset '.txt']);
% for i=1:715
%     imname = sprintf('%0.7d',map_id2im(i,2));
% 
%     % GROUND TRUTH segmentation
%     GT = load([data_path dataset '/Labels/' imname '.regions.txt']);
% 
%     perm = [3 9 24 14 10 25 19 12 7 26 20 8 21 1 16 5 2 11 17 22 23 4 6 13 15 18];
%     cmap = jet(size(map_label2str,1));
%     cmap = cmap(perm,:);
%     imwrite(GT,cmap,[data_path dataset '/GT/' imname '.bmp' ]);
% end   

