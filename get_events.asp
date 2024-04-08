<%
Dim connString
connString = "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open connString

' Recupera gli eventi dal database
Dim strSQL, rsEvents, events
strSQL = "SELECT id, Title, Car, DATE_FORMAT(StartDate, '%Y-%m-%d') AS StartDate, DATE_FORMAT(EndDate, '%Y-%m-%d') AS EndDate, CreatedBy FROM events"
Set rsEvents = conn.Execute(strSQL)

If Not rsEvents.EOF Then
    events = "[" ' Inizia l'array JSON
    Do While Not rsEvents.EOF
        events = events & "{""id"":""" & rsEvents("id") & """, ""car"":""" & rsEvents("Car") & """, ""title"":""" & rsEvents("Title") & """, ""start"":""" & rsEvents("StartDate") & """, ""end"":""" & rsEvents("EndDate") & """, ""creator"":""" & rsEvents("CreatedBy") & """}"
        rsEvents.MoveNext
        If Not rsEvents.EOF Then
            events = events & "," ' Aggiungi una virgola se non è l'ultimo evento
        End If
    Loop
    events = events & "]" ' Termina l'array JSON
End If

rsEvents.Close

' Chiusura della connessione al database
conn.Close
Set conn = Nothing

' Restituisci gli eventi come array JSON
Response.ContentType = "application/json"
Response.Write(events)
%>
