# Use an Ubuntu base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CC=/usr/bin/x86_64-w64-mingw32-gcc
ENV CXX=/usr/bin/x86_64-w64-mingw32-g++

# Install required tools and dependencies
RUN apt-get update --fix-missing && apt-get install -y \
    build-essential \
    cmake \
    git \
    mingw-w64 \
    pkg-config \
    wget \
    unzip \
    make \
    ninja-build \
    && apt-get clean && \
    update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix && \
    update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

# Build OpenCV from source
RUN rm -rf /opencv && mkdir -p /opencv && cd /opencv && \
    git clone https://github.com/opencv/opencv.git && \
    git clone https://github.com/opencv/opencv_contrib.git

# Copy the toolchain file into the container
COPY opencv_toolchain/mingw-w64-x86_64.cmake /opencv/opencv/platforms/win32/mingw-w64-x86_64.cmake

    #mkdir -p /opencv/opencv/platforms/win32 && \
    #cp /app/opencv_toolchain/mingw-w64-x86_64.cmake /opencv/opencv/platforms/win32 && \
RUN mkdir -p /opencv/opencv/build && cd /opencv/opencv/build && \
    cmake -G "Ninja" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DCMAKE_TOOLCHAIN_FILE=/opencv/opencv/platforms/win32/mingw-w64-x86_64.cmake \
          -DCMAKE_SYSTEM_NAME=Windows \
          -DOPENCV_EXTRA_MODULES_PATH=/opencv/opencv_contrib/modules \
          -DCMAKE_MAKE_PROGRAM=/usr/bin/ninja \
          -DWITH_OPENEXR=OFF \
          -DWITH_FFMPEG=ON \
          #-DBUILD_SHARED_LIBS=OFF \
          .. && \
    ninja && ninja install

# Set working directory
WORKDIR /app

# Copy your source code into the container
COPY . /app

# Compile the C++ code to a Windows binary
RUN cd /app && \
    chmod +x cp2src && \
    x86_64-w64-mingw32-g++ -o rotate_video.exe rotate_video.cpp -std=c++11 -I/usr/local/include/opencv4 -L/usr/local/lib -lopencv_core4120 -lopencv_videoio4120 -lopencv_highgui4120 -lopencv_imgproc4120 -lopencv_imgcodecs4120

# copy the exe and dlls to the src folder
RUN if [ -d "/src" ]; then \
        echo "/src exists. Proceeding with file copy..."; \
        cp /app/rotate_video.exe /src/ && \
        cp /usr/local/bin/libopencv_core4120.dll /src/ && \
        cp /usr/local/bin/libopencv_videoio4120.dll /src/ && \
        cp /usr/local/bin/libopencv_highgui4120.dll /src/ && \
        cp /usr/local/bin/libopencv_imgproc4120.dll /src/ && \
        cp /usr/local/bin/libopencv_imgcodecs4120.dll /src/ && \
        cp /usr/lib/gcc/x86_64-w64-mingw32/9.3-posix/libstdc++-6.dll /src/ && \
        cp /usr/lib/gcc/x86_64-w64-mingw32/9.3-posix/libgcc_s_seh-1.dll /src/ && \
        cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll /src/ \
        # openh264-1.8.0-win64.dll this comes from cisco https://github.com/cisco/openh264/releases/tag/v1.8.0 \
    else \
        echo "Error: /src does not exist. Exiting."; \
        exit 1; \
    fi