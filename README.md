# earthquakesUS
This is a sample project to highlight iOS development skill. 
The project uses webservices to download JSON on earthquakes. 
Downloaded data is parsed and displayed in a summary tableview and map. 
Data in the tableview is color coded from green to red based on the magnitude of the earthquake.
If there is no network activity, previously downloaded data are available for summary inspection. 
Detailed data are only viewable with network activity.

Persistence is currently implemented using NSKeyArchiver & NSUserDefaults.
Currently in the process of adding CoreData (although it would be excessive for the apps needs).

Ap
