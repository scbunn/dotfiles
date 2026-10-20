// nowplaying prints "🔊 Artist - Title" for the track currently playing on
// Last.fm, or nothing at all if nothing is playing. Built for tmux's status bar.
//
// Environment:
//
//	LASTFM_USER     Last.fm username
//	LASTFM_API_KEY  Last.fm API key
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"time"
)

const (
	cacheTTL = 15 * time.Second
	width    = 40              // visible characters in the status bar
	step     = 2 * time.Second // scroll one character per step (match tmux status-interval)
	gap      = "   │   "       // separator between end and restart of the marquee
)

type response struct {
	RecentTracks struct {
		Track []struct {
			Name   string `json:"name"`
			Artist struct {
				Text string `json:"#text"`
			} `json:"artist"`
			Attr struct {
				NowPlaying string `json:"nowplaying"`
			} `json:"@attr"`
		} `json:"track"`
	} `json:"recenttracks"`
}

// parse returns "Artist - Title" if the newest track is playing now, else "".
func parse(body []byte) (string, error) {
	var r response
	if err := json.Unmarshal(body, &r); err != nil {
		return "", err
	}
	if len(r.RecentTracks.Track) == 0 {
		return "", nil
	}
	t := r.RecentTracks.Track[0]
	if t.Attr.NowPlaying != "true" {
		return "", nil
	}
	return t.Artist.Text + " - " + t.Name, nil
}

func fetch(user, key string) (string, error) {
	q := url.Values{
		"method":  {"user.getrecenttracks"},
		"user":    {user},
		"api_key": {key},
		"format":  {"json"},
		"limit":   {"1"},
	}
	c := http.Client{Timeout: 3 * time.Second}
	resp, err := c.Get("https://ws.audioscrobbler.com/2.0/?" + q.Encode())
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("last.fm: %s", resp.Status)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	return parse(body)
}

func cachePath() string {
	dir := os.Getenv("XDG_CACHE_HOME")
	if dir == "" {
		home, _ := os.UserHomeDir()
		dir = filepath.Join(home, ".cache")
	}
	return filepath.Join(dir, "nowplaying", "last")
}

func readCache() (string, bool) {
	p := cachePath()
	st, err := os.Stat(p)
	if err != nil || time.Since(st.ModTime()) > cacheTTL {
		return "", false
	}
	b, err := os.ReadFile(p)
	return string(b), err == nil
}

func writeCache(s string) {
	p := cachePath()
	if os.MkdirAll(filepath.Dir(p), 0o755) == nil {
		_ = os.WriteFile(p, []byte(s), 0o644)
	}
}

// window returns s unchanged if it fits in width, else a width-wide slice of
// the looping marquee "s<gap>s<gap>…" starting at an offset derived from now,
// so each invocation advances the scroll without keeping any state.
func window(s string, now time.Time) string {
	r := []rune(s)
	if len(r) <= width {
		return s
	}
	loop := append(r, []rune(gap)...)
	off := int(now.UnixNano()/int64(step)) % len(loop)
	out := make([]rune, width)
	for i := range out {
		out[i] = loop[(off+i)%len(loop)]
	}
	return string(out)
}

func render(song string) string {
	if song == "" {
		return ""
	}
	return "🔊 " + window(song, time.Now()) + " "
}

func main() {
	if song, ok := readCache(); ok {
		fmt.Print(render(song))
		return
	}
	user, key := os.Getenv("LASTFM_USER"), os.Getenv("LASTFM_API_KEY")
	if user == "" || key == "" {
		return // not configured on this machine: stay silent
	}
	song, err := fetch(user, key)
	if err != nil {
		return // offline etc: don't clutter the status bar
	}
	writeCache(song)
	fmt.Print(render(song))
}
