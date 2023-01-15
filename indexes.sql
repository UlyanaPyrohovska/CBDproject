--Search sales by city. The name of the city, the name of the seller, to make available, total sales 
--(note: cities with the same name but different locations should be considered distinct);

SELECT * FROM UserTable

SET STATISTICS IO ON

SELECT distinct s.CityID, c.Name, st.Name from SaleHeader s
left join City c on c.CityID = s.CityID
join State st on st.StateID = c.StateID
order by c.Name
join UserTable e on e.UserID = s.SalesPersonID
where E.PrimaryContact like 'K%'

--CREATE NONCLUSTERED INDEX pc_index on UserTable(PrimaryContact)
--CREATE NONCLUSTERED INDEX emp_index on SaleHeader(SalesPersonID)
CREATE NONCLUSTERED INDEX city_index on City(Name)
--CREATE NONCLUSTERED INDEX state_index on State(Name)

--DROP INDEX pc_index on UserTable
--DROP INDEX emp_index on SaleHeader
DROP INDEX city_index on City
--DROP INDEX state_index on State

SELECT c.Name, st.Name, e.PrimaryContact, COUNT(SaleHeaderID) as TotalSales FROM SaleHeader s
join City c on c.CityID = s.CityID
join State st on st.StateID = c.StateID
join UserTable e on e.UserID = s.SalesPersonID
where c.Name = 'Madaket' and st.Name = 'Massachusetts'
group by  c.Name, e.PrimaryContact, st.Name

SET STATISTICS IO OFF