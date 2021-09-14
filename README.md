# Pedometer
An application project that will allow you to track your steps, burned calories, traveled distance and more!<br>
Fully coded in Swift using the Combine framework and MVVM design pattern.
<br>
<br>
1. The app on the home screen shows live data such as steps taken, calories burned, floors climbed, tempo, and distance traveled.
<br><br>

2. The history tab generates graphs for the selected category (steps, distance or calories). User can change the date range for the charts. Total and average values for the selected period are also shown.
<br><br>

3. The settings tab allows the user to define the data needed to correctly calculate all parameters(such a user sex, weight) and define the goal of the steps for the day.
<br><br>


Full tech stack used in project:

| Name | Description          |
| ------------- | ----------- |
| Combine      | Handling of asynchronous events by combining event-processing operators.|
| HealthKit     | Access history health data such a steps, floors, etc. while maintaining the user’s privacy.   |
| CoreMotion     | Allows  to count the steps taken by the user in live time.   |
| Charts by Daniel Gindi     | Framework that allows to generate charts.   |
| UserDefaults     | An interface to the user’s default database - storing informations such a user sex, user weight, goal steps amount etc.   |
| NotificationCenter     | A notification dispatch mechanism that was used in this app to inform the user about the progress.   |
| PopupDialog     | Framework used for create a simple popup dialogs.    |

<br>

