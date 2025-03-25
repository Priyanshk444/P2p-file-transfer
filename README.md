# P2P File Sharing and Chat Application

This is a **CLI-based P2P file-sharing and chat application** built using **Java Sockets**. The app allows direct peer-to-peer communication for both **messaging** and **file transfers**, including folder transfers.

## Features

- **Peer-to-peer messaging**
- **File transfer support** (single file and entire folders)
- **On-demand connectivity** (connect as a listener or initiator)
- **Multiple concurrent peer connections** (supports chat and file transfer in parallel)

## Technologies Used

- **Java Sockets** - Networking
- **Multithreading** - Concurrent messaging & file transfer
- **I/O Streams** - File transfer & real-time communication

## Getting Started

### Prerequisites

- **Java 11+** installed
- Basic knowledge of Java

### Clone the Repository

```bash
git clone https://github.com/your-username/p2p-chat-app.git
cd p2p-chat-app
```

### Running the Application

1. **Compile the Java files**

   ```bash
   javac P2PChat/*.java
   ```

2. **Start the application**

   ```bash
   java P2PChat.P2PChat
   ```

3. **Choose Mode:**

   - Press **1** to act as a **listener** (wait for connections)
   - Press **2** to act as a **connector** (connect to a peer)

## Usage

### Messaging

- Once connected, type messages and press `Enter` to send.
- Messages will be received in real-time.

### File Transfer

- Enter the full path of the file/folder you want to send.
- The receiver's shared folder will store received files.

## File Structure

```
P2PChat/
│── P2PChat.java         # Main class handling peer-to-peer connections
│── MessageSender.java   # Handles sending messages
│── MessageReceiver.java # Handles receiving messages
│── FileSender.java      # Handles sending files & folders
│── FileReceiver.java    # Handles receiving files & folders
```

## Security Considerations

- Currently, **no encryption** is implemented.
- Future enhancements may include **SSL encryption** for secure transmission.

## Author

Priyansh Kumar



