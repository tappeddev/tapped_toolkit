# tapped toolkit 🧰

This repository is a collection of packages and best practices.


### App Setup Guide
TODO Describe how we setup apps using fvm, basic dependencies 

#### 1. Flutter version manager
TODO talk about fvm and how we set it up.
TODO research linking md files in other projects to avoid having duplicate code

#### 2. State managment
TODO talk about riverpod and other state managment solutions

#### 3. Dependency injection
TODO talk about how dependency injection can be done using riverpod

#### 4. Pipline stages
TODO talk about basic pipeline stages that every project needs. lint, format, test.

### Installing any of the packages included in tapped toolkit
Right now the packages are not published to pub and adding them is done using the `git` keyword.

TODO versioning? right now i added ref:stable
TODO check if path: packages/ is correct

````yaml
dependencies:
    # Installing all packages
    tapped_toolkit:
      git:
        url: https://github.com/tappeddev/tapped_toolkit.git
        ref: stable

    after_first_build:
      git:
        url: https://github.com/tappeddev/tapped_toolkit.git
        ref: stable
        path: packages/after_first_build
````
