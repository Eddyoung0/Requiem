# Event Ranking

A simple web application for discovering, ranking, and voting on events.

## What You Can Do

- **Create an Account** - Register and login to access the platform
- **Browse Events** - View all events across different categories
- **Submit Events** - Add new events to the platform
- **Vote & Rank** - Vote on events to help rank them
- **Bookmark Events** - Save your favorite events for later
- **View Analytics** - Check trending events and voting statistics
- **Admin Panel** - Manage events, categories, and users (admin only)

## How to Set Up

### Requirements

- Java 11 or higher
- MySQL database
- Maven
- Tomcat or similar web server

### Installation Steps

1. **Clone the project**

   ```
   git clone <repository-url>
   cd EventRanking_Main
   ```

2. **Update Database Configuration**
   - Open `eventranking/src/main/java/com/eventranking/util/DBConnection.java`
   - Update these values with your MySQL credentials:
     - URL: `jdbc:mysql://localhost:3306/event_ranking_db`
     - USERNAME: your MySQL username
     - PASSWORD: your MySQL password

3. **Create Database**
   - Use the SQL script in `eventranking/src/main/webapp/WEB-INF/includes/schema.sql`
   - Run it in your MySQL client to create tables

4. **Build the Project**

   ```
   cd eventranking
   mvn clean package
   ```

5. **Deploy**
   - Copy the generated WAR file to your Tomcat webapps folder
   - Start Tomcat

6. **Access the Application**
   - Open your browser and go to `http://localhost:8080/queuepro`

## Project Structure

- **java/com/eventranking/controller/** - Handles user requests (login, voting, etc.)
- **java/com/eventranking/dao/** - Manages database operations
- **java/com/eventranking/model/** - Event and User data objects
- **java/com/eventranking/util/** - Helper classes (database connection, email, scheduler)
- **webapp/** - User interface files (JSP pages, CSS, JavaScript, images)

## Main Features

- User authentication with "Remember Me" functionality
- Event submission and categorization
- Voting system with analytics
- Admin dashboard for content management
- Email notifications and reminders
- Responsive web interface

## Authentication Pages

- **Login Page** - Users can login with their email and password. There's a "Remember Me" checkbox to stay logged in for 30 days without re-entering credentials.
- **Register Page** - New users can create an account by providing their name, email, and password. After registration, you can immediately login to start exploring events.
- Both pages have validation to ensure email format is correct and passwords are secure.

## Core Servlets

### LoginServlet

- **URL:** `/login`
- **Methods:** GET, POST
- **Functionality:** Handles user authentication with email and password
- **Features:**
  - Validates user credentials against the database
  - Supports "Remember Me" functionality (30-day persistent login)
  - Redirects authenticated users to the home page
  - Displays error messages for invalid credentials

### RegisterServlet

- **URL:** `/register`
- **Methods:** GET, POST
- **Functionality:** Handles new user registration
- **Features:**
  - Validates user input (email format, password requirements)
  - Creates new user accounts in the database
  - Prevents duplicate email registrations
  - Automatically logs in users after successful registration

### LogoutServlet

- **URL:** `/logout`
- **Methods:** POST
- **Functionality:** Handles user logout
- **Features:**
  - Clears user session
  - Removes authentication cookies
  - Redirects users to the login page
  - Cleans up "Remember Me" tokens

### UserDashboardServlet

- **URL:** `/user-dashboard`
- **Methods:** GET, POST
- **Functionality:** Displays personalized user dashboard
- **Features:**
  - Shows user's bookmarked events
  - Displays voting history and statistics
  - Allows users to manage their events
  - Provides quick access to user preferences

## Default Login

After setup, you can create a new account or check the database for test credentials.
