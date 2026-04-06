package email

import (
	"crypto/tls"
	"fmt"
	"net/smtp"
	"os"
)

func SendNotificationEmail(toEmail string, subject string, body string) error {
	from := os.Getenv("SMTP_EMAIL")
	password := os.Getenv("SMTP_PASSWORD")
	host := os.Getenv("SMTP_HOST") // e.g. smtp.gmail.com
	port := os.Getenv("SMTP_PORT") // e.g. 587 or 465

	if from == "" || password == "" || host == "" || port == "" {
		// Mock behavior if not configured
		fmt.Printf("[Mock Email] To: %s | Subject: %s | Body: %s\n", toEmail, subject, body)
		return nil
	}

	auth := smtp.PlainAuth("", from, password, host)
	msg := []byte("To: " + toEmail + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"\r\n" +
		body + "\r\n")

	addr := fmt.Sprintf("%s:%s", host, port)

	if port == "465" {
		conn, err := tls.Dial("tcp", addr, &tls.Config{InsecureSkipVerify: true})
		if err != nil {
			return err
		}
		c, err := smtp.NewClient(conn, host)
		if err != nil {
			return err
		}
		if err = c.Auth(auth); err != nil {
			return err
		}
		if err = c.Mail(from); err != nil {
			return err
		}
		if err = c.Rcpt(toEmail); err != nil {
			return err
		}
		w, err := c.Data()
		if err != nil {
			return err
		}
		_, err = w.Write(msg)
		if err != nil {
			return err
		}
		err = w.Close()
		if err != nil {
			return err
		}
		return c.Quit()
	}

	// Default to STARTTLS
	return smtp.SendMail(addr, auth, from, []string{toEmail}, msg)
}
