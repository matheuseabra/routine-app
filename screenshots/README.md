# Routine demo screenshots

These images are captured from the iPhone 16 simulator in Light appearance at
its native screenshot resolution. To reproduce the populated main screens,
launch the app with:

```text
-screen main -tab home -demo-data
```

Switch `home` to `habits`, `insights`, or `profile` for the other main
destinations. The `-demo-data` flag resets and seeds only the local SwiftData
store for that explicit demo run; normal launches do not seed or remove data.
