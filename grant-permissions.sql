-- CS 121 Final Project Grant Permissions

-- Admin user
DROP USER 'nfladmin'@'localhost';
CREATE USER 'nfladmin'@'localhost' IDENTIFIED BY 'adminpw';
-- Client user
DROP USER 'nflclient'@'localhost';
CREATE USER 'nflclient'@'localhost' IDENTIFIED BY 'clientpw';

-- Granting permissions
GRANT ALL PRIVILEGES ON nfl.* TO 'nfladmin'@'localhost';
GRANT SELECT ON nfl.* TO 'nflclient'@'localhost';
FLUSH PRIVILEGES;
