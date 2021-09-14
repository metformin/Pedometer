
# Pedometer
An application project that will allow you to track your steps, burned calories, traveled distance and more!<br>
Fully coded in Swift using the Combine framework and MVVM design pattern.
<br>
<br>
1. The app on the home screen shows live data such as steps taken, calories burned, floors climbed, tempo, and distance traveled.
<br>

<p align="center"><img src="https://user-images.githubusercontent.com/45921300/133324527-ed58d2f9-f679-4d0f-a1bb-4b3ace9dccbf.PNG" width="300"> <img src="https://user-images.githubusercontent.com/45921300/133325307-356ae6b3-d774-43b4-9e41-5a68d1830280.PNG" width="300"></p>
<br>

2. The history tab generates graphs for the selected category (steps, distance or calories). User can change the date range for the charts. Total and average values for the selected period are also shown.
<br>
<p align="center"><img src="https://user-images.githubusercontent.com/45921300/133325854-5a037775-70bb-4f1e-bc8b-c882038ef2f1.PNG" width="300"> <img src="https://user-images.githubusercontent.com/45921300/133325870-01d231dd-9ab0-4c64-8dc9-0f0a8ffe5679.PNG" width="300"></p>



<br>

3. The settings tab allows the user to define the data needed to correctly calculate all parameters(such a user sex, weight) and define the goal of the steps for the day.
<br>

<p align="center">
<img src="https://user-images.githubusercontent.com/45921300/133326102-1180ee66-8236-4324-a95c-86f6b381550b.PNG" width="300"> 
<img src="https://user-images.githubusercontent.com/45921300/133326139-73492c71-9d6b-4b35-a57d-a94c9828984a.PNG" width="300"> 
<img src="https://user-images.githubusercontent.com/45921300/133326152-2e6ce9ec-51c0-4541-9ee2-1553faa6fe3d.PNG" width="300"> 
<img src="https://user-images.githubusercontent.com/45921300/133326211-6e196381-9c8e-41f8-8128-426924a83ca3.PNG" width="300"> </p>




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

