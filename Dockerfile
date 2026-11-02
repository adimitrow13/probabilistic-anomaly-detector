# Базово олекотено изображение с официален Python 3.11
FROM python:3.11-slim

# Настройка на променливи на средата за оптимална работа в контейнер
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Инсталиране на минимални системни инструменти за мониторинг
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Дефиниране на работната директория вътре в контейнера
WORKDIR /app

# Първо копираме само изискванията (за ефективно използване на Docker кеша)
COPY requirements.txt .

# Инсталиране на Python зависимостите без съхраняване на временен инсталационен кеш
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Копиране на останалата част от кодовата база
COPY . .

# Отваряне на стандартния мрежов порт за Streamlit
EXPOSE 8501

# Проверка на състоянието на контейнера (Healthcheck)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# Стартова команда за изпълнение на приложението
ENTRYPOINT ["streamlit", "run", "ui/app.py", "--server.port=8501", "--server.address=0.0.0.0"]
