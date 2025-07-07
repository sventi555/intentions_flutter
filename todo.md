- infinite scroll on posts (feed, intention page, profile)
    - extract infinite posts widget to use on intentions and profile
    - update other post providers to be paged providers
    - update respective pages to use new notifier providers and list widgets
- android production deployment (play store)

Tech debt:
- handle failed api calls on write operations more gracefully in all cases
- remove state errors from most providers (state errors should be handled from consumers probably)
- firestore rule tests for feed and notifications
- use more of an MVC architecture

Enhancements(?):
- non-blocking image upload pipeline
- option to clear image on post creation
