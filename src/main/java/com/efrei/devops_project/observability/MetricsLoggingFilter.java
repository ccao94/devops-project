package com.efrei.devops_project.observability;

import tools.jackson.databind.ObjectMapper;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.servlet.HandlerMapping;

import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

@Component
public class MetricsLoggingFilter extends OncePerRequestFilter {

    private final MeterRegistry registry;
    private final ObjectMapper objectMapper;

    public MetricsLoggingFilter(MeterRegistry registry, ObjectMapper objectMapper) {
        this.registry = registry;
        this.objectMapper = objectMapper;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        Timer.Sample sample = Timer.start(registry);
        try {
            chain.doFilter(request, response);
        } finally {
            String method = request.getMethod();
            String route = resolveRoute(request);
            int status = response.getStatus();

            Counter.builder("http_requests")
                    .description("Total HTTP requests")
                    .tags("method", method, "route", route, "status", String.valueOf(status))
                    .register(registry)
                    .increment();

            sample.stop(Timer.builder("http_request_duration")
                    .description("Request latency in seconds")
                    .tags("method", method, "route", route)
                    .serviceLevelObjectives(
                            Duration.ofMillis(50), Duration.ofMillis(100), Duration.ofMillis(300),
                            Duration.ofMillis(500), Duration.ofSeconds(1), Duration.ofSeconds(2))
                    .register(registry));

            Map<String, Object> logLine = new LinkedHashMap<>();
            logLine.put("timestamp", Instant.now().toString());
            logLine.put("level", status >= 500 ? "error" : "info");
            logLine.put("method", method);
            logLine.put("path", request.getRequestURI());
            logLine.put("status", status);
            System.out.println(objectMapper.writeValueAsString(logLine));
        }
    }

    private String resolveRoute(HttpServletRequest request) {
        Object pattern = request.getAttribute(HandlerMapping.BEST_MATCHING_PATTERN_ATTRIBUTE);
        return pattern != null ? pattern.toString() : request.getRequestURI();
    }
}