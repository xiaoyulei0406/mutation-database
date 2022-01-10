# mutation-database
Ongoing project............
Extract mutation from PDF files







# Patient Mutation Information Database

It is still being updated.

### Introduction:
Extract patient mutation information and metainformation (maybe later) from reports (pdf format) and Store data in the database. 

Clinical team members upload patient reports from a URL/local machine and store the results in our database. They will be notified when the data were uploaded and information was extracted

Immunologists and bioinformaticians download mutation information from database.

###Longterm Goals:

As mutation data and patient information accumulated, integration and visualisation function will be implemented.


### Start

Use Python 3.9 and its frameworks and libraries (Flask, Redis, and Celery) to this database. I test this on Mac.

To run this program, make sure you have all the modules listed above installed. Then, on the terminal, start the Redis Server by running:
```
redis-server
```
And start the Celery worker and the program, make sure these two commands are run in the same path folder
```
celery -A fetch_data worker --loglevel=info
python3 app.py
```
Finally, go to `http://localhost:5000/` on your browser.



### Updated


