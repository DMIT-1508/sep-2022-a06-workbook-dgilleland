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

-- Create Tables...
-- The CREATE TABLE statement contains a comma-separated list
-- of column declarations
-- DROP TABLE Students
CREATE TABLE Students
(
    [StudentID]       int,
    [GivenName]       varchar(50),
    [Surname]         varchar(50),
    [DateOfBirth]     datetime,
    [Enrolled]        bit
)

