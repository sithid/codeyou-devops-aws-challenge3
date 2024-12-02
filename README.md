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

     ENV SECRET_KEY

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

**Tasks for Students**:
1. **Write the Dockerfile**: Please write a Dockerfile that meets the requirements.
2. **Build and Run the Image**: Be sure you can build the image (`docker build -t custom-mysql .`) and run it (`docker run -d -p 3306:3306 custom-mysql`).
3. **Verify Initialization** *optional*: You can use the `MySQL` extension (extension ID is "cweijan.vscode-mysql-client2") in VSCode to connect to the MySQL server and verify that the database and tables from the `init.sql` script are correctly set up.
    - *optional* If you prefer doing things by command line then you can choose to install the mysql client in your terminal and connect to the container. This is left to your discretion to accomplish if you so choose. Message me after class if you need assistance with this.

**Requirements**:
1. **Name your Dockerfile**: Since you already have a dockerfile named `Dockerfile` you'll want to pick a different name for this one. Suggestion: `Dockerfile.mysql`
1. **Use an Official Base Image**: Start from `mysql:8.0`.
2. **Set Environment Variables**:
   - Set `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, and `MYSQL_PASSWORD` as environment variables.
   - These environment variables (a.k.a. envvars) can be set to anything you want, just be sure the values are lowercase, one word, and (for the sake of this task, preferably) don't have symbols.
3. **Add Custom Initialization Script**:
   - Copy a SQL script (`init.sql`) to the container to initialize the database with some tables and data.
4. **Expose the Database Port**: Expose port `3306`. This is the default port number for mysql.
5. **Command to Run**: Use the default MySQL command to start the server.
6. **Build your image**: Use `docker image build ...` and investigate which option will allow you to specify the name of the dockerfile that you want to build an image from. By default docker looks at: `"PATH/Dockerfile"`. When you build your image you'll need to pass in the `Dockerfile.mysql` (or whatever you named it) to the option you found.

**Hints**:
- **MySQL Command**: If you're interested in the CMD that image `mysql:9` runs by default then you can find the image [here in dockerhub](https://hub.docker.com/_/mysql). You can then go to `Tags` for that image and find the tag `9`. This will show you effectively the Dockerfile for this image, the last CMD statement in the layers for this image is the one that will run by default.
- **Environment Variables** (`ENV`): When we use the `ENV <some variable name>` keyword we are stating to Docker that there should be an environment variable setup at this point in the image build process. We can also set a default value that can be overridden at the command line by doing `ENV SOME_VARIABLE="some default value"`
- **Initialization Script**: Use `COPY` to place the `init.sql` script in the appropriate directory (`/docker-entrypoint-initdb.d/`) so it runs automatically when the container starts.

**BONUS**:
- **Background**: There is a path location specified in the image layers for the `mysql:9` image by the `VOLUME` keyword. This location is used by the mysqld server to store all the database information, i.e. database files, tables, etc. Currently in our implementation this data is volatile, meaning that if we rebuild the container then we've lost all that data. This behavior is, of course, undesirable.
- **Task**: Investigate the `docker run` command to see which options we can use to make a volume that mounts the location specified in the image layers by the `VOLUME` statement.


**Wrap-Up Discussion**:
- **Review Key Concepts**: What parts of this challenge were the most difficult for you, e.g. like setting environment variables or understanding how `COPY` works?
- **Q&A**: Open the floor for any remaining questions.



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

