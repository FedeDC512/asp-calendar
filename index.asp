<%
' Verifica se l'utente ha effettuato il logout
If Request.QueryString("action") = "logout" Then
    ' Elimina tutte le variabili di sessione
    Session.Abandon
    ' Reindirizza alla pagina di login
    Response.Redirect "index.asp"
End If

' Verifica se l'utente è già autenticato
If Session("Logged_In") = True Then
    ' Reindirizza alla homepage o a un'altra pagina protetta
    Response.Redirect "homepage.asp"
End If

' Verifica se sono stati inviati dati di login
If Request.Form("username") <> "" And Request.Form("password") <> "" Then
    Dim username, password
    username = Request.Form("username")
    password = Request.Form("password")
    
    ' Connessione al database
    Dim conn, rs
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"
    
    ' Esegui la query per verificare le credenziali
    Dim sql
    sql = "SELECT username, is_admin, u_id FROM c_users WHERE username = '" & username & "' AND password = '" & password & "'"
    Set rs = conn.Execute(sql)
    
    ' Verifica se la query ha restituito un risultato
    If Not rs.EOF Then
        ' L'utente è stato trovato nel database, impostiamo le variabili di sessione
        Session("Logged_In") = True
        Session("username") = rs("username")
        If CInt(rs("is_admin")) = 1 Then
            Session("admin") = True
        Else
            Session("admin") = False
        End If
        Session("userID") = rs("u_id")
        
        ' Chiudi il recordset e la connessione al database
        rs.Close
        conn.Close
        
        ' Reindirizza alla homepage o a un'altra pagina protetta
        Response.Redirect "homepage.asp"
    Else
        ' Chiudi il recordset e la connessione al database
        rs.Close
        conn.Close
        
        ' Mostra un messaggio di errore se le credenziali non sono valide
        Response.Write "Credenziali non valide. Riprova."
    End If
End If
%>
<!DOCTYPE html>
<html>
<head>
    <title>Ruby Rhino Rentals - Login</title>
    <link rel="stylesheet" href="styles.css" type="text/css" >
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Stick&display=swap" rel="stylesheet">
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <div class="login-title stick-regular">Effettua il login</div>
            <form class="form" method="post" action="index.asp">
                <div>
                    <label>Username:</label><br>
                    <input type="text" name="username"><br>
                </div>
                <div>
                    <label>Password:</label><br>
                    <input type="password" name="password"><br>
                </div>
                <input type="submit" value="Login">
            </form>
            </div>
    </div>
</body>
</html>
