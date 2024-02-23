package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
)

type StreamSegment struct {
	Duration float64 `json:"duration"`
	Offset   float64 `json:"offset"`
}
type Stream struct {
	StreamSegments []StreamSegment `json:"stream_segments"`
}
type PatchStreamRequest struct {
	Stream Stream `json:"stream"`
}

func main() {
	body := &bytes.Buffer{}

	w := multipart.NewWriter(body)
	w.WriteField("stream[stream_segments][][offset]", "0")
	w.WriteField("stream[stream_segments][][duration]", "4")

	f, err := os.Open("/Users/diane/Movies/2024-02-19 18-18-230.ts")
	if err != nil {
		panic(err)
	}
    part, err := w.CreateFormFile("stream[stream_segments][][source_video]", "2024-02-19 18-18-230.ts")
    if err != nil {
        panic(err)
    }
    io.Copy(part, f)

	w.Close()

	request, err := http.NewRequest(http.MethodPatch, "http://localhost:3000/streams/2PJsCtB2tJjsy3nVgERp3wR", body)

	request.Header.Set("Content-Type", w.FormDataContentType())
	fmt.Println(request)

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
