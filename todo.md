- pull up to refresh
- option to clear image on post creation
- clear data on logout (basically just need to add ref.watch(authUserProvider) to protected fetches)
- infinite scroll on posts (feed, intention page, profile)
- android production deployment (play store)

Tech debt:
- handle failed api calls on write operations more gracefully in all cases
- remove state errors from most providers (state errors should be handled from consumers probably)
- firestore rule tests for feed and notifications
- use more of an MVC architecture

Enhancements(?):
- non-blocking image upload pipeline
