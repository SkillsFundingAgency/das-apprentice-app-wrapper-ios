![Build badge](https://sfa-gov-uk.visualstudio.com/_apis/public/build/definitions/c39e0c0b-7aff-4606-b160-3566f3bbce23/788/badge)

# Apprentice App iOS Wrapper

A native iOS wrapper application for the Apprenticeship Service.

## Developer Guide

### Prerequisites

- **Xcode**: Version 14.0 or later (Recommended)
- **Swift**: Version 5.0
- **macOS**: Ventura or later

### Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/SkillsFundingAgency/das-apprentice-app-wrapper-ios.git
   ```

2. **Open the project**:
   - Navigate to `src/My Apprenticeship App`
   - Open `My Apprenticeship App.xcodeproj`

3. **Run the App**:
   - Select a simulator or connected device.
   - Press `Cmd + R` to build and run.

### Versioning

The application version is managed manually in Xcode.

**Important**: If you encounter an `Invalid Pre-Release Train` error during the pipeline run, it means the current version has been closed in App Store Connect.

**To fix this:**
1. Check the current version in **App Store Connect** > **TestFlight** > **iOS Builds** (under the app name).
2. Open the project in Xcode.
3. Select the **My Apprenticeship App** target.
4. Increment the **Version** (Marketing Version) in the General tab (e.g., change `1.5` to `1.6`).
5. Commit and push the changes.

---

## DevOps & CI/CD

The project uses Azure DevOps for Continuous Integration and Deployment.

### Pipeline Overview

- **Trigger**: Pushes to `main` branch.
- **Agent**: `macOS-latest`
- **Artifacts**: Produces an `.ipa` file.

### Key Pipeline Steps

1. **Install Certificates**: Installs Apple Distribution Certificate.
2. **Install Provisioning Profile**: Installs App Store Provisioning Profile.
3. **Build & Sign**: Uses `xcodebuild` to archive and export the IPA.
   - **Export Method**: `app-store`
   - **Versioning**: Uses `$(Build.BuildId)` as the **Build Number** (CFBundleVersion), but relies on the project file for the **App Version** (CFBundleShortVersionString).
4. **Upload to TestFlight**: Automatically uploads successful builds to TestFlight (Only on `main` branch).

### Troubleshooting Builds

- **"Duplicate Build" Error**: The pipeline automatically handles build numbers using the Azure DevOps Build ID. If this error occurs, check if the `CURRENT_PROJECT_VERSION` override in the pipeline is functioning correctly.
- **"Invalid Pre-Release Train"**: See the [Versioning](#versioning) section above.

## License

Licensed under the [MIT license](LICENSE)
