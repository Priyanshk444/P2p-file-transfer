package P2PChat;
import java.io.BufferedReader;
import java.io.IOException;

/** Class for receiving messages */
class MessageReceiver extends Thread {
    private BufferedReader input;

    public MessageReceiver(BufferedReader input) {
        this.input = input;
    }

    @Override
    public void run() {
        try {
            String message;
            while ((message = input.readLine()) != null) {
                System.out.println("Peer: " + message);
            }
        } catch (IOException e) {
            System.out.println("Connection closed.");
        }
    }
}
