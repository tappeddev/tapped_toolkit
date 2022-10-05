# tapped toolkit 🧰

This repository is a collection of packages and best practices.

### App Setup Guide

We like to keep our dependencies to a minimum and make as much use of the libraryies or packages that we install.
This guide will walk you through some of the packages and explain why we are using them.

#### 1. Flutter version manager

We are using [FVM (flutter version manager)]((https://github.com/leoafarias/fvm)) to ensures that every developer uses
the same flutter sdk.
FVM does a great job in managing your different flutter sdks and sharing them across your projects.

To install `fvm`:

1. Run `dart pub global activate fvm`
2. Run `fvm version` to check if the installation was successful.
3. Run `fvm install`. This will install the SDK and link it with the project. This link can be found
   in `.fvm/flutter_sdk`.
4. Run `fvm flutter doctor` to ensure your setup is correct.
5. If needed link the installed SDK with your IDE. See https://fvm.app/docs/getting_started/configuration

⚠️ If you already installed `fvm` but you can not find the `.fvm/flutter_sdk` link to the flutter sdk, you need to
call `fvm install`. You should now see `.fvm/flutter_sdk`.

More details here: https://fvm.app/docs/getting_started/overview

Please ensure that the sdk is set up correctly by calling `fvm flutter doctor`

#### 2. State managment

We use [Riverpod](https://riverpod.dev/) for state managment.
Riverpods provides all the tools we need to build different kinds of architectures for
different apps in a simple way.

#### 3. Dependency injection

As explained above, we are trying to keep our package dependencies to a minimum and that's why we also use Riverpod for
dependency injection.
We can override providers when creating a `ProviderContainer` and this gives us the ability to mock certain providers
in a test.

We might setup our provider strucutre like this:

```dart
// Here we have a simple service that is wrapped in a provider.
final provMyService = Provider<MyService>((ref) => MyServiceImpl());

final provHomeChangeNotifier = ChangeNotifierProvider((ref) {
  // Accessing dependencies is done like this.
  // Based on your use case you might use ref.watch().
  return HomeChangeNotifier(myService: ref.read(myService));
});
```

In a test scenario we can simply mock `MyService` like this:

````dart
void main() {
  test("example test", () {
    final container = ProviderContainer(
      overrides: [
        provMyService.overrideWithValue(MyServiceMock()),
      ],
    );

    final homeChangeNotifier = container.read(provHomeChangeNotifier);
  });
}
````

#### 4. Pipline stages

CI/CD is part of every application we build at tapped.
Independent of the platform executing the pipeline (mostly GitHub or GitLab) most projects configure the pipeline to
do 4 basics tasks that can be grouped in different stages.

##### 1. Linting/Analyze

Static code analysis will catch compile time errors and warnings.
It can be executed in the project directory by using `fvm flutter analyze`.

##### 2. Format

It's important to have a consistent formatting in every file. Especially widgets have bigger build methods that
suffer from readbility when reading changes in a diff.
Keeping a consistent formatting helps reading diffs and avoids arguing about code style.
Running the formatter in the pipeline can be done by executing `fvm flutter format --set-exit-if-changed`.

This will also reformat generated code. We can adjust our code to exclude generated code.
`find . -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -path '*/generated/*' ! -path '*/gen/*' | xargs fvm flutter format -n --set-exit-if-changed`

##### 3. Test

Execute tests using `fvm flutter test`

##### 4. Deploy

TODO talk about deployment using fastlane if needed.

### Installing any of the packages included in tapped toolkit

Right now the packages are not published to pub and adding them is done using the `git` keyword.

````yaml
dependencies:
  # Installing all packages
  tapped_toolkit:
    git:
      url: git@github.com:tappeddev/tapped_toolkit.git
      ref: stable

  # Installing selected package
  after_first_build:
    git:
      url: git@github.com:tappeddev/tapped_toolkit.git
      ref: stable
      path: packages/after_first_build
````
