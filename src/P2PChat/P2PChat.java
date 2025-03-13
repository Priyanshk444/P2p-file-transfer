package P2PChat;

import java.io.*;
import java.net.*;
import java.util.Scanner;

public class P2PChat {
    static String ip = "192.168.107.144";
    static String destinationPath = "D:\socket messaging app\received_files"; 

    public static void main(String[] args) throws IOException {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Enter '1' to act as a listener or '2' to act as a connector:");
        int choice = scanner.nextInt();
        scanner.nextLine(); // Consume newline

        if (choice == 1) {
            startListener(scanner);
        } else if (choice == 2) {
            startConnector(scanner);
        } else {
            System.out.println("Invalid choice. Exiting.");
        }
    }

    private static void startListener(Scanner scanner) {
        try (ServerSocket serverSocket = new ServerSocket(12345)) {
            System.out.println("Waiting for a peer to connect...");
            Socket socket = serverSocket.accept();
            System.out.println("Client connected: " + socket.getInetAddress());

            System.out.println("Press 1 for chat ,Press 2 for file transfer");
            int choice = scanner.nextInt();
            scanner.nextLine();

            if (choice == 1) {
                handleMessageCommunication(socket, scanner);
            } else if (choice == 2) {
                handleFileTransfer(socket, scanner);
            } else {
                System.out.println("Invalid choice!!");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void startConnector(Scanner scanner) {

        try (Socket socket = new Socket(ip, 12345)) {
            System.out.println("Connected to the peer!");

            System.out.println("Press 1 for chat ,Press 2 for file transfer");
            int choice = scanner.nextInt();
            scanner.nextLine();

            if (choice == 1) {
                handleMessageCommunication(socket, scanner);
            } else if (choice == 2) {
                handleFileTransfer(socket, scanner);
            } else {
                System.out.println("Invalid choice!!");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void handleMessageCommunication(Socket socket, Scanner scanner) {
        try (
                BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                PrintWriter output = new PrintWriter(socket.getOutputStream(), true)) {
            // Thread for receiving messages
            MessageReceiver receiveThread = new MessageReceiver(input);
            // Thread for sending messages
            Thread sendThread = new Thread(new MessageSender(output, scanner));

            receiveThread.start();
            sendThread.start();

            // Wait for threads to finish
            receiveThread.join();
            sendThread.join();

        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }

    private static void handleFileTransfer(Socket socket, Scanner scanner) {
        try (DataOutputStream out = new DataOutputStream(socket.getOutputStream());
                DataInputStream in = new DataInputStream(socket.getInputStream())) {

            // Thread for sending message
            Thread sendThread = new Thread(new FileSender(out, scanner));
            // Thread for receiving message
            Thread receiveThread = new Thread(new FileReceiver(in));

            receiveThread.start();
            sendThread.start();

            // Wait for threads to finish
            receiveThread.join();
            sendThread.join();

        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }

    }
}
