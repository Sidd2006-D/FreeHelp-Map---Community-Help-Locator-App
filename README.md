# FreeHelp-Map---Community-Help-Locator-App
FreeHelp Map is a location-based community assistance mobile application designed to help users discover and share free resources such as food distribution events, medical camps, blood donation drives, shelters, and educational support. The application focuses on trust, relevance, and accessibility by using distance-based filtering, scheduled event handling, verification, community comments, and a rating-based trust system.
# Problem Statement
In many regions, especially in India, information about free community help such as food or medical aid is scattered across social media, posters, or word-of-mouth. These methods are unreliable, hard to verify, and not location-aware. As a result, people often miss timely help opportunities.
# Proposed Solution
FreeHelp Map provides a centralized, map-based platform where verified help posts are displayed within a user-selected distance range. Users can view ongoing or upcoming events, interact via comments, navigate to locations using maps, and evaluate contributors through ratings.
# System Architecture
The system follows a hybrid architecture using Django and Firebase. Django manages business logic, APIs, relational data, and role-based access control. Firebase Authentication handles secure login, Firebase Storage stores images, and Firebase Cloud Messaging delivers real-time notifications.
# Application Flow
1. User logs in using Firebase Authentication.
2. Django verifies the Firebase ID token and retrieves or creates the user record.
3. The home map displays verified help posts within the selected distance range.
4. Users can add help posts, view details, comment, rate contributors, and navigate.
5. Volunteers verify posts before they become publicly visible.
6. Notifications are sent to nearby users when relevant events occur.
# Key Features
- Map-based help discovery
- Distance range filtering (2 km, 4 km, 6 km, 10 km)
- Scheduled, ongoing, and completed event handling
- Comment section for community interaction
- Google Maps navigation for directions
- Rating and trust score system
- Volunteer-based post verification
- Push notifications for nearby events
# Database Design (ER Overview)
The system includes the following main entities:

User: Stores Firebase UID, role, and trust score.
HelpPost: Stores help type, description, location, event timing, status, and creator.
Comment: Stores user comments associated with help posts.
Rating: Stores per-post ratings given to help post creators.

Relationships ensure one-to-many mapping between users and posts, posts and comments, and per-post ratings to prevent abuse.
# Technology Stack
Frontend: Mobile Application (Flutter or Android)
Backend: Django with Django REST Framework
Database: Django ORM (SQLite/PostgreSQL)
Authentication: Firebase Authentication
Storage: Firebase Storage
Notifications: Firebase Cloud Messaging
Maps: Google Maps API
# Future Scope
Future enhancements may include NGO and government integration, advanced analytics dashboards, AI-based fake post detection, multilingual support, and expansion to multiple cities.
# Conclusion
FreeHelp Map offers a practical, scalable, and socially impactful solution for improving access to community-driven assistance. By combining location intelligence, verification, and community feedback, the application ensures timely and trustworthy help discovery.
