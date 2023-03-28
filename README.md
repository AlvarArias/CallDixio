# Dixio

DIXIO is a mobile application designed to provide users with a comprehensive Swedish-Spanish and Spanish-Swedish dictionary experience. The app is built with a modern and scalable data architecture that allows for seamless integration of different technologies.

One of the key components of DIXIO's architecture is the MVVM (Model-View-ViewModel) pattern. This pattern allows for a separation of concerns between the application's data, its user interface, and the logic that connects the two. The ViewModel acts as an intermediary between the Model (the data) and the View (the user interface), which makes it easier to manage data flow and keep the UI responsive.

To play the word sound, DIXIO uses AVFoundation, Apple's framework for working with audio and video media. The ViewModel retrieves the audio file URL from the Model and passes it to the View, which plays the sound using AVFoundation.

DIXIO uses Combine, Apple's framework for reactive programming, to notify the UI of changes to the URLSession response. The ViewModel subscribes to the response using Combine's Publisher-Subscriber pattern and updates the View accordingly.

Core Data is used to save the words that the user searches for.

DIXIO's Settings View allows the user to change the app's language to Spanish, Swedish, or English (default). This feature is implemented using Apple's Localization framework, which enables the app to display different content based on the user's preferred language. The ViewModel updates the app's language preference in Core Data, and the View displays the content accordingly.

In summary, DIXIO's technical architecture combines several modern technologies to provide users with a seamless and responsive Swedish-Spanish and Spanish-Swedish dictionary experience. The use of MVVM, AVFoundation, Combine, Core Data, and Localization frameworks enables the app to manage data flow, play audio, notify the UI, save user data, and display content in multiple languages.
