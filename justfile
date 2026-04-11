default: build

# build the executable
build:
	swiftc main.swift -o wa

# run the live wallpaper with a video file
run video_path: build
	./wa {{video_path}}

# clean compiled binaries
clean:
	rm -f wa main
