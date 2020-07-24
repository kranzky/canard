# Quacks

## num must be between 0 and 99

* Before `Foo#bar(num)`

```
Q^ "too small" if num < 0
Q^  "too big" if num > 99
```

## num should exist here

* Within `Foo#bar(num)`

```
Q^ "non-existence!" unless defined? num
```

## returns half the value passed in

* After `Foo#bar(num)`

```
Q^ "wrong answer" if retval != num / 2
```
