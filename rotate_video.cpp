#include <opencv2/opencv.hpp>
#include <iostream>
#include <string>

int main(int argc, char** argv) {
    // Check for command-line arguments
    if (argc != 4) {
        std::cerr << "Usage: " << argv[0] << " <input_video> <output_video> <angle (90, 180, 270)>" << std::endl;
        return -1;
    }

    std::string inputPath = argv[1];
    std::string outputPath = argv[2];
    int angle = std::stoi(argv[3]);

    // Validate rotation angle
    if (angle != 90 && angle != 180 && angle != 270) {
        std::cerr << "Invalid rotation angle. Allowed values are 90, 180, or 270." << std::endl;
        return -1;
    }

    // Open the input video
    std::cout << "Trying to open file: " << inputPath << std::endl;
    cv::VideoCapture video(inputPath);
    if (!video.isOpened()) {
        std::cerr << "Error: Could not open input video file: " << inputPath << std::endl;
        return -1;
    }

    // Get video properties
    int width = static_cast<int>(video.get(cv::CAP_PROP_FRAME_WIDTH));
    int height = static_cast<int>(video.get(cv::CAP_PROP_FRAME_HEIGHT));
    double fps = video.get(cv::CAP_PROP_FPS);
    int fourcc = static_cast<int>(video.get(cv::CAP_PROP_FOURCC));

    // Adjust width and height for 90 or 270-degree rotation
    if (angle == 90 || angle == 270) {
        std::swap(width, height);
    }

    // Create a video writer
    cv::VideoWriter writer(outputPath, fourcc, fps, cv::Size(width, height));
    if (!writer.isOpened()) {
        std::cerr << "Error: Could not open output video file: " << outputPath << std::endl;
        return -1;
    }

    cv::Mat frame, rotatedFrame;

    // Process each frame
    while (true) {
        video >> frame;
        if (frame.empty()) {
            break;
        }

        // Rotate the frame
        if (angle == 90) {
            cv::rotate(frame, rotatedFrame, cv::ROTATE_90_CLOCKWISE);
        } else if (angle == 180) {
            cv::rotate(frame, rotatedFrame, cv::ROTATE_180);
        } else if (angle == 270) {
            cv::rotate(frame, rotatedFrame, cv::ROTATE_90_COUNTERCLOCKWISE);
        }

        // Write the rotated frame to the output video
        writer.write(rotatedFrame);
    }

    std::cout << "Video rotated by " << angle << " degrees and saved to " << outputPath << std::endl;

    return 0;
}