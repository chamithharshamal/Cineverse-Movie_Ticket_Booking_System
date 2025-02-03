package cineverse.connection;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailService {

    public static void sendEmail(String toEmail, String subject, String body) {
        final String fromEmail = "chweerasinghe619@gmail.com"; // Replace with your Gmail address
        final String password = "ecsrhkglxvxlhsch"; // Replace with your Gmail app password

        
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com"); 
        props.put("mail.smtp.port", "465"); 
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true"); 

   
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

       
        session.setDebug(true);

        try {
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(body, "text/html"); // Set email format to HTML

          
            Transport.send(message);
            System.out.println("Email sent successfully to " + toEmail);

        } catch (MessagingException e) {
            e.printStackTrace();
            System.err.println("Error sending email: " + e.getMessage());
        }
    }
}
