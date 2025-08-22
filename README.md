# **dls (Dart Log Server)** 🪵
[![sentry](https://img.shields.io/pub/v/dls.svg?label=dls)](https://pub.dev/packages/dls)   
**dls** is a command-line interface (CLI) tool and a local HTTP server designed to simplify logging for Dart applications. It provides an efficient and lightweight alternative to traditional logging methods, especially when dealing with a high volume of logs that might cause performance issues in an IDE or when writing to files.

-----

### **The Problem** 😩

During the development of a Dart analyzer plugin, I encountered significant challenges with conventional logging. Logging directly to a file or using IDE tools often led to performance degradation, and in some cases, an excessive number of logs would even cause my computer to hang. This experience highlighted the need for a more robust and non-intrusive logging solution that could handle a constant stream of log data without impacting system performance.

-----

### **The Solution** ✨

**dls** was created to address these issues. It works as a local HTTP server that listens for incoming log requests. When you run `dls`, in the terminal window, starts an HTTP server on `http://localhost:8080` (you can use any port i.e -p 9090). Any `POST` request sent to `http://localhost:8080/log` with a text body will have its content printed directly to the `dls`-opened terminal. This approach offloads the logging process from your main application and IDE, preventing performance bottlenecks and providing a dedicated, clean view of your logs.

-----

### **Usage** 💻

#### **Installation**

Install **dls** globally via `pub`:

```bash
dart pub global activate dls
```

#### **Running the Server**

Open a new terminal window and run the `dls` command.

```bash
dls
```

The server will start and listen for logs. Keep this terminal open while you are logging.

#### **Sending Logs from Your Dart App**

To send logs from your Dart application, you can use the `dart:io` `HttpClient` to make a `POST` request to the server. Below is a sample function you can use for silent logging, which gracefully handles potential connection errors.

```dart
import 'dart:io';

/// Logs a message to the dls server silently.
Future<void> logToDLSSilently(String logMessage) async {
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:8080/log'));
    request.headers.contentType = ContentType.text;
    request.write(logMessage);
    await request.close();
  } catch (_) {
    // Optionally handle the error, but this function is designed to fail silently.
  }
}

// Example usage:
void main() {
  logToDLSSilently('My first log message!');
}
```

This method ensures that your application continues to run smoothly even if the `dls` server is not active.

