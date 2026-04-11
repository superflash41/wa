default: build

# build the binary
build:
	swift build -c release
	rm -f wa
	cp .build/release/wa .

# start the wallpaper
run video="": build
	./wa start {{video}}

# stop the wallpaper
stop: build
	./wa stop

# show status
status: build
	./wa status

# clean compiled binaries
clean:
	rm -rf wa .build
