function out = normalizeFeature(fea)
    fea = fea(:);
    fea_norm = norm(fea);
    out = [fea / fea_norm; fea_norm];
end
