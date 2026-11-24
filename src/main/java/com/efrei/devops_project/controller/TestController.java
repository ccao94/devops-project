package com.efrei.devops_project.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

@RestController
public class TestController {

    @GetMapping("/slow")
    public Map<String, Object> slow() throws InterruptedException {
        long delayMs = ThreadLocalRandom.current().nextLong(0, 2001);
        Thread.sleep(delayMs);
        return Map.of("endpoint", "slow", "delay_ms", delayMs);
    }

    @GetMapping("/error")
    public ResponseEntity<Map<String, Object>> error() {
        if (ThreadLocalRandom.current().nextDouble() < 0.3) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("endpoint", "error", "status", "failed"));
        }
        return ResponseEntity.ok(Map.of("endpoint", "error", "status", "ok"));
    }
}