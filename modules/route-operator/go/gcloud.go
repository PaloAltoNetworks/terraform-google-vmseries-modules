package main

import (
	"fmt"
	"io"
	"log"
	"os/exec"
	"strings"
)

// NewRouteCmd is a wrapper over an exec.Cmd intended to run `gcloud` and dynamically add or remove Routes on the GCP.
func NewRouteCmd(onPathMonitorFailure bool, deviceName, chakra []byte) {
	deviceNameStr := string(deviceName)
	chakraStr := string(chakra)
	if routeConfig.RouteSets == nil {
		log.Printf("Route definitions not found for path_monitoring")
		return
	}
	r2, found := routeConfig.RouteSets[deviceNameStr]
	if !found {
		log.Printf("No route definitions for device hostname %q", deviceNameStr)
		return
	}
	found = false
	for _, ch := range r2.Chakras {
		if ch == chakraStr {
			found = true
		}
	}
	if !found {
		log.Printf("No route definitions for chakra %q on device %q", chakraStr, deviceNameStr)
		return
	}
	for _, r := range routeConfig.RouteSets[deviceNameStr].Routes {
		cmdl := []string{"gcloud", "compute", "routes", "delete", r.Name, "--quiet"}
		if onPathMonitorFailure {
			cmdl = []string{"gcloud", "compute", "routes", "create", r.Name, "--destination-range", r.DestRange, "--next-hop-address", r.NextHopIP, "--network", r.VPC, "--priority", fmt.Sprintf("%d", r.Priority), "--tags", r.SubjectTags}
		}
		cmd := exec.Command(cmdl[0], cmdl[1:]...)
		buf := new(strings.Builder)
		for _, v := range cmdl {
			buf.WriteString(fmt.Sprintf(" %s", v))
		}
		cmdstr := buf.String()

		go func(cmd *exec.Cmd) {
			stderr, err := cmd.StderrPipe()
			if err != nil {
				log.Print(err)
				return
			}

			err = cmd.Start()
			if err != nil {
				log.Print(err)
				return
			}
			log.Printf("Started %q", cmdstr)

			buf := &strings.Builder{}
			_, err = io.Copy(buf, stderr)
			if err != nil {
				log.Print(err)
				return
			}
			if stderrstr := buf.String(); stderrstr != "" {
				log.Printf("Command %q returned stderr output: %q", cmdstr, stderrstr)
			}

			if err := cmd.Wait(); err != nil {
				log.Printf("Command %q finished with error: %v", cmdstr, err)
				return
			}
			log.Print("Command succeeded")
		}(cmd)
	}
}
