FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the RSS script
COPY rss_script.py .

EXPOSE 8000

CMD ["uvicorn", "rss_script:app", "--host", "0.0.0.0", "--port", "8000"] 