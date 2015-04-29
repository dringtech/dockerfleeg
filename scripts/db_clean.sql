DELETE FROM mysql.user WHERE User='signonotron2' AND Host='%';
FLUSH PRIVILEGES;
DROP DATABASE IF EXISTS signonotron2_development;
DROP DATABASE IF EXISTS signonotron2_test;
