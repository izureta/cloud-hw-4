#!/usr/bin/python3
import requests

def print_request(request):
    req = b'%b %b HTTP/1.1\r\n%b\r\n%b' % (
        request.method.encode(),
        request.path_url.encode(),
        ''.join('{0}: {1}\r\n'.format(k, v) for k, v in request.headers.items()).encode(),
        request.body,
    )
    return b'%d\n%b\r\n' % (len(req), req)

#POST multipart form data
def post_multipart(host, port, namespace, files, headers, payload):
    req = requests.Request(
        'POST',
        'http://{host}:{port}{namespace}'.format(
            host = host,
            port = port,
            namespace = namespace,
        ),
        headers = headers,
        data = payload,
        files = files
    )
    prepared = req.prepare()
    return print_request(prepared)

if __name__ == '__main__':
    host = 'does.not.matter'
    port = '8000'
    namespace = '/'
    headers = {
        'User-Agent': 'tank'
    }
    payload = {
        'model': 'mosaic'
    }
    files = {
        'image': ('lenna.jpg', open('examples/lenna.jpg', 'rb'))
    }

    res = post_multipart(host, port, namespace, files, headers, payload)
    with open('ammo.txt', 'wb') as f:
        f.write(res)
