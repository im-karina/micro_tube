package main


import (
	"bufio"
	"bytes"
	"encoding/json"
    "path/filepath"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

type StreamSegment struct {
	Duration float64 `json:"duration"`
	Offset   float64 `json:"offset"`
}
type Stream struct {
	ID             string          `json:"id"`
	StreamSegments []StreamSegment `json:"stream_segments"`
}
type PatchStreamRequest struct {
	Stream Stream `json:"stream"`
}
type PostStreamRequest struct {
	StartUnixUsec int64 `json:"start_unix_usec"`
}
type PostStreamResponse struct {
	Stream Stream `json:"stream"`
}

const backend = "http://localhost:3000"

const backendPOSTUrl = backend + "/streams.json"
const backendPATCHUrl = backend + "/streams/%s.json"
const backendPOSTClipUrl = backend + "/stream_slices.json"

const clipsEnabled = true
const videoEnabled = true
const wowEnabled = true

var wg sync.WaitGroup

func main() {
	idCh = make(chan string)
	clipCh = make(chan Clip)

	if videoEnabled {
		wg.Add(1)
		go mainVideo()
	}
	if clipsEnabled {
		wg.Add(1)
		go mainClips()
	}
	if wowEnabled {
		wg.Add(1)
		go mainWow()
	}
	wg.Wait()
}

type Clip struct {
	Name      string
	StartTime time.Time
	EndTime   time.Time
}

var clipCh chan Clip

func mainWow() {
	defer wg.Done()

	assumedYear := time.Now().Year()

	clPath := os.Args[2]
	cl, err := os.OpenFile(clPath, os.O_RDONLY, 0)
	if err != nil {
		panic(err)
	}
	sc := bufio.NewScanner(cl)
	for {
		if !sc.Scan() {
			// todo: exponential backoff
			time.Sleep(1 * time.Second)
			continue
		}

		line := sc.Text()
		if strings.HasPrefix(line, "COMBAT_LOG_VERSION") {
			continue
		}

		var dateS, timeS, eventS string

		_, err = fmt.Sscanf(line, "%s %s  %s", &dateS, &timeS, &eventS)
		if err != nil {
			panic(err)
		}

		t, err := time.Parse("2006/1/2 15:04:05.000", strconv.Itoa(assumedYear)+"/"+dateS+" "+timeS)
		if err != nil {
			panic(err)
		}
		t = time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, t.Nanosecond(), t.Location())
		if t.Before(streamEpoch) {
			continue
		}
		if strings.HasPrefix(eventS, "UNIT_DIED") {
			clipCh <- Clip{"death", t.Add(-10 * time.Second), t.Add(5 * time.Second)}
		}

		t = t
	}
}

type PostClipRequest struct {
	StreamId      string `json:"stream_id"`
	StartUnixUsec int64  `json:"start_unix_usec"`
	EndUnixUsec   int64  `json:"end_unix_usec"`
}
type PostClipResponse struct {
	StreamSlice struct {
		ID string `json:'id'`
	} `json:"stream_slice"`
}

var id string
var streamEpoch time.Time
var idCh chan string

func mainClips() {
	defer wg.Done()

	id := <-idCh
	for {
		clip := <-clipCh
		body, err := json.Marshal(PostClipRequest{
			StreamId:      id,
			StartUnixUsec: clip.StartTime.UnixMicro(),
			EndUnixUsec:   clip.EndTime.UnixMicro(),
		})
		if err != nil {
			panic(err)
		}

		res, err := http.Post(backendPOSTClipUrl, "application/json", bytes.NewBuffer(body))
		if err != nil {
			panic(err)
		}
		resBody, err := io.ReadAll(res.Body)
		if err != nil {
			panic(err)
		}
		pcr := PostClipResponse{}
		err = json.Unmarshal(resBody, &pcr)
		fmt.Println("new clip:", pcr.StreamSlice.ID)
	}
}

func mainVideo() {
	defer wg.Done()

	m3u8Path := os.Args[1]
	m3u8Dir := filepath.Dir(m3u8Path)

	m3u8Data, err := os.ReadFile(m3u8Path)
	if err != nil {
		panic(err)
	}
	r := bufio.NewScanner(bytes.NewBuffer(m3u8Data))
	var firstTs time.Time

	for r.Scan() {

		line := r.Text()
		var tsStr string
		_, err := fmt.Sscanf(line, "#EXT-X-PROGRAM-DATE-TIME:%s", &tsStr)
		if err != nil {
			continue
		}
		firstTs, err = time.Parse("2006-01-02T15:04:05.000-0700", tsStr)
		if err != nil {
			panic(err)
		}

		break
	}
	streamEpoch = firstTs

	reqJson, err := json.Marshal(PostStreamRequest{
		StartUnixUsec: firstTs.UnixMicro(),
	})

	res, err := http.Post(backendPOSTUrl, "application/json", bytes.NewBuffer(reqJson))
	if err != nil {
		panic(err)
	}
	data, err := io.ReadAll(res.Body)
	if err != nil {
		panic(err)
	}

	postResponse := PostStreamResponse{}
	err = json.Unmarshal(data, &postResponse)
	if err != nil {
		panic(err)
	}

	id := postResponse.Stream.ID
	idCh <- id
	fmt.Println("stream id: ", id)

	uploaded := make(map[string]struct{})
	for {
		m3u8Data, err := os.ReadFile(m3u8Path)
		if err != nil {
			panic(err)
		}
		r := bufio.NewScanner(bytes.NewBuffer(m3u8Data))
		paths := []string{}
		durations := []float64{}
		offsets := []float64{}
		timestamps := []time.Time{}
		sequences := []int{}

		var offset float64 = 0
		var sequence int = 0

		for r.Scan() {

			line := r.Text()
			var newSequence int
			if _, err := fmt.Sscanf(line, "#EXT-X-MEDIA-SEQUENCE:%d", &newSequence); err == nil {
				sequence = newSequence
			}

			var duration float64
			if _, err := fmt.Sscanf(line, "#EXTINF:%f,", &duration); err == nil {
				r.Scan()
				fullTs := r.Text()
				r.Scan()
				path := r.Text()
				offset += duration

				var tsStr string
				fmt.Sscanf(fullTs, "#EXT-X-PROGRAM-DATE-TIME:%s", &tsStr)
				ts, err := time.Parse("2006-01-02T15:04:05.000-0700", tsStr)
				if err != nil {
					panic(err)
				}

				_, ok := uploaded[path]
				if !ok {
					fmt.Printf("[%f@%f] %s\n", duration, offset, path)
					paths = append(paths, path)
					durations = append(durations, duration)
					offsets = append(offsets, offset)
					timestamps = append(timestamps, ts)
					sequences = append(sequences, sequence)
					uploaded[path] = struct{}{}
				}
				sequence += 1
			}
		}

		if len(paths) > 0 {
			fmt.Println("Uploading new batch")
		}
		for i, path := range paths {
			body := &bytes.Buffer{}
			w := multipart.NewWriter(body)
			w.WriteField("stream[stream_segments][][offset]", "0")
			w.WriteField("stream[stream_segments][][duration]", fmt.Sprintf("%f", durations[i]))
			w.WriteField("stream[stream_segments][][start_unix_usec]", fmt.Sprintf("%d", timestamps[i].UnixMicro()))
			w.WriteField("stream[stream_segments][][sequence]", fmt.Sprintf("%d", sequences[i]))

            path := filepath.Join(m3u8Dir, path)
			f, err := os.Open(path)
			if err != nil {
				panic(err)
			}
			part, err := w.CreateFormFile("stream[stream_segments][][source_video]", path)
			if err != nil {
				panic(err)
			}
			io.Copy(part, f)

			w.Close()

			request, err := http.NewRequest(http.MethodPatch, fmt.Sprintf(backendPATCHUrl, id), body)

			request.Header.Set("Content-Type", w.FormDataContentType())

			client := &http.Client{}
			resp, err := client.Do(request)
			if err != nil {
				panic(err)
			}

			defer resp.Body.Close()

			_, err = io.ReadAll(resp.Body)
			if err != nil {
				log.Fatal(err)
			}
		}

		time.Sleep(50 * time.Millisecond)
	}
}
