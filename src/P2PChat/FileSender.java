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
            // Get the file/folder path from the user
            System.out.print("Enter the file or folder path to send: ");
            String path = scanner.nextLine();

            File file = new File(path);

            if (!file.exists()) {
                System.out.println("File/Folder not found!");
                return;
            }

            try {
                // Check if it's a file or folder
                if (file.isFile()) {
                    sendFile(file, "");
                } else if (file.isDirectory()) {
                    sendFolder(file, file.getName());
                }
                System.out.println("File/Folder sent successfully!");

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void sendFile(File file, String relativePath) throws IOException {
        // Send a marker to indicate this is a file
        out.writeUTF("FILE");
        // Send the relative path for folder reconstruction
        out.writeUTF(relativePath + File.separator + file.getName());
        // Send the file size
        out.writeLong(file.length());

        // Send the file data
        try (FileInputStream fis = new FileInputStream(file)) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }

    private void sendFolder(File folder, String relativePath) throws IOException {
        // Send a marker to indicate this is a folder
        out.writeUTF("FOLDER");
        // Send the folder name or relative path
        out.writeUTF(relativePath);

        // Recursively process all contents of the folder
        File[] files = folder.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isFile()) {
                    sendFile(file, relativePath);
                } else if (file.isDirectory()) {
                    sendFolder(file, relativePath + File.separator + file.getName());
                }
            }
        }
    }
}
