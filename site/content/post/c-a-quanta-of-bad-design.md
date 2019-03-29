
+++
date = "2013-06-21T09:06:30.0000000-07:00"
title = "C# A Quanta of Bad Design"
author = "João P. Bragança"
tags = ["WTF"]
+++

This bit me in the ass yesterday.

```csharp
0m.Equals(0.0m)
```

but

```csharp
0m.ToString().Equals(0.0m.ToString()).Equals(false)
```