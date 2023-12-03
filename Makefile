# 變數定義
DAY := day1
PART := 1
FILE := input

# 主要目標
run:
	zig run src/$(DAY).zig --mod clap::.zigmod/deps/git/github.com/Hejsil/zig-clap/clap.zig --deps clap -- -p$(PART) -f$(FILE)
