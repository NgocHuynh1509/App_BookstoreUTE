package com.hcmute.bookstore;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class UteBookstoreBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(UteBookstoreBackendApplication.class, args);
	}

}
