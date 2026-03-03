-- Replace password hash with your real bcrypt hash before use.
INSERT INTO users (email, password_hash, role)
VALUES ('admin@emotune.local', '$2b$12$replace_with_bcrypt_hash', 'admin');
