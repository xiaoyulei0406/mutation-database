from celery_config import app
import requests

@app.task
def fetch_data(url):
    """ Fetches and returns data from URL. """
    try:
        response = requests.get(url).text
    except:
        response = {"error": "unable to get url"}

    return response
#def send_email(url, inputEmail):
#	results = requests.get(url).text
#	subject = '******** Result'
#	print results
#	message = 'See the results at http://127.0.0.1:5000/result/%s' % results
#	msg = Message(subject=subject, html=message, recipients=[inputEmail])
#	mail.send(msg)
#	DATA = """ Dear %s,
#	your RNAMake job is finished.
#	See the results at
#	http://127.0.0.1:5000/result/%s
#	""" % (inputEmail, url)

#	return