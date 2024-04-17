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
    <title>Ruby Rhino Rentals</title>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js'></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <link rel="stylesheet" href="styles.css" type="text/css" >
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Stick&display=swap" rel="stylesheet">


    <script>
    function hideEventInfo() {
        let infoItem = document.getElementById('event-info');
        infoItem.innerHTML = '<div class="event-title">Select an Event from the Calendar</div>'; // Svuota il contenuto del div delle informazioni dell'evento
    }

    
    function deleteEvent(id) {
        let calendar = $('#calendar').data('fullCalendarObj'); //retreive the object from data attr (IMPORTANTE!)
        let event = calendar.getEventById(id);
        if(event){ //TODO: non viene trovato l'id degli eventi appena creati
            let isAdmin = "<%=Session("admin")%>" == "True" ? true : false;
            let isCreator = event.extendedProps.creator == <%=Session("userID")%>; 

            if (isAdmin || isCreator) {
                if (confirm("Do you want to delete this event?")) {
                    $.ajax({
                        url: 'delete_event.asp',
                        type: 'POST',
                        data: { 
                            id: id
                        },
                        success: function(response) {
                            console.log('Event deleted');

                            // Verifica se l'evento esiste
                            if (event) {
                                // Rimuovi l'evento dal calendario
                                event.remove();
                                console.log('Event with ID ' + id + ' deleted successfully.');
                            } else {
                                console.error('Event with ID ' + id + ' not found.');
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('Error deleting event:', error);
                        }
                    });
                }
            } else alert("You don't have permission to delete this event!");
        } else alert("You can't delete this event now, try reloading the page");
    }

    document.addEventListener('DOMContentLoaded', function() {
        let calendarEl = document.getElementById('calendar');

        let calendar = new FullCalendar.Calendar(calendarEl, {
            defaultAllDay: false,
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay'
            },
            editable: true,
            selectable: true,
            select: function(info) {
                let title = prompt('Insert event title:');
                if (title) {
                    let creator = <%=Session("userID")%>;
                    let car = prompt('Enter the Car model:');
                    let answer = prompt("Do you want to rent the car for the whole day(s)?\nAnswer with 'yes' or 'no'", "yes");
                    answer = answer.toLowerCase();
                    let allDay = (answer == 'yes') ? 1 : 0; //1 = true, 0 = false. in MySql there is no boolean :(
                    if (allDay == 0){
                        let startTime = prompt('Enter the start time (HH:mm):');
                        let endTime = prompt('Enter the end time (HH:mm):');

                        if (startTime && endTime) {
                            let start = info.startStr.split('T')[0] + 'T' + startTime;
                            let end = info.endStr.split('T')[0] + 'T' + endTime;
                            console.log(start);

                            let endVisual = new Date(info.endStr); //tolgo un giorno (end - 1 giorno) perchè FullCalendar visualizza la fine nel giorno successivo (non so perchè)
                            let giorno = endVisual.getDate();
                            endVisual.setDate(giorno - 1);
                            endVisual = endVisual.toISOString().split('T')[0] + 'T' + endTime;

                            let eventData = {
                                title: title,
                                start: start,
                                end: endVisual, //quando visualizzo l'evento, finisce al giorno -1
                                car: car,
                                creator: creator,
                                allDay: allDay,
                            };
                            console.log(eventData);
                            calendar.addEvent(eventData);
                            saveEvent(title, start, endVisual, car, creator, allDay); // Chiamata alla funzione ASP per salvare l'evento
                        } else {
                            alert('You must enter both times.');
                        }
                    } else {
                        let start = info.startStr;
                        let end = info.endStr;
                        let eventData = {
                            title: title,
                            start: start,
                            end: end,
                            car: car,
                            creator: creator,
                            allDay: allDay,
                        };
                        console.log(eventData);
                        calendar.addEvent(eventData);
                        saveEvent(title, start, end, car, creator, allDay); // Chiamata alla funzione ASP per salvare l'evento
                    }
                
                }
            },
            eventClick: function(info) {
                showEventInfo(info.event);
            },
            eventDrop: function(info) {
                updateEvent(info.event);
            },
            eventAllow: function(dropInfo, draggedEvent) {
                if(draggedEvent.id){ //TODO: non viene trovato l'id degli eventi appena creati
                    // Verifica se l'utente è un admin
                    console.log(draggedEvent);
                    let isAdmin = "<%=Session("admin")%>" == "True" ? true : false; // Imposta questa variabile in base alla sessione dell'utente

                    // Verifica se l'utente è l'organizzatore (creator) dell'evento
                    let isCreator = draggedEvent.extendedProps.creator == <%=Session("userID")%>; // Imposta questa variabile in base alla sessione dell'utente

                    // Consenti lo spostamento solo se l'utente è un admin o è l'organizzatore dell'evento
                    if (!isAdmin && !isCreator) {
                        return false; // Non consentire lo spostamento
                    }

                    return true; // Consenti lo spostamento
                } else {
                    return false;
                }
            }
        });

        $(calendarEl).data('fullCalendarObj',calendar); //save the calendar pointer in data attached to Dom object

        calendar.render();
        
        // Carica gli eventi dal database quando la pagina viene caricata
        loadEvents();
            
        function loadEvents() {
            $.ajax({
                url: 'get_events.asp', // Script ASP per recuperare gli eventi dal database
                type: 'GET',
                success: function(response) {
                    console.log('Response from server:', response);
                    // Aggiungi gli eventi recuperati direttamente al calendario
                    calendar.addEventSource(response);
                },
                error: function(xhr, status, error) {
                    console.error('Error during event retrieval:', error);
                }
            });
        }

        function saveEvent(title, start, end, car, creator, allDay) {
            // Chiamata AJAX a uno script ASP per salvare l'evento nel database o in un file
            $.ajax({
                url: 'save_event.asp',
                type: 'POST',
                data: { title: title, start: start, end: end, car: car, creator: creator, allDay: allDay},
                success: function(response) {
                    console.log('Event saved');
                },
                error: function(xhr, status, error) {
                    console.error('Error saving event:', error);
                }
            });
        }

        function updateEvent(event) {

            //a FullCalendar non vanno bene le date con il fuso orario, quindi lo rimuovo dalle stringhe event.startStr e event.endStr
            var dateWithTimeZone = new Date(event.startStr);
            var year = dateWithTimeZone.getFullYear();
            var month = ('0' + (dateWithTimeZone.getMonth() + 1)).slice(-2); // Aggiungi 1 al mese perché i mesi in JavaScript partono da zero
            var day = ('0' + dateWithTimeZone.getDate()).slice(-2);
            var hours = ('0' + dateWithTimeZone.getHours()).slice(-2);
            var minutes = ('0' + dateWithTimeZone.getMinutes()).slice(-2);
            var seconds = ('0' + dateWithTimeZone.getSeconds()).slice(-2);
            var startWithoutTimeZone = year + '-' + month + '-' + day + 'T' + hours + ':' + minutes + ':' + seconds;

            dateWithTimeZone = new Date(event.endStr);
            year = dateWithTimeZone.getFullYear();
            month = ('0' + (dateWithTimeZone.getMonth() + 1)).slice(-2);
            day = ('0' + dateWithTimeZone.getDate()).slice(-2);
            hours = ('0' + dateWithTimeZone.getHours()).slice(-2);
            minutes = ('0' + dateWithTimeZone.getMinutes()).slice(-2);
            seconds = ('0' + dateWithTimeZone.getSeconds()).slice(-2);
            var endWithoutTimeZone = year + '-' + month + '-' + day + 'T' + hours + ':' + minutes + ':' + seconds;

            $.ajax({
                url: 'update_event.asp',
                type: 'POST',
                data: { 
                    id: event.id,
                    start: startWithoutTimeZone,
                    end: endWithoutTimeZone
                },
                success: function(response) {
                    console.log('Event with id ' + event.id + ' updated');
                },
                error: function(xhr, status, error) {
                    console.error('Error updating event:', error);
                }
            });
        }

        function showEventInfo(event) {
            console.log(event);
            let infoItem = document.getElementById('event-info');
            let html;

            let userID = event.extendedProps.creator ? event.extendedProps.creator : 0;
            let username;
            
            getUsername(userID)
                .then(function(result) {
                    username = result; // Salva l'username nella variabile

                    if(event.allDay){
                        let start = event.start.toLocaleDateString();
                        let end = new Date(event.end); //tolgo un giorno (end - 1 giorno) perchè FullCalendar visualizza la fine nel giorno successivo (non so perchè)
                        let giorno = end.getDate();
                        end.setDate(giorno - 1);
                        end = end.toLocaleDateString();

                        html = `<div class="event-item-bar"><div class="event-title">Selected Event:</div>
                        <button onclick="hideEventInfo()">Close</button></div>
                        <p><strong>Title:</strong> ${event.title} </p>
                        <p><strong>Car:</strong> ${event.extendedProps.car} </p>
                        <img class="car-calendar" src="cars/${event.extendedProps.car}.png" alt="${event.extendedProps.car}">
                        <p><strong>Created by:</strong> ${username} </p>
                        <p><strong>All Day:</strong> ${event.allDay} </p>`
                        if( start == end ) html += `<p><strong>Date:</strong> ${start} </p>`
                        else html += `<p><strong>Start:</strong> ${start} </p>
                            <p><strong>End:</strong> ${end} </p>`
                        html += `<button onclick="deleteEvent( ${event.id} )">Delete</button>`;
                    } else {
                        html = `<div class="event-item-bar"><div class="event-title">Selected Event:</div>
                        <button onclick="hideEventInfo()">Close</button></div>
                        <p><strong>Title:</strong> ${event.title} </p>
                        <p><strong>Car:</strong> ${event.extendedProps.car} </p>
                        <img class="car-calendar" src="cars/${event.extendedProps.car}.png" alt="${event.extendedProps.car}">
                        <p><strong>Created by:</strong> ${username} </p>
                        <p><strong>All Day:</strong> ${event.allDay} </p>
                        <p><strong>Start:</strong> ${event.start.toLocaleString()} </p>
                        <p><strong>End:</strong> ${event.end.toLocaleString()} </p>
                        <button onclick="deleteEvent( ${event.id} )">Delete</button>`;
                    }
                    infoItem.innerHTML = html;

            })
            .catch(function(error) {
                $("#risultato").text("Si è verificato un errore durante la ricerca dell'username.");
            });
        }

        function getUsername(userID) {
            return new Promise(function(resolve, reject) {
                let url = "find_username.asp?id=" + userID;

                $.ajax({
                    url: url,
                    type: "GET",
                    success: function(response) {
                        let username = response; // Salva l'username nella variabile
                        resolve(username); // Risolvi la promessa con l'username
                    },
                    error: function(xhr, status, error) {
                        console.error('An error occurred:', error);
                        reject(error); // Rifiuta la promessa con l'errore
                    }
                });
            });
        }


    });
    </script>
</head>
<body>
<!--#include file="header.asp"-->

<div class="homepage-division">
    <div class="calendar-column">
        <div id='calendar'></div>
    </div>
    <div class="info-column">
        <div class="event-info">
            <div class="event-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" viewBox="0 0 24 24"><path fill="currentColor" d="M11 17h2v-6h-2zm1-8q.425 0 .713-.288T13 8t-.288-.712T12 7t-.712.288T11 8t.288.713T12 9m0 13q-2.075 0-3.9-.788t-3.175-2.137T2.788 15.9T2 12t.788-3.9t2.137-3.175T8.1 2.788T12 2t3.9.788t3.175 2.137T21.213 8.1T22 12t-.788 3.9t-2.137 3.175t-3.175 2.138T12 22m0-2q3.35 0 5.675-2.325T20 12t-2.325-5.675T12 4T6.325 6.325T4 12t2.325 5.675T12 20m0-8"/></svg>
            Calendar Tutorial:</div>
            <p>Here are some basic instructions on how to use the calendar:</p>
            <ul>
                <li><strong>To Add Events:</strong> Click on a day to select it, then fill out the event details in the prompt.</li>
                <li><strong>To Move Events:</strong> Click and drag an event to a new time or date.</li>
                <li><strong>To Delete Events:</strong> Click on an event and select "Delete" from the info menu.</li>
            </ul>
        </div>
        <div class="event-info" id="event-info">
            <div class="event-title">Select an Event from the Calendar</div>
        </div>

    </div>
</div>

</body>
</html>
