package com.example.plantcare;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.test.context.TestConfiguration;

@TestConfiguration(proxyBeanMethods = false)
public class TestPlantCareApplication {

    public static void main(String[] args) {
        SpringApplication.from(PlantCareApplication::main).with(TestPlantCareApplication.class).run(args);
    }

}
