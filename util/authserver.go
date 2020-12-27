package main

import (
	"github.com/gorilla/mux"
	"net/http"
    "crypto/subtle"
    "log"
)


// use provides a cleaner interface for chaining middleware for single routes.
// Middleware functions are simple HTTP handlers (w http.ResponseWriter, r *http.Request)
//
//  r.HandleFunc("/login", use(loginHandler, rateLimit, csrf))
//  r.HandleFunc("/form", use(formHandler, csrf))
//  r.HandleFunc("/about", aboutHandler)
// 
// See https://gist.github.com/elithrar/7600878#comment-955958 for how to extend it to suit simple http.Handler's
func use(h http.HandlerFunc, middleware ...func(http.HandlerFunc) http.HandlerFunc) http.HandlerFunc {
	for _, m := range middleware {
		h = m(h)
	}

	return h
}

func myHandler(w http.ResponseWriter, r *http.Request) {

	w.Write([]byte("Authenticated!"))
	return
}

type BasicAuthMiddleware struct {
    username, password, realm string
}

func (bam *BasicAuthMiddleware) Init(user, pw, realm string) {
    bam.username = user
    bam.password = pw
    bam.realm = realm
}

func (bam *BasicAuthMiddleware) Middleware(next http.HandlerFunc) http.HandlerFunc {
   return http.HandlerFunc(
     func(w http.ResponseWriter, r *http.Request) { 
        user, pass, ok := r.BasicAuth()
        if !ok || 
            subtle.ConstantTimeCompare([]byte(user), []byte(bam.username)) != 1 || 
            subtle.ConstantTimeCompare([]byte(pass), []byte(bam.password)) != 1 {

            w.Header().Set("WWW-Authenticate", `Basic realm="`+bam.realm+`"`)
            w.WriteHeader(401)
            w.Write([]byte("user Unauthorised.\n"))
            return
        }

        log.Printf("Authenticated user %s\n", user)
        next.ServeHTTP(w,r)
        return 
     })
}

func main() {

    username := "apiuser"
    password := "apipass"
    realm    := "restricted"

	r := mux.NewRouter()
    bam := BasicAuthMiddleware{}
    bam.Init(username, password, realm)
    //r.Use(bam.Middleware)

	r.HandleFunc("/form", use(myHandler, bam.Middleware))
	http.Handle("/", r)

	http.ListenAndServe(":9900", nil)
}
