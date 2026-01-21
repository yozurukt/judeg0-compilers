
public class Main {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String name = reader.readLine();
        // BigInteger requires java.math.* which is auto-imported by our wrapper
        BigInteger bi = new BigInteger("1");
        System.out.printf("Hello, %s\n", name);
    }
}
