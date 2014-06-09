function iSaveX(fname,x1)
% Save a variable, good to be called in a parallel for loop.
  fea = x1;
  save(fname,'fea');
end