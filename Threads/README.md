# Threads

This is my playground while reading [Parallel and Concurrent Programming in Haskell][1].

## Chapter 7
| Example | Description |
| --- | --- |
| Fork | Try out the [`forkIO`][2] API to create threads. |
| Reminders | Try out the [`threadDelay`][3] API to suspend a thread. |
| MVar1, MVar2, MVar3 | Learn the basic of [`MVar`][4]. |
| Logger | Use the [`MVar`][4] to create a logger thread. |
| PhoneBook | Use the [`MVar`][4] to create a thread-safe phonebook. |

[1]: https://www.oreilly.com/library/view/parallel-and-concurrent/9781449335939/
[2]: https://hackage.haskell.org/package/base-4.17.0.0/docs/Control-Concurrent.html#v:forkIO
[3]: https://hackage.haskell.org/package/base-4.17.0.0/docs/Control-Concurrent.html#v:threadDelay
[4]: https://hackage.haskell.org/package/base-4.17.0.0/docs/Control-Concurrent-MVar.html