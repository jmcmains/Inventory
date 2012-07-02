ActionMailer::Base.smtp_settings = {
	address: "smtp.gmail.com",
	port: 587,
	domain: "rubberbanditz.com",
	user_name: "info@rubberbanditz.com",
	password: "rubber123",
	authentication: "plain",
	enable_starttls_auto: true
}
