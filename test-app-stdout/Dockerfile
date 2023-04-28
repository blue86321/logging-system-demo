# Use an official Python runtime as a parent image
FROM python:alpine3.17

# Copy the current directory contents into the container at /app
COPY . /app

# Set the working directory to /app
WORKDIR /app

CMD ["python", "-u", "go-test.py"]
