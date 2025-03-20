CREATE DATABASE library_management;
USE library_management;

create table books (ISBN int , `Book-Title` varchar (40),`Book-Author` varchar (50),`Year-Of-Publication` VARCHAR (50),	Publisher VARCHAR(50), `Image-URL-S` varchar(100),`Image-URL-M` varchar(100),`Image-URL-L` varchar(100));
ALTER TABLE books MODIFY COLUMN `Year-Of-Publication` INT;
# drooping of some column and adding of the availibilty column in it 
alter table books drop column `Image-URL-S`, drop column `Image-URL-M`,drop column `Image-URL-L`;
ALTER TABLE books add column Availability enum('Y','N') DEFAULT 'Y';
ALTER TABLE books MODIFY COLUMN ISBN INT PRIMARY KEY;
ALTER TABLE books ADD UNIQUE (ISBN);

-- Creating user_info table
CREATE TABLE user_info (
    member_id BIGINT PRIMARY KEY ,
    name VARCHAR(30)
);

-- Creating borrower_info table
CREATE TABLE borrower_info (
    name VARCHAR(40),
    member_id BIGINT,
    isbn INT,
    issue_date DATE,
    due_date DATE,
    Fine INT DEFAULT 0,
    CONSTRAINT fk1 FOREIGN KEY (member_id) REFERENCES user_info(member_id) ON DELETE CASCADE,
    CONSTRAINT fk2 FOREIGN KEY (isbn) REFERENCES books(ISBN) ON DELETE CASCADE
);

ALTER TABLE borrower_info DROP COLUMN Fine;
select * from borrower_info;

-- Creating returned_user table
CREATE TABLE returned_user (
    member_id BIGINT,
    fine INT
);

-- Creating trigger to update book availability on borrowing
DELIMITER //
CREATE TRIGGER t1
AFTER INSERT ON borrower_info
FOR EACH ROW
BEGIN
    UPDATE books SET Availability = 'N' WHERE ISBN = NEW.isbn; 
END //
DELIMITER ;

-- Creating trigger to update book availability on return
DELIMITER //
CREATE TRIGGER t2
AFTER DELETE ON borrower_info
FOR EACH ROW
BEGIN
    UPDATE books SET Availability = 'Y' WHERE ISBN = OLD.isbn;
END //
DELIMITER ;


-- Trigger to set due date on book borrowing
DELIMITER //
CREATE TRIGGER tk3
BEFORE INSERT ON borrower_info
FOR EACH ROW
BEGIN
    SET NEW.due_date = DATE_ADD(NEW.issue_date, INTERVAL 30 DAY);
END //
DELIMITER ;

-- Trigger to handle fine calculation on return
DELIMITER //
CREATE TRIGGER tk4
AFTER DELETE ON borrower_info
FOR EACH ROW
BEGIN
    DECLARE CALCULATED_FINES INT;
    IF CURDATE() > OLD.due_date THEN 
        SET CALCULATED_FINES = DATEDIFF(CURDATE(), OLD.due_date);
    ELSE
        SET CALCULATED_FINES = 0;
    END IF;
    INSERT INTO returned_user (member_id, fine) VALUES (OLD.member_id, CALCULATED_FINES);
END //
DELIMITER ;

-- Inserting book records
INSERT INTO books (ISBN, `Book-Title`, `Book-Author`, `Year-Of-Publication`, Publisher)
VALUES (574384292, 'Helen Keller', 'Harry Smith', 2008, 'T-Series');
select * from books;
-- Inserting user records
INSERT INTO user_info (member_id,name) VALUES (34278282394,'Aakriti'), (348239437,'Himanshi'), (347828342,'Prithvi'), (346743834,'Pranav'), (347824784,'Aryan');
select * from user_info;
-- Borrowing a book
INSERT INTO borrower_info (name, member_id, isbn, issue_date)
VALUES ('Aakriti',34278282394 , 574384292, CURDATE());
INSERT INTO borrower_info (name, member_id, isbn, issue_date)
VALUES ('Prithvi',347828342,2005018, '2024-02-18');
select * from borrower_info;

-- Checking records
SELECT * FROM books;
SELECT * FROM user_info;
SELECT * FROM borrower_info;

-- Returning a book
DELETE FROM borrower_info WHERE name = 'Aakriti';
DELETE FROM borrower_info WHERE name = 'Prithvi';
-- Checking return logs
SELECT * FROM returned_user;

  
 






