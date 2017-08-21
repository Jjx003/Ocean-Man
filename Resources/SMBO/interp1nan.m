function Vq = interp1nan(X,V,Xq)
%INTERP1NAN One-dimensional cubic interpolation with no extrapolation, and ignoring NaN values.

  idx = find(~isnan(V));
  if (isempty(idx))
    Vq = NaN*Xq;
  else
    Vq = interp1(X(idx),V(idx),Xq,'spline',NaN);
  end

end

