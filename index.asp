<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ruby Rhino Rentals</title>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js'></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <link rel="stylesheet" href="styles.css" type="text/css" >
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Stick&display=swap" rel="stylesheet">


    <script>
    function hideEventInfo() {
        var infoItem = document.getElementById('event-info');
        infoItem.innerHTML = ''; // Svuota il contenuto del div delle informazioni dell'evento
    }

    function deleteEvent(id) {
        if (confirm("Do you want to delete this event?")) {
            $.ajax({
                url: 'delete_event.asp',
                type: 'POST',
                data: { 
                    id: id
                },
                success: function(response) {
                    console.log('Event deleted');
                    //event.remove(); // Rimuove l'evento dal calendario
                    /*var calendarEl = document.getElementById('calendar');
                    var calendar = calendarEl.getApi();
                    var event = calendar.getEventById(id);
                    if (event) {
                        event.remove(); // Rimuove l'evento dal calendario
                    }*/
                },
                error: function(xhr, status, error) {
                    console.error('Error deleting event:', error);
                }
            });
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        var calendarEl = document.getElementById('calendar');

        var calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay'
            },
            editable: true,
            selectable: true,
            select: function(info) {
                var title = prompt('Insert event title:');
                if (title) {
                    var car = prompt('Enter the Car model:');
                    var startTime = prompt('Enter the start time (HH:mm):');
                    var endTime = prompt('Enter the end time (HH:mm):');
                    if (startTime && endTime) {
                        var start = info.startStr.split('T')[0] + 'T' + startTime;
                        var end = info.endStr.split('T')[0] + 'T' + endTime;
                        var eventData = {
                            title: title,
                            start: start,
                            end: end,
                            car: car,
                        };
                        console.log(eventData);
                        calendar.addEvent(eventData);
                        saveEvent(title, start, end, car); // Chiamata alla funzione ASP per salvare l'evento
                    } else {
                        alert('You must enter both times.'); //TODO: da mettere AllDay se non si mettono gli orari
                    }
                }
            },
            eventClick: function(info) {
                showEventInfo(info.event);
            },
            /*eventClick: function(info) {
                if (confirm("Do you want to delete this event?")) {
                    deleteEvent(info.event);
                }
            },*/
            eventDrop: function(info) {
                updateEvent(info.event);
            }
        });

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

        function saveEvent(title, start, end, car) {
            // Chiamata AJAX a uno script ASP per salvare l'evento nel database o in un file
            $.ajax({
                url: 'save_event.asp',
                type: 'POST',
                data: { title: title, start: start, end: end, car: car },
                success: function(response) {
                    console.log('Event saved');
                },
                error: function(xhr, status, error) {
                    console.error('Error saving event:', error);
                }
            });
        }

        function updateEvent(event) {
            $.ajax({
                url: 'update_event.asp',
                type: 'POST',
                data: { 
                    id: event.id,
                    start: event.startStr,
                    end: event.endStr
                },
                success: function(response) {
                    console.log('Event updated');
                },
                error: function(xhr, status, error) {
                    console.error('Error updating event:', error);
                }
            });
        }

        function showEventInfo(event) {
            console.log(event.id);
            var infoItem = document.getElementById('event-info');
            var html = '<p><strong>Title:</strong> ' + event.title + '</p>';
            html += '<p><strong>Car:</strong> ' + event.extendedProps.car + '</p>';
            html += '<p><strong>Start:</strong> ' + event.start.toLocaleString() + '</p>';
            html += '<p><strong>End:</strong> ' + event.end.toLocaleString() + '</p>';
            html += '<button onclick="deleteEvent(' + event.id + ')">Delete</button>'; //TODO: non funziona
            html += '<button onclick="hideEventInfo()">Close</button>';
            infoItem.innerHTML = html;
        }
    });
    </script>
</head>
<body>
<div class="header">
    <div class="h-logoname">
        <a href=""><svg class="rhino h-button" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 512 512"><path fill="currentColor" d="M450.125 32.734c-9.41 47.727-17.293 105.183-30.922 156.774c-8.34 31.574-18.838 60.978-33.72 84.795c-12.89 20.63-29.425 37.144-50.47 46.172c12.023 25.86 43.083 47.34 76.24 53.63c3.538-6.146 7.304-13.7 11.08-22.447c10.868-25.16 21.89-59.925 29.843-99.13c13.89-68.487 18.235-150.56-2.05-219.794zM18 38.904V494h39.537c7.66-8.97 13.41-22.46 17.453-46c36.388 0 55.403-4.45 66.643-11.002c-28.225-25.493-51.414-58.844-68.455-101.207c11.647 15.058 25.708 29.464 42.047 42.96c43.04 66.73 107.412 97.86 188.41 106.137c.528-.748.977-1.347 1.726-2.532c1.156-1.823 2.407-3.91 4.275-6.074c1.868-2.162 4.978-5.622 10.906-5.264c5.675.342 8.213 3.45 10.146 5.636c1.932 2.186 3.372 4.383 4.71 6.342c1.196 1.756 2.208 3.126 2.928 3.985c33.258.64 59.62-3.37 76.278-12.105c16.926-8.875 24.842-20.973 24.392-42.29c-1.524-14.847-11.34-27.683-26.947-40.118c-40.617-6.275-78.99-31.115-94.06-66.02c-11.03-1.295-20.466-8.332-27.383-16.86c-8.08-9.963-13.61-22.38-16.327-34.36c-10.642-23.767-32.987-62.51-58.23-95.098c-12.69-16.383-26.14-31.236-38.918-41.884a115.044 115.044 0 0 0-10.282-7.67l-14.9 7.45c-8.804-17.61-12.764-38.21-16.733-56.073c-2.863-12.88-6.157-24.08-9.576-31.213c-18.795 14.465-23.428 28.884-22.86 44.033c.64 16.96 9.29 35.243 17.27 51.202l-16.1 8.05a850.688 850.688 0 0 1-4.14-8.38c-11.03 13.237-20.28 31.073-26.37 50.798c-6.42 20.808-9.224 43.544-7.645 65.106l-18.42-20.466c.835-17.014 3.946-34.01 8.865-49.95c7.323-23.725 18.72-45.27 33.504-61.33c.698-.758 1.407-1.5 2.123-2.234c-3.773-9.99-6.648-20.786-7.074-32.12c-.12-3.19-.005-6.415.352-9.653C64.072 65.847 42.305 48.19 18 38.904M194.36 60.74c-3.418 7.133-6.712 18.332-9.575 31.213c-1.77 7.97-3.603 16.458-5.846 24.984a152.97 152.97 0 0 1 9.71 7.48c6.103 5.086 12.168 10.863 18.143 17.136c5.438-12.064 9.973-24.722 10.426-36.78c.568-15.15-4.065-29.568-22.86-44.033zm157.05 142.824c-5.54 15.163-11.94 31.276-21.65 45.877c-7.622 11.46-17.263 21.663-29.983 27.83a55.92 55.92 0 0 1-5.5 2.302c2.51 6.778 6.125 13.518 10.307 18.674a43.676 43.676 0 0 0 3.772 4.11l4.384 3.51a19.802 19.802 0 0 0 3.97 1.984l3.183-.938c11.455-3.372 21.48-9.33 30.41-17.547a142.926 142.926 0 0 0 2.9-11.252c4.44-20.718 5.33-46.135-1.792-74.55zM226.2 322.134c6.122.148 12.176 1.467 17.788 3.446c12.83 4.524 24.37 12.33 33.467 19.26l-10.906 14.32c-.79-.602-1.616-1.21-2.442-1.816C261.828 364.064 255.42 369 248 369c-9.282 0-17-7.718-17-17c0-3.94 1.4-7.59 3.71-10.496c-8.33-2.39-15.434-2.134-21.774 2.023l-9.872-15.054c6.477-4.247 13.5-6.1 20.508-6.328c.876-.03 1.753-.03 2.627-.01zm170.46 100.637a38.27 38.27 0 0 1 4.473.3l-2.26 17.86c-9.21-1.166-15.993 2.556-23.755 12.58l-14.23-11.02c8.79-11.354 20.693-19.265 34.308-19.7a37.56 37.56 0 0 1 1.465-.02z"/></svg></a> 
        <div class="homepage-title stick-regular">Ruby Rhino Rentals</div>
      </div>
      <div class="h-icons">
        <a href=""><svg class="rhino h-button" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="m20.772 10.155l-1.368-4.104A2.995 2.995 0 0 0 16.559 4H7.441a2.995 2.995 0 0 0-2.845 2.051l-1.368 4.104A2 2 0 0 0 2 12v5c0 .738.404 1.376 1 1.723V21a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-2h12v2a1 1 0 0 0 1 1h1a1 1 0 0 0 1-1v-2.277A1.99 1.99 0 0 0 22 17v-5a2 2 0 0 0-1.228-1.845M7.441 6h9.117c.431 0 .813.274.949.684L18.613 10H5.387l1.105-3.316A1 1 0 0 1 7.441 6M5.5 16a1.5 1.5 0 1 1 .001-3.001A1.5 1.5 0 0 1 5.5 16m13 0a1.5 1.5 0 1 1 .001-3.001A1.5 1.5 0 0 1 18.5 16"/></svg>
        <a href=""><svg class="rhino h-button" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 48 48"><g fill="currentColor"><path d="M32 20a8 8 0 1 1-16 0a8 8 0 0 1 16 0"/><path fill-rule="evenodd" d="M23.184 43.984C12.517 43.556 4 34.772 4 24C4 12.954 12.954 4 24 4s20 8.954 20 20s-8.954 20-20 20a21.253 21.253 0 0 1-.274 0c-.181 0-.362-.006-.542-.016M11.166 36.62a3.028 3.028 0 0 1 2.523-4.005c7.796-.863 12.874-.785 20.632.018a2.99 2.99 0 0 1 2.498 4.002A17.942 17.942 0 0 0 42 24c0-9.941-8.059-18-18-18S6 14.059 6 24c0 4.916 1.971 9.373 5.166 12.621" clip-rule="evenodd"/></g></svg></a>   
      </div>
    </div>
</div>

<div class="homepage-division">
    <div class="calendar-column">
        <div id='calendar'></div>
    </div>
    <div class="info-column" id="event-info">

    </div>
</div>

</body>
</html>
