CREATE USER 'signonotron2'@'%';
#GRANT ALL PRIVILEGES ON signonotron2.* TO 'signonotron2'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'signonotron2'@'%';
SET PASSWORD FOR 'signonotron2'@'%' = PASSWORD('signonotron2');
