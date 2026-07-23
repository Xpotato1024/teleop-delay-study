function digest = sha256_text(text)
% sha256_text  Compute a deterministic SHA-256 digest for analysis identity text.

bytes = uint8(unicode2native(char(string(text)), "UTF-8"));
md = java.security.MessageDigest.getInstance("SHA-256");
md.update(bytes);
digest = upper(string(reshape(dec2hex(typecast(md.digest(), "uint8"), 2).', 1, [])));
end
