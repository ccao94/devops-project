package com.efrei.devops_project.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    // used by Docker, Kubernetes probes and monitoring later
    @GetMapping("/health")
    public String health() {
        return "KO";
    }
}