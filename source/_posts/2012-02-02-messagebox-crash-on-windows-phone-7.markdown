---
layout: post
comments: true
title: "MessageBox crash on Windows Phone 7"
date: 2012-02-02T22:05:00+01:00
categories:
 - Windows Phone
 - Rant
 - C#
---


Guess what's wrong with this Application Bar button handler:

``` c#
private void OnAboutButtonClick(object sender, EventArgs e)
{
    MessageBox.Show("Blah blah blah, our app v1.0");
}
```

If you answered "you're using hardcoded string instead of application resource" you are of course right, but that's not the worst problem with it, so no cookie for you. If the user clicks the application bar button twice before the message box is shown it crashes:

``` c#
System.Exception was unhandled
  Message=0x8000ffff
  StackTrace:
    at MS.Internal.XcpImports.CheckHResult(UInt32 hr)
    at MS.Internal.XcpImports.MessageBox_ShowCore(String messageBoxText, String caption, UInt32 type)
    at System.Windows.MessageBox.ShowCore(String messageBoxText, String caption, MessageBoxButton button)
    at System.Windows.MessageBox.Show(String messageBoxText)
    at PhoneApp1.MainPage.OnAboutButtonClick(Object sender, EventArgs e)
    at Microsoft.Phone.Shell.ApplicationBarItemContainer.FireEventHandler(EventHandler handler, Object sender, EventArgs args)
    at Microsoft.Phone.Shell.ApplicationBarIconButton.ClickEvent()
    at Microsoft.Phone.Shell.ApplicationBarIconButtonContainer.ClickEvent()
    at Microsoft.Phone.Shell.ApplicationBar.OnCommand(UInt32 idCommand)
    at Microsoft.Phone.Shell.Interop.NativeCallbackInteropWrapper.OnCommand(UInt32 idCommand)
    at MS.Internal.XcpImports.MessageBox_ShowCoreNative(IntPtr context, String messageBoxText, String caption, UInt32 type, Int32& result)
    at MS.Internal.XcpImports.MessageBox_ShowCore(String messageBoxText, String caption, UInt32 type)
    at System.Windows.MessageBox.ShowCore(String messageBoxText, String caption, MessageBoxButton button)
    at System.Windows.MessageBox.Show(String messageBoxText)
    at PhoneApp1.MainPage.OnAboutButtonClick(Object sender, EventArgs e)
    at Microsoft.Phone.Shell.ApplicationBarItemContainer.FireEventHandler(EventHandler handler, Object sender, EventArgs args)
    at Microsoft.Phone.Shell.ApplicationBarIconButton.ClickEvent()
    at Microsoft.Phone.Shell.ApplicationBarIconButtonContainer.ClickEvent()
    at Microsoft.Phone.Shell.ApplicationBar.OnCommand(UInt32 idCommand)
    at Microsoft.Phone.Shell.Interop.NativeCallbackInteropWrapper.OnCommand(UInt32 idCommand)

```

The interesting thing about this stack trace is that it contains two calls to `MessageBox.Show()`. WTF? Since `MessageBox.Show()` returns the value, I assumed it's a synchronous call, i.e. no stuff would happen until the user clicks "OK". Apparently MessageBox opens internal event loop (which kind of makes sense, since something has to handle the user clicking "OK"), which handles the second application bar click, tries to open the second message box and the whole application blows up.

Now, you may say "It's only a problem if the user intentionally bangs the poor phone like an ADD afflicted monkey on speed". I say "Fix your god damn app" (and in case anyone from Microsoft would ever read this, I also say "Fix your god damn framework").

So what can we do? Using lock is out of the question, since everything is executed in the same thread. So the only option I came up with is a Crappy Boolean Flag Pattern:

``` c#
private bool _msgboxShown = false;
private void OnAboutButtonClick(object sender, EventArgs e)
{
    if (!_msgboxShown)
    {
        _msgboxShown = true;
        MessageBox.Show("Blah blah blah, our app v1.0");
        _msgboxShown = false;
    }
}
```

Not elegant, but it works. Of course if you use message boxes for other stuff, create some helper class for this crap.
