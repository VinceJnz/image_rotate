

1. Create a Dockerfile

Here’s an example Dockerfile to set up a cross-compilation environment for Windows using mingw-w64 and OpenCV:


2. Build the Docker Image

Save the Dockerfile in the same directory as your rotate_video.cpp file. Then, clear build cache, then build the Docker image:

`docker builder prune`

`docker build -t opencv-windows-compiler .`


3. Run the Docker Container

If you want to keep the container running after exiting, start it in detached mode and mount the current folder to /src:
`docker run -dit -v ${PWD}:/src --name opencv-compiler  opencv-mingw-compiler /bin/bash`

You can reconnect to it later using:
`docker exec -it opencv-compiler /bin/bash`

When you're done, you can stop the container:
`docker stop <CONTAINER ID or NAME>`
`docker stop opencv-compiler`

This will compile your rotate_video.cpp file into a Windows binary (rotate_video.exe) and save it in your current docker directory.
`x86_64-w64-mingw32-g++ -o rotate_video.exe rotate_video.cpp -std=c++11 -I/usr/local/include/opencv4 -L/usr/local/lib -lopencv_core4120 -lopencv_videoio4120 -lopencv_highgui4120 -lopencv_imgproc4120 -lopencv_imgcodecs4120`


4. Transfer the Binary to Windows

After the compilation, you can transfer the rotate_video.exe file to your Windows machine and run it.

5. Notes

Cross-Compilation: The mingw-w64 toolchain is used to cross-compile the code for Windows.
OpenCV Configuration: The CMAKE_TOOLCHAIN_FILE is set to use the MinGW toolchain for Windows.
Dependencies: Ensure that the compiled binary includes all necessary OpenCV libraries. You may need to distribute the .dll files with the executable.




file *.dll
file rotate_video.exe

ldd rotate_video.exe

