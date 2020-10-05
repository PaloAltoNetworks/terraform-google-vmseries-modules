package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/julienschmidt/httprouter"
)

func TestGet(t *testing.T) {
	r := httprouter.New()
	s := &server{}
	s.InstallOn(r)

	t.Run("returns 404 on GET /whatever", func(t *testing.T) {
		want := 404

		request, _ := http.NewRequest(http.MethodGet, "/whatever", nil)
		response := httptest.NewRecorder()

		r.ServeHTTP(response, request)
		got := response.Code

		if got != want {
			t.Errorf("response.Code got %v, but expected %v", got, want)
		}
	})
}

func TestPost(t *testing.T) {
	tests := []struct {
		name                   string
		body                   string
		authheader             string
		want                   int
		wantPathMonitorFailure bool
		wantCmdDeviceName      string
		wantCmdSubnetGateway   string
	}{{
		"returns 204 on good POST path-monitor-failure",
		"  event_id:path-monitor-failure, object:., with next hop 10.200.0.1. Meh device_name:fw-b</description></entry></request>",
		basicAuth(),
		204,
		true,
		"fw-b",
		"10.200.0.1",
	}, {
		"returns 403 on POST with wrong user/pass",
		"  event_id:path-monitor-failure, object:., with next hop 10.200.0.1. Meh device_name:fw-b</description></entry></request>",
		"Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
		403,
		false,
		"",
		"",
	}, {
		"returns 401 on unauthenticated POST",
		"  event_id:path-monitor-failure, object:., with next hop 10.200.0.1. Meh device_name:fw-b</description></entry></request>",
		"",
		401,
		false,
		"",
		"",
	}, {
		"returns 204 on good POST path-monitor-failure with newlines",
		" event_id:path-monitor-failure \n object:.  with next hop 10.0.0.099. Meh\r\n device_name:fw",
		basicAuth(),
		204,
		true,
		"fw",
		"10.0.0.099",
	}, {
		"returns 204 on good POST path-monitor-recovery",
		" event_id:path-monitor-recovery, object:.  with next hop 10.200.0.1 recovered\r\n device_name:fw-b",
		basicAuth(),
		204,
		false,
		"fw-b",
		"10.200.0.1",
	}, {
		"returns 409 on good POST test",
		" event_id:general, object:test, opaque:, ",
		basicAuth(),
		409,
		false,
		"",
		"",
	}}
	for _, tt := range tests {

		gotPathMonitorFailure := false
		gotCmdDeviceName := []byte{}
		gotCmdSubnetGateway := []byte{}

		r := httprouter.New()
		s := &server{func(onPathMonitorFailure bool, deviceName, subnetGateway []byte) {
			gotPathMonitorFailure = onPathMonitorFailure
			gotCmdDeviceName = deviceName
			gotCmdSubnetGateway = subnetGateway
		}}
		s.InstallOn(r)
		t.Run(tt.name, func(t *testing.T) {
			buf := strings.NewReader(tt.body)
			request, _ := http.NewRequest(http.MethodPost, "/api/path-monitor/panos-event", buf)
			if tt.authheader != "" {
				request.Header["Authorization"] = []string{tt.authheader}
			}
			response := httptest.NewRecorder()

			r.ServeHTTP(response, request)
			got := response.Code

			if got != tt.want {
				t.Errorf("response.Code: got %v, but expected %v", got, tt.want)
			}
			if string(gotCmdDeviceName) != tt.wantCmdDeviceName {
				t.Errorf("route command execution deviceName: got %v, but expected %v", string(gotCmdDeviceName), tt.wantCmdDeviceName)
			}
			if string(gotCmdSubnetGateway) != tt.wantCmdSubnetGateway {
				t.Errorf("route command execution subnetGateway: got %v, but expected %v", string(gotCmdSubnetGateway), tt.wantCmdSubnetGateway)
			}
			if gotPathMonitorFailure != tt.wantPathMonitorFailure {
				t.Errorf("route command execution onPathMonitorFailure: got %v, but expected %v", gotPathMonitorFailure, tt.wantPathMonitorFailure)
			}
		})
	}
}
