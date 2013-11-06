% all_features is n x k x t, t is number of iterations

function features = precomputed_features(all_features)

  persistent num_called;

  % check to see whether i've been called
  if (isempty(num_called))
    num_called = 1;
  else
    num_called = num_called + 1;
  end

  features = all_features(:, :, num_called);

end