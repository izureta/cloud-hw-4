from flask import Flask, render_template, request, make_response
import tempfile
import os
import time

from prometheus_client import Counter, Histogram, make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from style_transfer import process_image

REQUEST_COUNT = Counter(
    'app_requests_total',
    'Total number of requests',
    ['method', 'status_code'],
)

POST_LATENCY = Histogram(
    'app_post_latency_seconds',
    'Latency of successful POST requests in seconds',
    buckets=[round(x * 0.01, 2) for x in range(1, 1001)],
)

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 20 * 1024 * 1024
ALLOWED_MODELS = ['feathers', 'mosaic', 'the_scream']

app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app(),
})


@app.route('/', methods=['GET', 'POST'])
def apply_model():
    if request.method == 'POST':
        if 'model' not in request.form:
            REQUEST_COUNT.labels(method='POST', status_code='400').inc()
            return 'no model selected', 400
        model = request.form['model']
        if model not in ALLOWED_MODELS:
            REQUEST_COUNT.labels(method='POST', status_code='400').inc()
            return 'incorrect model', 400

        if 'image' not in request.files:
            REQUEST_COUNT.labels(method='POST', status_code='400').inc()
            return 'no image', 400
        image = request.files['image']
        if image.filename == '':
            REQUEST_COUNT.labels(method='POST', status_code='400').inc()
            return 'no image selected', 400

        start = time.monotonic()
        with tempfile.NamedTemporaryFile() as input_file:
            image.save(input_file.name)
            with tempfile.NamedTemporaryFile(suffix='.jpg') as output_file:
                model_path = os.path.join(app.root_path, 'models', model + '.t7')
                process_image(input_file.name, model_path, output_file.name)
                response = make_response(output_file.read())
        POST_LATENCY.observe(time.monotonic() - start)
        REQUEST_COUNT.labels(method='POST', status_code='200').inc()
        response.headers.set('Content-Type', 'image/jpeg')
        return response

    REQUEST_COUNT.labels(method='GET', status_code='200').inc()
    return render_template('upload.html')
