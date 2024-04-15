<%
' Connessione al database
Dim conn, rs
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"

' ID ricevuto dalla richiesta
Dim userID
userID = Request.QueryString("id")

' Query per recuperare l'username corrispondente all'ID
Dim strSQL
strSQL = "SELECT username FROM c_users WHERE u_id = " & userID

' Esecuzione della query
Set rs = conn.Execute(strSQL)

' Verifica se la query ha restituito un record
If Not rs.EOF Then
    ' Se è stata trovata una corrispondenza, restituisci l'username
    Dim username
    username = rs("username")
    Response.Write username
Else
    ' Se non è stata trovata una corrispondenza, restituisci un messaggio indicando che l'utente non è stato trovato
    Response.Write "No user found"
End If

' Chiudi il recordset e la connessione al database
rs.Close
conn.Close
Set rs = Nothing
Set conn = Nothing
%>
