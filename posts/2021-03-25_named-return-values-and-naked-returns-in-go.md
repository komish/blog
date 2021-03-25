---
title: Named Return Values and Naked Returns in Go
date: 2021-03-25
categories: [Thoughts]
tags: [development, go, golang, micro]
description: A lesson I learned on naked returns in Go.
---

While working on a bug in a Go application that a friend discovered, I learned
about the concept of a  [Naked Return](https://tour.golang.org/basics/7).

I've been familiar with the concept of named return values, but not the concept
of a naked return that goes along with it. A "naked return" refers to a return
in a function with named return values that does not explicitly indicate the
values to be returned.

Take this example ([playground](https://play.golang.org/p/akTh6Z5V848)):

```go
package main

import (
    "fmt"
)

func main() {
    fmt.Println(simpleNakedReturn())
}

func simpleNakedReturn() (someString string) {
    someString = "foo"
    return
}
```

The function `simpleNakedReturn` returns a string, but we only call `return` at
the end of the function. This is a "naked return". Typically we would expect to
see `return someString`.

What's interesting to note is that the returned value is "foo" in this case.
That's by design, as functions with named return values effectively instantiate
the value at the beginning of the function. In this case, we could assume that
it would have been something like `var someString string`.

This can be problematic (as it was in the bug that we discovered) in situations
where you return something that can be `<nil>`, and really drives home the need
to do error checking and nil checking in this case.

Take this example ([playground](https://play.golang.org/p/GoYUebSzAHP)):

```go
package main

import (
    "fmt"
)

func main() {
    s, p := nakedReturnSomeThings()
    defer p() // this fails

    fmt.Println("s is:", s)

}

func nakedReturnSomeThings() (someString string, someFunc func()) {
    someString = "foo"
    return
}
```

In this case, the naked return obscures that I've returned `<nil>` for
`someFunc`. As a result, when I try to defer `someFunc`, I have no issue until
the function completes and the defer tries to execute.

This reinforces to me that I would rather return explicitly, but it's certainly
an interesting language-ism that I was not aware of.
