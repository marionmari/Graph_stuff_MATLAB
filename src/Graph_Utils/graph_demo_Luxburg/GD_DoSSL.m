function GD_DoSSL2(dataset, s, K_Diff, iteration, damping, timestep, GraphTypeDiff, GraphTypeClass, K_Class, gammaVal, runs);

rand('state',0)
%dataset=1
%K_Diff = 100;
%K_Class = 100; 
%s = 2;
%iter = 1;
%GraphType_Diff=1;
%GraphType_Class=1;
%runs = 100;
num_classes=3;
lambda = 0.0;
%gammaVal = 1.5;

MuRegul=0.2;

if(dataset<10 || dataset>12)
  num_classes=3;
  y = [ ones(333,1); 2*ones(250,1); 3*ones(417,1)];
  %y = [ ones(33,1); 2*ones(25,1); 3*ones(42,1)];
  %y = [y; y];
  [X,y] = Manifold_Denoising3(dataset,s,K_Diff,iteration,0,1,GraphTypeDiff);
  num = size(X,2);
  num_classes=y(num);
  %y = [ ones(num/2,1); 2*ones(num/2,1)];
  %y = [ones(3,1); 2*ones(3,1); 3*ones(4,1)];
  % y=ones(floor(num/num_classes),1);
  % for i=2:num_classes-1
  %     y = [ y; i*ones(floor(num/num_classes),1)];
  % end
  % y = [y; num_classes*ones(num-size(y,1),1)];
else
  if(dataset==11)
    num_classes=10;
    y = [ ones(6903,1); 2*ones(7877,1); 3*ones(6990,1);  4*ones(7141,1);  5*ones(6824,1);   6*ones(6313,1); 7*ones(6876,1);  8*ones(7293,1);  9*ones(6825,1);  10*ones(6958,1);];
    num=size(y,1);
    dim=28*28;        
    string=['RESULT_data=',num2str(dataset),'_s=',num2str(s),'_KNN=',num2str(K_Diff),'_iter=',num2str(iteration),'_damp=',num2str(damping),'_timestep=',num2str(timestep),'_GraphType=',num2str(GraphTypeDiff),'.BIN']
    %fid=fopen(string);
    %[X, c]=fread(fid,inf,'float32');
    %fclose(fid);
    %num=size(X,1)/(dim)
    %X=reshape(X,dim,num);
  end
end

% transforming the multiclass labels into binary (-1,1) one-versus-all
% label set
Labels = zeros(num,num_classes);
for i=1:num_classes
  Labels(:,i) = 2*(y==i) - 1;
end

% computing the k nearest neighbors
tic
[KNN, KNNDist] = getKNN(X,K_Class);
t=toc;
disp(['Time for computation of k nearest neighbors: ', num2str(t)]);

% possible values for the number of labeled points
num_labeled_pos = num_classes*[1,2,5,10,20];
%num_labeled_pos = [3, 6, 12, 24, 48, 96, 192, 384];
%num_labeled_pos = [10, 20, 50, 100, 500, 1000, 5000, 20000, 50000];

% array for the errors and number of not classified points
error         = zeros(size(num_labeled_pos,2),runs);
not_classified =zeros(size(num_labeled_pos,2),runs);

for tt=1:size(num_labeled_pos,2)
  num_labeled = num_labeled_pos(tt); 
  
  disp(['']);
  disp([num2str(runs),' runs of dataset ',num2str(dataset)]);
  disp([num2str(iteration),' Iterations with graph type ', num2str(GraphTypeDiff),' and K =',num2str(K_Diff)]);
  disp(['Classification with graph type ',num2str(GraphTypeClass),' and K =',num2str(K_Class)]);
  disp(['Number of points: ', num2str(num),', Number of labeled points: ', num2str(num_labeled)]);
 
  % select randomly labels from the labeled set
  tic
  trainLabels = zeros(num,num_classes*runs);
  trainLabels = sparse(trainLabels);
  for i=1:runs
    %disp(['Run: ',num2str(i)]);
    % select num_labeled Labels from the Labels and ensure that there is
    % one from each class
    not_accept = 1;
    while not_accept
      indices = randperm(num);
     
      trainLabels(indices(1:num_labeled),(i-1)*num_classes+1:i*num_classes)=Labels(indices(1:num_labeled),:);
      not_accept=0;
      for j=1:num_classes
          if(sum(trainLabels(:,(i-1)*num_classes+j)==1)==0) not_accept=1; end
      end
      if(not_accept)
          trainLabels(:,(i-1)*num_classes+1:i*num_classes)=zeros(num,num_classes);
      end
    end
  end
  t=toc
  disp(['Time for generation of labels: ', num2str(t)]);
  
  % get classifier output (simultaneously for all runs) for all the labels
  tic
  output=zeros(num,num_classes*runs);
  [output,d]=getSSLClassificationFromKNN(KNNDist, KNN, trainLabels, 0, 1.0, lambda, gammaVal, GraphTypeClass,MuRegul);
  mean(d)
  t=toc
  disp(['Time for Classification: ', num2str(t)]);


  % compute final classification, final==0 corresponds to "not classified
  % -> vertex is disconnected from labeled components
  table = repmat(0:num_classes,num,1)';
  for i=1:runs    
    % augmentation is done to include a zero label which corresponds to not
    % classified
    augment = [zeros(num,1), output(:,(i-1)*num_classes+1:i*num_classes)];
    final = table( min( augment == repmat(max(augment(:,2:num_classes+1),[],2),1,num_classes+1), [ones(num,1),augment(:,2:num_classes+1)] ~=0)');
    error(tt,i) = mean(final~=y);
    not_classified(tt,i) = mean(final==0);
    %table2=1:num;
    %table2(final==0);
  end
  map=[ [0,0,1];[0,1,0]; [0,0,0]; [1,0,0]; [1,1,0] ; [0,1,1]; [1,0,1] ];
  figure
  hold on      
  scatter(X(1,:),X(2,:),5,sign(output(:,1)),'filled');	  
  colormap(map);
  grid on
  view(2)
  hold off
      %colormap(hsv(128));
  [error(tt,:)', not_classified(tt,:)'];
  mean_error(tt) = mean(error(tt,:));
  disp(['Mean error: ', num2str(mean_error(tt))]);
  mean_not_classified(tt) = mean(not_classified(tt,:));
  disp(['Mean of not classified points: ', num2str(mean_not_classified(tt))]);
  std_error(tt)  = sqrt(var(error(tt,:)));
  disp(['Standard deviation of the error: ', num2str(std_error(tt))]);
end

filename = ['SSL_data=',num2str(dataset),'_s=',num2str(s),'_KNN=',num2str(K_Diff),'_iter=',num2str(iteration),'_damp=',num2str(damping),'_timestep=',num2str(timestep),'_GraphTypeDiff=',num2str(GraphTypeDiff),'_GraphTypeClass=',num2str(GraphTypeClass),'_KCLass=',num2str(K_Class),'_Gamma=',num2str(gammaVal)];

save(filename,'num_labeled_pos', 'error', 'not_classified', 'mean_error', 'mean_not_classified', 'std_error')
