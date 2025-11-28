# Troubleshooting Network Connection Issues

## Problem: "Network error: failed to fetch api"

If you're getting network errors when the API works in Postman, follow these steps:

## ✅ Fixes Applied

1. **Added Cleartext Traffic Permission** - Android 9+ requires this for HTTP connections
2. **Improved Error Handling** - Better error messages with debugging info
3. **Added Connection Logging** - Console logs show the exact URL being called

## 🔍 Debugging Steps

### 1. Check Console Logs

When you try to sign in, you should see logs like:
```
🔧 Base URL configured: http://10.0.2.2:3000/api
🔧 Platform: android, Using host: 10.0.2.2
🌐 API Call: POST http://10.0.2.2:3000/api/auth/sign-in
📤 Request Body: {"email":"...","password":"..."}
📥 Response Status: 200
```

### 2. Verify Your Platform

**For Android Emulator:**
- Should use: `http://10.0.2.2:3000/api`
- `10.0.2.2` is the special IP that maps to `localhost` on your computer

**For iOS Simulator:**
- Should use: `http://127.0.0.1:3000/api`
- Or `http://localhost:3000/api`

**For Real Device:**
- You need to use your computer's LAN IP address
- Find it with: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Update `kLanIp` in `lib/services/api_client.dart`
- Set `kUseLanIpForRealDevice = true`

### 3. Test Connection

You can test the connection using the `ConnectionTest` utility:

```dart
import 'package:door/services/connection_test.dart';

// Test basic connection
final result = await ConnectionTest.testConnection();
print(result);

// Test sign-in endpoint
final endpointResult = await ConnectionTest.testSignInEndpoint();
print(endpointResult);
```

### 4. Common Issues & Solutions

#### Issue: "SocketException: Connection refused"
**Solution:**
- Make sure your backend server is running on port 3000
- Check: `http://localhost:3000/api/auth/sign-in` works in Postman
- Verify the port number matches (3000)

#### Issue: "Connection timeout"
**Solution:**
- Check firewall settings
- Ensure emulator/device can reach your computer
- For real device: Make sure both are on the same WiFi network

#### Issue: "Failed to fetch" (Web)
**Solution:**
- Web apps have CORS restrictions
- Backend needs CORS headers
- Or use a proxy in development

### 5. Manual Configuration

If automatic host detection doesn't work, you can manually set it:

**In `lib/services/api_client.dart`:**

```dart
String _resolveHost() {
  // Force a specific host
  return '10.0.2.2'; // For Android emulator
  // return '127.0.0.1'; // For iOS simulator
  // return '192.168.1.100'; // For real device (your computer's IP)
}
```

### 6. Verify Backend is Running

Test in Postman or browser:
```
GET http://localhost:3000/api/auth/sign-in
```

Should return an error (since no body), but proves server is running.

### 7. Check Android Manifest

Make sure `android/app/src/main/AndroidManifest.xml` has:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application
    android:usesCleartextTraffic="true"
    ...>
```

## 📱 Platform-Specific Notes

### Android Emulator
- Always use `10.0.2.2` instead of `localhost`
- This is automatically configured

### iOS Simulator
- Can use `127.0.0.1` or `localhost`
- Both should work

### Real Device
1. Find your computer's IP:
   - Windows: `ipconfig` → Look for "IPv4 Address"
   - Mac/Linux: `ifconfig` → Look for "inet"
2. Update `kLanIp` in `api_client.dart`
3. Set `kUseLanIpForRealDevice = true`
4. Make sure device and computer are on same WiFi

## 🐛 Still Having Issues?

1. **Check the console logs** - They show the exact URL being called
2. **Test in Postman** - Verify the exact same request works
3. **Compare URLs** - Make sure Postman URL matches what Flutter is calling
4. **Check backend logs** - See if requests are reaching the server
5. **Try curl** - Test from terminal: `curl http://localhost:3000/api/auth/sign-in`

## Example Working Configuration

For Android Emulator:
```
Base URL: http://10.0.2.2:3000/api
Full URL: http://10.0.2.2:3000/api/auth/sign-in
```

For iOS Simulator:
```
Base URL: http://127.0.0.1:3000/api
Full URL: http://127.0.0.1:3000/api/auth/sign-in
```

For Real Device (example):
```
Base URL: http://192.168.1.100:3000/api
Full URL: http://192.168.1.100:3000/api/auth/sign-in
```

Make sure your backend is accessible at these URLs!




