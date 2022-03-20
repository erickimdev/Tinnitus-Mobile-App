# TINNITUS MOBILE APP

### <a name="about"></a>About
Mobile app created for Android / iOS designed specifically for tinnitus patients to regularly utilize 3 modules:
  1. **An interactive calendar widget to log and trace any tinnitus events that occur**
  2. **A daily questionnaire where the patient ranks feelings of particular emotions**
  ```
    > Questions:
        1. "I have been feeling stressed & nervous."
        2. "I have been feeling depressed & sad."
        3. "I have been feeling tired or have little energy."
        4. "I have been satisfied with my sleep."
        5. "I have been engaging in physical activities I enjoy."
        6. "My social relationships have been supportive & rewarding."
    
    > Answers:
        1. Never
        2. Rarely
        3. Sometimes
        4. Often
        5. Always
  ```
  3. **Day-Week-Month graphs that constantly measure and visualizes physical metrics using smartband, including:**
  ```
    > Heart:
        - Maximum Heartrate
        - Minimum Heartrate
        - Average Heartrate
    
    > Steps:
        - Total Step Count
        - Distance Traveled
    
    > Sleep:
        - Calories Burned
        - Movement Minutes
    
    > Activity:
        - Awake Time
        - Light Sleep Time
        - Deep Sleep Time
        - REM Sleep Time
        - Total Time Asleep
  ```

### Project File Hierarchy
```
project
│
└───lib
    │   main.dart
    │   FirestoreService.dart
    │
    └───pages
        │   home.dart
        │   profile.dart
        │
        │───calendar
        │   │   addEvent.dart
        │   │   calendar.dart
        │   │   utils.dart
        │
        │───poll
        │   │   poll.dart
        │
        └───smartwatch
            │   smartwatch.dart
            │   utils.dart
            │
            └───parts
                │   activity.dart
                │   heart.dart
                │   sleep.dart
                │   step.dart
```


## TECHNOLOGY STACK USED
* Dart
* Flutter
* Xcode
* REST - Google Fit API
* Kotlin/Swift
* Android Virtual Device (AVD) Emulator
* Google Firestore
* OAuth 2.0


## LINKS
* ["Smartband - App Connection" Instruction Guide](https://erickim.dev/wp-content/uploads/2022/03/Tinnitus-App-Instruction-Manual.pdf)
* [Android APK Download](https://drive.google.com/file/d/1hDs7fnVB492pgGa-DsNm-KkFOkYk0bs7/view?usp=sharing) - current build
* iOS Download - coming soon!


## SCREENSHOTS
\**Click on any image to enlarge*\*

  * **HOME SCREEN**
  <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Home.png" width="150">

  * **CALENDAR**
  <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Calendar-Add-Event.png" width="365">

  * **DAILY QUESTIONNAIRE** - *Questions*
  <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Daily-Questionnaire.png" width="950">
  
    * **DAILY QUESTIONNAIRE** - *Submitted*
    <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Questionnaire-Submitted.png" width="150">
  
  * **SMARTWATCH BEHAVIOROME** - *Home page*
  <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Smartwatch.png" width="150">

    * **SMARTWATCH** - *Step*
    <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Step.png" width="500">

    * **SMARTWATCH** - *Activity*
    <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Activity.png" width="500">

    * **SMARTWATCH** - *Sleep*
    <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Sleeping.png" width="500">

    * **SMARTWATCH** - *Heart*
    <br> <img class="image" src="https://erickim.dev/wp-content/uploads/2022/03/Heart.png" width="500">
