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
                            hideEventInfo();
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

                $('#eventForm').on('submit', handleSubmit);
                
                function handleSubmit(event) { //funzione che aggunge al tasto Submit la funzione per inviare i dati
                    event.preventDefault();

                    var title = document.getElementById("title").value;
                    var car = $('input[name="car"]:checked').val();

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

                    if (multipleDays && startDate == endDate) { // Verifica se si stanno inserendo date illegali
                        alert('If multiple days is selected, the start date and end date must be different.');
                        event.preventDefault();
                        return;
                    } else if (multipleDays && startDate > endDate) {
                        alert('The end date cannot be before the start date.');
                        event.preventDefault();
                        return;
                    }

                    let eventData;
                    if (allDay == 0){ // Caso in cui selezioni solo un giorno con orari o più giorni con orari, o selezioni più giorni dal calendario, ma con il modal metti in seguito un solo giorno con orari, o selezioni più giorni con orari e poi metti più giorni diversi con orari
                        console.log("allDay == 0");
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
                        
                    } else if (allDay == 1 && multipleDays == 0){ // Caso in cui: selezioni solo un giorno allDay, o selezioni più giorni dal calendario, ma con il modal metti in seguito un solo giorno allDay
                        console.log("allDay == 1 && multipleDays == 0");
                        console.log("allDay:" + allDay +"multipleDays:" + multipleDays);
                        console.log(startDate);
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
                        saveEvent(title, startDate, endDate, car, creator, allDay);
                    
                    } else { // Caso in cui selezioni più giorni allDay, o selezioni più giorni o un giorno dal calendario, ma con il modal metti più giorni allDay ma con date diverse
                        console.log("else");
                        console.log("info.endStr:" + info.endStr +" endDate:" + endDate);

                        endDate = new Date(endDate); 
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
                        saveEvent(title, startDate, endDate, car, creator, allDay);
                    }

                    resetModal();
                    modal.style.display = "none"; // Chiudi il modale dopo l'invio del modulo
                };

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

        $(calendarEl).data('fullCalendarObj',calendar); // Save the calendar pointer in data attached to Dom object

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

                        html = `<div class="event-item-bar"><div class="car-title-text">Selected Event:</div>
                        <button class="bootstrap-btn-2" onclick="hideEventInfo()">Close</button></div>
                        <div class="car-title-text" style="text-align: center;"><strong>Title:</strong> ${event.title} </div>
                        <div class="car-list-img-container">
                            <img class="car-calendar" src="cars/${event.extendedProps.car}.png" alt="${event.extendedProps.car}">
                        </div>
                        <ul class="car-info" style="color: black;">
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 24 24"><path fill="currentColor" d="m5 11l1.5-4.5h11L19 11m-1.5 5a1.5 1.5 0 0 1-1.5-1.5a1.5 1.5 0 0 1 1.5-1.5a1.5 1.5 0 0 1 1.5 1.5a1.5 1.5 0 0 1-1.5 1.5m-11 0A1.5 1.5 0 0 1 5 14.5A1.5 1.5 0 0 1 6.5 13A1.5 1.5 0 0 1 8 14.5A1.5 1.5 0 0 1 6.5 16M18.92 6c-.2-.58-.76-1-1.42-1h-11c-.66 0-1.22.42-1.42 1L3 12v8a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-1h12v1a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-8z"/></svg>
                                <div><strong>Car:</strong> ${event.extendedProps.car} </div>
                            </li>
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="2.5"><path stroke-linejoin="round" d="M4 18a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/><circle cx="12" cy="7" r="3"/></g></svg>
                                <div><strong>Created by:</strong> ${username} </div>
                            </li>
                        </ul>
                        <ul class="car-info" style="color: black;">
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 20 20"><path fill="currentColor" d="M17 5.5A2.5 2.5 0 0 0 14.5 3h-9A2.5 2.5 0 0 0 3 5.5v9A2.5 2.5 0 0 0 5.5 17h4.1a5.5 5.5 0 0 1-.393-1H8v-3h1.207q.149-.524.393-1H8V8h4v1.6a5.5 5.5 0 0 1 1-.393V8h3v1.207q.524.149 1 .393zm-13 9V13h3v3H5.5l-.144-.007A1.5 1.5 0 0 1 4 14.5M12 4v3H8V4zm1 0h1.5l.145.007A1.5 1.5 0 0 1 16 5.5V7h-3zM7 4v3H4V5.5l.007-.144A1.5 1.5 0 0 1 5.5 4zm0 4v4H4V8zm12 6.5a4.5 4.5 0 1 1-9 0a4.5 4.5 0 0 1 9 0m-4-2a.5.5 0 0 0-1 0V14h-1.5a.5.5 0 0 0 0 1H14v1.5a.5.5 0 0 0 1 0V15h1.5a.5.5 0 0 0 0-1H15z"/></svg>
                                <div><strong>All Day:</strong> ${event.allDay} </div>
                            </li>
                            <li></li>`
                        if( end == start ) html += `
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 100 100"><path fill="currentColor" d="M21 32C9.459 32 0 41.43 0 52.94c0 4.46 1.424 8.605 3.835 12.012l14.603 25.244c2.045 2.672 3.405 2.165 5.106-.14l16.106-27.41c.325-.59.58-1.216.803-1.856A20.668 20.668 0 0 0 42 52.94C42 41.43 32.544 32 21 32m0 9.812c6.216 0 11.16 4.931 11.16 11.129c0 6.198-4.944 11.127-11.16 11.127c-6.215 0-11.16-4.93-11.16-11.127c0-6.198 4.945-11.129 11.16-11.129M87.75 0C81.018 0 75.5 5.501 75.5 12.216c0 2.601.83 5.019 2.237 7.006l8.519 14.726c1.193 1.558 1.986 1.262 2.978-.082l9.395-15.99c.19-.343.339-.708.468-1.082a12.05 12.05 0 0 0 .903-4.578C100 5.5 94.484 0 87.75 0m0 5.724c3.626 0 6.51 2.876 6.51 6.492c0 3.615-2.884 6.49-6.51 6.49c-3.625 0-6.51-2.875-6.51-6.49c0-3.616 2.885-6.492 6.51-6.492"/><path fill="currentColor" fill-rule="evenodd" d="M88.209 37.412c-2.247.05-4.5.145-6.757.312l.348 5.532a126.32 126.32 0 0 1 6.513-.303zm-11.975.82c-3.47.431-6.97 1.045-10.43 2.032l1.303 5.361c3.144-.896 6.402-1.475 9.711-1.886zM60.623 42.12a24.52 24.52 0 0 0-3.004 1.583l-.004.005l-.006.002c-1.375.866-2.824 1.965-4.007 3.562c-.857 1.157-1.558 2.62-1.722 4.35l5.095.565c.038-.406.246-.942.62-1.446h.002v-.002c.603-.816 1.507-1.557 2.582-2.235l.004-.002a19.64 19.64 0 0 1 2.388-1.256zM58 54.655l-3.303 4.235c.783.716 1.604 1.266 2.397 1.726l.01.005l.01.006c2.632 1.497 5.346 2.342 7.862 3.144l1.446-5.318c-2.515-.802-4.886-1.576-6.918-2.73c-.582-.338-1.092-.691-1.504-1.068m13.335 5.294l-1.412 5.327l.668.208l.82.262c2.714.883 5.314 1.826 7.638 3.131l2.358-4.92c-2.81-1.579-5.727-2.611-8.538-3.525l-.008-.002l-.842-.269zm14.867 7.7l-3.623 3.92c.856.927 1.497 2.042 1.809 3.194l.002.006l.002.009c.372 1.345.373 2.927.082 4.525l5.024 1.072c.41-2.256.476-4.733-.198-7.178c-.587-2.162-1.707-4.04-3.098-5.548M82.72 82.643a11.84 11.84 0 0 1-1.826 1.572h-.002c-1.8 1.266-3.888 2.22-6.106 3.04l1.654 5.244c2.426-.897 4.917-1.997 7.245-3.635l.006-.005l.003-.002a16.95 16.95 0 0 0 2.639-2.287zm-12.64 6.089c-3.213.864-6.497 1.522-9.821 2.08l.784 5.479c3.421-.575 6.856-1.262 10.27-2.18zm-14.822 2.836c-3.346.457-6.71.83-10.084 1.148l.442 5.522c3.426-.322 6.858-.701 10.285-1.17zm-15.155 1.583c-3.381.268-6.77.486-10.162.67l.256 5.536c3.425-.185 6.853-.406 10.28-.678zm-15.259.92c-2.033.095-4.071.173-6.114.245l.168 5.541a560.1 560.1 0 0 0 6.166-.246z" color="currentColor"/></svg>
                                <div><strong>Date:</strong> ${start} </div>
                            </li>`
                        else html += `
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 100 100"><path fill="currentColor" d="M21 32C9.459 32 0 41.43 0 52.94c0 4.46 1.424 8.605 3.835 12.012l14.603 25.244c2.045 2.672 3.405 2.165 5.106-.14l16.106-27.41c.325-.59.58-1.216.803-1.856A20.668 20.668 0 0 0 42 52.94C42 41.43 32.544 32 21 32m0 9.812c6.216 0 11.16 4.931 11.16 11.129c0 6.198-4.944 11.127-11.16 11.127c-6.215 0-11.16-4.93-11.16-11.127c0-6.198 4.945-11.129 11.16-11.129"/><path fill="currentColor" fill-rule="evenodd" d="M88.209 37.412c-2.247.05-4.5.145-6.757.312l.348 5.532a126.32 126.32 0 0 1 6.513-.303zm-11.975.82c-3.47.431-6.97 1.045-10.43 2.032l1.303 5.361c3.144-.896 6.402-1.475 9.711-1.886zM60.623 42.12a24.52 24.52 0 0 0-3.004 1.583l-.004.005l-.006.002c-1.375.866-2.824 1.965-4.007 3.562c-.857 1.157-1.558 2.62-1.722 4.35l5.095.565c.038-.406.246-.942.62-1.446h.002v-.002c.603-.816 1.507-1.557 2.582-2.235l.004-.002a19.64 19.64 0 0 1 2.388-1.256zM58 54.655l-3.303 4.235c.783.716 1.604 1.266 2.397 1.726l.01.005l.01.006c2.632 1.497 5.346 2.342 7.862 3.144l1.446-5.318c-2.515-.802-4.886-1.576-6.918-2.73c-.582-.338-1.092-.691-1.504-1.068m13.335 5.294l-1.412 5.327l.668.208l.82.262c2.714.883 5.314 1.826 7.638 3.131l2.358-4.92c-2.81-1.579-5.727-2.611-8.538-3.525l-.008-.002l-.842-.269zm14.867 7.7l-3.623 3.92c.856.927 1.497 2.042 1.809 3.194l.002.006l.002.009c.372 1.345.373 2.927.082 4.525l5.024 1.072c.41-2.256.476-4.733-.198-7.178c-.587-2.162-1.707-4.04-3.098-5.548M82.72 82.643a11.84 11.84 0 0 1-1.826 1.572h-.002c-1.8 1.266-3.888 2.22-6.106 3.04l1.654 5.244c2.426-.897 4.917-1.997 7.245-3.635l.006-.005l.003-.002a16.95 16.95 0 0 0 2.639-2.287zm-12.64 6.089c-3.213.864-6.497 1.522-9.821 2.08l.784 5.479c3.421-.575 6.856-1.262 10.27-2.18zm-14.822 2.836c-3.346.457-6.71.83-10.084 1.148l.442 5.522c3.426-.322 6.858-.701 10.285-1.17zm-15.155 1.583c-3.381.268-6.77.486-10.162.67l.256 5.536c3.425-.185 6.853-.406 10.28-.678zm-15.259.92c-2.033.095-4.071.173-6.114.245l.168 5.541a560.1 560.1 0 0 0 6.166-.246z" color="currentColor"/></svg>
                                <div><strong>Start Date:</strong> ${start} </div>
                            </li>
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 100 100"><path fill="currentColor" d="M87.75 0C81.018 0 75.5 5.501 75.5 12.216c0 2.601.83 5.019 2.237 7.006l8.519 14.726c1.193 1.558 1.986 1.262 2.978-.082l9.395-15.99c.19-.343.339-.708.468-1.082a12.05 12.05 0 0 0 .903-4.578C100 5.5 94.484 0 87.75 0m0 5.724c3.626 0 6.51 2.876 6.51 6.492c0 3.615-2.884 6.49-6.51 6.49c-3.625 0-6.51-2.875-6.51-6.49c0-3.616 2.885-6.492 6.51-6.492"/><path fill="currentColor" fill-rule="evenodd" d="M88.209 37.412c-2.247.05-4.5.145-6.757.312l.348 5.532a126.32 126.32 0 0 1 6.513-.303zm-11.975.82c-3.47.431-6.97 1.045-10.43 2.032l1.303 5.361c3.144-.896 6.402-1.475 9.711-1.886zM60.623 42.12a24.52 24.52 0 0 0-3.004 1.583l-.004.005l-.006.002c-1.375.866-2.824 1.965-4.007 3.562c-.857 1.157-1.558 2.62-1.722 4.35l5.095.565c.038-.406.246-.942.62-1.446h.002v-.002c.603-.816 1.507-1.557 2.582-2.235l.004-.002a19.64 19.64 0 0 1 2.388-1.256zM58 54.655l-3.303 4.235c.783.716 1.604 1.266 2.397 1.726l.01.005l.01.006c2.632 1.497 5.346 2.342 7.862 3.144l1.446-5.318c-2.515-.802-4.886-1.576-6.918-2.73c-.582-.338-1.092-.691-1.504-1.068m13.335 5.294l-1.412 5.327l.668.208l.82.262c2.714.883 5.314 1.826 7.638 3.131l2.358-4.92c-2.81-1.579-5.727-2.611-8.538-3.525l-.008-.002l-.842-.269zm14.867 7.7l-3.623 3.92c.856.927 1.497 2.042 1.809 3.194l.002.006l.002.009c.372 1.345.373 2.927.082 4.525l5.024 1.072c.41-2.256.476-4.733-.198-7.178c-.587-2.162-1.707-4.04-3.098-5.548M82.72 82.643a11.84 11.84 0 0 1-1.826 1.572h-.002c-1.8 1.266-3.888 2.22-6.106 3.04l1.654 5.244c2.426-.897 4.917-1.997 7.245-3.635l.006-.005l.003-.002a16.95 16.95 0 0 0 2.639-2.287zm-12.64 6.089c-3.213.864-6.497 1.522-9.821 2.08l.784 5.479c3.421-.575 6.856-1.262 10.27-2.18zm-14.822 2.836c-3.346.457-6.71.83-10.084 1.148l.442 5.522c3.426-.322 6.858-.701 10.285-1.17zm-15.155 1.583c-3.381.268-6.77.486-10.162.67l.256 5.536c3.425-.185 6.853-.406 10.28-.678zm-15.259.92c-2.033.095-4.071.173-6.114.245l.168 5.541a560.1 560.1 0 0 0 6.166-.246z" color="currentColor"/></svg>
                                <div><strong>End Date:</strong> ${end} </div>
                            </li>`
                        html += `</ul>
                        <div><button class="bootstrap-btn-1" onclick="deleteEvent( ${event.id} )">Delete</button></div>`;
                    } else {
                        console.log(event.start.toLocaleString() + " - " + event.end.toLocaleString());

                        html = `<div class="event-item-bar"><div class="car-title-text">Selected Event:</div>
                        <button class="bootstrap-btn-2" onclick="hideEventInfo()">Close</button></div>
                        <div class="car-title-text" style="text-align: center;"><strong>Title:</strong> ${event.title} </div>
                        <div class="car-list-img-container">
                            <img class="car-calendar" src="cars/${event.extendedProps.car}.png" alt="${event.extendedProps.car}">
                        </div><ul class="car-info" style="color: black;">
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 24 24"><path fill="currentColor" d="m5 11l1.5-4.5h11L19 11m-1.5 5a1.5 1.5 0 0 1-1.5-1.5a1.5 1.5 0 0 1 1.5-1.5a1.5 1.5 0 0 1 1.5 1.5a1.5 1.5 0 0 1-1.5 1.5m-11 0A1.5 1.5 0 0 1 5 14.5A1.5 1.5 0 0 1 6.5 13A1.5 1.5 0 0 1 8 14.5A1.5 1.5 0 0 1 6.5 16M18.92 6c-.2-.58-.76-1-1.42-1h-11c-.66 0-1.22.42-1.42 1L3 12v8a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-1h12v1a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-8z"/></svg>
                                <div><strong>Car:</strong> ${event.extendedProps.car} </div>
                            </li>
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="2.5"><path stroke-linejoin="round" d="M4 18a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/><circle cx="12" cy="7" r="3"/></g></svg>
                                <div><strong>Created by:</strong> ${username} </div>
                            </li>
                        </ul>
                        <ul class="car-info" style="color: black;">
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 20 20"><path fill="currentColor" d="M17 5.5A2.5 2.5 0 0 0 14.5 3h-9A2.5 2.5 0 0 0 3 5.5v9A2.5 2.5 0 0 0 5.5 17h4.1a5.5 5.5 0 0 1-.393-1H8v-3h1.207q.149-.524.393-1H8V8h4v1.6a5.5 5.5 0 0 1 1-.393V8h3v1.207q.524.149 1 .393zm-13 9V13h3v3H5.5l-.144-.007A1.5 1.5 0 0 1 4 14.5M12 4v3H8V4zm1 0h1.5l.145.007A1.5 1.5 0 0 1 16 5.5V7h-3zM7 4v3H4V5.5l.007-.144A1.5 1.5 0 0 1 5.5 4zm0 4v4H4V8zm12 6.5a4.5 4.5 0 1 1-9 0a4.5 4.5 0 0 1 9 0m-4-2a.5.5 0 0 0-1 0V14h-1.5a.5.5 0 0 0 0 1H14v1.5a.5.5 0 0 0 1 0V15h1.5a.5.5 0 0 0 0-1H15z"/></svg>
                                <div><strong>All Day:</strong> ${event.allDay} </div>
                            </li>
                            <li></li>
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 100 100"><path fill="currentColor" d="M21 32C9.459 32 0 41.43 0 52.94c0 4.46 1.424 8.605 3.835 12.012l14.603 25.244c2.045 2.672 3.405 2.165 5.106-.14l16.106-27.41c.325-.59.58-1.216.803-1.856A20.668 20.668 0 0 0 42 52.94C42 41.43 32.544 32 21 32m0 9.812c6.216 0 11.16 4.931 11.16 11.129c0 6.198-4.944 11.127-11.16 11.127c-6.215 0-11.16-4.93-11.16-11.127c0-6.198 4.945-11.129 11.16-11.129"/><path fill="currentColor" fill-rule="evenodd" d="M88.209 37.412c-2.247.05-4.5.145-6.757.312l.348 5.532a126.32 126.32 0 0 1 6.513-.303zm-11.975.82c-3.47.431-6.97 1.045-10.43 2.032l1.303 5.361c3.144-.896 6.402-1.475 9.711-1.886zM60.623 42.12a24.52 24.52 0 0 0-3.004 1.583l-.004.005l-.006.002c-1.375.866-2.824 1.965-4.007 3.562c-.857 1.157-1.558 2.62-1.722 4.35l5.095.565c.038-.406.246-.942.62-1.446h.002v-.002c.603-.816 1.507-1.557 2.582-2.235l.004-.002a19.64 19.64 0 0 1 2.388-1.256zM58 54.655l-3.303 4.235c.783.716 1.604 1.266 2.397 1.726l.01.005l.01.006c2.632 1.497 5.346 2.342 7.862 3.144l1.446-5.318c-2.515-.802-4.886-1.576-6.918-2.73c-.582-.338-1.092-.691-1.504-1.068m13.335 5.294l-1.412 5.327l.668.208l.82.262c2.714.883 5.314 1.826 7.638 3.131l2.358-4.92c-2.81-1.579-5.727-2.611-8.538-3.525l-.008-.002l-.842-.269zm14.867 7.7l-3.623 3.92c.856.927 1.497 2.042 1.809 3.194l.002.006l.002.009c.372 1.345.373 2.927.082 4.525l5.024 1.072c.41-2.256.476-4.733-.198-7.178c-.587-2.162-1.707-4.04-3.098-5.548M82.72 82.643a11.84 11.84 0 0 1-1.826 1.572h-.002c-1.8 1.266-3.888 2.22-6.106 3.04l1.654 5.244c2.426-.897 4.917-1.997 7.245-3.635l.006-.005l.003-.002a16.95 16.95 0 0 0 2.639-2.287zm-12.64 6.089c-3.213.864-6.497 1.522-9.821 2.08l.784 5.479c3.421-.575 6.856-1.262 10.27-2.18zm-14.822 2.836c-3.346.457-6.71.83-10.084 1.148l.442 5.522c3.426-.322 6.858-.701 10.285-1.17zm-15.155 1.583c-3.381.268-6.77.486-10.162.67l.256 5.536c3.425-.185 6.853-.406 10.28-.678zm-15.259.92c-2.033.095-4.071.173-6.114.245l.168 5.541a560.1 560.1 0 0 0 6.166-.246z" color="currentColor"/></svg>
                                <div><strong>Start Date:</strong> ${event.start.toLocaleDateString()} </div>
                            </li>
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.5em" height="1.5em" viewBox="0 0 100 100"><path fill="currentColor" d="M87.75 0C81.018 0 75.5 5.501 75.5 12.216c0 2.601.83 5.019 2.237 7.006l8.519 14.726c1.193 1.558 1.986 1.262 2.978-.082l9.395-15.99c.19-.343.339-.708.468-1.082a12.05 12.05 0 0 0 .903-4.578C100 5.5 94.484 0 87.75 0m0 5.724c3.626 0 6.51 2.876 6.51 6.492c0 3.615-2.884 6.49-6.51 6.49c-3.625 0-6.51-2.875-6.51-6.49c0-3.616 2.885-6.492 6.51-6.492"/><path fill="currentColor" fill-rule="evenodd" d="M88.209 37.412c-2.247.05-4.5.145-6.757.312l.348 5.532a126.32 126.32 0 0 1 6.513-.303zm-11.975.82c-3.47.431-6.97 1.045-10.43 2.032l1.303 5.361c3.144-.896 6.402-1.475 9.711-1.886zM60.623 42.12a24.52 24.52 0 0 0-3.004 1.583l-.004.005l-.006.002c-1.375.866-2.824 1.965-4.007 3.562c-.857 1.157-1.558 2.62-1.722 4.35l5.095.565c.038-.406.246-.942.62-1.446h.002v-.002c.603-.816 1.507-1.557 2.582-2.235l.004-.002a19.64 19.64 0 0 1 2.388-1.256zM58 54.655l-3.303 4.235c.783.716 1.604 1.266 2.397 1.726l.01.005l.01.006c2.632 1.497 5.346 2.342 7.862 3.144l1.446-5.318c-2.515-.802-4.886-1.576-6.918-2.73c-.582-.338-1.092-.691-1.504-1.068m13.335 5.294l-1.412 5.327l.668.208l.82.262c2.714.883 5.314 1.826 7.638 3.131l2.358-4.92c-2.81-1.579-5.727-2.611-8.538-3.525l-.008-.002l-.842-.269zm14.867 7.7l-3.623 3.92c.856.927 1.497 2.042 1.809 3.194l.002.006l.002.009c.372 1.345.373 2.927.082 4.525l5.024 1.072c.41-2.256.476-4.733-.198-7.178c-.587-2.162-1.707-4.04-3.098-5.548M82.72 82.643a11.84 11.84 0 0 1-1.826 1.572h-.002c-1.8 1.266-3.888 2.22-6.106 3.04l1.654 5.244c2.426-.897 4.917-1.997 7.245-3.635l.006-.005l.003-.002a16.95 16.95 0 0 0 2.639-2.287zm-12.64 6.089c-3.213.864-6.497 1.522-9.821 2.08l.784 5.479c3.421-.575 6.856-1.262 10.27-2.18zm-14.822 2.836c-3.346.457-6.71.83-10.084 1.148l.442 5.522c3.426-.322 6.858-.701 10.285-1.17zm-15.155 1.583c-3.381.268-6.77.486-10.162.67l.256 5.536c3.425-.185 6.853-.406 10.28-.678zm-15.259.92c-2.033.095-4.071.173-6.114.245l.168 5.541a560.1 560.1 0 0 0 6.166-.246z" color="currentColor"/></svg>
                                <div><strong>End Date:</strong> ${event.end.toLocaleDateString()} </div>
                            </li>
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.29em" height="1.5em" viewBox="0 0 1536 1792"><path fill="currentColor" d="M1408 128q0 261-106.5 461.5T1035 896q160 106 266.5 306.5T1408 1664h96q14 0 23 9t9 23v64q0 14-9 23t-23 9H32q-14 0-23-9t-9-23v-64q0-14 9-23t23-9h96q0-261 106.5-461.5T501 896Q341 790 234.5 589.5T128 128H32q-14 0-23-9T0 96V32Q0 18 9 9t23-9h1472q14 0 23 9t9 23v64q0 14-9 23t-23 9zm-128 0H256q0 66 9 128h1006q9-61 9-128m0 1536q0-130-34-249.5t-90.5-208t-126.5-152T883 960H653q-76 31-146 94.5t-126.5 152t-90.5 208t-34 249.5z"/></svg>
                                <div><strong>Start Time:</strong> ${String(event.start.getHours()).padStart(2, "0")}:${String(event.start.getMinutes()).padStart(2, "0")} </div>
                            </li>
                            <li class="car-feature">
                                <svg class="rhino-red" xmlns="http://www.w3.org/2000/svg" width="1.29em" height="1.5em" viewBox="0 0 1536 1792"><path fill="currentColor" d="M1408 128q0 261-106.5 461.5T1035 896q160 106 266.5 306.5T1408 1664h96q14 0 23 9t9 23v64q0 14-9 23t-23 9H32q-14 0-23-9t-9-23v-64q0-14 9-23t23-9h96q0-261 106.5-461.5T501 896Q341 790 234.5 589.5T128 128H32q-14 0-23-9T0 96V32Q0 18 9 9t23-9h1472q14 0 23 9t9 23v64q0 14-9 23t-23 9zM874 836q77-29 149-92.5T1152.5 591t92.5-210t35-253H256q0 132 35 253t92.5 210T513 743.5T662 836q19 7 30.5 23.5T704 896t-11.5 36.5T662 956q-137 51-244 196h700q-107-145-244-196q-19-7-30.5-23.5T832 896t11.5-36.5T874 836"/></svg>
                                <div><strong>End Time:</strong> ${String(event.end.getHours()).padStart(2, "0")}:${String(event.end.getMinutes()).padStart(2, "0")} </div>
                            </li>
                        </ul>
                        <div><button class="bootstrap-btn-1" onclick="deleteEvent( ${event.id} )">Delete</button></div>`;
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
    <div class="modal-top-margin"></div>
    <div class="modal-content">
        <div class="modal-title">
            <div class="event-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" viewBox="0 0 24 24"><path fill="currentColor" d="M11 17h2v-6h-2zm1-8q.425 0 .713-.288T13 8t-.288-.712T12 7t-.712.288T11 8t.288.713T12 9m0 13q-2.075 0-3.9-.788t-3.175-2.137T2.788 15.9T2 12t.788-3.9t2.137-3.175T8.1 2.788T12 2t3.9.788t3.175 2.137T21.213 8.1T22 12t-.788 3.9t-2.137 3.175t-3.175 2.138T12 22m0-2q3.35 0 5.675-2.325T20 12t-2.325-5.675T12 4T6.325 6.325T4 12t2.325 5.675T12 20m0-8"/></svg>
            Calendar Tutorial</div>
            <span class="close">&times;</span>
        </div>
        <p>Here are some basic instructions on how to use the calendar:</p>
        <ul>
            <li><strong>To Add Events:</strong> Click on a day to select it, or hold to select multiple days. After selecting, you can choose the event name and <a href="cars.asp">car model</a>, specify the rental duration (start and end dates can be adjusted if needed), and decide whether you are renting for a full day or specific hours. You can set the start and end times accordingly.</li>
            <li><strong>To Move Events:</strong> Click and drag an event to a new time or date. You can only move events created by you. Only admins can move any event.</li>
            <li><strong>To Delete Events:</strong> Click on an event and select "Delete" from the info menu. You can only delete events created by you. Only admins can delete any event.</li>
        </ul>
        <br>
        <div class="modal-title">
            <div class="event-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" viewBox="0 0 24 24"><path fill="currentColor" d="M11 17h2v-6h-2zm1-8q.425 0 .713-.288T13 8t-.288-.712T12 7t-.712.288T11 8t.288.713T12 9m0 13q-2.075 0-3.9-.788t-3.175-2.137T2.788 15.9T2 12t.788-3.9t2.137-3.175T8.1 2.788T12 2t3.9.788t3.175 2.137T21.213 8.1T22 12t-.788 3.9t-2.137 3.175t-3.175 2.138T12 22m0-2q3.35 0 5.675-2.325T20 12t-2.325-5.675T12 4T6.325 6.325T4 12t2.325 5.675T12 20m0-8"/></svg>
            Mobile Usage</div>
        </div>
        <p> To add an event on a mobile device, press and hold on the day or drag across multiple days to select them. Once selected, you can enter all the event info.</p>
    </div>
    
</div>

<div id="calendarModal" class="modal">
    <div class="modal-top-margin"></div>
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
            <div id="car-options" class="form-car-container"></div>
            <div class="modal-btn-container">
                <button type="button" id="load-more-btn" class="bootstrap-btn-2">Load More</button>
            </div>
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
    resetModal();
    modal.style.display = 'none';
  });

  window.addEventListener('click', function(event) {
    if (event.target === modal) {
        resetModal();
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

function resetModal() {//definita qui perchè non accessibile da fuori, ridefinita in seguito per lo stesso motivo
    // Reset tutti i campi del form
    document.getElementById("eventForm").reset();
    // Nascondi il campo "End Date" e "Time Fields" se sono stati visualizzati
    document.getElementById('endDateField').style.display = 'none';
    document.getElementById('timeFields').style.display = 'none';
    // Ripristina i valori predefiniti
    document.getElementById('oneDay').checked = true;
    document.getElementById('allDayYes').checked = true;
    document.getElementById('startTime').value = '09:00';
    document.getElementById('endTime').value = '18:00';
    // Nascondi il modal
    document.getElementById('calendarModal').style.display = 'none';
    $('#eventForm').off();
    //document.getElementById('eventForm').removeEventListener('submit', handleSubmit);
}


$(document).ready(function() {
    let loading = false;
    let allCarsLoaded = false;
    let currentCarPage = 0;
    let totalCars;
    $.ajax({
        url: "get_cars.asp",
        type: "GET",
        dataType: "json",
        data: { numCarsToLoad: 1000, currentCarPage: 0 }, // Load a large number to get total count
        success: function(data) {
            totalCars = data.length;
            console.log("Total number of cars: " + totalCars);
        },
        error: function(xhr, status, error) {
            console.error("Error loading car data: " + status + " - " + error);
        }
    });

    function loadCars() {
        if (!loading && !allCarsLoaded) {
            loading = true;
            numCarsToLoad = 5;
            $.ajax({
                url: "get_cars.asp",
                type: "GET",
                dataType: "json",
                data: { numCarsToLoad: numCarsToLoad, currentCarPage: currentCarPage },
                success: function(data) {
                    if (data.length > 0) {
                        $.each(data, function(key, value) {
                            $('#car-options').append(`
                                <div class="form-car-card">
                                    <label for="car${currentCarPage * numCarsToLoad + key}">
                                        <div class="form-car-img-container">
                                            <img class="form-car-img" src="cars/${value.name}.png" alt="${value.name}">
                                        </div>
                                    </label>
                                    <div class="form-car-name-container">
                                        <input type="radio" id="car${currentCarPage * numCarsToLoad + key}" name="car" value="${value.name}" required>
                                        <label for="car${currentCarPage * numCarsToLoad + key}">${value.name}</div></label>
                                    </div>
                                </div>
                            `);
                        });
                        currentCarPage++;

                        if (currentCarPage == totalCars/numCarsToLoad){
                            $('#load-more-btn').hide();
                            allCarsLoaded = true;
                        }
                    } else {
                        console.log("No car loaded");
                    }
                },
                error: function(xhr, status, error) {
                    console.error("Error loading car data: " + status + " - " + error);
                },
                complete: function() {
                    loading = false;
                }
            });
        }
    }

    // Carica i dati delle macchine inizialmente
    loadCars();

    // Carica ulteriori dati delle macchine alla pressione del tasto "Load More"
    $('#load-more-btn').on('click', function() {
        loadCars();
    });
});
</script>

</body>
</html>
