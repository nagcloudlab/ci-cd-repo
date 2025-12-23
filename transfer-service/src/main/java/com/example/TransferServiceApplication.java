package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import lombok.Data;

@Data
class TransferRequest {
	private String fromAccount;
	private String toAccount;
	private double amount;

	// Getters and Setters
	public String getFromAccount() {
		return fromAccount;
	}

	public void setFromAccount(String fromAccount) {
		this.fromAccount = fromAccount;
	}

	public String getToAccount() {
		return toAccount;
	}

	public void setToAccount(String toAccount) {
		this.toAccount = toAccount;
	}

	public double getAmount() {
		return amount;
	}

	public void setAmount(double amount) {
		this.amount = amount;
	}
}

@Data
class TransferResponse {
	private String status;
	private String transactionId;

	// Getters and Setters
	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
	}
}

@SpringBootApplication
@RestController
public class TransferServiceApplication {

	@PostMapping("/api/transfer")
	public TransferResponse transfer(
			@RequestBody TransferRequest request) {
		// Simulate processing the transfer
		TransferResponse response = new TransferResponse();
		response.setStatus("SUCCESS");
		response.setTransactionId("TXN" + System.currentTimeMillis());
		return response;
	}

	public static void main(String[] args) {
		SpringApplication.run(TransferServiceApplication.class, args);
	}

}
