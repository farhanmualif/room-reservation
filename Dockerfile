# Menggunakan Flutter image sebagai base
FROM ghcr.io/cirruslabs/flutter:stable

# Install adb (Android Debug Bridge) dan platform-tools
RUN apt-get update && apt-get install -y android-tools-adb android-sdk-platform-tools cmake g++ ninja-build

# Buat user non-root
RUN useradd -ms /bin/bash developer

# Set working directory
WORKDIR /home/developer/app

# Salin seluruh proyek ke dalam container
COPY --chown=developer:developer . .

# Ubah kepemilikan direktori Flutter SDK dan app
RUN chown -R developer:developer /sdks/flutter /home/developer/app

# Ganti ke user non-root
USER developer

# Periksa versi Flutter
RUN flutter --version

# Jalankan pub get untuk mengunduh dependencies
RUN flutter pub get

# Jalankan flutter doctor untuk memastikan semua dependencies terinstal
RUN flutter doctor

# Connect to the physical Android device wirelessly using ADB
RUN adb connect 192.168.1.3:5555

# Wait for the device to connect
RUN sleep 10

# List all connected devices
RUN flutter devices

# Get the device ID of the first device in the list
RUN DEVICE_ID=$(flutter devices | head -n 1 | awk '{print $1}')

# Set the CMAKE_MAKE_PROGRAM environment variable
ENV CMAKE_MAKE_PROGRAM=/usr/bin/ninja

# Set the CMAKE_CXX_COMPILER environment variable
ENV CMAKE_CXX_COMPILER=/usr/bin/g++

# Run the Flutter app on the physical device
RUN flutter run -d "$DEVICE_ID" --verbose

# Expose port untuk menjalankan aplikasi
EXPOSE 8080

# Buat script untuk menjalankan Flutter
RUN echo '#!/bin/sh\n\
flutter run -d $DEVICE_ID' > /home/developer/app/run.sh && \
    chmod +x /home/developer/app/run.sh

# Perintah default untuk menjalankan flutter di Android device
CMD ["/bin/sh", "/home/developer/app/run.sh"]