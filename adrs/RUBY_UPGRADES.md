# SLNSW Amplify Rails 8 and Ruby 3.4 Upgrade Plan

This document outlines the steps, estimates, and considerations for upgrading the application from Rails 7 to Rails 8.

---

## 1. Pre-Upgrade Checklist
- [ ] Review the [Rails 8 Release Notes](https://guides.rubyonrails.org/8_0_release_notes.html).
- [ ] Ensure all dependencies are compatible with Rails 8.
- [ ] Run the application’s test suite to ensure a clean baseline.
- [ ] **Upgrade Ruby to version 3.4.2 (post Rails 8 upgrade).**
- [ ] Identify and address incompatible gems:
  - `acts-as-taggable-on` (upgrade to 12.0.0).
  - `font-awesome-rails` (upgrade to 4.7.0.9).
  - Consider replacing `sqlite3` due to incompatibility with Ruby 3.4.

---

## 2. Upgrade Steps and Estimates

### Step 0: Update Dependencies
- **Description**: Update the `Gemfile` to use Rails 8 and ensure all gems are compatible.
- **Estimated Time**: 12-18 hours
- **Tasks**:
  - Upgrade `acts-as-taggable-on` to version 12.0.0.
  - Upgrade `font-awesome-rails` to version 4.7.0.9.
  - Replace `sqlite3` with a compatible database gem or remove it if not needed.
  - Run `bundle update` and resolve any dependency conflicts.
  - Test the application to ensure all dependencies work as expected.

---

### Step 1: Update Configuration Files
- **Description**: Update configuration files to match Rails 8 defaults.
- **Estimated Time**: 6-8 hours
- **Tasks**:
  - Run `rails app:update` and review changes.
  - Manually merge configuration changes if necessary.

---

### Step 2: Address Deprecations
- **Description**: Identify and resolve deprecations in the codebase.
- **Estimated Time**: 10-12 hours
- **Tasks**:
  - Review the 9 deprecation warnings in the codebase.
  - Resolve warnings related to `RSpec::Mocks.configuration.allow_message_expectations_on_nil`.
  - Address the `unknown OID 2249` warning.
  - Update code to remove deprecated methods or features.

---

### Step 3: Update Tests
- **Description**: Update and fix tests to ensure compatibility with Rails 8.
- **Estimated Time**: 12-16 hours
- **Tasks**:
  - Update test helpers and configurations.
  - Fix any failing tests caused by the upgrade.
  - Ensure all deprecation warnings in tests are resolved.

---

### Step 4: Perform Manual Testing
- **Description**: Conduct manual testing to ensure the application works as expected.
- **Estimated Time**: 6-8 hours
- **Tasks**:
  - Test critical workflows and features.
  - Verify UI and API functionality.

---

### Step 5: Deployment and Monitoring
- **Description**: Deploy the upgraded application and monitor for issues.
- **Estimated Time**: 3-5 hours
- **Tasks**:
  - Deploy to staging and production environments.
  - Monitor logs and performance metrics.

---

### Step 6: Upgrade Ruby to 3.4.2
- **Description**: Upgrade the Ruby version to 3.4.2 after the Rails 8 upgrade.
- **Estimated Time**: 10-14 hours
- **Tasks**:
  - Update the Ruby version in `.ruby-version` and `Gemfile`.
  - Replace or remove `sqlite3` due to incompatibility with Ruby 3.4.
  - Ensure all gems are compatible with Ruby 3.4.2.
  - Run the application and resolve any compatibility issues.
  - Update CI/CD pipelines to use Ruby 3.4.2.
  - Run the test suite to ensure everything works as expected.

---

## 3. Risks and Mitigation
- **Risk**: Incompatible gems or dependencies.
  - **Mitigation**: Research and test gem updates before upgrading.
- **Risk**: Breaking changes in Rails 8 or Ruby 3.4.2.
  - **Mitigation**: Review release notes and test thoroughly.
- **Risk**: Deprecation warnings causing runtime issues.
  - **Mitigation**: Address all deprecation warnings during the upgrade process.

---

## 4. Estimated Total Time
**Total Estimated Time**: ~60-80 hours

---

## 5. Notes
- Keep a backup of the current application before starting the upgrade.
- Document any issues encountered during the upgrade process.

---

## Why I Come Up with This Estimate?

The estimate is based on the following factors:

1. **Outdated Gems**:
   - 189 out of 286 gems (66%) are outdated, requiring updates and compatibility checks.
   - This includes resolving dependency conflicts and testing the application after updates.

2. **Incompatible Gems**:
   - Two gems are incompatible with Rails 8:
     - `acts-as-taggable-on` (requires upgrade to 12.0.0).
     - `font-awesome-rails` (requires upgrade to 4.7.0.9).
   - One gem (`sqlite3`) is incompatible with Ruby 3.4 and may need to be replaced or removed.

3. **Deprecation Warnings**:
   - There are 9 deprecation warnings in the codebase that need to be addressed, including:
     - `RSpec::Mocks.configuration.allow_message_expectations_on_nil`.
     - `unknown OID 2249` warning.
   - Resolving these warnings will require code updates and testing.

4. **Testing Effort**:
   - Updating test helpers and configurations to ensure compatibility with Rails 8.
   - Fixing failing tests caused by the upgrade.
   - Conducting manual testing to verify critical workflows and features.

5. **Configuration Updates**:
   - Updating configuration files to match Rails 8 defaults using `rails app:update`.
   - Manually merging changes where necessary.

6. **Deployment and Monitoring**:
   - Deploying the upgraded application to staging and production environments.
   - Monitoring logs and performance metrics to ensure stability.

7. **Ruby Upgrade**:
   - Upgrading Ruby to version 3.4.2 after the Rails 8 upgrade.
   - Replacing or removing incompatible gems like `sqlite3`.
   - Ensuring all gems are compatible with Ruby 3.4.2 and resolving any issues.

Each step has been carefully estimated based on the complexity of the tasks, the number of dependencies, and the time required for thorough testing and validation.

