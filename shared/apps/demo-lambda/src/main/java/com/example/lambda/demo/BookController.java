package com.example.lambda.demo;
import io.micronaut.http.annotation.Body;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Post;

import javax.validation.Valid;
import java.util.UUID;

/**
 * docker run -p 9000:8080 <image name>
 * curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"body":"{\"name\":\"test\"}", "httpMethod":"POST", "path":"/", "isBase64Encoded":false}'
 */
@Controller
public class BookController {

    @Post
    public BookSaved save(@Valid @Body Book book) {
        BookSaved bookSaved = new BookSaved();
        bookSaved.setName(book.getName());
        bookSaved.setIsbn(UUID.randomUUID().toString());
        return bookSaved;
    }
}
