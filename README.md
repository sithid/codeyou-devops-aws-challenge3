**Walkthrough Phase**: Building a Python Flask Web App Dockerfile

**Objective**: Guide students through creating a Dockerfile that containerizes a simple Python Flask application. This phase will introduce key Dockerfile concepts like setting a base image, copying files, installing dependencies, defining entry points, and working with environment variables.

**Steps**:
1. **Introduction to Dockerfile Basics**: Explain the purpose of Dockerfiles and the role of each instruction (e.g., `FROM`, `COPY`, `RUN`, `CMD`, etc.).
2. **Step-by-Step Walkthrough**:
   - Start with the given Dockerfile:
     ```dockerfile
     # Use an official Python runtime as the base image
     FROM python:3.9

     # Set the working directory
     WORKDIR /app

     # Copy the requirements file and install dependencies
     COPY ./source/requirements.txt /app/requirements.txt
     RUN pip install -r requirements.txt

     # Copy the rest of the application code
     COPY ./source/http /app

     # Expose the application port
     EXPOSE 5000

     # Define the command to run the app
     CMD ["flask", "run", "--host=0.0.0.0"]
     ```
   - **Explain Each Step**:
     - **Base Image** (`FROM`): Selecting an appropriate base image. Here, we are using Python 3.9 to ensure we have the runtime environment needed for our Flask app.
     - **Working Directory** (`WORKDIR`): Setting the working directory to `/app`. This is where all subsequent commands will be executed, and it helps keep the file structure organized.
     - **Copying Files** (`COPY`): Copying `requirements.txt` first allows Docker to cache the layer, making rebuilds faster if dependencies haven't changed. Then we copy the rest of the application code.
     - **Installing Dependencies** (`RUN`): Using `RUN pip install -r requirements.txt` to install all the necessary packages listed in the `requirements.txt` file.
     - **Exposing Ports** (`EXPOSE`): The `EXPOSE` statement is used to indicate that the container will listen on port `5000` at runtime. Note that this statement is primarily for documentation purposes within the Dockerfile and helps communicate to users and other containers which port the application will use. To make this port accessible outside of the container, you still need to use the `-p` or `--publish` flag when running the container (e.g., `docker run -p 6001:5000 ...`).
     - **Defining the Entry Point** (`CMD`): Specifies how to run the Flask application. By using `--host=0.0.0.0`, we ensure that the Flask server listens on all available network interfaces, allowing external access to the container.
3. **Environment Variables in `app.py`**:
   - In the `app.py` file, the Flask app uses an environment variable for `SECRET_KEY`:
     ```python
     app.secret_key = os.getenv('SECRET_KEY', 'secret string')
     ```
     This line sets the `SECRET_KEY` for Flask using the value from an environment variable `SECRET_KEY`. If the variable is not set, it defaults to `'secret string'`. To provide this value when running the container, you can use the `-e` flag:
     ```sh
     docker run -p 6001:5000 -e SECRET_KEY=mysecretkey flask-app
     ```
     This is useful for managing sensitive information like secret keys without hardcoding them in your application.
4. **Build and Debug the Docker Container**:
   - **Initial Build**: Now you can try to build the image using `docker build -t flask-app .`. This build should fail because the `RUN pip install -r requirements.txt` command will encounter an issue with `jsmin==2.2.2` in the `requirements.txt` file.
   - **Debugging Steps**:
     1. **Comment Out Problematic Lines**: Comment out the `RUN pip install ...` line and any other lines that prevent building the image.
     2. **Rebuild the Image**: Build the image successfully so that we can get a shell inside of it for further debugging.
        ```sh
        docker build -t flask-app-debug .
        ```
     3. **Run the Container in Interactive Mode**: Use the following command to start the container and get a shell inside it:
        ```sh
        docker run -it flask-app-debug /bin/bash
        ```
     4. **Replicate the Error**: Inside the container, try running the problematic command manually:
        ```sh
        pip install -r requirements.txt
        ```
        This will allow you to see the specific error message related to `jsmin==2.2.2`.
     5. **Identify the Problem**: Locate the offending line in `requirements.txt` and comment it out.
     6. **Retry the Installation**: Run the `pip install -r requirements.txt` command again. It should succeed this time.
     7. **Exit and Update**: Exit and kill the container. Modify the `requirements.txt` file on the local machine to remove or comment out the problematic line (`jsmin==2.2.2`).
     8. **Uncomment Dockerfile Lines**: Uncomment the lines in the Dockerfile that were previously commented out, and rebuild the image.
        ```sh
        docker build -t flask-app .
        ```
     9. **Successful Build**: The image should now build successfully, and you can continue onwards.
5. **Run the Container**: Run the container using `docker run -p 6001:5000 flask-app`. Mention that the `-p` flag maps port `5000` in the container to port `6001` on the host.
6. **Q&A**: This is a time to ask questions as you follow along to build your Dockerfile.

**Challenge Phase**: Building a Custom MySQL Container

**Objective**: Challenge students to write a Dockerfile that creates a custom MySQL container with some specific configuration. This task will test their understanding of the Dockerfile commands and how to customize container behavior.

**Requirements**:
1. **Use an Official Base Image**: Start from `mysql:8.0`.
2. **Set Environment Variables**:
   - Set `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, and `MYSQL_PASSWORD` as environment variables.
3. **Add Custom Initialization Script**:
   - Copy a SQL script (`init.sql`) to the container to initialize the database with some tables and data.
4. **Expose the Database Port**: Expose port `3306`.
5. **Command to Run**: Use the default MySQL command to start the server.

**Hints**:
- **Environment Variables** (`ENV`): Explain how to set default values for passwords and database names.
- **Initialization Script**: Guide students on how to use `COPY` to place the `init.sql` script in the appropriate directory (`/docker-entrypoint-initdb.d/`) so it runs automatically when the container starts.

**Example Dockerfile** (for guidance, not a complete solution):
```dockerfile
# Use the official MySQL base image
FROM mysql:8.0

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=exampledb
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=userpassword

# Copy the initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Expose MySQL port
EXPOSE 3306
```

**Tasks for Students**:
1. **Write the Dockerfile**: Have them write a Dockerfile that meets the requirements.
2. **Build and Run the Image**: Instruct students to build the image (`docker build -t custom-mysql .`) and run it (`docker run -d -p 3306:3306 custom-mysql`).
3. **Verify Initialization**: Ask them to connect to the MySQL server and verify that the database and tables from the `init.sql` script are correctly set up.

**Wrap-Up Discussion**:
- **Review Key Concepts**: Go over the most challenging parts students faced, like setting environment variables or understanding how `COPY` works.
- **Common Pitfalls**: Highlight common mistakes (e.g., incorrect paths, missing dependencies).
- **Q&A**: Open the floor for any remaining questions.

**Extensions (Optional)**:
- Ask students to create a multi-stage Dockerfile to reduce the image size.
- Challenge them to create a Docker Compose file to orchestrate the Flask app and MySQL container together.

**FAQ/Troubleshooting**:

1. **Flask Application Not Accessible Externally**:
   - **Issue**: The Flask app is running, but you cannot access it from your browser using the mapped port.
   - **Solution**: By default, `flask run` listens only on `127.0.0.1` (localhost), which makes it inaccessible from outside the container. To fix this, modify the `CMD` instruction in your Dockerfile to make Flask listen on all available interfaces:
     ```dockerfile
     CMD ["flask", "run", "--host=0.0.0.0"]
     ```
     This change allows external connections to reach the Flask server.

2. **MySQL Initialization Script Not Running**:
   - **Issue**: The custom SQL script (`init.sql`) is not being executed when the container starts.
   - **Solution**: Make sure that the `init.sql` script is copied to the correct directory (`/docker-entrypoint-initdb.d/`) and that it has the correct permissions. The MySQL image will automatically run scripts located in this directory during the initialization process.

