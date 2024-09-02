/* Ejercicio 1 Crear una vista que retorne el listado de todos los clientes junto con el total de pagos que han hecho. 
Debe incluir además a los clientes que aún no han realizado pagos, la vista debe retornar la siguiente información 
id del cliente, nombre del cliente, email y el total de pagos. Use subqueries.*/



/*Esta vista utiliza una subconsulta para calcular el total de pagos realizados por cada cliente.
Si un cliente no ha efectuado ningún pago, se devuelve un valor de 0.*/
CREATE VIEW [dbo].[CustomerPaymentsSummary] AS
SELECT 
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    c.Email,
    ISNULL((SELECT SUM(p.Amount) 
            FROM Payments p 
            WHERE p.BookingID IN (SELECT b.BookingID 
                                  FROM Bookings b 
                                  WHERE b.CustomerID = c.CustomerID)), 0) AS TotalPayments
FROM 
    Customers c;
GO

/*Ejercicio 2 Crear una vista que retorne todas las reservaciones que tienen pendiente una parte del pago, 
la consulta debe devolver la siguiente información id del cliente, nombre del cliente, id de la reservación, 
total a pagar, total pendiente a pagar. Use subqueries.*/


/*Esta vista encuentra reservaciones donde el monto total pagado es menor que el monto total adeudado.
Utiliza una subconsulta para determinar la cantidad pendiente de pago.*/
CREATE VIEW [dbo].[PendingPayments] AS
SELECT 
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    b.BookingID,
    b.TotalAmount AS TotalToPay,
    b.TotalAmount - ISNULL((SELECT SUM(p.Amount) 
                            FROM Payments p 
                            WHERE p.BookingID = b.BookingID), 0) AS PendingAmount
FROM 
    Bookings b
INNER JOIN 
    Customers c ON b.CustomerID = c.CustomerID
WHERE 
    b.TotalAmount > (SELECT ISNULL(SUM(p.Amount), 0) 
                     FROM Payments p 
                     WHERE p.BookingID = b.BookingID);
GO

/*Ejercicio 3 Crear una vista que retorne los cuartos que tienen la mayor cantidad de reservaciones. 
Debe incluir un Right Join para incluir todos los cuartos. La información a mostrar es la siguiente: 
id del cuarto, tipo de cuarto, precio, cantidad de reservaciones*/


/** Esta vista emplea un RIGHT JOIN para incluir todos los cuartos y contabilizar cuántas reservaciones tiene cada uno,
incluso si no tienen ninguna, en cuyo caso el conteo es 0.*/
CREATE VIEW [dbo].[RoomReservationCount] AS
SELECT 
    r.RoomID,
    r.RoomType,
    r.Rate,
    ISNULL((SELECT COUNT(b.BookingID) 
            FROM Bookings b 
            WHERE b.RoomID = r.RoomID), 0) AS ReservationCount
FROM 
    Rooms r
RIGHT JOIN 
    Bookings b ON r.RoomID = b.RoomID
GROUP BY 
    r.RoomID, r.RoomType, r.Rate;
GO
