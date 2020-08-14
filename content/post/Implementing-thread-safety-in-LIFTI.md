---
title: "Implementing thread safety in LIFTI"
date: "2011-01-11T00:00:00.0000000"
author: "Mike Goatly"
---
I've wanted to get a bit of thread\-safety going in LIFTI for a
little while now because one of the my target scenarios was for the
index to be hosted in a website\.

The index is already thread safe for concurrent reads\, but it
would definitely be a really bad thing if we started mixing
concurrent writes with our reads\, not least because LIFTI makes
heavy use of the generic Dictionary class\. \(The Thread Safety
section of the [documentation](http://msdn.microsoft.com/en-us/library/xfhwa508.aspx) specifically calls this out\)

Given that concurrent reads are ok\, using a [ReaderWriterLockSlim](http://msdn.microsoft.com/en-us/library/system.threading.readerwriterlockslim.aspx) \(RWLS from now on\)
instance to synchronize access to the index would seem to be a good
idea\. The basic premise to the RWLS class is:

- Multiple threads can simultaneously obtain read locks\.
- Only one thread at a time can obtain a write lock\.
- If a write lock is requested while there are pending locks on
other threads\, it will block until the pending locks are
released\.
- Any read locks that are requested while a write lock is pending
are blocked until the write lock is released\, at which time they
are all granted\.

### Adding the ReaderWriterLockSlim to the index

A very simplistic approach to this would be to just keep an
instance of RWLS in the FullTextIndex class\, but that will lead to
fairly verbose code in quite a few places\, like this:

``` csharp

this.readerWriterLock.AcquireWriterLock();
try
{
    this.IndexItem(itemKey, this.IndexText(itemKey));
}
finally
{
    this.readerWriterLock.ReleaseWriterLock();
}
```
I also wanted to support the disabling of the locking process \-
but would mean making the code even messier than it already
was\.

Looking at the try…finally block I was reminded of something
else \- it's pretty much what the **using** block gets
compiled down to when you use a disposable object\. With that in
mind\, the code would ideally be:

``` csharp

using (this.LockManager.AcquireWriteLock())
{
    this.IndexItem(itemKey, this.IndexText(itemKey));
}
```
It's no co\-incidence then\, that this is what the final
implementation of the code looks like\!

### Introducing LockManager

In keeping with the replaceable part philosophy of LIFTI there
is a new property on FullTextIndex called
**LockManager** that accepts anything implementing
**ILockManager**:

``` csharp

public interface ILockManager
{
    /// <summary>
    /// Gets or sets a value indicating whether locking is enabled.
    /// </summary>
    /// <value><c>true</c> if enabled; otherwise, <c>false</c>.</value>
    bool Enabled { get; set; }

    /// <summary>
    /// Obtains a read lock. This will remain active until the 
    /// provided lock is disposed.
    /// </summary>
    /// <returns>An instance of <see cref="ILock"/> 
    /// that represents the read lock.</returns>
    ILock AcquireReadLock();

    /// <summary>
    /// Obtains a write lock. This will remain active until the 
    /// provided lock is disposed.
    /// </summary>
    /// <returns>An instance of <see cref="ILock"/> 
    /// that represents the write lock.</returns>
    ILock AcquireWriteLock();
}
```
Both methods return an instance of **ILock**\, which
is about as minimalist as an interface comes \- the key point being
that it enforces that a class that implements it also implements
**IDisposable**:

``` csharp

public interface ILock : IDisposable
{
}
```
I'll admit this looks odd\, and FXCop complains about it
*\(CA1040 \- Define a custom attribute to replace ILock\)*\, but
I think in this case it's justifiable as it makes the return type
of the methods more explicit\.

So now we have the interface\, I'll walk through the
implementation of **AcquireReadLock**
\(AcquireWriteLock is almost identical\)\.

``` csharp

public ILock AcquireReadLock()
{
    if (this.Enabled)
    {
        // Enter the lock
        this.readerWriterLock.EnterReadLock();

        // Return a read lock instance
        return new ReadLock(this);
    }

    // Locking is not enabled, so return a new disposable 
    // null lock that does nothing
    return new NullLock();
}
```
Assuming the lock manager is enabled\, a call to
**EnterReadLock** on the class\-level RWLS instance is
made\. This will either block the thread while other locks are
processed\, or grant the lock immediately\. Either way\, once the call
returns\, a new instance of **ReadLock** is returned\.
\(I'll come back to ReadLock very shortly\)

However\, if the lock manager isn't enabled\, all that happens is
a new **NullLock** instance is returned\. NullLock
doesn't do anything\, even when it is disposed by the caller\, so is
essentially a no\-op\. This is great because if the lock manager is
disabled\, then the calling code can remain blissfully unaware\.

### ReadLock

Here's the full ReadLock implementation:

``` csharp

internal struct ReadLock : ILock
{
    private readonly LockManager lockManager;

    internal ReadLock(LockManager lockManager)
    {
        this.lockManager = lockManager;
    }

    public void Dispose()
    {
        this.lockManager.ReleaseReadLock();
    }
}
```
So when a **ReadLock** instance is disposed\, an
internal method **ReleaseReadLock** is called on the
instance of the lock manager that was passed into the constructor \-
ReleaseReadLock looks like this:

``` csharp

internal void ReleaseReadLock()
{
    this.readerWriterLock.ExitReadLock();
}
```
Awesome\, so that's the round trip completed\. Locks are created
at the beginning of a using statement\, and released when they are
disposed automatically at the end\.

### Disposable Structs

One final note: you might have noticed that ReadLock is a
struct\, not a class \- this is true for all the current ILock
implementations\. Doing this prevents an extra object being created
on the heap\, and reduces the amount of work the GC would have to
do\.

