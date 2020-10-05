package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strings"

	"gopkg.in/yaml.v2"
)

// RouteConfig is the entirety of managed RouteSets.
//
// The indexing of RouteSets nested map is like this:
//
//   routeConfig.RouteSets["my-fw-hostname"].Routes["route-id"]
//
// The "my-fw-hostname" identifies the device that is reporting healthcheck results
// for some chakra and *not* the device that actually failed/recovered.
//
// The "route-id" is an arbitrary string.
type RouteConfig struct {
	Config    AppConfig           `yaml:"config"`
	RouteSets map[string]RouteSet `yaml:"route_sets"`
}

// AppConfig stores various configuration items.
type AppConfig struct {
	BasicAuth string `yaml:"http_basic_auth"`
}

// RouteSet contains routes that always switch together. The intention
// is to keep routing symmetrical, so if a route appears east-to-west,
// a corresponding route needs to appear west-to-east, so that traffic
// uses the same router bi-directionally.
type RouteSet struct {
	// Chakras are the points where the health is measured. They are typically gateways, like "10.200.1.1", "10.200.4.1"
	Chakras []string         `yaml:"chakras"`
	Routes  map[string]Route `yaml:"routes"`
}

// Route is a single network route in GCP.
type Route struct {
	VPC         string `yaml:"vpc"`
	DestRange   string `yaml:"dest_range"`
	Name        string `yaml:"name"`
	NextHopIP   string `yaml:"next_hop_ip"`
	SubjectTags string `yaml:"subject_tags"`
	Priority    int    `yaml:"priority"`
}

// UnmarshalYAML implements yaml.UnUnmarshal interface in order to assert
// that the key fields are not missing or empty.
func (r *Route) UnmarshalYAML(unmarshal func(interface{}) error) error {
	type plain Route
	err := unmarshal((*plain)(r))
	if err == nil {
		if r.VPC == "" {
			return fmt.Errorf("yaml field `vpc` cannot be empty")
		}
		if r.DestRange == "" {
			return fmt.Errorf("yaml field `dest_range` cannot be empty")
		}
		if r.Name == "" {
			return fmt.Errorf("yaml field `name` cannot be empty")
		}
		if r.NextHopIP == "" {
			return fmt.Errorf("yaml field `next_hop_ip` cannot be empty")
		}
		if r.SubjectTags == "" {
			return fmt.Errorf("yaml field `subject_tags` cannot be empty")
		}
		if r.Priority == 0 {
			return fmt.Errorf("yaml field `priority` cannot be zero")
		}
	}
	return err
}

func basicAuth() string {
	buf := strings.Builder{}
	buf.WriteString("Basic ")
	buf.WriteString(routeConfig.Config.BasicAuth)
	return buf.String()
}

var routeConfig = &RouteConfig{Config: AppConfig{BasicAuth: "testtoken"}}

func readRouteConfig(filename string) *RouteConfig {
	c := &RouteConfig{}

	yamlFile, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalf("reading config: %v", err)
	}
	err = yaml.Unmarshal(yamlFile, c)
	if err != nil {
		log.Fatalf("cannot unmarshal data: %v", err)
	}

	return c
}
