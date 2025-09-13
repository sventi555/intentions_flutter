- loading animations:
    - sign up
    - notification response
- crop profile pic better (or add option to do it manually)
- delete post UI
- toggle for public profile

Tech debt:
- handle failed api calls on write operations more gracefully in all cases
- remove state errors from most providers (state errors should be handled from consumers probably)
- firestore rule tests for feed and notifications
- use more of an MVC architecture

Enhancements(?):
- random intention every day that people can participate in together!
- non-blocking image upload pipeline
- option to clear image on post creation
