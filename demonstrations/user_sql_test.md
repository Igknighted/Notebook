Below is a small demonstration test I went over for a company. The answers are below the assumed information and setup bits.


Assumed information:
```
database employees
table users
userid	firstname 	lastname 	username 	password 	dateadded
1		nick 		smith 		16660 		sm660 		6/20/2014
2		fred 		jones 		16661 		jo661 		6/20/2014
3		jason 		watts 		15248 		wa248	 	6/20/2014
4 		edward 		johnson 	19824 		jo824 		6/20/2014
5 		susan 		summers 	13058 		su058 		6/20/2014
6 		jennifer 	lars 		15542 		la542 		6/20/2014
```

Statements to make assumed information into real database:
```
CREATE DATABASE employees;
USE DATABASE employees;
CREATE TABLE `users` (
  `userid` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(20) NOT NULL,
  `lastname` varchar(20) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `dateadded` v NOT NULL,
  PRIMARY KEY (`userid`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

INSERT INTO users values ('1', 'nick', 'smith', '16660', 'sm660', date('2014-6-20'));
INSERT INTO users values ('2', 'fred', 'jones', '16661', 'jo661', '2014-6-20');
INSERT INTO users values ('3', 'jason', 'watts', '15248', 'wa248', '2014-6-20');
INSERT INTO users values ('4', 'edward', 'johnson', '19824', 'jo824', '2014-6-20');
INSERT INTO users values ('5', 'susan', 'summers', '13058', 'su058', '2014-6-20');
INSERT INTO users values ('6', 'jennifer', 'lars', '15542', 'la542', '2014-6-20');
```



Question #1: (multiple answers)
-------------------------------
```
select password from users where userid = '1';
select password from users where username = '16660';
select password from users where firstname = 'nick' and lastname = 'smith';
```

Question #2:
------------
```
UPDATE users SET firstname="mack" WHERE userid='2';
```

Question #3:
------------
```
INSERT INTO users values (null, 'al', 'harrington', '14485', CONCAT(LEFT(lastname, 2), RIGHT(username, 3)), '2014-6-20');
SELECT LAST_INSERT_ID();
```

Question #4:
------------
```
<?php
if(!isset($_REQUEST['owntools']) || $_REQUEST['owntools'] == ""){
	echo 'You failed to fill in the owntools field.';
	die;
}
```


Question #5:
------------
---
"$sqla" should be "$sql"
"$roww" should be "$row"
Single quote at end of $sql initialization
No semicolon at end of $sql initialization

That's just what I noticed at a glance.
