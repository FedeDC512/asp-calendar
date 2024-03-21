<%
Dim title, start, endd
title = Request.Form("title")
start = Request.Form("start")
endd = Request.Form("end")

' Connessione al database
Dim connString
connString = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open connString

' Elimina l'evento dal database
Dim strSQL
strSQL = "DELETE FROM events WHERE Title = '" & title & "' AND StartDate = '" & start & "' AND EndDate = '" & endd & "'"
conn.Execute(strSQL)

' Chiusura della connessione al database
conn.Close
Set conn = Nothing

Response.Write("Event deleted.")
%>