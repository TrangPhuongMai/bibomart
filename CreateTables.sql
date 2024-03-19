CREATE DATABASE bibomart;
GO;

USE BIBOMART;
GO;


CREATE TABLE Students (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(100)
);

CREATE TABLE Lecturers (
    LecturerID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(100)
);

CREATE TABLE SchedulePatterns (
    PatternID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Lecturers(LecturerID),
    PatternType NVARCHAR(50) CONSTRAINT CK_PatternType CHECK (PatternType IN ('SpecificDayOfMonth', 'Weekly')),
    Day NVARCHAR(10) CONSTRAINT CK_Day CHECK (Day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') OR Day IS NULL),
    -- day bắt buộc phải thuộc kiểu trên bằng k code sẽ hỏng vì stored proc sử dụng DATENAME
    Week INT,  -- 1 for First, 2 for Second, etc., NULL for weekly patterns
    DayOfMonth INT CONSTRAINT CK_DayOfMonth CHECK (DayOfMonth >0 and DayOfMonth< 31),
    StartTime TIME,
    EndTime TIME,
    StillActivate BIT DEFAULT 0 -- SchedulePatterns này vẫn được kích hoạt hay k
                                -- giảm thiểu load cho các tính toàn sau này mà k phải xóa dữ liệu
);

CREATE TABLE OverrideDates (
    OverrideID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Lecturers(LecturerID),
    Date DATE,
    IsOverride BIT  -- 0 cho không khả dụng, 1 cho ghi đè khả dụng đặc biệt
);

CREATE TABLE SessionLengths (
    UserID INT FOREIGN KEY REFERENCES Lecturers(LecturerID),
    PatternID INT FOREIGN KEY REFERENCES SchedulePatterns(PatternID),
    Length INT  -- 15, 30, 45, 60
);

CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    PatternID INT NULL FOREIGN KEY REFERENCES SchedulePatterns(PatternID),
    OverrideID INT NULL FOREIGN KEY REFERENCES OverrideDates(OverrideID),
    UserID INT FOREIGN KEY REFERENCES Students(StudentID),
    LecturerID INT FOREIGN KEY REFERENCES Lecturers(LecturerID),
    Date DATE,
    StartTime TIME,
    EndTime TIME,
    Status NVARCHAR(50)  CONSTRAINT CK_Status CHECK (Status in ('Booked','Cancelled')) -- 'Booked', 'Cancelled'
);





















