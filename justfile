clean:
	rm -rf zig-out zig-cache

build:
	zig build --release=safe
dbg:
	zig build
