Psen
====

Psen provides convention-based and out-of-the-box builds, tests, installations and deployments for .NET projects.

Features
--------
* Builds solution
* Runs tests
* Packages supported project types
* Mounts websites

Prerequisites
-------------
* nuget installed in `[SolutionRoot]\.nuget` and committed to version control

Installation
------------
* From command-line: `.nuget\nuget.exe install psen` or from Visual Studio: `Install-Package psen`.
* Copy `[SolutionRoot]\packages\psen.[version]\tools\build.ps1` to `[SolutionRoot]`.
* Commit `.\build.ps1` to version control

Usage
-----
* Run `.\build.ps1`

Standard layout
---------------
* Visual Studio solution file: `[SolutionRoot]\*.sln`
* Visual Studio projects located here: `[SolutionRoot]\src\Me.MyProduct.Web\Me.MyProduct.Web.csproj`

Supported project types
-----------------------
* Web applications named like `*.Web`
* NUnit test projects named like `*.Tests`

Misc
----
* Psen is pronounced like 'Zen'.
* Psen uses psake.