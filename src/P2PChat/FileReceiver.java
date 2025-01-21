package P2PChat;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

class FileReceiver extends Thread {
    private InputStream in;;

    public FileReceiver(InputStream inputStream) {
        this.in = inputStream;
    }

    @Override
    public void run() {

        String fileName = ""; 
        long fileSize;
        try {
            // Read the file name
            fileName = ((DataInputStream) in).readUTF();
            System.out.println("Receiving file: " + fileName);

            // Read the file size
            fileSize = ((DataInputStream) in).readLong();
            System.out.println("File size: " + fileSize + " bytes");


        // Specify the directory where files will be saved
        File saveDir = new File("received_files"); // Directory for saving files
        if (!saveDir.exists()) {
            saveDir.mkdirs(); // Create directory if it doesn't exist
        }

        // Create the file with the original name in the save directory
        File receivedFile = new File(saveDir, "received_" + System.currentTimeMillis() + "_" + fileName);

        // Write the file data
        try (FileOutputStream fos = new FileOutputStream(receivedFile);){
            byte[] buffer = new byte[4096];
            long bytesRead = 0;
            while (bytesRead < fileSize) {
                int read = in.read(buffer, 0, (int) Math.min(buffer.length, fileSize - bytesRead));
                fos.write(buffer, 0, read);
                bytesRead += read;
            }
            System.out.println("File received and saved successfully at: " + receivedFile.getAbsolutePath());
        }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
}
