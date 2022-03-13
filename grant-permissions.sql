-- CS 121 Final Project Grant Permissions

-- Admin user
CREATE USER 'nfladmin'@'localhost' IDENTIFIED BY 'adminpw';
-- Client user
CREATE USER 'nflclient'@'localhost' IDENTIFIED BY 'clientpw';

-- Granting permissions
GRANT ALL PRIVILEGES ON nfl.* TO 'nfladmin'@'localhost';
GRANT SELECT ON nfl.* TO 'nflclient'@'localhost';
FLUSH PRIVILEGES;
