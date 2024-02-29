package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
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
}
type PostStreamResponse struct {
    Stream Stream `json:"stream"`
}

const backend = "http://localhost:3000"

const backendPOSTUrl = backend + "/streams.json"
const backendPATCHUrl = backend + "/streams/%s.json"

func main() {
	res, err := http.Post(backendPOSTUrl, "application/json", bytes.NewBufferString(""))
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
    fmt.Println("stream id: ", id)
	m3u8Path := os.Args[1]

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
		var offset float64 = 0

		for r.Scan() {
			line := r.Text()
			var duration float64
			if _, err := fmt.Sscanf(line, "#EXTINF:%f,", &duration); err == nil {
				r.Scan()
				path := r.Text()
				offset += duration

				_, ok := uploaded[path]
				if !ok {
                    fmt.Printf("[%f@%f] %s\n", duration, offset, path)
					paths = append(paths, path)
					durations = append(durations, duration)
					offsets = append(offsets, offset)
					uploaded[path] = struct{}{}
				}
			}
		}

		for i, path := range paths {
			body := &bytes.Buffer{}
			w := multipart.NewWriter(body)
			w.WriteField("stream[stream_segments][][offset]", "0")
			w.WriteField("stream[stream_segments][][duration]", fmt.Sprintf("%f", durations[i]))

			f, err := os.Open("/Users/diane/Movies/" + path)
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

		time.Sleep(100 * time.Millisecond)
	}
}
