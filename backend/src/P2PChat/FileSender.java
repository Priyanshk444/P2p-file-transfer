package P2PChat;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Scanner;

public class FileSender extends Thread {
    DataOutputStream out;
    Scanner scanner;

    public FileSender(DataOutputStream outputStream, Scanner scanner) {
        this.out = outputStream;
        this.scanner = scanner;
    }

    @Override
    public void run() {
        while (true) {
            // Get the file path from the user
            System.out.print("Enter the file path to send: ");
            String filePath = scanner.nextLine();

            // Open the file
            File file = new File(filePath);
            if (!file.exists()) {
                System.out.println("File not found!");
                return;
            }

            try {
                // Send the file name
                out.writeUTF(file.getName());
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

                System.out.println("file sent successfully!");

            } catch (IOException e) {
                e.printStackTrace();
            }

        }
    }
}
