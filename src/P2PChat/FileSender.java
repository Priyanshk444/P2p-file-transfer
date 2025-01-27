package P2PChat;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Scanner;

public class FileSender extends Thread {
    private DataOutputStream out;
    private Scanner scanner;

    public FileSender(DataOutputStream outputStream, Scanner scanner) {
        this.out = outputStream;
        this.scanner = scanner;
    }

    @Override
    public void run() {
        while (true) {
            // Get the file or folder path from the user
            System.out.print("Enter the file/folder path to send: ");
            String filePath = scanner.nextLine();

            File file = new File(filePath);

            if (!file.exists()) {
                System.out.println("File or folder not found!");
                return;
            }

            try {
                if (file.isDirectory()) {
                    // Send a signal indicating a folder is being sent
                    out.writeUTF("FOLDER");
                    sendFolder(file, file.getAbsolutePath());
                } else {
                    // Send a single file
                    out.writeUTF("FILE");
                    sendFile(file);
                }

                System.out.println("File/folder sent successfully!");

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void sendFolder(File folder, String basePath) throws IOException {
        File[] files = folder.listFiles();
        if (files == null) return;

        for (File file : files) {
            if (file.isDirectory()) {
                // Send directory metadata
                out.writeUTF("DIR"); // Signal for directory
                out.writeUTF(file.getAbsolutePath().substring(basePath.length() + 1)); // Relative path
                sendFolder(file, basePath); // Recursive call
            } else {
                // Send file metadata
                out.writeUTF("FILE");
                out.writeUTF(file.getAbsolutePath().substring(basePath.length() + 1)); // Relative path
                sendFile(file); // Send the file
            }
        }
        // Signal the end of the folder's files
        out.writeUTF("END_DIR");
    }

    private void sendFile(File file) throws IOException {
        // Send file name and size
        out.writeUTF(file.getName());
        out.writeLong(file.length());

        // Send file data
        try (FileInputStream fis = new FileInputStream(file)) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
