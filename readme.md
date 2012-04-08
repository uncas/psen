Psen provides convention-based and out-of-the-box builds, tests, installations and deployments for .NET projects.

Prerequisites:
- nuget installed in [SolutionRoot]\.nuget and committed to version control

Install steps:
- From command-line: '.nuget\nuget.exe install psen' or from VS: 'Install-Package psen'.
- Copy [SolutionRoot]\packages\psen.[version]\tools\build.ps1 to [SolutionRoot].
- Commit .\build.ps1 to version control

Usage:
- Run .\build.ps1

Psen assumes a standard layout:
- VS solution file: [ProjectRoot]\*.sln
- VS projects located here: [ProjectRoot]\src\MyProject\MyProject.csproj
- NUnit test projects named like *.Tests
- Supported project types:
-- Web applications named like *.Web.

Features:
- Builds solution
- Runs tests
- Packages supported project types
- Mounts websites

Misc:
- Psen is pronounced like 'Zen'.
- Psen uses psake.