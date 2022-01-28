package com.example

import io.micronaut.context.annotation.Value
import io.micronaut.context.event.ApplicationEventListener
import io.micronaut.discovery.event.ServiceReadyEvent
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import javax.inject.Singleton

@Singleton
class POCSealedSecrets(
        @Value("\${poc.sensitive-data}") private val sensitiveData: String = "!@#$%*()",
) : ApplicationEventListener<ServiceReadyEvent> {
    private val logger: Logger = LoggerFactory.getLogger(javaClass)

    override fun onApplicationEvent(event: ServiceReadyEvent?) {
        logger.info("[com.example.POCSealedSecrets] - sensitive data: $sensitiveData")
    }
}