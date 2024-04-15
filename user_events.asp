<%
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"

Dim userID
userID = Session("userID")

Dim strSQL, rsEvents, events
strSQL = "SELECT id, Title, Car, DATE_FORMAT(StartDate, '%Y-%m-%d, %H:%i') AS StartDate, DATE_FORMAT(EndDate, '%Y-%m-%d, %H:%i') AS EndDate, allDay FROM events WHERE CreatedBy = " & userID & " ORDER BY StartDate"
Set rsEvents = conn.Execute(strSQL)

If Not rsEvents.EOF Then
    events = "[" ' Inizia l'array JSON
    Do While Not rsEvents.EOF
        events = events & "{""id"":""" & rsEvents("id") & """, ""car"":""" & rsEvents("Car") & """, ""title"":""" & rsEvents("Title") & """, ""start"":""" & rsEvents("StartDate") & """, ""end"":""" & rsEvents("EndDate") & """, "
        
        If rsEvents("allDay") = 0 Then 
            events = events & """allDay"":false}"
        Else 
            events = events & """allDay"":true}"
        End If
        
        rsEvents.MoveNext
        If Not rsEvents.EOF Then
            events = events & "," ' Aggiungi una virgola se non è l'ultimo evento
        End If
    Loop
    events = events & "]" ' Termina l'array JSON
End If

rsEvents.Close

conn.Close
Set conn = Nothing

Response.ContentType = "application/json"
Response.Write(events)
%>
