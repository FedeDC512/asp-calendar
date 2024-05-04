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
    <title>Ruby Rhino Rentals - Profile</title>
    <link rel="icon" type="image/svg" href="rhino.svg">
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js'></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <link rel="stylesheet" href="styles.css" type="text/css" >
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Stick&display=swap" rel="stylesheet">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script>
    function keepSessionAlive() {
        setInterval(function() {
            $.ajax({
                url: 'keep_session_alive.asp',
                type: 'GET',
                success: function(response) {
                    //console.log('Session maintained active');
                },
                error: function(xhr, status, error) {
                    console.error('Error while maintaining the session:', status, error);
                }
            });
        }, 30000); // 30 secondi
    }
    // Avvia il mantenimento della sessione al caricamento della pagina
    $(document).ready(function() {
        keepSessionAlive();
    });

    $(document).ready(function() {
        $.ajax({
            url: 'user_events.asp',
            type: 'GET',
            success: function(response) {
                console.log(response);
                let events = response;

                // Costruisci una stringa per visualizzare i dati degli eventi
                let html = '<div class="event-list">';
                for (let i = 0; i < events.length; i++) {
                    html += '<pre class="event-profile-info">'
                    html += 'ID: ' + events[i].id + '\n';
                    html += 'Title: ' + events[i].title + '\n';
                    html += 'Car: ' + events[i].car + '\n';
                    html += '<img class="car-profile" src="cars/'+events[i].car+'.png" alt="'+events[i].car+'">\n'
                    html += 'All Day: ' + events[i].allDay + '\n';

                    if(events[i].allDay){
                        let start = new Date(events[i].start).toLocaleDateString();
                        let end = new Date(events[i].end); //tolgo un giorno (end - 1 giorno) perchè FullCalendar visualizza la fine nel giorno successivo
                        let giorno = end.getDate();
                        end.setDate(giorno - 1);
                        end = end.toLocaleDateString();

                        if( start == end ) html += 'Date: ' + start + '\n'; //senza le ore
                        else html += 'Start: ' + start + '\nEnd: ' + end + '\n'; //senza le ore
                    } else {
                        let start = new Date(events[i].start).toLocaleString();
                        let end = new Date(events[i].end).toLocaleString();

                        html += 'Start: ' + start + '\n';
                        html += 'End: ' + end + '\n';
                    }

                    html += '\n';
                    
                    html += '</pre>';
                }
                html += '</div>';

                // Inserisci la stringa nella pagina HTML
                $('#events').html(html);
            },
            error: function(xhr, status, error) {
                console.error('Error during event retrival:', error);
            }
        });
    });
    </script>
</head>

<body>
    <!--#include file="header.asp"-->
    <div class="profile-info-container">
        <div class="profile-info">
            <div class="event-title"><%=Session("username")%>' Profile:</div><br>
            <%dim i
            For Each i in Session.Contents
            Response.Write(i & ": " & Session.Contents(i) & "<br>")
            Next
            %><br>


            <button><a href="index.asp?action=logout" class="logout">Logout</a></button>
        </div>
    </div>

    <div class="small-page-title stick-regular">Your car bookings</div>

    <div id="events"></div>
    
</body>