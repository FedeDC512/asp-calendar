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
<link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&family=Stick&display=swap" rel="stylesheet">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <script>
    function hideEventInfo() {
        let infoItem = document.getElementById('event-info');
        infoItem.innerHTML = '<div class="event-title">Select an Event from the Calendar</div>'; // Svuota il contenuto del div delle informazioni dell'evento
    }

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

                let modal = document.getElementById('calendarModal');
                modal.style.display = "block";

                let endVisual = new Date(info.endStr); //tolgo un giorno (end - 1 giorno) perchè FullCalendar visualizza la fine nel giorno successivo (non so perchè)
                let giorno = endVisual.getDate();
                endVisual.setDate(giorno - 1);
                endVisual = endVisual.toISOString().split('T')[0];

                if(info.startStr != endVisual){
                    document.getElementById('endDateField').style.display = 'flex';
                    document.getElementById('multipleDays').checked = true;
                }

                document.getElementById('startDate').value = info.startStr;
                document.getElementById('endDate').value = endVisual;

                form.addEventListener('submit', function(event) { //funzione che aggunge al tasto Submit la funzione per inviare i dati
                    event.preventDefault();

                    var title = document.getElementById("title").value;
                    var car = document.getElementById("car").value;

                    var multipleDays;
                    if (document.getElementById("oneDay").checked) multipleDays = 0;
                    else if (document.getElementById("multipleDays").checked) multipleDays = 1;

                    var startDate = document.getElementById("startDate").value;
                    var endDate = document.getElementById("endDate").value;

                    var allDay;
                    if (document.getElementById("allDayYes").checked) allDay = 1;
                    else if (document.getElementById("allDayNo").checked) allDay = 0;

                    var startTime = document.getElementById("startTime").value;
                    var endTime = document.getElementById("endTime").value;

                    var creator = <%=Session("userID")%>;

                    let eventData;
                    if (allDay == 0){
                        if(multipleDays == 0) endDate = startDate;

                        startDate = startDate + 'T' + startTime;
                        endDate = endDate + 'T' + endTime;

                        eventData = {
                            title: title,
                            car: car,
                            start: startDate,
                            end: endDate,
                            creator: creator,
                            allDay: allDay,
                            multipleDays: multipleDays,
                        };

                        console.log(eventData);
                        calendar.addEvent(eventData);
                        saveEvent(title, startDate, endDate, car, creator, allDay); // Chiamata alla funzione ASP per salvare l'evento
                    } else if (allDay == 1 && multipleDays == 0){ //caso in cui selezioni più giorni dal calendario, ma con il modal metti in seguito un solo giorno
                        endDate = new Date(startDate); 
                        giorno = endDate.getDate();
                        endDate.setDate(giorno + 1);
                        endDate = endDate.toISOString().split('T')[0];
                        
                        eventData = {
                            title: title,
                            car: car,
                            start: startDate,
                            end: endDate,
                            creator: creator,
                            allDay: allDay,
                            multipleDays: multipleDays,
                        };
                        console.log(eventData);
                        calendar.addEvent(eventData);
                        saveEvent(title, startDate, endDate, car, creator, allDay); // Chiamata alla funzione ASP per salvare l'evento
                    
                    } /*else if (info.endStr == startDate && multipleDays == 1){ //caso in cui selezioni un giorno dal calendario, ma con il modal metti in seguito più giorni
                        endDate = new Date(startDate); 
                        giorno = endDate.getDate();
                        endDate.setDate(giorno + 1);
                        endDate = endDate.toISOString().split('T')[0];
                        
                        eventData = {
                            title: title,
                            car: car,
                            start: startDate,
                            end: endDate,
                            creator: creator,
                            allDay: allDay,
                            multipleDays: multipleDays,
                        };
                        console.log(eventData);
                        calendar.addEvent(eventData);
                        saveEvent(title, startDate, endDate, car, creator, allDay); // Chiamata alla funzione ASP per salvare l'evento
                    
                    } */else {
                        eventData = {
                            title: title,
                            car: car,
                            start: startDate,
                            end: info.endStr, //negli eventi allDay la data di fine è giusta
                            creator: creator,
                            allDay: allDay,
                            multipleDays: multipleDays,
                        };
                        
                        console.log(eventData);
                        calendar.addEvent(eventData);
                        saveEvent(title, startDate, info.endStr, car, creator, allDay); // Chiamata alla funzione ASP per salvare l'evento
                    }

                    modal.style.display = "none"; // Chiudi il modale dopo l'invio del modulo
                    });

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
            let dateWithTimeZone = new Date(event.startStr);
            let year = dateWithTimeZone.getFullYear();
            let month = ('0' + (dateWithTimeZone.getMonth() + 1)).slice(-2); // Aggiungi 1 al mese perché i mesi in JavaScript partono da zero
            let day = ('0' + dateWithTimeZone.getDate()).slice(-2);
            let hours = ('0' + dateWithTimeZone.getHours()).slice(-2);
            let minutes = ('0' + dateWithTimeZone.getMinutes()).slice(-2);
            let seconds = ('0' + dateWithTimeZone.getSeconds()).slice(-2);
            let startWithoutTimeZone = year + '-' + month + '-' + day + 'T' + hours + ':' + minutes + ':' + seconds;

            dateWithTimeZone = new Date(event.endStr);
            year = dateWithTimeZone.getFullYear();
            month = ('0' + (dateWithTimeZone.getMonth() + 1)).slice(-2);
            day = ('0' + dateWithTimeZone.getDate()).slice(-2);
            hours = ('0' + dateWithTimeZone.getHours()).slice(-2);
            minutes = ('0' + dateWithTimeZone.getMinutes()).slice(-2);
            seconds = ('0' + dateWithTimeZone.getSeconds()).slice(-2);
            let endWithoutTimeZone = year + '-' + month + '-' + day + 'T' + hours + ':' + minutes + ':' + seconds;

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
                        console.log(start + " - " + end);

                        html = `<div class="event-item-bar"><div class="event-title">Selected Event:</div>
                        <button class="bootstrap-btn-2" onclick="hideEventInfo()">Close</button></div>
                        <p><strong>Title:</strong> ${event.title} </p>
                        <p><strong>Car:</strong> ${event.extendedProps.car} </p>
                        <img class="car-calendar" src="cars/${event.extendedProps.car}.png" alt="${event.extendedProps.car}">
                        <p><strong>Created by:</strong> ${username} </p>
                        <p><strong>All Day:</strong> ${event.allDay} </p>`
                        if( end == start ) html += `<p><strong>Date:</strong> ${start} </p>`
                        else html += `<p><strong>Start:</strong> ${start} </p>
                            <p><strong>End:</strong> ${end} </p>`
                        html += `<button class="bootstrap-btn-1" onclick="deleteEvent( ${event.id} )">Delete</button>`;
                    } else {
                        console.log(event.start.toLocaleString() + " - " + event.end.toLocaleString());

                        html = `<div class="event-item-bar"><div class="event-title">Selected Event:</div>
                        <button class="bootstrap-btn-2" onclick="hideEventInfo()">Close</button></div>
                        <p><strong>Title:</strong> ${event.title} </p>
                        <p><strong>Car:</strong> ${event.extendedProps.car} </p>
                        <img class="car-calendar" src="cars/${event.extendedProps.car}.png" alt="${event.extendedProps.car}">
                        <p><strong>Created by:</strong> ${username} </p>
                        <p><strong>All Day:</strong> ${event.allDay} </p>
                        <p><strong>Start:</strong> ${event.start.toLocaleString()} </p>
                        <p><strong>End:</strong> ${event.end.toLocaleString()} </p>
                        <button class="bootstrap-btn-1" onclick="deleteEvent( ${event.id} )">Delete</button>`;
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
    <div class="btn-tutorial-container">
        <button id="openTutorialModal" class="bootstrap-btn-2">
            <div class="modal-title">
                <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" viewBox="0 0 24 24"><path fill="currentColor" d="M11 17h2v-6h-2zm1-8q.425 0 .713-.288T13 8t-.288-.712T12 7t-.712.288T11 8t.288.713T12 9m0 13q-2.075 0-3.9-.788t-3.175-2.137T2.788 15.9T2 12t.788-3.9t2.137-3.175T8.1 2.788T12 2t3.9.788t3.175 2.137T21.213 8.1T22 12t-.788 3.9t-2.137 3.175t-3.175 2.138T12 22m0-2q3.35 0 5.675-2.325T20 12t-2.325-5.675T12 4T6.325 6.325T4 12t2.325 5.675T12 20m0-8"/></svg>
                Calendar Tutorial
            </div>
        </button>
    </div>
        <div class="event-info" id="event-info">
            <div class="event-title">Select an Event from the Calendar</div>
        </div>

    </div>
</div>

<div id="myModal" class="modal">
    <div class="modal-top-margin">
        <div class="modal-content">
            <div class="modal-title">
                <div class="event-title">
                <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" viewBox="0 0 24 24"><path fill="currentColor" d="M11 17h2v-6h-2zm1-8q.425 0 .713-.288T13 8t-.288-.712T12 7t-.712.288T11 8t.288.713T12 9m0 13q-2.075 0-3.9-.788t-3.175-2.137T2.788 15.9T2 12t.788-3.9t2.137-3.175T8.1 2.788T12 2t3.9.788t3.175 2.137T21.213 8.1T22 12t-.788 3.9t-2.137 3.175t-3.175 2.138T12 22m0-2q3.35 0 5.675-2.325T20 12t-2.325-5.675T12 4T6.325 6.325T4 12t2.325 5.675T12 20m0-8"/></svg>
                Calendar Tutorial</div>
                <span class="close">&times;</span>
            </div>
            <p>Here are some basic instructions on how to use the calendar:</p>
            <ul>
                <li><strong>To Add Events:</strong> Click on a day to select it, or hold to select multiple days, then fill in the event details by entering start and end times and choosing one of <a href="cars.asp">our available cars</a>.</li>
                <li><strong>To Move Events:</strong> Click and drag an event to a new time or date. You can only move events created by you. Only admins can move any event.</li>
                <li><strong>To Delete Events:</strong> Click on an event and select "Delete" from the info menu. You can only delete events created by you. Only admins can delete any event.</li>
            </ul>
        </div>
    </div>
</div>

<div id="calendarModal" class="modal">
  <div class="modal-content">
  
    <div class="modal-title modal-form-title">
        <div class="event-title">Fill in the new event info:</div>
        <span class="close">&times;</span>
    </div>

    <form id="eventForm" class="form">
        <div class="small-form">
            <label for="title">Event Title <span>*</span></label>
            <input class="bootstrap-form" type="text" id="title" placeholder="Event Title" required>
        </div>
        <div class="small-form">
            <label for="car">Car Model <span>*</span></label>
            <input class="bootstrap-form" type="text" id="car" placeholder="Car Model" required>
        </div>
        <div>
            <label for="rentDuration">Rent Duration <span>*</span></label><br>
            <input type="radio" id="oneDay" name="rentDuration" value="oneDay" required checked>
            <label for="oneDay">One Day</label>
            <input type="radio" id="multipleDays" name="rentDuration" value="multipleDays" required>
            <label for="multipleDays">Multiple Days</label>
        </div>
        <div style="display: flex;gap: 1rem;">
            <div class="small-form">
                <label for="startDate">Start Date <span>*</span></label>
                <input class="bootstrap-form" type="date" id="startDate" required>
            </div>
            <div class="small-form" id="endDateField" style="display: none;">
                <label for="endDate">End Date</label>
                <input class="bootstrap-form" type="date" id="endDate">
            </div>
        </div>
        <div>
            <label for="allDay">Rent for Whole Day(s)? <span>*</span></label><br>
            <input type="radio" id="allDayYes" name="allDay" value="yes" required checked>
            <label for="allDayYes">Yes</label>
            <input type="radio" id="allDayNo" name="allDay" value="no" required>
            <label for="allDayNo">No</label>
        </div>

        <div id="timeFields" style="display: none;gap: 1rem;">
            <div class="small-form">
                <label for="startTime">Start Time</label>
                <input class="bootstrap-form" type="time" id="startTime" value="09:00">
            </div>
            <div class="small-form">
                <label for="endTime">End Time</label>
                <input class="bootstrap-form" type="time" id="endTime" value="18:00">
            </div>
        </div>

      <button type="submit" class="bootstrap-btn-1">Submit</button>
    </form>
  </div>
</div>

<script>
var modals = document.querySelectorAll('.modal');
var tutorialBtn = document.getElementById("openTutorialModal");
var form = document.getElementById("eventForm");

tutorialBtn.onclick = function() {
    var modal = document.getElementById('myModal');
    modal.style.display = "block";
}

modals.forEach(function(modal) {
  var closeButton = modal.querySelector('.close');

  closeButton.addEventListener('click', function() {
    modal.style.display = 'none';
  });

  window.addEventListener('click', function(event) {
    if (event.target === modal) {
      modal.style.display = 'none';
    }
  });
});

//Calendar Event Modal
document.getElementById('oneDay').addEventListener('change', function() {
    document.getElementById('endDateField').style.display = 'none';
});

document.getElementById('multipleDays').addEventListener('change', function() {
    document.getElementById('endDateField').style.display = 'flex';
});

document.getElementById("allDayYes").addEventListener("change", function() {
  document.getElementById("timeFields").style.display = "none";
    document.getElementById('startTime').value = '09:00';
    document.getElementById('endTime').value = '18:00';
});

document.getElementById("allDayNo").addEventListener("change", function() {
  document.getElementById("timeFields").style.display = "flex";
});

</script>

</body>
</html>
