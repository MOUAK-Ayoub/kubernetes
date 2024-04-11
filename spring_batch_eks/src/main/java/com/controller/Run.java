package com.controller;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.item.database.JdbcBatchItemWriter;
import org.springframework.batch.item.database.builder.JdbcBatchItemWriterBuilder;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.Resource;

import javax.sql.DataSource;

@SpringBootApplication
@EnableBatchProcessing
public class Run {

    @Value("${spring.jobs.jobCsv.filename}")
    public Resource resource;

    public static void main(String[] args) {
        SpringApplication.run(Run.class, args);
    }



    @Bean
    public FlatFileItemReader<Person> itemReader() {
        return new FlatFileItemReaderBuilder<Person>()
                .name("personItemReader")
                .resource(resource)
                .delimited()
                .names("firstname", "lastname")
                .targetType(Person.class)
                .build();
    }

    @Bean
    public JdbcBatchItemWriter<Person> itemWriter(DataSource dataSource) {
        return new JdbcBatchItemWriterBuilder<Person>()
                .dataSource(dataSource)
                .sql("INSERT INTO PEOPLE (FIRST_NAME, LAST_NAME) VALUES (:firstname, :lastname)")
                .beanMapped()
                .build();
    }

    @Bean
    public Job jobCsv(JobBuilderFactory jobs, StepBuilderFactory steps,
                      DataSource dataSource) {
        return jobs.get("job")
                .start(steps.get("step")
                        .<Person, Person>chunk(3)
                        .reader(itemReader())
                        .writer(itemWriter(dataSource))
                        .build())
                .build();
    }

}
