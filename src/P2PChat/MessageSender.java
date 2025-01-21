package P2PChat;
import java.io.PrintWriter;
import java.util.Scanner;

/** Class for sending messages */
class MessageSender implements Runnable {
    private PrintWriter output;
    private Scanner scanner;

    public MessageSender(PrintWriter output, Scanner scanner) {
        this.output = output;
        this.scanner = scanner;
    }

    @Override
    public void run() {
        try {
            String message;
            while (true) {
                System.out.print("You: ");
                message = scanner.nextLine();
                output.println(message);
            }
        } catch (Exception e) {
            System.out.println("Error sending message: " + e.getMessage());
        }
    }
}
