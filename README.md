# Ruby Rhino Rentals Web Application

This project is a comprehensive web application built using Classic ASP for a fictional car rental service named "Ruby Rhino Rentals." The application focuses on providing a seamless user experience for both administrators and customers, offering a range of features such as event scheduling, session management, and a responsive design.

## Table of Contents

- [Key Features](#key-features)
- [Login](#login)
- [Homepage](#homepage)
- [Profile](#profile)
- [Databases](#databases)
- [Demo](#demo)
- [Conclusion](#conclusion)
- [Credits](#credits)

## Key Features

- **Event Management with FullCalendar:** The application integrates FullCalendar for scheduling and managing rental bookings. Users can create, view, and delete events directly from the calendar interface, with support for both single and multi-day events.

- **Session Management:** Ensuring user security and experience, the application includes robust session management. Users must be authenticated to access certain features, and their sessions are kept active through periodic server communication.

- **Responsive Design:** The application is optimized for mobile viewing, ensuring that users can manage their bookings and rentals from any device.

- **User Roles:** The application supports different user roles (admin and regular users), with specific permissions for each, ensuring secure and controlled access to functionality.

- **AJAX Integration:** The application uses AJAX for dynamic content updates without the need to reload the page, improving the user experience.


## Databases
![cars_db.png](https://github.com/FedeDC512/asp-calendar/blob/main/images/cars_db.png)
![events_db.png](https://github.com/FedeDC512/asp-calendar/blob/main/images/events_db.png)
![users_db.png](https://github.com/FedeDC512/asp-calendar/blob/main/images/users_db.png)

## Conclusion

Developing "Ruby Rhino Rentals" provided a deep dive into both client-side and server-side scripting, highlighting the importance of session management, AJAX for smooth user experiences, and the integration of external libraries like FullCalendar.js. The project also emphasized the value of secure user authentication and maintaining session integrity across user interactions.

This project has significantly enhanced my skills as a web developer, particularly in Classic ASP, and has broadened my understanding of how to integrate modern front-end technologies with classic server-side scripting to build feature-rich, interactive web applications.

## Credits

- **Calendar Integration**: The interactive calendar functionalities are powered by [FullCalendar.js](https://fullcalendar.io/), enabling dynamic event management and real-time updates.
- **Session Management**: AJAX-based session management was implemented to keep sessions active without interrupting user activities, utilizing [jQuery](https://jquery.com/) for asynchronous server communication.
- **MD5 Hashing**: The application uses MD5 hashing for secure data handling, implemented in Classic ASP with the help of [ASPMD5 by Centurix](https://github.com/Centurix/ASPMD5).
- **Front-End Enhancements**: User interface enhancements and AJAX functionalities were integrated using [jQuery](https://jquery.com/), ensuring a responsive and interactive user experience. 
- **Gifs Creation**: GIFs for the project README were created using [FFmpeg](https://ffmpeg.org/). The command used was `ffmpeg -i input.mp4 output.gif`.