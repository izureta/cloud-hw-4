# Сервисный аккаунт для Load Testing — нужен чтобы агент мог
# писать результаты тестов в бакет и управлять тестами
resource "yandex_iam_service_account" "load_testing" {
  name = "hw4-load-testing-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "load_testing_editor" {
  folder_id = var.folder_id
  role      = "loadtesting.generatorClient"
  member    = "serviceAccount:${yandex_iam_service_account.load_testing.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = var.folder_id
  role      = "storage.admin"  # editor недостаточно для создания бакета
  member    = "serviceAccount:${yandex_iam_service_account.load_testing.id}"
}

# Статические ключи для доступа к Object Storage
resource "yandex_iam_service_account_static_access_key" "load_testing_key" {
  service_account_id = yandex_iam_service_account.load_testing.id
}

# Бакет для хранения отчётов нагрузочного тестирования
resource "yandex_storage_bucket" "reports" {
  bucket     = "hw4-lt-reports-${var.folder_id}"  # folder_id делает имя уникальным
  access_key = yandex_iam_service_account_static_access_key.load_testing_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.load_testing_key.secret_key

  depends_on = [yandex_resourcemanager_folder_iam_member.storage_editor]

  # Публичный доступ на чтение — чтобы ссылка на отчёт открывалась в браузере
  acl = "public-read"

  # Режим хостинга статического сайта
  website {
    index_document = "index.html"
  }
}
