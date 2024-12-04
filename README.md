# Real-Time Video Streaming to Azure Blob Storage
This project enables real-time video streaming from an iOS device to Azure Blob Storage using Swift. The application captures video using the device camera, processes frames in real-time, and streams them to an append blob in Azure Blob Storage without intermediate file storage.

## Features
- **Real-Time Video Capture**: Uses the AVCaptureSession to capture video from the device's camera.
- **Azure Blob Storage Integration**: Streams video data directly to Azure Blob Storage using SAS (Shared Access Signature) URL.
- **Chunked Uploads**: Splits video data into chunks to efficiently upload to an append blob.

## Prerequisites
1. **Azure Storage Account**:
    - Ensure you have an Azure Storage Account.
    - Create a container in the storage account to hold the video blob.
2. **SAS URL**:
    - Generate a SAS URL for an append blob with appropriate permissions (acw - Add, Create, Write).
3. **Development Environment**:
    - Xcode 14+.
    - Swift 5+.
    - iOS 14+ target device.

## Setup and Configuration
1. Clone the repository:

```bash
git clone https://github.com/devni-heraliyawala/live-streamer.git
cd live-streamer
```
2. Open the project in Xcode:

```bash

open LiveStreamer.xcodeproj
```

3. Configure the SAS URL:
    - Open `VideoStreamManager.swift`.
    - Replace the `sasUrl` variable with your SAS URL:
```swift
private var sasUrl = "https://<your-storage-account>.blob.core.windows.net/<your-container>/<your-blob-name>?<sas-token>"
```
4. Build and run the project on a physical iOS device (video capture is not supported on simulators).

## Project Structure
* VideoStreamManager.swift:
    * Manages the video capture session.
    * Handles frame processing and real-time streaming to Azure Blob Storage.
* Main.storyboard:
    * Basic UI for starting and stopping the video stream.
* AppDelegate.swift / SceneDelegate.swift:
    * Handles application lifecycle events.

## How It Works
1. **Video Capture**:
    * The app initializes an `AVCaptureSession` to capture video frames from the camera.
2. **Frame Processing**:
    * Frames are encoded into JPEG format and buffered.
3. **Chunked Upload**:
    * Once the buffer reaches a specific size (e.g., 256 KB), it is uploaded to Azure Blob Storage as a chunk using the `PUT` method with the `comp=appendblock` query parameter.
4. **Real-Time Stream**:
    * Frames are processed at consistent intervals to ensure a smooth streaming experience.

## Key Points
### Azure Blob Storage Configuration
* Ensure the blob is created as an Append Blob.
* Verify the SAS URL has the required permissions (acw).
* Check the blob container's CORS policy to allow requests from the app if needed.

### Performance Optimization
* Chunk size is set to `256 KB` for efficient network usage. Adjust as necessary based on your requirements.
Frames are processed at intervals to reduce CPU and memory usage.

### Error Handling
* Handles errors such as network failures and Azure authentication errors gracefully.
* Logs errors for debugging and retries failed uploads.

## Usage
1.  Launch the app on an iOS device.
2. Grant camera permissions.
3. Start streaming by tapping the "**Start Streaming**" button.
4. Video will be streamed to the specified Azure Blob Storage in real time.
5. Stop streaming by tapping the "**Stop Streaming**" button.

## Limitations
* Real-time streaming requires a stable internet connection.
* Ensure the Azure Blob Storage SAS token is valid for the duration of the session.
* The app currently supports video data but does not include audio.

## Future Enhancements
* Add support for audio streaming.
* Implement adaptive bitrate streaming for varying network conditions.
* Enhance error recovery mechanisms for improved reliability.

## License
This project is licensed under the MIT License. See the `LICENSE` file for more details.

