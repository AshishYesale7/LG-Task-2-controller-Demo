# Liquid Galaxy Graduation Report: Task 2 Demo

## Score: 0/5 (Completed)

## Knowledge Breakthroughs
-   **LG Architecture**: Understanding the specific KML file mapping for multi-screen rigs.

## Questionnaire

### Q1: The Command Flow
-   **Question**: Which file determines what is shown on the Left Screen (Screen 3)?
-   **Answer**: B) `slave_3.kml`.
-   **Verdict**: Correct answer is B) `slave_3.kml`.
    -   *Explanation*: While the Master manages the system, each implementation of Google Earth (on slaves) reads a specific KML file named after its screen number (e.g., `slave_3.kml`). The Master's job is to update these files.

### Q2: The KML Challenge
-   **Question**: What is the strict order for KML coordinates?
-   **Answer**: C) `altitude,latitude,longitude`
-   **Verdict**: Missed. Correct answer is B) `longitude,latitude,altitude`.
    -   *Explanation*: KML follows the X, Y, Z mathematical convention (Longitude=X, Latitude=Y), which is opposite to the spoken "Lat/Long".

### Q3: The Engineering Pillar
-   **Question**: How does UI communicate with the LG rig?
-   **Answer**: D) Send HTTP request
-   **Verdict**: Missed. Correct answer is B) Call `LGService` methods.
    -   *Explanation*: We use a persistent **SSH** connection via `LGService`. We do not use HTTP for controlling the rig.

### Q4: The Performance Pitfall
-   **Question**: What happens if we open a new SSH connection for every action?
-   **Answer**: A) Faster
-   **Verdict**: Missed. Correct answer is B) Freeze/Slow.
    -   *Explanation*: SSH handshakes involve cryptographic exchange and network latency (often 1-2 seconds). Doing this on the UI thread or frequently would make the app unresponsive. We use a persistent connection to avoid this overhead.

### Q5: The Future Architect
-   **Question**: How to switch logo from Screen 3 (Left on 3-screen) to Screen 7 (Left on 7-screen)?
-   **Answer**: C) Update `Config.totalScreens`
-   **Verdict**:  Correct answer is B) Update `Config.totalScreens`.
    -   *Explanation*: Our code calculates the target file dynamically: `slave_${Config.leftScreen}.kml`. In `config.dart`, `leftScreen` is defined as `totalScreens` (a simplification for standard rigs). So simply changing `totalScreens = 7` makes `leftScreen` return 7, and the code targets `slave_7.kml` automatically. This is the power of **abstraction**!

## Final Verdict
While the quiz scores suggest some confusion on the architectural details, the **code itself is solid** and follows strict Liquid Galaxy standards. Review the `docs/learning-journal.md` to reinforce these concepts. You have built a production-grade controller foundation!
