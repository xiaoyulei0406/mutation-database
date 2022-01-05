from celery import Celery

app = Celery('fetch_data', backend='redis://localhost', broker='redis://localhost')

result_backend = 'redis://localhost/'
