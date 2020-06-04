---
title: Playing with IFS in Bash
date: 2019-05-16
categories: [Code]
tags: [Development, Bash]
description: Exploring the functionality of the `${IFS}` variable at a very basic level.
aliases:
- /blog/playing-with-ifs-in-bash.html
---

I came across these notes in an old gist two years ago that I cleared out and figured I'd best migrate it elsewhere for safe keeping. I remember placing it as a gist to share with some buddies of mine who were working with shell scripts at the time, so it's written to take the basic constructs (loops) and reach the use case for the `${IFS}` variable. At some point I'll revisit this for a deeper understanding.

### The Notes!

I don't have a full understanding of the `$IFS` variable (where it comes from, why it's set, from when it originates), but it seems to serve the purpose of a "field separator" in bash shells at the very least.

In playing with writing bash_completion functions, I came across the need for some kind of tuple data structure. Google searches suggested modifying the `IFS` variable to accomplish the intended behavior.

Looping is quite simple in bash:

```shell
for i in one two three; do
  echo "$i"
done

## results
one
two
three
```

You can use variable expansion for the same purpose (note that we don't quote our `$thing` variable as we want the arguments to be treated independently):

```shell
thing="one two three"
for i in ${thing}; do
  echo "$i"
done

## results
one
two
three
```

So with little requirement, the value of `$thing` above is iterable using what appears to be a space separator.

The `$IFS` variable seems to be what defines that separator. If you re-assign the variable, you can use an alternative separator which can be then used to imitate the tuple construct. Online research indicates the original value should be stored and re-assigned once the completed purpose of the reassignment has taken place.

```shell
# create a 'tuple'-like variable
thing="1,one 2,two 3,three"

# store your original IFS value
ORIGIFS=$IFS
for i in $thing; do
  IFS=","
  set -- ${i}
  echo "i is ${i}"
  echo "first value (\$1) is ${1}"
  echo "second value (\$2) is ${2}"
  echo
done; IFS=$ORIGIFS

## result
i is 1,one
first value ($1) is 1
second value ($2) is one

i is 2,two
first value ($1) is 2
second value ($2) is two

i is 3,three
first value ($1) is 3
second value ($2) is three
```

Note the reference to the values in the 'tuple' `$1, $2, ..., $n` and the restoration of IFS at the very end which would otherwise make repeat executions of this loop fail because the value of `$IFS` is used to parse the arguments in `$thing`.


#### Additional Reading
* [The Default Value of IFS](https://unix.stackexchange.com/questions/120575/understanding-the-default-value-of-ifs)
* [Iterate over tuples in bash](https://stackoverflow.com/questions/9713104/loop-over-tuples-in-bash)