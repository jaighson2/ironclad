# Use a pre-configured, stable base image with the Android SDK.
# This eliminates all environment and PATH-related failures.
FROM thyrlian/android-sdk:latest

# Install Python 3 and the pip package manager
RUN apt-get update && apt-get install -y python3 python3-pip

# Set the working directory inside the container
WORKDIR /app

# Copy the Python requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --break-system-packages -r requirements.txt

# Copy the test script into the working directory
COPY test_vulnerability.py .

# Use the SDK manager to accept licenses and install the required system image and emulator.
RUN yes | sdkmanager "platforms;android-33" "system-images;android-33;google_apis;x86_64" "emulator" "platform-tools"

# Create the Android Virtual Device (AVD) that the test script will use.
RUN echo "no" | avdmanager create avd --force -n "ironclad_avd" -k "system-images;android-33;google_apis;x86_64"

# Set the default command to run the test script.
CMD ["pytest", "-v", "test_vulnerability.py"]
