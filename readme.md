Psen
====

Psen provides convention-based and out-of-the-box builds, tests, installations and deployments for .NET projects.

Features
--------
* Builds solution
* Runs tests
* Packages supported project types
* Mounts websites
* Overridable properties
* Customizable publish method
* FTP synchronization (psake_ext.ps1/SynchronizeFoldersViaFtp)

Prerequisites
-------------
* nuget installed in `[SolutionRoot]\.nuget` and committed to version control

Installation
------------
* From command-line: `[SolutionRoot]\.nuget\nuget.exe install psen` or from Visual Studio Package Manager Console: `Install-Package psen`
* Copy `[SolutionRoot]\packages\psen.[version]\tools\build.ps1` to `[SolutionRoot]\build.ps1`
* Commit `[SolutionRoot]\build.ps1` to version control

Usage
-----
* Run `[SolutionRoot]\build.ps1`

Standard layout
---------------
* Visual Studio solution file located in root folder: `[SolutionRoot]\*.sln`
* Visual Studio projects located in `src` folder: `[SolutionRoot]\src\Me.MyProduct.Web\Me.MyProduct.Web.csproj`
* Visual Studio NUnit test projects located in `test` folder: `[SolutionRoot]\test\Me.MyProduct.Tests\Me.MyProduct.Tests.csproj`

Supported project types
-----------------------
* Web applications named like `*.Web`
* NUnit test projects named like `*.Tests`

Misc
----
* Psen is pronounced like 'Zen'
* Psen uses psake