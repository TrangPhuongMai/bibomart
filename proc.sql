USE BIBOMART;
GO;

--  InsertUserSchedule (this will save the lecturer’s availability, and this should handle all the
-- use cases outlined above and create the base data.


CREATE PROCEDURE InsertUserSchedule @UserID INT,
                                    @PatternType NVARCHAR(50),
                                    @Day NVARCHAR(10),
                                    @Week INT,
                                    @StartTime TIME,
                                    @EndTime TIME
AS
BEGIN
    INSERT INTO SchedulePatterns (UserID, PatternType, Day, Week, StartTime, EndTime)
    VALUES (@UserID, @PatternType, @Day, @Week, @StartTime, @EndTime);
END;

go;

EXECUTE InsertUserSchedule @UserID = 1, @PatternType = 'Weekly', @Day = 'Wednesday', @Week=2, @StartTime='09:00',
        @EndTime='11:00';

--
--     DROP PROCEDURE InsertUserSchedule;
-- GO

-- SelectUserSchedule (for the lecturer to view his schedule which is populated by the insert
-- proc. Include a @TargetDate input param which will be used by the student when they click
-- on a specific date to see the available timeslots. Remember once a timeslot is selected it
-- should not appear for other students)

CREATE PROCEDURE SelectUserSchedule @UserID INT,
                                    @TargetDate DATE
AS
BEGIN
    -- tạo bảng temp
    CREATE TABLE #AvailableSlots
    (
        PatternID INT,
        StartTime TIME,
        EndTime   TIME,
        Length    INT
    );
    CREATE TABLE #DividedSlots
    (
        StartTime TIME,
        EndTime   TIME
    );

    DECLARE @IsOverride BIT;
    SELECT @IsOverride = IsOverride FROM OverrideDates WHERE UserID = @UserID AND Date = @TargetDate;
    -- kiểm tra xem IsAvailable có là false không

    IF @IsOverride IS NULL or @IsOverride = 0
        BEGIN
            INSERT INTO #AvailableSlots (PatternID, StartTime, EndTime, Length)
            SELECT sp.PatternID, StartTime, EndTime, sl.Length
            FROM SchedulePatterns sp
                     join SessionLengths sl on sp.PatternID = sl.PatternID
            WHERE sp.UserID = @UserID
              AND sp.StillActivate = 1 -- kiểm tra SchedulePatterns này còn kích hoạt k
              AND ( -- phần quan trọng nhất code, tính lịch theo PatternType
                    (sp.PatternType = 'Weekly' AND Day = DATENAME(dw, @TargetDate)) OR
                    (sp.PatternType = 'SpecificDayOfMonth'
                        AND Day = DATENAME(dw, @TargetDate)
                        AND Week = DATEPART(week, @TargetDate) -
                                   DATEPART(week, DATEADD(MONTH, DATEDIFF(MONTH, 0, @TargetDate), 0)))
                );
        END
    ELSE
        IF @IsOverride = 1
            BEGIN
                -- Date is an available override, assuming all day is available, this will need to be adjusted based on actual available times
                INSERT INTO #AvailableSlots (PatternID, StartTime, EndTime)
                VALUES (NULL, NULL, NULL); -- nếu bị overwrite
            END
    select * from #AvailableSlots
    -- dữ liệu sẽ có kiểu như sau
    -- "PatternID": 1,
    -- "StartTime": "09:00:00",
    -- "EndTime": "11:00:00",
    -- "Length": 30 -- khoảng thời gian từng sessions tính theo phút


    -- loop để tạo một bảng con với 2 cột starttime và endtime đã được chia ra
    -- từng phần theo cột Length của bảng tạm #AvailableSlots
    DECLARE cur CURSOR FOR
        SELECT PatternID, StartTime, EndTime, Length FROM #AvailableSlots;
    OPEN cur;

    DECLARE @PatternID INT, @StartTime TIME, @EndTime TIME, @Length INT, @NextStartTime TIME;

    FETCH NEXT FROM cur INTO @PatternID, @StartTime, @EndTime, @Length;

    WHILE @@FETCH_STATUS = 0 -- tạo loop while
        BEGIN
            SET @NextStartTime = @StartTime;
            WHILE @NextStartTime < @EndTime
                BEGIN
                    DECLARE @NextEndTime TIME = DATEADD(MINUTE, @Length, @NextStartTime);
                    IF @NextEndTime > @EndTime SET @NextEndTime = @EndTime;

                    INSERT INTO #DividedSlots (StartTime, EndTime)
                    VALUES (@NextStartTime, @NextEndTime);

                    SET @NextStartTime = @NextEndTime;

                    IF @NextEndTime = @EndTime BREAK;
                END

            FETCH NEXT FROM cur INTO @PatternID, @StartTime, @EndTime, @Length;
        END
    CLOSE cur;
    DEALLOCATE cur;

    -- kiêm tra và trả về các time slot mà k bị booked
    SELECT ds.StartTime, ds.EndTime
    FROM #DividedSlots ds
    WHERE NOT EXISTS(
            SELECT 1
            FROM Bookings
            WHERE ds.StartTime = Bookings.StartTime
              AND ds.EndTime = Bookings.EndTime
              AND Bookings.Date = @TargetDate
              AND Bookings.Status in ('Booked', 'Cancelled')
        );


    -- xóa bảng temp
    DROP TABLE #AvailableSlots;
    DROP TABLE #DividedSlots;
END;

-- để test proc insert vào bảng SchedulePatterns và bảng SessionLengths
--     ex :
-- INSERT INTO SchedulePatterns (UserID, PatternType, Day, Week, StartTime, EndTime,StillActivate)
-- VALUES (2, 'SpecificDayOfMonth', 'Monday', 1, '15:00', '16:30',1);
-- INSERT INTO SessionLengths (UserID, PatternID, Length)
-- VALUES (2, 2, 15);
    -- điều kiện là cùng userid và PatternID

exec SelectUserSchedule @UserID = 1, @TargetDate='2024-03-18'
-- test case cho 'Weekly'
exec SelectUserSchedule @UserID = 2, @TargetDate='2024-03-04' -- <-- chú ý nếu trường hợp viết testcase cho SpecificDayOfMonth
                    -- cần đảm bảo là ngày này đúng là ngày trong SchedulePatterns ví dụ nếu mình test 2024-03-04
                    -- thì SchedulePatterns chỉ đúng khi để là thứ 2 đầu tháng  'SpecificDayOfMonth', 'Monday', 1,
-- test case cho 'SpecificDayOfMonth'


    -- 3. InsertUserScheduleBooking (this is when a student selects a timeslots on a specific date and
-- books it)


CREATE PROCEDURE InsertUserScheduleBooking @UserID INT,
                                           @LecturerID INT,
                                           @Date DATE,
                                           @StartTime TIME,
                                           @EndTime TIME
AS
BEGIN

    INSERT INTO Bookings (UserID, LecturerID, Date, StartTime, EndTime, Status)
    VALUES (@UserID, @LecturerID, @Date, @StartTime, @EndTime, 'Booked');
END


exec InsertUserScheduleBooking @UserID = 1, @LecturerID=1, @Date='2024-03-18', @StartTime='10:00:00', @EndTime='10:30:00'

