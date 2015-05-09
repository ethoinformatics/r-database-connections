DROP DATABASE IF EXISTS mysql_kenny;

CREATE DATABASE mysql_kenny;

USE mysql_kenny;

CREATE TABLE animals (
	animal_id INT ( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	animal_name VARCHAR( 100 ) NOT NULL ,
	sex SET ('male','female') ,
	animal_remarks VARCHAR( 100 )
) ENGINE = InnoDB;

CREATE TABLE social_groups (
	social_group_id  INT ( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	social_group_name VARCHAR ( 100 ) NOT NULL ,
	social_group_remarks VARCHAR ( 100 )
) ENGINE = InnoDB;

CREATE TABLE contacts (
	contact_id INT ( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	time_start DATETIME NOT NULL ,
	time_end DATETIME ,
	group_in_contact INT ( 10 ) UNSIGNED ,
	contact_remarks VARCHAR ( 100 ) ,
	FOREIGN KEY ( group_in_contact ) REFERENCES social_groups ( social_group_id ) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE focal_samples (
	focal_sample_id  INT ( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	time_start DATETIME NOT NULL ,
	focal_animal  INT ( 10 ) UNSIGNED NOT NULL ,
	focal_sample_remarks VARCHAR ( 100 ) ,
	FOREIGN KEY ( focal_animal ) REFERENCES animals ( animal_id ) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE focal_behavior (
	focal_behavior_id INT ( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
	focal_sample_id INT ( 10 ) UNSIGNED NOT NULL ,
	time_start DATETIME NOT NULL ,
	time_end DATETIME ,
	behavior VARCHAR ( 100 ) NOT NULL ,
	partner_animal INT ( 10 ) UNSIGNED ,
	interaction_direction SET('actor', 'recipient') ,
	focal_behavior_remarks VARCHAR ( 100 ) ,
	FOREIGN KEY ( focal_sample_id ) REFERENCES focal_samples ( focal_sample_id ) ON DELETE CASCADE ON UPDATE CASCADE ,
	FOREIGN KEY ( partner_animal ) REFERENCES animals ( animal_id ) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

INSERT INTO animals (animal_id, animal_name, sex, animal_remarks) VALUES
	(1, 'Bob', 'male', NULL), 
	(2, 'Bruce', 'male', NULL), 
	(3, 'Dolly', 'female', NULL), 
	(4, 'Ella', 'female', NULL), 
	(5, 'Eva', 'female', NULL), 
	(6, 'Florence', 'female', NULL), 
	(7, 'Imogen', 'female', NULL), 
	(8, 'Jack', 'male', NULL), 
	(9, 'Johnny', 'male', NULL), 
	(10, 'Karen', 'female', NULL), 
	(11, 'Lauren', 'female', NULL), 
	(12, 'Leonard', 'male', NULL), 
	(13, 'Neil', 'male', NULL), 
	(14, 'Noel', 'male', NULL), 
	(15, 'Regina', 'female', NULL), 
	(16, 'Sam', 'male', NULL), 
	(17, 'Simon', 'male', NULL), 
	(18, 'Thom', 'male', NULL), 
	(19, 'Tina', 'female', NULL), 
	(20, 'Tracy', 'female', NULL);

INSERT INTO social_groups (social_group_id, social_group_name, social_group_remarks) VALUES
	(1, 'Mountain Troop', NULL),
	(2, 'River Troop', NULL),
	(3, 'Desert Troop', NULL);

INSERT INTO contacts (contact_id, time_start, time_end, group_in_contact, contact_remarks) VALUES
	(1, '2015-05-08 14:38:29', '2015-05-08 16:12:31', 1, 'The group was very active'),
	(2, '2013-11-02 09:23:41', NULL, 2, NULL),
	(3, '2014-06-12 12:54:23', '2014-06-12 12:54:23', 1, 'Brief sighting'),
	(4, '2015-09-01 00:00:00', NULL, 1, 'This event has yet to happen');

INSERT INTO focal_samples (focal_sample_id, time_start, focal_animal, focal_sample_remarks) VALUES
	(1, '2015-05-08 14:00:00', 6, 'First focal sample'),
	(2, '2015-05-08 14:30:00', 2, 'Second focal sample');

INSERT INTO focal_behavior (focal_behavior_id, focal_sample_id, time_start, time_end, behavior, partner_animal, interaction_direction, focal_behavior_remarks) VALUES
	(1, 1, '2015-05-08 14:00:00', '2015-05-08 14:08:29', 'rest', NULL, NULL, NULL),
	(2, 1, '2015-05-08 14:08:29', '2015-05-08 14:11:01', 'groom', 2, 'actor', NULL),
	(3, 1, '2015-05-08 14:11:01', '2015-05-08 14:16:39', 'groom', 2, 'recipient', NULL),
	(4, 1, '2015-05-08 14:16:39', '2015-05-08 14:16:55', 'travel', NULL, NULL, NULL),
	(5, 1, '2015-05-08 14:16:55', '2015-05-08 14:20:00', 'rest', NULL, NULL, 'ended at 20 minutes'),
	(6, 2, '2015-05-09 09:23:00', '2015-05-09 09:28:34', 'rest', NULL, NULL, NULL),
	(7, 2, '2015-05-09 09:28:34', '2015-05-09 09:32:23', 'feed', NULL, NULL, NULL),
	(8, 2, '2015-05-09 09:32:23', '2015-05-09 09:32:23', 'scream', 9, NULL, NULL),
	(9, 2, '2015-05-09 09:32:23', '2015-05-09 09:39:20', 'travel', NULL, NULL, NULL),
	(10, 2, '2015-05-09 09:39:20', '2015-05-09 09:43:00', 'rest', NULL, NULL, NULL);