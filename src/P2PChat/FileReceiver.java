package P2PChat;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class FileReceiver extends Thread {
    private static final String SHARED_FOLDER = "shared folder"; // Base folder for all received files
    private DataInputStream in;

    public FileReceiver(DataInputStream inputStream) {
        this.in = inputStream;
    }

    @Override
    public void run() {
        try {
            // Ensure the shared folder exists
            File sharedFolder = new File(SHARED_FOLDER);
            if (!sharedFolder.exists()) {
                sharedFolder.mkdirs();
            }

            while (true) {
                // Read the marker to identify if it's a file or folder
                String type = in.readUTF();

                if (type.equals("FILE")) {
                    receiveFile();
                } else if (type.equals("FOLDER")) {
                    createFolder();
                } else {
                    System.out.println("Unknown type received: " + type);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void receiveFile() throws IOException {
        // Read the relative file path
        String relativePath = in.readUTF();
        // Read the file size
        long fileSize = in.readLong();

        // Prepend the shared folder path
        File file = new File(SHARED_FOLDER, relativePath);
        // Ensure parent directories exist
        file.getParentFile().mkdirs();

        try (FileOutputStream fos = new FileOutputStream(file)) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            long remaining = fileSize;

            while (remaining > 0 && (bytesRead = in.read(buffer, 0, (int) Math.min(buffer.length, remaining))) != -1) {
                fos.write(buffer, 0, bytesRead);
                remaining -= bytesRead;
            }
        }

        System.out.println("File received: " + file.getAbsolutePath());
    }

    private void createFolder() throws IOException {
        // Read the relative folder path
        String relativePath = in.readUTF();

        // Prepend the shared folder path
        File folder = new File(SHARED_FOLDER, relativePath);
        // Create the folder if it doesn't exist
        if (folder.mkdirs()) {
            System.out.println("Folder created: " + folder.getAbsolutePath());
        } else {
            System.out.println("Folder already exists: " + folder.getAbsolutePath());
        }
    }
}
