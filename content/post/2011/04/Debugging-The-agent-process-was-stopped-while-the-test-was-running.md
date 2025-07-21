---
title: "Debugging \"The agent process was stopped while the test was running\""
date: "2011-04-25T00:00:00.0000000"
author: "Mike Goatly"
---
I've encountered the unhelpful "The agent process was stopped
while the test was running" MSTest error result a couple of times
recently\, and I thought that I'd share a few of my findings and
approaches to debugging the unit tests that cause them\.

## The MSTest "Error" Result

In my experience\, the Error result usually manifests itself for
one of a two reasons:

- A critical error occurred during the execution of the test\.
This might be due to something caused by the code executed by the
test\, for example a stack overflow error\, but it may also occur
when the test framework is unable to execute the test for some
reason\, e\.g\. it is unable to copy dependent files\.
- A test caused some code to be executed on *another
thread*\, and ** an exception occurred on that thread\,
not the main test one\.

The first of these is easy to overcome\, as I'll show later\,
however the second can\, under some circumstances\, be much trickier
to diagnose\.

## Viewing the Test run error information

The error results are usually presented in the Test Results
window like this:

![image](/images/post/2011/04/Windows-Live-Writer_Debugging_12BE4_image_thumb_1.png)

*Side note: you can see that I've grouped the tests by their
result \- this is my preferred approach to viewing my unit tests in
this window\.*

When the test results contain an error\, you can get more details
by clicking on the "Test run error" hyperlink\. This shows you the
error details for each of the tests that ended up with the Error
result\, and may well provide you with enough information to solve
your problem:

![image](/images/post/2011/04/Windows-Live-Writer_Debugging_12BE4_image_thumb_2.png)

Here you can see that an error on the background thread caused
the test to fail\. If you're lucky\, this window should given you
enough information to fix your problem\.

## Background threads

Something that's important to consider is that if your code
makes use of background threads that live on beyond the lifetime of
the test\, an exception raised on this thread *can cause the
error to be reported against a subsequent test\!*

Take these sample tests:

``` csharp

[TestMethod]
public void BadBackgroundTestCausingDelayedError()
{
    // Create another thread and execute it - this test will pass,
    // but the exception raised by the thread will cause ANOTHER test to fail.
    var thread = new Thread(() =>
        {
            DoSomething();
        });

    thread.Start();
}

[TestMethod]
public void GoodTest1()
{
    // Pretend to do some work
    Thread.Sleep(2000);
}

private void DoSomething()
{
    throw new Exception("I'm sorry Dave, you can't do that.");
}
```
When executed in order\, you'll see this in the test results:

![image](/images/post/2011/04/Windows-Live-Writer_Debugging_12BE4_image_thumb_3.png)

Uh\, oh\. The test that did nothing wrong was blamed for the
failure of the bad one\. Looking at the Test run error report will
help a little in this case \- the call stack looks like this:

```

One of the background threads threw exception: 
System.Exception: I'm sorry Dave, you can't do that.
   at TestProject1.UnitTest1.DoSomething() in UnitTest1.cs:line 56
   at TestProject1.UnitTest1.<BadBackgroundTestCausingDelayedError>b__0() in UnitTest1.cs:line 20
   at System.Threading.ThreadHelper.ThreadStart_Context(Object state)
   at System.Threading.ExecutionContext.runTryCode(Object userData)
   at System.Runtime.CompilerServices.RuntimeHelpers.ExecuteCodeWithGuaranteedCleanup(TryCode code, CleanupCode backoutCode, Object userData)
   at System.Threading.ExecutionContext.RunInternal(ExecutionContext executionContext, ContextCallback callback, Object state)
   at System.Threading.ExecutionContext.Run(ExecutionContext executionContext, ContextCallback callback, Object state, Boolean ignoreSyncCtx)
   at System.Threading.ExecutionContext.Run(ExecutionContext executionContext, ContextCallback callback, Object state)
   at System.Threading.ThreadHelper.ThreadStart()
```
If you look carefully\, you might see some indication of the test
that the exception originated from\.

## No call stack in the results window

You can't always infer the test at the root of the problem from
this call stack\. Indeed\, there are times when you don't get
*any* stack trace information \- like this:

![image](/images/post/2011/04/Windows-Live-Writer_Debugging_12BE4_image_thumb_4.png)

When this happens\, I've found that it's usually because the
exception that is being thrown from the other thread is a
*custom exception* and the test framework is unable to
de\-serialize it into the test AppDomain\. If you dig around in the
debug output you might find exception details that indicate
this:

```

E, 1020, 17, 2011/04/25, 22:34:14.366, MGLAPTOP\QTAgent32.exe, 
    Unhandled Exception Caught, reporting through Watson: 
    System.Runtime.Serialization.SerializationException: 
    Unable to find assembly 'TestProject1, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null'.
   at System.Runtime.Serialization.Formatters.Binary.BinaryAssemblyInfo.GetAssembly()
   ...
   at System.Runtime.Remoting.Channels.CrossAppDomainSerializer.DeserializeObject(MemoryStream stm)
   at System.AppDomain.Deserialize(Byte[] blob)
   at System.AppDomain.UnmarshalObject(Byte[] blob)
The program '[1020] QTAgent32.exe: Program Trace' has exited with code 0 (0x0).
The program '[1020] QTAgent32.exe: Managed (v4.0.30319)' has exited with code -2 (0xfffffffe).
```
## Debugging the tests

If you still haven't got to the bottom of your test Error\, then
you can always debug the tests\. Before you start debugging\, make
sure that you're catching all exceptions from the Debug/Exceptions
menu \(or Ctrl\-Alt\-E\):

![image](/images/post/2011/04/Windows-Live-Writer_Debugging_12BE4_image_thumb_7.png)

Hopefully these tips will help you identify the cause of your
unit test errors \- good luck\!

