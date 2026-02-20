# DEMO LG Controller

**A Flutter-based Liquid Galaxy Controller Application.**

This application serves as a comprehensive controller for a Liquid Galaxy rig, demonstrating the power of the **LG Flutter Starter Kit** combined with **AI-driven development (Agentic Coding)**.

##  Features

*   **Connectivity Management**: Secure SSH connection to the Liquid Galaxy Master node.
*   **Logo Management**: 
    -   **Send Logo**: Uploads and displays the Liquid Galaxy logo on the screens (works offline via local network).
    -   **Clean Logo**: Instantly removes any overlay.
    -   **Clean KMLs**: Clears all KMLs and resets the view.
*   **Visualization**:
    -   **Send Pyramid**: Generates a massive 3D Pyramid structure (5km height) near Lleida, Spain.
    -   **FlyTo**: Automatically moves the camera to key locations.
    -   **Weather Visualization**: Fetches real-time weather data for a city (e.g., Lleida) and displays it as a styled HTML placemark.
    -   **Custom Placemarks**: Create and send custom KML placemarks.
*   **System Control**:
    -   **Reboot LG**: Remotely reboots the entire Liquid Galaxy rig (Master + Slaves).

##  How It Was Made

This project was built using the **LG Flutter Starter Kit** as a foundation and rapidly developed using **AI Agents**.

### Key Components

1.  **Architecture**:
    -   **Services**: `LGService` (Business Logic), `SSHService` (Communication), `KMLService` (KML Generation), `WeatherService` (API).
    -   **State Management**: `Provider` architecture for reactive UI updates.
    -   **UI**: Material Design 3 interfaces.

2.  **API Integrations**:
    -   **OpenWeatherMap API**: Used to fetch real-time weather data (`WeatherService`).
    -   **SSH (dartssh2)**: Used for all communication with the Liquid Galaxy rig (executing commands, uploading files via SFTP).

3.  **Agentic Workflow**:
    -   **Planning**: AI analyzed requirements and created implementation plans.
    -   **Execution**: Code was generated, debugged, and refined by AI agents.
    -   **Verification**: Automated build tools and manual verification steps ensured quality.

##  Usage

1.  **Download**: Get the latest APK directly from the repo: [Download APK](./release/DEMO_LG_Controller.apk).
2.  **Install**: Install the APK on your Android tablet/phone.
3.  **Connect**:
    -   Tap the **Settings** icon.
    -   Enter your Rig's Master IP (e.g., `192.168.0.10`) and credentials.
    -   Tap **Connect**.
4.  **Control**: Use the buttons on the main screen to interact with the rig.

##  LG Flutter Starter Kit

This project demonstrates how easily the **LG Flutter Starter Kit** can be extended. The kit provides:
-   Pre-configured SSH logic.
-   KML generation utilities.
-   Basic UI scaffolding.
-   Connection management.

By leveraging these pre-built components, we focused on building **features** rather than boilerplate.

## 📄 License
MIT License
