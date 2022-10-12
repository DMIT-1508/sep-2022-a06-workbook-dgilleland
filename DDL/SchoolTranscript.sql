/* **********************************************
 * Simple Table Creation - Columns and Primary Keys
 *
 * School Transcript
 *  Version 1.0.0
 *
 * Author: Dan Gilleland
 ********************************************** */
-- Create the database
IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'SchoolTranscript')
BEGIN
    CREATE DATABASE [SchoolTranscript]
END
GO
-- Single line comments start with two dashes
-- DROP DATABASE [SchoolTranscript]

-- Switch execution context to the database
USE [SchoolTranscript] -- remaining SQL statements will run against the SchoolTranscript database
GO

DROP TABLE IF EXISTS StudentCourses
DROP TABLE IF EXISTS Courses
DROP TABLE IF EXISTS Students
GO
-- Create Tables...
-- The CREATE TABLE statement contains a comma-separated list
-- of column declarations
CREATE TABLE Students
(
    -- Our column definitions will describe the
    -- name of the column and its data type as well as
    -- any "constraints" or "restrictions" around the
    -- data that can be stored in that column
    [StudentID]       int
        CONSTRAINT PK_Students_StudentID PRIMARY KEY
        -- A PRIMARY KEY constraint prevents duplicate data
            IDENTITY (2000, 5)
            -- The IDENTITY constraint does not need a name.
            -- An IDENTITY constraint means that the database server
            -- will take responsibility to put a value in this column
            -- every time a new row is added to the table.
            -- IDENTITY constraints can only be applied to the PRIMARY KEY
            -- columns that are of a whole-number numeric type.
            -- The IDENTITY constraint takes two values
            --      - The "seed" or starting value for the first row
            --      - The "increment" or value by which we increment
                                    NOT NULL,
    [GivenName]       varchar(50)
        CONSTRAINT CK_Students_GivenName
            CHECK (GivenName LIKE '[A-Z][A-Z]%')
            -- Matches 'Dan' or 'Danny' or 'Jo'
                                    NOT NULL,
    [Surname]         varchar(50)
        CONSTRAINT CK_Students_Surname
            CHECK (Surname LIKE '__%') -- Not as good as [A-Z][A-Z]%
                                       -- Silly matches: 42
                                    NOT NULL,
    [DateOfBirth]     datetime      NOT NULL,
    [Enrolled]        bit -- Holds values of either 1 or 0
        CONSTRAINT DF_Students_Enrolled
            DEFAULT (1)
        -- A DEFAULT constraint means that if no data is supplied
        -- for this column, it will automatically use the default.
                                    NOT NULL
)

CREATE TABLE Courses
(
    [Number]        varchar(10)
        CONSTRAINT PK_Courses_Number PRIMARY KEY
        CONSTRAINT CK_Courses_Number
            CHECK ([Number] LIKE '[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9]')                                                                                                                  
                                    NOT NULL,
    [Name]          varchar(50)     NOT NULL,
    [Credits]       decimal(3, 1)
        CONSTRAINT CK_Courses_Credits
            CHECK (Credits IN (3, 4.5, 6))
                                    NOT NULL,
    [Hours]         tinyint
        CONSTRAINT CK_Courses_Hours
            CHECK ([Hours] = 60 OR [Hours] = 90 OR [Hours] = 120)
            --     [Hours] IN (60, 90, 120)
                                    NOT NULL,
    [Active]        bit             NOT NULL,
    [Cost]          money
        CONSTRAINT CK_Courses_Cost
            CHECK (Cost BETWEEN 400.00 AND 1500.00)
        -- A CHECK constraint will ensure that the value passed in
        -- meets the requirements of the constraint.
                                    NOT NULL,
    -- Table-Level constraints are used for anything involving more than
    -- one column, such as Composite Primary Keys or complex CHECK constraints.
    -- It's a good pattern to put table-level constraint AFTER you have done all the
    -- column definitions.
    CONSTRAINT CK_Courses_Credits_Hours
        CHECK ([Hours] IN (60, 90) AND Credits IN (3, 4.5) OR [Hours] = 120 AND Credits = 6)
        --     \       #1 T/F    /
        --                             \       #2  T/F   /
        --             \            #3 T/F      /
        --                                                    \      #4   /
        --                                                                      \     #5  /
        --                                                           \       #6        /
        --                          \                     #7                  /
)

CREATE TABLE StudentCourses
(
    [StudentID]     int
        -- Foreign Key constraints provide us with what is
        -- called "Referential Integrity"; that is, the data
        -- must exist in the PK column of the related table.
        CONSTRAINT FK_StudentCourses_Students
            FOREIGN KEY REFERENCES Students(StudentID)
        -- A FOREIGN KEY constraint means that the only values
        -- acceptable for this column must be values that exist
        -- in the referenced table.
                                    NOT NULL,
    [CourseNumber]  varchar(10)
        CONSTRAINT FK_StudentCourses_Courses -- All constraint names must be unique
            FOREIGN KEY REFERENCES Courses([Number])
                                    NOT NULL,
    [Year]          int
        CONSTRAINT CK_StudentCourses_Year
            CHECK ([Year] > 2010)
            --     NOT [Year] <= 2010
                                    NOT NULL,
    [Term]          char(3)         NOT NULL,
    [FinalMark]     tinyint
        CONSTRAINT CK_StudentCourses_FinalMark
            CHECK (FinalMark BETWEEN 0 AND 100)
            --     FinalMark >= 0 AND FinalMark <= 100
            -- NOT(FinalMark <  0 OR  FinalMark >  100)    
                                        NULL,
    [Status]        char(1)
        CONSTRAINT CK_StudentCourses_Status
            -- The acceptable values for this column are 'A', 'W', and 'E'
            CHECK ([Status] LIKE '[AWE]') -- A pattern-matching approach
            --     [Status] = 'A' OR [Status] = 'E' OR [Status] = 'W'
            --     [Status] IN ('A','W','E')
                                    NOT NULL,
    -- Table-Level Constraint - when a constraint involves more than one column
    CONSTRAINT PK_StudentCourses_StudentID_CourseNumber
        PRIMARY KEY (StudentID, CourseNumber)
        -- Composite Primary Key Constraint
)

GO -- End of CREATE TABLE statements
-- Run all the batches above, then run the script that inserts test data into your database



/* Editing Table Structure AFTER data exists
SELECT  StudentID, GivenName, Surname, DateOfBirth, Enrolled
FROM    Students
SELECT [Number], [Name], Credits, [Hours], Active, Cost
FROM   Courses
SELECT StudentID, CourseNumber, [Year], Term, [Status]
FROM   StudentCourses
*/
-- Modifying Database Table Schemas with ALTER TABLE

-- Consider the fact that there may be data in the table
-- that you are trying to alter.
-- If you don't have a default value to apply when
-- adding your new column, then the new column should
-- allow NULL values.

-- Here is an example where we add an extra column to the
-- Students table for the student's home email.
ALTER TABLE Students
   ADD  Email   varchar(30)     NULL

/*
-- Here's a quck'n'dirty way to see all the column in a table
SELECT * FROM Students
*/

-- New requirement: We need a column called "Paid" on
-- the StudentCourses table. This has to be a Required
-- column (NOT NULL).
-- We need a DEFAULT value for existing rows of data.
ALTER TABLE StudentCourses
    ADD     Paid    bit     NOT NULL
        CONSTRAINT DF_StudentCourses_Paid DEFAULT (0)

-- SELECT * FROM StudentCourses
-- sp_help StudentCourses

-- Practice: Alter the StudentCourses table
-- to add a column "OverDue" as a bit. (Optional)
ALTER TABLE StudentCourses
    ADD     OverDue     bit     NULL
GO -- end of this ALTER TABLE batch, but there's more to come!

-- New change request: Have a default for the
-- "OverDue" column: 0
ALTER TABLE StudentCourses
    ADD CONSTRAINT DF_StudentCourses_OverDue
        DEFAULT (0) FOR OverDue
-- Also notice above that I have a slightly different
-- syntax for the default constraint:
--  DEFAULT (value) FOR ColumnName
-- Lastly, not that the new constraint will only apply for
-- new rows of data for my DEFAULT constraint.
/*
-- Testing with inserting some data
INSERT INTO StudentCourses(StudentID, CourseNumber, [Year], Term, [Status])
VALUES (2015, 'DMIT-1508', 2020, 'SEP', 'E')
SELECT * FROM StudentCourses
SELECT * FROM Students
*/


-- Here's another change request: The Students.Email column is too short.
-- sp_help Students
-- Alter the table to allow up to 90 characters in length
ALTER TABLE Students
    ALTER COLUMN   Email       varchar(90)     NULL
-- sp_help Students
GO -- Another "batch" for the latest change request

-- If you mistakenly added a column to a table, like this:
ALTER TABLE Students -- Oops
    ADD     FinalGrade  int     NULL
GO
-- You can remove or drop a column like this
ALTER TABLE Students -- Oops
    DROP COLUMN    FinalGrade
GO

/* ALTER TABLE Statements - PRACTICE */

-- A) Add column to the Courses table called "SyllabusURL" that is a variable-length
--    string of up to 70 characters. Determine for yourself if it should be NULL or NOT NULL.
ALTER TABLE Courses
    ADD SyllabusURL varchar(70) NULL
/* After you add the column, here's some test data to insert into the database
SELECT * FROM Courses
INSERT INTO Courses(Number, Name, Credits, Hours, Active, Cost, SyllabusURL)
VALUES ('HACK-0001', 'White-Hat Hacking', 4.5, 90, 1, 450.00, 'gopher://hack.dev')
*/ 
GO

-- B) Add a CHECK constraint to the SyllabusURL that will ensure the value matches a website URL (HTTPS://).
ALTER TABLE Courses
        WITH NOCHECK
    --  WITH NOCHECK means it will not apply the CHECK
    --               to the existing data in the table
    ADD CONSTRAINT CK_Courses_SyllabusURL
        CHECK (SyllabusURL LIKE 'https://%')
        --      Match for       'https://DMIT-1508.github.io'
/*
INSERT INTO Courses(Number, Name, Credits, Hours, Active, Cost, SyllabusURL)
VALUES ('HACK-1705', 'Gray-Hat Hacking', 4.5, 90, 1, 450.00, 'https://hack.dev')
INSERT INTO Courses(Number, Name, Credits, Hours, Active, Cost, SyllabusURL)
VALUES ('SHIP-1705', 'Warp Drive Engineering', 4.5, 90, 1, 450.00, 'https://ST.Earth.UFP')
*/

-- C) One of the functions that we can use in SQL is the GETDATE() function that will 
--    return the current datetime. Use this GETDATE() function as the default value
--    for new column in Students called "EnrolledDate".
ALTER TABLE Students
    ADD EnrolledDate    datetime    NOT NULL
        CONSTRAINT DF_Students_EnrolledDate
            DEFAULT (GETDATE())

GO -- end the batch of statements that alter the database

