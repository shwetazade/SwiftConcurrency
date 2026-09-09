import Foundation

/*
 Question 1)

 final class UserProfile {
     var name: String
     var preferences: [String: String]
     init(name: String, preferences: [String: String]) {
         self.name = name
         self.preferences = preferences
     }
 }
 
 actor UserStore {
     private var profiles: [UserProfile] = []
     func save(_ profile: UserProfile) {
         profiles.append(profile)
     }
 }

 func testUserStore() {
     let profile = UserProfile(name: "Alex", preferences: ["theme": "dark"])
     Task {
         await UserStore().save(profile)
     }
 }

 
 Issue while compiling is "Sending 'profile' risks causing data races"
 'Sending task-isolated 'profile' to actor-isolated instance method 'save' risks causing data races between actor-isolated
 and task-isolated uses' on line await UserStore().save(profile)
 Reason - UserProfile is a class, which is a reference type.
  Also, UserProfile is mutable because its properties can be changed. When we pass profile to UserStore, the same
 UserProfile object is transferred to another concurrency context, which is the UserStore actor.

 The actor protects its own state, such as the profiles array, but it doesn't automatically make the UserProfile object
 itself safe to access from different concurrency contexts.

 Since UserProfile is a mutable reference type, the same object could potentially be accessed or modified from the original
 context while it is also being used by the UserStore actor.

 For example, one context could modify:
 profile.name = "John"
 while another context is accessing the same UserProfile object.
 This could result in a data race.

 So, the main issue is that we are sending a mutable class instance, which is a reference type, between concurrency
 contexts without guaranteeing that the object can be accessed safely from both contexts.
 
 */


/*
Question 2.1) Used struct for UserProfile
 
 struct UserProfile {
     var name: String
     var preferences: [String: String]

     init(name: String, preferences: [String: String]) {
         self.name = name
         self.preferences = preferences
     }
 }

 actor UserStore {
     private var profiles: [UserProfile] = []
     func save(_ profile: UserProfile) {
         profiles.append(profile)
     }
 }

 func testUserStore() {
     var profile = UserProfile(name: "Alex", preferences: ["theme": "dark"])
     let store = UserStore()
     Task {
         await store.save(profile)
         profile.name = "John"
         print(profile.name)
     }
 }
 */


/*
 Question 2.2)
 
 In the below code, Changed UserProfile from a class to an actor.
 Since UserProfile contains mutable properties, making it an actor ensures that its mutable state is protected by actor
 isolation when it is accessed from different concurrency contexts.
 Kept name and preferences as var because their values still need to be changeable.
 Since actor-isolated properties cannot be directly modified from outside the actor, added updateName() and
 updatePreference() methods. These methods modify the properties inside the UserProfile actor and we use await when calling
 them from outside.
 UserStore also remains an actor and can safely store UserProfile actor references.
 
 actor UserProfile {
     private(set) var name: String
     private(set) var preferences: [String: String]
     
     init(name: String, preferences: [String: String]) {
         self.name = name
         self.preferences = preferences
     }
     
     func updateName(_ newName: String) {
         self.name = newName
     }
     
     func updatePreference(key: String, value: String) {
         self.preferences[key] = value
     }
 }

 actor UserStore {
     private var profiles: [UserProfile] = []
     
     func save(_ profile: UserProfile) {
         profiles.append(profile)
     }
 }

 func testUserStore() {
     let profile = UserProfile(name: "Alex", preferences: ["theme": "dark"])
     let store = UserStore()
     Task {
         await store.save(profile)
         await profile.updateName("John")
         await profile.updatePreference(key: "language", value: "English")
         let name = await profile.name
         let preferences = await profile.preferences
         print(name)
         print(preferences)
     }
 }
 
 */


/*
 Question 2.3)
 
Kept UserProfile as a class and used the sending keyword in save().
sending tells Swift that the profile is being passed to another concurrency context and helps ensure the transfer is safe.
 
 final class UserProfile {
     var name: String
     var preferences: [String: String]
     init(name: String, preferences: [String: String]) {
         self.name = name
         self.preferences = preferences
     }
 }

 actor UserStore {
     private var profiles: [UserProfile] = []
     
     func save(_ profile: sending UserProfile) {
         profiles.append(profile)
     }
 }

 func testUserStore() async {
     let profile = UserProfile( name: "Alex", preferences: ["theme": "dark"])
     let store = UserStore()
     await store.save(profile)
 }
 
 */


