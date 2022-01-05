from redis import Redis
from flask import Flask, request, render_template, jsonify, session
from flaskext.mail import Mail

from flask_mail import Mail, Message
import rq
from rq.job import Job
from fetch_data import fetch_data
from celery_config import app
from celery.result import AsyncResult
import os
import smtplib

flask_app = Flask(__name__)
flask_app.config['MAIL_SERVER'] = 'smtp.gmail.com'
flask_app.config['MAIL_PORT'] = 587 
flask_app.config['MAIL_USE_TLS'] = True
flask_app.config['MAIL_DEFAULT_SENDER'] = 'chunlei.yu1990@gmail.com' 
flask_app.config['MAIL_USERNAME'] = 'chunlei.yu1990@gmail.com' 

flask_app.config['MAIL_PASSWORD'] = 'xyuqyyimuzgiuppq'

#export MAIL_PASSWORD=xyuqyyimuzgiuppq
flask_app.secret_key = 'yuchunlei1990'
mail=Mail(flask_app)
# Initialize application


# Set up a Redis connection
redis = Redis()

# Initialize queue based on redis connection
queue = rq.Queue(connection=redis)

jobs = []

@flask_app.route("/")
def main():
    return render_template('base_template.html')

@flask_app.route("/Hic_Cal")
def main():
    return render_template('Hic_Cal.html')

@flask_app.route('/Hic_Cal/status/<job_id>', methods=['GET'])
def get_status(job_id):
    """ Returns status of job with id of job_id.
        If job_id doesn't exist, status of it will be 'PENDING'
    """
    job = send_email.AsyncResult(job_id, app=app)
    return jsonify({'job_id': job_id, 'status': job.status})

@flask_app.route('/Hic_Cal/results/<job_id>', methods=['GET'])
def view_result(job_id):
    """ Returns the results of the job with id of job_id if the job was successful.
    """
    job = fetch_data.AsyncResult(job_id, app=app)
    if job.successful():
        result = job.result
        return jsonify({'job_id': job_id, 'result': job.result})
    else:
        result = 'job was not finished or was not successful'
    return jsonify({'job_id': job_id, 'result': result})

@flask_app.route('/Hic_Cal', methods=['GET', 'POST'])
def query():
    url = request.form['url']
    job = fetch_data.delay(url)
    inputEmail = request.form['inputEmail']
    print (inputEmail)
    jobs.append(job.id)
    send_email(inputEmail, job.id)
    return render_template('/Hic_Cal.html', jobs=jobs)


def send_email(email, results):
    subject = 'Test Result'
    message = """ Hello, %s,
    See the results at http://127.0.0.1:5000/results/%s""" % (email, results)
    msg = Message(subject=subject, html=message, recipients=[email])
    mail.send(msg)

    return


if __name__ == '__main__':
    flask_app.run(debug=True)
