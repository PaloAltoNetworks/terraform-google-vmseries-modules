package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"regexp"
	"runtime/debug"

	"github.com/gorilla/handlers"
	"github.com/julienschmidt/httprouter"
	"github.com/pkg/errors"
)

func main() {
	routeConfig = readRouteConfig("./ro_api_config.yaml")

	log.Printf("Parsed config: %v", routeConfig)
	log.Print("------------ end of config --------------")

	r := httprouter.New()
	r.PanicHandler = panicHandler

	s := &server{NewRouteCmdFunc: NewRouteCmd}
	s.InstallOn(r)

	h := handlers.CombinedLoggingHandler(os.Stdout, r)
	log.Print("Started http server on *:3000")
	go func() { log.Fatalf("%v", http.ListenAndServe(":3000", h)) }()
	log.Print("Started https server on *:8443")
	log.Fatalf("%v", http.ListenAndServeTLS(":8443", "bundle.pem", "key.pem", h))
}

func panicHandler(w http.ResponseWriter, r *http.Request, err interface{}) {
	log.Printf("panic serving path %v: %v\n%s", r.URL.Path, err, debug.Stack())
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusInternalServerError)
	w.Write([]byte("HTTP 500: internal server error.\n"))
}

// Server is an interface that can install handlers onto any httprouter.Router.
type Server interface {
	InstallOn(r *httprouter.Router)
}

type server struct {
	NewRouteCmdFunc func(onPathMonitorFailure bool, deviceName, subnetGateway []byte)
}

func (s *server) InstallOn(r *httprouter.Router) {
	// when passing a func, the *s will be carried within its closure
	r.GET("/api/path-monitor/:widget_id", s.getWidget)
	r.POST("/api/path-monitor/panos-event", s.postPanosEvent)
}

// Error encapsulates an error so it could be returned encoded as JSON.
type Error struct {
	Error string `json:"error"`
}

func errorJSON(w http.ResponseWriter, httpcode int, errmsg string) {
	respondJSON(w, httpcode, &Error{errmsg})
}

// respondJSON writes out http headers then the response body marshaled to JSON
// It expects `w` not to have written out anything yet.
//
// Intended to be primarily called from inside http.HandlerFunc.
// Like http.HandlerFunc, it panics on errors.
func respondJSON(w http.ResponseWriter, httpcode int, response interface{}) {
	w.Header().Set("Content-Type", "application/json")
	// Anyway, code 200 is implicitly written later on.
	// We don't write it out now explicitly, we give a chance for the panic handler
	// to write out another code, like 500 Internal Server Error.
	// This should also handle other response codes, what if panic happens during 302 Redirect.
	if httpcode != 200 {
		w.WriteHeader(httpcode)
	}
	if response == nil {
		return
	}
	err := json.NewEncoder(w).Encode(response)
	if err != nil {
		panic(err)
	}
}

func (s *server) getWidget(w http.ResponseWriter, req *http.Request, params httprouter.Params) {
	log.Printf("the url ends in %q", params.ByName("widget_id"))
	wid := params.ByName("widget_id")
	if wid == "unknown" {
		errorJSON(w, 404, "unknown record")
		return
	}
	respondJSON(w, 200, wid)
}

func (s *server) postPanosEvent(w http.ResponseWriter, req *http.Request, params httprouter.Params) {
	buf := make([]byte, 4096)

	h, found := req.Header["Authorization"]
	if !found {
		errorJSON(w, 401, "authorization required")
		return
	}

	passfound := false
	for _, v := range h {
		if v == basicAuth() {
			passfound = true
			break
		}
		log.Printf("Authorization header did not match: %q", v)
	}

	if !passfound {
		errorJSON(w, 403, "unauthorized")
		return
	}

	len, err := req.Body.Read(buf)
	if err != nil && err != io.EOF {
		errors.WithStack(err)
		errorJSON(w, 422, "cannot read body")
		return
	}

	str := string(buf[:len])
	log.Printf("Body read as %#v", str)

	/*
		POST /api/path-monitor/panos-event HTTP/1.1
		Host: 10.100.0.8:3000
		Accept: ...
		content-type: text/xml
		Content-Length: ...

		<request><entry><short_description>SYSTEM, generated at 2020/09/07 05:20:18 </short_description>
				<description> domain:1, receive_time:2020/09/07 05:20:18, serial:007258000131772, type:SYSTEM, subtype:routing, config_ver:0, time_generated:2020/09/07 05:20:18, vsys:, event_id:path-monitor-failure, object:VR1, format:0, id:2, module:general, severity:critical, opaque:"Path monitoring failed for static route destination 100.64.0.6/32 with next hop 10.200.0.1. Route removed.", seqno:2609, actionflags:0x0,  dg_hier_level_1:0, dg_hier_level_2:0, dg_hier_level_3:0, dg_hier_level_4:0, vsys_name:, device_name:sabre-fw01-us-central1b</description></entry></request>
	*/

	if f := regexp.MustCompile(`(?s) event_id:path-monitor-failure.* with next hop (.*)[.] .* device_name:([a-zA-Z0-9.-]*)`).FindSubmatch(buf); f != nil {
		log.Printf("got path-monitor-failure event nh %q on device %q", f[1], f[2])
		s.NewRouteCmdFunc(true, f[2], f[1])
		respondJSON(w, 204, nil)
		return
	}

	if f := regexp.MustCompile(`(?s) event_id:path-monitor-recovery.* with next hop (.*) recovered.* device_name:([a-zA-Z0-9.-]*)`).FindSubmatch(buf); f != nil {
		log.Printf("got path-monitor-recovery event nh %q on device %q", f[1], f[2])
		s.NewRouteCmdFunc(false, f[2], f[1])
		respondJSON(w, 204, nil)
		return
	}

	if f := regexp.MustCompile(`(?s) event_id:general.* object:test.* opaque:,`).FindSubmatch(buf); f != nil {
		log.Printf("got test event")
		// For an external test, as can be run from Panos Device -> Server Profiles -> HTTP -> Edit -> Payload Format -> System -> Send Test Log
		// the HTTP 409 identifies a correct result. Any other HTTP response, including even 200 or 301, is an incorrect result.
		respondJSON(w, 409, "test correct")
		return
	}

	errorJSON(w, 400, "bad request")
}
