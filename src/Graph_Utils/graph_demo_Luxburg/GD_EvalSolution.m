function [TestError,TrainError, not_classified,final]=GD_EvalSolution(y,output,Labeled)

num_classes=max(y);
num=length(y);

% compute final classification, final==0 corresponds to "not classified
% -> vertex is disconnected from labeled components
table = repmat(0:num_classes,num,1)';   
% augmentation is done to include a zero label which corresponds to not
% classified
augment = [zeros(num,1), output(:,1:num_classes)];
classmat = min( augment == repmat(max(augment(:,2:num_classes+1),[],2),1,num_classes+1), [ones(num,1),augment(:,2:num_classes+1)] ~=0)';
[r1,c2]=find(classmat==1); % finds the entries with the maximum of the ouput or a one at zero for not classified
[j2,mm,nn]=unique(c2);    % if more than one nonzero entry per column occurs we make it unique by the unique function
final = r1(mm)-1;   
TotalError = sum(final~=y);

TrainError = sum(final(Labeled)~=y(Labeled));
TestError= (TotalError-TrainError)/(num-length(Labeled));
TrainError = TrainError / length(Labeled);
not_classified = (sum(final==0) - sum(final(Labeled)==0))/(num-length(Labeled));
 
