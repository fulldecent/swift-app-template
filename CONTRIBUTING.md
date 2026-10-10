# Contributing

All contributors are welcome. Please use issues and pull requests to contribute to the project. Commit messages use `fix:`, `feat:` or `BREAKING CHANGE:`. Release Please writes [CHANGELOG.md](CHANGELOG.md) from those messages. Confirm the build is [passing in GitHub Actions](https://github.com/fulldecent/swift-app-template/actions) before merging.

## Release process

A push to `main` runs the tests. When the App Store secrets are set, that push uploads the commit to TestFlight. Release Please opens a pull request for outstanding `fix:`, `feat:` and `BREAKING CHANGE:` commits. Merging that pull request submits the version for App Store review. Setup for that workflow is in [Releasing](README.md#releasing).

## Development

The commands CI runs are in [Testing](README.md#testing).

## Maintenance

Do this every month or so. The checklist is in [Maintenance](README.md#maintenance).
