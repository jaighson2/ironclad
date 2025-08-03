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
