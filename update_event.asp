<%
Dim id, start, endd
id = Request.Form("id")
start = Request.Form("start")
endd = Request.Form("end")

' Connessione al database
Dim connString
connString = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open connString

' Aggiornamento dell'evento nel database
Dim strSQL
strSQL = "UPDATE events SET StartDate = '" & start & "', EndDate = '" & endd & "' WHERE id = '" & id & "'"
conn.Execute(strSQL)

' Chiusura della connessione al database
conn.Close
Set conn = Nothing

Response.Write("Event updated in the database.")
%>
