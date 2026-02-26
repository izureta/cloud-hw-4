**Cloud HW 4**

POST-Test results: https://load-testing-iliakruchinin-post.website.yandexcloud.net/

GET-Test results: https://load-testing-iliakruchinin-get.website.yandexcloud.net/

Const-Test results: https://load-testing-iliakruchinin-const.website.yandexcloud.net/


Как пострелять:

```bash
cd flask-style-tranfser/examples

export BASE_URL="http://158.160.90.121:8000"

curl -sS -o out.jpg \
  -F "model=mosaic" \
  -F "image=@./lenna.jpg" \
  "$BASE_URL/“
```

Вернется out.jpg - lenna.jpg в стиле мозайки

Grafana Dashboard:

http://130.193.42.164:3000/goto/dfef6lzheczcwb?orgId=1
