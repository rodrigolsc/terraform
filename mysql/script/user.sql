CREATE USER IF NOT EXISTS 'rodrigolsc'@'%' IDENTIFIED BY 'rodrigolsc';

CREATE DATABASE IF NOT EXISTS rodrigolsc;

ALTER DATABASE rodrigolsc
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

GRANT ALL PRIVILEGES ON petclinic.* TO 'rodrigolsc'@'%' IDENTIFIED BY 'rodrigolsc';