---
title: Type Mismatches in Go Projects with Vendored Dependencies
date: 2020-09-06
categories: [Code]
tags: [Go]
description: Interesting behaviors observed when importing a library that uses a type from a vendored dependency.
---

I ran into this behavior while working on a project and it struck me as odd. It started with a compile-time error similar to this (this is a replication, and I've spaced it out so it's a bit easier to read):

```
 $ go run .
# github.com/komish/vendor-demo-mod-1
./main.go:16:28: 
		cannot use c (type "github.com/komish/vendor-demo-mod-3/pkg/colors".Color) 
		as type "github.com/komish/vendor-demo-mod-2/pkg/vehicles/vendor/github.com/komish/vendor-demo-mod-3/pkg/colors".Color
		in argument to vehicles.GetSedan
```

## How We Get Here

Let's set the stage. 

Let's say that I'm writing a program that intends on using some functions from a module (**"B"**). Module **"B"** has functions with signatures referencing types defined in Module **"C"**. That effectively indicates that module **"B"** depends on module **"C"**. Module **"B"** has vendored its dependencies (in this case, just module **"C"**).

My program intends on using the functions defined in module **"B"**. In order to call those functions, I'll need to also import module **"C"** so that I can make sure to provide the correct arguments to the functions defined in module **"B"**.

I start writing my `main()` and call a function from module **"B"**. I feed it a type defined from module **"C"**, but when I go and compile... I get an error similar to the above. 

In summary, it seems as if the vendoring of module **"C"** into module **"B"** causes the definition of the type to change. My guess is that this is related to the adjustment of the import path done when a vendor directory exists within a repository. 

Vendoring effectively has my projects referring to local code instead of code pulled from the internet. The idea here is that I've stored the code of a dependency I need in my repository for reasons such as reproducible builds, experimental patches, reducing round trips to the internet, and other reasons a developer might vendor dependencies (all of which I'm sure are well discussed on the internet).

I assume this reference to local code instead of code from the internet is changing how the import path is interpreted in some way - which results in this error. I'd have to do more research to be sure.

## A Concrete Example

I've made three packages available where this behavior can be observed. The repositories are as follows, and you only need to download one of theme to see the issue in action.

* [github.com/komish/vendor-demo-mod-1](https://github.com/komish/vendor-demo-mod-1) - **My Program** in the above example - the only repo you need to download to try this out.
* [github.com/komish/vendor-demo-mod-2](https://github.com/komish/vendor-demo-mod-2) - **Module B** in the above example. 
* [github.com/komish/vendor-demo-mod-3](https://github.com/komish/vendor-demo-mod-3) - **Module C** in the above example.

The **vendor-demo-mod-3** repository exposes a package "colors". The package "colors" defines a type `Color` which has fields `NameEnglish` and `NameSpanish`, allowing a user to instantiate a color and assign the name of that color in both languages. Remember that this is "module C" in our example, so it will be imported as a dependency for **vendor-demo-mod-2**. The full definition of the `Color` type is copied here for reference:

```go
// Color is the type for a color which contains english and spanish names for that color.
type Color struct {
	NameEnglish string
	NameSpanish string
}
```

The **vendor-demo-mod-2** repository exposes a package "vehicles". The package "vehicles" defines a type `Vehicle` which has several , one of which is `Color` which is of type `Color` defined in **vendor-demo-mod-3**. The "vehicles" package also provides a few functions that allow you to get several common vehicles by only passing in a color choice for that vehicle. Here's a snippet of that file for reference.

```go
// Package vehicles contains vehicle types.
package vehicles

// ... import statement truncated for brevity ...

// Vehicle represents a vehicle of some sort.
type Vehicle struct {
	Type   string
	Wheels uint8
	Seats  uint8
	Color  colors.Color
}

// GetSedan returns a sedan vehicle that seats 4 in the color provided.
func GetSedan(color colors.Color) Vehicle {
	return Vehicle{
		Type:   "sedan",
		Wheels: 4,
		Seats:  4,
		Color:  color,
	}
}
// ... other functions truncated for brevity ...
```

As mentioned, **vendor-demo-mod-2** has vendored its dependencies, so the project layout looks like this:

```
 $ tree .
.
└── pkg
    └── vehicles
        ├── go.mod
        ├── go.sum
        ├── util.go
        ├── vehicles.go
        └── vendor
            ├── github.com
            │   └── komish
            │       └── vendor-demo-mod-3
            │           └── pkg
            │               └── colors
            │                   └── colors.go
            └── modules.txt

8 directories, 6 files
```

Finally, the **vendor-demo-mod-1** repository is the equivalent of "My Program", in the above example. We have a simple `main()` function here that does nothing more than create a sedan of a specific color, and then prints out the a simple message indicate the type of car that I drive and the color of said car. The entire file is here for reference, with line numbers to make things easier to reference in the rest of this article.

```go
     1  package main
     2
     3  import (
     4          "fmt"
     5
     6          "github.com/komish/vendor-demo-mod-2/pkg/vehicles"
     7          "github.com/komish/vendor-demo-mod-3/pkg/colors"
     8  )
     9
    10  func main() {
    11          c := colors.Color{
    12                  NameEnglish: "Blue",
    13                  NameSpanish: "Azul",
    14          }
    15          /* Let's get a blue sedan, but this one fails */
    16          // myCar := vehicles.GetSedan(c)
    17
    18          /* Let's get a blue sedan, successfully this time */
    19          myCar := vehicles.GetSedan(vehicles.GetColor(c.NameEnglish, c.NameSpanish))
    20
    21          /* Print out some information about our car */
    22          fmt.Println("I drive a", myCar.Color.NameEnglish, myCar.Type)
    23  }
```

As written above (which is also how it exists in the referenced repository), the program will execute without issue. However, if you comment out line 19 and uncomment line 16, we run into the error mentioned at the top of this article.

``` $ go run .
# github.com/komish/vendor-demo-mod-1
./main.go:16:28: 
		cannot use c (type "github.com/komish/vendor-demo-mod-3/pkg/colors".Color) 
		as type "github.com/komish/vendor-demo-mod-2/pkg/vehicles/vendor/github.com/komish/vendor-demo-mod-3/pkg/colors".Color
		in argument to vehicles.GetSedan
```

The compile-time error is telling us that the function `GetSedan()`, which comes from the "vehicles" package made available in **vendor-demo-mod-2** does not accept a `Color` type as defined in the "colors" package in **vendor-demo-mod-3**. This is despite the fact that both **vendor-demo-mod-1** and **vendor-demo-mod-2**  imported the same package "colors" from **vendor-demo-mod-3**.

## Working Around It

I've done some initial digging to determine why this happens, but there's more to be done. In the meantime, I looked at workaround and suggestions on how to build your programs such that you don't run into this issue. I came across an old [twitter thread](https://twitter.com/fatih/status/740883554264096772) (2016) that suggested that vendoring doesn't make sense for libraries.

I think I understand where this is coming from. Vendoring dependencies helps give your program a reproducible build, but libraries aren't necessary built in the same way a program that produces a binary would be. I'd think that in the case of a library, it would simply make sense to make sure you're releasing in a stable fashion. That said, libraries can have dependencies - and I guess anything that can have a dependency can have a need to "vendor" that dependency should the dependency maintainer not be releasing in a stable way. I can see this both ways, I guess.

A [stack overflow](https://stackoverflow.com/questions/38091816/packages-type-cannot-be-used-as-the-vendored-packages-type) (2016) discussion also mentioned avoiding vendoring in libraries, but proposes another alternative of providing accessor functions to the library such that the types in question can be created indirectly. This seems to work in practice.

If you look at [github.com/komish/vendor-demo-mod-2](https://github.com/komish/vendor-demo-mod-2/blob/main/pkg/vehicles/util.go#L8), the "vehicles" package provides a `GetColor()` function which returns a `Color` struct. We've indirectly created a `Color` struct through the "vehicles" package instead of by directly getting that struct from the "colors" package. As a result, we don't have a type mismatch complaint from the compiler which solves this issue outright.

## Downsides of Being Indirect

Approaching things this way has some issues. Effectively I've accessed module **"C"** through module **"B"** which means that I'm at the mercy of module **"B"** to stay in lock-step with module **"C"**  over time.

In practice, I'd agree with the idea that avoiding vendoring in this scenario would be the best bet - but if you're in a situation where a module you do not control has already vendored dependencies, you might not have much in the way of choices.

Either way, it has been an interesting behavior to observe. Perhaps finding some more-recent discussion on this topic is worthwhile.

