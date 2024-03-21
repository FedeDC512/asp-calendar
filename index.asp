<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendar</title>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js'></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var calendarEl = document.getElementById('calendar');

        var calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            editable: true,
            selectable: true,
            select: function(info) {
                var title = prompt('Inserisci il titolo dell\'evento:');
                if (title) {
                    var start = info.startStr;
                    var end = info.endStr;
                    var eventData = {
                        title: title,
                        start: start,
                        end: end
                    };
                    console.log(eventData);
                    calendar.addEvent(eventData);
                    saveEvent(title, start, end); // Chiamata alla funzione ASP per salvare l'evento
                }
            },
            eventClick: function(info) {
                if (confirm("Do you want to delete this event?")) {
                    deleteEvent(info.event);
                }
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

        function saveEvent(title, start, end) {
            // Chiamata AJAX a uno script ASP per salvare l'evento nel database o in un file
            $.ajax({
                url: 'save_event.asp',
                type: 'POST',
                data: { title: title, start: start, end: end },
                success: function(response) {
                    console.log('Event saved.');
                },
                error: function(xhr, status, error) {
                    console.error('Error saving event:', error);
                }
            });
        }
    
        function deleteEvent(event) {
            $.ajax({
                url: 'delete_event.asp',
                type: 'POST',
                data: { 
                    title: event.title,
                    start: event.startStr,
                    end: event.endStr
                },
                success: function(response) {
                    console.log('Event deleted.');
                    event.remove(); // Rimuove l'evento dal calendario
                },
                error: function(xhr, status, error) {
                    console.error('Error deleting event:', error);
                }
            });
        }
    });
    </script>
</head>
<body>

<div id='calendar'></div>

</body>
</html>