function idx = clusterExamples(pos, K)
  
  idx = cell(1,length(K));

  for p = 1:length(K);
      for ex = 1:length(pos)
          idx{p}(ex) = pos(ex).mix;
      end
  end

end

