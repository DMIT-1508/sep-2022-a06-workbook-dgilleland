--Stored Procedures (Sprocs)
-- Global Variables - @@IDENTITY, @@ROWCOUNT, @@ERROR
-- Other global variables can be found here:
--  https://code.msdn.microsoft.com/Global-Variables-in-SQL-749688ef
USE [A06-School]
GO

/*
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'SprocName')
    DROP PROCEDURE SprocName
GO
CREATE PROCEDURE SprocName
    -- Parameters here
AS
    -- Body of procedure here
RETURN
GO
*/

-- 1. Create a stored procedure called AddPosition that will accept a Position Description (varchar 50). Return the primary key value that was database-generated as a result of your Insert statement. Also, ensure that the supplied description is not NULL and that it is at least 5 characters long. Make sure that you do not allow a duplicate position name.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'AddPosition')
    DROP PROCEDURE AddPosition
GO
CREATE PROCEDURE AddPosition
    -- Parameters here
    @Description    varchar(50) -- Max of 50 characters
AS
    -- Body of procedure here
    IF @Description IS NULL
    BEGIN -- {
        RAISERROR('Description is required', 16, 1) -- Throw an exception
    END   -- }
    ELSE
    BEGIN -- {
        IF LEN(@Description) < 5
        BEGIN -- {
            RAISERROR('Description must be between 5 and 50 characters', 16, 1)
        END   -- }
        ELSE
        BEGIN -- {
            IF EXISTS(SELECT * FROM Position WHERE PositionDescription = @Description)
            BEGIN -- {
                RAISERROR('Duplicate positions are not allowed', 16, 1)
            END   -- }
            ELSE
            BEGIN -- { -- This BEGIN/END is needed, because of two SQL statements
                INSERT INTO Position(PositionDescription)
                VALUES (@Description)
                -- Send back the database-generated primary key
                SELECT @@IDENTITY AS 'NewPositionID' -- This is a global variable
            END   -- }
        END   -- }
    END   -- }
RETURN
GO

-- Let's test our AddPosition stored procedure
INSERT INTO Position(PositionDescription)  VALUES (NULL)
SELECT @@IDENTITY
INSERT INTO Position(PositionDescription)  VALUES ('Substitute')
-- @@IDENTITY is the last-generated/used IDENTITY value regardless of what
-- database table it was generated in. This is GLOBAL variable.
SELECT @@IDENTITY -- The PositionID that was actually used/stored

SELECT * FROM Position
EXEC AddPosition 'The Boss'
EXEC AddPosition NULL -- This should result in an error being raised
EXEC AddPosition 'Me' -- This should result in an error being raised
EXEC AddPosition 'The Boss' -- This should result in an error as well (a duplicate)
-- This long string gets truncated at the parameter, because the parameter size is 50
EXEC AddPosition 'The Boss of everything and everyone, everywhere and all the time, both past present and future, without any possible exception. Unless, of course, I''m not...'
EXEC AddPosition 'The Janitor'
SELECT * FROM Position
-- DELETE FROM Position WHERE PositionID = 12
GO

ALTER PROCEDURE AddPosition
    -- Parameters here
    @Description    varchar(500) -- Just to "allow" a larger value, but check the length later
AS
    -- Body of procedure here
    IF @Description IS NULL
    BEGIN -- {
        RAISERROR('Description is required', 16, 1) -- Throw an exception
    END   -- }
    ELSE
    BEGIN -- {
        IF LEN(@Description) < 5 OR Len(@Description) > 50
        BEGIN -- {
            RAISERROR('Description must be between 5 and 50 characters', 16, 1)
        END   -- }
        ELSE
        BEGIN -- {
            IF EXISTS(SELECT * FROM Position WHERE PositionDescription = @Description)
            BEGIN -- {
                RAISERROR('Duplicate positions are not allowed', 16, 1)
            END   -- }
            ELSE
            BEGIN -- { -- This BEGIN/END is needed, because of two SQL statements
                INSERT INTO Position(PositionDescription)
                VALUES (@Description)
                -- Send back the database-generated primary key
                SELECT @@IDENTITY -- This is a global variable
            END   -- }
        END   -- }
    END   -- }
RETURN
GO

EXEC AddPosition 'Still the Boss of everything and everyone, everywhere and all the time, both past present and future, without any possible exception. Unless, of course, I''m not...'
SELECT * FROM Position
-- DELETE FROM Position WHERE PositionID = 12

-- 2) Create a stored procedure called LookupClubMembers that takes a club ID and returns the full names of all members in the club.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'LookupClubMembers')
    DROP PROCEDURE LookupClubMembers
GO
CREATE PROCEDURE LookupClubMembers
    -- Parameters here
    @ClubId     varchar(10)
AS
    -- Body of procedure here
    IF @ClubId IS NULL OR NOT EXISTS(SELECT * FROM Club WHERE ClubId = @ClubId)
    BEGIN
        RAISERROR('ClubID is invalid/does not exist', 16, 1)
    END
    ELSE
    BEGIN
        SELECT  FirstName + ' ' + LastName AS 'MemberName'
        FROM    Student S
            INNER JOIN Activity A ON A.StudentID = S.StudentID
        WHERE   A.ClubId = @ClubId
    END
RETURN
GO

-- Test the above sproc
EXEC LookupClubMembers 'CHESS'
EXEC LookupClubMembers 'CSS'
EXEC LookupClubMembers 'Drop Out'
EXEC LookupClubMembers 'NASA1'
EXEC LookupClubMembers NULL

-- 3) Create a stored procedure called RemoveClubMembership that takes a club ID and deletes all the members of that club. Be sure that the club exists. Also, raise an error if there were no members deleted from the club.
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'RemoveClubMembership')
    DROP PROCEDURE RemoveClubMembership
GO
CREATE PROCEDURE RemoveClubMembership
    -- Parameters here
    @ClubId     varchar(10)
AS
    -- Body of procedure here
    IF @ClubId IS NULL OR NOT EXISTS(SELECT * FROM Club WHERE ClubId = @ClubId)
    BEGIN
        RAISERROR('ClubID is invalid/does not exist', 16, 1)
    END
    ELSE
    BEGIN
        DELETE FROM Activity
        WHERE       ClubId = @ClubId
        -- Any Insert/Update/Delete will affect the global @@ROWCOUNT value
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('No members were deleted', 16, 1)
        END
    END
RETURN
GO
-- Test the above sproc...
EXEC LookupClubMembers 'CHESS'
EXEC LookupClubMembers 'CSS'
EXEC LookupClubMembers 'Drop Out'
EXEC LookupClubMembers 'NASA1'
EXEC LookupClubMembers NULL

EXEC RemoveClubMembership NULL
EXEC RemoveClubMembership 'Drop Out'
EXEC RemoveClubMembership 'NASA1'
EXEC RemoveClubMembership 'CSS'
EXEC RemoveClubMembership 'CSS' -- The second time this is run, there will be no members to remove

-- 3.5) Create a stored procedure called PayTuition that processes a payment for a student's account. The procedure will be given an amount for the payment, the ID of the student as well as the name of the means of payment being used. Validate all the input. Ensure that no overpayments are being made.
--     A) What's being sent into the sproc
--          @Amount      
--          @ID          
--          @PaymentName
--          (check for NULL values)
--     B) What is returned by the sproc
--          @@IDENTITY from inserting into the table
--     C) What table(s) are we working with?
--          Payment : Insert
--                    - Required information: StudentID, PaymentTypeID, Amount
--                    - The PK column (PaymentID) is an IDENTITY column
--                    - The PaymentDate column has a default of GETDATE()
GO
CREATE OR ALTER PROCEDURE PayTuition
    -- Parameters here
    @Amount         decimal,    -- the data type should match Payment.Amount
    @ID             int,        -- the data type should match Payment.StudentID
    @PaymentName    varchar(40) -- the data type should match PaymentType.PaymentTypeDescription
AS
    -- Body of stored procedure
    IF @Amount IS NULL OR @ID IS NULL or @PaymentName IS NULL
    BEGIN
        RAISERROR('All parameters are required; null values are rejected', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO Payment(StudentID, PaymentTypeID, Amount)
        VALUES (@ID, (SELECT PaymentTypeID FROM PaymentType WHERE PaymentTypeDescription = @PaymentName), @Amount)
        IF @@ERROR <> 0
        BEGIN
            RAISERROR('Unable to pay tuition - insert statement failed', 16, 1)
        END
        ELSE
        BEGIN
            SELECT @@IDENTITY AS 'NewPaymentID' -- The identity value from the insert
        END
    END
RETURN
GO

-- To test my sproc, I'll look for a student that has some money due
-- SELECT * FROM Student WHERE BalanceOwing > 0
-- Everybody has paid their tuition, so let's just pick somebody who wants to give money to the school
EXEC PayTuition 500, 200011730, 'CASH'
EXEC PayTuition 500, 200011730, 'Bitcoin'


-- 4) Create a stored procedure called OverActiveMembers that takes a single number: ClubCount. This procedure should return the names of all members that are active in as many or more clubs than the supplied club count.
--    (p.s. - You might want to make sure to add more members to more clubs, seeing as tests for the last question might remove a lot of club members....)
-- TODO: Student Answer Here



-- 5) Create a stored procedure called ListStudentsWithoutClubs that lists the full names of all students who are not active in a club.
-- TODO: Student Answer Here



-- 6) Create a stored procedure called LookupStudent that accepts a partial student last name and returns a list of all students whose last name includes the partial last name. Require at least 1 character in the supplied parameter. Return the student first and last name as well as their ID.
-- TODO: Student Answer Here

-- 7) Create a stored procedure called AddPaymentType that takes in a description/name for the payment type and adds it to the PaymentType table. Be sure to prevent any duplicate payment types and also make sure the name of the pament type is at least 4 characters long. Return the PaymentTypeID that was generated for the inserted row.
-- TODO: Student Answer Here

-- 8) Create a stored procedure called RemovePaymentType that takes in the name of the payment type and deletes it from the PaymentType table. Ensure the supplied name is valid and that it exists. Generate your own error message if the attempted delete fails.
-- TODO: Student Answer Here

-- 9) Create a stored procedure called RemoveJobPosition that takes in the name of the position and deletes it from the Position table. Ensure the supplied name is valid and that it exists. Generate your own error message if the attempted delete fails.
-- TODO: Student Answer Here

