# Ruby Rhino Rentals Web Application

This project is a comprehensive web application built using Classic ASP for a fictional car rental service named "Ruby Rhino Rentals." The application focuses on providing a seamless user experience for both administrators and customers, offering a range of features such as event scheduling, session management, and a responsive design.

## Table of Contents

- [Key Features](#key-features)
- [Login and Sign Up](#login-and-sign-up)
- [Homepage](#homepage)
- [Car Models List](#car-models-list)
- [Managing Events](#managing-events)
- [Permission Management](#permission-management)
- [Responsive Pages](#responsive-pages)
- [Databases](#databases)
- [Mobile Demo](#mobile-demo)
- [Desktop Demo](#desktop-demo)
- [Conclusion](#conclusion)
- [Credits](#credits)

## Key Features

- **Event Management with FullCalendar:** The application integrates FullCalendar for scheduling and managing rental bookings. Users can easily create, view, and remove events within the calendar interface, with flexibility for events spanning one or multiple days. Events can be scheduled as either full-day or confined to particular start and end times, allowing for four different configurations: a single full day, a single day with defined times, multiple full days, or multiple days with specific time frames.

- **Session Management:** Ensuring user security and experience, the application includes robust session management. Users must be authenticated to access certain features, and their sessions are kept active through periodic server communication.

- **Responsive Design:** The application is optimized for mobile viewing, ensuring that users can manage their bookings and rentals from any device.

- **User Roles:** The application supports different user roles (admin and regular users), with specific permissions for each, ensuring secure and controlled access to functionality. Regular users can move and delete only the events they have created themselves, while admins have the ability to move and delete any events, regardless of the creator.

- **AJAX Integration:** The application uses AJAX for dynamic content updates without requiring a page reload, enhancing the user experience. On the 'Car Models List' page, lazy loading is activated automatically as the user scrolls to the bottom, allowing for continuous and uninterrupted browsing.


## Login and Sign Up
![login_signup.gif](https://github.com/FedeDC512/asp-calendar/blob/main/images/login_signup.gif)

## Homepage
![calendar.gif](https://github.com/FedeDC512/asp-calendar/blob/main/images/calendar.gif)
![tutorial.png](https://github.com/FedeDC512/asp-calendar/blob/main/images/tutorial.png)

## Car Models List
![cars.gif](https://github.com/FedeDC512/asp-calendar/blob/main/images/cars.gif)

## Managing Events
https://github.com/user-attachments/assets/9d589123-cad6-4963-8435-ef4831abe174

## Permission Management
### User View
![permissions_user.gif](https://github.com/FedeDC512/asp-calendar/blob/main/images/permissions_user.gif)
### Admin View
![permissions_admin.gif](https://github.com/FedeDC512/asp-calendar/blob/main/images/permissions_admin.gif)

## Responsive Pages
![responsive.gif](https://github.com/FedeDC512/asp-calendar/blob/main/images/responsive.gif)

## Databases
![cars_db.png](https://github.com/FedeDC512/asp-calendar/blob/main/images/cars_db.png)
![events_db.png](https://github.com/FedeDC512/asp-calendar/blob/main/images/events_db.png)
![users_db.png](https://github.com/FedeDC512/asp-calendar/blob/main/images/users_db.png)

## Mobile Demo
https://github.com/user-attachments/assets/adf60d32-14ca-43da-99b7-485f40669216

## Desktop Demo
https://github.com/user-attachments/assets/daf8c849-df24-463d-99ed-f0c6a6b3b72d

## Conclusion

Developing "Ruby Rhino Rentals" provided a deep dive into both client-side and server-side scripting, highlighting the importance of session management, AJAX for smooth user experiences, and the integration of external libraries like FullCalendar.js. The project also emphasized the value of secure user authentication and maintaining session integrity across user interactions.

This project has significantly enhanced my skills as a web developer, particularly in Classic ASP, and has broadened my understanding of how to integrate modern front-end technologies with classic server-side scripting to build feature-rich, interactive web applications.

## Credits

- **Calendar Integration**: The interactive calendar functionalities are powered by [FullCalendar.js](https://fullcalendar.io/), enabling dynamic event management and real-time updates.
- **Session Management**: AJAX-based session management was implemented to keep sessions active without interrupting user activities, utilizing [jQuery](https://jquery.com/) for asynchronous server communication.
- **MD5 Hashing**: The application uses MD5 hashing for secure data handling, implemented in Classic ASP with the help of [ASPMD5 by Centurix](https://github.com/Centurix/ASPMD5).
- **Front-End Enhancements**: User interface enhancements and AJAX functionalities were integrated using [jQuery](https://jquery.com/), ensuring a responsive and interactive user experience. 
- **Gifs Creation**: GIFs for the project README were created using [FFmpeg](https://ffmpeg.org/). The command used was `ffmpeg -i input.mp4 output.gif`.
