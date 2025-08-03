# Start from the ubuntu:22.04 base image for full control
FROM ubuntu:22.04

# Set environment variables for Android SDK
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV PATH="$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator"

# Set DEBIAN_FRONTEND to noninteractive to prevent all interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install core system dependencies, Java, Python, and other tools
RUN apt-get update && apt-get install -y \
    openjdk-17-jre \
    wget \
    unzip \
    curl \
    sudo \
    python3 \
    python3-pip \
    python3-full \
    git \
    iproute2 \
    net-tools \
    libstdc++6 \
    libncurses5 \
    libusb-1.0-0 \
    qemu-kvm \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir --break-system-packages mitmproxy pytest requests

# Download and install Android SDK Command-line Tools
ARG SDK_TOOLS_VERSION=11076708
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS_VERSION}_latest.zip -O /tmp/commandlinetools-linux.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && unzip /tmp/commandlinetools-linux.zip -d /tmp/android_extract \
    && mv /tmp/android_extract/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ \
    && rm -rf /tmp/android_extract /tmp/commandlinetools-linux.zip

# Create symbolic links for mitmproxy so it's in the system PATH
RUN PYTHON_SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[0])") && \
    ln -s ${PYTHON_SITE_PACKAGES}/mitmproxy/mitmproxy /usr/bin/mitmproxy && \
    ln -s ${PYTHON_SITE_PACKAGES}/mitmproxy/mitmdump /usr/bin/mitmdump

# Explicitly accept Android SDK licenses by creating the license files
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

# Install Android SDK components
RUN sdkmanager "platforms;android-33" "system-images;android-33;google_apis;x86_64" "emulator" "platform-tools"

# Create a non-root user for running the emulator
RUN useradd -ms /bin/bash androiduser && echo "androiduser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/androiduser
USER androiduser
WORKDIR /home/androiduser/work

# Create an AVD (Android Virtual Device)
RUN echo "no" | avdmanager create avd -n test_avd -k "system-images;android-33;google_apis;x86_64"

# Copy all necessary files into the container
COPY 1Password.apk ./
COPY test_vulnerability.py ./
COPY entrypoint.sh ./

# Make the entrypoint script executable
RUN sudo chmod +x entrypoint.sh

# Set the entrypoint script as the default command
CMD ["./entrypoint.sh"]

