<%
Dim title, start, endd, car
title = Request.Form("title")
start = Request.Form("start")
endd = Request.Form("end")
car = Request.Form("car")

' Connessione al database
Dim connString
connString = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open connString

' Inserimento dell'evento nel database
Dim strSQL
strSQL = "INSERT INTO events (Title, StartDate, EndDate, Car) VALUES ('" & title & "', '" & start & "', '" & endd & "', '" & car & "')"
conn.Execute(strSQL)

' Chiusura della connessione al database
conn.Close
Set conn = Nothing

Response.Write("Event saved in the database")
%>