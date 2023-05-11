CREATE TABLE `marriages` (
	`husband` varchar(100) NOT NULL,
	`wife` varchar(100) NOT NULL,
	PRIMARY KEY (`husband`)
);

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
	('ring', '戒指', 1, 0, 1)
;