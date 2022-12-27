# Chapter 9. Cancellation and Timeouts

This is my playground while reading [Parallel and Concurrent Programming in Haskell][1] chapter 9.

## Note
To make `Async` cancellable, according to the book, it's defined as

```haskell
data Async a = Async ThreadId (Either SomeException a)
```

However, an `Async` task may start multiple threads. For example, `waitEither` forks 2 threads, `waitAny` forks n threads.
A proper defintion of `Async` would be

```haskell
data Async a = Async [ThreadId] (Either SomeException a)
```


[1]: https://www.oreilly.com/library/view/parallel-and-concurrent/9781449335939/
