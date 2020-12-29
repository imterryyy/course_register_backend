CREATE SCHEMA LEARNING_SYSTEM;
USE LEARNING_SYSTEM;

CREATE TABLE PERSON (
	SSN CHAR(9) PRIMARY KEY CHECK(SSN REGEXP '[0-9]{9}'),
    FNAME VARCHAR(15),
    LNAME VARCHAR(15),
    USER_ROLE VARCHAR(15),
    GENDER CHAR CHECK(GENDER IN ('M', 'F', 'N')),
    BIRTHDATE DATE,
    EMAIL VARCHAR(30) CHECK(EMAIL LIKE '%@%')
);

CREATE TABLE ACCOUNTS (
	SSN CHAR(9) PRIMARY KEY CHECK(SSN REGEXP '[0-9]{9}'),
	USERNAME VARCHAR(20),
    PASS	 VARCHAR(100),
    FOREIGN KEY (SSN) REFERENCES PERSON(SSN)
);
CREATE TABLE FACULTY (
	FACULTY_CODE CHAR(4) PRIMARY KEY CHECK (FACULTY_CODE REGEXP 'F[0-9]{3}'),
    FACULTY_NAME VARCHAR(15)
);

CREATE TABLE AUTHOR (
	AUTHOR_ID CHAR(9) PRIMARY KEY CHECK (AUTHOR_ID REGEXP 'A[0-9]{8}')
);

CREATE TABLE PUBLISHER (
	PUBLISHER_NAME VARCHAR(15) PRIMARY KEY
);

CREATE TABLE STUDENT (
	STUDENT_ID CHAR(9) PRIMARY KEY CHECK (STUDENT_ID REGEXP 'SD[0-9]{7}'),
    SSN CHAR(9) UNIQUE NOT NULL,
    GPA DECIMAL(4, 2) CHECK(GPA >= 0 AND GPA <= 10),
    FCODE CHAR(4) NOT NULL,
    FOREIGN KEY (FCODE) REFERENCES FACULTY(FACULTY_CODE),
    FOREIGN KEY (SSN) REFERENCES PERSON(SSN)
);

CREATE TABLE STAFF (
	STAFF_ID CHAR(9) PRIMARY KEY CHECK (STAFF_ID REGEXP 'SFF[0-9]{6}'),
    SSN CHAR(9) UNIQUE NOT NULL CHECK (SSN REGEXP '[0-9]{9}'),
    FCODE CHAR(4) NOT NULL,
    FOREIGN KEY (FCODE) REFERENCES FACULTY(FACULTY_CODE),
    FOREIGN KEY (SSN) REFERENCES PERSON(SSN)
);

CREATE TABLE MANAGEMENT_INSTRUCTOR(
	STAFF_ID CHAR(9) PRIMARY KEY,
    ACADEMIC_RANK VARCHAR(3) CHECK (ACADEMIC_RANK IN ('GS', 'PGS')),
    FOREIGN KEY (STAFF_ID) REFERENCES STAFF(STAFF_ID)
);

CREATE TABLE INSTRUCTOR (
	STAFF_ID CHAR(9) PRIMARY KEY,
    DEGREE VARCHAR(9) CHECK (DEGREE IN ('Bachelor', 'Master', 'Doctor')),
    MGR_ID CHAR(9) NOT NULL,
    FOREIGN KEY (STAFF_ID) REFERENCES STAFF(STAFF_ID),
    FOREIGN KEY (MGR_ID) REFERENCES MANAGEMENT_INSTRUCTOR(STAFF_ID)
);

CREATE TABLE AAO_STAFF (
	STAFF_ID CHAR(9) PRIMARY KEY,
    TYPING_SPEED VARCHAR(15) CHECK (TYPING_SPEED IN ("Good", "Normal")),
    FOREIGN KEY (STAFF_ID) REFERENCES STAFF(STAFF_ID)
);

CREATE TABLE MAJOR_INSTRUCTOR(
	STAFF_ID CHAR(9) PRIMARY KEY,
    EXPERIENCE INT CHECK(EXPERIENCE > 0),
    FOREIGN KEY (STAFF_ID) REFERENCES INSTRUCTOR(STAFF_ID)
);

CREATE TABLE DOCUMENT(
	ISBN VARCHAR(13) PRIMARY KEY CHECK (ISBN REGEXP '[0-9]{10}' OR ISBN REGEXP '[0-9]{13}'),
    DOCUMENT_NAME VARCHAR(15),
    PUBLISHER_NAME VARCHAR(15) NOT NULL,
    FOREIGN KEY (PUBLISHER_NAME) REFERENCES PUBLISHER(PUBLISHER_NAME)
);

CREATE TABLE COURSE(
	COURSE_ID CHAR(3) PRIMARY KEY CHECK(COURSE_ID LIKE 'C%'),
    COURSE_NAME VARCHAR(15),
    CREDIT INT CHECK (CREDIT >= 1 AND CREDIT <= 3),
    FCODE CHAR(4) NOT NULL,
    FOREIGN KEY (FCODE) REFERENCES FACULTY(FACULTY_CODE)
);

CREATE TABLE CLASS (
	COURSE_ID CHAR(3),
    CLASS_ID CHAR(3) CHECK (CLASS_ID REGEXP 'L[0-9]{2}'),
    YEAR_SEMESTER CHAR(3) NOT NULL,
    PERIOD INT CHECK (PERIOD >= 1 AND PERIOD <= 14),
    PRIMARY KEY (COURSE_ID, CLASS_ID),
    FOREIGN KEY (COURSE_ID) REFERENCES COURSE(COURSE_ID)
);

CREATE TABLE CLASS_GROUP (
	COURSE_ID CHAR(3),
    CLASS_ID CHAR(3),
    ORDER_NO CHAR CHECK (ORDER_NO REGEXP '[A-Za-z]'),
    STAFF_ID CHAR(9),
    PRIMARY KEY (COURSE_ID, CLASS_ID, ORDER_NO),
    FOREIGN KEY (COURSE_ID, CLASS_ID) REFERENCES CLASS(COURSE_ID, CLASS_ID)
		on update cascade on delete cascade,
    FOREIGN KEY (STAFF_ID) REFERENCES INSTRUCTOR(STAFF_ID) 
);

CREATE TABLE WEEK_OF_STUDY (
	COURSE_ID CHAR(3),
    CLASS_ID CHAR(3),
    ORDER_NO CHAR,
    WEEK_ORDER_NO INT CHECK (WEEK_ORDER_NO > 0),
    STAFF_ID CHAR(9),
    PRIMARY KEY (COURSE_ID, CLASS_ID, ORDER_NO, WEEK_ORDER_NO),
    FOREIGN KEY (COURSE_ID, CLASS_ID, ORDER_NO) REFERENCES CLASS_GROUP(COURSE_ID, CLASS_ID, ORDER_NO),
    FOREIGN KEY (STAFF_ID) REFERENCES INSTRUCTOR(STAFF_ID) 
);

CREATE TABLE REGISTER (
	STUDENT_ID CHAR(9),
    COURSE_ID CHAR(3),
    REGISTER_TIME DATE,
    SEMESTER VARCHAR(3),
    PRIMARY KEY (STUDENT_ID, COURSE_ID, SEMESTER),
    FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID),
    FOREIGN KEY (COURSE_ID) REFERENCES COURSE(COURSE_ID)
);

CREATE TABLE PARRALLEL_COURSE(
	COURSE_ID CHAR(3),
    P_COURSE CHAR(3),
    PRIMARY KEY (COURSE_ID, P_COURSE),
    CHECK (COURSE_ID <> P_COURSE),
    FOREIGN KEY (COURSE_ID) REFERENCES COURSE(COURSE_ID),
    FOREIGN KEY (P_COURSE) REFERENCES COURSE(COURSE_ID)
);

CREATE TABLE DECISION_COURSE(
	COURSE_ID CHAR(3),
    D_COURSE CHAR(3),
    PRIMARY KEY (COURSE_ID, D_COURSE),
    CHECK (COURSE_ID <> D_COURSE),
    FOREIGN KEY (COURSE_ID) REFERENCES COURSE(COURSE_ID),
    FOREIGN KEY (D_COURSE) REFERENCES COURSE(COURSE_ID)
);

CREATE TABLE AUTHOR_WRITE (
	AUTHOR_ID CHAR(9),
    DOC_ISBN VARCHAR(13),
    PRIMARY KEY (AUTHOR_ID, DOC_ISBN),
    FOREIGN KEY (AUTHOR_ID) REFERENCES AUTHOR(AUTHOR_ID),
    FOREIGN KEY (DOC_ISBN) REFERENCES DOCUMENT(ISBN)
);

CREATE TABLE USE_DOCUMENT (
	COURSE_ID CHAR(3),
    DOC_ISBN VARCHAR(13),
    PRIMARY KEY (COURSE_ID, DOC_ISBN),
	FOREIGN KEY (COURSE_ID) REFERENCES COURSE(COURSE_ID),
    FOREIGN KEY (DOC_ISBN) REFERENCES DOCUMENT(ISBN)
);

CREATE TABLE STUDY (
	STUDENT_ID CHAR(9),
    COURSE_ID CHAR(3),
    CLASS_ID CHAR(3),
    ORDER_NO CHAR,
    PRIMARY KEY (STUDENT_ID, COURSE_ID, CLASS_ID, ORDER_NO),
    FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID),
    FOREIGN KEY (COURSE_ID, CLASS_ID, ORDER_NO) REFERENCES CLASS_GROUP(COURSE_ID, CLASS_ID, ORDER_NO)
);

CREATE TABLE SAVE_SCORE (
	STUDENT_ID CHAR(9),
    COURSE_ID CHAR(3),
    MAJOR_INSTRUCTOR_ID CHAR(9) NOT NULL,
    RESULT DECIMAL(4, 2) CHECK (RESULT >= 0 AND RESULT <= 10),
    PRIMARY KEY (STUDENT_ID, COURSE_ID),
    FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID),
    FOREIGN KEY (COURSE_ID) REFERENCES COURSE(COURSE_ID),
    FOREIGN KEY (MAJOR_INSTRUCTOR_ID) REFERENCES MAJOR_INSTRUCTOR(STAFF_ID)
);

CREATE TABLE DECIDE(
	INSTRUCTOR_ID CHAR(9),
    DOC_ISBN VARCHAR(13),
    COURSE_ID CHAR(3),
    CLASS_ID CHAR(3),
    PRIMARY KEY (INSTRUCTOR_ID, DOC_ISBN, COURSE_ID, CLASS_ID),
    FOREIGN KEY (INSTRUCTOR_ID) REFERENCES INSTRUCTOR(STAFF_ID),
    FOREIGN KEY (DOC_ISBN) REFERENCES DOCUMENT(ISBN),
    FOREIGN KEY (COURSE_ID, CLASS_ID) REFERENCES CLASS(COURSE_ID, CLASS_ID)
		on update cascade on delete cascade
);

CREATE TABLE PERSON_PHONE (
	PSSN CHAR(9),
    APHONE CHAR(10) CHECK (APHONE REGEXP '0[0-9]{9}'),
    PRIMARY KEY (PSSN, APHONE),
    FOREIGN KEY (PSSN) REFERENCES PERSON (SSN)
);

CREATE TABLE STATUS_LEARNING (
	STUDENT_ID CHAR(9),
    STUDENT_STATUS VARCHAR(15) CHECK (STUDENT_STATUS IN ("Studying", "Pause", "Stop")),
    CURRENT_SEMESTER CHAR(3) CHECK (CURRENT_SEMESTER REGEXP '[0-9]{3}'),
    PRIMARY KEY (STUDENT_ID, STUDENT_STATUS, CURRENT_SEMESTER),
    FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID)
);

CREATE TABLE DOCUMENT_CATEGORY (
	DOC_ISBN VARCHAR(13),
    ACATEGORY VARCHAR(15),
    PRIMARY KEY (DOC_ISBN, ACATEGORY),
    FOREIGN KEY (DOC_ISBN) REFERENCES DOCUMENT(ISBN)
);

CREATE TABLE AUTHOR_EMAIL (
	AUTHOR_ID CHAR(9),
    AEMAIL VARCHAR(30) CHECK(AEMAIL LIKE '%@%'),
    PRIMARY KEY (AUTHOR_ID, AEMAIL),
    FOREIGN KEY (AUTHOR_ID) REFERENCES AUTHOR(AUTHOR_ID)
);

CREATE TABLE PUBLISHING_YEAR (
	DOC_ISBN VARCHAR(13),
    AYEAR INT CHECK (AYEAR > 0),
    PRIMARY KEY (DOC_ISBN, AYEAR),
    FOREIGN KEY (DOC_ISBN) REFERENCES DOCUMENT(ISBN)
);

CREATE TABLE PUBLISHING_TYPE (
	PNAME VARCHAR(15),
    ATYPE VARCHAR(15) CHECK (ATYPE IN ("domestic", "international")),
    PRIMARY KEY (PNAME, ATYPE),
    FOREIGN KEY (PNAME) REFERENCES PUBLISHER(PUBLISHER_NAME)
);