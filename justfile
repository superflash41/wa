# list available commands
default:
    @just --list

# build the binary
build:
	swift build -c release
	rm -f wa
	cp .build/release/wa .

# start the wallpaper app
run video="": build
	./wa start {{ if video == "" { "" } else { quote(video) } }}

# run the menu bar app in the foreground
app video="": build
	./wa app {{ if video == "" { "" } else { quote(video) } }}

# run the unit tests
test:
	swift test

# stop the wallpaper
stop: build
	./wa stop

# show status
status: build
	./wa status

# install agent
install video="": build
	./wa install-agent {{ if video == "" { "" } else { quote(video) } }} --executable ./wa

# remove agent
uninstall: build
	./wa uninstall-agent

# cleanup
clean:
	rm -rf wa .build
