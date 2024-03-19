USE BIBOMART;
GO;


INSERT INTO Lecturers (Username )
VALUES ('Dr. Smith');
INSERT INTO Lecturers (Username )
VALUES ('Professor Johnson');
INSERT INTO Lecturers (Username )
VALUES ('Dr. Kim');
INSERT INTO Students (Username)
VALUES ('Student_Alice');
INSERT INTO Students (Username)
VALUES ('Student_Bob');


-- Dr. Smith is available every Monday from 09:00 to 11:00
INSERT INTO SchedulePatterns (UserID, PatternType, Day, Week, StartTime, EndTime,StillActivate)
VALUES (1, 'Weekly', 'Monday', NULL, '09:00', '11:00',1);

-- Professor Johnson is available the first Friday of each month from 15:00 to 16:30
INSERT INTO SchedulePatterns (UserID, PatternType, Day, Week, StartTime, EndTime,StillActivate)
VALUES (2, 'SpecificDayOfMonth', 'Friday', 1, '15:00', '16:30',1);

INSERT INTO SchedulePatterns (UserID, PatternType, Day, Week, StartTime, EndTime,StillActivate)
VALUES (2, 'SpecificDayOfMonth', 'Monday', 1, '15:00', '16:30',1);


-- Dr. Smith is not available on May 20th
INSERT INTO OverrideDates (UserID, Date, IsOverride)
VALUES (1, '2023-05-20', 1);

-- Professor Johnson has added an extra available day on May 21st from 10:00 to 12:00
-- This requires additional handling in logic, not directly insertable without additional structure
-- Dr. Smith meets students for 30 and 45 minute sessions
INSERT INTO SessionLengths (UserID, PatternID, Length)
VALUES (1, 1, 30);

-- Professor Johnson meets students for 15 and 60 minute sessions
INSERT INTO SessionLengths (UserID, PatternID, Length)
VALUES (2, 2, 15);


INSERT INTO SessionLengths (UserID, PatternID, Length)
VALUES (2, 6, 15);

-- -- Student_Alice books a session with Dr. Smith on a Monday
-- INSERT INTO Bookings (UserID,  Date, StartTime, EndTime, Status)
-- VALUES (3, 1, '2023-04-03', '09:30', '10:00', 'Booked');

-- -- Student_Bob books a session with Professor Johnson on the first Friday of June
-- INSERT INTO Bookings (UserID,  Date, StartTime, EndTime, Status)
-- VALUES (4, 2, '2023-06-02', '15:30', '16:00', 'Booked');
--
-- select *
-- from Bookings
--
--
-- select *
-- from SchedulePatterns
-- -- DBCC CHECKIDENT ('SchedulePatterns', RESEED, 0);
--
-- select * from SessionLengths
--
-- select * from OverrideDates

select Day = DATENAME(dw, '2024-03-04')

select Week = DATEPART(week, '2024-03-04') -
                   DATEPART(week, DATEADD(MONTH, DATEDIFF(MONTH, 0, '2024-03-04'), 0))