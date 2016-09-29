CREATE Database `enrollmentsdb`;

USE `enrollmentsdb`;

SET SQL_MODE = 'ALLOW_INVALID_DATES';

CREATE TABLE ENROLLMENTS(
    REC_ID INT AUTO_INCREMENT,
    STUDENT_ID VARCHAR(8),
    ENROLMENT_TIME VARCHAR(20),
    SUBJECT VARCHAR(6),
    PRIMARY KEY (REC_ID)
    );
CREATE TABLE STUDENTS(
    STUDENT_ID VARCHAR(8) NOT NULL,
    FIRST_NAME VARCHAR(24),
    LAST_NAME VARCHAR(24),
    DATE_OF_BIRTH VARCHAR(20),
    PRIMARY KEY (STUDENT_ID)
    );

DELETE FROM STUDENTS;

INSERT INTO STUDENTS(STUDENT_ID,FIRST_NAME,LAST_NAME,DATE_OF_BIRTH)  VALUES('02341334','Jessey','Pinkman','1979-04-05 13:10:03');
INSERT INTO STUDENTS(STUDENT_ID,FIRST_NAME,LAST_NAME,DATE_OF_BIRTH)  VALUES('02341335','Walter','White','1952-08-01 18:19:23');
INSERT INTO STUDENTS(STUDENT_ID,FIRST_NAME,LAST_NAME,DATE_OF_BIRTH)  VALUES('02341336','Gustavo','Fring','1962-02-04 09:39:00');

DELETE FROM ENROLLMENTS;

INSERT INTO ENROLLMENTS(STUDENT_ID,ENROLMENT_TIME,SUBJECT) VALUES('02341334','18-06-12 10:34:09','5242GW');
INSERT INTO ENROLLMENTS(STUDENT_ID,ENROLMENT_TIME,SUBJECT) VALUES('02341335','18-06-12 10:34:09','5242GW');
INSERT INTO ENROLLMENTS(STUDENT_ID,ENROLMENT_TIME,SUBJECT) VALUES('02341336','18-06-12 10:34:09','5242GW');
INSERT INTO ENROLLMENTS(STUDENT_ID,ENROLMENT_TIME,SUBJECT) VALUES('02341335','18-06-12 10:34:09','ERP2GW');
INSERT INTO ENROLLMENTS(STUDENT_ID,ENROLMENT_TIME,SUBJECT) VALUES('02341336','18-06-12 10:34:09','ERP2GW');
INSERT INTO ENROLLMENTS(STUDENT_ID,ENROLMENT_TIME,SUBJECT) VALUES('02341336','18-06-12 10:34:09','ERAU27');
