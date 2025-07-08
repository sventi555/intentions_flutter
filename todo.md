- fix self profile link on user tab
- android production deployment (play store)

Tech debt:
- handle failed api calls on write operations more gracefully in all cases
- remove state errors from most providers (state errors should be handled from consumers probably)
- firestore rule tests for feed and notifications
- use more of an MVC architecture

Enhancements(?):
- non-blocking image upload pipeline
- option to clear image on post creation
