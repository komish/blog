---
title: Don't forget to deepcopy your Nested Lists
date: 2019-05-15
categories: [Code]
tags: [python, development]
description: A quick refresher on the importance of deepcopying a nested list in Python.
aliases:
- /blog/dont-forget-to-deepcopy.html
---


I got owned by this internal functionality of Python and figured it'd be best I store some notes for the next time I spin my wheels on this particular thing. It's pretty common practice and I was aware of the concept, but I of course forgot about this behavior in the *nested* context and as such spent an excessive amount of time refactoring trying to figure out why my tests kept showing heavily manipulated inputs.

Take the following nested list:

```python
>>> list_one = [[1,2], [3,4]]
```

And say we need another:

```python
>>> list_two = list_one
```

This might *read* like we're copying `list_one` variable into `list_two`, but what we've actually done here is simply create another label to the same object identity which we can confirm outputting the same:

```python
>>> id(list_one); id(list_two)
4451987656
4451987656
```

As these two match, we can be conclusive that any action affecting `list_one` will also *appear* to impact `list_two` simply because they're in effect the same space in memory.

So should we want a copy, you might see the `copy()` function called on the object or alternatively something like this:

```python3
>>> list_two = list_one[:]
```

Checking the identity of these two objects *now* reveals that we've got separate objects:

```python
>>> id(list_one); id(list_two)
4451987656
4451987592
```

So at this point we can take an action that modifies the objects in place without collision. So should we remove the final element of `list_two` we can expect `list_one` to go unaffected.

```python
>>> list_two.pop()
[3, 4]
>>> list_two
[[1, 2]]
>>> list_one
[[1, 2], [3, 4]]
```

No problems there, but what happens if I need to remove one of the nested list elements?

```python
>>> list_two[0].pop()
2
>>> list_two
[[1]]
>>> list_one
[[1], [3, 4]]
```

We see that `list_one` is affected. While we have made a copy of the top-level, the inner lists are still just references to the same object identity. In effect, this *shallow copy* we've made only allows us to manipulate the top layer independently. 

```python
>>> id(list_one[0]); id(list_two[0])
4450906376
4450906376
```

A *deep copy* is needed here to make sure we get independent object identities for each of the nested elements as well.

```python
>>> list_three = [[1,2], [3,4]]
>>> from copy import deepcopy
>>> list_four = deepcopy(list_three)
```

Once we have our deepcopy in place, we can check IDs of the top level as well as the nested lists to confirm the unique IDs:

```python
>>> id(list_three); id(list_four)
4452021768
4452053128
>>> id(list_three[0]); id(list_four[0])
4451195656
4452053192
```

From then on, we can manipulate our nested lists without any collision.

```python
>>> list_three[0].pop()
2
>>> list_three; list_four
[[1], [3, 4]]
[[1, 2], [3, 4]]
```