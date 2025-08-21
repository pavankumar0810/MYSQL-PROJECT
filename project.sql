create database project;
use project;

CREATE TABLE Locations (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    City VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Vehicles (
    VehicleID INT PRIMARY KEY AUTO_INCREMENT,
    Make VARCHAR(50) NOT NULL,
    Model VARCHAR(50) NOT NULL,
    Year INT,
    RentalRatePerDay DECIMAL(8, 2) NOT NULL,
    Status VARCHAR(20) DEFAULT 'Available' 
);


CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    VehicleID INT,
    PickupLocationID INT,
    PickupDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    FOREIGN KEY (PickupLocationID) REFERENCES Locations(LocationID)
);

-- ==============================================================

INSERT INTO Locations (City, Address) VALUES
('Los Angeles', '123 LAX Airport Rd'),
('New York', '456 JFK Airport Blvd');


INSERT INTO Customers (FullName, Email) VALUES
('Peter Jones', 'peter.j@email.com'),
('Maria Garcia', 'maria.g@email.com'),
('David Smith', 'david.s@email.com');


INSERT INTO Vehicles (Make, Model, Year, RentalRatePerDay, Status) VALUES
('Toyota', 'Camry', 2022, 55.00, 'Available'),
('Honda', 'CR-V', 2023, 70.00, 'Rented'),
('Ford', 'Mustang', 2021, 95.50, 'Available'),
('Tesla', 'Model 3', 2023, 120.00, 'Maintenance');


INSERT INTO Bookings (CustomerID, VehicleID, PickupLocationID, PickupDate, ReturnDate) VALUES
(1, 3, 1, '2024-06-25', '2024-06-28'),
(2, 2, 2, '2024-07-10', NULL),            
(1, 1, 1, '2024-08-05', '2024-08-10'); 

select* from Customers;
SELECT Make, Model, RentalRatePerDay FROM Vehicles WHERE Status = 'Available' AND RentalRatePerDay < 100.00;


SELECT Make, Model, Status FROM Vehicles WHERE Make = 'Toyota' OR Status = 'Maintenance';

SELECT * FROM Bookings WHERE PickupDate BETWEEN '2024-06-01' AND '2024-06-30';

-- like
SELECT Make, Model FROM Vehicles WHERE Model LIKE '%Model%';


-- --- UPDATE ---
UPDATE Vehicles SET Status = 'Available' WHERE VehicleID = 2;
UPDATE Bookings SET ReturnDate = '2024-07-20' WHERE BookingID = 2;
SELECT * FROM Vehicles WHERE VehicleID = 2; -- Verify change
SELECT * FROM Bookings WHERE BookingID = 2; -- Verify change


-- --- ALTER TABLE ---
ALTER TABLE Vehicles ADD COLUMN Color VARCHAR(30);
ALTER TABLE Vehicles DROP COLUMN Color;


-- --- JOINS (INNER and OUTER) ---

SELECT
    b.BookingID,
    c.FullName,
    v.Make,
    v.Model,
    b.PickupDate,
    b.ReturnDate,
    DATEDIFF(b.ReturnDate, b.PickupDate) * v.RentalRatePerDay AS CalculatedCost
FROM Bookings b
INNER JOIN Customers c ON b.CustomerID = c.CustomerID
INNER JOIN Vehicles v ON b.VehicleID = v.VehicleID
WHERE b.ReturnDate IS NOT NULL;


SELECT
    c.FullName,
    COUNT(b.BookingID) AS NumberOfBookings
FROM Customers c
LEFT JOIN Bookings b ON c.CustomerID = b.CustomerID
GROUP BY c.FullName;


-- --- GROUP BY, HAVING, ORDER BY ---

SELECT
    c.FullName,
    COUNT(b.BookingID) AS TotalBookings
FROM Customers c
JOIN Bookings b ON c.CustomerID = b.CustomerID
GROUP BY c.FullName
HAVING TotalBookings > 0
ORDER BY TotalBookings DESC;



-- STORED PROCEDURES
DROP PROCEDURE IF EXISTS GetCustomerHistory;
DROP PROCEDURE IF EXISTS CreateNewBooking;



DELIMITER //
CREATE PROCEDURE GetCustomerHistory(IN inputCustomerID INT)
BEGIN
    SELECT
        b.PickupDate,
        v.Make,
        v.Model,
        DATEDIFF(b.ReturnDate, b.PickupDate) AS DaysRented
    FROM Bookings b
    JOIN Vehicles v ON b.VehicleID = v.VehicleID
    WHERE b.CustomerID = inputCustomerID
    ORDER BY b.PickupDate DESC;
END //
DELIMITAER ;

SELECT 
CALL GetCustomerHistory(1);


SELECT 
DELIMITER //
CREATE PROCEDURE CreateNewBooking(
    IN inputCustomerID INT,
    IN inputVehicleID INT,
    IN inputPickupLocationID INT,
    IN inputPickupDate DATE
)
BEGIN
    -- Insert the new booking record
    INSERT INTO Bookings (CustomerID, VehicleID, PickupLocationID, PickupDate)
    VALUES (inputCustomerID, inputVehicleID, inputPickupLocationID, inputPickupDate);

    -- Update the vehicle's status to 'Rented'
    UPDATE Vehicles
    SET Status = 'Rented'
    WHERE VehicleID = inputVehicleID;
END //
DELIMITER ;


CALL CreateNewBooking(3, 3, 1, '2024-09-01');
SELECT '-- Verifying the new booking and status change';
SELECT * FROM Bookings WHERE CustomerID = 3;
SELECT Status FROM Vehicles WHERE VehicleID = 3;