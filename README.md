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

4. **Running with Fastlane (Local Pipeline Test)**:
   This project uses [Fastlane](https://fastlane.tools) to automate building and signing.

   **Prerequisites**:
   - Ruby (Recommended: use `rbenv` or `rvm` to match `.ruby-version` if present)
   - Bundler: `gem install bundler`

   **Setup**:
   ```bash
   bundle install
   ```

   **Run Build Command (Build + Archive)**:
   ```bash
   bundle exec fastlane build_only
   ```
   *Note: This will use your local certificates. If you want to test the full CI flow, you may need read access to the certificates repo.*

### Versioning

### Versioning

*   **Build Number** (`CFBundleVersion`): **Automatic**. The pipeline sets this based on the Azure DevOps Build ID.
*   **App Version** (`Marketing Version`): **Manual**. You must increment this in the Xcode **General** settings when you release a new version (e.g., `1.0` -> `1.1`).


### Signing Strategy

The project uses a **Hybrid Signing** approach to balance developer experience with CI security:

*   **Local Development (Debug)**: Uses **Automatic Signing**. You can run the app on simulators or your own device using your personal Apple ID/Team. No manual certificate installation is required.
*   **CI / Release**: Uses **Manual Signing** managed by [Fastlane Match](https://docs.fastlane.tools/actions/match/). Encrypted certificates and provisioning profiles are stored in a private git repository and injected securely during the Azure DevOps build.


---

## DevOps & CI/CD

The project uses Azure DevOps for Continuous Integration and Deployment.

### Pipeline Overview

- **Trigger**: Pushes to `main` branch.
- **Agent**: `macOS-latest`
- **Artifacts**: Produces an `.ipa` file.

### Key Pipeline Steps

1.  **Signing**: `fastlane match` securely fetches encrypted certificates from the private repository.
2.  **Build**: `fastlane gym` builds and signs the IPA artifact.
3.  **Deployment**: Uploads to TestFlight on `main` builds.
    *   **Note**: Deployment is **paused** by default. You must approve the release in the **Azure DevOps Environment** check.

### Troubleshooting Builds

- **"Duplicate Build" Error**: The pipeline automatically handles build numbers using the Azure DevOps Build ID. If this error occurs, check if the `CURRENT_PROJECT_VERSION` override in the pipeline is functioning correctly.
- **"Invalid Pre-Release Train"**: See the [Versioning](#versioning) section above.

## License

Licensed under the [MIT license](LICENSE)
