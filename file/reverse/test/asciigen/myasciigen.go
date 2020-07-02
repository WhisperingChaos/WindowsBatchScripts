package myasciigen

import (
	"bytes"
	"os"
)

func Write() {
	ascii := make([]byte, 255)
	j := 0
	for i, _ := range ascii {
		if i == 0 || i == 13 || i == 10 || i == 26 {
			continue
		}
		ascii[j] = byte(i)
		j++
	}
	ascii[j] = byte(255)
	j++
	ascii[j] = byte(13)
	j++
	ascii[j] = byte(10)
	j++
	ascii[j] = byte(26)
	asciiTbl, _ := os.Create("asciiTbl.txt")
	asciiCodes := bytes.NewBuffer(ascii)
	asciiCodes.WriteTo(asciiTbl)
	asciiTbl.Close()
}
