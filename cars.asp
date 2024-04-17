<%
' Verifica se l'utente è autenticato
If Session("Logged_In") <> True Then
    ' Reindirizza alla pagina di login
    Response.Redirect "index.asp"
End If
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/svg" href="rhino.svg">
    <title>Ruby Rhino Rentals - Cars</title>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js'></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <link rel="stylesheet" href="styles.css" type="text/css" >
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Stick&display=swap" rel="stylesheet">

    <script>
    </script>
</head>

<body>
    <!--#include file="header.asp"-->
    
</body>