# Start from the thyrlian/android-sdk base image
FROM ubuntu:22.04

# Ensure python3 and pip are installed (thyrlian usually has them, but good to ensure)
RUN apt-get update && apt-get install -y python3 python3-pip curl && rm -rf /var/lib/apt/lists/*

# Set WORKDIR for our application files
WORKDIR /app

# Copy application requirements
COPY requirements.txt .

# Install Python dependencies
# Removed --break-system-packages for broader pip compatibility
RUN pip install --no-cache-dir -r requirements.txt
# Create symbolic links for mitmproxy executables to be in a standard PATH location
# This ensures that 'mitmproxy' and 'mitmdump' can be found and executed directly.
RUN ln -s $(find / -name mitmproxy -type f -executable 2>/dev/null | head -n 1) /usr/bin/mitmproxy && \
    ln -s $(find / -name mitmdump -type f -executable 2>/dev/null | head -n 1) /usr/bin/mitmdump

# Copy test script
COPY test_vulnerability.py .

# --- Android SDK Configuration for robust installation ---
# thyrlian/android-sdk usually has ANDROID_SDK_ROOT set to /opt/android-sdk and sdkmanager in PATH.

# Explicitly accept Android SDK licenses (most robust method for thyrlian base)
# These UUIDs cover common Android SDK licenses.
# Assumes ANDROID_SDK_ROOT is correctly set by the base image (e.g., /opt/android-sdk)
RUN mkdir -p ${ANDROID_SDK_ROOT}/licenses \
    && echo "8933cc44-9fd0-4702-95cc-ac721bdc4b60" > ${ANDROID_SDK_ROOT}/licenses/android-sdk-license \
    && echo "84831b14-a957-49d0-881b-c19be05963f9" >> ${ANDROID_SDK_ROOT}/licenses/android-sdk-preview-license \
    && echo "84831b14-a957-49d0-881b-c19be05963f9" >> ${ANDROID_SDK_ROOT}/licenses/android-sdk-arm-dbt-license \
    && echo "50466750-df18-4900-8413-f42528d2279b" >> ${ANDROID_SDK_ROOT}/licenses/android-sdk-ext-license \
    && echo "d975f782-9322-416d-b3b4-f06b72a08990" >> ${ANDROID_SDK_ROOT}/licenses/google-gdk-license \
    && echo "e61e0e85-d8aa-4623-a55d-318e47451310" >> ${ANDROID_SDK_ROOT}/licenses/mips-android-sysimage-license \
    && echo "51c5048d-bf6a-4874-a90c-b02ae2e032b4" >> ${ANDROID_SDK_ROOT}/licenses/android-sdk-license-2 \
    && echo "336b6d27-4a00-4b13-a9d9-299f0f15c7e0" >> ${ANDROID_SDK_ROOT}/licenses/android-sdk-license-3 \
    && echo "android-googletv-license" > ${ANDROID_SDK_ROOT}/licenses/android-googletv-license

# Install Android SDK components incrementally for better caching and resilience
RUN sdkmanager "platforms;android-33"
RUN sdkmanager "system-images;android-33;google_apis;x86_64"
RUN sdkmanager "emulator"
RUN sdkmanager "platform-tools"

# Create an AVD (Android Virtual Device)
RUN echo "no" | avdmanager create avd --force -n "ironclad_avd" -k "system-images;android-33;google_apis;x86_64"

# Set the default command to run when the container starts
CMD ["/usr/bin/python3", "/app/test_vulnerability.py"]
