package main

import (
	"testing"
	"time"
)

func TestParse(t *testing.T) {
	playing := `{"recenttracks":{"track":[{"name":"Song","artist":{"#text":"Band"},"@attr":{"nowplaying":"true"}}]}}`
	idle := `{"recenttracks":{"track":[{"name":"Song","artist":{"#text":"Band"}}]}}`
	empty := `{"recenttracks":{"track":[]}}`
	for _, c := range []struct{ in, want string }{{playing, "Band - Song"}, {idle, ""}, {empty, ""}} {
		got, err := parse([]byte(c.in))
		if err != nil || got != c.want {
			t.Errorf("parse(%s) = %q, %v; want %q", c.in, got, err, c.want)
		}
	}
}

func TestWindow(t *testing.T) {
	now := time.Unix(0, 0)
	if got := window("short", now); got != "short" {
		t.Errorf("short = %q", got)
	}
	long := "A very long artist name - An even longer song title here"
	for i := 0; i < 50; i++ {
		got := window(long, now.Add(time.Duration(i)*step))
		if n := len([]rune(got)); n != width {
			t.Fatalf("step %d: width %d, want %d", i, n, width)
		}
	}
	if window(long, now) == window(long, now.Add(step)) {
		t.Error("window did not advance")
	}
}
