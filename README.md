Репозиторий содержит Helm-чарт для развёртывания одиночной инсталляции ClickHouse в Kubernetes.

Чарт полностью параметризован и позволяет задавать:

версию ClickHouse;

список пользователей и их параметры;

размер и класс хранилища (PVC);

ресурсы контейнера.

Решение подходит для локальных кластеров (Minikube, k3d) и тестовых сред (CI).

📦 Установка зависимостей (Ubuntu)
🔧 Docker
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
docker ps

🔧 kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubectl

🧩 Minikube (локальный Kubernetes)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube


Проверка:

minikube version

🧰 Helm 3
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

☸️ Запуск Kubernetes-кластера
minikube start --driver=docker --cpus=2 --memory=4g


Проверка:

kubectl get nodes

🚀 Установка ClickHouse

Перейдите в каталог чарта:

cd clickhouse-single


Создайте namespace:

kubectl create namespace clickhouse


Установите чарт:

helm install clickhouse . --namespace clickhouse


Проверьте Pod:

kubectl get pods -n clickhouse


Ожидаемый вывод:

clickhouse-clickhouse-single-0   1/1   Running

⚙️ Настройка через values.yaml
1. Версия ClickHouse
image:
  repository: clickhouse/clickhouse-server
  tag: "24.3"


Можно указать при установке:

helm install clickhouse . -n clickhouse --set image.tag=24.8

2. Пользователи ClickHouse

values.yaml:

clickhouse:
  users:
    - name: "app_user"
      password: "app_password"
      profile: "default"
      quota: "default"
      networks:
        - "::/0"

    - name: "readonly"
      password: "readonly_pass"
      profile: "default"
      quota: "default"
      networks:
        - "10.0.0.0/8"


Чарт автоматически сгенерирует users.xml и смонтирует его в:

/etc/clickhouse-server/users.d/users.xml

🔌 Подключение к ClickHouse

Откройте порт:

kubectl port-forward -n clickhouse svc/clickhouse-clickhouse-single 8123:8123


Выполните запрос:

curl "http://localhost:8123/?query=SELECT%201" \
  --user app_user:app_password


Ожидаемый результат:

1

🔄 Обновление чарта

После изменения values.yaml запустите:

helm upgrade clickhouse . -n clickhouse

🗑 Удаление
helm uninstall clickhouse -n clickhouse
kubectl delete namespace clickhouse
