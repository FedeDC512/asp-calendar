<%
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"

' Query per selezionare tutte le macchine
Dim strSQL
strSQL = "SELECT * FROM cars"
Set rs = conn.Execute(strSQL)

' Creazione di un oggetto JSON per contenere i dati delle macchine
Dim jsonData
jsonData = "[" ' Apertura dell'array JSON

' Iterazione sui record del set di risultati e aggiunta dei dati all'array JSON
Do While Not rs.EOF
    Dim carJson
    carJson = "{"
    carJson = carJson & """name"":""" & Replace(rs("name"), """", "\""") & ""","
    carJson = carJson & """year"":""" & rs("year") & ""","
    carJson = carJson & """people"":""" & rs("people") & ""","
    carJson = carJson & """km"":""" & FormatNumber(rs("km"), 2, vbFalse, vbFalse, vbTrue) & ""","
    carJson = carJson & """change_type"":""" & Replace(rs("change_type"), """", "\""") & ""","
    carJson = carJson & """power_supply"":""" & Replace(rs("power_supply"), """", "\""") & ""","
    carJson = carJson & """price"":""" & FormatNumber(rs("price"), 2, vbFalse, vbFalse, vbTrue) & """"
    carJson = carJson & "}"
    
    ' Aggiunta del record al JSON principale
    jsonData = jsonData & carJson & ","
    
    rs.MoveNext
Loop


' Rimozione della virgola finale dall'array JSON
If Right(jsonData, 1) = "," Then
    jsonData = Left(jsonData, Len(jsonData) - 1)
End If

jsonData = jsonData & "]" ' Chiusura dell'array JSON

' Chiusura del recordset e della connessione al database
rs.Close
conn.Close
Set rs = Nothing
Set conn = Nothing

' Output del JSON
Response.ContentType = "application/json"
Response.Write(jsonData)
%>
