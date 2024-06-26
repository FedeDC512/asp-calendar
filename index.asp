
<!--#include file="ASPMD5/class_md5.asp"-->
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

    Dim objMD5, hashed_password
    Set objMD5 = New MD5
    objMD5.Text = password
    hashed_password = objMD5.HEXMD5
    
    ' Connessione al database
    Dim conn, rs
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "Driver={MySQL ODBC 3.51 Driver};Server=localhost;Database=federico;Uid=federico;Pwd=agnello;"
    
    ' Esegui la query per verificare le credenziali
    Dim sql
    sql = "SELECT username, is_admin, u_id FROM c_users WHERE username = '" & username & "' AND password = '" & hashed_password & "'"
    Set rs = conn.Execute(sql)

    Dim dynamicError
    
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
        dynamicError = "Invalid credentials. Retry!"
    End If
End If
%>
<!DOCTYPE html>
<html>
<head>
    <title>Ruby Rhino Rentals - Login</title>
    <link rel="stylesheet" href="styles.css" type="text/css" >
    <link rel="icon" type="image/svg" href="rhino.svg">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&family=Stick&display=swap" rel="stylesheet">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<script>
/*
document.addEventListener('DOMContentLoaded', function() {
    function showSignUp(event) {
        event.preventDefault(); // Impedisce l'azione predefinita del bottone
        let container = document.getElementById('container');
        container.classList.add('sign-up-container');

        let colLeft = document.getElementById('col-left');
        colLeft.classList.add('sign-up-col-left');

        document.getElementById('col-left-signup').classList.remove('hidden');
        document.getElementById('col-left-login').classList.add('hidden');

        document.getElementById('col-right-signup').classList.remove('hidden');
        document.getElementById('col-right-login').classList.add('hidden');

        return false; // Assicura che l'evento non venga propagato oltre
    }

    document.getElementById('sign-up').addEventListener('click', showSignUp);
});*/
</script>

</head>
<body>

<div class="wrapper login">
        <div class="container" id="container">

            <div class="col-left" id="col-left">

                <div id="col-left-login">
                    <div class="login-text stick-regular">
                        <svg class="login-rhino" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 512 512"><path fill="currentColor" d="M450.125 32.734c-9.41 47.727-17.293 105.183-30.922 156.774c-8.34 31.574-18.838 60.978-33.72 84.795c-12.89 20.63-29.425 37.144-50.47 46.172c12.023 25.86 43.083 47.34 76.24 53.63c3.538-6.146 7.304-13.7 11.08-22.447c10.868-25.16 21.89-59.925 29.843-99.13c13.89-68.487 18.235-150.56-2.05-219.794zM18 38.904V494h39.537c7.66-8.97 13.41-22.46 17.453-46c36.388 0 55.403-4.45 66.643-11.002c-28.225-25.493-51.414-58.844-68.455-101.207c11.647 15.058 25.708 29.464 42.047 42.96c43.04 66.73 107.412 97.86 188.41 106.137c.528-.748.977-1.347 1.726-2.532c1.156-1.823 2.407-3.91 4.275-6.074c1.868-2.162 4.978-5.622 10.906-5.264c5.675.342 8.213 3.45 10.146 5.636c1.932 2.186 3.372 4.383 4.71 6.342c1.196 1.756 2.208 3.126 2.928 3.985c33.258.64 59.62-3.37 76.278-12.105c16.926-8.875 24.842-20.973 24.392-42.29c-1.524-14.847-11.34-27.683-26.947-40.118c-40.617-6.275-78.99-31.115-94.06-66.02c-11.03-1.295-20.466-8.332-27.383-16.86c-8.08-9.963-13.61-22.38-16.327-34.36c-10.642-23.767-32.987-62.51-58.23-95.098c-12.69-16.383-26.14-31.236-38.918-41.884a115.044 115.044 0 0 0-10.282-7.67l-14.9 7.45c-8.804-17.61-12.764-38.21-16.733-56.073c-2.863-12.88-6.157-24.08-9.576-31.213c-18.795 14.465-23.428 28.884-22.86 44.033c.64 16.96 9.29 35.243 17.27 51.202l-16.1 8.05a850.688 850.688 0 0 1-4.14-8.38c-11.03 13.237-20.28 31.073-26.37 50.798c-6.42 20.808-9.224 43.544-7.645 65.106l-18.42-20.466c.835-17.014 3.946-34.01 8.865-49.95c7.323-23.725 18.72-45.27 33.504-61.33c.698-.758 1.407-1.5 2.123-2.234c-3.773-9.99-6.648-20.786-7.074-32.12c-.12-3.19-.005-6.415.352-9.653C64.072 65.847 42.305 48.19 18 38.904M194.36 60.74c-3.418 7.133-6.712 18.332-9.575 31.213c-1.77 7.97-3.603 16.458-5.846 24.984a152.97 152.97 0 0 1 9.71 7.48c6.103 5.086 12.168 10.863 18.143 17.136c5.438-12.064 9.973-24.722 10.426-36.78c.568-15.15-4.065-29.568-22.86-44.033zm157.05 142.824c-5.54 15.163-11.94 31.276-21.65 45.877c-7.622 11.46-17.263 21.663-29.983 27.83a55.92 55.92 0 0 1-5.5 2.302c2.51 6.778 6.125 13.518 10.307 18.674a43.676 43.676 0 0 0 3.772 4.11l4.384 3.51a19.802 19.802 0 0 0 3.97 1.984l3.183-.938c11.455-3.372 21.48-9.33 30.41-17.547a142.926 142.926 0 0 0 2.9-11.252c4.44-20.718 5.33-46.135-1.792-74.55zM226.2 322.134c6.122.148 12.176 1.467 17.788 3.446c12.83 4.524 24.37 12.33 33.467 19.26l-10.906 14.32c-.79-.602-1.616-1.21-2.442-1.816C261.828 364.064 255.42 369 248 369c-9.282 0-17-7.718-17-17c0-3.94 1.4-7.59 3.71-10.496c-8.33-2.39-15.434-2.134-21.774 2.023l-9.872-15.054c6.477-4.247 13.5-6.1 20.508-6.328c.876-.03 1.753-.03 2.627-.01zm170.46 100.637a38.27 38.27 0 0 1 4.473.3l-2.26 17.86c-9.21-1.166-15.993 2.556-23.755 12.58l-14.23-11.02c8.79-11.354 20.693-19.265 34.308-19.7a37.56 37.56 0 0 1 1.465-.02z"/></svg>
                        Welcome back! <br>Please login to R.R.R.
                    </div>
                    <p class="login-text-small">Not registered?<br>Create an account!</p>
                    <a href="" class="bootstrap-btn-2" id="sign-up">Sign Up</a>
                </div>

                <div id="col-left-signup" class="sign-up-col-left-inside hidden">
                    <div class="login-text stick-regular">
                        <svg class="login-rhino" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 512 512"><path fill="currentColor" d="M450.125 32.734c-9.41 47.727-17.293 105.183-30.922 156.774c-8.34 31.574-18.838 60.978-33.72 84.795c-12.89 20.63-29.425 37.144-50.47 46.172c12.023 25.86 43.083 47.34 76.24 53.63c3.538-6.146 7.304-13.7 11.08-22.447c10.868-25.16 21.89-59.925 29.843-99.13c13.89-68.487 18.235-150.56-2.05-219.794zM18 38.904V494h39.537c7.66-8.97 13.41-22.46 17.453-46c36.388 0 55.403-4.45 66.643-11.002c-28.225-25.493-51.414-58.844-68.455-101.207c11.647 15.058 25.708 29.464 42.047 42.96c43.04 66.73 107.412 97.86 188.41 106.137c.528-.748.977-1.347 1.726-2.532c1.156-1.823 2.407-3.91 4.275-6.074c1.868-2.162 4.978-5.622 10.906-5.264c5.675.342 8.213 3.45 10.146 5.636c1.932 2.186 3.372 4.383 4.71 6.342c1.196 1.756 2.208 3.126 2.928 3.985c33.258.64 59.62-3.37 76.278-12.105c16.926-8.875 24.842-20.973 24.392-42.29c-1.524-14.847-11.34-27.683-26.947-40.118c-40.617-6.275-78.99-31.115-94.06-66.02c-11.03-1.295-20.466-8.332-27.383-16.86c-8.08-9.963-13.61-22.38-16.327-34.36c-10.642-23.767-32.987-62.51-58.23-95.098c-12.69-16.383-26.14-31.236-38.918-41.884a115.044 115.044 0 0 0-10.282-7.67l-14.9 7.45c-8.804-17.61-12.764-38.21-16.733-56.073c-2.863-12.88-6.157-24.08-9.576-31.213c-18.795 14.465-23.428 28.884-22.86 44.033c.64 16.96 9.29 35.243 17.27 51.202l-16.1 8.05a850.688 850.688 0 0 1-4.14-8.38c-11.03 13.237-20.28 31.073-26.37 50.798c-6.42 20.808-9.224 43.544-7.645 65.106l-18.42-20.466c.835-17.014 3.946-34.01 8.865-49.95c7.323-23.725 18.72-45.27 33.504-61.33c.698-.758 1.407-1.5 2.123-2.234c-3.773-9.99-6.648-20.786-7.074-32.12c-.12-3.19-.005-6.415.352-9.653C64.072 65.847 42.305 48.19 18 38.904M194.36 60.74c-3.418 7.133-6.712 18.332-9.575 31.213c-1.77 7.97-3.603 16.458-5.846 24.984a152.97 152.97 0 0 1 9.71 7.48c6.103 5.086 12.168 10.863 18.143 17.136c5.438-12.064 9.973-24.722 10.426-36.78c.568-15.15-4.065-29.568-22.86-44.033zm157.05 142.824c-5.54 15.163-11.94 31.276-21.65 45.877c-7.622 11.46-17.263 21.663-29.983 27.83a55.92 55.92 0 0 1-5.5 2.302c2.51 6.778 6.125 13.518 10.307 18.674a43.676 43.676 0 0 0 3.772 4.11l4.384 3.51a19.802 19.802 0 0 0 3.97 1.984l3.183-.938c11.455-3.372 21.48-9.33 30.41-17.547a142.926 142.926 0 0 0 2.9-11.252c4.44-20.718 5.33-46.135-1.792-74.55zM226.2 322.134c6.122.148 12.176 1.467 17.788 3.446c12.83 4.524 24.37 12.33 33.467 19.26l-10.906 14.32c-.79-.602-1.616-1.21-2.442-1.816C261.828 364.064 255.42 369 248 369c-9.282 0-17-7.718-17-17c0-3.94 1.4-7.59 3.71-10.496c-8.33-2.39-15.434-2.134-21.774 2.023l-9.872-15.054c6.477-4.247 13.5-6.1 20.508-6.328c.876-.03 1.753-.03 2.627-.01zm170.46 100.637a38.27 38.27 0 0 1 4.473.3l-2.26 17.86c-9.21-1.166-15.993 2.556-23.755 12.58l-14.23-11.02c8.79-11.354 20.693-19.265 34.308-19.7a37.56 37.56 0 0 1 1.465-.02z"/></svg>
                        Welcome to <br>Ruby Rhino Rentals
                    </div>
                    <p class="login-text-small">Already have an account?<br>Login with your credentials!</p>
                    <a href="" class="bootstrap-btn-2" id="login">Login</a>
                </div>

            </div>

            <div class="col-right" id="col-right-login">
                <div class="login-title stick-regular">Login</div>
                <form class="form" method="post" action="index.asp">
                    <input class="bootstrap-form" placeholder="Username" type="text" name="username" required>
                    <input class="bootstrap-form" placeholder="Password" type="password" name="password" required>
                    <input class="bootstrap-btn-1" type="submit" value="Login">
                </form>
                <div class="error-message"> <%= dynamicError %></div>
            </div>

            <div class="col-right sign-up-col-right hidden" id="col-right-signup">
                <div class="login-title stick-regular">Sign Up</div>
                <form class="form" method="post" action="sign_in.asp">
                    <input class="bootstrap-form" placeholder="Username" type="text" name="username" required>
                    <input class="bootstrap-form" placeholder="Password" type="password" name="password" required>
                    <div class="checkbox-wrapper-4">
                        <input class="inp-cbx" id="admin-true" type="checkbox" name="is_admin"/>
                        <label class="cbx" for="admin-true"><span style="color: black;">
                        <svg width="12px" height="10px">
                            <use xlink:href="#check-4"></use>
                        </svg></span><span style="color: black;">Check to be an admin</span></label>
                        <svg class="inline-svg">
                            <symbol id="check-4" viewbox="0 0 12 10">
                            <polyline points="1.5 6 4.5 9 10.5 1"></polyline>
                            </symbol>
                        </svg>
                    </div>
                    <input class="bootstrap-btn-1" type="submit" value="Sign Up">
                </form>
            </div>

        </div>
    </div>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script>
        $(document).ready(function() {
            function showSignUp(event) {
                event.preventDefault(); 

                $('#col-left-login').fadeOut('slow', function() {
                    $('#col-left-signup').fadeIn('slow');
                });

                $('#col-right-login').fadeOut('slow', function() {
                    $('#col-right-signup').fadeIn('slow');
                    $('#col-right-signup').addClass('show-flex');

                    $('#container').addClass('sign-up-container');
                    $('#col-left').addClass('sign-up-col-left');
                });
                
                if ($(window).width() > 768) {
                    $('#col-left').fadeOut('slow', function() {
                        $('#col-left').fadeIn('slow');
                    });
                }

                return false;
            }

            $('#sign-up').click(showSignUp);
        });

        $(document).ready(function() {
            function showLogin(event) {
                event.preventDefault(); 

                $('#col-left-signup').fadeOut('slow', function() {
                    $('#col-left-login').fadeIn('slow');
                });

                $('#col-right-signup').fadeOut('slow', function() {
                    $('#col-right-login').fadeIn('slow');
                    $('#col-right-signup').removeClass('show-flex');
                    
                    $('#container').removeClass('sign-up-container');
                    $('#col-left').removeClass('sign-up-col-left');
                });

                if ($(window).width() > 768) {
                    $('#col-left').fadeOut('slow', function() {
                        $('#col-left').fadeIn('slow');
                    });
                }

                return false;
            }

            $('#login').click(showLogin);
        });

    </script>
</body>
</html>
