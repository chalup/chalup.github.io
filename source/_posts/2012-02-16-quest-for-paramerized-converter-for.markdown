---
layout: post
comments: true
title: "The quest for paramerized converter for Windows Phone 7"
date: 2012-02-16T13:16:00+01:00
categories:
 - MVVM
 - Windows Phone
 - Xaml
 - Rant
---


**Warning:** this is going to be a long post, because I want to provide full background for the issues I found. Also, none of the code posted here works in 100% of cases.

Recently I was involved in refactoring a program written by interns, which included an over engineered and messed up solution for application settings. I had plenty of time and, despite of the messed up implementation, the original idea might be useful for any form filled by user, so instead of scraping the whole thing I decided to clean it up.

Every type of setting is represented by different class derived from common base. The model of settings consist of a collection of base class objects. That collection is bound to ItemsSource property of ListBox and instead of single data template I use template selector, which creates different UI controls for different setting type.

There is a BooleanSetting, which is represented by a single ToggleSwitch from [Silverlight from Windows Phone Toolkit](http://silverlight.codeplex.com/). There is a ClosedListSetting, represented by ListPicker, which is used for a setting where user can choose one of many options from a predefined list (hence the name). Finally there is a OpenListSetting, which is just like a ClosedListSetting, except there is the "Other" option which allows user to enter any value. On web forms such field is usually represented as a radio button group with an input box beside the "Other" option.

For UI consistency I wanted to represent the OpenListSetting using ListPicker, and when the user would select the "Other" option, additional entry field will appear. It seemed really easy, I thought I'll just bind the visibility of the custom entry field to ListPicker's SelectedIndex property with a value converter.

The first complication is that the position of custom option might be different for a different settings - usually it's the last one, so it depends on the number of predefined options; for maximum flexibility it should be possible to have many custom options in one OpenListSetting. The obvious solution is to bind some value to converter's parameter property.

Quick search on Google reveals the major flaw in that plan, to wit, you cannot use the binding for converter parameter. There is a Multibinding, which sounds like a likely solution (after all I want to bind visibility to two properties and an operation between those properties), but apparently it's not available in Silverlight for Windows Phone 7. Yay, it's Java ME crap all over again!

The suggested workaround is creating a converter as a non-visual FrameworkElement, with parameter as a dependency property, which can be used in binding. I created a base class:

``` c#
public abstract class ConverterWithBindingParameter<T, TConverter> : FrameworkElement, IValueConverter
{
    public static readonly DependencyProperty ParameterProperty = DependencyProperty.Register(
        "BindingParameter",
        typeof(T),
        typeof(TConverter),
        null);

    public T BindingParameter
    {
        get { return (T)GetValue(ParameterProperty); }
        set { SetValue(ParameterProperty, value); }
    }

    abstract public object Convert(object value, Type targetType, object parameter, CultureInfo culture);
    abstract public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture);
}
```

And then derived the concrete converter for a problem at hand:

``` c#
public class EqualToVisibilityConverter : ConverterWithBindingParameter<int, EqualToVisibilityConverter>
{
    override public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        return (value.Equals(BindingParameter)) ? Visibility.Visible : Visibility.Collapsed;
    }

    override public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}
```

Edit XAML, rebuild, run, kaboom:

``` c#
System.ArgumentException was unhandled
    StackTrace:
    at System.Reflection.RuntimeMethodInfo.InternalInvoke(Object obj, BindingFlags invokeAttr, Binder binder, Object[] parameters, CultureInfo culture, StackCrawlMark& stackMark)
    at System.Reflection.RuntimePropertyInfo.InternalSetValue(PropertyInfo thisProperty, Object obj, Object value, Object[] index, StackCrawlMark& stackMark)
    at System.Reflection.RuntimePropertyInfo.SetValue(Object obj, Object value, Object[] index)
    at MS.Internal.XamlMemberInfo.SetValue(Object target, Object value)
    at MS.Internal.XamlManagedRuntimeRPInvokes.SetValue(XamlTypeToken inType, XamlQualifiedObject& inObj, XamlPropertyToken inProperty, XamlQualifiedObject& inValue)
    at MS.Internal.XcpImports.MeasureOverrideNative(IntPtr element, Single inWidth, Single inHeight, Single& outWidth, Single& outHeight)
    at MS.Internal.XcpImports.FrameworkElement_MeasureOverride(FrameworkElement element, Size availableSize)
    at System.Windows.FrameworkElement.MeasureOverride(Size availableSize)
    at System.Windows.FrameworkElement.MeasureOverride(IntPtr nativeTarget, Double inWidth, Double inHeight, Double& outWidth, Double& outHeight)
    at MS.Internal.XcpImports.Measure_WithDesiredSizeNative(IntPtr element, Single inWidth, Single inHeight, Single& outWidth, Single& outHeight)
    at MS.Internal.XcpImports.UIElement_Measure_WithDesiredSize(UIElement element, Size availableSize)
    at System.Windows.UIElement.Measure_WithDesiredSize(Size availableSize)
    at System.Windows.Controls.VirtualizingStackPanel.MeasureChild(UIElement child, Size layoutSlotSize)
    at System.Windows.Controls.VirtualizingStackPanel.MeasureOverride(Size constraint)
    at System.Windows.FrameworkElement.MeasureOverride(IntPtr nativeTarget, Double inWidth, Double inHeight, Double& outWidth, Double& outHeight)
    at MS.Internal.XcpImports.MeasureOverrideNative(IntPtr element, Single inWidth, Single inHeight, Single& outWidth, Single& outHeight)
    at MS.Internal.XcpImports.FrameworkElement_MeasureOverride(FrameworkElement element, Size availableSize)
    at System.Windows.FrameworkElement.MeasureOverride(Size availableSize)
    at System.Windows.Controls.ScrollContentPresenter.MeasureOverride(Size constraint)
    at System.Windows.FrameworkElement.MeasureOverride(IntPtr nativeTarget, Double inWidth, Double inHeight, Double& outWidth, Double& outHeight)
    at MS.Internal.XcpImports.MeasureNative(IntPtr element, Single inWidth, Single inHeight)
    at MS.Internal.XcpImports.UIElement_Measure(UIElement element, Size availableSize)
    at System.Windows.UIElement.Measure(Size availableSize)
    at System.Windows.Controls.ScrollViewer.MeasureOverride(Size constraint)
    at System.Windows.FrameworkElement.MeasureOverride(IntPtr nativeTarget, Double inWidth, Double inHeight, Double& outWidth, Double& outHeight)
    at MS.Internal.XcpImports.MeasureOverrideNative(IntPtr element, Single inWidth, Single inHeight, Single& outWidth, Single& outHeight)
    at MS.Internal.XcpImports.FrameworkElement_MeasureOverride(FrameworkElement element, Size availableSize)
    at System.Windows.FrameworkElement.MeasureOverride(Size availableSize)
    at System.Windows.FrameworkElement.MeasureOverride(IntPtr nativeTarget, Double inWidth, Double inHeight, Double& outWidth, Double& outHeight)
    at MS.Internal.XcpImports.MeasureOverrideNative(IntPtr element, Single inWidth, Single inHeight, Single& outWidth, Single& outHeight)
    at MS.Internal.XcpImports.FrameworkElement_MeasureOverride(FrameworkElement element, Size availableSize)
    at System.Windows.FrameworkElement.MeasureOverride(Size availableSize)
    at System.Windows.FrameworkElement.MeasureOverride(IntPtr nativeTarget, Double inWidth, Double inHeight, Double& outWidth, Double& outHeight)
```

On a hunch I created non-generic version of my converter and it seemed to work. Oh, so I can't use generic base for UI controls? Nice job MS.

``` c#
public class EqualToVisibilityConverter : FrameworkElement, IValueConverter
{
    public static readonly DependencyProperty ParameterProperty = DependencyProperty.RegisterAttached(
        "BindingParameter",
        typeof(int),
        typeof(EqualToVisibilityConverter),
        new PropertyMetadata(0));

    private static void OnBindingParameterChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
    {
    }

    public int BindingParameter
    {
        get { return (int)GetValue(ParameterProperty); }
        set { SetValue(ParameterProperty, value); }
    }

    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        int bp = BindingParameter;
        return (value.Equals(BindingParameter)) ? Visibility.Visible : Visibility.Collapsed;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
        throw new NotImplementedException();
    }
}
```

Note that I wrote "seemed to work". It means only that the code didn't explode in my face, but it didn't work quite as I expected. Here's the quick breakdown: when the visibility converter is called for the first time, the bound parameter is null. Then the dependency value is changed (at least the callback is called; curiously, the setter is not) and the bound parameter is initialized with a proper value, but there is no way to invalidate the conversion result.

That gave me another idea: why use IValueConverter interface at all? Let's create an UI element with 2 dependency properties for arguments and one property for result of binary operation: 

``` c#
public class EqualToVisibilityConverter : FrameworkElement, INotifyPropertyChanged
{
    public static readonly DependencyProperty LeftArgumentProperty = DependencyProperty.Register(
        "LeftArgument",
        typeof(int),
        typeof(EqualToVisibilityConverter),
        new PropertyMetadata(OnArgumentChanged)
        );

    public static readonly DependencyProperty RightArgumentProperty = DependencyProperty.Register(
        "RightArgument",
        typeof(Visibility),
        typeof(EqualToVisibilityConverter),
        new PropertyMetadata(OnArgumentChanged)
        );

    private static void OnArgumentChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
    {
        EqualToVisibilityConverter converter = d as EqualToVisibilityConverter;
        converter.Result = (converter.LeftArgument == converter.RightArgument) ? Visibility.Visible : Visibility.Collapsed;
    }

    public int LeftArgument
    {
        get { return (int)GetValue(LeftArgumentProperty); }
        set { SetValue(LeftArgumentProperty, value); }
    }

    public int RightArgument
    {
        get { return (int)GetValue(RightArgumentProperty); }
        set { SetValue(RightArgumentProperty, value); }
    }

    private Visibility _result;
    public Visibility Result
    {
        get { return _result; }
        set
        {
            if (value != _result)
            {
                _result = value;
                OnPropertyChanged("Result");
            }
        }
    }

    public event PropertyChangedEventHandler PropertyChanged;
    protected void OnPropertyChanged(string propertyName)
    {
        if (null != PropertyChanged)
        {
            PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
```

Now the callbacks of dependency properties can trigger the result recalculation and everything will be fine and dandy. Edit XAML, rebuild, run, KABOOM! This time application blew up, but I didn't even get a call stack, it just closed without any message.

This. Is. Fucking. Ridiculous.

At this moment I decided I already lost enough time on this crap, so I just said "screw it" and added additional property to OpenListSetting class.

This is when I finally got why the MVVM pattern got so much traction with XAML developers. I always assumed that it's supposed to be used for big model adaptations, and all minor stuff should be done in binding converters. However it seems that you have to use ViewModel for anything remotely useful. Don't get me wrong: I agree that preventing pollution of Model by stuff needed by View is a Good Thing TM, but I think a separation of View into View and ViewModel is necessary only because of limitations of XAML.
