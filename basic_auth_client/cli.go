package main

import (
    sw  "swagger-codegen-example2/basic_auth"
    "fmt"
    "golang.org/x/net/context"
	"encoding/base64"
)

func basicAuth(username, password string) string {
	auth := username + ":" + password
	return base64.StdEncoding.EncodeToString([]byte(auth))
}

func  main() {

    user := "apiuser"
    pass := "apipass"

    cfg := &sw.Configuration{

		BasePath:      "http://localhost:8080/v1",
		DefaultHeader: make(map[string]string),
		UserAgent:     "Swagger-Codegen/1.0.0/go",
	}

    testApi := sw.NewAPIClient(cfg)

    ctx := context.WithValue(context.Background(), sw.ContextBasicAuth, 
               sw.BasicAuth{ user, pass, })

    // (string, *http.Response, error) 
    result, r, err := 
         testApi.DefaultApi.CheckHealth(ctx) 

    // Test error
    if err != nil {
        fmt.Println("Pets by Tags Error:", err)
    }

    // Test HTTP Response code
    if r.StatusCode == 200 {
        fmt.Printf("result=%v\n", result)
        fmt.Printf("http_response=%v\n", r)
    }

    if (err != nil) {
        fmt.Printf("http_response=%v\n", r)
        fmt.Printf("err=%v\n", err)
    }
}

