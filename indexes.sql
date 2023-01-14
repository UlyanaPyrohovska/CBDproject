--Search sales by city. The name of the city, the name of the seller, to make available, total sales 
--(note: cities with the same name but different locations should be considered distinct);

SELECT * FROM City

SELECT * FROM SalesData s
join City c on c.CityID = s.CityID
--join UserTable e on e.UserID = s.SalesPersonID
where c.Name = 'Marion Junction'
