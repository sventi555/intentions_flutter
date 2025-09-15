- see who you're following and who's following you
- delete/edit post UI
- toggle for public profile (or just get rid of public... Would simplify backend. I think that is good)

Tech debt:
- handle failed api calls on write operations more gracefully in all cases
- remove state errors from most providers (state errors should be handled from consumers probably)
- firestore rule tests for feed and notifications
- use more of an MVC architecture

Enhancements(?):
- clear notifications
- random intention every day that people can participate in together!
- non-blocking image upload pipeline
- option to clear image on post creation
- image for each intention. gallery view of intentions (grid)
- multiple intentions for one post
- sign up/in can be top level. It doesn't need to keep the tab bar showing.
