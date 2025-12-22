package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class TransferServiceApplication {

	@PostMapping("/api/transfer")
	public String transfer() {
		// Placeholder for transfer logic
		return "Transfer completed successfully.";
	}

	public static void main(String[] args) {
		SpringApplication.run(TransferServiceApplication.class, args);
	}

}
