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
    [GivenName]       varchar(50)   NOT NULL,
    [Surname]         varchar(50)   NOT NULL,
    [DateOfBirth]     datetime      NOT NULL,
    [Enrolled]        bit           NOT NULL
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
        CONSTRAINT CK_Courses_Money
            CHECK (Cost BETWEEN 400.00 AND 1500.00)
        -- A CHECK constraint will ensure that the value passed in
        -- meets the requirements of the constraint.
                                    NOT NULL
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