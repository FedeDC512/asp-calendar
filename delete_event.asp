<%
Dim id
id = Request.Form("id")

' Connessione al database
Dim connString
connString = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open connString

' Elimina l'evento dal database
Dim strSQL
strSQL = "DELETE FROM events WHERE id = '" & id & "'"
conn.Execute(strSQL)

' Chiusura della connessione al database
conn.Close
Set conn = Nothing

Response.Write("Event deleted")
%>