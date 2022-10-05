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
                                    NOT NULL,
    [GivenName]       varchar(50)   NOT NULL,
    [Surname]         varchar(50)   NOT NULL,
    [DateOfBirth]     datetime      NOT NULL,
    [Enrolled]        bit           NOT NULL
)

CREATE TABLE Courses
(
    [Number]        varchar(10)     NOT NULL,
    [Name]          varchar(50)     NOT NULL,
    [Credits]       decimal(3, 1)   NOT NULL,
    [Hours]         tinyint         NOT NULL,
    [Active]        bit             NOT NULL,
    [Cost]          money           NOT NULL
)

CREATE TABLE StudentCourses
(
    [StudentID]     int             NOT NULL,
    [CourseNumber]  varchar(10)     NOT NULL,
    [Year]          int             NOT NULL,
    [Term]          char(3)         NOT NULL,
    [FinalMark]     tinyint             NULL,
    [Status]        char(1)         NOT NULL
)