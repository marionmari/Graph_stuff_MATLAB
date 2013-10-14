function [output,d]=GD_PerformSSL(K,Labeled, num_classes,laplacian, lambda, MuRegul);

num=size(K,1);

% transforming the multiclass labels into binary (-1,1) one-versus-all
% label set
Labels = zeros(num,num_classes);
for i=1:num_classes
  Labels(:,i) = 2*(Labeled == i) - 1 + (Labeled == 0);
end
  
% get classifier output (simultaneously for all runs) for all the labels
tic
output=zeros(num,num_classes);
[output,d]=GD_GetSSLSolution(K,Labels, laplacian, lambda, MuRegul);
t=toc
disp(['Time for Classification: ', num2str(t)]);

